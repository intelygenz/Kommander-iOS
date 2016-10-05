//
//  Kommand.swift
//  RSSReader_Core
//
//  Created by Juan on 11/5/16.
//  Copyright © 2016 Intelygenz. All rights reserved.
//

import Foundation

public class Kommand<T> {

    public typealias ActionBlock = () throws -> T
    public typealias SuccessBlock = (result: T) -> Void
    public typealias ErrorBlock = (error: ErrorType) -> Void
    
    private let action: ActionBlock
    private var successBlock: SuccessBlock?
    private var errorBlock: ErrorBlock?
    
    private let executor: KommandExecutor
    private let deliverer: KommandDeliverer
    
    internal init(action: ActionBlock, executor: KommandExecutor, deliverer: KommandDeliverer) {
        self.action = action
        self.executor = executor
        self.deliverer = deliverer
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
        executor.execute { 
            do {
                let result = try self.action()
                self.deliverer.deliver {
                    self.successBlock?(result: result)
                }
            } catch let error {
                self.deliverer.deliver {
                    self.errorBlock?(error: error)
                }
            }
        }
    }
}