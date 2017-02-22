//
//  Kommand.swift
//  Kommander
//
//  Created by Alejandro Ruperez Hernando on 26/1/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import Foundation

@objc public protocol KommandProtocol {
    init(deliverer: Dispatcher, executor: Dispatcher, block: @escaping () -> Any)
    func onSuccess(block: @escaping (_ result: Any) -> Void) -> KommandProtocol
    func onError(block: @escaping (_ error: Error) -> Void) -> KommandProtocol
    func execute()
    func cancel()
}

open class Kommand<T>: KommandProtocol {

    public typealias ActionBlock = () throws -> T
    public typealias SuccessBlock = (_ result: T) -> Void
    public typealias ErrorBlock = (_ error: Error) -> Void

    private final let deliverer: Dispatcher
    private final let executor: Dispatcher
    internal final let actionBlock: ActionBlock
    private(set) internal final var successBlock: SuccessBlock?
    private(set) internal final var errorBlock: ErrorBlock?
    internal final var action: Any?

    public init(deliverer: Dispatcher, executor: Dispatcher, actionBlock: @escaping ActionBlock) {
        self.deliverer = deliverer
        self.executor = executor
        self.actionBlock = actionBlock
    }

    public convenience required init(deliverer: Dispatcher, executor: Dispatcher, block: @escaping () -> Any) {
        self.init(deliverer: deliverer, executor: executor, actionBlock: { return block() as! T })
    }

    open func onSuccess(_ onSuccess: @escaping SuccessBlock) -> Self {
        self.successBlock = onSuccess
        return self
    }

    open func onSuccess(block: @escaping (Any) -> Void) -> KommandProtocol {
        return onSuccess(block)
    }

    open func onError(_ onError: @escaping ErrorBlock) -> Self {
        self.errorBlock = onError
        return self
    }

    open func onError(block: @escaping (Error) -> Void) -> KommandProtocol {
        return onError(block)
    }

    open func execute() {
        action = executor.execute {
            do {
                let result = try self.actionBlock()
                _ = self.deliverer.execute {
                    self.successBlock?(result)
                }
            } catch {
                _ = self.deliverer.execute {
                    self.errorBlock?(error)
                }
            }
        }
    }

    open func cancel() {
        if let operation = action as? Operation, operation.isExecuting {
            operation.cancel()
        }
        else if let work = action as? DispatchWorkItem, !work.isCancelled {
            work.cancel()
        }
    }

}
