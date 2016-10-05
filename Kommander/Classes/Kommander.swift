//
//  Kommander.swift
//  RSSReader_Core
//
//  Created by Juan on 11/5/16.
//  Copyright © 2016 Intelygenz. All rights reserved.
//

import Foundation

public class Kommander {
    
    private let executor: KommandExecutor
    private let deliverer: KommandDeliverer
    
    public init(executor: KommandExecutor, deliverer: KommandDeliverer) {
        
        self.executor = executor
        self.deliverer = deliverer
    }
    
    public func makeKommand<T>(action: () throws -> T) -> Kommand<T> {
        return Kommand<T>(action: action, executor: executor, deliverer: deliverer)
    }
}