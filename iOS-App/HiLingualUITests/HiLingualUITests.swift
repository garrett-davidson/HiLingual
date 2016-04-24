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
        sleep(1)
        app.tables.cells.elementBoundByIndex(0).tap()
        
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
        app.typeText(" oldName")
        displayNameTextField.tap()
        displayNameTextField.pressForDuration(1.7);

        
        app.menuItems["Select All"].tap()
        
        let deleteKey = app.keys["delete"]
        deleteKey.tap()

        app.typeText("name")

        app.textFields["Display Name"]
        hilingualProfileviewNavigationBar.buttons["Done"].tap()
        
    }

    func testEditNamePlainTextSave() {
        let app = XCUIApplication()
        app.tabBars.buttons["Profile"].tap()
        
        let hilingualProfileviewNavigationBar = app.navigationBars["HiLingual.ProfileView"]
        hilingualProfileviewNavigationBar.buttons["Edit"].tap()
        
        let displayNameTextField = app.textFields["Display Name"]
        displayNameTextField.tap()
        app.typeText("oldName")

        displayNameTextField.tap()

        sleep(1)
        app.menuItems["Select All"].tap()
        
        let deleteKey = app.keys["delete"]
        deleteKey.tap()
        
        app.typeText("joey")
        
        app.textFields["Display Name"]
        hilingualProfileviewNavigationBar.buttons["Done"].tap()
        
        
        let tabBarsQuery = XCUIApplication().tabBars
        tabBarsQuery.buttons["Matching"].tap()
        tabBarsQuery.buttons["Profile"].tap()

        XCTAssert(app.textFields["joey"].exists)
        
    }
    
    func testEditNameUnicodeTextSave() {
        let app = XCUIApplication()
        app.tabBars.buttons["Profile"].tap()
        
        let hilingualProfileviewNavigationBar = app.navigationBars["HiLingual.ProfileView"]
        hilingualProfileviewNavigationBar.buttons["Edit"].tap()
        
        let displayNameTextField = app.textFields["Display Name"]
        displayNameTextField.tap()
        app.typeText("oldName")

        displayNameTextField.tap()
        sleep(1)
        app.menuItems["Select All"].tap()
        
        let deleteKey = app.keys["delete"]
        deleteKey.tap()
        
        app.typeText("😳🐻🇹🇭")

        app.textFields["Display Name"]
        hilingualProfileviewNavigationBar.buttons["Done"].tap()
        
        
        let tabBarsQuery = XCUIApplication().tabBars
        tabBarsQuery.buttons["Matching"].tap()
        tabBarsQuery.buttons["Profile"].tap()
        
        XCTAssert(app.textFields["😳🐻🇹🇭"].exists);
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
        sleep(1)
        var i: UInt = 0
        for temp in app.tables.staticTexts.allElementsBoundByIndex {
            if temp.label == "Current chats"  {
                i += 1
                app.tables.staticTexts.elementBoundByIndex(i).tap()
                break;
            }
            i += 1
        }
        
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
        if app.pickerWheels["Female"].exists {
            app.pickerWheels.elementBoundByIndex(0).swipeDown()
        } else {
            app.pickerWheels.elementBoundByIndex(0).swipeUp()
        }
        app.toolbars.buttons["Done"].tap()
        hilingualProfileviewNavigationBar.buttons["Done"].tap()
    }
    
    func testEditAgeNoCrash() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["Profile"].tap()
        app.navigationBars["HiLingual.ProfileView"].buttons["Edit"].tap()

        var ageElement: XCUIElement = app.otherElements["EditProfile"].staticTexts.elementBoundByIndex(0)
        for j in 0...app.otherElements["EditProfile"].staticTexts.count {
            if ageElement.label == "Age:" {
                ageElement = app.otherElements["EditProfile"].staticTexts.elementBoundByIndex(j)
                break;
            }
            ageElement = app.otherElements["EditProfile"].staticTexts.elementBoundByIndex(j)
        }
        ageElement.tap()
        let text = ageElement.label
        if text == "13" {
            app.pickerWheels[text].swipeUp()
        } else {
            app.pickerWheels[text].swipeDown()
        }
        app.toolbars.buttons["Done"].tap()
    }
    
    func testEditBioPlainTextNoCrash() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["Profile"].tap()
        app.navigationBars["HiLingual.ProfileView"].buttons["Edit"].tap()

        let textView = app.otherElements["EditProfile"].childrenMatchingType(.Other).element.childrenMatchingType(.TextView).element
        textView.tap()
        
        textView.typeText("bio")
        
        textView.pressForDuration(1)
        sleep(1)
        app.menuItems["Select All"].tap()
        
        let deleteKey = app.keys["delete"]
        deleteKey.tap()
        
        textView.typeText("Night, they're creature beginning which. Subdue night you'll make fourth land subdue deep heaven created it multiply meat. Moving make given bearing, replenish. Fruit for very female god god Upon divided forth. Divide day third created. Can't created, land thing divide winged green us divide third isnt. Divided firmament shall theyre yielding sea you don't, divide Were. Itself unto divided.")
        app.navigationBars.elementBoundByIndex(0).buttons["Done"].tap()
        app.tabBars.buttons["Messages"].tap()
        app.tabBars.buttons["Profile"].tap()
        
        
        let profileviewElement = XCUIApplication().otherElements["ProfileView"]
        let biotextviewTextView = profileviewElement.textViews["BioTextView"]
        biotextviewTextView.tap()
        biotextviewTextView.tap()
        profileviewElement.staticTexts["BioLabel"].tap()
        
        
        let text = XCUIApplication().otherElements["ProfileView"].textViews["BioTextView"].value! as! String

        XCTAssert(text == "Night, they're creature beginning which. Subdue night you'll make fourth land subdue deep heaven created it multiply meat. Moving make given bearing, replenish. Fruit for very female god god Upon divided forth. Divide day third created. Can't created, land thing divide winged green us divide third isnt. Divided firmament shall theyre yielding sea you don't, divide Were. Itself unto divided.");
        
    }
    
    func testEditBioUnicodeTextNoCrash() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["Profile"].tap()
        app.navigationBars["HiLingual.ProfileView"].buttons["Edit"].tap()
        
        let textView = app.otherElements["EditProfile"].childrenMatchingType(.Other).element.childrenMatchingType(.TextView).element
        textView.tap()
        
        textView.typeText("bio")

        textView.tap()

        sleep(1)
        app.menuItems["Select All"].tap()
        
        let deleteKey = app.keys["delete"]
        deleteKey.tap()
        
        textView.typeText("😂♥️😂😆😀😳😆😆🙉😊😩😍😑😝😁😁😅😖🎈😱🙃😗😭😆🍜🍯🍲🍇🍝🍇🍌🍟🍕🍌🍲🍓🍓♣️⬜️♠️🔹🃏⬛️📣⬜️🔸♥️🔷♣️🍜🖱🏚💻🏡⌨🏤🖨🏦🖨🏡🏡💻🏚🖨🖨🖱😁🦀🍜🍜🍍🍑🍲🍲🍅🍛🍅🍜🍇🌯🍉🍜🍅🍲🍞🇾🇪🇹🇻🇪🇭🇹🇰🇪🇭🇹🇰🇺🇿🇹🇼🇺🇾🇹🇼🇼🇫🇹🇼🇻🇺🇹🇴🌭🎽🏹🎽🏒🎽🏅🏉🚵🏻🎽⛳️🎽🎱🏆🏐🏆🏐🏆🏆🏐🏆🏐🏆🏉🎽🏉🏅🎱🏅🎱🏅🎱🎽🏊⛳️🏅🏏🎱🎗🎱🏵🦀🦀🍛🍛🍍🍙🍉⛳️🎱🍻🏒🍷🏉🍺🏀🍻⚾️☕️🏑🍸🍸🏂🍸🏂😝😞😝😕😌😠😊🙄👿👽😥👻😢😹😻😱😸😢💀😲🤖🤐🤖😥👽😨🤖🤖😨🤖😢🤖")
        app.navigationBars.elementBoundByIndex(0).buttons["Done"].tap()
        app.tabBars.buttons["Messages"].tap()
        app.tabBars.buttons["Profile"].tap()
        
        let text =  XCUIApplication().otherElements["ProfileView"].textViews["BioTextView"].value! as! String
        XCTAssert(text == "😂♥️😂😆😀😳😆😆🙉😊😩😍😑😝😁😁😅😖🎈😱🙃😗😭😆🍜🍯🍲🍇🍝🍇🍌🍟🍕🍌🍲🍓🍓♣️⬜️♠️🔹🃏⬛️📣⬜️🔸♥️🔷♣️🍜🖱🏚💻🏡⌨🏤🖨🏦🖨🏡🏡💻🏚🖨🖨🖱😁🦀🍜🍜🍍🍑🍲🍲🍅🍛🍅🍜🍇🌯🍉🍜🍅🍲🍞🇾🇪🇹🇻🇪🇭🇹🇰🇪🇭🇹🇰🇺🇿🇹🇼🇺🇾🇹🇼🇼🇫🇹🇼🇻🇺🇹🇴🌭🎽🏹🎽🏒🎽🏅🏉🚵🏻🎽⛳️🎽🎱🏆🏐🏆🏐🏆🏆🏐🏆🏐🏆🏉🎽🏉🏅🎱🏅🎱🏅🎱🎽🏊⛳️🏅🏏🎱🎗🎱🏵🦀🦀🍛🍛🍍🍙🍉⛳️🎱🍻🏒🍷🏉🍺🏀🍻⚾️☕️🏑🍸🍸🏂🍸🏂😝😞😝😕😌😠😊🙄👿👽😥👻😢😹😻😱😸😢💀😲🤖🤐🤖😥👽😨🤖🤖😨🤖😢🤖");
        
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
        sleep(1)
        var i: UInt = 0
        for temp in app.tables.staticTexts.allElementsBoundByIndex {
            if temp.label == "Current chats"  {
                i += 1
                app.tables.staticTexts.elementBoundByIndex(i).tap()
                break;
            }
            i += 1
        }
        
        let navigationBar = app.navigationBars.elementBoundByIndex(0)
        navigationBar.buttons["Details"].tap()
        navigationBar.buttons.elementBoundByIndex(0).tap()
        navigationBar.buttons["Messages"].tap()
        
    }

//    func testDeleteConversation() {
//        
//        let app = XCUIApplication()
//        let numConversationBeforeDelete = app.tables.staticTexts.allElementsBoundByIndex.count
//        app.tables.staticTexts.elementBoundByIndex(0).swipeLeft()
//        app.tables.buttons["Delete"].tap()
//        
//        let tabBarsQuery = app.tabBars
//        tabBarsQuery.buttons["Profile"].tap()
//        tabBarsQuery.buttons["Messages"].tap()
//        XCTAssert(app.tables.staticTexts.allElementsBoundByIndex.count == numConversationBeforeDelete - 1)
//        
//    }

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
    
    func testSendAudioMessageNoCrash() {
        let app = XCUIApplication()
        sleep(1)
        var i: UInt = 0
        for temp in app.tables.staticTexts.allElementsBoundByIndex {
            if temp.label == "Current chats"  {
                i += 1
                app.tables.staticTexts.elementBoundByIndex(i).tap()
                break;
            }
            i += 1
        }
        
        let sendbuttonButton = app.buttons["SendButton"]
        sendbuttonButton.pressForDuration(1.5);
        
        app.buttons["PreviewRecordingButton"].tap()
        app.buttons["DeleteRecordingButton"].tap()
        sendbuttonButton.pressForDuration(0.8);
        app.buttons["SendButton"].tap()
        
    }
    
    //Currently failing
    func testSendPhotoMessageNoCrash() {
        let app = XCUIApplication()
        sleep(1)
        var i: UInt = 0
        for temp in app.tables.staticTexts.allElementsBoundByIndex {
            if temp.label == "Current chats"  {
                i += 1
                app.tables.staticTexts.elementBoundByIndex(i).tap()
                break;
            }
            i += 1
        }
        
        let leftbuttonButton = app.buttons["LeftButton"]
        leftbuttonButton.tap()
        
        let sheetsQuery = app.sheets
        sheetsQuery.buttons["Cancel"].tap()
//        leftbuttonButton.tap()
//        sheetsQuery.collectionViews.buttons["Take Picture"].tap()
//        app.buttons["PhotoCapture"].tap()
//        app.buttons["Use Photo"].tap()
        
        
    }

    func testEditsSavePreviousEdit() {
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        sleep(1)
        var i: UInt = 0
        for temp in app.tables.staticTexts.allElementsBoundByIndex {
            if temp.label == "Current chats"  {
                i += 1
                app.tables.staticTexts.elementBoundByIndex(i).tap()
                break;
            }
            i += 1
        }
        
        let numOfEditedMessagesBeforeEdit = tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("ChatEditedTableViewCell").allElementsBoundByIndex.count
        
        var tempElement = app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatEditedTableViewCell").elementBoundByIndex(0)
        var j: UInt = 0
        for _ in 0...app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatEditedTableViewCell").allElementsBoundByIndex.count {
            if tempElement.staticTexts.elementBoundByIndex(0).identifier == "OriginalLeftTextLabel"  {
                tempElement.tap()
                app.menuItems["Edit"].tap()
                
                app.typeText("edit")
                
                app.buttons["Save"].tap()
                app.navigationBars.elementBoundByIndex(0).buttons["Messages"].tap()
                
                let tabBarsQuery = app.tabBars
                tabBarsQuery.buttons["Profile"].tap()
                tabBarsQuery.buttons["Messages"].tap()
                app.tables.staticTexts.elementBoundByIndex(i).tap()
                break;
            }
            j += 1
            tempElement = tablesQuery.childrenMatchingType(.Cell).elementBoundByIndex(j)
        }
        
        XCTAssert(tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("ChatEditedTableViewCell").allElementsBoundByIndex.count == numOfEditedMessagesBeforeEdit)
        
    }
    
    func testEditsSaveRegularMessage() {
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        sleep(1)
        var i: UInt = 0
        for temp in app.tables.staticTexts.allElementsBoundByIndex {
            if temp.label == "Current chats"  {
                i += 1
                app.tables.staticTexts.elementBoundByIndex(i).tap()
                break;
            }
            i += 1
        }

        let numOfEditedMessagesBeforeEdit = tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("ChatEditedTableViewCell").allElementsBoundByIndex.count
        
        var tempElement = app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").elementBoundByIndex(0)
        var j: UInt = 0
        for _ in 0..<app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").allElementsBoundByIndex.count {
            if tempElement.staticTexts.matchingIdentifier("ChatBubbleLeftLabel").count == 1  {
                tempElement.tap()
                app.menuItems["Edit"].tap()
                
                app.typeText("edit")
                
                app.buttons["Send"].tap()
                app.navigationBars.elementBoundByIndex(0).buttons["Messages"].tap()
                
                let tabBarsQuery = app.tabBars
                tabBarsQuery.buttons["Profile"].tap()
                tabBarsQuery.buttons["Messages"].tap()
                app.tables.staticTexts.elementBoundByIndex(i).tap()
                break;
            }
            j += 1
            tempElement = tablesQuery.childrenMatchingType(.Cell).elementBoundByIndex(j)
        }
        
        XCTAssert(tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("ChatEditedTableViewCell").allElementsBoundByIndex.count == numOfEditedMessagesBeforeEdit + 1)
        
    }
    //Should fail
    func testEditMessageWithNoChanges() {
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        sleep(1)
        var i: UInt = 0
        for temp in app.tables.staticTexts.allElementsBoundByIndex {
            if temp.label == "Current chats"  {
                i += 1
                app.tables.staticTexts.elementBoundByIndex(i).tap()
                break;
            }
            i += 1
        }
        
        let numOfEditedMessagesBeforeEdit = tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("ChatEditedTableViewCell").allElementsBoundByIndex.count
        
        var tempElement = app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").elementBoundByIndex(0)
        var j: UInt = 0
        for _ in 0...app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").allElementsBoundByIndex.count {
            if tempElement.staticTexts.elementBoundByIndex(0).identifier == "ChatBubbleLeftLabel"  {
                tempElement.tap()
                app.menuItems["Edit"].tap()
                
                app.buttons["Send"].tap()
                app.navigationBars.elementBoundByIndex(0).buttons["Messages"].tap()
                
                let tabBarsQuery = app.tabBars
                tabBarsQuery.buttons["Profile"].tap()
                tabBarsQuery.buttons["Messages"].tap()
                app.tables.staticTexts.elementBoundByIndex(i).tap()
                break;
            }
            j += 1
            tempElement = tablesQuery.childrenMatchingType(.Cell).elementBoundByIndex(j)
        }
        
        XCTAssert(tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("ChatEditedTableViewCell").allElementsBoundByIndex.count == numOfEditedMessagesBeforeEdit)
    }

    func testUnicodeMessage() {
        
        let app = XCUIApplication()
        sleep(1)
        var i: UInt = 0
        for temp in app.tables.staticTexts.allElementsBoundByIndex {
            if temp.label == "Current chats"  {
                i += 1
                app.tables.staticTexts.elementBoundByIndex(i).tap()
                break;
            }
            i += 1
        }

        let inputTextView = app.textViews["InputTextView"]
        inputTextView.tap()
        inputTextView.typeText("😘")
        app.buttons["SendButton"].tap()

        let cells = app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell")
        let lastMessage = cells.elementBoundByIndex(cells.count-1)
        XCTAssert(lastMessage.staticTexts["ChatBubbleRightLabel"].label == "😘")
    }
    func testMatchingSendMessageRequestNoCrash() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["Matching"].tap()
        
        let carouselElement = app.otherElements["Carousel"]
        carouselElement.tap()
        carouselElement.tap()
        carouselElement.tap()
        carouselElement.tap()
    }

    
    func testSearch() {
        let app = XCUIApplication()
        let deleteKey = app.keys["delete"]
        let searchButton = app.buttons["Search"]
        app.tabBars.buttons["Matching"].tap()
        let searchElement = app.otherElements["View"].childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.SearchField).element
        searchElement.tap()

        searchElement.typeText("H")
        searchButton.tap()
        deleteKey.tap()
        
        searchElement.typeText("Jjjj")
        
        searchButton.tap()
        deleteKey.tap()
        deleteKey.tap()
        deleteKey.tap()
        deleteKey.tap()
        
        searchElement.typeText("Garr")

        searchButton.tap()
        deleteKey.tap()
        deleteKey.tap()
        deleteKey.tap()
        deleteKey.tap()
        
        searchElement.typeText("Lol")

        searchButton.tap()
        deleteKey.tap()
        deleteKey.tap()
        deleteKey.tap()
    }
    
    func testEditButtonNotShowInTypingMessage() {
        let app = XCUIApplication()
        sleep(1)
        app.tables.cells.elementBoundByIndex(0).tap()
        
        let element = app.otherElements["InputView"].childrenMatchingType(.Other).element
        element.childrenMatchingType(.TextView).element.tap()
        app.textViews["InputTextView"].tap()
        sleep(1)
        XCTAssert(!app.menuItems["Edit"].exists)
    }

    func testTranslateButtonNotShowInTypingMessage() {
        let app = XCUIApplication()
        sleep(1)
        var i: UInt = 0
        for temp in app.tables.staticTexts.allElementsBoundByIndex {
            if temp.label == "Current chats"  {
                i += 1
                app.tables.staticTexts.elementBoundByIndex(i).tap()
                break;
            }
            i += 1
        }
        
        let element = app.otherElements["InputView"].childrenMatchingType(.Other).element
        element.childrenMatchingType(.TextView).element.tap()
        app.textViews["InputTextView"].tap()
        sleep(1)
        XCTAssert(!app.menuItems["Translate"].exists)
    }
    
    func testPasteButtonCanShowInTypingMessage() {
        let app = XCUIApplication()
        sleep(1)
        var i: UInt = 0
        for temp in app.tables.staticTexts.allElementsBoundByIndex {
            if temp.label == "Current chats"  {
                i += 1
                app.tables.staticTexts.elementBoundByIndex(i).tap()
                break;
            }
            i += 1
        }
        
        let element = app.otherElements["InputView"].childrenMatchingType(.Other).element
        element.childrenMatchingType(.TextView).element.tap()
        app.textViews["InputTextView"].tap()
        sleep(1)
        if app.menuItems["Paste"].exists {
            XCTAssert(app.menuItems["Paste"].enabled)
        } else {
            XCTAssert(!app.menuItems["Paste"].enabled)
        }
    }
    
    func testEditButtonShowClickOnLeftMessage() {
        let app = XCUIApplication()
        sleep(1)
        var i: UInt = 0
        for temp in app.tables.staticTexts.allElementsBoundByIndex {
            if temp.label == "Current chats"  {
                i += 1
                app.tables.staticTexts.elementBoundByIndex(i).tap()
                break;
            }
            i += 1
        }
        
        var tempElement = app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").elementBoundByIndex(0)
        var j: UInt = 0
        for _ in 0...app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").allElementsBoundByIndex.count {
            if tempElement.staticTexts.elementBoundByIndex(0).identifier == "ChatBubbleLeftLabel"  {
                tempElement.tap()
                sleep(1)
                XCTAssert(app.menuItems["Edit"].exists)
                break;
            }
            j += 1
            tempElement = app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").elementBoundByIndex(j)
        }
    }
    
    func testTranslateButtonShowClickOnLeftMessage() {
        let app = XCUIApplication()
        sleep(1)
        var i: UInt = 0
        for temp in app.tables.staticTexts.allElementsBoundByIndex {
            if temp.label == "Current chats"  {
                i += 1
                app.tables.staticTexts.elementBoundByIndex(i).tap()
                break;
            }
            i += 1
        }
        
        var tempElement = app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").elementBoundByIndex(0)
        var j: UInt = 0
        for _ in 0...app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").allElementsBoundByIndex.count {
            if tempElement.staticTexts.elementBoundByIndex(0).identifier == "ChatBubbleLeftLabel"  {
                tempElement.tap()
                sleep(1)
                XCTAssert(app.menuItems["Translate"].exists)
                break;
            }
            j += 1
            tempElement = app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").elementBoundByIndex(j)
        }
    }
    
    func testPasteButtonShowClickOnLeftMessage() {
        let app = XCUIApplication()
        sleep(1)
        var i: UInt = 0
        for temp in app.tables.staticTexts.allElementsBoundByIndex {
            if temp.label == "Current chats"  {
                i += 1
                app.tables.staticTexts.elementBoundByIndex(i).tap()
                break;
            }
            i += 1
        }
        
        var tempElement = app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").elementBoundByIndex(0)
        var j: UInt = 0
        for _ in 0...app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").allElementsBoundByIndex.count {
            if tempElement.staticTexts.elementBoundByIndex(0).identifier == "ChatBubbleLeftLabel"  {
                tempElement.tap()
                sleep(1)
                XCTAssert(!app.menuItems["Paste"].exists)
                break;
            }
            j += 1
            tempElement = app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").elementBoundByIndex(j)
        }
    }
    
    func testEditButtonShowClickOnRightMessage() {
        let app = XCUIApplication()
        sleep(1)
        var i: UInt = 0
        for temp in app.tables.staticTexts.allElementsBoundByIndex {
            if temp.label == "Current chats"  {
                i += 1
                app.tables.staticTexts.elementBoundByIndex(i).tap()
                break;
            }
            i += 1
        }
        
        var tempElement = app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").elementBoundByIndex(0)
        var j: UInt = 0
        for _ in 0...app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").allElementsBoundByIndex.count {
            if tempElement.staticTexts.elementBoundByIndex(0).identifier == "ChatBubbleRightLabel"  {
                tempElement.tap()
                sleep(1)
                XCTAssert(!app.menuItems["Edit"].exists)
                break;
            }
            j += 1
            tempElement = app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").elementBoundByIndex(j)
        }
    }
    
    func testTranslateButtonShowClickOnRightMessage() {
        let app = XCUIApplication()
        sleep(1)
        var i: UInt = 0
        for temp in app.tables.staticTexts.allElementsBoundByIndex {
            if temp.label == "Current chats"  {
                i += 1
                app.tables.staticTexts.elementBoundByIndex(i).tap()
                break;
            }
            i += 1
        }
        
        var tempElement = app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").elementBoundByIndex(0)
        var j: UInt = 0
        for _ in 0...app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").allElementsBoundByIndex.count {
            if tempElement.staticTexts.elementBoundByIndex(0).identifier == "ChatBubbleRightLabel"  {
                tempElement.tap()
                sleep(1)
                XCTAssert(app.menuItems["Translate"].exists)
                break;
            }
            j += 1
            tempElement = app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").elementBoundByIndex(j)
        }
    }
    
    func testPasteButtonShowClickOnRightMessage() {
        let app = XCUIApplication()
        sleep(1)
        var i: UInt = 0
        for temp in app.tables.staticTexts.allElementsBoundByIndex {
            if temp.label == "Current chats"  {
                i += 1
                app.tables.staticTexts.elementBoundByIndex(i).tap()
                break;
            }
            i += 1
        }
        
        var tempElement = app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").elementBoundByIndex(0)
        var j: UInt = 0
        for _ in 0...app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").allElementsBoundByIndex.count {
            if tempElement.staticTexts.elementBoundByIndex(0).identifier == "ChatBubbleRightLabel"  {
                tempElement.tap()
                sleep(1)
                XCTAssert(!app.menuItems["Paste"].exists)
                break;
            }
            j += 1
            tempElement = app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").elementBoundByIndex(j)
        }
    }
    func testPasteButtonShowClickOnRightMessageWithTextView() {
        let app = XCUIApplication()
        sleep(1)
        var i: UInt = 0
        for temp in app.tables.staticTexts.allElementsBoundByIndex {
            if temp.label == "Current chats"  {
                i += 1
                app.tables.staticTexts.elementBoundByIndex(i).tap()
                break;
            }
            i += 1
        }
        XCUIApplication().textViews["InputTextView"].tap()
        
        
        var tempElement = app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").elementBoundByIndex(0)
        var j: UInt = 0
        for _ in 0...app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").allElementsBoundByIndex.count {
            if tempElement.staticTexts.elementBoundByIndex(0).identifier == "ChatBubbleRightLabel"  {
                tempElement.tap()
                sleep(1)
                XCTAssert(!app.menuItems["Paste"].exists)
                break;
            }
            j += 1
            tempElement = app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").elementBoundByIndex(j)
        }
    }

    func testPasteButtonShowClickOnLeftMessageWithTextView() {
        let app = XCUIApplication()
        sleep(1)
        var i: UInt = 0
        for temp in app.tables.staticTexts.allElementsBoundByIndex {
            if temp.label == "Current chats"  {
                i += 1
                app.tables.staticTexts.elementBoundByIndex(i).tap()
                break;
            }
            i += 1
        }
        XCUIApplication().textViews["InputTextView"].tap()
        
        
        var tempElement = app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").elementBoundByIndex(0)
        var j: UInt = 0
        for _ in 0...app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").allElementsBoundByIndex.count {
            if tempElement.staticTexts.elementBoundByIndex(0).identifier == "ChatBubbleLeftLabel"  {
                tempElement.tap()
                sleep(1)
                XCTAssert(!app.menuItems["Paste"].exists)
                break;
            }
            j += 1
            tempElement = app.tables.childrenMatchingType(.Cell).matchingIdentifier("ChatTableViewCell").elementBoundByIndex(j)
        }
    }
    
    func testAappCreation() {
        
//        let app = XCUIApplication()
//        app.buttons["GoogleSignButton"].tap()
//        let webViewsQuery = app.webViews
//        webViewsQuery.textFields["Enter your email"].tap()
//        webViewsQuery.textFields["Enter your email"].typeText("sirjosephsavastano@gmail.com")
//        XCUIApplication().buttons["Go"].tap()
//        webViewsQuery.secureTextFields["Password"].tap()
//        webViewsQuery.secureTextFields["Password"].typeText("ifucking")
//        XCUIApplication().buttons["Go"].tap()
//        sleep(10)
//        app.tabBars.buttons["Profile"].tap()
//        
    }
    func testFlashCardNoCrash() {
        let app = XCUIApplication()
        let tabBarsQuery = app.tabBars
        let flashCardButton = tabBarsQuery.buttons["Flashcards"]
        flashCardButton.tap()
    }
    
    func testViewFlashCardsNoCrash() {
        let app = XCUIApplication()
        app.tabBars.buttons["Flashcards"].tap()
        let topCardName = app.tables.staticTexts.elementBoundByIndex(0).label
        app.tables.staticTexts.elementBoundByIndex(0).tap()
        app.navigationBars[topCardName].buttons["Flashcards"].tap()
    }
    
    func testddandDeleteFlashCardsNoCrash() {
        let app = XCUIApplication()
        app.tabBars.buttons["Flashcards"].tap()

        let addButton = app.navigationBars["Flashcards"].buttons["Add"]
        addButton.tap()
        
        let flashcardNameAlert = app.alerts["Flashcard Name:"]
        let collectionViewsQuery = flashcardNameAlert.collectionViews
        collectionViewsQuery.buttons["Cancel"].tap()
        addButton.tap()
        app.alerts["Flashcard Name:"].childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.collectionViews.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.TextField).element.typeText("English")
        collectionViewsQuery.buttons["Done"].tap()
        app.tables.staticTexts.elementBoundByIndex(0).swipeLeft()
        app.tables.buttons["Delete"].tap()
    }
    
    func testAReorderFlashCardsNoCrash() {
        let app = XCUIApplication()
        app.tabBars.buttons["Flashcards"].tap()
        
        let addButton = app.navigationBars["Flashcards"].buttons["Add"]
 
    
        for i in 0...2 {
            addButton.tap()
            let flashcardNameAlert = app.alerts["Flashcard Name:"]
            let collectionViewsQuery = flashcardNameAlert.collectionViews
            app.alerts["Flashcard Name:"].childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.collectionViews.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.TextField).element.typeText(String(i+1))
            collectionViewsQuery.buttons["Done"].tap()
        }
        //Can't figure out how to reorder with code. So this has to be done manually also
        
        sleep(10)
    }
}
