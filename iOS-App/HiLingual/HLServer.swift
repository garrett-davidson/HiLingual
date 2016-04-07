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

                    case 400..<500:
                        print("You probably fucked up the request 😓")

                    case 503:
                        print("*********Server Down********* 😭")

                    case 500..<600:
                        print("Server fucked up 😏")

                    default:
                        print("Wtf just happened??? 💩")
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

    static func sendRequestToEndpoint(endpoint: String, method: String, withDictionary dict: Dictionary<String, AnyObject>?, authenticated: Bool=true) -> [NSDictionary]? {
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

    static func sendGETRequestToEndpoint(endpoint: String, withParameterString parameters: String?=nil, authenticated: Bool=true) -> [NSDictionary]? {
        var urlString = apiBase + endpoint

        if parameters != nil {
            urlString += parameters!
        }

        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)

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

        request.HTTPMethod = "GET"
        
        return sendRequest(request)
    }

    static func getTranslationForMessage(message: HLMessage, fromLanguage: String?, toLangauge: String="en-US") -> String? {

        if let ret = sendGETRequestToEndpoint("chat/\(message.receiverID)/message/\(message.messageUUID!)/translate") {
            return ret[0]["translatedContent"] as? String
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

    static func retrieveMessageFromUser(user:Int64, sinceLastMessageId lastMessageId: Int64=0, max: Int64=50) -> [HLMessage]? {

        if let messagesDicts = sendGETRequestToEndpoint("chat/\(user)/message", withParameterString: "?before=\(lastMessageId)&limit=\(max)") {

            return messagesDicts.map({ (messageDict) -> HLMessage in
                return HLMessage.fromDict(messageDict)!
            })
        }

        return nil
    }
}