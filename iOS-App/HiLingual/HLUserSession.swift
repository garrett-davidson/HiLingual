//
//  HLUserSession.swift
//  HiLingual
//
//  Created by Garrett Davidson on 2/14/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation

enum LoginAuthority: String {
    case Facebook = "FACEBOOK"
    case Google = "GOOGLE"
}

class HLUserSession: NSObject, NSCoding {
    let sessionId: String
    let userId: Int64

    init(userId: Int64, sessionId: String) {
        self.userId = userId
        self.sessionId = sessionId
    }

    @objc required init?(coder aDecoder: NSCoder) {
        self.userId = (aDecoder.decodeObjectForKey("userId") as! NSNumber).longLongValue
        self.sessionId = aDecoder.decodeObjectForKey("sessionId") as! String
    }

    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(NSNumber(longLong: userId), forKey: "userId")
        aCoder.encodeObject(sessionId, forKey: "sessionId")
    }

    func isValid() -> Bool {
        return true
    }
}
