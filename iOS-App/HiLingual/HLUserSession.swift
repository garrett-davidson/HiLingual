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
        self.userId = (aDecoder.decodeObject(forKey: "userId") as! NSNumber).int64Value
        self.sessionId = aDecoder.decodeObject(forKey: "sessionId") as! String
    }

    @objc func encode(with aCoder: NSCoder) {
        aCoder.encode(NSNumber(value: userId), forKey: "userId")
        aCoder.encode(sessionId, forKey: "sessionId")
    }

    func isValid() -> Bool {
        return true
    }
}
