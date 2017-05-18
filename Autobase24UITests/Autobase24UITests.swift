//
//  Autobase24UITests.swift
//  Autobase24UITests
//
//  Created by Jovito Royeca on 16/05/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import XCTest

class Autobase24UITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        XCUIApplication().tabBars.buttons["Favorites"].tap()
        
        
        
        
    }
    
    func testSorting() {
        let app = XCUIApplication()
        var sortButton = app.navigationBars["Autobase24.CarsView"].buttons.element(boundBy: 0)
        sortButton.tap()
        sortButton.tap()
        
        // go to Favorites tab
        app.tabBars.buttons["Favorites"].tap()
        sortButton = app.navigationBars["Autobase24.FavoritesView"].buttons.element(boundBy: 0)
        sortButton.tap()
        sortButton.tap()
    }

    func testFiltering() {
        let app = XCUIApplication()
        let tablesQuery = app.tables
        
        tablesQuery.buttons["bmw"].tap()
        tablesQuery.buttons["audi"].tap()
        tablesQuery.buttons["mercedes benz"].tap()
        tablesQuery.buttons["all cars"].tap()
    }
    
    func testAddFavorites() {
        let app = XCUIApplication()
        let tablesQuery = app.tables
        
        // tap on the switches
        for i in 0..<tablesQuery.cells.count {
            let cell = tablesQuery.cells.element(boundBy: i)
            for j in 0..<cell.switches.count {
                let fSwitch = cell.switches.element(boundBy: j)
                if let on = (fSwitch.value! as AnyObject).boolValue {
                    if !on {
                        fSwitch.tap()
                    }
                }
            }
        }
    }
    
    func testRemoveFavorites() {
        let app = XCUIApplication()
        
        app.tabBars.buttons["Favorites"].tap()
        
        let tablesQuery = app.tables
        
        for i in 0..<tablesQuery.cells.count {
            let cell = tablesQuery.cells.element(boundBy: i)
            cell.swipeLeft()
            cell.buttons["Delete"].tap()
        }
    }
    
    func testCalculation() {
        let app = XCUIApplication()
        
        // go to Favorites tab and do calculation
        app.tabBars.buttons["Favorites"].tap()
        let textField = app.textFields["amountTextField"]
        textField.press(forDuration: 1.0)
        textField.typeText("10000")
        app.buttons["Calculate"].tap()
    }
}
