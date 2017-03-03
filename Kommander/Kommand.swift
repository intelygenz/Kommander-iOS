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
public class Kommand<Result> {

    /// Action block type
    public typealias ActionBlock = () throws -> Result
    /// Success block type
    public typealias SuccessBlock = (result: Result) -> Void
    /// Error block type
    public typealias ErrorBlock = (error: ErrorType?) -> Void

    /// Kommand<Result> state
    internal(set) public final var state = State.uninitialized

    /// Deliverer
    private final var deliverer: Dispatcher?
    /// Executor
    private final var executor: Dispatcher?
    /// Action block
    private(set) final var actionBlock: ActionBlock?
    /// Success block
    private(set) final var successBlock: SuccessBlock?
    /// Error block
    private(set) final var errorBlock: ErrorBlock?
    /// Action to cancel
    final var action: Any?

    /// Kommand<Result> instance with your deliverer, your executor and your actionBlock returning generic and throwing errors
    public init(deliverer: Dispatcher, executor: Dispatcher, actionBlock: ActionBlock) {
        self.deliverer = deliverer
        self.executor = executor
        self.actionBlock = actionBlock
        state = .ready
    }

    /// Specify Kommand<Result> success block
    public func onSuccess(onSuccess: SuccessBlock) -> Self {
        self.successBlock = onSuccess
        return self
    }

    /// Specify Kommand<Result> error block
    public func onError(onError: ErrorBlock) -> Self {
        self.errorBlock = onError
        return self
    }

    /// Execute Kommand<Result>
    public func execute() -> Self {
        guard state == .ready else {
            return self
        }
        action = executor?.execute {
            do {
                if let actionBlock = self.actionBlock {
                    self.state = .running
                    let result = try actionBlock()
                    guard self.state == .running else {
                        return
                    }
                    _ = self.deliverer?.execute {
                        self.state = .finished
                        self.successBlock?(result: result)
                    }
                }
            } catch {
                guard self.state == .running else {
                    return
                }
                _ = self.deliverer?.execute {
                    self.state = .finished
                    self.errorBlock?(error: error)
                }
            }
        }
        return self
    }

    /// Cancel Kommand<Result>
    public func cancel(throwingError: Bool = false) {
        guard state != .canceled else {
            return
        }
        _ = self.deliverer?.execute {
            if throwingError {
                self.errorBlock?(error: NSCocoaError.UserCancelledError)
            }
            self.errorBlock = nil
            self.deliverer = nil
        }
        if let operation = action as? NSOperation where operation.executing {
            operation.cancel()
        }
        else if let block = action as? dispatch_block_t where dispatch_block_testcancel(block) == 0 {
            dispatch_block_cancel(block)
        }
        action = nil
        executor = nil
        successBlock = nil
        actionBlock = nil
        state = .canceled
    }

}
