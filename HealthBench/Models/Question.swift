//
// This source file is part of the Stanford Biodesign Digital Health HealthBench project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


// periphery:ignore - All the properties are encoded due to the codable conformance.
struct Question: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "question_id"
        case caseID = "case_id"
        case questionStr = "question_str"
    }
    

    let id: String
    let caseID: String
    let questionStr: String
}
