//
//  KommandDeliverer.swift
//  RSSReader_Core
//
//  Created by Juan on 18/5/16.
//  Copyright © 2016 Intelygenz. All rights reserved.
//

import Foundation

public protocol KommandDeliverer {
    
    func deliver(block: () -> Void)
}