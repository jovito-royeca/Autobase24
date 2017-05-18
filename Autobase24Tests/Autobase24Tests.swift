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
    
    // MARK: Fetch data tests
    
    /*
     * Test if we fetched and saved all vehicles to Core Data
     */
    func testFetchAllCars() {
        let expectation = self.expectation(description: "fetch all cars")
        
        APIManager.sharedInstance.fetchCars(path: .all, completion: { error in
            XCTAssert(error == nil)
            
            // check if we saved the vehicles in Core Data
            let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Vehicle")
            request.sortDescriptors = [NSSortDescriptor(key: "firstRegistrationDate", ascending: true)]
            
            let vehicles = try! APIManager.sharedInstance.dataStack.mainContext.fetch(request)
            XCTAssert(vehicles.count > 0)
            print("all vehicles = \(vehicles.count)")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    /*
     * Test if we fetched and saved the BMW vehicles to Core Data
     */
    func testFetchBWM() {
        let expectation = self.expectation(description: "fetch bmw")
        
        APIManager.sharedInstance.fetchCars(path: .bmw, completion: { error in
            XCTAssert(error == nil)
            
            // check if we saved the vehicles in Core Data
            let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Vehicle")
            request.sortDescriptors = [NSSortDescriptor(key: "firstRegistrationDate", ascending: true)]
            request.predicate = NSPredicate(format: "make = %@", "BMW")
            
            let vehicles = try! APIManager.sharedInstance.dataStack.mainContext.fetch(request)
            XCTAssert(vehicles.count > 0)
            print("bmw vehicles = \(vehicles.count)")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }

    /*
     * Test if we fetched and saved the Audi vehicles to Core Data
     */
    func testFetchAudi() {
        let expectation = self.expectation(description: "fetch audi")
        
        APIManager.sharedInstance.fetchCars(path: .audi, completion: { error in
            XCTAssert(error == nil)
            
            let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Vehicle")
            request.sortDescriptors = [NSSortDescriptor(key: "firstRegistrationDate", ascending: true)]
            request.predicate = NSPredicate(format: "make = %@", "Audi")
            
            let vehicles = try! APIManager.sharedInstance.dataStack.mainContext.fetch(request)
            XCTAssert(vehicles.count > 0)
            print("audi vehicles = \(vehicles.count)")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }

    /*
     * Test if we fetched and saved the Mercedes-Benz vehicles to Core Data
     */
    func testFetchMercedesNenz() {
        let expectation = self.expectation(description: "fetch mercedes-benz")
        
        APIManager.sharedInstance.fetchCars(path: .mercedes, completion: { error in
            XCTAssert(error == nil)
            
            let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Vehicle")
            request.sortDescriptors = [NSSortDescriptor(key: "firstRegistrationDate", ascending: true)]
            request.predicate = NSPredicate(format: "make = %@", "Mercedes-Benz")
            
            let vehicles = try! APIManager.sharedInstance.dataStack.mainContext.fetch(request)
            XCTAssert(vehicles.count > 0)
            print("mercedes vehicles = \(vehicles.count)")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
}
