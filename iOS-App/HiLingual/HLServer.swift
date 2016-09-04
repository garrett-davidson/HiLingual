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
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            // topController should now be your topmost view controller
            return topController
        }

        return nil
    }

    static func sendRequest(_ request: URLRequest) -> [NSDictionary]? {
        var resp: URLResponse?

        //TODO: Make this properly asynchronous
        if let returnedData = try? NSURLConnection.sendSynchronousRequest(request, returning: &resp) {
            if let returnString = NSString(data: returnedData, encoding: String.Encoding.utf8.rawValue) {
                print(returnString)

                if let response = resp as? HTTPURLResponse {
                    switch response.statusCode {
                    case 200..<300:
                        if let ret = (try? JSONSerialization.jsonObject(with: returnedData, options: JSONSerialization.ReadingOptions(rawValue: 0))) as? NSDictionary {
                            return [ret]
                        } else if let ret = (try? JSONSerialization.jsonObject(with: returnedData, options: JSONSerialization.ReadingOptions(rawValue: 0))) as? [NSDictionary] {
                            return ret
                        } else if returnString != "" {
                            return [["result": returnString]]
                        } else {
                            //We succeeded but the result was empty
                            return [NSDictionary()]
                        }

                    case 300..<400:
                        print("Result redirected")
                        print("Was that supposed to happen...? 🤔")

                    case 401:
                        print("You aren't authorized to do that bitch🖕")

                    case 400..<500:
                        print("You probably fucked up the request 😓")

                    case 503:
                        print("😭😭😭 *********Server Down********* 😭😭😭")
                        let alertController = UIAlertController(title: "Cannot connect".localized, message: "Our server seems to be down. Please try again later", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Ok".localized, style: .cancel, handler: nil))
                        if let topVC = getTopViewController() {
                            topVC.present(alertController, animated: true, completion: nil)
                        }

                        //We don't need to run the diagnostic stuff below if we get here
                        return nil

                    case 500..<600:
                        print("Server fucked up 😏")

                    default:
                        print("Wtf just happened???  ?¿💩")
                    }
                } else {
                    print("Couldn't parse return dictionary")
                }
            } else {
                print("Response not a string")
            }
        } else {
            print("Served returned no data")
        }

        if resp != nil {
            print("Server Response: ", resp!)
        }

        return nil
    }

    static func sendRequestToEndpoint(_ endpoint: String, method: String, contentType: String="application/json", withDictionary dict: Dictionary<String, AnyObject>?=nil, withData data: Data?=nil, authenticated: Bool=true) -> [NSDictionary]? {

        let request = NSMutableURLRequest(url: URL(string: apiBase + endpoint)!)

        request.httpMethod = method

        if dict != nil {
            request.httpBody = try? JSONSerialization.data(withJSONObject: NSDictionary(dictionary: dict!), options: JSONSerialization.WritingOptions(rawValue: 0))
        } else if data != nil {
            request.httpBody = data!
        }

        var headerFields = ["Content-Type": contentType]
        if authenticated {
            if let session = HLUser.getCurrentUser().getSession() {
                headerFields["Authorization"] = "HLAT " + session.sessionId
            } else {
                print("Could not authenticate")
                return nil
            }
        }

        if request.httpBody != nil {
            headerFields["Content-Length"] = "\(request.httpBody!.count)"
        }

        request.allHTTPHeaderFields = headerFields

        return sendRequest(request as URLRequest)
    }

    static func sendGETRequestToEndpoint(_ endpoint: String, withParameterString parameters: String?=nil, authentication: HLUserSession?=HLUser.getCurrentUser().getSession()) -> [NSDictionary]? {
        var urlString = apiBase + endpoint

        if parameters != nil {
            urlString += parameters!
        }

        let request = NSMutableURLRequest(url: URL(string: urlString)!)

        var headerFields = ["Content-Type": "application/json"]

        if authentication != nil {
            headerFields["Authorization"] = "HLAT " + authentication!.sessionId
        }

        request.allHTTPHeaderFields = headerFields

        request.httpMethod = "GET"

        return sendRequest(request as URLRequest)
    }

    static func getUniqueDisplayName(_ name: String) -> String {
        let ret = sendGETRequestToEndpoint("user/names", withParameterString: "?name=\(name)")
        return (ret![0]["result"] as? String)!
    }

    static func getTranslationForMessage(_ message: HLMessage, edit: Bool=false, fromLanguage: String?, toLangauge: String="en-US") -> String? {

        if let ret = sendGETRequestToEndpoint("chat/\(message.receiverID)/message/\(message.messageUUID!)/translate", withParameterString: edit ? "?edit=true" : "") {

            if let encodedTranslation = ret[0]["translatedContent"] as? String {
                return encodedTranslation.fromBase64()
            } else {
                print("Did not receive translation")
            }
        }

        return nil
    }

    static func saveEdit(_ editedText: String, forMessage message: HLMessage) -> Bool {
        if let encodedEdit = editedText.toBase64() {
            if sendRequestToEndpoint("chat/\(message.senderID)/message/\(message.messageUUID!)", method: "PATCH", withDictionary: ["editData" : encodedEdit as AnyObject]) != nil {
                return true
            }
        }

        return false
    }

    static func retrieveMessageFromUser(_ user: Int64, before: Int64, max: Int64=50) -> [HLMessage]? {

        if let messagesDicts = sendGETRequestToEndpoint("chat/\(user)/message", withParameterString: "?before=\(before)&limit=\(max)") {

            return messagesDicts.map({ (messageDict) -> HLMessage in
                return HLMessage.fromDict(messageDict)!
            })
        }

        return nil
    }

    static func retrieveMessageFromUser(_ user: Int64, after: Int64, max: Int64=50) -> [HLMessage]? {
        if let messagesDicts = sendGETRequestToEndpoint("chat/\(user)/message", withParameterString: "?after=\(after)&limit=\(max)") {

            return messagesDicts.map({ (messageDict) -> HLMessage in
                return HLMessage.fromDict(messageDict)!
            })
        }

        return nil
    }

    static func retrieveEditedMessages(_ user: Int64, before: Int64, max: Int64=50) -> [NSDictionary]? {
        return sendGETRequestToEndpoint("chat/\(user)/message", withParameterString: "?before=\(before+1)&limit=\(max)&e=true")
    }

    static func sendMessageWithText(_ text: String, receiverID: Int64) -> HLMessage? {

        if let encodedString = text.toBase64() {
            if let messageDict = sendRequestToEndpoint("chat/\(receiverID)/message", method: "POST", withDictionary: ["content": encodedString as AnyObject]) {
                return HLMessage.fromDict(messageDict[0])
            } else {
                print("Couldn't send message")
            }
        } else {
            print("Couldn't base64 encode message text")
        }

        return nil
    }

    static func sendImageWithData(_ data: Data, receiverID: Int64) -> HLMessage? {
        if let messageDict = sendRequestToEndpoint("chat/\(receiverID)/message", method: "POST", withDictionary: ["image": data.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)) as AnyObject]) {
            return HLMessage.fromDict(messageDict[0])
        } //this needs to be asynchronous so bad pls

        return nil
    }

    static func sendVoiceMessageWithData(_ data: Data, receiverID: Int64) -> HLMessage? {

        if let messageDict = sendRequestToEndpoint("chat/\(receiverID)/message", method: "POST", withDictionary: ["audio": data.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)) as AnyObject]) {
            return HLMessage.fromDict(messageDict[0])
        }

        return nil
    }

    static func blockUser(_ userID: Int64) {
        sendRequestToEndpoint("user/\(userID)/block", method: "POST")
    }

    static func unblockUser(_ userID: Int64) {
        sendRequestToEndpoint("user/\(userID)/block", method: "DELETE")
    }

    static func reportUser(_ userID: Int64, reason: String!) {
        sendRequestToEndpoint("user/\(userID)/report", method: "POST", withDictionary: ["reason": reason as AnyObject])
    }

    static var loadedUsers = [Int64: HLUser]()

    static func getUserById(_ id: Int64, session: HLUserSession=HLUser.getCurrentUser().getSession()!) -> HLUser? {

        let userURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(id).user")

//        if let cachedUser = NSKeyedUnarchiver.unarchiveObjectWithFile(userURL.path!) as? HLUser {
//            print("Pulled user from cache")
//            return cachedUser
//        }
        if let user = loadedUsers[id] {
            return user
        }

        if let userDict = sendGETRequestToEndpoint("user/\(id)", withParameterString: nil, authentication: session) {
            let returnedUser = HLUser.fromDict(userDict[0])

            loadedUsers[id] = returnedUser

            if NSKeyedArchiver.archiveRootObject(returnedUser, toFile: userURL.path) {
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

    static func getSearchResultsForQuery(_ query: String) -> [HLUser]? {

        if let resultsDicts = sendGETRequestToEndpoint("user/search", withParameterString: "?query=" + query) {
            return resultsDicts.map({ (userDict) -> HLUser in
                HLUser.fromDict(userDict)
            })
        }

        return nil
    }

    static func sendChatRequestToUser(_ userId: Int64) -> Bool {

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

    static func deleteConversationWithUser(_ userId: Int64) -> Bool {
        return sendRequestToEndpoint("chat/\(userId)", method: "DELETE") != nil
    }

    static func deleteRequestFromUser(_ userId: Int64) -> Bool {
        return sendRequestToEndpoint("chat/\(userId)/request", method: "DELETE") != nil
    }

    static func acceptRequestFromUser(_ userId: Int64) -> Bool {
        return sendRequestToEndpoint("chat/\(userId)/accept", method: "POST") != nil
    }

    enum LoginAuthority: String {
        case Facebook = "FACEBOOK"
        case Google = "GOOGLE"
    }

    static func authenticate(authority: LoginAuthority, authorityAccountId: String, authorityToken: String, deviceToken: String?) -> Bool {

        var bodyDict = ["authority": authority.rawValue, "authorityAccountId": authorityAccountId, "authorityToken": authorityToken]

        if deviceToken != nil {
            bodyDict["deviceToken"] = deviceToken!
        }

        if let authDictArray = sendRequestToEndpoint("auth", method: "POST", withDictionary: bodyDict as Dictionary<String, AnyObject>?, authenticated: false) {
            if authDictArray.count == 1 {
                if let userDict = authDictArray[0]["user"] as? NSDictionary {
                    let authedUser = HLUser.fromDict(userDict)

                    if let sessionString = authDictArray[0]["sessionToken"] as? String {
                        let session = HLUserSession(userId: authedUser.userId, sessionId: sessionString)
                        authedUser.save(session, toServer: false)
                        return true
                    }
                }
            }
        }

        return false
    }
    static func sendImageToProfile(_ image: UIImage, onUser userId: UInt64) -> URL? {

        let boundary = "unique-consistent-string"

        let body = NSMutableData()
        if let imageData = UIImagePNGRepresentation(image) {
            body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Disposition: form-data; name=file\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Type: image/png\r\n\r\n".data(using: String.Encoding.utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: String.Encoding.utf8)!)
        } else {
            return nil
        }

        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
         print("before")

        if let resultsDicts =  sendRequestToEndpoint("asset/avatar/\(userId)", method: "POST", contentType:"multipart/form-data; boundary=" + boundary, withData: body as Data) {
            if let imageURLString = resultsDicts[0]["image"] as? String {
                return URL(string: imageURLString)
            }
        }
        print("here")
        return nil

    }

    static func sendImage(_ image: UIImage, toUser userId: UInt64) -> Bool {

        let boundary = "unique-consistent-string"

        let body = NSMutableData()
        if let imageData = UIImagePNGRepresentation(image) {
            body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Disposition: form-data; name=file\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Type: image/png\r\n\r\n".data(using: String.Encoding.utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: String.Encoding.utf8)!)
        } else {
            return false
        }

        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)

        return sendRequestToEndpoint("chat/\(userId)/message/image", method: "POST", contentType:"multipart/form-data; boundary=" + boundary, withData: body as Data) != nil
    }

    static func loadImageWithURL(_ url: URL) -> UIImage? {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let picURL = documentsURL.appendingPathComponent("\(url.lastPathComponent).png")

        let image: UIImage?
        if let data = try? Data(contentsOf: picURL) {
            image = UIImage(data: data)?.scaledToSize(180, height: 180)
        } else {

            ChatViewController.loadFileSync(url, writeTo: picURL, completion: {(picURL: String, error: NSError?) in
                print("downloaded to: \(picURL)")
            })

            if let data = try? Data(contentsOf: picURL) {
                image = UIImage(data: data)?.scaledToSize(180, height: 180)
            } else {
                print("Failed to load image")
                image = nil
            }
        }

        return image
    }

    static func loadImageWithURL(_ url: URL, forView: ImageLoadingView, withCallback callback: @escaping (UIImage) -> ()) {
        var view = forView
        view.spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        view.loadingImageView.image = nil
        view.loadingImageView.backgroundColor = UIColor.gray
        view.spinner!.center = CGPoint(x: view.loadingImageView.bounds.width/2, y: view.loadingImageView.bounds.height/2)
        view.loadingImageView.addSubview(view.spinner!)
        view.spinner!.startAnimating()
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            if let image = loadImageWithURL(url) {
                DispatchQueue.main.async(execute: {
                    view.spinner?.removeFromSuperview()
                    view.spinner?.stopAnimating()
                    view.spinner = nil
                    view.spinner = nil
                    view.loadingImageView.image = image
                    callback(image)
                })
            }
        })
    }

    static func loadImageWithURL(_ url: URL, forCell cell: ImageLoadingView, inTableView tableView: UITableView, atIndexPath indexPath: IndexPath, withCallback callback: @escaping (UIImage) -> ()) {
        //This weird cell assignment stuff has to be here because of the reuse of cells as the tableview scrolls
        //And the fact that cellForRowAtIndexPath will return nil if called recursively
        var loadingCell = cell
        loadingCell.spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        loadingCell.loadingImageView.image = nil
        loadingCell.loadingImageView.backgroundColor = UIColor.gray
        loadingCell.spinner!.center = CGPoint(x: loadingCell.loadingImageView.bounds.width/2, y: loadingCell.loadingImageView.bounds.height/2)
        loadingCell.loadingImageView.addSubview(loadingCell.spinner!)
        loadingCell.spinner!.startAnimating()
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            if let image = loadImageWithURL(url) {
                DispatchQueue.main.async(execute: {
                    if var cell = tableView.cellForRow(at: indexPath) as? ImageLoadingView {
                        cell.spinner?.stopAnimating()
                        cell.spinner?.removeFromSuperview()
                        cell.spinner = nil
                        cell.loadingImageView.image = image
                        callback(image)
                    }
                })
            }
        })
    }

    static func saveFlaschcardRing(_ flashcards: [HLFlashCard], withName name: String) {
        var ringDict: [String: [[String: String]]] = ["name": (name as AnyObject) as! Array<Dictionary<String, String>>]
        let flashcardJSONArray = flashcards.map { (flashcard) -> [String: String] in
            ["front": flashcard.frontText!.toBase64()!, "back": flashcard.backText!.toBase64()!]
        }
        ringDict["flashcards"] = flashcardJSONArray
        if let data = try? JSONSerialization.data(withJSONObject: [ringDict], options: JSONSerialization.WritingOptions(rawValue: 0)) {
            sendRequestToEndpoint("user/me/cards", method: "PUT", withData: data)
        }
    }

    static func retrieveFlashcards() -> [(String, [HLFlashCard])]? {

        if let ret = sendGETRequestToEndpoint("user/me/cards") {
            var rings = [(String, [HLFlashCard])]()

            for ringDict in ret {
                if let name = ringDict["name"] as? String {
                    var cards = [HLFlashCard]()
                    if let cardArray = ringDict["flashcards"] as? [NSDictionary] {
                        for cardDict in cardArray {
                            if let frontText = (cardDict["front"] as? String)?.fromBase64() {
                                if let backText = (cardDict["back"] as? String)?.fromBase64() {
                                    cards.append(HLFlashCard(frontText: frontText, backText: backText))
                                }
                            }
                        }
                    }

                    rings.append((name, cards))
                }
            }

            return rings
        }

        return nil
    }
}

protocol ImageLoadingView {
    var spinner: UIActivityIndicatorView? {get set}
    weak var loadingImageView: UIImageView! {get}
}
