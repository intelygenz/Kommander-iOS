//
//  MainDispatcher.swift
//  Kommander
//
//  Created by Alejandro Ruperez Hernando on 30/1/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import Foundation

/// Main queue dispatcher
open class MainDispatcher: Dispatcher {

    /// Dispatcher instance with main OperationQueue
    public init() {
        super.init(name: nil, qos: nil)
        operationQueue = OperationQueue.main
        dispatchQueue = DispatchQueue.main
    }

    /// - Warning: You can't use this initializer!
    private override convenience init(name: String?, qos: QualityOfService?, maxConcurrentOperationCount: Int? = nil) {
        self.init()
        assertionFailure("You can't use this initializer for a \(String(describing: type(of: self))).")
    }

    /// - Warning: You can't use this initializer!
    @available(*, deprecated, message: "This will be removed in Kommander 0.9. Use `MainDispatcher.init()` instead.")
    private override convenience init(label: String?, qos: DispatchQoS?, attributes: DispatchQueue.Attributes?, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency?, target: DispatchQueue?) {
        self.init()
        assertionFailure("You can't use this initializer for a \(String(describing: type(of: self))).")
    }

}
