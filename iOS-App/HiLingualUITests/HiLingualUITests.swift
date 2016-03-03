//
//  HiLingualUITests.swift
//  HiLingualUITests
//
//  Created by Garrett Davidson on 1/28/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import XCTest

class HiLingualUITests: XCTestCase {
        
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
        
        
        let app = XCUIApplication()
        app.tabBars.buttons["Profile"].tap()
        
        let hilingualProfileviewNavigationBar = app.navigationBars["HiLingual.ProfileView"]
        hilingualProfileviewNavigationBar.buttons["Edit"].tap()
        
        let displayNameTextField = app.textFields["Display Name"]
        displayNameTextField.tap()
        displayNameTextField.typeText("hi")
        hilingualProfileviewNavigationBar.buttons["Done"].tap()
        
        
        
    }
    func testEditBio() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["Profile"].tap()
        
        let hilingualProfileviewNavigationBar = app.navigationBars["HiLingual.ProfileView"]
        hilingualProfileviewNavigationBar.buttons["Edit"].tap()
        
        let textView = app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(2).childrenMatchingType(.Other).element.childrenMatchingType(.TextView).element
        textView.tap()
        textView.typeText("This Test better work!!!!!!!!jjjjjjjjsdfkjghsdfgjrxyctfuvygbuhnijhugyvftcdrcfvgybhunoubgyuftycdrcytfvgybuhbgyvftcdrtfvgybuhygvuftcydrctfvygbuh")
        hilingualProfileviewNavigationBar.buttons["Done"].tap()
        
    }
    func testDisplayName() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["Profile"].tap()
        
        let hilingualProfileviewNavigationBar = app.navigationBars["HiLingual.ProfileView"]
        hilingualProfileviewNavigationBar.buttons["Edit"].tap()
        
        let displayNameTextField = app.textFields["Display Name"]
        displayNameTextField.tap()
        displayNameTextField.typeText("NOah")
        hilingualProfileviewNavigationBar.buttons["Done"].tap()
        
        
    }
    
}
