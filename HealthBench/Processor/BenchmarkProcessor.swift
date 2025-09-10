//
//  BenchmarkProcessor.swift
//  HealthBench
//
//  Created by Leon Nissen on 1/23/25.
//

import Spezi
import SpeziLLM
import SpeziLLMLocal
import SwiftUI
import MLX


@Observable
class BenchmarkProcessor: DefaultInitializable, Module, EnvironmentAccessible {
    private(set) var running = false
    private(set) var status: [String] = []
    private(set) var currentModel: String = ""
    private(set) var finishedModels: [String] {
        get {
            UserDefaults.standard.stringArray(forKey: StorageKeys.finishedModels) ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: StorageKeys.finishedModels)
        }
    }
    @ObservationIgnored private var benchmarkTask: Task<(), Never>? = nil
    @ObservationIgnored let cases: [Case]
    @ObservationIgnored @Dependency(Downloader.self) var downloader = Downloader()
    @ObservationIgnored @Dependency(LLMRunner.self) private var runner
    @ObservationIgnored private var session: LLMLocalSession?
    
    required init() {
        guard let url = Bundle.main.url(forResource: "cases", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let cases = try? JSONDecoder().decode([Case].self, from: data) else {
            fatalError("Cannot parse cases")
        }
        self.cases = cases
    }
    
    func start() {
        guard ProcessInfo.processInfo.isLowPowerModeEnabled == false else { return }
        
        UIApplication.shared.isIdleTimerDisabled = true
        running = true
        PerformanceProcessor.shared.start()
        
        guard var selectedModels = Array<String>(rawValue: UserDefaults.standard.string(forKey: StorageKeys.selectedModels) ?? "[]") else {
            Task { @MainActor in
                stop()
            }
            return
        }
        
        if selectedModels.isEmpty {
            selectedModels = StorageKeys.generatorModels
        }
        
        print("selectedModels", selectedModels)
        
        benchmarkTask = Task(priority: .userInitiated) {
            modelLoop: for (modelIndex, model) in selectedModels.enumerated() {
                if benchmarkTask?.isCancelled ?? true {
                    return
                }
                currentModel = model
                
                print("finishedModels", finishedModels)
                
                // already benched?
                if finishedModels.contains(model) {
                    continue
                }
               
                // download
                do {
                    status = ["Downloading Model: \(model)"]
                    try await downloader.load(model: model)
                } catch {
                    print("cannot download", model)
                    print(error)
                    continue
                }
                
                if benchmarkTask?.isCancelled ?? true {
                    return
                }
                
                // load into memory
                status = ["Load Model: \(model)"]
                let llmModel = LLMLocalModel.custom(id: model)
                
                do {
                    if !(benchmarkTask?.isCancelled ?? true) {
                        try await setupLLM(model: llmModel)
                    }
                } catch {
                    print("cannot setup LLM", model)
                    print(error)
                    continue
                }
                
                // benchmark each case
                for currentCase in cases {
                    if UserDefaults.standard.bool(forKey: StorageKeys.onlySelectedCase),
                       let selectedCases = Array<String>(rawValue: UserDefaults.standard.string(forKey: StorageKeys.selectedCases) ?? "[]"),
                       !selectedCases.contains(currentCase.id) {
                        continue
                    }
                    
                    // benchmark each question in this case
                    for currentQuestion in currentCase.questions {
                        if benchmarkTask?.isCancelled ?? true {
                            break modelLoop
                        }
                        
                        status = [
                            "Model: \(modelIndex + 1)/\(selectedModels.count)",
                            "Case: \(currentCase.id)/\(cases.count)",
                            "Question: \(currentQuestion.id)/\(currentCase.questions.count)"
                        ]
                        
                        while case .critical = ProcessInfo.processInfo.thermalState {
                            if let last = status.last,
                               !last.contains("Overheating") {
                                status.append("Overheating ThermalState: \(ProcessInfo.processInfo.thermalState)")
                            }
                            do {
                                try await Task.sleep(for: .seconds(10))
                            } catch {
                                break
                            }
                        }
                        
                        do {
                            if benchmarkTask?.isCancelled ?? true {
                                return
                            }
                            let started = Date()
                            let generationResponse = try await executeLLM(currentCase: currentCase, currentQuestion: currentQuestion)
                            let ended = Date()
                            
                            PersistenceController.shared.saveAnswer(
                                model: model,
                                caseID: currentCase.id,
                                questionID: currentQuestion.id,
                                question: currentQuestion.questionStr,
                                generatorResponse: generationResponse?.output ?? "No response from generation model",
                                started: started,
                                ended: ended,
                                inputTime: generationResponse?.promptTime ?? -1,
                                inputTokenPerSec: generationResponse?.promptTokensPerSecond ?? -1,
                                inputTokenCount: Double(generationResponse?.inputTokens.count ?? -1),
                                outputTime: generationResponse?.generateTime ?? -1,
                                outputTokenPerSec: generationResponse?.tokensPerSecond ?? -1,
                                outputTokenCount: Double(generationResponse?.outputTokens.count ?? -1)
                            )
                            MLX.GPU.clearCache()
                        } catch {
                            print("cannot bench question", currentCase.id, currentQuestion.id)
                            print(error)
                            continue
                        }
                    }
                }
                
                if benchmarkTask?.isCancelled ?? true {
                    return
                }
                
                await offloadLLM()

                // add to finished
                finishedModels.append(model)
                if !UserDefaults.standard.bool(forKey: StorageKeys.deleteModelWhenFinish) {
                    do {
                        try await downloader.delete(model: model)
                    } catch {
                        print("cannot delete", model)
                        print(error)
                        continue
                    }
                }
            }
            await stop()
        }
    }
    
    @MainActor
    func stop() {
        benchmarkTask?.cancel()
        session?.cancel()
        PerformanceProcessor.shared.stop()
        currentModel = ""
        status = []
        running = false
        PersistenceController.shared.save()
        UIApplication.shared.isIdleTimerDisabled = false
        Task {
            await offloadLLM()
        }
    }
    
    
    private func setupLLM(model: LLMLocalModel) async throws {
        var maxOutputLength = UserDefaults.standard.integer(forKey: StorageKeys.maxOutputLength)
        if maxOutputLength == 0 {
            maxOutputLength = 2048
        }
        
        print("setupLLM", maxOutputLength)
        let schema = LLMLocalSchema(
            model: model,
            parameters: LLMLocalParameters(maxOutputLength: maxOutputLength, displayEveryNTokens: 20), // TODO: SET
            samplingParameters: LLMLocalSamplingParameters(temperature: 0.1), // TODO: SET
            injectIntoContext: false
        )
        let session = runner(with: schema)
        try await session.setup()
        self.session = session
    }
    
    
    private func executeLLM(currentCase: Case, currentQuestion: Question) async throws -> LLMLocalGenerationResult? {
        guard let session else { return nil }
        
        let context = generateContext(currentCase: currentCase, currentQuestion: currentQuestion)
        await MainActor.run {
            session.customContext = context
        }
        
        async let generate: AsyncThrowingStream<LLMLocalGenerateState, Error> = session.generate()
        for try await state in try await generate {
            guard case .final(let result) = state else {
                continue
            }
            return result
        }
        
        return nil
    }
    
    func offloadLLM() async {
        guard let session = session else { return }
        await session.offload()
        self.session = nil
    }
    
    private func generateContext(currentCase: Case, currentQuestion: Question) -> [[String: String]] {
        [
            [
                "role": "user",
                "content": """
                Initial Case: \(currentCase.vignette)
                
                Question: \(currentQuestion.questionStr)
                """
            ]
        ]
    }
}
