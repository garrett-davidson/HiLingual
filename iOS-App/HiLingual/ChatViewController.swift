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

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate{
    var user: HLUser!
    var currentUser = HLUser.getCurrentUser()
    var messageTest = [String]()
    var messages = [HLMessage]()

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
        self.title = user.name
        print(user.name)
        print(user.userId)
        loadMessages2()
        self.chatTableView.estimatedRowHeight = 40
        self.chatTableView.rowHeight = UITableViewAutomaticDimension
        self.tabBarController?.tabBar.hidden = true
        enableKeyboardHideOnTap()
        tableViewScrollToBottom(false)

        setupEditMenuButtons()

        testView.chatViewController = self

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.handleNewMessageNotification(_:)), name: AppDelegate.NotificationTypes.newMessage.rawValue, object: nil)
        
        //Code for bringing up audio scren
       // let controller = AudioRecorderViewController()
       // controller.audioRecorderDelegate = self
        //presentViewController(controller, animated: true, completion: nil)
        
    }

    func handleNewMessageNotification(notification: NSNotification) {
        didReceiveMessage()
    }

    func didReceiveMessage() {
        loadMessages2()
    }

    func saveMessageEdit(editedText editedText: String) {
        messages[editingCellIndex!].editedText = editedText
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: editingCellIndex!, inSection:0)], withRowAnimation: .Automatic)
    }

    func sendMessageWithText(text: String) -> Bool {
        if let message = HLMessage.sendMessageWithText(text, receiverID: recipientId) {
            print("Sent message")
            print(message.text)

            loadMessages2()

            return true
        }

        return false
    }
    
    func sendVoiceMessageWithData(data: NSData) {
        if let message = HLMessage.sendVoiceMessageWithData(data, receiverID: recipientId) {
            print("Sent message")
            print(message)
        }
        
        loadMessages2()

    }

    func setupEditMenuButtons() {
        let menuController = UIMenuController.sharedMenuController()

        let editItem = UIMenuItem(title: "Edit", action: #selector(ChatViewController.editMessage))
        let translateItem = UIMenuItem(title: "Translate", action: #selector(ChatViewController.translateMessage))

        menuController.menuItems = [editItem, translateItem]
    }

    func translateMessage() {
        print("Translate this message")
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

        guard messages[indexPath.row].senderID != currentUser.userId else {
            return
        }

        guard editingCellIndex == nil else {
            return
        }

        let menuController = UIMenuController.sharedMenuController()

        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? ChatTableViewCell {
            selectedCellIndex = indexPath.row
            let rect = cell.convertRect(cell.chatBubbleLeft.frame, toView: self.view)
            menuController.setTargetRect(rect, inView: self.view)
            menuController.setMenuVisible(true, animated: true)
        }
        else if let cell = tableView.cellForRowAtIndexPath(indexPath) as? ChatEditedTableViewCell {
            selectedCellIndex = indexPath.row
            let rect = cell.convertRect(cell.chatBubbleLeft.frame, toView: self.view)
            menuController.setTargetRect(rect, inView: self.view)
            menuController.setMenuVisible(true, animated: true)
        }
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
        
        tableViewScrollToBottom(true)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double

        UIView.animateWithDuration(duration) { () -> Void in
            if let height = self.navigationController?.navigationBar.frame.height {
                self.chatTableView.contentInset = UIEdgeInsetsMake(height + 20, 0, 0, 0);
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        if (message.audioURL != nil)  {
            let cellIdentity = "ChatTableViewCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentity, forIndexPath: indexPath) as! ChatTableViewCell
            
            let button = cell.button
            button.hidden = false
            
            if(isPlayingMessage){
                button.setImage(UIImage(named: "shittyx")?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
            }else{
                button.setImage(UIImage(named: "shittyplay")?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
            }
            button.addTarget(self, action: #selector(ChatViewController.tapPlayButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            button.tag = indexPath.row
            
            cell.chatBubbleLeft.hidden = true
            cell.chatBubbleRight.hidden = true
            button.translatesAutoresizingMaskIntoConstraints = true
            if messages[indexPath.row].senderID  ==  currentUser.userId {
                button.frame = CGRectMake(view.frame.size.width-45, 0, 30, 30)
            }
            else {
                button.frame = CGRectMake(15, 0, 30, 30)
            }
            
            return cell
        }else if message.editedText == nil {
            let cellIdentity = "ChatTableViewCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentity, forIndexPath: indexPath) as! ChatTableViewCell
            
            
            if messages[indexPath.row].senderID  ==  currentUser.userId {
                cell.chatBubbleLeft.hidden = true
                
                cell.chatBubbleRight.layer.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.5).CGColor
                cell.chatBubbleRight.text = message.text
                cell.chatBubbleRight.hidden = false
                cell.chatBubbleRight.layer.cornerRadius = 5
            }
                
            else {
                cell.chatBubbleRight.hidden = true
                
                cell.chatBubbleLeft.layer.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.5).CGColor
                cell.chatBubbleLeft.text = message.text
                cell.chatBubbleLeft.hidden = false
                cell.chatBubbleLeft.layer.cornerRadius = 5
            }
        
            cell.button.hidden = true
            
            return cell
        }else {
            let cellIdentity = "ChatEditedTableViewCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentity, forIndexPath: indexPath) as! ChatEditedTableViewCell

            if messages[indexPath.row].senderID  ==  currentUser.userId {
                cell.chatBubbleLeft.hidden = true

                cell.chatBubbleRight.hidden = false
                cell.chatBubbleRight.layer.cornerRadius = 5

                cell.rightMessageLabel.text = message.text
                cell.rightEditedMessageLabel.text = message.editedText
            }

            else {
                cell.chatBubbleRight.hidden = true

                cell.chatBubbleLeft.hidden = false
                cell.chatBubbleLeft.layer.cornerRadius = 5

                cell.leftMessageLabel.text = message.text
                cell.leftEditedMessageLabel.text = message.editedText
            }

            return cell
        }
    }
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool){
        curPlayingMessage!.setImage(UIImage(named: "shittyplay")?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
        isPlayingMessage = false;
    }
    func tapPlayButton(sender: UIButton) {
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
    func loadMessages() {
        let message1 = HLMessage(text: "Long ass message incoming HAHAHAHAAHAHAHAHAAHAHAHAHHAAHAHAHAHAHAHHAHAHAHAAHAHAHAHAAHAHAHAHHAAHAHAHAHAHAHHAHAHAHAAHAHAHAHAAHAHAHAHHAAHAHAHAHAHAHHAHAHAHAAHAHAHAHAAHAHAHAHHAAHAHAHAHAHAHHAHAHAHAAHAHAHAHAAHAHAHAHHAAHAHAHAHAHAHHAHAHAHAAHAHAHAHAAHAHAHAHHAAHAHAHAHAHAHHAHAHAHAAHAHAHAHAAHAHAHAHHAAHAHAHAHAHAHHAHAHAHAAHAHAHAHAAHAHAHAHHAAHAHAHAHAHAH", senderID: 5, receiverID: 68)
        let message2 = HLMessage(text: "💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩", senderID: 69, receiverID: 68)
        let message3 = HLMessage(text: "HA Messages are working", senderID: 5, receiverID: 68)
        let message4 = HLMessage(text: "lets see", senderID: 69, receiverID: 68)
        let message5 = HLMessage(text: "HA Messages are working", senderID: 5, receiverID: 69)
        let message6 = HLMessage(text: "Test Editedmessage 1", senderID: 1, receiverID: 69)
        let message7 = HLMessage(text: "Test ediTed mesage2", senderID: 69, receiverID: 5)
        let message8 = HLMessage(text: "audio://blahblah", senderID: 1, receiverID: 69)

        message6.editedText = "Test edited message 1"
        message7.editedText = "Test edited message 2"

        messages = [message1, message2, message3, message4, message5, message6, message7,message8]
    }

    func loadMessages2() {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://gethilingual.com/api/chat/\(recipientId)/message")!)
        if let session = HLUser.getCurrentUser().getSession() {

            request.allHTTPHeaderFields = ["Content-Type": "application/json", "Authorization": "HLAT " + session.sessionId]
            request.HTTPMethod = "GET"

            if let returnedData = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: nil) {
                print(returnedData)
                if let returnString = NSString(data: returnedData, encoding: NSUTF8StringEncoding) {
                    print(returnString)
                    messages = HLMessage.fromJSONArray(returnedData)
                    tableView.reloadData()

                    tableViewScrollToBottom(true)
                    return
                }
            }
        }
        
        print("Unable to load messages from server")

    }
}