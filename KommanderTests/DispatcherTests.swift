//
//  DispatcherTests.swift
//  Kommander
//
//  Created by Alejandro Ruperez Hernando on 13/3/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import XCTest
@testable import Kommander

class DispatcherTests: XCTestCase {

    var dispatcher: Dispatcher!
    
    override func setUp() {
        super.setUp()
        dispatcher = .default
    }
    
    override func tearDown() {
        dispatcher = nil
        super.tearDown()
    }
    
    func testDefaultDispatcherMaxConcurrentOperationCount() {
        XCTAssertEqual(dispatcher.operationQueue.maxConcurrentOperationCount, OperationQueue.defaultMaxConcurrentOperationCount)
    }

    func testDefaultDispatcherQualityOfService() {
        XCTAssertEqual(dispatcher.operationQueue.qualityOfService, .default)
    }

    func testDefaultDispatcherOperationQueue() {
        if let operation = dispatcher.execute({ sleep(2) }) as? Operation {
            XCTAssertGreaterThan(dispatcher.operationQueue.operationCount, 0)
            operation.cancel()
            XCTAssertTrue(operation.isCancelled)
        } else {
            XCTFail("Default dispatcher isn't using OperationQueue.")
        }
    }

    func testDefaultDispatcherDispatchQueue() {
        let dispatchWorkItem = DispatchWorkItem(qos: .default, flags: .assignCurrentContext) { sleep(2) }
        dispatcher.execute(dispatchWorkItem)
        XCTAssertFalse(dispatchWorkItem.isCancelled)
        dispatchWorkItem.cancel()
        XCTAssertTrue(dispatchWorkItem.isCancelled)
    }

    func testCustomDispatcherOperationQueue() {
        let randomName = UUID().uuidString
        dispatcher = Dispatcher(name: randomName, qos: .background, maxConcurrentOperationCount: 1)
        XCTAssertEqual(dispatcher.operationQueue.name, randomName)
        XCTAssertEqual(dispatcher.operationQueue.maxConcurrentOperationCount, 1)
        XCTAssertEqual(dispatcher.operationQueue.qualityOfService, .background)
        if let operation = dispatcher.execute({ sleep(2) }) as? Operation {
            XCTAssertGreaterThan(dispatcher.operationQueue.operationCount, 0)
            operation.cancel()
            XCTAssertTrue(operation.isCancelled)
        } else {
            XCTFail("Custom dispatcher isn't using OperationQueue.")
        }
    }

    func testMainDispatcherOperationQueue() {
        dispatcher = .main
        if let operation = dispatcher.execute({ sleep(2) }) as? Operation {
            XCTAssertEqual(dispatcher.operationQueue, OperationQueue.main)
            XCTAssertGreaterThan(dispatcher.operationQueue.operationCount, 0)
            operation.cancel()
            XCTAssertTrue(operation.isCancelled)
        } else {
            XCTFail("Main dispatcher isn't using OperationQueue.")
        }
    }

    func testMainDispatcherDispatchQueue() {
        dispatcher = .main
        let dispatchWorkItem = DispatchWorkItem(qos: .default, flags: .assignCurrentContext) { sleep(2) }
        dispatcher.execute(dispatchWorkItem)
        XCTAssertEqual(dispatcher.dispatchQueue, DispatchQueue.main)
        XCTAssertFalse(dispatchWorkItem.isCancelled)
        dispatchWorkItem.cancel()
        XCTAssertTrue(dispatchWorkItem.isCancelled)
    }

    func testCurrentDispatcherOperationQueue() {
        let operationQueue = OperationQueue()
        operationQueue.addOperation {
            self.dispatcher = .current
            if let operation = self.dispatcher.execute({ sleep(2) }) as? Operation {
                XCTAssertGreaterThan(self.dispatcher.operationQueue.operationCount, 0)
                operation.cancel()
                XCTAssertTrue(operation.isCancelled)
            } else {
                XCTFail("Current dispatcher isn't using OperationQueue.")
            }
        }
    }

    func testCurrentDispatcherDispatchQueue() {
        let dispatchQueue = DispatchQueue(label: "")
        dispatchQueue.async {
            self.dispatcher = .current
            let dispatchWorkItem = DispatchWorkItem(qos: .default, flags: .assignCurrentContext) { sleep(2) }
            self.dispatcher.execute(dispatchWorkItem)
            XCTAssertFalse(dispatchWorkItem.isCancelled)
            dispatchWorkItem.cancel()
            XCTAssertTrue(dispatchWorkItem.isCancelled)
        }
    }

}
