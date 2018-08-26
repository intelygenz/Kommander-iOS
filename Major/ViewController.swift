//
//  SwiftViewController.swift
//  Major
//
//  Created by Alejandro Ruperez Hernando on 28/2/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import UIKit
import Kommander

class ViewController: UIViewController {

    let kommander = Kommander()
    let sleepTime: UInt32 = 2

    @IBAction func singleAction(_ sender: UIButton) {
        kommander.do { () -> TimeInterval in
            sleep(self.sleepTime)
            return Date().timeIntervalSince1970
        }.success { result in
            print("Single: " + String(describing: result))
        }.run()
    }

    @IBAction func concurrentAction(_ sender: UIButton) {
        kommander.run(kommander.do([ { () -> Any? in
            sleep(self.sleepTime)
            print("Concurrent first: " + String(describing: Date().timeIntervalSince1970))
            return nil
        }, {
            sleep(self.sleepTime)
            print("Concurrent second: " + String(describing: Date().timeIntervalSince1970))
            return nil
        }, {
            sleep(self.sleepTime)
            print("Concurrent third: " + String(describing: Date().timeIntervalSince1970))
            return nil
        } ]), concurrent: true)
    }

    @IBAction func sequentialAction(_ sender: UIButton) {
        kommander.run(kommander.do([ { () -> Any? in
            sleep(self.sleepTime)
            print("Sequential first: " + String(describing: Date().timeIntervalSince1970))
            return nil
        }, {
            sleep(self.sleepTime)
            print("Sequential second: " + String(describing: Date().timeIntervalSince1970))
            return nil
        }, {
            sleep(self.sleepTime)
            print("Sequential third: " + String(describing: Date().timeIntervalSince1970))
            return nil
        } ]), concurrent: false)
    }

    @IBAction func errorAction(_ sender: UIButton) {
        kommander.do {
            sleep(self.sleepTime)
            throw CocoaError(.featureUnsupported)
        }.error(CocoaError.self) { error in
            print("Error: " + String(describing: error!))
        }.run()
    }

    @IBAction func crashAction(_ sender: UIButton) {
        kommander.do {
            sleep(self.sleepTime)
            fatalError()
        }.run()
    }
}
