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

    /// Kommand<Result> state
    public indirect enum State: Equatable {
        /// Uninitialized state
        case uninitialized
        /// Ready state
        case ready
        /// Executing state
        case running
        /// Succeeded state
        case succeeded(Result)
        /// Failed state
        case failed(Swift.Error)
        /// Cancelled state
        case cancelled

        public static func ==(lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.uninitialized, .uninitialized):
                return true
            case (.ready, .ready):
                return true
            case (.running, .running):
                return true
            case (.succeeded, .succeeded):
                return true
            case (.failed, .failed):
                return true
            case (.cancelled, .cancelled):
                return true
            default:
                return false
            }
        }
    }

    /// Action closure type
    public typealias ActionClosure = () throws -> Result
    /// Success closure type
    public typealias SuccessClosure = (_ result: Result) -> Void
    /// Error closure type
    public typealias ErrorClosure = (_ error: Swift.Error?) -> Void
    /// Retry closure type
    public typealias RetryClosure = (_ error: Swift.Error?, _ executionCount: UInt) -> Bool

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
    /// Execution count
    internal(set) final var executionCount: UInt
    /// Operation to cancel
    internal(set) final weak var operation: Operation?

    /// Kommand<Result> instance with deliverer, executor and actionClosure returning generic and throwing errors
    public required init(deliverer: Dispatcher = .current, executor: Dispatcher = .default, actionClosure: @escaping ActionClosure) {
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
        retryClosure = nil
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

    /// Specify Kommand<Result> error closure
    @discardableResult open func error<Reason: Swift.Error>(_ type: Reason.Type, _ error: @escaping (_ error: Reason?) -> Void) -> Self {
        self.errorClosure = {
            guard let reason = $0 as? Reason else {
                error(nil)
                return
            }
            error(reason)
        }
        return self
    }

    /// Specify Kommand<Result> retry closure
    @discardableResult open func retry(_ retry: @escaping RetryClosure) -> Self {
        self.retryClosure = retry
        return self
    }

    /// Specify Kommand<Result> error closure
    @discardableResult open func retry<Reason: Swift.Error>(_ type: Reason.Type, _ retry: @escaping (_ error: Reason?, _ executionCount: UInt) -> Bool) -> Self {
        self.retryClosure = {
            guard let reason = $0 as? Reason else {
                return retry(nil, $1)
            }
            return retry(reason, $1)
        }
        return self
    }

    open var result: Result? {
        guard case .succeeded(let result) = state else {
            return nil
        }
        return result
    }

    open var error: Error? {
        guard case .failed(let error) = state else {
            return nil
        }
        return error
    }

    /// Execute Kommand<Result> after delay
    @discardableResult open func run(after delay: DispatchTimeInterval) -> Self {
        executor?.run(after: delay, closure: {
            self.run()
        })
        return self
    }

    /// Execute Kommand<Result>
    @discardableResult open func run() -> Self {
        guard state == .ready else {
            return self
        }
        operation = executor?.run {
            do {
                if let actionClosure = self.actionClosure {
                    self.state = .running
                    self.executionCount += 1
                    let result = try actionClosure()
                    guard self.state == .running else {
                        return
                    }
                    self.deliverer?.run {
                        self.state = .succeeded(result)
                        self.successClosure?(result)
                    }
                }
            } catch {
                guard self.state == .running else {
                    return
                }
                self.deliverer?.run {
                    self.state = .failed(error)
                    if self.retryClosure?(error, self.executionCount) == true {
                        self.state = .ready
                        self.run()
                    } else {
                        self.errorClosure?(error)
                    }
                }
            }
        }
        return self
    }

    /// Cancel Kommand<Result> after delay
    @discardableResult open func cancel(_ throwingError: Bool = false, after delay: DispatchTimeInterval) -> Self {
        executor?.run(after: delay, closure: {
            self.cancel(throwingError)
        })
        return self
    }

    /// Cancel Kommand<Result>
    @discardableResult open func cancel(_ throwingError: Bool = false) -> Self {
        guard state == .ready || state == .running else {
            return self
        }
        self.deliverer?.run {
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
        executor?.run(after: delay, closure: {
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
        return run()
    }

}
