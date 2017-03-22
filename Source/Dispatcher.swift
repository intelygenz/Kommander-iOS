//
//  Dispatcher.swift
//  Kommander
//
//  Created by Alejandro Ruperez Hernando on 26/1/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import Foundation

/// Queue priority
private enum Priority {
    /// Operation queue priority
    case operation
    /// Dispatch queue priority
    case dispatch
}

/// Dispatcher
open class Dispatcher {

    /// Dispatcher operation queue
    final var operationQueue = OperationQueue()
    /// Dispatcher dispatch queue
    final var dispatchQueue = DispatchQueue(label: UUID().uuidString)
    /// Dispatcher queue priority
    private final var priority = Priority.operation

    /// Dispatcher instance with default OperationQueue
    public convenience init() {
        self.init(name: nil, qos: nil, maxConcurrentOperationCount: OperationQueue.defaultMaxConcurrentOperationCount)
    }

    /// Dispatcher instance with custom OperationQueue
    public init(name: String?, qos: QualityOfService?, maxConcurrentOperationCount: Int) {
        operationQueue.name = name ?? UUID().uuidString
        operationQueue.qualityOfService = qos ?? .default
        operationQueue.maxConcurrentOperationCount = maxConcurrentOperationCount
    }

    /// Dispatcher instance with custom DispatchQueue
    public init(label: String?, qos: DispatchQoS?, attributes: DispatchQueue.Attributes?, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency?, target: DispatchQueue?) {
        dispatchQueue = DispatchQueue(label: label ?? UUID().uuidString, qos: qos ?? .default, attributes: attributes ?? .concurrent, autoreleaseFrequency: autoreleaseFrequency ?? .inherit, target: target)
        priority = .dispatch
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
    open func execute(_ block: @escaping () -> Void) -> Any {
        if priority == .dispatch {
            return execute(qos: nil, flags: nil, block: block)
        }
        else {
            let blockOperation = BlockOperation(block: block)
            execute(blockOperation)
            return blockOperation
        }
    }

    /// Execute [block] collection in priority queue (if possible) concurrently or sequentially
    open func execute(_ blocks: [() -> Void], concurrent: Bool = true, waitUntilFinished: Bool = false) -> [Any] {
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

    /// Execute block in DispatchQueue using custom DispatchWorkItem instance
    open func execute(qos: DispatchQoS?, flags: DispatchWorkItemFlags?, block: @escaping @convention(block) () -> ()) -> DispatchWorkItem {
        let work = DispatchWorkItem(qos: qos ?? .default, flags: flags ?? .assignCurrentContext, block: block)
        execute(work)
        return work
    }

    /// Execute DispatchWorkItem instance in DispatchQueue
    open func execute(_ work: DispatchWorkItem) {
        dispatchQueue.async(execute: work)
    }

}
