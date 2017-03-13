//
//  InterfaceController.swift
//  Major watchOS Extension
//
//  Created by Alejandro Ruperez Hernando on 13/3/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import WatchKit
import Foundation
import Kommander

class InterfaceController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
