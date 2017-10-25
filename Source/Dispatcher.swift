//
//  Dispatcher.swift
//  Kommander
//
//  Created by Alejandro Ruperez Hernando on 26/1/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import Foundation

/// Dispatcher
open class Dispatcher {

    /// Dispatcher operation queue
    final var operationQueue = OperationQueue()
    /// Dispatcher dispatch queue
    final var dispatchQueue = DispatchQueue(label: UUID().uuidString)

    /// Main queue dispatcher
    open static var main: Dispatcher { return MainDispatcher() }
    /// Current queue dispatcher
    open static var current: Dispatcher { return CurrentDispatcher() }
    /// Dispatcher with default quality of service
    open static var `default`: Dispatcher { return Dispatcher() }
    /// Dispatcher with user interactive quality of service
    open static var userInteractive: Dispatcher { return Dispatcher(name: nil, qos: .userInteractive) }
    /// Dispatcher with user initiated quality of service
    open static var userInitiated: Dispatcher { return Dispatcher(name: nil, qos: .userInitiated) }
    /// Dispatcher with utility quality of service
    open static var utility: Dispatcher { return Dispatcher(name: nil, qos: .utility) }
    /// Dispatcher with background quality of service
    open static var background: Dispatcher { return Dispatcher(name: nil, qos: .background) }

    /// Dispatcher instance with default OperationQueue
    public convenience init() {
        self.init(name: nil, qos: .default)
    }

    /// Dispatcher instance with custom OperationQueue
    public init(name: String?, qos: QualityOfService?, maxConcurrentOperationCount: Int? = nil) {
        operationQueue.name = name ?? UUID().uuidString
        operationQueue.qualityOfService = qos ?? .default
        operationQueue.maxConcurrentOperationCount = maxConcurrentOperationCount ?? OperationQueue.defaultMaxConcurrentOperationCount
    }

    /// Dispatcher instance with custom DispatchQueue
    @available(*, deprecated, message: "This will be removed in Kommander 0.9. Use `Dispatcher.init(name:qos:maxConcurrentOperationCount:)` instead.")
    public init(label: String?, qos: DispatchQoS?, attributes: DispatchQueue.Attributes? = nil, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency? = nil, target: DispatchQueue? = nil) {
        dispatchQueue = DispatchQueue(label: label ?? UUID().uuidString, qos: qos ?? .default, attributes: attributes ?? .concurrent, autoreleaseFrequency: autoreleaseFrequency ?? .inherit, target: target)
    }

    /// Execute Operation instance in OperationQueue
    open func execute(_ operation: Operation) {
        operationQueue.addOperation(operation)
    }

    /// Execute [Operation] instance collection in OperationQueue
    open func execute(_ operations: [Operation], waitUntilFinished: Bool = false) {
        operationQueue.addOperations(operations, waitUntilFinished: waitUntilFinished)
    }

    /// Execute block in priority queue
    @discardableResult open func execute(_ block: @escaping () -> Void) -> Any {
        let blockOperation = BlockOperation(block: block)
        execute(blockOperation)
        return blockOperation
    }

    /// Execute [block] collection in priority queue (if possible) concurrently or sequentially
    @discardableResult open func execute(_ blocks: [() -> Void], concurrent: Bool = true, waitUntilFinished: Bool = false) -> [Any] {
        var lastOperation: Operation?
        let operations = blocks.map { block -> Operation in
            let blockOperation = BlockOperation(block: block)
            if let lastOperation = lastOperation, !concurrent {
                blockOperation.addDependency(lastOperation)
            }
            lastOperation = blockOperation
            return blockOperation
        }
        execute(operations, waitUntilFinished: waitUntilFinished)
        return operations
    }

    /// Execute block in DispatchQueue after delay
    open func execute(after delay: DispatchTimeInterval, block: @escaping () -> Void) {
        guard delay != .never else {
            return
        }
        dispatchQueue.asyncAfter(deadline: .now() + delay, execute: block)
    }

    /// Execute block in DispatchQueue using custom DispatchWorkItem instance after delay
    @available(*, deprecated, message: "This will be removed in Kommander 0.9. Use `execute(delay:work:)` instead.")
    open func execute(after delay: DispatchTimeInterval, qos: DispatchQoS?, flags: DispatchWorkItemFlags?, block: @escaping @convention(block) () -> ()) {
        guard delay != .never else {
            return
        }
        dispatchQueue.asyncAfter(deadline: .now() + delay, qos: qos ?? .default, flags: flags ?? .assignCurrentContext, execute: block)
    }

    /// Execute DispatchWorkItem instance in DispatchQueue after delay
    open func execute(after delay: DispatchTimeInterval, work: DispatchWorkItem) {
        guard delay != .never else {
            work.cancel()
            return
        }
        dispatchQueue.asyncAfter(deadline: .now() + delay, execute: work)
    }

    /// Execute block in DispatchQueue using custom DispatchWorkItem instance
    @available(*, deprecated, message: "This will be removed in Kommander 0.9. Use `execute(work:)` instead.")
    @discardableResult open func execute(qos: DispatchQoS?, flags: DispatchWorkItemFlags?, block: @escaping @convention(block) () -> ()) -> DispatchWorkItem {
        let work = DispatchWorkItem(qos: qos ?? .default, flags: flags ?? .assignCurrentContext, block: block)
        execute(work)
        return work
    }

    /// Execute DispatchWorkItem instance in DispatchQueue
    open func execute(_ work: DispatchWorkItem) {
        dispatchQueue.async(execute: work)
    }

}
