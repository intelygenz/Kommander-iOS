//
//  Kommander.swift
//  RSSReader_Core
//
//  Created by Juan on 11/5/16.
//  Copyright © 2016 Intelygenz. All rights reserved.
//

import Foundation

open class Kommander {
    
    fileprivate let executor: KommandExecutor
    fileprivate let deliverer: KommandDeliverer
    
    public init(executor: KommandExecutor, deliverer: KommandDeliverer) {
        
        self.executor = executor
        self.deliverer = deliverer
    }
    
    open func makeKommand<T>(_ action: @escaping () throws -> T) -> Kommand<T> {
        return Kommand<T>(action: action, executor: executor, deliverer: deliverer)
    }
}
