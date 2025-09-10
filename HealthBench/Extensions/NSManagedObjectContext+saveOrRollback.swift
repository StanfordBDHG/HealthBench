//
// This source file is part of the Stanford Biodesign Digital Health HealthBench project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import CoreData


extension NSManagedObjectContext {
    /**
     Attempt to save the context to storage, rollingback if the save fails.
     
     - returns: true if saved
     */
    @discardableResult
    func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            print(error)
            rollback()
            return false
        }
    }
}
