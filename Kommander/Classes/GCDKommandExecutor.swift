//
//  GCDKommandExecutor.swift
//  RSSReader_Core
//
//  Created by Juan on 12/5/16.
//  Copyright © 2016 Intelygenz. All rights reserved.
//

import Foundation

public class GCDKommandExecutor: KommandExecutor {
    
    public init(){
    }
    
    public func execute(block: () -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            
            block()
        }
    }
}