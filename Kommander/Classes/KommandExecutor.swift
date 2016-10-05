//
//  KommandExecutor.swift
//  RSSReader_Core
//
//  Created by Juan on 18/5/16.
//  Copyright © 2016 Intelygenz. All rights reserved.
//

import Foundation

public protocol KommandExecutor {
    
    func execute(_ block: @escaping() -> Void)
}
