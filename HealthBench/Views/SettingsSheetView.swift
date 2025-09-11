//
// This source file is part of the Stanford Biodesign Digital Health HealthBench project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct SettingsSheetView: View {
    @Environment(BenchmarkProcessor.self) private var benchmark

    var body: some View {
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
                            _ = try? await benchmark.downloader.delete(model: model)
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
}
