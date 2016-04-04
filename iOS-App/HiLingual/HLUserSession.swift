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
    let authority: LoginAuthority
    let authorityAccountId: String
    let authorityToken: String
    let userId: Int64

    init(userId: Int64, sessionId: String, authority: LoginAuthority, authorityAccountId: String, authorityToken: String) {
        self.userId = userId
        self.sessionId = sessionId
        self.authority = authority
        self.authorityAccountId = authorityAccountId
        self.authorityToken = authorityToken
    }

    @objc required init?(coder aDecoder: NSCoder) {
        self.userId = aDecoder.decodeObjectForKey("userId") as! Int64
        self.sessionId = aDecoder.decodeObjectForKey("sessionId") as! String
        self.authority = LoginAuthority(rawValue:aDecoder.decodeObjectForKey("authority") as! String)!
        self.authorityAccountId = aDecoder.decodeObjectForKey("authorityAccountId") as! String
        self.authorityToken = aDecoder.decodeObjectForKey("authorityToken") as! String
    }

    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(NSNumber(longLong: userId), forKey: "userId")
        aCoder.encodeObject(sessionId, forKey: "sessionId")
        aCoder.encodeObject(authority.rawValue, forKey: "authority")
        aCoder.encodeObject(authorityAccountId, forKey: "authorityAccountId")
        aCoder.encodeObject(authorityToken, forKey: "authorityToken")
    }

    func isValid() -> Bool {
        return true
    }
}