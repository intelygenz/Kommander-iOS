//
//  Kommand.swift
//  Kommander
//
//  Created by Alejandro Ruperez Hernando on 26/1/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import Foundation

public class Kommand<T> {

    public typealias ActionBlock = () throws -> T
    public typealias SuccessBlock = (result: T) -> Void
    public typealias ErrorBlock = (error: ErrorType) -> Void

    private final let deliverer: Dispatcher
    private final let executor: Dispatcher
    internal final let actionBlock: ActionBlock
    private(set) internal final var successBlock: SuccessBlock?
    private(set) internal final var errorBlock: ErrorBlock?
    internal final var action: Any?

    public init(deliverer: Dispatcher, executor: Dispatcher, actionBlock: ActionBlock) {
        self.deliverer = deliverer
        self.executor = executor
        self.actionBlock = actionBlock
    }

    public func onSuccess(onSuccess: SuccessBlock) -> Self {
        self.successBlock = onSuccess
        return self
    }

    public func onError(onError: ErrorBlock) -> Self {
        self.errorBlock = onError
        return self
    }

    public func execute() {
        action = executor.execute {
            do {
                let result = try self.actionBlock()
                _ = self.deliverer.execute {
                    self.successBlock?(result: result)
                }
            } catch {
                _ = self.deliverer.execute {
                    self.errorBlock?(error: error)
                }
            }
        }
    }

    public func cancel() {
        if let operation = action as? NSOperation where operation.executing {
            operation.cancel()
        }
        else if let block = action as? dispatch_block_t where dispatch_block_testcancel(block) == 0 {
            dispatch_block_cancel(block)
        }
    }

}
