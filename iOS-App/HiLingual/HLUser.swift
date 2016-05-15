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
    case Male = 0, Female, Not_Set

    //It is important that these are in the same order as declared in the line above
    //We're currently not allowing "Not Specified" as an option
    static let allValues: [Gender] = [.Male, .Female]
}

@objc class HLUser: NSObject, NSCoding {
    var userId: Int64
    var name: String?
    var displayName: String?
    var knownLanguages: [Languages]
    var learningLanguages: [Languages]
    var bio: String?
    var gender: Gender?
    var birthdate: NSDate?
    var profilePicture: UIImage?

    var profilePictureURL: NSURL?

    var blockedUsers: [Int64]
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

    init(userId: Int64, name: String?, displayName: String?, knownLanguages: [Languages]?, learningLanguages: [Languages]?, bio: String?, gender: Gender?, birthdate: NSDate?, profilePictureURL: NSURL?) {
        self.userId = userId
        self.name = name
        self.displayName = displayName
        self.knownLanguages = knownLanguages != nil ? knownLanguages! : []
        self.learningLanguages = learningLanguages != nil ? learningLanguages! : []
        self.bio = bio
        self.gender = gender
        self.birthdate = birthdate
        self.profilePicture = nil
        self.profilePictureURL = profilePictureURL

        self.usersChattedWith = []
        self.pendingChats = []
        self.blockedUsers = []
    }

    func loadImageWithCallback(callback: (UIImage)-> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let picURL = documentsURL.URLByAppendingPathComponent("\(self.profilePictureURL!.lastPathComponent!).png")

            if let data = NSData(contentsOfURL: picURL) {
                self.profilePicture = UIImage(data: data)?.scaledToSize(180, height: 180)
                callback(self.profilePicture!)
                return
            }


            ChatViewController.loadFileSync(self.profilePictureURL!, writeTo: picURL, completion: {(picURL: String, error: NSError!) in
                print("downloaded to: \(picURL)")
            })

            if let data = NSData(contentsOfURL: picURL) {
                self.profilePicture = UIImage(data: data)?.scaledToSize(180, height: 180)

                callback(self.profilePicture!)
            } else {
                print("Failed to load image")
            }
        })
    }

    @objc required init?(coder aDecoder: NSCoder) {
        self.userId = (aDecoder.decodeObjectForKey("UUID") as! NSNumber).longLongValue
        self.name = aDecoder.decodeObjectForKey("name") as? String
        self.displayName = aDecoder.decodeObjectForKey("displayName") as? String
        self.bio = aDecoder.decodeObjectForKey("bio") as? String
        if let rawGender = aDecoder.decodeObjectForKey("gender") as? Int {
            self.gender = Gender(rawValue: rawGender)!
        } else {
            self.gender = nil
        }
        self.birthdate = aDecoder.decodeObjectForKey("birthdate") as? NSDate
        self.profilePictureURL = aDecoder.decodeObjectForKey("profilePictureURL") as? NSURL
        //self.blockedUsers = (aDecoder.decodeObjectForKey("blockedUsers") as! [HLUser]?)

        if let blocked = (aDecoder.decodeObjectForKey("blockedUsers") as? [NSNumber]) {
            self.blockedUsers = blocked.map({ (num) -> Int64 in
                return num.longLongValue
            })
        } else {
            self.blockedUsers = []
        }

        if let chatted2 = (aDecoder.decodeObjectForKey("usersChattedWith2") as? [NSNumber]) {
            self.usersChattedWith = chatted2.map({ (num) -> Int64 in
                return num.longLongValue
            })
        } else {
            self.usersChattedWith = []
        }

        if let pending = (aDecoder.decodeObjectForKey("pendingChats") as? [NSNumber]) {
            self.pendingChats = pending.map({ (num) -> Int64 in
                return num.longLongValue
            })
        } else {
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

        let gender: Gender
        if let genderString = userDict["gender"] as? String {
            if genderString == "MALE" {
                gender = Gender.Male
            } else if genderString == "FEMALE" {
                gender = Gender.Female
            } else {
                gender = Gender.Not_Set
                print("Uncrecognized gender")
            }
        } else {
            gender = .Not_Set
            print("No gender returned")
        }

        //Not important
        let blockedUsers = userDict["blockedUsers"]


        let bio: String?
        if let encodedBio = userDict["bio"] as? String {
            bio = encodedBio.fromBase64()
        } else {
            bio = nil
        }

        //Not important
        let usersChattedWith = userDict["usersChattedWith"]

        let birthdayNumber = (userDict["birthdate"] as! NSNumber).doubleValue
        let birthday = NSDate(timeIntervalSince1970: birthdayNumber / 1000)

        let imageURL: NSURL?
        if let tempimageURL = userDict["imageURL"] as? String {
            imageURL = NSURL(string: tempimageURL)
        } else {
            imageURL = nil
        }

        let knownLanguagesStrings = userDict["knownLanguages"] as! [String]
        let learningLanguagesStrings = userDict["learningLanguages"] as! [String]

        let knownLanguages = knownLanguagesStrings.map({ (languageString) -> Languages in
            Languages(rawValue: languageString)!
        })

        let learningLanguages = learningLanguagesStrings.map({ (languageString) -> Languages in
            Languages(rawValue: languageString)!
        })

        let name = userDict["name"] as! String

        return HLUser(userId: userId, name: name, displayName: displayName, knownLanguages: knownLanguages, learningLanguages: learningLanguages, bio: bio, gender: gender, birthdate: birthday, profilePictureURL:imageURL)
    }

    static func downloadProfilePicture(imageURL: NSURL, user: HLUser) {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let picURL = documentsURL.URLByAppendingPathComponent("\(imageURL).png")

        if let data = NSData(contentsOfURL: picURL) {
            user.profilePicture = UIImage(data: data)?.scaledToSize(180, height: 180)
            return
            //assign your image here
        } else {

            ChatViewController.loadFileSync(imageURL, writeTo: picURL, completion: {(picURL: String, error: NSError!) in
                print("downloaded to: \(picURL)")
            })
            if let data = NSData(contentsOfURL: picURL) {
                user.profilePicture = UIImage(data: data)?.scaledToSize(180, height: 180)
                return
            } else {
                print("Failed to load image")
            }
        }

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

    func save(session: HLUserSession=HLUser.getCurrentUser().session!, toServer: Bool=true) {
        //This should only be called on the current user

        HLUser.currentUser = self
        self.session = session

        let userData = NSKeyedArchiver.archivedDataWithRootObject(self)
        NSUserDefaults.standardUserDefaults().setObject(userData, forKey: "currentUser")

        if toServer {
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
    }
    func scaleImage(image: UIImage, toSize newSize: CGSize) -> (UIImage) {
        let newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height))
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
            userDict.setObject(bio!.toBase64()!, forKey: "bio")
        }
        if gender != nil {
            userDict.setObject("\(gender!)".uppercaseString, forKey: "gender")
        }
        if birthdate != nil {
            userDict.setObject(birthdate!.timeIntervalSince1970 * 1000, forKey: "birthdate")
        }

        if profilePictureURL != nil {
            userDict.setObject(profilePictureURL!.absoluteString, forKey: "imageURL")
        }

        let learningLanguagesStrings = learningLanguages.map { (language) -> String in
            language.rawValue
        }
        userDict.setObject(learningLanguagesStrings, forKey: "learningLanguages")

        let knownLanguagesStrings = knownLanguages.map { (language) -> String in
            language.rawValue
        }
        userDict.setObject(knownLanguagesStrings, forKey: "knownLanguages")

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
        aCoder.encodeObject(profilePictureURL, forKey: "profilePictureURL")

        let blocked = blockedUsers.map { (i) -> NSNumber in
            return NSNumber(longLong: i)
        }
        aCoder.encodeObject(blocked, forKey: "blockedUsers")

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
        let randomNameArray = ["Alfred", "Bob", "Charles", "David", "Eli", "Fred", "George", "Harry", "Riley", "Joey", "Dick"]
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
        let testImageURL = NSURL(string: "test.com")!

        return HLUser(userId: testUserId, name: testName, displayName: testDisplayName, knownLanguages: testKnown, learningLanguages: testLearning, bio: testBio, gender: testGender, birthdate: testBirthDate, profilePictureURL: testImageURL)
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
