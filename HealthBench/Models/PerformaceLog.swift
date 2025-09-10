//
// This source file is part of the Stanford Biodesign Digital Health HealthBench project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


struct PerformaceLog {
    static let header = "timestamp,cpu,memory,thermalstate,batterylevel,batterystate"
    

    let timestamp: Double
    let cpu: Double
    let memory: String
    let thermalState: String
    let batteryLevel: Double
    let batteryState: String
    

    var csv: String {
        "\(timestamp),\(String(format: "%.2f", cpu)),\(memory),\(thermalState),\(String(format: "%.2f", batteryLevel)),\(batteryState)"
    }
}
