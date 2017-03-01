//
//  Kommand.swift
//  Kommander
//
//  Created by Alejandro Ruperez Hernando on 26/1/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import Foundation

/// Generic Kommand
open class Kommand<Result> {

    /// Action block type
    public typealias ActionBlock = (_ cancelAid: inout Any?) throws -> Result
    /// Success block type
    public typealias SuccessBlock = (_ result: Result) -> Void
    /// Error block type
    public typealias ErrorBlock = (_ error: Error?) -> Void
    /// Cancel block type
    public typealias CancelBlock = (_ cancelAid: Any?) -> Void

    open var isExecuting = false
    open var isCancelled = false

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
    /// Cancel block
    private(set) internal final var cancelBlock: CancelBlock?
    /// Action to cancel
    internal final var action: Any?
    /// Cancel aid object
    internal final var cancelAid: Any? = nil

    /// Kommand<Result> instance with your deliverer, your executor and your actionBlock returning generic and throwing errors
    public init(deliverer: Dispatcher, executor: Dispatcher, actionBlock: @escaping ActionBlock) {
        self.deliverer = deliverer
        self.executor = executor
        self.actionBlock = actionBlock
    }

    /// Specify Kommand<Result> success block
    open func onSuccess(_ onSuccess: @escaping SuccessBlock) -> Self {
        self.successBlock = onSuccess
        return self
    }

    /// Specify Kommand<Result> error block
    open func onError(_ onError: @escaping ErrorBlock) -> Self {
        self.errorBlock = onError
        return self
    }

    /// Specify Kommand<Result> error block
    open func onCancel(_ onCancel: @escaping CancelBlock) -> Self {
        self.cancelBlock = onCancel
        return self
    }

    /// Execute Kommand<Result>
    open func execute() -> Self {
        action = executor.execute {
            do {
                self.isExecuting = true
                if let actionBlock = self.actionBlock {
                    let result = try actionBlock(&self.cancelAid)
                    _ = self.deliverer.execute {
                        self.successBlock?(result)
                        self.isExecuting = false
                    }
                }
            } catch {
                _ = self.deliverer.execute {
                    self.errorBlock?(error)
                    self.isExecuting = false
                }
            }
        }
        return self
    }

    /// Cancel Kommand<Result>
    open func cancel(_ throwingError: Bool = false) {
        _ = self.deliverer.execute {
            self.cancelBlock?(self.cancelAid)
        }
        cancelAid = nil
        if let operation = action as? Operation, operation.isExecuting {
            operation.cancel()
        }
        else if let work = action as? DispatchWorkItem, !work.isCancelled {
            work.cancel()
        }
        action = nil
        isCancelled = true
        if throwingError {
            errorBlock?(CocoaError(.userCancelled))
        }
        successBlock = nil
        errorBlock = nil
        cancelBlock = nil
        actionBlock = nil
    }

}
