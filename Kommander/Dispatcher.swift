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

    internal final var operationQueue = OperationQueue()
    internal final var dispatchQueue = DispatchQueue(label: UUID().uuidString)
    private final var priority = Priority.operation

    public convenience init() {
        self.init(name: nil, qos: nil, maxConcurrentOperationCount: OperationQueue.defaultMaxConcurrentOperationCount)
    }

    public init(name: String?, qos: QualityOfService?, maxConcurrentOperationCount: Int) {
        operationQueue.name = name ?? UUID().uuidString
        operationQueue.qualityOfService = qos ?? .default
        operationQueue.maxConcurrentOperationCount = maxConcurrentOperationCount
    }

    public init(label: String?, qos: DispatchQoS?, attributes: DispatchQueue.Attributes?, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency?, target: DispatchQueue?) {
        dispatchQueue = DispatchQueue(label: label ?? UUID().uuidString, qos: qos ?? .default, attributes: attributes ?? .concurrent, autoreleaseFrequency: autoreleaseFrequency ?? .inherit, target: target)
        priority = .dispatch
    }

    public func execute(_ operation: Operation) {
        operationQueue.addOperation(operation)
    }

    public func execute(_ operations: [Operation], waitUntilFinished: Bool = false) {
        operationQueue.addOperations(operations, waitUntilFinished: waitUntilFinished)
    }

    public func execute(_ block: @escaping () -> Void) -> Any {
        if priority == .dispatch {
            return execute(qos: nil, flags: nil, block: block)
        }
        else {
            let blockOperation = BlockOperation(block: block)
            execute(blockOperation)
            return blockOperation
        }
    }

    public func execute(qos: DispatchQoS?, flags: DispatchWorkItemFlags?, block: @escaping @convention(block) () -> ()) -> DispatchWorkItem {
        let work = DispatchWorkItem(qos: qos ?? .default, flags: flags ?? .assignCurrentContext, block: block)
        execute(work)
        return work
    }

    public func execute(_ work: DispatchWorkItem) {
        dispatchQueue.async(execute: work)
    }

}
