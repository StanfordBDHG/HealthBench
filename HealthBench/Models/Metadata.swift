//
//  Metadata.swift
//  HealthBench
//
//  Created by Leon Nissen on 1/23/25.
//

import Foundation


struct Metadata: Codable {
    let device: String
    let os: String
    let totalStorage: String
    let freeStorage: String
    let totalMemory: String
}
