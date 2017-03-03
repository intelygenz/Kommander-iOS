//
//  MainDispatcher.swift
//  Kommander
//
//  Created by Alejandro Ruperez Hernando on 30/1/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import Foundation

/// Main queue dispatcher
public class MainDispatcher: Dispatcher {

    /// Dispatcher instance with main OperationQueue
    public init() {
        super.init(name: nil, qos: nil, maxConcurrentOperationCount: NSOperationQueueDefaultMaxConcurrentOperationCount)
        operationQueue = NSOperationQueue.mainQueue()
        dispatchQueue = dispatch_get_main_queue()
    }

    /// - Warning: You can't use this initializer!
    private override convenience init(name: String?, qos: NSQualityOfService?, maxConcurrentOperationCount: Int) {
        self.init()
        assertionFailure("You can't use this initializer for a \(String(self.dynamicType)).")
    }

    /// - Warning: You can't use this initializer!
    private override convenience init(label: String?, qos: dispatch_qos_class_t, attributes: dispatch_queue_attr_t?, target: dispatch_queue_t?) {
        self.init()
        assertionFailure("You can't use this initializer for a \(String(self.dynamicType)).")
    }

}
