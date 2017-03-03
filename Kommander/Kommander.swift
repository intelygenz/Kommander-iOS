//
//  Kommander.swift
//  Kommander
//
//  Created by Alejandro Ruperez Hernando on 26/1/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import Foundation

/// Kommander manager
public class Kommander {

    /// Deliverer
    private final let deliverer: Dispatcher
    /// Executor
    private final let executor: Dispatcher

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
    public convenience init(name: String?, qos: NSQualityOfService?, maxConcurrentOperationCount: Int) {
        self.init(deliverer: nil, name: name, qos: qos, maxConcurrentOperationCount: maxConcurrentOperationCount)
    }

    /// Kommander instance with CurrentDispatcher deliverer and custom DispatchQueue executor
    public convenience init(name: String?, qos: dispatch_qos_class_t, attributes: dispatch_queue_attr_t?, target: dispatch_queue_t?) {
        self.init(deliverer: nil, name: name, qos: qos, attributes: attributes, target: target)
    }

    /// Kommander instance with your deliverer and custom OperationQueue executor
    public init(deliverer: Dispatcher?, name: String?, qos: NSQualityOfService?, maxConcurrentOperationCount: Int) {
        self.deliverer = deliverer ?? CurrentDispatcher()
        executor = Dispatcher(name: name, qos: qos, maxConcurrentOperationCount: maxConcurrentOperationCount)
    }

    /// Kommander instance with your deliverer and custom DispatchQueue executor
    public init(deliverer: Dispatcher?, name: String?, qos: dispatch_qos_class_t, attributes: dispatch_queue_attr_t?, target: dispatch_queue_t?) {
        self.deliverer = deliverer ?? CurrentDispatcher()
        executor = Dispatcher(label: name, qos: qos, attributes: attributes, target: target)
    }

    /// Build Kommand<Result> instance with an actionBlock returning generic and throwing errors
    public func makeKommand<Result>(actionBlock: () throws -> Result) -> Kommand<Result> {
        return Kommand<Result>(deliverer: deliverer, executor: executor, actionBlock: actionBlock)
    }

    /// Build [Kommand<Result>] instances collection with actionBlocks returning generic and throwing errors
    public func makeKommands<Result>(actionBlocks: [() throws -> Result]) -> [Kommand<Result>] {
        var kommands = [Kommand<Result>]()
        for actionBlock in actionBlocks {
            kommands.append(Kommand<Result>(deliverer: deliverer, executor: executor, actionBlock: actionBlock))
        }
        return kommands
    }

    /// Execute [Kommand<Result>] instances collection concurrently
    public func execute<Result>(kommands: [Kommand<Result>], waitUntilFinished: Bool = false) {
        let blocks = kommands.map { kommand -> () -> Void in
            return {
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
                        _ = self.deliverer.execute {
                            kommand.state = .finished
                            kommand.successBlock?(result: result)
                        }
                    }
                } catch {
                    guard kommand.state == .running else {
                        return
                    }
                    _ = self.deliverer.execute {
                        kommand.state = .finished
                        kommand.errorBlock?(error: error)
                    }
                }
            }
        }
        let actions = executor.execute(blocks, waitUntilFinished: waitUntilFinished)
        for (index, kommand) in kommands.enumerate() {
            kommand.action = actions[index]
        }
    }

    /// Cancel [Kommand<Result>] instances collection
    public func cancel<Result>(kommands: [Kommand<Result>], throwingError: Bool = false) {
        for kommand in kommands {
            kommand.cancel(throwingError)
        }
    }

}
