//
//  HLFlashCard.swift
//  HiLingual
//
//  Created by Noah Maxey on 4/14/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation

class HLFlashCard: NSObject, NSCoding {
    var frontText: String?
    var backText: String?

    required init?(coder aDecoder: NSCoder) {

        frontText = aDecoder.decodeObjectForKey("front") as? String
        backText = aDecoder.decodeObjectForKey("back") as? String

    }
    func encodeWithCoder(aCoder: NSCoder) {

        aCoder.encodeObject(frontText, forKey: "front")
        aCoder.encodeObject(backText, forKey: "back")
    }
    init(frontText: String, backText: String) {
        self.backText = backText
        self.frontText = frontText
    }

    func toJSON() -> NSData? {
        let userDict = NSMutableDictionary()

        if frontText != nil {
            userDict.setObject(frontText!, forKey: "front")
        }

        if backText != nil {
            userDict.setObject(backText!, forKey: "back")
        }

        return try? NSJSONSerialization.dataWithJSONObject(userDict, options: NSJSONWritingOptions(rawValue: 0))
    }
}
