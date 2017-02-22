//
//  Dispatcher.swift
//  Kommander
//
//  Created by Alejandro Ruperez Hernando on 26/1/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import Foundation

private enum Priority {
    case operation, dispatch
}

public class Dispatcher {

    internal final var operationQueue = NSOperationQueue()
    internal final var dispatchQueue = dispatch_queue_create(NSUUID().UUIDString, DISPATCH_QUEUE_SERIAL)
    private final var priority = Priority.operation

    public convenience init() {
        self.init(name: nil, qos: nil, maxConcurrentOperationCount: NSOperationQueueDefaultMaxConcurrentOperationCount)
    }

    public init(name: String?, qos: NSQualityOfService?, maxConcurrentOperationCount: Int) {
        operationQueue.name = name ?? NSUUID().UUIDString
        operationQueue.qualityOfService = qos ?? .Default
        operationQueue.maxConcurrentOperationCount = maxConcurrentOperationCount
    }

    public init(label: String?, qos: dispatch_qos_class_t, attributes: dispatch_queue_attr_t?, target: dispatch_queue_t?) {
        let attr = dispatch_queue_attr_make_with_qos_class(attributes, qos, QOS_MIN_RELATIVE_PRIORITY)
        dispatchQueue = dispatch_queue_create(NSUUID().UUIDString, attr)
        dispatch_set_target_queue(dispatchQueue, target)
        priority = .dispatch
    }

    public func execute(operation: NSOperation) {
        operationQueue.addOperation(operation)
    }

    public func execute(operations: [NSOperation], waitUntilFinished: Bool = false) {
        operationQueue.addOperations(operations, waitUntilFinished: waitUntilFinished)
    }

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

    public func execute(blocks: [() -> Void], waitUntilFinished: Bool = false) -> [Any] {
        var actions = [Any]()
        for block in blocks {
            actions.append(execute(block))
        }
        return actions
    }

    public func execute(block: dispatch_block_t) -> dispatch_block_t {
        dispatch_async(dispatchQueue, block)
        return block
    }

}
