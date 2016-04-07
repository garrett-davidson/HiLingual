//
//  HLMessage.swift
//  HiLingual
//
//  Created by Garrett Davidson on 2/13/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation

class HLMessage: NSObject, NSCoding {
    let messageUUID: Int64?
    let sentTimestamp: NSDate
    var editedTimestamp: NSDate?
    let text: String
    var editedText: String? {

//        get {
//            return editedText
//        }

        didSet {
            saveMessageEdit()
        }
    }
    //TODO: Add hide flags

    let senderID: Int64
    let receiverID: Int64

    let audioURL: NSURL?

    var translatedText: String?

    var showTranslation: Bool

    required init?(coder aDecoder: NSCoder) {
        messageUUID = aDecoder.decodeInt64ForKey("uuid")
        sentTimestamp = aDecoder.decodeObjectForKey("sentTimestamp") as! NSDate

        editedTimestamp = aDecoder.decodeObjectForKey("editedTimestamp") as? NSDate

        text = aDecoder.decodeObjectForKey("text") as! String

        editedText = aDecoder.decodeObjectForKey("editedText") as? String

        senderID = aDecoder.decodeInt64ForKey("senderID")
        receiverID = aDecoder.decodeInt64ForKey("receiverID")

        translatedText = aDecoder.decodeObjectForKey("translatedText") as? String
        showTranslation = aDecoder.decodeBoolForKey("showTranslation")

        if let audio = aDecoder.decodeObjectForKey("audioURL") as? NSURL {
            audioURL = audio
        }
        else {
            audioURL = nil
        }
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInt64(messageUUID!, forKey: "uuid")
        aCoder.encodeObject(sentTimestamp, forKey: "sentTimestamp")
        aCoder.encodeObject(editedTimestamp, forKey: "editedTimestamp")
        aCoder.encodeObject(text, forKey: "text")
        aCoder.encodeObject(editedText, forKey: "editedText")
        aCoder.encodeInt64(senderID, forKey: "senderID")
        aCoder.encodeInt64(receiverID, forKey: "receiverID")
        aCoder.encodeObject(audioURL, forKey: "audioURL")
        aCoder.encodeObject(translatedText, forKey: "translatedText")
        aCoder.encodeBool(showTranslation, forKey: "showTranslation")
    }

    func saveMessageEdit() {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://gethilingual.com/api/chat/\(senderID)/message/\(messageUUID!)")!)
        if let session = HLUser.getCurrentUser().getSession() {

            request.allHTTPHeaderFields = ["Content-Type": "application/json", "Authorization": "HLAT " + session.sessionId]
            request.HTTPMethod = "PATCH"

            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(NSDictionary(dictionary: ["editData" : editedText!]), options: NSJSONWritingOptions(rawValue: 0))

            if let returnedData = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: nil) {
                print(returnedData)
                if let returnString = NSString(data: returnedData, encoding: NSUTF8StringEncoding) {
                    print(returnString)
                    return
                }
            }
        }
        
        print("Failed to edit message")
    }

    init(UUID: Int64, sentTimestamp: NSDate, editedTimestamp: NSDate?, text: String, editedText:String?, senderID: Int64, receiverID: Int64, translatedText: String?, showTranslation: Bool, audioURLString: String?=nil) {
        self.messageUUID = UUID
        self.sentTimestamp = sentTimestamp

        if editedTimestamp != NSDate(timeIntervalSince1970: 0) {
            self.editedTimestamp = editedTimestamp
        }

        else {
            self.editedTimestamp = nil
        }


        self.text = text
        self.editedText = editedText
        self.senderID = senderID
        self.receiverID = receiverID
        self.translatedText = translatedText
        self.showTranslation = showTranslation

        if audioURLString != nil {
            self.audioURL = NSURL(string: audioURLString!)
        }
        else {
            self.audioURL = nil
        }
    }

    init(text: String, senderID: Int64, receiverID: Int64) {
        self.messageUUID = nil
        self.sentTimestamp = NSDate()
        self.text = text
        self.editedText = nil
        self.senderID = senderID
        self.receiverID = receiverID
        self.translatedText = nil
        self.showTranslation = false
        self.audioURL = nil
    }

    static func sendVoiceMessageWithData(data: NSData, receiverID: Int64) -> HLMessage? {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://gethilingual.com/api/chat/\(receiverID)/message")!)
        if let session = HLUser.getCurrentUser().getSession() {

            request.allHTTPHeaderFields = ["Content-Type": "application/json", "Authorization": "HLAT " + session.sessionId]
            request.HTTPMethod = "POST"

            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(NSDictionary(dictionary: ["audio": data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))]), options: NSJSONWritingOptions(rawValue: 0))

            if let returnedData = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: nil) {
                print(returnedData)
                if let returnString = NSString(data: returnedData, encoding: NSUTF8StringEncoding) {
                    print(returnString)
                    if let message = HLMessage.fromJSON(returnedData) {
                        return message
                    }
                }
            }
        }
        
        return nil
    }

    static func sendMessageWithText(text: String, receiverID: Int64) -> HLMessage? {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://gethilingual.com/api/chat/\(receiverID)/message")!)
        if let session = HLUser.getCurrentUser().getSession() {

            request.allHTTPHeaderFields = ["Content-Type": "application/json", "Authorization": "HLAT " + session.sessionId]
            request.HTTPMethod = "POST"

            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(NSDictionary(dictionary: ["content": text]), options: NSJSONWritingOptions(rawValue: 0))

            if let returnedData = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: nil) {
                print(returnedData)
                if let returnString = NSString(data: returnedData, encoding: NSUTF8StringEncoding) {
                    print(returnString)
                    if let message = HLMessage.fromJSON(returnedData) {
                        return message
                    }
                }
            }
        }
        
        return nil
    }

    static func fromJSONArray(messageData: NSData) -> [HLMessage] {
        var messageArray = [HLMessage]()

        if let obj = try? NSJSONSerialization.JSONObjectWithData(messageData, options: NSJSONReadingOptions(rawValue: 0)) {
            if let array = obj as? [NSDictionary] {
                for messageDict in array {
                    messageArray.append(fromDict(messageDict)!)
                }
            }
        }

        return messageArray
    }

    static func fromDict(messageDict: NSDictionary) -> HLMessage? {
        if let uuid = (messageDict["id"] as? NSNumber)?.longLongValue {
            if let sentTime = (messageDict["sentTimestamp"] as? NSNumber)?.doubleValue {
                let sentTimestamp = NSDate(timeIntervalSince1970: sentTime / 1000)

                if let senderId = (messageDict["sender"] as? NSNumber)?.longLongValue {
                    if let editTime = (messageDict["editTimestamp"] as? NSNumber)?.doubleValue {
                        let editTimestamp: NSDate?
                        if editTime != 0 {
                            editTimestamp = NSDate(timeIntervalSince1970: editTime / 1000)
                        }

                        else {
                            editTimestamp = nil
                        }

                        let editText = messageDict["editData"] as? String

                        if let text = messageDict["content"] as? String {

                            let audioURLString: String?
                            if let audio = messageDict["audio"] as? String {
                                if audio == "" {
                                    audioURLString = nil
                                }
                                else {
                                    audioURLString = audio
                                }
                            }
                            else {
                                audioURLString = nil
                            }

                            return HLMessage(UUID: uuid, sentTimestamp: sentTimestamp, editedTimestamp: editTimestamp, text: text, editedText: editText, senderID: senderId, receiverID: HLUser.getCurrentUser().userId, translatedText: nil, showTranslation: false, audioURLString: audioURLString)
                        }
                    }
                }
            }
        }

        return nil
    }

    static func fromJSON(messageData: NSData) -> HLMessage? {
        if let ret = (try? NSJSONSerialization.JSONObjectWithData(messageData, options: NSJSONReadingOptions(rawValue: 0))) as? NSDictionary {
            return fromDict(ret)
        }
        else {
            print("Couldn't parse return value")
        }

        return nil
    }
    
}