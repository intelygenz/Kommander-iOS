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
public class Dispatcher {

    /// Dispatcher operation queue
    final var operationQueue = NSOperationQueue()
    /// Dispatcher dispatch queue
    final var dispatchQueue = dispatch_queue_create(NSUUID().UUIDString, DISPATCH_QUEUE_SERIAL)
    /// Dispatcher queue priority
    private final var priority = Priority.operation

    /// Dispatcher instance with default OperationQueue
    public convenience init() {
        self.init(name: nil, qos: nil, maxConcurrentOperationCount: NSOperationQueueDefaultMaxConcurrentOperationCount)
    }

    /// Dispatcher instance with custom OperationQueue
    public init(name: String?, qos: NSQualityOfService?, maxConcurrentOperationCount: Int) {
        operationQueue.name = name ?? NSUUID().UUIDString
        operationQueue.qualityOfService = qos ?? .Default
        operationQueue.maxConcurrentOperationCount = maxConcurrentOperationCount
    }

    /// Dispatcher instance with custom DispatchQueue
    public init(label: String?, qos: dispatch_qos_class_t, attributes: dispatch_queue_attr_t?, target: dispatch_queue_t?) {
        let attr = dispatch_queue_attr_make_with_qos_class(attributes, qos, QOS_MIN_RELATIVE_PRIORITY)
        dispatchQueue = dispatch_queue_create(NSUUID().UUIDString, attr)
        dispatch_set_target_queue(dispatchQueue, target)
        priority = .dispatch
    }

    /// Execute Operation instance in OperationQueue
    public func execute(operation: NSOperation) {
        operationQueue.addOperation(operation)
    }

    /// Execute [Operation] instance collection in OperationQueue
    public func execute(operations: [NSOperation], waitUntilFinished: Bool = false) {
        operationQueue.addOperations(operations, waitUntilFinished: waitUntilFinished)
    }

    /// Execute block in priority queue
    public func execute(block: () -> Void) -> Any {
        if priority == .dispatch {
            return execute(block as dispatch_block_t)
        }
        else {
            let blockOperation = NSBlockOperation(block: block)
            execute(blockOperation)
            return blockOperation
        }
    }

    /// Execute [block] collection in priority queue (if possible) concurrently
    public func execute(blocks: [() -> Void], waitUntilFinished: Bool = false) -> [Any] {
        var actions = [Any]()
        for block in blocks {
            actions.append(execute(block))
        }
        return actions
    }

    /// Execute block in DispatchQueue using dispatch_block_t
    public func execute(block: dispatch_block_t) -> dispatch_block_t {
        dispatch_async(dispatchQueue, block)
        return block
    }

}
