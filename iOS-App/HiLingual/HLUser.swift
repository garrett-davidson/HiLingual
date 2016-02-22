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

class HLUser {
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

    class func generateTestUser() -> HLUser {
        let randomNameArray = ["Alfred", "Bob", "Charles", "David", "Eli", "Fred", "George", "Harry", "Riley" , "Joey", "IT IS NOT RANDOM"]
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
        return Int(rand() % Int32(max))
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