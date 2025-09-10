//
// This source file is part of the Stanford Biodesign Digital Health HealthBench project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import CoreData

struct MainView: View {
    @Environment(BenchmarkProcessor.self) private var benchmark
    @State private var showShareSheet = false
    @State private var shareURL: URL? = nil
    @AppStorage(StorageKeys.deleteModelWhenFinish) private var deleteModelWhenFinish = false
    @AppStorage(StorageKeys.selectedModels) private var selectedModels: [String] = []
    @AppStorage(StorageKeys.finishedModels) private var finishedModels: [String] = []
    @AppStorage(StorageKeys.onlySelectedCase) private var onlySelectedCase = false
    @AppStorage(StorageKeys.selectedCases) private var selectedCase: [String] = []
    @AppStorage(StorageKeys.maxOutputLength) private var maxOutputLength = 2048
    
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    modelSelection
                    
                    caseSelection
                    
                    Toggle("Delete Model When Finish", isOn: $deleteModelWhenFinish)
                    
                    Picker("Max Output Length", selection: $maxOutputLength) {
                        Text("2048").tag(2048)
                        Text("4096").tag(4096)
                    }
                   
                    if benchmark.downloader.currentModel != nil && benchmark.downloader.currentProgress != nil {
                        Button("To cancel the download, kill the app") { }
                            .disabled(true)
                    } else {
                        Button("Predownload All Models") {
                            Task {
                                try await benchmark.downloader.loadAll()
                            }
                        }
                    }
                } footer: {
                    if let model = benchmark.downloader.currentModel,
                        let progress = benchmark.downloader.currentProgress {
                        Text("Downloading: \(model), \(String(format: "%.0f", progress.fractionCompleted * 100))%")
                    }
                }
                
                Section {
                    Button("Start", action: benchmark.start)
                } footer: {
                    Text("To stop the benchmark, quickly tap five times anywhere on the screen.")
                }
                
                Section {
                    Button("Export", action: export)
                } footer: {
                    Text("Exporting can take a few seconds to complete.")
                }
            }
            .sheet(
                isPresented: Binding(
                    get: { showShareSheet && shareURL != nil },
                    set: { if !$0 { showShareSheet = false } }
                )
            ) {
                if let shareURL {
                    ShareSheet(sharedURL: shareURL)
                }
            }
            .fullScreenCover(isPresented: .constant(benchmark.running)) {
                ZStack {
                    Color(.black)
                        .ignoresSafeArea()
                    Text(benchmark.status.joined(separator: "\n"))
                        .foregroundStyle(.white)
                }
                .ignoresSafeArea()
                .onTapGesture(count: 5, perform: benchmark.stop)
                .interactiveDismissDisabled()
                .persistentSystemOverlays(.hidden)
            }
            .sheet(isPresented: $showSettings) {
                List {
                    Section {
                        Button("Delete Data") {
                            Task {
                                PersistenceController.shared.deleteAll()
                            }
                        }.tint(.red)
                        
                        Button("Reset Config") {
                            Task {
                                UserDefaults.standard.removeObject(forKey: StorageKeys.finishedModels)
                                UserDefaults.standard.removeObject(forKey: StorageKeys.deleteModelWhenFinish)
                                UserDefaults.standard.removeObject(forKey: StorageKeys.onlySelectedCase)
                                UserDefaults.standard.removeObject(forKey: StorageKeys.selectedCases)
                                UserDefaults.standard.removeObject(forKey: StorageKeys.maxOutputLength)
                            }
                        }.tint(.red)
                        
                        Button("Delete Models") {
                            Task {
                                for model in StorageKeys.generatorModels {
                                    let _ = try? await benchmark.downloader.delete(model: model)
                                }
                            }
                        }.tint(.red)
                    }
                    
                    Section {
                        Button("Clear Cache") {
                            Task {
                                await benchmark.offloadLLM()
                            }
                        }.tint(.blue)
                    } footer: {
                        Text(FileManager.default.temporaryDirectory.absoluteString)
                            .font(.footnote)
                    }
                }
                .presentationDetents([.fraction(0.35), .large])
                .presentationDragIndicator(.visible)
            }
            .navigationTitle("HealthBench")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }

                }
            }
        }
    }
    
    @ViewBuilder
    private var modelSelection: some View {
        DisclosureGroup {
            ForEach(StorageKeys.generatorModels, id: \.self) { model in
                modelSelectionCell(model: model)
            }
        } label: {
            let modelCount = selectedModels.isEmpty ? "all" : "\(selectedModels.count)"
            Text("Selected Models (\(modelCount))")
        }
    }
    
    @ViewBuilder
    private func modelSelectionCell(model: String) -> some View {
        Button {
            modelSelected(model)
        } label: {
            VStack(alignment: .leading) {
                HStack {
                    Text("`\(model)`")
                    Spacer()
                    if selectedModels.contains(model) {
                        Image(systemName: "checkmark.circle.fill")
                    } else {
                        Image(systemName: "circle")
                    }
                }
                Text("Finished")
                    .foregroundStyle(.gray)
                    .font(.footnote)
                    .opacity(finishedModels.contains(model) ? 1 : 0)
            }
        }
    }
    
    @ViewBuilder
    private var caseSelection: some View {
        Toggle("Run only selected cases", isOn: $onlySelectedCase)
        
        if onlySelectedCase {
            let selectedCaseCount = selectedCase.isEmpty ? "none" : "\(selectedCase.count)"
            DisclosureGroup("Select Case (\(selectedCaseCount))") {
                ForEach(benchmark.cases, id: \.id) { currentCase in
                    caseSelectionCell(currentCase: currentCase)
                }
            }
        }
    }
    
    @ViewBuilder
    private func caseSelectionCell(currentCase: Case) -> some View {
        Button {
            if selectedCase.contains(currentCase.id) {
                selectedCase.removeAll { $0 == currentCase.id }
            } else {
                selectedCase.append(currentCase.id)
            }
        } label: {
            HStack {
                Text("CaseID: `\(currentCase.id)`")
                Spacer()
                if selectedCase.contains(currentCase.id) {
                    Image(systemName: "checkmark.circle.fill")
                } else {
                    Image(systemName: "circle")
                }
            }
        }
    }
    
    
    private func modelSelected(_ model: String) {
        if selectedModels.contains(model) {
            selectedModels.removeAll { $0 == model }
        } else {
            selectedModels.append(model)
        }
    }
    
    
    
    private func export() {
        if let url = PersistenceController.shared.export() {
            shareURL = url
            showShareSheet = true
            print(url)
        } else {
            print("Failed to generate export URL")
        }
    }
}
