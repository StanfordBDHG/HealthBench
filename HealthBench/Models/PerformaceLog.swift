//
//  PerformaceLog.swift
//  HealthBench
//
//  Created by Leon Nissen on 1/23/25.
//

import Foundation


struct PerformaceLog {
    let timestamp: Double
    let cpu: Double
    let memory: String
    let thermalState: String
    let batteryLevel: Double
    let batteryState: String
    
    static let header = "timestamp,cpu,memory,thermalstate,batterylevel,batterystate"
    var csv: String {
        "\(timestamp),\(String(format: "%.2f", cpu)),\(memory),\(thermalState),\(String(format: "%.2f", batteryLevel)),\(batteryState)"
    }
}
