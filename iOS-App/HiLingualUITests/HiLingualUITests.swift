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
    func testSettingTab() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["Profile"].tap()
        app.navigationBars["HiLingual.ProfileView"].buttons["Settings"].tap()
        
        let tablesQuery2 = app.tables
        let showGenderSwitch = tablesQuery2.switches["Show Gender"]
        showGenderSwitch.tap()
        showGenderSwitch.tap()
        showGenderSwitch.tap()
        
        let tablesQuery = tablesQuery2
        tablesQuery.switches["Show Age"].tap()
        tablesQuery.switches["Show Profile in Matching"].tap()
        tablesQuery.switches["Display Full Name"].tap()
        app.navigationBars["HiLingual.SettingsView"].buttons["Done"].tap()
        
        
    }
    func testTextViewHeight() {
        
        let app = XCUIApplication()
        app.tables.staticTexts["This is an already accepted request"].tap()
        
        let element = app.childrenMatchingType(.Window).elementBoundByIndex(1).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element
        element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.TextView).element.tap()
        element.childrenMatchingType(.Other).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.TextView).element.tap()
        app.menuItems["Paste"].tap()
        
        let sendButton = app.buttons["Send"]
        sendButton.tap()
        sendButton.tap()
//     XCTAssert(textView.frame.size.height < 110)
        
    }
    
    func testEditingLongMessage() {
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("ConversationTableViewCell").elementBoundByIndex(4).staticTexts["LastMessageLabel"].tap()
        tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").elementBoundByIndex(4).staticTexts["ChatBubbleLeftLabel"].tap()
        app.menuItems["Edit"].tap()
        app.otherElements["InputView"].childrenMatchingType(.Other).element.childrenMatchingType(.Button).matchingIdentifier("Button").elementBoundByIndex(0).tap()
        
        
        
        let textView = XCUIApplication().otherElements["InputView"].childrenMatchingType(.Other).element.childrenMatchingType(.TextView).element
        XCTAssert(textView.frame.size.height > 2)
        
        
    }
    func testLongMessageSend(){
        
        
        
        
        
    }
    func playbuttonsGetSmallerForSomeReasonFuckMe(){
        
        let app = XCUIApplication()
        let chatbubblerightlabelStaticText = app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").elementBoundByIndex(14).staticTexts["ChatBubbleRightLabel"]
        chatbubblerightlabelStaticText.pressForDuration(0.7);
        chatbubblerightlabelStaticText.tap()
        chatbubblerightlabelStaticText.tap()
        
        let element = app.otherElements["InputView"].childrenMatchingType(.Other).element
        let textView = element.childrenMatchingType(.TextView).element
        textView.tap()
        textView.tap()
        app.menuItems["Paste"].tap()
        
        let returnButton = app.buttons["Return"]
        returnButton.tap()
        element.childrenMatchingType(.TextView).element
        returnButton.tap()
        element.childrenMatchingType(.TextView).element
        returnButton.tap()
        element.childrenMatchingType(.TextView).element
        returnButton.tap()
        element.childrenMatchingType(.TextView).element
        returnButton.tap()
        element.childrenMatchingType(.TextView).element
        returnButton.tap()
        element.childrenMatchingType(.TextView).element
        app.buttons["Send"].tap()
        
    }
    
    //Test bio
    func testEditName() {
        
        let app = XCUIApplication()
        let tabBarsQuery = app.tabBars
        let profileButton = tabBarsQuery.buttons["Profile"]
        profileButton.tap()
        
        let hilingualProfileviewNavigationBar = app.navigationBars["HiLingual.ProfileView"]
        hilingualProfileviewNavigationBar.buttons["Edit"].tap()
        
        let displayNameTextField = app.textFields["Display Name"]
        displayNameTextField.tap()
        displayNameTextField.pressForDuration(1.3);
        app.menuItems["Select All"].tap()
        
        let deleteKey = app.keys["delete"]
        deleteKey.tap()
        
        app.keys["n"].tap()
        app.keys["a"].tap()
        app.keys["m"].tap()
        app.keys["e"].tap()
        app.textFields["Display Name"]
        hilingualProfileviewNavigationBar.buttons["Done"].tap()
        tabBarsQuery.buttons["Messages"].tap()
        profileButton.tap()

        
        
        let text1 = app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element
        XCTAssert(text1.label == "name")
    }
    
    func testSetttingSwitchsDontCrash() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["Profile"].tap()
        app.navigationBars["HiLingual.ProfileView"].buttons["Settings"].tap()
        
        let tablesQuery = app.tables
        let settingswitchSwitch = tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("SettingsCell").elementBoundByIndex(0).switches["SettingSwitch"]
        settingswitchSwitch.tap()
        settingswitchSwitch.tap()
        
        let settingswitchSwitch2 = tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("SettingsCell").elementBoundByIndex(1).switches["SettingSwitch"]
        settingswitchSwitch2.tap()
        settingswitchSwitch2.tap()
        
        let settingswitchSwitch3 = tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("SettingsCell").elementBoundByIndex(2).switches["SettingSwitch"]
        settingswitchSwitch3.tap()
        settingswitchSwitch3.tap()
        
        let settingswitchSwitch4 = tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("SettingsCell").elementBoundByIndex(3).switches["SettingSwitch"]
        settingswitchSwitch4.tap()
        settingswitchSwitch4.tap()
        app.navigationBars["HiLingual.SettingsView"].buttons["Done"].tap()
        
    }
    
    func testSendSimpleMessage() {
        
        let app = XCUIApplication()
        app.tables.childrenMatchingType(.Cell).matchingIdentifier("ConversationTableViewCell").elementBoundByIndex(0).staticTexts["LastMessageLabel"].tap()
        
        let element = app.otherElements["InputView"].childrenMatchingType(.Other).element
        element.childrenMatchingType(.TextView).element.tap()
        element.childrenMatchingType(.TextView).element
        app.keys["H"].tap()
        app.keys["e"].tap()
        app.keys["l"].tap()
        app.keys["l"].tap()
        app.keys["o"].tap()
        app.buttons["Send"].tap()
        app.navigationBars["Nathan Ohlson"].buttons["Messages"].tap()
        
    }
}
