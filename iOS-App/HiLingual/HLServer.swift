//
//  HLServer.swift
//  HiLingual
//
//  Created by Garrett Davidson on 4/7/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation


class HLServer {

    static let apiBase = "https://gethilingual.com/api/"

    static func getTopViewController() -> UIViewController? {
        if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            // topController should now be your topmost view controller
            return topController
        }

        return nil
    }

    static func sendRequest(request: NSURLRequest) -> [NSDictionary]? {
        var resp: NSURLResponse?

        if let returnedData = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: &resp) {
            if let returnString = NSString(data: returnedData, encoding: NSUTF8StringEncoding) {
                print(returnString)

                if let response = resp as? NSHTTPURLResponse {
                    switch response.statusCode {
                    case 200..<300:
                        if let ret = (try? NSJSONSerialization.JSONObjectWithData(returnedData, options: NSJSONReadingOptions(rawValue: 0))) as? NSDictionary {
                            return [ret]
                        }

                        else if let ret = (try? NSJSONSerialization.JSONObjectWithData(returnedData, options: NSJSONReadingOptions(rawValue: 0))) as? [NSDictionary] {
                            return ret
                        }

                        else {
                            //We succeeded but the result was empty
                            return [NSDictionary()]
                        }

                    case 300..<400:
                        print("Result redirected")
                        print("Was that supposed to happen...? 🤔")

                    case 401:
                        print("You aren't authorized to do that 🖕")

                    case 400..<500:
                        print("You probably fucked up the request 😓")

                    case 503:
                        print("😭😭😭 *********Server Down********* 😭😭😭")
                        let alertController = UIAlertController(title: "Cannot connect".localized, message: "Our server seems to be down. Please try again later", preferredStyle: .Alert)
                        alertController.addAction(UIAlertAction(title: "Ok".localized, style: .Cancel, handler: nil))
                        if let topVC = getTopViewController() {
                            topVC.presentViewController(alertController, animated: true, completion: nil)
                        }
                        
                        //We don't need to run the diagnostic stuff below if we get here
                        return nil

                    case 500..<600:
                        print("Server fucked up 😏")

                    default:
                        print("Wtf just happened???  ?¿💩")
                    }
                }


                else {
                    print("Couldn't parse return dictionary")
                }
            }

            else {
                print("Response not a string")
            }
        }
        else {
            print("Served returned no data")
        }

        if resp != nil {
            print("Server Response: ", resp!)
        }

        return nil
    }

    static func sendRequestToEndpoint(endpoint: String, method: String, withDictionary dict: Dictionary<String, AnyObject>?=nil, authenticated: Bool=true) -> [NSDictionary]? {
        let request = NSMutableURLRequest(URL: NSURL(string: apiBase + endpoint)!)

        var headerFields = ["Content-Type": "application/json"]

        if authenticated {
            if let session = HLUser.getCurrentUser().getSession() {
                headerFields["Authorization"] = "HLAT " + session.sessionId
            }

            else {
                print("Could not authenticate")
                return nil
            }
        }

        request.allHTTPHeaderFields = headerFields

        request.HTTPMethod = method

        if dict != nil {
            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(NSDictionary(dictionary: dict!), options: NSJSONWritingOptions(rawValue: 0))
        }


        return sendRequest(request)
    }

    static func sendGETRequestToEndpoint(endpoint: String, withParameterString parameters: String?=nil, authentication: HLUserSession?=HLUser.getCurrentUser().getSession()) -> [NSDictionary]? {
        var urlString = apiBase + endpoint

        if parameters != nil {
            urlString += parameters!
        }

        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)

        var headerFields = ["Content-Type": "application/json"]

        if authentication != nil {
            headerFields["Authorization"] = "HLAT " + authentication!.sessionId
        }

        request.allHTTPHeaderFields = headerFields

        request.HTTPMethod = "GET"
        
        return sendRequest(request)
    }

    static func getTranslationForMessage(message: HLMessage, edit:Bool=false, fromLanguage: String?, toLangauge: String="en-US") -> String? {

        if let ret = sendGETRequestToEndpoint("chat/\(message.receiverID)/message/\(message.messageUUID!)/translate", withParameterString: edit ? "?edit=true" : "") {

            if let encodedTranslation = ret[0]["translatedContent"] as? String {
                return (NSString(data: NSData(base64EncodedString: encodedTranslation, options: NSDataBase64DecodingOptions(rawValue: 0))!, encoding: NSUTF8StringEncoding) as! String)
            }

            else {
                print("Did not receive translation")
            }
        }

        return nil
    }

    static func saveEdit(editedText: String, forMessage message: HLMessage) -> Bool {
        if let encodedEdit = editedText.dataUsingEncoding(NSUTF8StringEncoding)?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0)) {
            if sendRequestToEndpoint("chat/\(message.senderID)/message/\(message.messageUUID!)", method: "PATCH", withDictionary: ["editData" : encodedEdit]) != nil {
                return true
            }
        }

        return false
    }

    static func retrieveMessageFromUser(user:Int64, before: Int64, max: Int64=50) -> [HLMessage]? {

        if let messagesDicts = sendGETRequestToEndpoint("chat/\(user)/message", withParameterString: "?before=\(before)&limit=\(max)") {

            return messagesDicts.map({ (messageDict) -> HLMessage in
                return HLMessage.fromDict(messageDict)!
            })
        }

        return nil
    }

    static func retrieveMessageFromUser(user:Int64, after: Int64, max: Int64=50) -> [HLMessage]? {
        if let messagesDicts = sendGETRequestToEndpoint("chat/\(user)/message", withParameterString: "?after=\(after)&limit=\(max)") {

            return messagesDicts.map({ (messageDict) -> HLMessage in
                return HLMessage.fromDict(messageDict)!
            })
        }
        
        return nil
    }

    static func retrieveEditedMessages(user:Int64, before: Int64, max: Int64=50) -> [NSDictionary]? {
        return sendGETRequestToEndpoint("chat/\(user)/message", withParameterString: "?before=\(before+1)&limit=\(max)&e=true")
    }

    static func sendMessageWithText(text: String, receiverID: Int64) -> HLMessage? {

        if let encodedString = text.dataUsingEncoding(NSUTF8StringEncoding)?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0)) {
            if let messageDict = sendRequestToEndpoint("chat/\(receiverID)/message", method: "POST", withDictionary: ["content": encodedString]) {
                return HLMessage.fromDict(messageDict[0])
            }

            else {
                print("Couldn't send message")
            }
        }

        else {
            print("Couldn't base64 encode message text")
        }

        return nil
    }
    
    static func sendImageWithData(data: NSData, receiverID: Int64) -> HLMessage? {
        print("string length: ",data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0)).characters.count)
        if let messageDict = sendRequestToEndpoint("chat/\(receiverID)/message", method: "POST", withDictionary: ["image": data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))]) {
            return HLMessage.fromDict(messageDict[0])
        } //this needs to be asynchronous so bad pls
        
        return nil
    }


    static func sendVoiceMessageWithData(data: NSData, receiverID: Int64) -> HLMessage? {

        if let messageDict = sendRequestToEndpoint("chat/\(receiverID)/message", method: "POST", withDictionary: ["audio": data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))]) {
            return HLMessage.fromDict(messageDict[0])
        }
        
        return nil
    }

    static func getUserById(id: Int64, session: HLUserSession=HLUser.getCurrentUser().getSession()!) -> HLUser? {

        let userURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent("\(id).user")

        if let cachedUser = NSKeyedUnarchiver.unarchiveObjectWithFile(userURL.path!) as? HLUser {
            print("Pulled user from cache")
            return cachedUser
        }

        if let userDict = sendGETRequestToEndpoint("user/\(id)", withParameterString: nil, authentication: session) {
            let returnedUser = HLUser.fromDict(userDict[0])


            if NSKeyedArchiver.archiveRootObject(returnedUser, toFile: userURL.path!) {
                print("Wrote user to cache")
            } else {
                print("Failed to write user to cache")
            }
            return returnedUser
        }

        return nil
    }

    static func registerOrLoginWithFacebook() -> Bool {
        //TODO: Implement this, once the server is updated
        return false
    }

    static func registerOrLoginWithGoogle() -> Bool {
        //TODO: Implement this, once the server is updated
        return false
    }

    static func getSearchResultsForQuery(query: String) -> [HLUser]? {

        if let resultsDicts = sendGETRequestToEndpoint("user/search", withParameterString: "?query=" + query) {
            return resultsDicts.map({ (userDict) -> HLUser in
                HLUser.fromDict(userDict)
            })
        }

        return nil
    }

    static func sendChatRequestToUser(userId: Int64) -> Bool {

        return sendRequestToEndpoint("chat/\(userId)/", method: "POST") != nil
    }

    static func getMyMatches() -> [HLUser]? {

        if let matchDicts = sendGETRequestToEndpoint("user/match") {
            return matchDicts.map({ (match) -> HLUser in
                HLUser.fromDict(match)
            })
        }

        return nil
    }

    static func getChats() -> NSDictionary? {

        if let ret = sendGETRequestToEndpoint("chat/me") {
            return ret[0]
        }

        return nil
    }

    static func deleteConversationWithUser(userId: Int64) -> Bool {
        return sendRequestToEndpoint("chat/\(userId)", method: "DELETE") != nil
    }

    static func deleteRequestFromUser(userId: Int64) -> Bool {
        return sendRequestToEndpoint("chat/\(userId)/request", method: "DELETE") != nil
    }

    static func acceptRequestFromUser(userId: Int64) -> Bool {
        return sendRequestToEndpoint("chat/\(userId)/accept", method: "POST") != nil
    }
}