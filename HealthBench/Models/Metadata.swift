//
// This source file is part of the Stanford Biodesign Digital Health HealthBench project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


// periphery:ignore - All the properties are encoded due to the codable conformance.
struct Metadata: Codable {
    let device: String
    let operatingSystem: String
    let totalStorage: String
    let freeStorage: String
    let totalMemory: String
}
