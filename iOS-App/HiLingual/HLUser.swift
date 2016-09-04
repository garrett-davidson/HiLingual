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
    case male = 0, female, not_Set

    //It is important that these are in the same order as declared in the line above
    //We're currently not allowing "Not Specified" as an option
    static let allValues: [Gender] = [.male, .female]
}

@objc class HLUser: NSObject, NSCoding {
    var userId: Int64
    var name: String?
    var displayName: String?
    var knownLanguages: [Languages]
    var learningLanguages: [Languages]
    var bio: String?
    var gender: Gender?
    var birthdate: Date?
    var profilePicture: UIImage?

    var profilePictureURL: URL?

    var blockedUsers: [Int64]
    var usersChattedWith: [Int64]

    var pendingChats: [Int64]

    var age: Int? {
        get {
            if (self.birthdate != nil) {
                //TODO: Figure out how to do this in one line
                var a: Set<Calendar.Component> = Set()
                a.insert(Calendar.Component.year)
                return Calendar.current.dateComponents(a, from: self.birthdate!).year
            }
            return nil
        }
    }

    fileprivate var session: HLUserSession?

    init(userId: Int64, name: String?, displayName: String?, knownLanguages: [Languages]?, learningLanguages: [Languages]?, bio: String?, gender: Gender?, birthdate: Date?, profilePictureURL: URL?) {
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

    func loadImageWithCallback(_ callback: @escaping (UIImage)-> ()) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let picURL = documentsURL.appendingPathComponent("\(self.profilePictureURL!.lastPathComponent).png")

            if let data = try? Data(contentsOf: picURL) {
                self.profilePicture = UIImage(data: data)?.scaledToSize(180, height: 180)
                callback(self.profilePicture!)
                return
            }

            ChatViewController.loadFileSync(self.profilePictureURL!, writeTo: picURL, completion: {(picURL: String, error: NSError!) in
                print("downloaded to: \(picURL)")
            } as! (String, NSError?) -> Void)

            if let data = try? Data(contentsOf: picURL) {
                self.profilePicture = UIImage(data: data)?.scaledToSize(180, height: 180)

                callback(self.profilePicture!)
            } else {
                print("Failed to load image")
            }
        })
    }

    @objc required init?(coder aDecoder: NSCoder) {
        self.userId = (aDecoder.decodeObject(forKey: "UUID") as! NSNumber).int64Value
        self.name = aDecoder.decodeObject(forKey: "name") as? String
        self.displayName = aDecoder.decodeObject(forKey: "displayName") as? String
        self.bio = aDecoder.decodeObject(forKey: "bio") as? String
        if let rawGender = aDecoder.decodeObject(forKey: "gender") as? Int {
            self.gender = Gender(rawValue: rawGender)!
        } else {
            self.gender = nil
        }
        self.birthdate = aDecoder.decodeObject(forKey: "birthdate") as? Date
        self.profilePictureURL = aDecoder.decodeObject(forKey: "profilePictureURL") as? URL
        //self.blockedUsers = (aDecoder.decodeObjectForKey("blockedUsers") as! [HLUser]?)

        if let blocked = (aDecoder.decodeObject(forKey: "blockedUsers") as? [NSNumber]) {
            self.blockedUsers = blocked.map({ (num) -> Int64 in
                return num.int64Value
            })
        } else {
            self.blockedUsers = []
        }

        if let chatted2 = (aDecoder.decodeObject(forKey: "usersChattedWith2") as? [NSNumber]) {
            self.usersChattedWith = chatted2.map({ (num) -> Int64 in
                return num.int64Value
            })
        } else {
            self.usersChattedWith = []
        }

        if let pending = (aDecoder.decodeObject(forKey: "pendingChats") as? [NSNumber]) {
            self.pendingChats = pending.map({ (num) -> Int64 in
                return num.int64Value
            })
        } else {
            self.pendingChats = []
        }

        self.session = aDecoder.decodeObject(forKey: "session") as? HLUserSession

        learningLanguages = [Languages]()
        knownLanguages = [Languages]()
        for lang in aDecoder.decodeObject(forKey: "learningLanguages") as! [String] {
            learningLanguages.append(Languages(rawValue: lang)!)
        }

        for lang in aDecoder.decodeObject(forKey: "knownLanguages") as! [String] {
            knownLanguages.append(Languages(rawValue: lang)!)
        }
    }

    fileprivate static var currentUser: HLUser?

    static func getCurrentUser() -> HLUser! {

        if (currentUser == nil) {
            //If current user was nil and this failed, something went wrong
            if let userData = UserDefaults.standard.data(forKey: "currentUser") {
                currentUser = NSKeyedUnarchiver.unarchiveObject(with: userData) as? HLUser
            }
        }

        return currentUser
    }

    static func fromDict(_ userDict: NSDictionary) -> HLUser {
        let userId = (userDict["userId"] as! NSNumber).int64Value
        let displayName = userDict["displayName"] as! String

        let gender: Gender
        if let genderString = userDict["gender"] as? String {
            if genderString == "MALE" {
                gender = Gender.male
            } else if genderString == "FEMALE" {
                gender = Gender.female
            } else {
                gender = Gender.not_Set
                print("Uncrecognized gender")
            }
        } else {
            gender = .not_Set
            print("No gender returned")
        }

        //TODO: Blocked users
//        let blockedUsers = userDict["blockedUsers"]

        let bio: String?
        if let encodedBio = userDict["bio"] as? String {
            bio = encodedBio.fromBase64()
        } else {
            bio = nil
        }

        //TODO: Users chatted with
//        let usersChattedWith = userDict["usersChattedWith"]

        let birthdayNumber = (userDict["birthdate"] as! NSNumber).doubleValue
        let birthday = Date(timeIntervalSince1970: birthdayNumber / 1000)

        let imageURL: URL?
        if let tempimageURL = userDict["imageURL"] as? String {
            imageURL = URL(string: tempimageURL)
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

    static func downloadProfilePicture(_ imageURL: URL, user: HLUser) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let picURL = documentsURL.appendingPathComponent("\(imageURL).png")

        if let data = try? Data(contentsOf: picURL) {
            user.profilePicture = UIImage(data: data)?.scaledToSize(180, height: 180)
            return
            //assign your image here
        } else {

            ChatViewController.loadFileSync(imageURL, writeTo: picURL, completion: {(picURL: String, error: NSError?) in
                print("downloaded to: \(picURL)")
            })
            if let data = try? Data(contentsOf: picURL) {
                user.profilePicture = UIImage(data: data)?.scaledToSize(180, height: 180)
                return
            } else {
                print("Failed to load image")
            }
        }

    }

    static func fromJSON(_ jsonData: Data) -> HLUser? {
        if let obj = try? JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions(rawValue: 0)) {
            if let userDict = obj as? NSDictionary {
                return(fromDict(userDict))
            }
        }

        return nil
    }

    static func fromJSONArray(_ jsonData: Data) -> [HLUser] {
        var userArray = [HLUser]()
        if let obj = try? JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions(rawValue: 0)) {
            if let array = obj as? [NSDictionary] {
                for userDict in array {
                    userArray.append(fromDict(userDict))
                }
            }
        }

        return userArray
    }

    func save(_ session: HLUserSession=HLUser.getCurrentUser().session!, toServer: Bool=true) {
        //This should only be called on the current user

        HLUser.currentUser = self
        self.session = session

        let userData = NSKeyedArchiver.archivedData(withRootObject: self)
        UserDefaults.standard.set(userData, forKey: "currentUser")

        //TODO: Make this properly asynchronous
        if toServer {
            if let userJSONData = self.toJSON() {
                let request = NSMutableURLRequest(url: URL(string: "https://gethilingual.com/api/user/\(self.userId)")!)
                request.allHTTPHeaderFields = ["Content-Type": "application/json", "Authorization": "HLAT " + session.sessionId]
                request.httpMethod = "PATCH"
                request.httpBody = userJSONData
                if let returnedData = try? NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: nil) {
                    print(returnedData)
                    if let returnString = NSString(data: returnedData, encoding: String.Encoding.utf8.rawValue) {
                        print(returnString)
                    }
                }
            }
        }
    }
    func scaleImage(_ image: UIImage, toSize newSize: CGSize) -> (UIImage) {
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context!.interpolationQuality = .high
        let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
        context?.concatenate(flipVertical)
        context?.draw(image.cgImage!, in: newRect)
        let newImage = UIImage(cgImage: (context?.makeImage()!)!)
        UIGraphicsEndImageContext()
        return newImage
    }

    func toJSON() -> Data? {
        let userDict = NSMutableDictionary()
        userDict.setObject(NSNumber(value: userId), forKey: "userId" as NSCopying)
        if name != nil {
            userDict.setObject(name!, forKey: "name" as NSCopying)
        }
        if displayName != nil {
            userDict.setObject(displayName!, forKey: "displayName" as NSCopying)
        }
        if bio != nil {
            userDict.setObject(bio!.toBase64()!, forKey: "bio" as NSCopying)
        }
        if gender != nil {
            userDict.setObject("\(gender!)".uppercased(), forKey: "gender" as NSCopying)
        }
        if birthdate != nil {
            userDict.setObject(birthdate!.timeIntervalSince1970 * 1000, forKey: "birthdate" as NSCopying)
        }

        if profilePictureURL != nil {
            userDict.setObject(profilePictureURL!.absoluteString, forKey: "imageURL" as NSCopying)
        }

        let learningLanguagesStrings = learningLanguages.map { (language) -> String in
            language.rawValue
        }
        userDict.setObject(learningLanguagesStrings, forKey: "learningLanguages" as NSCopying)

        let knownLanguagesStrings = knownLanguages.map { (language) -> String in
            language.rawValue
        }
        userDict.setObject(knownLanguagesStrings, forKey: "knownLanguages" as NSCopying)

        return try? JSONSerialization.data(withJSONObject: userDict, options: JSONSerialization.WritingOptions(rawValue: 0))
    }

    func getSession() -> HLUserSession? {
        //The expilicit check against false handles the nil case
        if ((session?.isValid()) == false) {
            session = nil
        }

        return session
    }

    func setSession(_ session: HLUserSession?) {
        self.session = session
    }

    @objc func encode(with aCoder: NSCoder) {
        aCoder.encode(NSNumber(value: userId), forKey: "UUID")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(displayName, forKey: "displayName")
        aCoder.encode(bio, forKey: "bio")
        if gender != nil { aCoder.encode(gender!.rawValue, forKey: "gender") }
        aCoder.encode(birthdate, forKey: "birthdate")
        aCoder.encode(profilePictureURL, forKey: "profilePictureURL")

        let blocked = blockedUsers.map { (i) -> NSNumber in
            return NSNumber(value: i)
        }
        aCoder.encode(blocked, forKey: "blockedUsers")

        let chatted2 = usersChattedWith.map { (i) -> NSNumber in
            return NSNumber(value: i)
        }

        aCoder.encode(chatted2, forKey: "usersChattedWith2")

        let pending = pendingChats.map { (i) -> NSNumber in
            return NSNumber(value: i)
        }
        aCoder.encode(pending, forKey: "pendingChats")

        if session != nil {
            aCoder.encode(session!, forKey: "session")
        }

        var learningLanguagesStrings = [String]()
        for lang in learningLanguages {
            learningLanguagesStrings.append(lang.rawValue)
        }

        var knownLanguagesStrings = [String]()
        for lang in knownLanguages {
            knownLanguagesStrings.append(lang.rawValue)
        }

        aCoder.encode(learningLanguagesStrings, forKey: "learningLanguages")
        aCoder.encode(knownLanguagesStrings, forKey: "knownLanguages")
    }

    class func generateTestUser() -> HLUser {
        let randomNameArray = ["Alfred", "Bob", "Charles", "David", "Eli", "Fred", "George", "Harry", "Riley", "Joey", "Dick"]
        let randomLanguagesArray = Languages.allValues
        let randomGenderArray = [Gender.female, Gender.male]

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
        let testBirthDate = Date.random()
        let testImageURL = URL(string: "test.com")!

        return HLUser(userId: testUserId, name: testName, displayName: testDisplayName, knownLanguages: testKnown, learningLanguages: testLearning, bio: testBio, gender: testGender, birthdate: testBirthDate, profilePictureURL: testImageURL)
    }
}

extension Int {
    static func random(max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(max)))
    }
}

extension Array {
    func random() -> Element {
        return self[Int.random(max: self.count)]
    }
}

extension Date {
    public static func random() -> Date {
        var dateComponents = DateComponents()
        (dateComponents as NSDateComponents).calendar = NSCalendar.current
        dateComponents.day = Int.random(max: 28)
        dateComponents.month = Int.random(max: 12)
        dateComponents.year = Int.random(max: 2016)
        return (dateComponents as NSDateComponents).date!
    }
}
