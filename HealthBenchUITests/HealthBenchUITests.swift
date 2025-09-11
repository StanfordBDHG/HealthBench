//
// This source file is part of the Stanford Biodesign Digital Health HealthBench project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import XCTest


final class HealthBenchUITests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
    }
    
    
    @MainActor
    func testSuccessfulLaunch() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssert(app.staticTexts["HealthBench"].waitForExistence(timeout: 1))
    }
}
