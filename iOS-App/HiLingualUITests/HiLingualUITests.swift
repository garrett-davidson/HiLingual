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
    func testTextViewHeight() {
        
        let app = XCUIApplication()
        app.tables.childrenMatchingType(.Cell).elementBoundByIndex(0).tap()
        
        let element = app.childrenMatchingType(.Window).elementBoundByIndex(1).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element
        element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.TextView).element.tap()
        element.childrenMatchingType(.Other).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.TextView).element.tap()
        app.menuItems["Paste"].tap()
        
        let sendButton = app.buttons["SendButton"]
        sendButton.tap()
        sendButton.tap()
//     XCTAssert(textView.frame.size.height < 110)
        
    }
    
    //Test bio
    func testEditNameNoCrash() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["Profile"].tap()
        
        let hilingualProfileviewNavigationBar = app.navigationBars["HiLingual.ProfileView"]
        hilingualProfileviewNavigationBar.buttons["Edit"].tap()
        
        let displayNameTextField = app.textFields["Display Name"]
        displayNameTextField.tap()
        displayNameTextField.pressForDuration(0.7);

        app.menuItems["Select All"].tap()
        
        let deleteKey = app.keys["delete"]
        deleteKey.tap()

        app.typeText("name")
        
        app.textFields["Display Name"]
        hilingualProfileviewNavigationBar.buttons["Done"].tap()
        
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
    
    func testSendSimpleMessageNoCrash() {
        
        let app = XCUIApplication()
        app.tables.childrenMatchingType(.Cell).matchingIdentifier("ConversationTableViewCell").elementBoundByIndex(0).staticTexts["LastMessageLabel"].tap()
        
        let element = app.otherElements["InputView"].childrenMatchingType(.Other).element
        element.childrenMatchingType(.TextView).element.tap()
        element.childrenMatchingType(.TextView).element
        app.typeText("Hello")
        app.buttons["SendButton"].tap()
    }
    
    func testEditGenderNoCrash() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["Profile"].tap()
        
        let hilingualProfileviewNavigationBar = app.navigationBars["HiLingual.ProfileView"]
        hilingualProfileviewNavigationBar.buttons["Edit"].tap()
        
        app.otherElements["EditProfile"].staticTexts["GenderSelectionLabel"].tap()
        app.pickerWheels["Female"].tap()
        app.toolbars.buttons["Done"].tap()
        hilingualProfileviewNavigationBar.buttons["Done"].tap()
        
    }
    
    func testEditAgeNoCrash() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["Profile"].tap()
        
        let hilingualProfileviewNavigationBar = app.navigationBars["HiLingual.ProfileView"]
        hilingualProfileviewNavigationBar.buttons["Edit"].tap()

        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.tap()
        
        app.otherElements["EditProfile"].staticTexts["AgeSelectionLabel"].tap()
        app.pickers["PickerView"].swipeDown()
        app.toolbars.buttons["Done"].tap()
        hilingualProfileviewNavigationBar.buttons["Done"].tap()
    }
    
    func testEditBioNoCrash() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["Profile"].tap()
        
        let hilingualProfileviewNavigationBar = app.navigationBars["HiLingual.ProfileView"]
        hilingualProfileviewNavigationBar.buttons["Edit"].tap()
        
        let textView = app.otherElements["EditProfile"].childrenMatchingType(.Other).element.childrenMatchingType(.TextView).element
        textView.tap()
        textView.pressForDuration(0.9);
        
        let app2 = app
        app2.menuItems["Select All"].tap()
        
        let deleteKey = app2.keys["delete"]
        deleteKey.tap()
        
        textView.typeText("new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio new bio")
        
        hilingualProfileviewNavigationBar.buttons["Done"].tap()
    }
    
    func testEditSpeaksNoCrash() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["Profile"].tap()
        app.navigationBars["HiLingual.ProfileView"].buttons["Edit"].tap()
        app.otherElements["EditProfileView"].staticTexts["SpeaksLabel"].tap()
        
        let tablesQuery = app.tables
        let languagecellCell = tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("LanguageCell").elementBoundByIndex(0)
        languagecellCell.staticTexts["LanguageTitleLabel"].tap()
        languagecellCell.childrenMatchingType(.StaticText).matchingIdentifier("LanguageTitleLabel").elementBoundByIndex(0).tap()
        
        let languagecellCell2 = tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("LanguageCell").elementBoundByIndex(1)
        languagecellCell2.staticTexts["LanguageTitleLabel"].tap()
        languagecellCell2.childrenMatchingType(.StaticText).matchingIdentifier("LanguageTitleLabel").elementBoundByIndex(0).tap()
        
        let languagecellCell3 = tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("LanguageCell").elementBoundByIndex(2)
        languagecellCell3.staticTexts["LanguageTitleLabel"].tap()
        languagecellCell3.childrenMatchingType(.StaticText).matchingIdentifier("LanguageTitleLabel").elementBoundByIndex(0).tap()
        
        let languagecellCell4 = tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("LanguageCell").elementBoundByIndex(3)
        languagecellCell4.staticTexts["LanguageTitleLabel"].tap()
        languagecellCell4.childrenMatchingType(.StaticText).matchingIdentifier("LanguageTitleLabel").elementBoundByIndex(0).tap()
        
        let languagecellCell5 = tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("LanguageCell").elementBoundByIndex(4)
        languagecellCell5.staticTexts["LanguageTitleLabel"].tap()
        languagecellCell5.childrenMatchingType(.StaticText).matchingIdentifier("LanguageTitleLabel").elementBoundByIndex(0).tap()
        
        let languagecellCell6 = tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("LanguageCell").elementBoundByIndex(5)
        languagecellCell6.staticTexts["LanguageTitleLabel"].tap()
        languagecellCell6.childrenMatchingType(.StaticText).matchingIdentifier("LanguageTitleLabel").elementBoundByIndex(0).tap()
        
        let languagecellCell7 = tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("LanguageCell").elementBoundByIndex(6)
        languagecellCell7.staticTexts["LanguageTitleLabel"].tap()
        languagecellCell7.childrenMatchingType(.StaticText).matchingIdentifier("LanguageTitleLabel").elementBoundByIndex(0).tap()
        app.navigationBars["HiLingual.LanguageSelectionTableView"].buttons["Done"].tap()
        
        
    }
    
    func testEditLearningNoCrash() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["Profile"].tap()
        app.navigationBars["HiLingual.ProfileView"].buttons["Edit"].tap()
        app.otherElements["EditProfileView"].staticTexts["LearningLabel"].tap()

        
        let tablesQuery = app.tables
        let languagecellCell = tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("LanguageCell").elementBoundByIndex(0)
        languagecellCell.staticTexts["LanguageTitleLabel"].tap()
        languagecellCell.childrenMatchingType(.StaticText).matchingIdentifier("LanguageTitleLabel").elementBoundByIndex(0).tap()
        
        let languagecellCell2 = tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("LanguageCell").elementBoundByIndex(1)
        languagecellCell2.staticTexts["LanguageTitleLabel"].tap()
        languagecellCell2.childrenMatchingType(.StaticText).matchingIdentifier("LanguageTitleLabel").elementBoundByIndex(0).tap()
        
        let languagecellCell3 = tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("LanguageCell").elementBoundByIndex(2)
        languagecellCell3.staticTexts["LanguageTitleLabel"].tap()
        languagecellCell3.childrenMatchingType(.StaticText).matchingIdentifier("LanguageTitleLabel").elementBoundByIndex(0).tap()
        
        let languagecellCell4 = tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("LanguageCell").elementBoundByIndex(3)
        languagecellCell4.staticTexts["LanguageTitleLabel"].tap()
        languagecellCell4.childrenMatchingType(.StaticText).matchingIdentifier("LanguageTitleLabel").elementBoundByIndex(0).tap()
        
        let languagecellCell5 = tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("LanguageCell").elementBoundByIndex(4)
        languagecellCell5.staticTexts["LanguageTitleLabel"].tap()
        languagecellCell5.childrenMatchingType(.StaticText).matchingIdentifier("LanguageTitleLabel").elementBoundByIndex(0).tap()
        
        let languagecellCell6 = tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("LanguageCell").elementBoundByIndex(5)
        languagecellCell6.staticTexts["LanguageTitleLabel"].tap()
        languagecellCell6.childrenMatchingType(.StaticText).matchingIdentifier("LanguageTitleLabel").elementBoundByIndex(0).tap()
        
        let languagecellCell7 = tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("LanguageCell").elementBoundByIndex(6)
        languagecellCell7.staticTexts["LanguageTitleLabel"].tap()
        languagecellCell7.childrenMatchingType(.StaticText).matchingIdentifier("LanguageTitleLabel").elementBoundByIndex(0).tap()
        app.navigationBars["HiLingual.LanguageSelectionTableView"].buttons["Done"].tap()
        
        
    }
    
    func testMessagesProfileViewNoCrash(){
        
        let app = XCUIApplication()

        app.tables.childrenMatchingType(.Cell).matchingIdentifier("ConversationTableViewCell").elementBoundByIndex(0).staticTexts["LastMessageLabel"].tap()
        
        let navBar = app.navigationBars.elementBoundByIndex(0)
        navBar.buttons["Details"].tap()
        navBar.buttons.elementBoundByIndex(0).tap()
        navBar.buttons["Messages"].tap()
        
    }
    
    func testSendMessageButton() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["Matching"].tap()
        
        let carouselElement = app.otherElements["Carousel"]
        carouselElement.tap()
        carouselElement.tap()
        carouselElement.tap()
        carouselElement.tap()
        carouselElement.tap()
        carouselElement.tap()
        carouselElement.tap()
        carouselElement.tap()
        
    }
    
    func testEditsSave() {
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        let lastmessagelabelStaticText = tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("ConversationTableViewCell").elementBoundByIndex(0).staticTexts["LastMessageLabel"]
        lastmessagelabelStaticText.tap()
        
        let numOfEditedMessagesBeforeEdit = tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("ChatEditedTableViewCell").allElementsBoundByIndex.count
        
        tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").elementBoundByIndex(0).staticTexts["ChatBubbleLeftLabel"].tap()
        app.menuItems["Edit"].tap()
    
        app.otherElements["InputView"].childrenMatchingType(.Other).element.childrenMatchingType(.TextView).element.tap()
        app.menuItems["Select"].tap()
        
        app.keys["j"]

        app.buttons["Save"].tap()
        app.navigationBars.elementBoundByIndex(0).buttons["Messages"].tap()
        
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Profile"].tap()
        tabBarsQuery.buttons["Messages"].tap()
        lastmessagelabelStaticText.tap()
        
        
        XCTAssert(tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("ChatEditedTableViewCell").allElementsBoundByIndex.count == numOfEditedMessagesBeforeEdit + 1)
        
    }
    
    func testEditMessageWithNoChanges() {
        let app = XCUIApplication()
        let tablesQuery = app.tables
        let lastmessagelabelStaticText = tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("ConversationTableViewCell").elementBoundByIndex(0).staticTexts["LastMessageLabel"]
        lastmessagelabelStaticText.tap()
        
        let numOfEditedMessagesBeforeEdit = tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("ChatEditedTableViewCell").allElementsBoundByIndex.count
        
        tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").elementBoundByIndex(0).staticTexts["ChatBubbleLeftLabel"].tap()
        app.menuItems["Edit"].tap()
        
        app.otherElements["InputView"].childrenMatchingType(.Other).element.childrenMatchingType(.TextView).element.tap()
        app.menuItems["Select"].tap()
        
        app.keys["j"]
        
        app.buttons["Save"].tap()
        app.navigationBars.elementBoundByIndex(0).buttons["Messages"].tap()
        
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Profile"].tap()
        tabBarsQuery.buttons["Messages"].tap()
        lastmessagelabelStaticText.tap()
        
        XCTAssert(XCUIApplication().tables.cells["ChatEditedTableViewCell"].childrenMatchingType(.StaticText).matchingIdentifier("OriginalLeftTextLabel").allElementsBoundByIndex.count == 1)
    }
}
