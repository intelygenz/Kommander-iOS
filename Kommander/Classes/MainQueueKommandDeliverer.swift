//
//  MainQueueKommandDeliverer.swift
//  RSSReader_Core
//
//  Created by Juan on 12/5/16.
//  Copyright © 2016 Intelygenz. All rights reserved.
//

import Foundation

public class MainQueueKommandDeliverer: KommandDeliverer {
    
    public init(){
    }
    
    public func deliver(block: () -> Void) {
        dispatch_async(dispatch_get_main_queue()) {
            block()
        }
    }
}