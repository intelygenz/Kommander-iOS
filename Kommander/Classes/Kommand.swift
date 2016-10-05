//
//  Kommand.swift
//  RSSReader_Core
//
//  Created by Juan on 11/5/16.
//  Copyright © 2016 Intelygenz. All rights reserved.
//

import Foundation

open class Kommand<T> {

    public typealias ActionBlock = () throws -> T
    public typealias SuccessBlock = (_ result: T) -> Void
    public typealias ErrorBlock = (_ error: Error) -> Void
    
    fileprivate let action: ActionBlock
    fileprivate var successBlock: SuccessBlock?
    fileprivate var errorBlock: ErrorBlock?
    
    fileprivate let executor: KommandExecutor
    fileprivate let deliverer: KommandDeliverer
    
    internal init(action: @escaping ActionBlock, executor: KommandExecutor, deliverer: KommandDeliverer) {
        self.action = action
        self.executor = executor
        self.deliverer = deliverer
    }
    
    open func onSuccess(_ onSuccess: @escaping SuccessBlock) -> Self {
        self.successBlock = onSuccess
        return self
    }
    
    open func onError(_ onError: @escaping ErrorBlock) -> Self {
        self.errorBlock = onError
        return self
    }
    
    open func execute() {        
        executor.execute { 
            do {
                let result = try self.action()
                self.deliverer.deliver {
                    self.successBlock?(result)
                }
            } catch let error {
                self.deliverer.deliver {
                    self.errorBlock?(error)
                }
            }
        }
    }
}
