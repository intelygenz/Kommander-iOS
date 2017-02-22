//
//  MainDispatcher.swift
//  Kommander
//
//  Created by Alejandro Ruperez Hernando on 30/1/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import Foundation

public class MainDispatcher: Dispatcher {

    public init() {
        super.init(name: nil, qos: nil, maxConcurrentOperationCount: NSOperationQueueDefaultMaxConcurrentOperationCount)
        operationQueue = NSOperationQueue.mainQueue()
        dispatchQueue = dispatch_get_main_queue()
    }

    private override convenience init(name: String?, qos: NSQualityOfService?, maxConcurrentOperationCount: Int) {
        self.init()
        assertionFailure("You can't use this initializer for a \(String(self.dynamicType)).")
    }

    private override convenience init(label: String?, qos: dispatch_qos_class_t, attributes: dispatch_queue_attr_t?, target: dispatch_queue_t?) {
        self.init()
        assertionFailure("You can't use this initializer for a \(String(self.dynamicType)).")
    }

}
