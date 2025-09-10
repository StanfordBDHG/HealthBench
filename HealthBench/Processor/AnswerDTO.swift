//
// This source file is part of the Stanford Biodesign Digital Health HealthBench project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


struct AnswerDTO {
    let model: String
    let caseID: String
    let questionID: String
    let question: String
    let generatorResponse: String
    let started: Date
    let ended: Date
    let inputTime: Double
    let inputTokenPerSec: Double
    let inputTokenCount: Double
    let outputTime: Double
    let outputTokenPerSec: Double
    let outputTokenCount: Double
}
