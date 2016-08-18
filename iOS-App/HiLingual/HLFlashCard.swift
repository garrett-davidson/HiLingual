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

        frontText = aDecoder.decodeObject(forKey: "front") as? String
        backText = aDecoder.decodeObject(forKey: "back") as? String

    }
    func encode(with aCoder: NSCoder) {

        aCoder.encode(frontText, forKey: "front")
        aCoder.encode(backText, forKey: "back")
    }
    init(frontText: String, backText: String) {
        self.backText = backText
        self.frontText = frontText
    }

    func toJSON() -> Data? {
        let userDict = NSMutableDictionary()

        if frontText != nil {
            userDict.setObject(frontText!, forKey: "front" as NSCopying)
        }

        if backText != nil {
            userDict.setObject(backText!, forKey: "back" as NSCopying)
        }

        return try? JSONSerialization.data(withJSONObject: userDict, options: JSONSerialization.WritingOptions(rawValue: 0))
    }
}
