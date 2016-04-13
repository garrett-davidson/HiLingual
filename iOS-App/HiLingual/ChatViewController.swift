//
//  ChatViewController.swift
//  HiLingual
//
//  Created by Garrett Davidson on 2/14/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import AVFoundation

class NonPastableTextField: UITextField {
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        return false
    }
}

//Displays both the sent and received messages in a single chat

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate{
    var user: HLUser!
    var currentUser = HLUser.getCurrentUser()
    var messageTest = [String]()
    var messages = [HLMessage]()
    var scroll = 0

    var audioPlayer: AVAudioPlayer!
    var recordingSession: AVAudioSession!

    //This is not hard coding
    //This variable is set by another view when this view comes on screen
    var recipientId: Int64 = -1

    @IBOutlet weak var detailsProfile: UIBarButtonItem!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var hiddenTextField: UITextField!

    @IBOutlet weak var testView: AccessoryView!
    var selectedCellIndex: Int?
    
    
    var curPlayingMessage: UIButton?
    var isPlayingMessage = false
    
    var editingCellIndex: Int?
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ChatViewController.loadMoreMessages(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)

        self.title = user.name
        print(user.name)
        print(user.userId)
        loadMessages()
        self.chatTableView.estimatedRowHeight = 40
        self.chatTableView.rowHeight = UITableViewAutomaticDimension
        self.tabBarController?.tabBar.hidden = true
        enableKeyboardHideOnTap()

        setupEditMenuButtons()

        testView.chatViewController = self

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.handleNewMessageNotification(_:)), name: AppDelegate.NotificationTypes.newMessage.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.handleEditedMessageNotification(_:)), name: AppDelegate.NotificationTypes.editedMessage.rawValue, object: nil)
        
        //Code for bringing up audio scren
       // let controller = AudioRecorderViewController()
       // controller.audioRecorderDelegate = self
        //presentViewController(controller, animated: true, completion: nil)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        chatTableView.scrollToBottom(animated: true)
    }

    override func viewWillDisappear(animated: Bool) {
        let chatURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent("\(recipientId).chat")
        let count = messages.count

        //Caches up to 50 messages on disk
        let last50 = Array(messages[(count >= 50 ? count-50 : 0)..<count])
        if NSKeyedArchiver.archiveRootObject(last50, toFile: chatURL.path!) {
            //Succeeded in writing to file
            print("Wrote message cache to disk")
        }

        else {
            print("Failed to write chat cache")
        }

        if let lastMessage = last50.last {
            if NSKeyedArchiver.archiveRootObject(lastMessage, toFile: chatURL.URLByAppendingPathExtension("last").path!) {
                print("Wrote last message to disk")
            }

            else {
                print("Failed to write last message to disk")
            }
        }
    }

    func handleEditedMessageNotification(notification: NSNotification) {
        didReceiveMessage()
    }

    func handleNewMessageNotification(notification: NSNotification) {
        didReceiveMessage()
    }

    func didReceiveMessage() {
        loadMessages()
    }

    func saveMessageEdit(editedText editedText: String) {
        let message = messages[editingCellIndex!]
        if editedText != message.text {
            message.editedText = editedText
            message.saveMessageEdit()
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: editingCellIndex!, inSection:0)], withRowAnimation: .Automatic)
        }
    }

    func sendMessageWithText(text: String) -> Bool {
        if let message = HLServer.sendMessageWithText(text, receiverID: recipientId) {
            print("Sent message")
            print(message.text)

            loadMessages()

            return true
        }

        return false
    }
    func sendImageWithData(data: NSData) {
        if let message = HLServer.sendImageWithData(data, receiverID: recipientId) {
            print("Sent voice message")
            print(message)
        }
        
        loadMessages()
        
    }
    
    func sendVoiceMessageWithData(data: NSData) {
        if let message = HLServer.sendVoiceMessageWithData(data, receiverID: recipientId) {
            print("Sent voice message")
            print(message)
        }
        
        loadMessages()

    }
    func setupEditMenuButtons() {
        let menuController = UIMenuController.sharedMenuController()

        let editItem = UIMenuItem(title: "Edit".localized, action: #selector(ChatViewController.editMessage))
        let translateItem = UIMenuItem(title: "Translate".localized, action: #selector(ChatViewController.translateMessage))

        menuController.menuItems = [editItem, translateItem]
    }

    func translateMessage() {

        let message = messages[selectedCellIndex!]

        if message.translatedText == nil {
            if let translatedText = HLServer.getTranslationForMessage(message, fromLanguage: nil) {
                message.translatedText = translatedText
            }
        }

        if message.translatedText != nil {
            message.showTranslation = !message.showTranslation
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: selectedCellIndex!, inSection: 0)], withRowAnimation: .Automatic)
            selectedCellIndex = nil
        }

        else {
            print("Cannot translate message")
        }
    }

    func editMessage() {
        editingCellIndex = selectedCellIndex
        
        testView.textView.becomeFirstResponder()
        testView.didBegingEditing()
        let selectedMessage = messages[selectedCellIndex!]
        if let editText = selectedMessage.editedText {
            testView.textView.text = editText
        }
        else {
            testView.textView.text = selectedMessage.text
        }
        testView.textViewDidChange(testView.textView)
        testView.textTestchange()
        //testView.textViewDidChange(testView.textView)

        tableView.scrollToRowAtIndexPath(NSIndexPath(forItem: editingCellIndex!, inSection: 0), atScrollPosition: .Bottom, animated: true)
    }

    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == #selector(ChatViewController.editMessage) {
            return selectedCellIndex != nil && canEditMessage()
        }

        else if action == #selector(ChatViewController.translateMessage) {
            return selectedCellIndex != nil
        }

        else if selectedCellIndex != nil {
            return false
        }

        return super.canPerformAction(action, withSender: sender)
    }
    
    @IBAction func details(sender: AnyObject) {
        //load user profile
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "detailsSegue" {
            let messageDetailViewController = segue.destinationViewController as! DetailViewController
            messageDetailViewController.user = user
            messageDetailViewController.hiddenName = true
        }
    }

    override func canBecomeFirstResponder() -> Bool {
        return true
    }

    func canEditMessage() -> Bool {
        if selectedCellIndex != nil {
            return messages[selectedCellIndex!].senderID  !=  currentUser.userId
        }
        return false
    }

    override var inputAccessoryView: UIView? {
        return testView
    }

    private func enableKeyboardHideOnTap(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.menuWillHide(_:)), name: UIMenuControllerWillHideMenuNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillChangeFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    func textViewDidChange(textView: UITextView) {
        tableView.scrollToBottom()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        guard editingCellIndex == nil else {
            return
        }

        let menuController = UIMenuController.sharedMenuController()

        let bubble: CGRect

        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? ChatTableViewCell {
            bubble = cell.convertRect(messages[indexPath.row].senderID == currentUser.userId ? cell.chatBubbleRight.frame : cell.chatBubbleLeft.frame, toView: self.view)
        }
        else if let cell = tableView.cellForRowAtIndexPath(indexPath) as? ChatEditedTableViewCell {
            bubble = cell.convertRect(messages[indexPath.row].senderID == currentUser.userId ? cell.chatBubbleRight.frame : cell.chatBubbleLeft.frame, toView: self.view)
        }

        else {
            return
        }

        selectedCellIndex = indexPath.row

        //This keeps the keyboard up if it's already up
        if testView.textView.isFirstResponder() {
            hiddenTextField.becomeFirstResponder()
        }

        //This delay MUST be here
        //Otherwiser, the whenever the first responder changes, the menu immediately disappears
        dispatch_after(5, dispatch_get_main_queue(), {
            menuController.setTargetRect(bubble, inView: self.view)
            menuController.setMenuVisible(true, animated: true)
        })
    }

    func menuWillHide(notification: NSNotification) {
        selectedCellIndex = nil
    }

    func keyboardWillShow(notification: NSNotification) {
        let oldKeyboardFrame = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()

        if oldKeyboardFrame.height + oldKeyboardFrame.minY > self.view.frame.height {
            self.chatTableView.scrollToBottom()
        }
    }

    func keyboardWillChangeFrame(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double

        UIView.animateWithDuration(duration) { () -> Void in
            if let height = self.navigationController?.navigationBar.frame.height {
                let inset = UIEdgeInsetsMake(height + 20, 0, keyboardFrame.size.height, 0)
                self.chatTableView.contentInset = inset
                self.chatTableView.scrollIndicatorInsets = inset
            }
        }

        if editingCellIndex != nil {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forItem: editingCellIndex!, inSection: 0), atScrollPosition: .Bottom, animated: true)
        }
    }

    //MARK:CELL ROW
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        if (message.audioURL != nil)  {
            let cellIdentity = "ChatVoiceTableViewCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentity, forIndexPath: indexPath) as! ChatVoiceTableViewCell
            
            let shownButton: UIButton
            let hiddenButton: UIButton

            if messages[indexPath.row].senderID  ==  currentUser.userId {
                shownButton = cell.rightButton
                hiddenButton = cell.leftButton
            }

            else {
                shownButton = cell.leftButton
                hiddenButton = cell.rightButton
            }

            shownButton.hidden = false
            hiddenButton.hidden = true
            
            shownButton.tag = indexPath.row

            if(isPlayingMessage){
                shownButton.setImage(UIImage(named: "shittyx")?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
            }else{
                shownButton.setImage(UIImage(named: "shittyplay")?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
            }
            
            return cell
        } else if message.editedText == nil {
            let cellIdentity = "ChatTableViewCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentity, forIndexPath: indexPath) as! ChatTableViewCell
            
            
            if messages[indexPath.row].senderID  ==  currentUser.userId {
                cell.chatBubbleLeft.hidden = true
                cell.chatBubbleLeft.text = ""
                
                cell.chatBubbleRight.layer.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.5).CGColor
                cell.chatBubbleRight.text = message.showTranslation ? message.translatedText! : message.text
                cell.chatBubbleRight.hidden = false
                cell.chatBubbleRight.layer.cornerRadius = 5
            }
                
            else {
                cell.chatBubbleRight.hidden = true
                cell.chatBubbleRight.text = ""
                
                cell.chatBubbleLeft.layer.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.5).CGColor
                cell.chatBubbleLeft.text = message.showTranslation ? message.translatedText! : message.text
                cell.chatBubbleLeft.hidden = false
                cell.chatBubbleLeft.layer.cornerRadius = 5
            }
        
            
            return cell
        } else {
            let cellIdentity = "ChatEditedTableViewCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentity, forIndexPath: indexPath) as! ChatEditedTableViewCell

            if message.attributedEditedText == nil {
                let lcs = longestCommonSubsequence(message.text, s2: message.editedText!)
                message.attributedEditedText = getDiff(message.text, s2: message.editedText!, lcs: lcs)
            }

            if messages[indexPath.row].senderID  ==  currentUser.userId {
                cell.chatBubbleLeft.hidden = true
                cell.leftMessageLabel.text = ""
                cell.leftEditedMessageLabel.text = ""
                cell.chatBubbleLeft.frame.size.height = 0
                cell.chatBubbleRight.hidden = false
                cell.chatBubbleRight.layer.cornerRadius = 5

                cell.rightMessageLabel.text = message.showTranslation ? message.translatedText! : message.text
                cell.rightEditedMessageLabel.attributedText = message.attributedEditedText
            }

            else {
                cell.chatBubbleRight.hidden = true
                cell.rightMessageLabel.text = ""
                cell.rightEditedMessageLabel.text = ""
                cell.chatBubbleLeft.hidden = false
                cell.chatBubbleLeft.layer.cornerRadius = 5

                cell.leftMessageLabel.text = message.showTranslation ? message.translatedText! : message.text
                cell.leftEditedMessageLabel.attributedText = message.attributedEditedText
            }

            return cell
        }
    }

    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool){
        curPlayingMessage!.setImage(UIImage(named: "shittyplay")?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
        isPlayingMessage = false;
    }

    @IBAction func tapPlayButton(sender: UIButton) {
        if isPlayingMessage == true {
            if sender == curPlayingMessage {
                sender.setImage(UIImage(named: "shittyplay")?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
                isPlayingMessage = false;
                audioPlayer.stop()
            } else {
                curPlayingMessage!.setImage(UIImage(named: "shittyplay")?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
                audioPlayer.stop()
                isPlayingMessage = false;
                tapPlayButton(sender)
            }
        } else {
            let deviceURL = messages[sender.tag].messageUUID!
            let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let audioURL = documentsURL.URLByAppendingPathComponent("\(deviceURL).m4a")
            recordingSession = AVAudioSession.sharedInstance()
            do {
                try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try recordingSession.setActive(true)

                //If an exception breakpoint stops here, you can usually ignore it because the exception is caught down below
                try audioPlayer = AVAudioPlayer(contentsOfURL: audioURL)
                audioPlayer.delegate = self
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
                audioPlayer.volume = 1;
                curPlayingMessage = sender
                audioPlayer.play()
            } catch let error as NSError{
                print("Downloading audio...",error);
                loadFileSync(messages[sender.tag].audioURL!,writeTo: audioURL, completion:{(audioURL:String, error:NSError!) in
                    print("downloaded to: \(audioURL)")
                })
                tapPlayButton(sender)
            }
            isPlayingMessage = true;
            sender.setImage(UIImage(named: "shittyx")?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
        }
    }
    
    func loadFileSync(url: NSURL,writeTo:NSURL, completion:(path:String, error:NSError!) -> Void) {
        //let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        let destinationUrl = writeTo
        if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
            completion(path: destinationUrl.path!, error:nil)
        } else if let dataFromURL = NSData(contentsOfURL: url){
            if dataFromURL.writeToURL(destinationUrl, atomically: true) {
                completion(path: destinationUrl.path!, error:nil)
            } else {
                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                completion(path: destinationUrl.path!, error:error)
            }
        } else {
            let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
            completion(path: destinationUrl.path!, error:error)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func loadMoreMessages(refreshControl: UIRefreshControl) {
        if let previousMessages = HLServer.retrieveMessageFromUser(recipientId, before: messages.first!.messageUUID!, max: 20) {
            messages = previousMessages + messages
            tableView.reloadData()
        }

        else {
            print("Couldn't load any more messages")
        }

        refreshControl.endRefreshing()
    }

    func loadEdits(before: Int64, count: Int=50) {
        if let edits = HLServer.retrieveEditedMessages(recipientId, before: before) {
            for edit in edits {
                if let id = (edit["id"] as? NSNumber)?.longLongValue {
                    if let encodedEditText = edit["editData"] as? String {
                        let editText = (NSString(data: NSData(base64EncodedString: encodedEditText, options: NSDataBase64DecodingOptions(rawValue: 0))!, encoding: NSUTF8StringEncoding) as! String)
                        for message in messages {
                            if message.messageUUID == id {
                                message.editedText = editText
                            }
                        }
                    }
                }
            }
        }
    }

    func loadMessages() {
        let chatURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent("\(recipientId).chat")
        if let storedMessages = NSKeyedUnarchiver.unarchiveObjectWithFile(chatURL.path!) as? [HLMessage] {
            messages = storedMessages
        }

        let lastCached: Int64
        if messages.count > 0 {
            lastCached = messages.last!.messageUUID!
        }

        else {
            lastCached = 0
        }

        if let newMessages = HLServer.retrieveMessageFromUser(recipientId, after: lastCached, max: 1000) {
            if newMessages.count > 0 {
                messages += newMessages
            } else {
                print("No new messages")
            }

            loadEdits(lastCached, count: 50 - newMessages.count)

            tableView.reloadData()
            tableView.scrollToBottom()
        }

        else {
            print("Failed to retrieve messsages from server")
        }
    }

    //Longest Common Subsequence
    func longestCommonSubsequence(s1: String, s2: String) -> String {
        print("s1: ", s1)
        print("s2: ", s2)
        var L = [[Int]](count: s1.characters.count+1, repeatedValue: [Int](count: s2.characters.count+1, repeatedValue: 0))

        for i in 0...s1.characters.count {
            for j in 0...s2.characters.count {
                if i == 0 || j == 0 {
                    L[i][j] = 0
                }

                else if s1[i-1] == s2[j-1] {
                    L[i][j] = L[i-1][j-1] + 1
                }

                else {
                    L[i][j] = max(L[i-1][j], L[i][j-1])
                }
            }
        }

        // Create a character array to store the lcs string
        var lcs = ""

        // Start from the right-most-bottom-most corner and
        // one by one store characters in lcs[]
        var i = s1.characters.count
        var j = s2.characters.count
        while (i > 0 && j > 0) {
            // If current character in X[] and Y are same, then
            // current character is part of LCS
            if (s1[i-1] == s2[j-1]) {
                lcs.insert(s1[i-1]!, atIndex: lcs.startIndex)
                i -= 1
                j -= 1
            }

            // If not same, then find the larger of two and
            // go in the direction of larger value
            else if (L[i-1][j] > L[i][j-1]) {
                i -= 1;
            }
            else {
                j -= 1;
            }
        }

        print(lcs)
        return lcs
    }

    func getDiff(s1: String, s2: String, lcs: String) -> NSAttributedString {

        var i = 0
        var j = 0
        var k = 0

        let attributedDiff = NSMutableAttributedString()
        var removedString = ""
        var addedString = ""
        var commonString = ""

        func appendRemovedString() {
            let attributedAddedString = NSAttributedString(string: removedString, attributes: [NSForegroundColorAttributeName : UIColor.grayColor(), NSStrikethroughStyleAttributeName : NSNumber(int: Int32(NSUnderlineStyle.StyleSingle.rawValue))])
            attributedDiff.appendAttributedString(attributedAddedString)
            removedString = ""
        }

        func appendAddedString() {
            let attributedRemovedString = NSAttributedString(string: addedString, attributes: [NSForegroundColorAttributeName : UIColor(red: 0, green: 169/255, blue: 0, alpha: 1)])
            attributedDiff.appendAttributedString(attributedRemovedString)
            addedString = ""
        }

        func appendCommonString() {
            let attributedCommonString = NSAttributedString(string: commonString)
            attributedDiff.appendAttributedString(attributedCommonString)
            commonString = ""
        }

        while i < s1.characters.count || j < s2.characters.count || k < lcs.characters.count {

            if s2[j] != lcs[k] {
                if removedString != "" {
                    appendRemovedString()
                }
                else if commonString != "" {
                    appendCommonString()
                }

                addedString.append(s2[j]!)
                j += 1
            }

            else if s1[i] != lcs[k] {
                if addedString != "" {
                    appendAddedString()
                }
                else if commonString != "" {
                    appendCommonString()
                }

                removedString.append(s1[i]!)
                i += 1
            }

            else {
                if removedString != "" {
                    appendRemovedString()
                }
                else if addedString != "" {
                    appendAddedString()
                }
                
                commonString.append(lcs[k]!)
                k += 1
                i += 1
                j += 1
            }
        }

        if addedString != "" {
            appendAddedString()
        }

        else if removedString != "" {
            appendRemovedString()
        }

        else if commonString != "" {
            appendCommonString()
        }
        
        return attributedDiff
    }

    func accessoryViewChangedToNewHeight(height: CGFloat) {
        
    }

}

extension UITableView {
    func scrollToBottom(ofSection section:Int=0, animated:Bool=true) {
        let cellCount = self.numberOfRowsInSection(section)

        self.scrollToRowAtIndexPath(NSIndexPath(forItem: cellCount-1, inSection: section), atScrollPosition: .Top, animated: animated)
    }
}

extension String {

    subscript (i: Int) -> Character? {
        if i >= self.characters.count {
            return nil
        }
        return self[self.startIndex.advancedBy(i)]
    }

//    subscript (i: Int) -> String {
//        return String(self[i] as Character)
//    }

    subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end = start.advancedBy(r.endIndex - r.startIndex)
        return self[Range(start ..< end)]
    }
}