//
//  Case.swift
//  HealthBench
//
//  Created by Leon Nissen on 1/23/25.
//

import Foundation

struct Case: Codable {
    let id: String
    let title: String
    let vignette: String
    let questions: [Question]
    
    enum CodingKeys: String, CodingKey {
        case id = "case_id"
        case title = "case_title"
        case vignette = "case_vignette"
        case questions
    }
}
