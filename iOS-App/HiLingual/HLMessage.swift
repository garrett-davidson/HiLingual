//
//  HLMessage.swift
//  HiLingual
//
//  Created by Garrett Davidson on 2/13/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation

class HLMessage {
    let messageUUID: Int64?
    let sentTimestamp: NSDate
    var editedTimestamp: NSDate?
    let text: String
    var editedText: String?
    //TODO: Add hide flags

    let senderID: Int64
    let receiverID: Int64

    init(UUID: Int64, sentTimestamp: NSDate, editedTimestamp: NSDate?, text: String, editedText:String?, senderID: Int64, receiverID: Int64) {
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
    }

    init(text: String, senderID: Int64, receiverID: Int64) {
        self.messageUUID = nil
        self.sentTimestamp = NSDate()
        self.text = text
        self.editedText = nil
        self.senderID = senderID
        self.receiverID = receiverID
    }

    static func sendMessageWithText(text: String, receiverID: Int64) -> HLMessage? {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://gethilingual.com/api/chat/\(receiverID)/message")!)
        if let session = HLUser.getCurrentUser().getSession() {
        

            request.allHTTPHeaderFields = ["Content-Type": "application/json", "Authorization": "HLAT " + session.sessionId]
            request.HTTPMethod = "POST"
            if(isVoice){
                request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(NSDictionary(dictionary: ["audio": text]), options: NSJSONWritingOptions(rawValue: 0))
            }else{
                request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(NSDictionary(dictionary: ["content": text]), options: NSJSONWritingOptions(rawValue: 0))
            }
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

    static func fromJSON(messageData: NSData) -> HLMessage? {
        if let ret = (try? NSJSONSerialization.JSONObjectWithData(messageData, options: NSJSONReadingOptions(rawValue: 0))) as? NSDictionary {
            //{"id":-1,"sentTimestamp":1459872650307,"editTimestamp":0,"sender":15,"receiver":13,"content":"Asdf","audio":null,"editData":null}

            if let uuid = (ret["id"] as? NSNumber)?.longLongValue {
                if let sentTime = (ret["sentTimestamp"] as? NSNumber)?.doubleValue {
                    let sentTimestamp = NSDate(timeIntervalSince1970: sentTime / 1000)

                    if let text = ret["content"] as? String {
                        if let senderId = (ret["sender"] as? NSNumber)?.longLongValue {
                            if let editTime = (ret["editTimestamp"] as? NSNumber)?.doubleValue {
                                let editTimestamp: NSDate?
                                if editTime != 0 {
                                    editTimestamp = NSDate(timeIntervalSince1970: editTime / 1000)
                                }

                                else {
                                    editTimestamp = nil
                                }

                                let editText = ret["editData"] as? String

                                return HLMessage(UUID: uuid, sentTimestamp: sentTimestamp, editedTimestamp: editTimestamp, text: text, editedText: editText, senderID: senderId, receiverID: HLUser.getCurrentUser().userId)
                            }
                        }
                    }
                }
            }

            else {
                print("Couldn't create message from JSON")
                print(ret)
            }
        }
        else {
            print("Couldn't parse return value")
        }

        return nil
    }
    
}