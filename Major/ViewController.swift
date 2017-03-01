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
        _ = kommander.makeKommand { c -> Double in
            sleep(self.sleepTime)
            return Date().timeIntervalSince1970
        }.onSuccess { result in
            print("Single: " + String(describing: result))
        }.execute()
    }

    @IBAction func concurrentAction(_ sender: UIButton) {
        kommander.execute(kommander.makeKommands([{ c -> Any? in
            sleep(self.sleepTime)
            print("Concurrent first: " + String(describing: Date().timeIntervalSince1970))
            return nil
        }, { c -> Any? in
            sleep(self.sleepTime)
            print("Concurrent second: " + String(describing: Date().timeIntervalSince1970))
            return nil
        }, { c -> Any? in
            sleep(self.sleepTime)
            print("Concurrent third: " + String(describing: Date().timeIntervalSince1970))
            return nil
        }]), concurrent: true)
    }

    @IBAction func sequentialAction(_ sender: UIButton) {
        kommander.execute(kommander.makeKommands([{ c -> Any? in
            sleep(self.sleepTime)
            print("Sequential first: " + String(describing: Date().timeIntervalSince1970))
            return nil
        }, { c -> Any? in
            sleep(self.sleepTime)
            print("Sequential second: " + String(describing: Date().timeIntervalSince1970))
            return nil
        }, { c -> Any? in
            sleep(self.sleepTime)
            print("Sequential third: " + String(describing: Date().timeIntervalSince1970))
            return nil
        }]), concurrent: false)
    }

    @IBAction func errorAction(_ sender: UIButton) {
        _ = kommander.makeKommand { c -> Void in
            sleep(self.sleepTime)
            throw CocoaError(.featureUnsupported)
        }.onError { error in
            print("Error: " + String(describing: error!))
        }.execute()
    }

    @IBAction func crashAction(_ sender: UIButton) {
        _ = kommander.makeKommand { c -> Void in
            sleep(self.sleepTime)
            fatalError()
        }.execute()
    }
}
