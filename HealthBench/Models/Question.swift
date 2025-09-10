//
//  Question.swift
//  HealthBench
//
//  Created by Leon Nissen on 1/23/25.
//

import Foundation

struct Question: Codable {
    let id: String
    let caseID: String
    let questionStr: String
    
    enum CodingKeys: String, CodingKey {
        case id = "question_id"
        case caseID = "case_id"
        case questionStr = "question_str"
    }
}
