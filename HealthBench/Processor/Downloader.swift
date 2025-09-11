//
// This source file is part of the Stanford Biodesign Digital Health HealthBench project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Hub
import Spezi
import SwiftUI


@Observable
class Downloader: DefaultInitializable, Module {
    private(set) var currentModel: String?
    private(set) var currentProgress: Progress?
    @ObservationIgnored private var api = HubApi()
    
    required init() { }
    
    func load(model: String) async throws {
        try await api.snapshot(
            from: model,
            matching: StorageKeys.modelFiles,
            progressHandler: updateProgress(_:)
        )
        
        currentModel = nil
        currentProgress = nil
    }
    
    @MainActor
    func cancel() {
        currentProgress?.cancel()
        
        currentModel = nil
        currentProgress = nil
    }
    
    
    func delete(model: String) async throws {
        let url = api.localRepoLocation(.init(id: model))
        let files = try await api.getFilenames(from: model)
        
        for file in files {
            let fileURL = url.appending(path: file)
            guard let _ = try? FileManager.default.removeItem(at: fileURL) else {
                continue
            }
        }
    }
    
    func loadAll() async throws {
        await MainActor.run {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        
        guard let selectedModels = [String](rawValue: UserDefaults.standard.string(forKey: StorageKeys.selectedModels) ?? "[]") else {
            await MainActor.run {
                UIApplication.shared.isIdleTimerDisabled = false
            }
            return
        }
        
        for (index, model) in selectedModels.enumerated() {
            currentModel = "(\(index + 1)/\(selectedModels.count)) \(model)"
            try await load(model: model)
        }
        
        await MainActor.run {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    private func updateProgress(_ progress: Progress) {
        currentProgress = progress
    }
}
