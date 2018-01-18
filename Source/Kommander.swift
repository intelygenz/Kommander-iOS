//
//  Kommander.swift
//  Kommander
//
//  Created by Alejandro Ruperez Hernando on 26/1/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import Foundation

/// Kommander manager
open class Kommander {

    /// Deliverer
    final let deliverer: Dispatcher
    /// Executor
    final let executor: Dispatcher

    /// Kommander instance with CurrentDispatcher deliverer and MainDispatcher executor
    open static var main: Kommander { return Kommander(executor: .main) }
    /// Kommander instance with CurrentDispatcher deliverer and CurrentDispatcher executor
    open static var current: Kommander { return Kommander(executor: .current) }
    /// Kommander instance with CurrentDispatcher deliverer and Dispatcher executor with default quality of service
    open static var `default`: Kommander { return Kommander() }
    /// Kommander instance with CurrentDispatcher deliverer and Dispatcher executor with user interactive quality of service
    open static var userInteractive: Kommander { return Kommander(executor: .userInteractive) }
    /// Kommander instance with CurrentDispatcher deliverer and Dispatcher executor with user initiated quality of service
    open static var userInitiated: Kommander { return Kommander(executor: .userInitiated) }
    /// Kommander instance with CurrentDispatcher deliverer and Dispatcher executor with utility quality of service
    open static var utility: Kommander { return Kommander(executor: .utility) }
    /// Kommander instance with CurrentDispatcher deliverer and Dispatcher executor with background quality of service
    open static var background: Kommander { return Kommander(executor: .background) }

    /// Kommander instance with deliverer and executor
    public init(deliverer: Dispatcher = .current, executor: Dispatcher = .default) {
        self.deliverer = deliverer
        self.executor = executor
    }

    /// Kommander instance with deliverer and custom OperationQueue executor
    public init(deliverer: Dispatcher = .current, name: String = UUID().uuidString, qos: QualityOfService = .default, maxConcurrentOperations: Int = OperationQueue.defaultMaxConcurrentOperationCount) {
        self.deliverer = deliverer
        executor = Dispatcher(name: name, qos: qos, maxConcurrentOperations: maxConcurrentOperations)
    }

    /// Build Kommand<Result> instance with an actionClosure returning generic and throwing errors
    open func make<Result>(_ actionClosure: @escaping () throws -> Result) -> Kommand<Result> {
        return Kommand<Result>(deliverer: deliverer, executor: executor, actionClosure: actionClosure)
    }

    /// Build [Kommand<Result>] instances collection with actionClosures returning generic and throwing errors
    open func make<Result>(_ actionClosures: [() throws -> Result]) -> [Kommand<Result>] {
        var kommands = [Kommand<Result>]()
        for actionClosure in actionClosures {
            kommands.append(Kommand<Result>(deliverer: deliverer, executor: executor, actionClosure: actionClosure))
        }
        return kommands
    }

    /// Execute [Kommand<Result>] instances collection concurrently or sequentially after delay
    open func execute<Result>(_ kommands: [Kommand<Result>], concurrent: Bool = true, waitUntilFinished: Bool = false, after delay: DispatchTimeInterval) {
        executor.execute(after: delay) { 
            self.execute(kommands, concurrent: concurrent, waitUntilFinished: waitUntilFinished)
        }
    }

    /// Execute [Kommand<Result>] instances collection concurrently or sequentially
    open func execute<Result>(_ kommands: [Kommand<Result>], concurrent: Bool = true, waitUntilFinished: Bool = false) {
        let executionClosures = kommands.map { kommand in
            executionClosure(kommand)
        }
        let operations = executor.execute(executionClosures, concurrent: concurrent, waitUntilFinished: waitUntilFinished)
        for (index, kommand) in kommands.enumerated() {
            kommand.operation = operations[index]
        }
    }

    /// Cancel [Kommand<Result>] instances collection after delay
    open func cancel<Result>(_ kommands: [Kommand<Result>], throwingError: Bool = false, after delay: DispatchTimeInterval) {
        executor.execute(after: delay) {
            self.cancel(kommands, throwingError: throwingError)
        }
    }

    /// Cancel [Kommand<Result>] instances collection
    open func cancel<Result>(_ kommands: [Kommand<Result>], throwingError: Bool = false) {
        for kommand in kommands {
            kommand.cancel(throwingError)
        }
    }

    /// Retry [Kommand<Result>] instances collection after delay
    open func retry<Result>(_ kommands: [Kommand<Result>], after delay: DispatchTimeInterval) {
        executor.execute(after: delay) {
            self.retry(kommands)
        }
    }

    /// Retry [Kommand<Result>] instances collection
    open func retry<Result>(_ kommands: [Kommand<Result>]) {
        for kommand in kommands {
            kommand.retry()
        }
    }

}

private extension Kommander {

    final func executionClosure<Result>(_ kommand: Kommand<Result>) -> () -> Void {
        return {
            guard kommand.state == .ready else {
                return
            }
            do {
                if let actionClosure = kommand.actionClosure {
                    kommand.state = .running
                    kommand.executionCount += 1
                    let result = try actionClosure()
                    guard kommand.state == .running else {
                        return
                    }
                    self.deliverer.execute {
                        kommand.state = .succeeded(result)
                        kommand.successClosure?(result)
                    }
                }
            } catch {
                guard kommand.state == .running else {
                    return
                }
                self.deliverer.execute {
                    kommand.state = .failed(error)
                    if kommand.retryClosure?(error, kommand.executionCount) == true {
                        kommand.state = .ready
                        kommand.execute()
                    } else {
                        kommand.errorClosure?(error)
                    }
                }
            }
        }
    }

}
