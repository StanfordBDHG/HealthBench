//
//  HealthBenchApp.swift
//  HealthBench
//
//  Created by Leon Nissen on 1/22/25.
//

import SwiftUI

@main
struct HealthBenchApp: App {
    @UIApplicationDelegateAdaptor(HealthBenchAppDelegate.self) private var appDelegate
    private let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .spezi(appDelegate)
        }
    }
}
