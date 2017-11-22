//
//  KommandCancelledError.swift
//  Kommander
//
//  Created by Juan Trías on 27/10/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import Foundation

/// Kommander cancelled error
public struct KommandCancelledError<Result>: RecoverableError {

    private let kommand: Kommand<Result>

    init(_ kommand: Kommand<Result>) {
        self.kommand = kommand
    }

    /// Provides a set of possible recovery options to present to the user.
    public var recoveryOptions: [String] {
        return ["Retry the Kommand"]
    }

    /// Attempt to recover from this error when the user selected the
    /// option at the given index. Returns true to indicate
    /// successful recovery, and false otherwise.
    ///
    /// This entry point is used for recovery of errors handled at
    /// the "application" granularity, where nothing else in the
    /// application can proceed until the attempted error recovery
    /// completes.
    public func attemptRecovery(optionIndex recoveryOptionIndex: Int) -> Bool {
        guard kommand.state == .cancelled else {
            return false
        }
        kommand.retry()
        return true
    }

}
