//
//  Kommand.swift
//  Kommander
//
//  Created by Alejandro Ruperez Hernando on 26/1/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import Foundation

/// Kommand<Result> state
public enum State {
    /// Uninitialized state
    case uninitialized
    /// Ready state
    case ready
    /// Executing state
    case running
    /// Finished state
    case finished
    /// Cancelled state
    case canceled
}

/// Generic Kommand
open class Kommand<Result> {

    /// Action block type
    public typealias ActionBlock = () throws -> Result
    /// Success block type
    public typealias SuccessBlock = (_ result: Result) -> Void
    /// Error block type
    public typealias ErrorBlock = (_ error: Error?) -> Void

    /// Kommand<Result> state
    internal(set) public final var state = State.uninitialized

    /// Deliverer
    private final weak var deliverer: Dispatcher?
    /// Executor
    private final weak var executor: Dispatcher?
    /// Action block
    private(set) final var actionBlock: ActionBlock?
    /// Success block
    private(set) final var successBlock: SuccessBlock?
    /// Error block
    private(set) final var errorBlock: ErrorBlock?
    /// Operation to cancel
    final weak var operation: Operation?
    /// Work to cancel
    final weak var work: DispatchWorkItem?

    /// Kommand<Result> instance with your deliverer, your executor and your actionBlock returning generic and throwing errors
    public init(deliverer: Dispatcher, executor: Dispatcher, actionBlock: @escaping ActionBlock) {
        self.deliverer = deliverer
        self.executor = executor
        self.actionBlock = actionBlock
        state = .ready
    }

    /// Release all resources
    deinit {
        operation = nil
        work = nil
        deliverer = nil
        executor = nil
        actionBlock = nil
        successBlock = nil
        errorBlock = nil
    }

    /// Specify Kommand<Result> success block
    @discardableResult open func onSuccess(_ onSuccess: @escaping SuccessBlock) -> Self {
        self.successBlock = onSuccess
        return self
    }

    /// Specify Kommand<Result> error block
    @discardableResult open func onError(_ onError: @escaping ErrorBlock) -> Self {
        self.errorBlock = onError
        return self
    }

    /// Execute Kommand<Result> after delay
    @discardableResult open func execute(after delay: TimeInterval) -> Self {
        executor?.execute(after: delay, block: { 
            self.execute()
        })

        return self
    }

    /// Execute Kommand<Result>
    @discardableResult open func execute() -> Self {
        guard state == .ready else {
            return self
        }
        let action = executor?.execute {
            do {
                if let actionBlock = self.actionBlock {
                    self.state = .running
                    let result = try actionBlock()
                    guard self.state == .running else {
                        return
                    }
                    self.deliverer?.execute {
                        self.state = .finished
                        self.successBlock?(result)
                    }
                }
            } catch {
                guard self.state == .running else {
                    return
                }
                self.deliverer?.execute {
                    self.state = .finished
                    self.errorBlock?(error)
                }
            }
        }
        if let operationAction = action as? Operation {
            operation = operationAction
        } else if let workAction = action as? DispatchWorkItem {
            work = workAction
        }

        return self
    }

    /// Cancel Kommand<Result> after delay
    open func cancel(_ throwingError: Bool = false, after delay: TimeInterval) {
        executor?.execute(after: delay, block: {
            self.cancel(throwingError)
        })
    }

    /// Cancel Kommand<Result>
    open func cancel(_ throwingError: Bool = false) {
        guard state != .canceled else {
            return
        }
        self.deliverer?.execute {
            if throwingError {
                self.errorBlock?(CocoaError(.userCancelled))
            }
            self.errorBlock = nil
            self.deliverer = nil
        }
        if let operation = operation, !operation.isFinished {
            operation.cancel()
        }
        else if let work = work, !work.isCancelled {
            work.cancel()
        }
        operation = nil
        work = nil
        executor = nil
        successBlock = nil
        actionBlock = nil
        state = .canceled
    }

}
