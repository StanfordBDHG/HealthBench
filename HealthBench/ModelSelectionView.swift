//
// This source file is part of the Stanford Biodesign Digital Health HealthBench project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ModelSelectionView: View {
    @Binding var selectedModels: [String]
    @Binding var finishedModels: [String]

    var body: some View {
        DisclosureGroup {
            ForEach(StorageKeys.generatorModels, id: \.self) { model in
                ModelSelectionCell(
                    model: model,
                    isSelected: selectedModels.contains(model),
                    isFinished: finishedModels.contains(model),
                    toggleSelection: { toggle(model) }
                )
            }
        } label: {
            let modelCount = selectedModels.isEmpty ? "all" : "\(selectedModels.count)"
            Text("Selected Models (\(modelCount))")
        }
    }

    private func toggle(_ model: String) {
        if let idx = selectedModels.firstIndex(of: model) {
            selectedModels.remove(at: idx)
        } else {
            selectedModels.append(model)
        }
    }
}

struct ModelSelectionCell: View {
    let model: String
    let isSelected: Bool
    let isFinished: Bool
    let toggleSelection: () -> Void

    var body: some View {
        Button(action: toggleSelection) {
            VStack(alignment: .leading) {
                HStack {
                    Text("`\(model)`")
                    Spacer()
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                }
                Text("Finished")
                    .foregroundStyle(.gray)
                    .font(.footnote)
                    .opacity(isFinished ? 1 : 0)
            }
        }
    }
}
