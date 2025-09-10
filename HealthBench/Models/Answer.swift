//
//  Answer.swift
//  HealthBench
//
//  Created by Leon Nissen on 1/24/25.
//

import Foundation
import CoreData


class Answer: NSManagedObject, Encodable {
    enum CodingKeys: CodingKey {
        case id
        case model
        case caseID
        case questionID
        case question
        case generatorResponse
        case started
        case ended
        case inputTime
        case inputTokenPerSec
        case inputTokenCount
        case outputTime
        case outputTokenPerSec
        case outputTokenCount
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(model, forKey: .model)
        try container.encode(caseId, forKey: .caseID)
        try container.encode(questionId, forKey: .questionID)
        try container.encode(questionStr, forKey: .question)
        try container.encode(generatorResponseStr, forKey: .generatorResponse)
        try container.encode(startedDate, forKey: .started)
        try container.encode(finishedDate, forKey: .ended)
        try container.encode(inputTime, forKey: .inputTime)
        try container.encode(inputTokenPerSec, forKey: .inputTokenPerSec)
        try container.encode(inputTokenCount, forKey: .inputTokenCount)
        try container.encode(outputTime, forKey: .outputTime)
        try container.encode(outputTokenPerSec, forKey: .outputTokenPerSec)
        try container.encode(outputTokenCount, forKey: .outputTokenCount)
    }
}
