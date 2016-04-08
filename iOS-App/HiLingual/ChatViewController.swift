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

//Displays both the sent and received messages in a single chat

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate, UIKeyInput{
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
        tableViewScrollToBottom(false)

        setupEditMenuButtons()

        testView.chatViewController = self

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.handleNewMessageNotification(_:)), name: AppDelegate.NotificationTypes.newMessage.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.handleEditedMessageNotification(_:)), name: AppDelegate.NotificationTypes.editedMessage.rawValue, object: nil)
        
        //Code for bringing up audio scren
       // let controller = AudioRecorderViewController()
       // controller.audioRecorderDelegate = self
        //presentViewController(controller, animated: true, completion: nil)
        
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
        messages[editingCellIndex!].editedText = editedText
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: editingCellIndex!, inSection:0)], withRowAnimation: .Automatic)
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
    
    func sendVoiceMessageWithData(data: NSData) {
        if let message = HLServer.sendVoiceMessageWithData(data, receiverID: recipientId) {
            print("Sent message")
            print(message)
        }
        
        loadMessages()

    }
    func setupEditMenuButtons() {
        let menuController = UIMenuController.sharedMenuController()

        let editItem = UIMenuItem(title: "Edit", action: #selector(ChatViewController.editMessage))
        let translateItem = UIMenuItem(title: "Translate", action: #selector(ChatViewController.translateMessage))

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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.menuWillHide(_:)), name: UIMenuControllerWillHideMenuNotification, object: nil)
    }
    
    func textViewDidChange(textView: UITextView) {
        tableViewScrollToBottom(true)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

//        guard messages[indexPath.row].senderID != currentUser.userId else {
//            return
//        }

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

        //This keeps the keyboard up if it's already up
        if testView.textView.isFirstResponder() {
            self.becomeFirstResponder()
        }

        selectedCellIndex = indexPath.row
        menuController.setTargetRect(bubble, inView: self.view)
        menuController.setMenuVisible(true, animated: true)
    }

    func menuWillHide(notification: NSNotification) {
        selectedCellIndex = nil
    }

    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double

        UIView.animateWithDuration(duration) { () -> Void in
            if let height = self.navigationController?.navigationBar.frame.height {
                self.chatTableView.contentInset = UIEdgeInsetsMake(height + 20, 0, keyboardFrame.height, 0)
                self.view.layoutIfNeeded()
            }
            
        }
        if scroll < 2{
            scroll += 1
            tableViewScrollToBottom(true)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double

        UIView.animateWithDuration(duration) { () -> Void in
            if let height = self.navigationController?.navigationBar.frame.height {
                self.chatTableView.contentInset = UIEdgeInsetsMake(height + 20, 0, 0, 0);
                self.view.layoutIfNeeded()
            }
        }
        scroll = 0
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
        }else if message.editedText == nil {
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
        }else {
            let cellIdentity = "ChatEditedTableViewCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentity, forIndexPath: indexPath) as! ChatEditedTableViewCell

            if messages[indexPath.row].senderID  ==  currentUser.userId {
                cell.chatBubbleLeft.hidden = true
                cell.leftMessageLabel.text = ""
                cell.leftEditedMessageLabel.text = ""
                cell.chatBubbleLeft.frame.size.height = 0
                cell.chatBubbleRight.hidden = false
                cell.chatBubbleRight.layer.cornerRadius = 5

                cell.rightMessageLabel.text = message.showTranslation ? message.translatedText! : message.text
                cell.rightEditedMessageLabel.text = message.editedText
            }

            else {
                cell.chatBubbleRight.hidden = true
                cell.rightMessageLabel.text = ""
                cell.rightEditedMessageLabel.text = ""
                cell.chatBubbleLeft.hidden = false
                cell.chatBubbleLeft.layer.cornerRadius = 5

                cell.leftMessageLabel.text = message.showTranslation ? message.translatedText! : message.text
                cell.leftEditedMessageLabel.text = message.editedText
            }

            return cell
        }
    }
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool){
        curPlayingMessage!.setImage(UIImage(named: "shittyplay")?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
        isPlayingMessage = false;
    }
    @IBAction func tapPlayButton(sender: UIButton) {
        if(isPlayingMessage == true){
            if(sender == curPlayingMessage){
                sender.setImage(UIImage(named: "shittyplay")?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
                isPlayingMessage = false;
                audioPlayer.stop()
            }else{
                curPlayingMessage!.setImage(UIImage(named: "shittyplay")?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
                audioPlayer.stop()
                isPlayingMessage = false;
                tapPlayButton(sender)
            }
        }else{
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
    
    func tableViewScrollToBottom(animated: Bool) {

        dispatch_async(dispatch_get_main_queue(), {
            let numberOfSections = self.chatTableView.numberOfSections
            let numberOfRows = self.chatTableView.numberOfRowsInSection(numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
                self.chatTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
            }
        })
    }

    func loadMoreMessages(refreshControl: UIRefreshControl) {

        let countToLoad = 20

        //TODO: Update this with the updated server api
        if let previousMessages = HLServer.retrieveMessageFromUser(recipientId, sinceLastMessageId: messages.first!.messageUUID! - countToLoad, max: 20) {
            messages = previousMessages + messages
            tableView.reloadData()
        }

        else {
            print("Couldn't load any more messages")
        }

        refreshControl.endRefreshing()
    }

    func loadMessages() {
        let chatURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent("\(recipientId).chat")
        if let storedMessages = NSKeyedUnarchiver.unarchiveObjectWithFile(chatURL.path!) as? [HLMessage] {
            messages = storedMessages
        }

        let mostRecentCached: Int64
        if messages.count > 0 {
            mostRecentCached = messages.last!.messageUUID!
        }

        else {
            mostRecentCached = 0
        }

        if let retrievedMessages = HLServer.retrieveMessageFromUser(recipientId, sinceLastMessageId: mostRecentCached, max: 1000) {
            messages += retrievedMessages
            tableView.reloadData()
            tableViewScrollToBottom(false)

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
        }

        else {
            print("Failed to retrieve messsages from server")
        }
    }

    //These have to be here to fix the Edit/Translate buttons 😑
    func hasText() -> Bool {
        return false
    }
    func insertText(text: String) {

    }
    func deleteBackward() {

    }
}