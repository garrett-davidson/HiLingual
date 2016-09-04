//
//  HLMessage.swift
//  HiLingual
//
//  Created by Garrett Davidson on 2/13/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation

extension UIImage {
    func scaledToSize(_ width: CGFloat, height: CGFloat) -> UIImage {
        let newSize = CGSize(width: width, height: height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let imageResized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return imageResized!
    }
}

class HLMessage: NSObject, NSCoding {
    let messageUUID: Int64?
    let sentTimestamp: Date
    var editedTimestamp: Date?
    let text: String
    var editedText: String? {
        didSet {
            if editedText != oldValue {
                self.attributedEditedText = nil
            }
        }
    }
    var attributedEditedText: NSAttributedString?
    //TODO: Add hide flags

    let senderID: Int64
    let receiverID: Int64

    let audioURL: URL?

    let pictureURL: URL?

    var translatedText: String?
    var translatedEdit: String?

    var showTranslation: Bool

    var image: UIImage?

    required init?(coder aDecoder: NSCoder) {
        messageUUID = aDecoder.decodeInt64(forKey: "uuid")
        sentTimestamp = aDecoder.decodeObject(forKey: "sentTimestamp") as! Date

        editedTimestamp = aDecoder.decodeObject(forKey: "editedTimestamp") as? Date

        text = aDecoder.decodeObject(forKey: "text") as! String

        editedText = aDecoder.decodeObject(forKey: "editedText") as? String
        attributedEditedText = aDecoder.decodeObject(forKey: "attributedEditedText") as? NSAttributedString

        senderID = aDecoder.decodeInt64(forKey: "senderID")
        receiverID = aDecoder.decodeInt64(forKey: "receiverID")

        translatedText = aDecoder.decodeObject(forKey: "translatedText") as? String
        translatedEdit = aDecoder.decodeObject(forKey: "translatedEdit") as? String

        showTranslation = false

        if let audio = aDecoder.decodeObject(forKey: "audioURL") as? URL {
            audioURL = audio
        } else {
            audioURL = nil
        }
        if let picture = aDecoder.decodeObject(forKey: "pictureURL") as? URL {
            pictureURL = picture
        } else {
            pictureURL = nil
        }
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(messageUUID!, forKey: "uuid")
        aCoder.encode(sentTimestamp, forKey: "sentTimestamp")
        aCoder.encode(editedTimestamp, forKey: "editedTimestamp")
        aCoder.encode(text, forKey: "text")
        aCoder.encode(editedText, forKey: "editedText")
        aCoder.encode(senderID, forKey: "senderID")
        aCoder.encode(receiverID, forKey: "receiverID")
        aCoder.encode(audioURL, forKey: "audioURL")
        aCoder.encode(translatedText, forKey: "translatedText")
        aCoder.encode(translatedEdit, forKey: "translatedEdit")
        aCoder.encode(attributedEditedText, forKey: "attributedEditedText")
        aCoder.encode(pictureURL, forKey: "pictureURL")
    }

    func saveMessageEdit() {

        if HLServer.saveEdit(editedText!, forMessage: self) {
            print("Saved edit")
        } else {
            print("Failed to save edit to server")
        }
    }

    init(UUID: Int64, sentTimestamp: Date, editedTimestamp: Date?, text: String, editedText: String?, senderID: Int64, receiverID: Int64, translatedText: String?, showTranslation: Bool, audioURLString: String?=nil, imageURLString: String?=nil) {
        self.messageUUID = UUID
        self.sentTimestamp = sentTimestamp

        if editedTimestamp != Date(timeIntervalSince1970: 0) {
            self.editedTimestamp = editedTimestamp
        } else {
            self.editedTimestamp = nil
        }

        self.text = text
        self.editedText = editedText
        self.senderID = senderID
        self.receiverID = receiverID
        self.translatedText = translatedText
        self.showTranslation = showTranslation

        if audioURLString != nil && audioURLString! != "" {
            self.audioURL = URL(string: audioURLString!)
        } else {
            self.audioURL = nil
        }

        if imageURLString != nil && imageURLString != "" {
            self.pictureURL = URL(string: imageURLString!)
        } else {
            self.pictureURL = nil
        }
    }

    init(text: String, senderID: Int64, receiverID: Int64) {
        self.messageUUID = nil
        self.sentTimestamp = Date()
        self.text = text
        self.editedText = nil
        self.senderID = senderID
        self.receiverID = receiverID
        self.translatedText = nil
        self.showTranslation = false
        self.audioURL = nil
        self.pictureURL = nil
    }

    static func fromJSONArray(_ messageData: Data) -> [HLMessage] {
        var messageArray = [HLMessage]()
        if let obj = try? JSONSerialization.jsonObject(with: messageData, options: JSONSerialization.ReadingOptions(rawValue: 0)) {
            if let array = obj as? [NSDictionary] {
                for messageDict in array {
                    messageArray.append(fromDict(messageDict)!)
                }
            }
        }

        return messageArray
    }

    static func fromDict(_ messageDict: NSDictionary) -> HLMessage? {
        if let uuid = (messageDict["id"] as? NSNumber)?.int64Value {
            if let sentTime = (messageDict["sentTimestamp"] as? NSNumber)?.doubleValue {
                let sentTimestamp = Date(timeIntervalSince1970: sentTime / 1000)

                if let senderId = (messageDict["sender"] as? NSNumber)?.int64Value {
                    if let editTime = (messageDict["editTimestamp"] as? NSNumber)?.doubleValue {
                        let editTimestamp: Date?
                        if editTime != 0 {
                            editTimestamp = Date(timeIntervalSince1970: editTime / 1000)
                        } else {
                            editTimestamp = nil
                        }

                        let editText: String?

                        if let encodedEditText = messageDict["editData"] as? String {
                            editText = encodedEditText.fromBase64()
                        } else {
                            editText = nil
                        }

                        if let encodedText = messageDict["content"] as? String {

                            if let text = encodedText.fromBase64() {

                                let audioURLString: String?
                                if let audio = messageDict["audio"] as? String {
                                    if audio == "" {
                                        audioURLString = nil
                                    } else {
                                        audioURLString = audio
                                    }
                                } else {
                                    audioURLString = nil
                                }

                                let imageURLString = messageDict["image"] as? String

                                return HLMessage(UUID: uuid, sentTimestamp: sentTimestamp, editedTimestamp: editTimestamp, text: text, editedText: editText, senderID: senderId, receiverID: HLUser.getCurrentUser().userId, translatedText: nil, showTranslation: false, audioURLString: audioURLString, imageURLString: imageURLString)
                            } else {
                                print("Message text not base64")
                            }
                        }
                    }
                }
            }
        }

        return nil
    }

    static func fromJSON(_ messageData: Data) -> HLMessage? {
        if let ret = (try? JSONSerialization.jsonObject(with: messageData, options: JSONSerialization.ReadingOptions(rawValue: 0))) as? NSDictionary {
            return fromDict(ret)
        } else {
            print("Couldn't parse return value")
        }

        return nil
    }

}
