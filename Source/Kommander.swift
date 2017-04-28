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
    private final let deliverer: Dispatcher
    /// Executor
    private final let executor: Dispatcher

    /// Kommander instance with CurrentDispatcher deliverer and MainDispatcher executor
    open static var main: Kommander { return Kommander(executor: Dispatcher.main) }
    /// Kommander instance with CurrentDispatcher deliverer and CurrentDispatcher executor
    open static var current: Kommander { return Kommander(executor: Dispatcher.current) }
    /// Kommander instance with CurrentDispatcher deliverer and Dispatcher executor with default quality of service
    open static var `default`: Kommander { return Kommander(executor: Dispatcher.default) }
    /// Kommander instance with CurrentDispatcher deliverer and Dispatcher executor with user interactive quality of service
    open static var userInteractive: Kommander { return Kommander(executor: Dispatcher.userInteractive) }
    /// Kommander instance with CurrentDispatcher deliverer and Dispatcher executor with user initiated quality of service
    open static var userInitiated: Kommander { return Kommander(executor: Dispatcher.userInitiated) }
    /// Kommander instance with CurrentDispatcher deliverer and Dispatcher executor with utility quality of service
    open static var utility: Kommander { return Kommander(executor: Dispatcher.utility) }
    /// Kommander instance with CurrentDispatcher deliverer and Dispatcher executor with background quality of service
    open static var background: Kommander { return Kommander(executor: Dispatcher.background) }

    /// Kommander instance with CurrentDispatcher deliverer and default Dispatcher executor
    public convenience init() {
        self.init(deliverer: nil, executor: nil)
    }

    /// Kommander instance with CurrentDispatcher deliverer and your executor
    public convenience init(executor: Dispatcher) {
        self.init(deliverer: nil, executor: executor)
    }

    /// Kommander instance with your deliverer and default Dispatcher executor
    public convenience init(deliverer: Dispatcher) {
        self.init(deliverer: deliverer, executor: nil)
    }

    /// Kommander instance with your deliverer and your executor
    public init(deliverer: Dispatcher?, executor: Dispatcher?) {
        self.deliverer = deliverer ?? CurrentDispatcher()
        self.executor = executor ?? Dispatcher()
    }

    /// Kommander instance with CurrentDispatcher deliverer and custom OperationQueue executor
    public convenience init(name: String?, qos: QualityOfService?, maxConcurrentOperationCount: Int) {
        self.init(deliverer: nil, name: name, qos: qos, maxConcurrentOperationCount: maxConcurrentOperationCount)
    }

    /// Kommander instance with CurrentDispatcher deliverer and custom DispatchQueue executor
    public convenience init(name: String?, qos: DispatchQoS?, attributes: DispatchQueue.Attributes?, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency?, target: DispatchQueue?) {
        self.init(deliverer: nil, name: name, qos: qos, attributes: attributes, autoreleaseFrequency: autoreleaseFrequency, target: target)
    }

    /// Kommander instance with your deliverer and custom OperationQueue executor
    public init(deliverer: Dispatcher?, name: String?, qos: QualityOfService?, maxConcurrentOperationCount: Int) {
        self.deliverer = deliverer ?? CurrentDispatcher()
        executor = Dispatcher(name: name, qos: qos, maxConcurrentOperationCount: maxConcurrentOperationCount)
    }

    /// Kommander instance with your deliverer and custom DispatchQueue executor
    public init(deliverer: Dispatcher?, name: String?, qos: DispatchQoS?, attributes: DispatchQueue.Attributes?, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency?, target: DispatchQueue?) {
        self.deliverer = deliverer ?? CurrentDispatcher()
        executor = Dispatcher(label: name, qos: qos, attributes: attributes, autoreleaseFrequency: autoreleaseFrequency, target: target)
    }

    /// Build Kommand<Result> instance with an actionBlock returning generic and throwing errors
    open func makeKommand<Result>(_ actionBlock: @escaping () throws -> Result) -> Kommand<Result> {
        return Kommand<Result>(deliverer: deliverer, executor: executor, actionBlock: actionBlock)
    }

    /// Build [Kommand<Result>] instances collection with actionBlocks returning generic and throwing errors
    open func makeKommands<Result>(_ actionBlocks: [() throws -> Result]) -> [Kommand<Result>] {
        var kommands = [Kommand<Result>]()
        for actionBlock in actionBlocks {
            kommands.append(Kommand<Result>(deliverer: deliverer, executor: executor, actionBlock: actionBlock))
        }
        return kommands
    }

    /// Execute [Kommand<Result>] instances collection concurrently or sequentially after delay
    open func execute<Result>(_ kommands: [Kommand<Result>], concurrent: Bool = true, waitUntilFinished: Bool = false, after delay: TimeInterval) {
        executor.execute(after: delay) { 
            self.execute(kommands, concurrent: concurrent, waitUntilFinished: waitUntilFinished)
        }
    }

    /// Execute [Kommand<Result>] instances collection concurrently or sequentially
    open func execute<Result>(_ kommands: [Kommand<Result>], concurrent: Bool = true, waitUntilFinished: Bool = false) {
        let blocks = kommands.map { kommand -> () -> Void in
            {
                guard kommand.state == .ready else {
                    return
                }
                do {
                    if let actionBlock = kommand.actionBlock {
                        kommand.state = .running
                        let result = try actionBlock()
                        guard kommand.state == .running else {
                            return
                        }
                        self.deliverer.execute {
                            kommand.state = .finished
                            kommand.successBlock?(result)
                        }
                    }
                } catch {
                    guard kommand.state == .running else {
                        return
                    }
                    self.deliverer.execute {
                        kommand.state = .finished
                        kommand.errorBlock?(error)
                    }
                }
            }
        }
        let actions = executor.execute(blocks, concurrent: concurrent, waitUntilFinished: waitUntilFinished)
        for (index, kommand) in kommands.enumerated() {
            if let operationAction = actions[index] as? Operation {
                kommand.operation = operationAction
            } else if let workAction = actions[index] as? DispatchWorkItem {
                kommand.work = workAction
            }
        }
    }

    /// Cancel [Kommand<Result>] instances collection after delay
    open func cancel<Result>(_ kommands: [Kommand<Result>], throwingError: Bool = false, after delay: TimeInterval) {
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

}
