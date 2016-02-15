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
}