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
    public static var main: Dispatcher { return MainDispatcher() }
    /// Current queue dispatcher
    public static var current: Dispatcher { return CurrentDispatcher() }
    /// Dispatcher with default quality of service
    public static var `default`: Dispatcher { return Dispatcher() }
    /// Dispatcher with user interactive quality of service
    public static var userInteractive: Dispatcher { return Dispatcher(qos: .userInteractive) }
    /// Dispatcher with user initiated quality of service
    public static var userInitiated: Dispatcher { return Dispatcher(qos: .userInitiated) }
    /// Dispatcher with utility quality of service
    public static var utility: Dispatcher { return Dispatcher(qos: .utility) }
    /// Dispatcher with background quality of service
    public static var background: Dispatcher { return Dispatcher(qos: .background) }

    /// Dispatcher instance with custom OperationQueue
    public init(name: String = UUID().uuidString, qos: QualityOfService = .default, maxConcurrentOperations: Int = OperationQueue.defaultMaxConcurrentOperationCount) {
        operationQueue.name = name
        operationQueue.qualityOfService = qos
        operationQueue.maxConcurrentOperationCount = maxConcurrentOperations
        dispatchQueue = DispatchQueue(label: name, qos: dispatchQoS(qos), attributes: .concurrent, autoreleaseFrequency: .inherit, target: operationQueue.underlyingQueue)
    }

    /// Execute Operation instance in OperationQueue
    open func execute(_ operation: Operation) {
        operationQueue.addOperation(operation)
    }

    /// Execute [Operation] instance collection in OperationQueue
    open func execute(_ operations: [Operation], waitUntilFinished: Bool = false) {
        operationQueue.addOperations(operations, waitUntilFinished: waitUntilFinished)
    }

    /// Execute closure in OperationQueue
    @discardableResult open func execute(_ closure: @escaping () -> Void) -> Operation {
        let operation = BlockOperation(block: closure)
        execute(operation)
        return operation
    }

    /// Execute [closure] collection in OperationQueue concurrently or sequentially
    @discardableResult open func execute(_ closures: [() -> Void], concurrent: Bool = true, waitUntilFinished: Bool = false) -> [Operation] {
        var lastOperation: Operation?
        let operations = closures.map { closure -> Operation in
            let operation = BlockOperation(block: closure)
            if let lastOperation = lastOperation, !concurrent {
                operation.addDependency(lastOperation)
            }
            lastOperation = operation
            return operation
        }
        execute(operations, waitUntilFinished: waitUntilFinished)
        return operations
    }

    /// Execute closure in DispatchQueue after delay
    open func execute(after delay: DispatchTimeInterval, closure: @escaping () -> Void) {
        guard delay != .never else {
            return
        }
        dispatchQueue.asyncAfter(deadline: .now() + delay, execute: closure)
    }

    /// Execute DispatchWorkItem instance in DispatchQueue after delay
    open func execute(after delay: DispatchTimeInterval, work: DispatchWorkItem) {
        guard delay != .never else {
            work.cancel()
            return
        }
        dispatchQueue.asyncAfter(deadline: .now() + delay, execute: work)
    }

    /// Execute DispatchWorkItem instance in DispatchQueue
    open func execute(_ work: DispatchWorkItem) {
        dispatchQueue.async(execute: work)
    }

}

public extension Array where Element: Operation {

    /// Execute [Operation] instance collection in OperationQueue
    public func execute(in operationQueue: OperationQueue, waitUntilFinished: Bool = false) {
        operationQueue.addOperations(self, waitUntilFinished: waitUntilFinished)
    }

    /// Execute [Operation] instance collection in Dispatcher
    public func execute(in dispatcher: Dispatcher, waitUntilFinished: Bool = false) {
        dispatcher.execute(self, waitUntilFinished: waitUntilFinished)
    }

}

private extension Dispatcher {

    final func dispatchQoS(_ qos: QualityOfService) -> DispatchQoS {
        switch qos {
        case .userInteractive: return .userInteractive
        case .userInitiated: return .userInitiated
        case .utility: return .utility
        case .background: return .background
        default: return .default
        }
    }

}
