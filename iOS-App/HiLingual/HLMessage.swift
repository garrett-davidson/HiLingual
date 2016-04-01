//
//  HLMessage.swift
//  HiLingual
//
//  Created by Garrett Davidson on 2/13/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation

class HLMessage {
    let messageUUID: String?
    let timestamp: NSDate
    let text: String
    var editedText: String?
    //TODO: Add hide flags

    let senderID: Int64
    let receiverID: Int64

    init(text: String, senderID: Int64, receiverID: Int64) {
        self.messageUUID = nil
        self.timestamp = NSDate()
        self.text = text
        self.editedText = nil
        self.senderID = senderID
        self.receiverID = receiverID
    }
}