//
// This source file is part of the Stanford Biodesign Digital Health HealthBench project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import MLX
import Spezi
import SpeziLLM
import SpeziLLMLocal
import SwiftUI


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
    @ObservationIgnored private var benchmarkTask: Task<(), Never>?
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
        guard ProcessInfo.processInfo.isLowPowerModeEnabled == false else {
            return
        }
        
        setupBenchmarkEnvironment()
        let selectedModels = getSelectedModels()
        startBenchmarkTask(with: selectedModels)
    }
    
    private func setupBenchmarkEnvironment() {
        UIApplication.shared.isIdleTimerDisabled = true
        running = true
        PerformanceProcessor.shared.start()
    }
    
    private func getSelectedModels() -> [String] {
        guard var selectedModels = [String](rawValue: UserDefaults.standard.string(forKey: StorageKeys.selectedModels) ?? "[]") else {
            return []
        }
        
        if selectedModels.isEmpty {
            selectedModels = StorageKeys.generatorModels
        }
        
        print("selectedModels", selectedModels)
        return selectedModels
    }
    
    private func startBenchmarkTask(with selectedModels: [String]) {
        benchmarkTask = Task(priority: .userInitiated) {
            await processModels(selectedModels)
            await stop()
        }
    }
    
    private func processModels(_ selectedModels: [String]) async {
        for (modelIndex, model) in selectedModels.enumerated() {
            if benchmarkTask?.isCancelled ?? true {
                return
            }
            currentModel = model
            
            print("finishedModels", finishedModels)
            
            // already benched?
            if finishedModels.contains(model) {
                continue
            }
            
            do {
                try await downloadAndSetupModel(model)
                try await benchmarkModel(model, modelIndex: modelIndex, totalModels: selectedModels.count)
                await cleanupModel(model)
            } catch {
                print("Error processing model \(model): \(error)")
                continue
            }
        }
    }
    
    private func downloadAndSetupModel(_ model: String) async throws {
        // download
        status = ["Downloading Model: \(model)"]
        try await downloader.load(model: model)
        
        if benchmarkTask?.isCancelled ?? true {
            throw CancellationError()
        }
        
        // load into memory
        status = ["Load Model: \(model)"]
        let llmModel = LLMLocalModel.custom(id: model)
        
        if !(benchmarkTask?.isCancelled ?? true) {
            try await setupLLM(model: llmModel)
        }
    }
    
    private func benchmarkModel(_ model: String, modelIndex: Int, totalModels: Int) async throws {
        for currentCase in cases {
            if shouldSkipCase(currentCase) {
                continue
            }
            
            for currentQuestion in currentCase.questions {
                if benchmarkTask?.isCancelled ?? true {
                    return
                }
                
                try await processQuestion(
                    model: model,
                    currentCase: currentCase,
                    currentQuestion: currentQuestion,
                    modelIndex: modelIndex,
                    totalModels: totalModels
                )
            }
        }
    }
    
    private func shouldSkipCase(_ currentCase: Case) -> Bool {
        if UserDefaults.standard.bool(forKey: StorageKeys.onlySelectedCase),
           let selectedCases = [String](rawValue: UserDefaults.standard.string(forKey: StorageKeys.selectedCases) ?? "[]"),
           !selectedCases.contains(currentCase.id) {
            return true
        }
        return false
    }
    
    private func processQuestion(
        model: String,
        currentCase: Case,
        currentQuestion: Question,
        modelIndex: Int,
        totalModels: Int
    ) async throws {
        status = [
            "Model: \(modelIndex + 1)/\(totalModels)",
            "Case: \(currentCase.id)/\(cases.count)",
            "Question: \(currentQuestion.id)/\(currentCase.questions.count)"
        ]
        
        try await waitForAcceptableThermalState()
        
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
    }
    
    private func waitForAcceptableThermalState() async throws {
        while case .critical = ProcessInfo.processInfo.thermalState {
            if let last = status.last,
               !last.contains("Overheating") {
                status.append("Overheating ThermalState: \(ProcessInfo.processInfo.thermalState)")
            }
            try await Task.sleep(for: .seconds(10))
        }
    }
    
    private func cleanupModel(_ model: String) async {
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
            }
        }
    }
    
    @MainActor
    func stop() {
        downloader.cancel()
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
            parameters: LLMLocalParameters(maxOutputLength: maxOutputLength, displayEveryNTokens: 20),
            samplingParameters: LLMLocalSamplingParameters(temperature: 0.1),
            injectIntoContext: false
        )
        let session = runner(with: schema)
        try await session.setup()
        self.session = session
    }
    
    
    private func executeLLM(currentCase: Case, currentQuestion: Question) async throws -> LLMLocalGenerationResult? {
        guard let session else {
            return nil
        }
        
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
        guard let session = session else {
            return
        }
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
