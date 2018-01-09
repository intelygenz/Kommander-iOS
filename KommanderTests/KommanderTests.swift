//
//  KommanderTests.swift
//  KommanderTests
//
//  Created by Alejandro Ruperez Hernando on 26/1/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import XCTest
@testable import Kommander

class KommanderTests: XCTestCase {

    var kommander: Kommander!
    var interactor: CommonInteractor!

    override func setUp() {
        super.setUp()

        kommander = Kommander()
        interactor = CommonInteractor(kommander: kommander)
    }


    func test_oneCall() {

        let ex = expectation(description: String(describing: type(of: self)))

        interactor.getCounter(name: "C1", to: 3)
            .success({ (name) in
                ex.fulfill()
            })
            .error({ (error) in
                ex.fulfill()
                XCTFail()
            }).execute()

        waitForExpectations(timeout: 100, handler: nil)
    }

    func test_twoCalls() {

        let ex = expectation(description: String(describing: type(of: self)))

        var successes = 0

        let k1 = interactor.getCounter(name: "C1", to: 3)
            .success({ (name) in
                successes+=1
                if successes>=2 {
                    ex.fulfill()
                }
            })
            .error({ (error) in
                ex.fulfill()
                XCTFail()
            }).execute()

        let k2 = interactor.getCounter(name: "C2", to: 5)
            .success({ (name) in
                successes+=1
                if successes>=2 {
                    ex.fulfill()
                }
            })
            .error({ (error) in
                ex.fulfill()
                XCTFail()
            }).execute()

        k1.execute()
        k2.execute()

        waitForExpectations(timeout: 100, handler: nil)
    }

    func test_nCalls_withDelay() {

        let ex = expectation(description: String(describing: type(of: self)))

        var successes = 0
        let calls = Int(arc4random_uniform(10) + 1)

        for i in 0..<calls {
            interactor.getCounter(name: "C\(i)", to: 3)
                .success({ (name) in
                    successes+=1
                    if successes>=calls {
                        ex.fulfill()
                    }
                })
                .error({ (error) in
                    ex.fulfill()
                    XCTFail()
                })
                .execute(after: .seconds(1))
        }

        waitForExpectations(timeout: 100, handler: nil)
    }

    func test_nCalls_andCancel() {

        let ex = expectation(description: String(describing: type(of: self)))

        var errors = 0
        let calls = Int(arc4random_uniform(10) + 1)

        for i in 0..<calls {
            interactor.getCounter(name: "C\(i)", to: 3)
                .success({ (name) in
                    ex.fulfill()
                    XCTFail()
                })
                .error({ (error) in
                    errors+=1
                    if errors>=calls {
                        ex.fulfill()
                    }
                })
                .execute()
                .cancel(true, after: .seconds(2))
        }

        waitForExpectations(timeout: 100, handler: nil)
    }

    func test_nCalls_andCancel_andRetry() {

        let ex = expectation(description: String(describing: type(of: self)))

        var successes = 0
        let calls = Int(arc4random_uniform(10) + 1)

        for i in 0..<calls {
            interactor.getCounter(name: "C\(i)", to: 3)
                .success({ (name) in
                    successes+=1
                    print("success \(successes)")
                    if successes>=calls {
                        ex.fulfill()
                    }
                })
                .error({ (error) in
                    ex.fulfill()
                    XCTFail()
                })
                .execute()
                .cancel(false, after: .seconds(2))
                .retry(after: .seconds(5))
        }

        waitForExpectations(timeout: 100, handler: nil)
    }

    func test_nCalls_andCancel_andRetryFromError() {
        let ex = expectation(description: String(describing: type(of: self)))

        var successes = 0
        let calls = Int(arc4random_uniform(10) + 1)

        for i in 0..<calls {
            interactor.getCounter(name: "C\(i)", to: 3)
                .success({ (name) in
                    successes+=1
                    print("success \(successes)")
                    if successes>=calls {
                        ex.fulfill()
                    }
                })
                .error({ (error) in
                    guard let error = error as? KommandCancelledError<String> else {
                        ex.fulfill()
                        XCTFail()
                        return
                    }

                    XCTAssertEqual(error.recoveryOptions, ["Retry the Kommand"])
                    let recoverySuccess = error.attemptRecovery(optionIndex: 0)
                    XCTAssert(recoverySuccess)
                    let secondRecoverySuccess = error.attemptRecovery(optionIndex: 0)
                    XCTAssertFalse(secondRecoverySuccess)
                })
                .execute()
                .cancel(true, after: .seconds(2))
        }

        waitForExpectations(timeout: 100, handler: nil)
    }

    func test_nCalls() {

        let ex = expectation(description: String(describing: type(of: self)))

        var successes = 0
        let calls = Int(arc4random_uniform(10) + 1)

        for i in 0..<calls {
            interactor.getCounter(name: "C\(i)", to: 3)
                .success({ (name) in
                    successes+=1
                    if successes>=calls {
                        ex.fulfill()
                    }
                })
                .error({ (error) in
                    ex.fulfill()
                    XCTFail()
                })
                .execute()
        }

        waitForExpectations(timeout: 100, handler: nil)
    }

    func test_nCalls_concurrent_waitUntilFinished() {

        let ex = expectation(description: String(describing: type(of: self)))

        var successes = 0
        let calls = Int(arc4random_uniform(10) + 1)

        var kommands = [Kommand<String>]()

        for i in 0..<calls {
            kommands.append(interactor.getCounter(name: "C\(i)", to: 3)
                .success({ (name) in
                    successes+=1
                    if successes>=calls {
                        ex.fulfill()
                    }
                })
                .error({ (error) in
                    ex.fulfill()
                    XCTFail()
                }))
        }

        interactor.kommander.execute(kommands, concurrent: true, waitUntilFinished: true)

        waitForExpectations(timeout: 100, handler: nil)
    }

    func test_nCalls_concurrent() {

        let ex = expectation(description: String(describing: type(of: self)))

        var successes = 0
        let calls = Int(arc4random_uniform(10) + 1)

        var kommands = [Kommand<String>]()

        for i in 0..<calls {
            kommands.append(interactor.getCounter(name: "C\(i)", to: 3)
                .success({ (name) in
                    successes+=1
                    if successes>=calls {
                        ex.fulfill()
                    }
                })
                .error({ (error) in
                    ex.fulfill()
                    XCTFail()
                }))
        }

        interactor.kommander.execute(kommands, concurrent: true, waitUntilFinished: false)

        waitForExpectations(timeout: 100, handler: nil)
    }

    func test_nCalls_sequential_waitUntilFinished() {

        let ex = expectation(description: String(describing: type(of: self)))

        var successes = 0
        let calls = Int(arc4random_uniform(10) + 1)

        var kommands = [Kommand<String>]()

        for i in 0..<calls {
            kommands.append(interactor.getCounter(name: "C\(i)", to: 3)
                .success({ (name) in
                    successes+=1
                    if successes>=calls {
                        ex.fulfill()
                    }
                })
                .error({ (error) in
                    ex.fulfill()
                    XCTFail()
                }))
        }

        interactor.kommander.execute(kommands, concurrent: false, waitUntilFinished: true)

        waitForExpectations(timeout: 100, handler: nil)
    }

    func test_nCalls_sequential() {

        let ex = expectation(description: String(describing: type(of: self)))

        var successes = 0
        let calls = Int(arc4random_uniform(10) + 1)

        var kommands = [Kommand<String>]()

        for i in 0..<calls {
            kommands.append(interactor.getCounter(name: "C\(i)", to: 3)
                .success({ (name) in
                    successes+=1
                    if successes>=calls {
                        ex.fulfill()
                    }
                })
                .error({ (error) in
                    ex.fulfill()
                    XCTFail()
                }))
        }

        interactor.kommander.execute(kommands, concurrent: false, waitUntilFinished: false)

        waitForExpectations(timeout: 100, handler: nil)
    }

    func testInitializers() {
        let custom = Kommander(name: "Test", maxConcurrentOperations: 2)
        XCTAssertEqual(custom.executor.operationQueue.name, "Test")
        XCTAssertEqual(custom.executor.operationQueue.maxConcurrentOperationCount, 2)
        XCTAssertEqual(Kommander.main.executor.operationQueue, OperationQueue.main)
        XCTAssertEqual(Kommander.current.executor.operationQueue, OperationQueue.current)
        XCTAssertEqual(Kommander.default.executor.operationQueue.qualityOfService, .default)
        XCTAssertEqual(Kommander.userInteractive.executor.operationQueue.qualityOfService, .userInteractive)
        XCTAssertEqual(Kommander.userInitiated.executor.operationQueue.qualityOfService, .userInitiated)
        XCTAssertEqual(Kommander.utility.executor.operationQueue.qualityOfService, .utility)
        XCTAssertEqual(Kommander.background.executor.operationQueue.qualityOfService, .background)
    }

}

extension KommanderTests {

    class CommonInteractor {

        let kommander: Kommander


        init(kommander: Kommander) {
            self.kommander = kommander
        }

        func getCounter(name: String, to: Int) -> Kommand<String> {
            return kommander.make({ () -> String in
                print (name + " Starts\n")
                var cont = 0
                while cont < to {
                    // for _ in 0...1000000 {}
                    sleep(arc4random_uniform(3) + 1)
                    print(cont)
                    cont+=1
                }
                print(name + "Ends\n")
                return name
            })
        }
        
    }

}
