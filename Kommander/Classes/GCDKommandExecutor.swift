//
//  GCDKommandExecutor.swift
//  RSSReader_Core
//
//  Created by Juan on 12/5/16.
//  Copyright © 2016 Intelygenz. All rights reserved.
//

import Foundation

open class GCDKommandExecutor: KommandExecutor {
    
    public init(){
    }
    
    public func execute(_ block: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            block()
        }
    }
}
