//
//  Kommander.swift
//  Kommander
//
//  Created by Alejandro Ruperez Hernando on 26/1/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import Foundation

public class Kommander {

    private final let deliverer: Dispatcher
    private final let executor: Dispatcher

    public convenience init() {
        self.init(deliverer: nil, executor: nil)
    }

    public convenience init(executor: Dispatcher) {
        self.init(deliverer: nil, executor: executor)
    }

    public convenience init(deliverer: Dispatcher) {
        self.init(deliverer: deliverer, executor: nil)
    }

    public init(deliverer: Dispatcher?, executor: Dispatcher?) {
        self.deliverer = deliverer ?? CurrentDispatcher()
        self.executor = executor ?? Dispatcher()
    }

    public convenience init(name: String?, qos: NSQualityOfService?, maxConcurrentOperationCount: Int) {
        self.init(deliverer: nil, name: name, qos: qos, maxConcurrentOperationCount: maxConcurrentOperationCount)
    }

    public convenience init(name: String?, qos: dispatch_qos_class_t, attributes: dispatch_queue_attr_t?, target: dispatch_queue_t?) {
        self.init(deliverer: nil, name: name, qos: qos, attributes: attributes, target: target)
    }

    public init(deliverer: Dispatcher?, name: String?, qos: NSQualityOfService?, maxConcurrentOperationCount: Int) {
        self.deliverer = deliverer ?? CurrentDispatcher()
        executor = Dispatcher(name: name, qos: qos, maxConcurrentOperationCount: maxConcurrentOperationCount)
    }

    public init(deliverer: Dispatcher?, name: String?, qos: dispatch_qos_class_t, attributes: dispatch_queue_attr_t?, target: dispatch_queue_t?) {
        self.deliverer = deliverer ?? CurrentDispatcher()
        executor = Dispatcher(label: name, qos: qos, attributes: attributes, target: target)
    }

    public func makeKommand<T>(actionBlock: () throws -> T?) -> Kommand<T> {
        return Kommand<T>(deliverer: deliverer, executor: executor, actionBlock: actionBlock)
    }

    public func makeKommands<T>(actionBlocks: [() throws -> T?]) -> [Kommand<T>] {
        var kommands = [Kommand<T>]()
        for actionBlock in actionBlocks {
            kommands.append(Kommand<T>(deliverer: deliverer, executor: executor, actionBlock: actionBlock))
        }
        return kommands
    }

    public func execute<T>(kommands: [Kommand<T>], waitUntilFinished: Bool = false) {
        let blocks = kommands.map { kommand -> () -> Void in
            return {
                do {
                    let result = try kommand.actionBlock()
                    _ = self.deliverer.execute {
                        kommand.successBlock?(result: result)
                    }
                } catch {
                    _ = self.deliverer.execute {
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

    public func cancel<T>(kommands: [Kommand<T>]) {
        for kommand in kommands {
            kommand.cancel()
        }
    }

}
