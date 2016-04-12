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
    case Male = 0, Female, NotSpecified

    //It is important that these are in the same order as declared in the line above
    //We're currently not allowing "Not Specified" as an option
    static let allValues: [Gender] = [.Male, .Female]
}

class HLUser: NSObject, NSCoding {
    var userId: Int64
    var name: String?
    var displayName: String?
    var knownLanguages: [Languages]
    var learningLanguages: [Languages]
    var bio: String?
    var gender: Gender?
    var birthdate: NSDate?
    var profilePicture: UIImage?

    var blockedUsers: [HLUser]?
    var usersChattedWith: [Int64]

    var pendingChats: [Int64]

    var age: Int? {
        get {
            if (self.birthdate != nil) {
                return NSCalendar.currentCalendar().components(.Year, fromDate: self.birthdate!, toDate: NSDate(), options: .MatchFirst).year
            }
            return nil
        }
    }

    private var session: HLUserSession?

    init(userId: Int64, name: String?, displayName: String?, knownLanguages: [Languages]?, learningLanguages: [Languages]?, bio: String?, gender: Gender?, birthdate: NSDate?, profilePicture: UIImage?) {
        self.userId = userId
        self.name = name
        self.displayName = displayName
        self.knownLanguages = knownLanguages != nil ? knownLanguages! : []
        self.learningLanguages = learningLanguages != nil ? learningLanguages! : []
        self.bio = bio
        self.gender = gender
        self.birthdate = birthdate
        self.profilePicture = profilePicture

        self.usersChattedWith = []
        self.pendingChats = []
    }

    @objc required init?(coder aDecoder: NSCoder) {
        self.userId = (aDecoder.decodeObjectForKey("UUID") as! NSNumber).longLongValue
        self.name = aDecoder.decodeObjectForKey("name") as? String
        self.displayName = aDecoder.decodeObjectForKey("displayName") as? String
        self.bio = aDecoder.decodeObjectForKey("bio") as? String
        if let rawGender = aDecoder.decodeObjectForKey("gender") as? Int {
            self.gender = Gender(rawValue: rawGender)!
        }
        else {
            self.gender = nil
        }
        self.birthdate = aDecoder.decodeObjectForKey("birthdate") as? NSDate
        self.profilePicture = aDecoder.decodeObjectForKey("profilePicture") as? UIImage
        self.blockedUsers = (aDecoder.decodeObjectForKey("blockedUsers") as! [HLUser]?)

        if let chatted2 = (aDecoder.decodeObjectForKey("usersChattedWith2") as? [NSNumber]) {
            self.usersChattedWith = chatted2.map({ (num) -> Int64 in
                return num.longLongValue
            })
        }
        else {
            self.usersChattedWith = []
        }

        if let pending = (aDecoder.decodeObjectForKey("pendingChats") as? [NSNumber]) {
            self.pendingChats = pending.map({ (num) -> Int64 in
                return num.longLongValue
            })
        }

        else {
            self.pendingChats = []
        }

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
            if let userData = NSUserDefaults.standardUserDefaults().dataForKey("currentUser") {
                currentUser = NSKeyedUnarchiver.unarchiveObjectWithData(userData) as? HLUser
            }
        }

        return currentUser
    }

    static func fromDict(userDict: NSDictionary) -> HLUser {
        let userId = (userDict["userId"] as! NSNumber).longLongValue
        let displayName = userDict["displayName"] as! String

        //                    let gender = userDict["gender"]
        //TODO: Fix this
        let gender = Gender.Female

        //Not important
        let blockedUsers = userDict["blockedUsers"]


        let bio = userDict["bio"] as! String

        //Not important
        let usersChattedWith = userDict["usersChattedWith"]

        let birthdayNumber = (userDict["birthdate"] as! NSNumber).doubleValue
        let birthday = NSDate(timeIntervalSince1970: birthdayNumber)
        //TODO: ^^ This doesn't quite work

        //TODO: Load this image
        let imageURL = userDict["imageURL"]

        let knownLanguagesStrings = userDict["knownLanguages"] as! [String]
        let learningLanguagesStrings = userDict["learningLanguages"] as! [String]

        let knownLanguages = knownLanguagesStrings.map({ (languageString) -> Languages in
            Languages(rawValue: languageString)!
        })

        let learningLanguages = learningLanguagesStrings.map({ (languageString) -> Languages in
            Languages(rawValue: languageString)!
        })



        let name = userDict["name"] as! String

        return HLUser(userId: userId, name: name, displayName: displayName, knownLanguages: knownLanguages, learningLanguages: learningLanguages, bio: bio, gender: gender, birthdate: birthday, profilePicture: UIImage(named: "cantaloupe"))
    }

    static func fromJSON(jsonData: NSData) -> HLUser? {
        if let obj = try? NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions(rawValue: 0)) {
            if let userDict = obj as? NSDictionary {
                return(fromDict(userDict))
            }
        }

        return nil
    }

    static func fromJSONArray(jsonData: NSData) -> [HLUser] {
        var userArray = [HLUser]()
        if let obj = try? NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions(rawValue: 0)) {
            if let array = obj as? [NSDictionary] {
                for userDict in array {
                    userArray.append(fromDict(userDict))
                }
            }
        }

        return userArray
    }

    func save(session: HLUserSession=HLUser.getCurrentUser().session!) {
        //This should only be called on the current user
        
        HLUser.currentUser = self
        var size = CGSize(width: 150, height: 150)
//        
//        let imageData = UIImagePNGRepresentation(scaleImage(HLUser.getCurrentUser().profilePicture!, toSize: size))
//        let base64String = imageData!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
//        let request = NSMutableURLRequest(URL: NSURL(string: "https://gethilingual.com/api/asset/avatar/\(HLUser.currentUser!.userId)")!)
//        if let session = HLUser.getCurrentUser().getSession() {
//            
//            request.allHTTPHeaderFields = ["Content-Type": "application/json", "Authorization": "HLAT " + session.sessionId]
//            request.HTTPMethod = "POST"
//            
//            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(NSDictionary(dictionary: ["image": base64String]), options: NSJSONWritingOptions(rawValue: 0))
//            
//            if let returnedData = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: nil) {
//                print(returnedData)
//                if let returnString = NSString(data: returnedData, encoding: NSUTF8StringEncoding) {
//                    print(returnString)
//                }
//            }
//        }
//
//
//        
//        
        

        let userData = NSKeyedArchiver.archivedDataWithRootObject(self)
        NSUserDefaults.standardUserDefaults().setObject(userData, forKey: "currentUser")
//
//        //TODO: Implement creating a loggin in to server user
//        //That way this doesn't have to be hard-coded
        if let userJSONData = self.toJSON() {
            let request = NSMutableURLRequest(URL: NSURL(string: "https://gethilingual.com/api/user/\(self.userId)")!)
            request.allHTTPHeaderFields = ["Content-Type": "application/json", "Authorization": "HLAT " + session.sessionId]
            request.HTTPMethod = "PATCH"
            request.HTTPBody = userJSONData
            if let returnedData = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: nil) {
                print(returnedData)
                if let returnString = NSString(data: returnedData, encoding: NSUTF8StringEncoding) {
                    print(returnString)
                }
            }
        }
    }
    func scaleImage(image: UIImage, toSize newSize: CGSize) -> (UIImage) {
        let newRect = CGRectIntegral(CGRectMake(0,0, newSize.width, newSize.height))
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetInterpolationQuality(context, .High)
        let flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height)
        CGContextConcatCTM(context, flipVertical)
        CGContextDrawImage(context, newRect, image.CGImage)
        let newImage = UIImage(CGImage: CGBitmapContextCreateImage(context)!)
        UIGraphicsEndImageContext()
        return newImage
    }

    func toJSON() -> NSData? {
        let userDict = NSMutableDictionary()
        userDict.setObject(NSNumber(longLong: userId), forKey: "userId")
        if name != nil {
            userDict.setObject(name!, forKey: "name")
        }
        if displayName != nil {
            userDict.setObject(displayName!, forKey: "displayName")
        }
        if bio != nil {
            userDict.setObject(bio!, forKey: "bio")
        }
        if gender != nil {
            userDict.setObject("\(gender!)".capitalizedString, forKey: "gender")
        }
        if birthdate != nil {
            userDict.setObject(birthdate!.timeIntervalSince1970 * 1000, forKey: "birthdate")
        }

        let learningLanguagesStrings = learningLanguages.map { (language) -> String in
            language.rawValue
        }
        userDict.setObject(learningLanguagesStrings, forKey: "learningLanguages")

        let knownLanguagesStrings = knownLanguages.map { (language) -> String in
            language.rawValue
        }
        userDict.setObject(knownLanguagesStrings, forKey: "learningLanguages")

        return try? NSJSONSerialization.dataWithJSONObject(userDict, options: NSJSONWritingOptions(rawValue: 0))
    }

    func getSession() -> HLUserSession? {
        //The expilicit check against false handles the nil case
        if ((session?.isValid()) == false) {
            session = nil
        }

        return session
    }

    func setSession(session: HLUserSession?) {
        self.session = session
    }

    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(NSNumber(longLong: userId), forKey: "UUID")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(displayName, forKey: "displayName")
        aCoder.encodeObject(bio, forKey: "bio")
        if gender != nil { aCoder.encodeObject(gender!.rawValue, forKey: "gender") }
        aCoder.encodeObject(birthdate, forKey: "birthdate")
        aCoder.encodeObject(profilePicture, forKey: "profilePicture")
        aCoder.encodeObject(blockedUsers, forKey: "blockedUsers")

        let chatted2 = usersChattedWith.map { (i) -> NSNumber in
            return NSNumber(longLong: i)
        }
        aCoder.encodeObject(chatted2, forKey: "usersChattedWith2")

        let pending = pendingChats.map { (i) -> NSNumber in
            return NSNumber(longLong: i)
        }
        aCoder.encodeObject(pending, forKey: "pendingChats")

        if session != nil {
            aCoder.encodeObject(session!, forKey: "session")
        }

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

        let testUserId: Int64 = 1
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

        return HLUser(userId: testUserId, name: testName, displayName: testDisplayName, knownLanguages: testKnown, learningLanguages: testLearning, bio: testBio, gender: testGender, birthdate: testBirthDate, profilePicture: testImage)
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