//
//  MajorUITests.swift
//  MajorUITests
//
//  Created by Alejandro Ruperez Hernando on 28/2/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import XCTest
import Kommander

class MajorUITests: XCTestCase {

    let application = XCUIApplication()
        
    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        application.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSingleAction() {
        application.buttons["Execute single Kommand"].tap()
        sleep(3)
    }

    func testConcurrentAction() {
        application.buttons["Execute concurrent Kommands"].tap()
        sleep(3)
    }

    func testSequentialAction() {
        application.buttons["Execute sequential Kommands"].tap()
        sleep(9)
    }

    func testErrorAction() {
        application.buttons["Execute error Kommand"].tap()
        sleep(3)
    }

    func testCrashAction() {
        application.buttons["Execute crash Kommand"].tap()
    }
    
}
