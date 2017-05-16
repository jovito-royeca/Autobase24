//
//  Autobase24Tests.swift
//  Autobase24Tests
//
//  Created by Jovito Royeca on 16/05/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import XCTest
import CoreData
@testable import Autobase24

class Autobase24Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testFetchCars() {
        print("docsPath = \(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])")
        
        let expectation = self.expectation(description: "fetch cars")
        
        APIManager.sharedInstance.fetchCars(completion: { error in
            XCTAssert(error == nil)
            
            // check if we saved the vehicles in Core Data
            let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Vehicle")
            request.sortDescriptors = [NSSortDescriptor(key: "firstRegistration", ascending: true)]
            
            if let vehicles = try! APIManager.sharedInstance.dataStack.mainContext.fetch(request) as? [Vehicle] {
                print("vehicles = \(vehicles.count)")
            } else {
                print("no vehicles found")
            }
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
}
