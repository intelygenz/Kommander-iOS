//
//  Kommander.swift
//  Kommander
//
//  Created by Alejandro Ruperez Hernando on 26/1/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import Foundation

@objc open class Kommander: NSObject {

    private final let deliverer: Dispatcher
    private final let executor: Dispatcher

    public override convenience init() {
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

    public convenience init(name: String?, qos: QualityOfService?, maxConcurrentOperationCount: Int) {
        self.init(deliverer: nil, name: name, qos: qos, maxConcurrentOperationCount: maxConcurrentOperationCount)
    }

    public convenience init(name: String?, qos: DispatchQoS?, attributes: DispatchQueue.Attributes?, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency?, target: DispatchQueue?) {
        self.init(deliverer: nil, name: name, qos: qos, attributes: attributes, autoreleaseFrequency: autoreleaseFrequency, target: target)
    }

    public init(deliverer: Dispatcher?, name: String?, qos: QualityOfService?, maxConcurrentOperationCount: Int) {
        self.deliverer = deliverer ?? CurrentDispatcher()
        executor = Dispatcher(name: name, qos: qos, maxConcurrentOperationCount: maxConcurrentOperationCount)
    }

    public init(deliverer: Dispatcher?, name: String?, qos: DispatchQoS?, attributes: DispatchQueue.Attributes?, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency?, target: DispatchQueue?) {
        self.deliverer = deliverer ?? CurrentDispatcher()
        executor = Dispatcher(label: name, qos: qos, attributes: attributes, autoreleaseFrequency: autoreleaseFrequency, target: target)
    }

    open func makeKommand<T>(_ actionBlock: @escaping () throws -> T) -> Kommand<T> {
        return Kommand<T>(deliverer: deliverer, executor: executor, actionBlock: actionBlock)
    }

    open func makeKommand(block: @escaping (_ error: AutoreleasingUnsafeMutablePointer<NSError?>) -> Any?) -> KommandProtocol {
        let actionBlock = { () throws -> Any? in
            var error: NSError? = nil
            let result = block(&error)
            if let error = error {
                throw error
            }
            return result
        }
        return makeKommand(actionBlock)
    }

    open func makeKommands<T>(_ actionBlocks: [() throws -> T]) -> [Kommand<T>] {
        var kommands = [Kommand<T>]()
        for actionBlock in actionBlocks {
            kommands.append(Kommand<T>(deliverer: deliverer, executor: executor, actionBlock: actionBlock))
        }
        return kommands
    }

    open func makeKommands(blocks: [(_ error: AutoreleasingUnsafeMutablePointer<NSError?>) -> Any?]) -> [KommandProtocol] {
        let actionBlocks = blocks.map { block -> () throws -> Any? in
            return { () throws -> Any? in
                var error: NSError? = nil
                let result = block(&error)
                if let error = error {
                    throw error
                }
                return result
            }
        }
        return makeKommands(actionBlocks)
    }

    open func execute<T>(_ kommands: [Kommand<T>], concurrent: Bool = true, waitUntilFinished: Bool = false) {
        let blocks = kommands.map { kommand -> () -> Void in
            return {
                do {
                    let result = try kommand.actionBlock()
                    _ = self.deliverer.execute {
                        kommand.successBlock?(result)
                    }
                } catch {
                    _ = self.deliverer.execute {
                        kommand.errorBlock?(error)
                    }
                }
            }
        }
        let actions = executor.execute(blocks, concurrent: concurrent, waitUntilFinished: waitUntilFinished)
        for (index, kommand) in kommands.enumerated() {
            kommand.action = actions[index]
        }
    }

    open func execute(kommands: [KommandProtocol], concurrent: Bool = true, waitUntilFinished: Bool = false) {
        execute(kommands as! [Kommand<Any?>], concurrent: concurrent, waitUntilFinished: waitUntilFinished)
    }

    open func cancel<T>(_ kommands: [Kommand<T>]) {
        for kommand in kommands {
            kommand.cancel()
        }
    }

    open func cancel(kommands: [KommandProtocol]) {
        cancel(kommands as! [Kommand<Any?>])
    }

}
