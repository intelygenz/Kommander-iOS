//
//  Kommand.swift
//  Kommander
//
//  Created by Alejandro Ruperez Hernando on 26/1/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import Foundation

/// Generic Kommand
open class Kommand<T> {

    /// Action block type
    public typealias ActionBlock = () throws -> T
    /// Success block type
    public typealias SuccessBlock = (_ result: T) -> Void
    /// Error block type
    public typealias ErrorBlock = (_ error: Error?) -> Void

    /// Deliverer
    private final let deliverer: Dispatcher
    /// Executor
    private final let executor: Dispatcher
    /// Action block
    private(set) internal final var actionBlock: ActionBlock?
    /// Success block
    private(set) internal final var successBlock: SuccessBlock?
    /// Error block
    private(set) internal final var errorBlock: ErrorBlock?
    /// Action to cancel
    internal final var action: Any?

    /// Kommand<T> instance with your deliverer, your executor and your actionBlock returning generic and throwing errors
    public init(deliverer: Dispatcher, executor: Dispatcher, actionBlock: @escaping ActionBlock) {
        self.deliverer = deliverer
        self.executor = executor
        self.actionBlock = actionBlock
    }

    /// Specify Kommand<T> success block
    open func onSuccess(_ onSuccess: @escaping SuccessBlock) -> Self {
        self.successBlock = onSuccess
        return self
    }

    /// Specify Kommand<T> error block
    open func onError(_ onError: @escaping ErrorBlock) -> Self {
        self.errorBlock = onError
        return self
    }

    /// Execute Kommand<T>
    open func execute() -> Self {
        action = executor.execute {
            do {
                if let actionBlock = self.actionBlock {
                    let result = try actionBlock()
                    _ = self.deliverer.execute {
                        self.successBlock?(result)
                    }
                }
            } catch {
                _ = self.deliverer.execute {
                    self.errorBlock?(error)
                }
            }
        }
        return self
    }

    /// Cancel Kommand<T>
    open func cancel(_ throwingError: Bool = false) {
        if let operation = action as? Operation, operation.isExecuting {
            operation.cancel()
        }
        else if let work = action as? DispatchWorkItem, !work.isCancelled {
            work.cancel()
        }
        if throwingError {
            errorBlock?(CocoaError(.userCancelled))
        }
        successBlock = nil
        errorBlock = nil
        actionBlock = nil
    }

}
