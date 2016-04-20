//
//  HLMessage.swift
//  HiLingual
//
//  Created by Garrett Davidson on 2/13/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation

extension UIImage {
    func scaledToSize(width: CGFloat, height: CGFloat) -> UIImage {
        let newSize = CGSize(width: width, height: height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let imageResized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return imageResized
    }
}

class HLMessage: NSObject, NSCoding {
    let messageUUID: Int64?
    let sentTimestamp: NSDate
    var editedTimestamp: NSDate?
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

    let audioURL: NSURL?
    
    let pictureURL: NSURL?

    var translatedText: String?
    var translatedEdit: String?

    var showTranslation: Bool

    private var cachedImage: UIImage?

    var image: UIImage? {
        return cachedImage
    }

    required init?(coder aDecoder: NSCoder) {
        messageUUID = aDecoder.decodeInt64ForKey("uuid")
        sentTimestamp = aDecoder.decodeObjectForKey("sentTimestamp") as! NSDate

        editedTimestamp = aDecoder.decodeObjectForKey("editedTimestamp") as? NSDate

        text = aDecoder.decodeObjectForKey("text") as! String

        editedText = aDecoder.decodeObjectForKey("editedText") as? String
        attributedEditedText = aDecoder.decodeObjectForKey("attributedEditedText") as? NSAttributedString

        senderID = aDecoder.decodeInt64ForKey("senderID")
        receiverID = aDecoder.decodeInt64ForKey("receiverID")

        translatedText = aDecoder.decodeObjectForKey("translatedText") as? String
        translatedEdit = aDecoder.decodeObjectForKey("translatedEdit") as? String

        showTranslation = aDecoder.decodeBoolForKey("showTranslation")

        if let audio = aDecoder.decodeObjectForKey("audioURL") as? NSURL {
            audioURL = audio
        }
        else {
            audioURL = nil
        }
        if let picture = aDecoder.decodeObjectForKey("pictureURL") as? NSURL {
            pictureURL = picture
        }
        else {
            pictureURL = nil
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
        aCoder.encodeObject(translatedEdit, forKey: "translatedEdit")
        aCoder.encodeBool(showTranslation, forKey: "showTranslation")
        aCoder.encodeObject(attributedEditedText, forKey: "attributedEditedText")
        aCoder.encodeObject(pictureURL, forKey: "pictureURL")
    }

    func loadImageWithCallback(callback: (UIImage)-> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let picURL = documentsURL.URLByAppendingPathComponent("\(self.messageUUID!).png")

            if let data = NSData(contentsOfURL: picURL) {
                self.cachedImage = UIImage(data: data)?.scaledToSize(180, height: 180)
                callback(self.cachedImage!)
                return

                //assign your image here
            } else {

                ChatViewController.loadFileSync(self.pictureURL!, writeTo: picURL, completion:{(picURL:String, error:NSError!) in
                    print("downloaded to: \(picURL)")
                })

                if let data = NSData(contentsOfURL: picURL) {
                    self.cachedImage = UIImage(data: data)?.scaledToSize(180, height: 180)

                    callback(self.cachedImage!)
                    return
                } else {
                    print("Failed to load image")
                }
            }
        })
    }

    func saveMessageEdit() {

        if HLServer.saveEdit(editedText!, forMessage: self) {
            print("Saved edit")
        }

        else {
            print("Failed to save edit to server")
        }
    }

    init(UUID: Int64, sentTimestamp: NSDate, editedTimestamp: NSDate?, text: String, editedText:String?, senderID: Int64, receiverID: Int64, translatedText: String?, showTranslation: Bool, audioURLString: String?=nil, imageURLString: String?=nil) {
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

        if audioURLString != nil && audioURLString! != "" {
            self.audioURL = NSURL(string: audioURLString!)
        }
        else {
            self.audioURL = nil
        }
        
        if imageURLString != nil && imageURLString != "" {
            self.pictureURL = NSURL(string: imageURLString!)
        }
        else {
            self.pictureURL = nil
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
        self.pictureURL = nil;
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

                        let editText: String?

                        if let encodedEditText = messageDict["editData"] as? String {
                            editText = encodedEditText.fromBase64()
                        }
                        else {
                            editText = nil
                        }

                        if let encodedText = messageDict["content"] as? String {

                            if let text = encodedText.fromBase64() {

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