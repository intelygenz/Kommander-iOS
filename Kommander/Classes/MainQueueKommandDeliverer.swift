//
//  MainQueueKommandDeliverer.swift
//  RSSReader_Core
//
//  Created by Juan on 12/5/16.
//  Copyright © 2016 Intelygenz. All rights reserved.
//

import Foundation

open class MainQueueKommandDeliverer: KommandDeliverer {
    
    public init(){
    }
    
    public func deliver(_ block: @escaping () -> Void) {
        DispatchQueue.main.async {
            block()
        }
    }
}
