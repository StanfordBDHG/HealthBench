//
// This source file is part of the Stanford Biodesign Digital Health HealthBench project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation

struct Case: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "case_id"
        case title = "case_title"
        case vignette = "case_vignette"
        case questions
    }
    
    let id: String
    let title: String
    let vignette: String
    let questions: [Question]
}
