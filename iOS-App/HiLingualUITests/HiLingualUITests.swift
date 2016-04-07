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
    func testEditNameNoCrash() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["Profile"].tap()
        
        let hilingualProfileviewNavigationBar = app.navigationBars["HiLingual.ProfileView"]
        hilingualProfileviewNavigationBar.buttons["Edit"].tap()
        
        let displayNameTextField = app.textFields["Display Name"]
        displayNameTextField.tap()
        displayNameTextField.pressForDuration(0.7);
        
        let app2 = app
        app2.menuItems["Select All"].tap()
        
        let deleteKey = app2.keys["delete"]
        deleteKey.tap()
        
        app.keys["n"].tap()
        app.keys["a"].tap()
        app.keys["m"].tap()
        app.keys["e"].tap()
        
        app2.textFields["Display Name"]
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
    
    func testEditGenderNoCrash() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["Profile"].tap()
        
        let hilingualProfileviewNavigationBar = app.navigationBars["HiLingual.ProfileView"]
        hilingualProfileviewNavigationBar.buttons["Edit"].tap()
        
        let app2 = app
        app2.otherElements["EditProfile"].staticTexts["Female"].tap()
        app2.pickerWheels["Female"].tap()
        app2.toolbars.buttons["Done"].tap()
        hilingualProfileviewNavigationBar.buttons["Done"].tap()
        
    }
    
    func testEditAgeNoCrash() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["Profile"].tap()
        
        let hilingualProfileviewNavigationBar = app.navigationBars["HiLingual.ProfileView"]
        hilingualProfileviewNavigationBar.buttons["Edit"].tap()
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.tap()
        
        let app2 = app
        app2.otherElements["EditProfile"].staticTexts["100"].tap()
        app2.pickerWheels["100"].swipeDown()
        app2.toolbars.buttons["Done"].tap()
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
        app.otherElements["EditProfile"].staticTexts["Speaks: Mandarin, Russian, English"].tap()
        
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
        app.otherElements["EditProfile"].staticTexts["Learning: Mandarin"].tap()
        
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
        
        let nathanOhlsonNavigationBar = app.navigationBars["Nathan Ohlson"]
        nathanOhlsonNavigationBar.buttons["Details"].tap()
        nathanOhlsonNavigationBar.buttons["Nathan Ohlson"].tap()
        nathanOhlsonNavigationBar.buttons["Messages"].tap()
        
    }
    
    func testDeleteConversation() {
        
        let app = XCUIApplication()
        app.tables.childrenMatchingType(.Cell).matchingIdentifier("ConversationTableViewCell").elementBoundByIndex(3).staticTexts["LastMessageLabel"].swipeLeft()
        app.tables.buttons["Delete"].tap()
        
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Profile"].tap()
        tabBarsQuery.buttons["Messages"].tap()
        XCTAssert(app.tables
            .childrenMatchingType(.Cell).matchingIdentifier("ConversationTableViewCell").allElementsBoundByIndex.count == 3)
        
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
        tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").elementBoundByIndex(4).staticTexts["ChatBubbleLeftLabel"].tap()
        app.menuItems["Edit"].tap()
        app.otherElements["InputView"].childrenMatchingType(.Other).element.childrenMatchingType(.TextView).element.tap()
        app.menuItems["Select"].tap()
        
        let deleteKey = app.keys["delete"]
        deleteKey.tap()
        deleteKey.tap()
        app.buttons["Save"].tap()
        app.navigationBars["Noah Maxey"].buttons["Messages"].tap()
        
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Profile"].tap()
        tabBarsQuery.buttons["Messages"].tap()
        lastmessagelabelStaticText.tap()
        
        
        //You should be able to tap on the second edit. But it does not show up. 
        XCUIApplication().tables.cells["ChatEditedTableViewCell"].childrenMatchingType(.StaticText).matchingIdentifier("OriginalLeftTextLabel").elementBoundByIndex(2).tap()
        
    }
    
    func testEditMessageWithNoChanges() {
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        let lastmessagelabelStaticText = tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("ConversationTableViewCell").elementBoundByIndex(0).staticTexts["LastMessageLabel"]
        lastmessagelabelStaticText.tap()
        tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").elementBoundByIndex(6).staticTexts["ChatBubbleLeftLabel"].tap()
        app.menuItems["Edit"].tap()
        app.buttons["Save"].tap()
        app.navigationBars["Noah Maxey"].buttons["Messages"].tap()
        
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Profile"].tap()
        tabBarsQuery.buttons["Messages"].tap()
        lastmessagelabelStaticText.tap()
        
        XCTAssert(      XCUIApplication().tables.cells["ChatEditedTableViewCell"].childrenMatchingType(.StaticText).matchingIdentifier("OriginalLeftTextLabel").allElementsBoundByIndex.count == 1)
    }
    
    func testAudioMessagePlayButtonNotShowingCorrectly() {
        
        let tablesQuery = XCUIApplication().tables
        tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("ConversationTableViewCell").elementBoundByIndex(4).staticTexts["LastMessageLabel"].tap()
        XCTAssert(tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").elementBoundByIndex(4).buttons["PlaybackButton"].frame == CGRectMake(15, 0, 30, 30))
        
    }
}
