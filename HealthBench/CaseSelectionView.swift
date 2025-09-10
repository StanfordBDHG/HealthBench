//
// This source file is part of the Stanford Biodesign Digital Health HealthBench project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct CaseSelectionView: View {
    @Environment(BenchmarkProcessor.self) private var benchmark
    @Binding var onlySelectedCase: Bool
    @Binding var selectedCase: [String]

    var body: some View {
        Toggle("Run only selected cases", isOn: $onlySelectedCase)
        if onlySelectedCase {
            let selectedCaseCount = selectedCase.isEmpty ? "none" : "\(selectedCase.count)"
            DisclosureGroup("Select Case (\(selectedCaseCount))") {
                ForEach(benchmark.cases, id: \.id) { currentCase in
                    CaseSelectionCell(
                        id: currentCase.id,
                        isSelected: selectedCase.contains(currentCase.id),
                        toggle: { toggle(currentCase.id) }
                    )
                }
            }
        }
    }

    private func toggle(_ id: String) {
        if let idx = selectedCase.firstIndex(of: id) {
            selectedCase.remove(at: idx)
        } else {
            selectedCase.append(id)
        }
    }
}

struct CaseSelectionCell: View {
    let id: String
    let isSelected: Bool
    let toggle: () -> Void

    var body: some View {
        Button(action: toggle) {
            HStack {
                Text("CaseID: `\(id)`")
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            }
        }
    }
}
