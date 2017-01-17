import UIKit
import XCTest
import Kommander

class KommanderTests: XCTestCase {
    
    var kommander: Kommander!
    var interactor: CommonInteractor!
    
    override func setUp() {
        super.setUp()
        
        kommander = Kommander(executor: GCDKommandExecutor(), deliverer: MainQueueKommandDeliverer())
        interactor = CommonInteractor(kommander: kommander)
    }
    
    
    func test_oneCall() {
        
        let ex = expectation(description: String(describing: type(of: self)))
        
        interactor.getCounter(name: "C1", to: 3)
            .onSuccess({ (name) in
                ex.fulfill()
            })
            .onError({ (error) in
                ex.fulfill()
                XCTFail()
            }).execute()
        
        waitForExpectations(timeout: 100, handler: nil)
    }
    
    func test_twoCalls() {
        
        let ex = expectation(description: String(describing: type(of: self)))
        
        var successes = 0
        
        let k1 = interactor.getCounter(name: "C1", to: 3)
            .onSuccess({ (name) in
                successes+=1
                if successes>=2 {
                    ex.fulfill()
                }
            })
            .onError({ (error) in
                ex.fulfill()
                XCTFail()
            })
        
        let k2 = interactor.getCounter(name: "C2", to: 5)
            .onSuccess({ (name) in
                successes+=1
                if successes>=2 {
                    ex.fulfill()
                }
            })
            .onError({ (error) in
                ex.fulfill()
                XCTFail()
            })
        
        k1.execute()
        k2.execute()
        
        waitForExpectations(timeout: 100, handler: nil)
    }
    
    func test_nCalls() {
        
        let ex = expectation(description: String(describing: type(of: self)))
        
        var successes = 0
        let calls = Int(arc4random_uniform(10) + 1)
        
        for i in 0..<calls {
            interactor.getCounter(name: "C\(i)", to: 3)
                .onSuccess({ (name) in
                    successes+=1
                    if successes>=calls {
                        ex.fulfill()
                    }
                })
                .onError({ (error) in
                    ex.fulfill()
                    XCTFail()
                })
                .execute()
        }
        
        waitForExpectations(timeout: 100, handler: nil)
    }
}

extension KommanderTests {
    
    class CommonInteractor {
        
        let kommander: Kommander
        
        
        init(kommander: Kommander) {
            self.kommander = kommander
        }
        
        func getCounter(name: String, to: Int) -> Kommand<String> {
            return kommander.makeKommand({ () -> String in
                print (name + " Starts\n")
                var cont = 0
                while cont < to {
//                    for _ in 0...1000000 {}
                    sleep(arc4random_uniform(3) + 1)
                    print(cont)
                    cont+=1
                }
                print(name + "Ends\n")
                return name
            })
        }
    }
}






