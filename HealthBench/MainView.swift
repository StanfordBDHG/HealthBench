//
// This source file is part of the Stanford Biodesign Digital Health HealthBench project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct MainView: View {
    @Environment(BenchmarkProcessor.self) private var benchmark
    @State private var showShareSheet = false
    @State private var shareURL: URL?
    @AppStorage(StorageKeys.deleteModelWhenFinish) private var deleteModelWhenFinish = false
    @AppStorage(StorageKeys.selectedModels) private var selectedModels: [String] = []
    @AppStorage(StorageKeys.finishedModels) private var finishedModels: [String] = []
    @AppStorage(StorageKeys.onlySelectedCase) private var onlySelectedCase = false
    @AppStorage(StorageKeys.selectedCases) private var selectedCase: [String] = []
    @AppStorage(StorageKeys.maxOutputLength) private var maxOutputLength = 2048
    
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            listContent
                .sheet(isPresented: shareSheetBinding) { shareSheet }
                .fullScreenCover(isPresented: .constant(benchmark.running)) { runningCover }
                .sheet(isPresented: $showSettings) { SettingsSheetView() }
                .navigationTitle("HealthBench")
                .toolbar { settingsButton }
        }
    }
    
    private var listContent: some View {
        List {
            controlsSection
            startSection
            exportSection
        }
    }

    private var controlsSection: some View {
        Section {
            ModelSelectionView(selectedModels: $selectedModels, finishedModels: $finishedModels)
            CaseSelectionView(onlySelectedCase: $onlySelectedCase, selectedCase: $selectedCase)
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
    }

    private var startSection: some View {
        Section {
            Button("Start", action: benchmark.start)
        } footer: {
            Text("To stop the benchmark, quickly tap five times anywhere on the screen.")
        }
    }

    private var exportSection: some View {
        Section {
            Button("Export", action: export)
        } footer: {
            Text("Exporting can take a few seconds to complete.")
        }
    }

    private var shareSheetBinding: Binding<Bool> {
        Binding(
            get: { showShareSheet && shareURL != nil },
            set: { if !$0 { showShareSheet = false } }
        )
    }

    @ViewBuilder private var shareSheet: some View {
        if let shareURL {
            ShareSheet(sharedURL: shareURL)
        }
    }

    private var runningCover: some View {
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

    private var settingsButton: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button { showSettings = true } label: {
                Image(systemName: "gear")
                    .accessibilityLabel("Settings")
            }
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
