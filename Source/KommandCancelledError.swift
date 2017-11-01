//
//  KommandCancelledError.swift
//  Kommander
//
//  Created by Juan Trías on 27/10/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import Foundation

public struct KommandCancelledError<Result>: RecoverableError {

    private let kommand: Kommand<Result>

    init(kommand: Kommand<Result>) {
        self.kommand = kommand
    }

    public var recoveryOptions: [String] {
        return ["Retry the Kommand"]
    }

    public func attemptRecovery(optionIndex recoveryOptionIndex: Int) -> Bool {
        kommand.retry()
        return true
    }

}
