//
// This source file is part of the Stanford Biodesign Digital Health HealthBench project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import CoreData
import Foundation
import os


struct PersistenceController {
    static let shared = PersistenceController()
    
    private let logger = Logger(subsystem: "HealthBench", category: "Persistance")

    let container: NSPersistentContainer
    private let backgroundContext: NSManagedObjectContext

    init() {
        container = NSPersistentContainer(name: "HealthBench")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                print("[StorageProcessor ERROR]", error.localizedDescription)
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext = container.newBackgroundContext()
    }
    
    func save() {
        container.viewContext.saveOrRollback()
        backgroundContext.saveOrRollback()
    }
    
    
    // swiftlint:disable:next function_parameter_count - The number of parameters is representative of the Answer type which we generate here.
    func saveAnswer(
        model: String,
        caseID: String,
        questionID: String,
        question: String,
        generatorResponse: String,
        started: Date,
        ended: Date,
        inputTime: Double,
        inputTokenPerSec: Double,
        inputTokenCount: Double,
        outputTime: Double,
        outputTokenPerSec: Double,
        outputTokenCount: Double
    ) {
        let answer = Answer(context: backgroundContext)
        answer.id = UUID()
        answer.model = model
        answer.caseId = caseID
        answer.questionId = questionID
        answer.questionStr = question
        answer.generatorResponseStr = generatorResponse
        
        answer.startedDate = started.timeIntervalSince1970
        answer.finishedDate = ended.timeIntervalSince1970
        
        answer.inputTokenPerSec = inputTokenPerSec
        answer.inputTokenCount = inputTokenCount
        answer.inputTime = inputTime
        
        answer.outputTokenPerSec = outputTokenPerSec
        answer.outputTokenCount = outputTokenCount
        answer.outputTime = outputTime
        
        backgroundContext.saveOrRollback()
    }
    
    func savePerformace(_ data: [PerformaceLog]) {
        let csv = data.map(\.csv).joined(by: "\n")
        
        let performace = Performance(context: backgroundContext)
        performace.data = String(csv)
        backgroundContext.saveOrRollback()
    }
    
    func export() -> URL? {
        guard let folderURL = createFolder(name: "export-\(UUID().uuidString)") else {
            return nil
        }
        
        do {
            try exportAnswers(to: folderURL)
            try exportPerformance(to: folderURL)
            try exportMetadata(to: folderURL)
        } catch {
            print(error)
        }
        return folderURL
    }
    
    func deleteAll() {
        for entity in ["Performance", "Answer"] {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try container.viewContext.execute(request)
            } catch {
                print(error)
                continue
            }
        }
    }
    
    private func exportAnswers(to folderURL: URL) throws {
        let request = Answer.fetchRequest()
        let result = try container.viewContext.fetch(request)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let encoded = try encoder.encode(result)
        
        writeToFile(name: "answer.json", data: encoded, directory: folderURL)
    }
    
    private func exportPerformance(to folderURL: URL) throws {
        let request = Performance.fetchRequest()
        let result = try container.viewContext.fetch(request)
        
        let performanceData = String(result.compactMap(\.data).joined(by: "\n"))
        
        guard let data = performanceData.data(using: .utf8) else {
            print("cannot convert performance log csv to data")
            return
        }
        
        writeToFile(name: "performance.csv", data: data, directory: folderURL)
    }
    
    private func exportMetadata(to folderURL: URL) throws {
        let metadata = PerformanceProcessor.systemMetadata
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(metadata)
        
        writeToFile(name: "metadata.json", data: data, directory: folderURL)
    }
    
    private func createFolder(name: String, in directory: URL? = nil, deleteExsisting: Bool = false) -> URL? {
        var path = directory ?? FileManager.default.temporaryDirectory
        path = path.appending(component: name, directoryHint: .isDirectory)
        
        do {
            if deleteExsisting && FileManager.default.fileExists(atPath: path.relativePath) {
                try FileManager.default.removeItem(at: path)
            }
            
            if FileManager.default.fileExists(atPath: path.relativePath) {
                return path
            }
            
            try FileManager.default.createDirectory(at: path, withIntermediateDirectories: false)
            return path
        } catch {
            logger.error("\(error.localizedDescription)")
            return nil
        }
    }
    
    
    @discardableResult
    private func writeToFile(name: String, data: Data, directory: URL? = nil) -> URL? {
        var path = directory ?? FileManager.default.temporaryDirectory
        path = path.appending(component: name, directoryHint: .notDirectory)
        
        do {
            try data.write(to: path)
            return path
        } catch {
            logger.error("\(error.localizedDescription)")
            return nil
        }
    }
}
