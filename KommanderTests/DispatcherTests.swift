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
        dispatcher = Dispatcher()
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
        let dispatchWorkItem = dispatcher.execute(qos: nil, flags: nil) { sleep(2) }
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

    func testCustomDispatcherDispatchQueue() {
        let randomName = UUID().uuidString
        dispatcher = Dispatcher(label: randomName, qos: .background, attributes: nil, autoreleaseFrequency: nil, target: nil)
        XCTAssertEqual(dispatcher.dispatchQueue.label, randomName)
        XCTAssertEqual(dispatcher.dispatchQueue.qos, .background)
        if let dispatchWorkItem = dispatcher.execute({ sleep(2) }) as? DispatchWorkItem {
            XCTAssertFalse(dispatchWorkItem.isCancelled)
            dispatchWorkItem.cancel()
            XCTAssertTrue(dispatchWorkItem.isCancelled)
        } else {
            XCTFail("Custom dispatcher isn't using DispatchQueue.")
        }
    }

    func testMainDispatcherOperationQueue() {
        dispatcher = MainDispatcher()
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
        dispatcher = MainDispatcher()
        let dispatchWorkItem = dispatcher.execute(qos: nil, flags: nil, block: { sleep(2) })
        XCTAssertEqual(dispatcher.dispatchQueue, DispatchQueue.main)
        XCTAssertFalse(dispatchWorkItem.isCancelled)
        dispatchWorkItem.cancel()
        XCTAssertTrue(dispatchWorkItem.isCancelled)
    }

    func testCurrentDispatcherOperationQueue() {
        let operationQueue = OperationQueue()
        operationQueue.addOperation {
            self.dispatcher = CurrentDispatcher()
            if let operation = self.dispatcher.execute({ sleep(2) }) as? Operation {
                XCTAssertEqual(self.dispatcher.operationQueue, operationQueue)
                XCTAssertGreaterThan(self.dispatcher.operationQueue.operationCount, 0)
                operation.cancel()
                XCTAssertTrue(operation.isCancelled)
            } else {
                XCTFail("Current dispatcher isn't using OperationQueue.")
            }
        }
    }

    func testCurrentDispatcherDispatchQueue() {
        let dispatchQueue = DispatchQueue(label: "test")
        dispatchQueue.async {
            self.dispatcher = CurrentDispatcher()
            let dispatchWorkItem = self.dispatcher.execute(qos: nil, flags: nil, block: { sleep(2) })
            XCTAssertEqual(self.dispatcher.dispatchQueue.label, dispatchQueue.label)
            XCTAssertFalse(dispatchWorkItem.isCancelled)
            dispatchWorkItem.cancel()
            XCTAssertTrue(dispatchWorkItem.isCancelled)
        }
    }

}
