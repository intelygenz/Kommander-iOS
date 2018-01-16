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
    case cancelled
}

/// Generic Kommand
open class Kommand<Result> {

    /// Action closure type
    public typealias ActionClosure = () throws -> Result
    /// Success closure type
    public typealias SuccessClosure = (_ result: Result) -> Void
    /// Error closure type
    public typealias ErrorClosure = (_ error: Error?) -> Void
    /// Retry closure type
    public typealias RetryClosure = (_ error: Error?, _ executionCount: UInt) -> Bool

    /// Kommand<Result> state
    internal(set) public final var state = State.uninitialized

    /// Deliverer
    private final weak var deliverer: Dispatcher?
    /// Executor
    private final weak var executor: Dispatcher?
    /// Action closure
    private(set) final var actionClosure: ActionClosure?
    /// Success closure
    private(set) final var successClosure: SuccessClosure?
    /// Error closure
    private(set) final var errorClosure: ErrorClosure?
    /// Retry closure
    private(set) final var retryClosure: RetryClosure?
    /// Retry count
    internal(set) final var executionCount: UInt
    /// Operation to cancel
    internal(set) final weak var operation: Operation?

    /// Kommand<Result> instance with deliverer, executor and actionClosure returning generic and throwing errors
    public init(deliverer: Dispatcher = .current, executor: Dispatcher = .default, actionClosure: @escaping ActionClosure) {
        self.deliverer = deliverer
        self.executor = executor
        self.actionClosure = actionClosure
        executionCount = 0
        state = .ready
    }

    /// Release all resources
    deinit {
        operation = nil
        deliverer = nil
        executor = nil
        actionClosure = nil
        successClosure = nil
        errorClosure = nil
    }

    /// Specify Kommand<Result> success closure
    @discardableResult open func success(_ success: @escaping SuccessClosure) -> Self {
        self.successClosure = success
        return self
    }

    /// Specify Kommand<Result> error closure
    @discardableResult open func error(_ error: @escaping ErrorClosure) -> Self {
        self.errorClosure = error
        return self
    }

    /// Specify Kommand<Result> retry closure
    @discardableResult open func retry(_ retry: @escaping RetryClosure) -> Self {
        self.retryClosure = retry
        return self
    }

    /// Execute Kommand<Result> after delay
    @discardableResult open func execute(after delay: DispatchTimeInterval) -> Self {
        executor?.execute(after: delay, closure: { 
            self.execute()
        })
        return self
    }

    /// Execute Kommand<Result>
    @discardableResult open func execute() -> Self {
        guard state == .ready else {
            return self
        }
        operation = executor?.execute {
            do {
                if let actionClosure = self.actionClosure {
                    self.state = .running
                    let result = try actionClosure()
                    self.executionCount += 1
                    guard self.state == .running else {
                        return
                    }
                    self.deliverer?.execute {
                        self.state = .finished
                        self.successClosure?(result)
                    }
                }
            } catch {
                guard self.state == .running else {
                    return
                }
                self.deliverer?.execute {
                    self.state = .finished
                    self.errorClosure?(error)
                    self.executor?.execute {
                        if self.retryClosure?(error, self.executionCount) == true {
                            self.state = .ready
                            self.execute()
                        }
                    }
                }
            }
        }
        return self
    }

    /// Cancel Kommand<Result> after delay
    @discardableResult open func cancel(_ throwingError: Bool = false, after delay: DispatchTimeInterval) -> Self {
        executor?.execute(after: delay, closure: {
            self.cancel(throwingError)
        })
        return self
    }

    /// Cancel Kommand<Result>
    @discardableResult open func cancel(_ throwingError: Bool = false) -> Self {
        guard state != .cancelled else {
            return self
        }
        self.deliverer?.execute {
            if throwingError {
                self.errorClosure?(KommandCancelledError(self))
            }
        }
        if let operation = operation, !operation.isFinished {
            operation.cancel()
        }
        state = .cancelled
        return self
    }

    /// Retry Kommand<Result> after delay
    @discardableResult open func retry(after delay: DispatchTimeInterval) -> Self {
        executor?.execute(after: delay, closure: {
            self.retry()
        })
        return self
    }

    /// Retry Kommand<Result>
    @discardableResult open func retry() -> Self {
        guard state == .cancelled else {
            return self
        }
        state = .ready
        return execute()
    }

}
