//
//  HLUser.swift
//  HiLingual
//
//  Created by Garrett Davidson on 2/13/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation
import UIKit

enum Gender: Int {
    case Male = 0, Female
}

class HLUser: NSCoding {
    let UUID: String
    var name: String
    var displayName: String
    var knownLanguages: [Languages]
    var learningLanguages: [Languages]
    var bio: String
    let gender: Gender
    let birthdate: NSDate
    var profilePicture: UIImage

    var blockedUsers: [HLUser]?
    var usersChattedWith: [HLUser]

    var session: HLUserSession?


    init(UUID: String, name: String, displayName: String, knownLanguages: [Languages], learningLanguages: [Languages], bio: String, gender: Gender, birthdate: NSDate, profilePicture: UIImage) {
        self.UUID = UUID
        self.name = name
        self.displayName = displayName
        self.knownLanguages = knownLanguages
        self.learningLanguages = learningLanguages
        self.bio = bio
        self.gender = gender
        self.birthdate = birthdate
        self.profilePicture = profilePicture

        self.usersChattedWith = []
    }

    @objc required init?(coder aDecoder: NSCoder) {
        self.UUID = aDecoder.decodeObjectForKey("UUID") as! String
        self.name = aDecoder.decodeObjectForKey("name") as! String
        self.displayName = aDecoder.decodeObjectForKey("displayName") as! String
        self.bio = aDecoder.decodeObjectForKey("bio") as! String
        self.gender = Gender(rawValue: aDecoder.decodeObjectForKey("gender") as! Int)!
        self.birthdate = aDecoder.decodeObjectForKey("birthdate") as! NSDate
        self.profilePicture = aDecoder.decodeObjectForKey("profilePicture") as! UIImage
        self.blockedUsers = (aDecoder.decodeObjectForKey("blockedUsers") as! [HLUser]?)
        self.usersChattedWith = (aDecoder.decodeObjectForKey("usersChattedWith") as! [HLUser])
        self.session = aDecoder.decodeObjectForKey("session") as? HLUserSession

        learningLanguages = [Languages]()
        knownLanguages = [Languages]()
        for lang in aDecoder.decodeObjectForKey("learningLanguages") as! [String] {
            learningLanguages.append(Languages(rawValue: lang)!)
        }

        for lang in aDecoder.decodeObjectForKey("knownLanguages") as! [String] {
            knownLanguages.append(Languages(rawValue: lang)!)
        }
    }

    private static var currentUser: HLUser?

    static func getCurrentUser() -> HLUser! {

        if (currentUser == nil) {
            //If current user was nil and this failed, something went wrong
            currentUser = (NSUserDefaults.standardUserDefaults().objectForKey("currentUser") as? HLUser)
        }

        return currentUser
    }

    func save() {
        //This should only be called on the current user
        HLUser.currentUser = self
        NSUserDefaults.standardUserDefaults().setObject(HLUser.currentUser!, forKey: "currentUser")
    }

    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(UUID, forKey: "UUID")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(displayName, forKey: "displayName")
        aCoder.encodeObject(bio, forKey: "bio")
        aCoder.encodeObject(gender.rawValue, forKey: "gender")
        aCoder.encodeObject(birthdate, forKey: "birthdate")
        aCoder.encodeObject(profilePicture, forKey: "profilePicture")
        aCoder.encodeObject(blockedUsers, forKey: "blockedUsers")
        aCoder.encodeObject(usersChattedWith, forKey: "usersChattedWith")
        aCoder.encodeObject(session, forKey: "session")

        var learningLanguagesStrings = [String]()
        for lang in learningLanguages {
            learningLanguagesStrings.append(lang.rawValue)
        }

        var knownLanguagesStrings = [String]()
        for lang in knownLanguages {
            knownLanguagesStrings.append(lang.rawValue)
        }

        aCoder.encodeObject(learningLanguagesStrings, forKey: "learningLanguages")
        aCoder.encodeObject(knownLanguagesStrings, forKey: "knownLanguages")
    }

    class func generateTestUser() -> HLUser {
        let randomNameArray = ["Alfred", "Bob", "Charles", "David", "Eli", "Fred", "George", "Harry", "Riley" , "Joey", "Dick"]
        let randomLanguagesArray = Languages.allValues
        let randomGenderArray = [Gender.Female, Gender.Male]

        let testUUID = "1"
        let testName = randomNameArray.random()
        let testDisplayName = randomNameArray.random()

        let knownCount = Int.random(max: randomLanguagesArray.count)
        let learningCount = Int.random(max: randomLanguagesArray.count)

        var testKnown: [Languages] = []
        var testLearning: [Languages] = []

        for _ in 0..<knownCount {
            testKnown.append(randomLanguagesArray.random())
        }

        for _ in 0..<learningCount {
            testLearning.append(randomLanguagesArray.random())
        }

        let testBio = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."

        let testGender = randomGenderArray.random()
        let testBirthDate = NSDate.random()
        let testImage = UIImage(named: "person")!

        return HLUser(UUID: testUUID, name: testName, displayName: testDisplayName, knownLanguages: testKnown, learningLanguages: testLearning, bio: testBio, gender: testGender, birthdate: testBirthDate, profilePicture: testImage)
    }
}

extension Int {
    static func random(max max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(max)))
    }
}

extension Array {
    func random() -> Element {
        return self[Int.random(max: self.count)]
    }
}

extension NSDate {
    public static func random() -> NSDate {
        let dateComponents = NSDateComponents()
        dateComponents.calendar = NSCalendar.currentCalendar()
        dateComponents.day = Int.random(max: 28)
        dateComponents.month = Int.random(max: 12)
        dateComponents.year = Int.random(max: 2016)
        return dateComponents.date!
    }
}