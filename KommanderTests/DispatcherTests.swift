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
        let operation = dispatcher.run({ sleep(2) })
        XCTAssertGreaterThan(dispatcher.operationQueue.operationCount, 0)
        operation.cancel()
        XCTAssertTrue(operation.isCancelled)
    }

    func testDefaultDispatcherDispatchQueue() {
        let dispatchWorkItem = DispatchWorkItem(qos: .default, flags: .assignCurrentContext) { sleep(2) }
        dispatcher.run(dispatchWorkItem)
        XCTAssertFalse(dispatchWorkItem.isCancelled)
        dispatchWorkItem.cancel()
        XCTAssertTrue(dispatchWorkItem.isCancelled)
    }

    func testCustomDispatcherOperationQueue() {
        let randomName = UUID().uuidString
        dispatcher = Dispatcher(name: randomName, qos: .background, maxConcurrentOperations: 1)
        XCTAssertEqual(dispatcher.operationQueue.name, randomName)
        XCTAssertEqual(dispatcher.operationQueue.maxConcurrentOperationCount, 1)
        XCTAssertEqual(dispatcher.operationQueue.qualityOfService, .background)
        let operation = dispatcher.run({ sleep(2) })
        XCTAssertGreaterThan(dispatcher.operationQueue.operationCount, 0)
        operation.cancel()
        XCTAssertTrue(operation.isCancelled)
    }

    func testMainDispatcherOperationQueue() {
        dispatcher = .main
        let operation = dispatcher.run({ sleep(2) })
        XCTAssertEqual(dispatcher.operationQueue, OperationQueue.main)
        XCTAssertGreaterThan(dispatcher.operationQueue.operationCount, 0)
        operation.cancel()
        XCTAssertTrue(operation.isCancelled)
    }

    func testMainDispatcherDispatchQueue() {
        dispatcher = .main
        let dispatchWorkItem = DispatchWorkItem(qos: .default, flags: .assignCurrentContext) { sleep(2) }
        dispatcher.run(dispatchWorkItem)
        XCTAssertEqual(dispatcher.dispatchQueue, DispatchQueue.main)
        XCTAssertFalse(dispatchWorkItem.isCancelled)
        dispatchWorkItem.cancel()
        XCTAssertTrue(dispatchWorkItem.isCancelled)
    }

    func testCurrentDispatcherOperationQueue() {
        let operationQueue = OperationQueue()
        operationQueue.addOperation {
            self.dispatcher = .current
            let operation = self.dispatcher.run({ sleep(2) })
            XCTAssertGreaterThan(self.dispatcher.operationQueue.operationCount, 0)
            operation.cancel()
            XCTAssertTrue(operation.isCancelled)
        }
    }

    func testCurrentDispatcherDispatchQueue() {
        let dispatchQueue = DispatchQueue(label: "")
        dispatchQueue.async {
            self.dispatcher = .current
            let dispatchWorkItem = DispatchWorkItem(qos: .default, flags: .assignCurrentContext) { sleep(2) }
            self.dispatcher.run(dispatchWorkItem)
            XCTAssertFalse(dispatchWorkItem.isCancelled)
            dispatchWorkItem.cancel()
            XCTAssertTrue(dispatchWorkItem.isCancelled)
        }
    }

}
