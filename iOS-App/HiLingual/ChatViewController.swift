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

//Displays both the sent and received messages in a single chat

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate{
    var user: HLUser!
    var messageTest = [String]()
    @IBOutlet weak var detailsProfile: UIBarButtonItem!
    @IBOutlet weak var chatTableView: UITableView!

    @IBOutlet weak var sendUITextView: UITextView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var sendMessageView: UIView!
    
    @IBOutlet var chatTableViewConstraint: NSLayoutConstraint!
    @IBOutlet var toolbarBottomConstraint: NSLayoutConstraint!
    var toolbarBottomConstraintInitialValue: CGFloat?
    var chatTableViewConstraintInitialValue: CGFloat?
    

    override func viewDidLoad() {

        

        self.title = user.name
        print(user.name)
        loadBorders()
        loadMessages()
        self.chatTableView.estimatedRowHeight = 40
        self.chatTableView.rowHeight = UITableViewAutomaticDimension
        self.tabBarController?.tabBar.hidden = true
        self.toolbarBottomConstraintInitialValue = toolbarBottomConstraint.constant
        self.chatTableViewConstraintInitialValue = chatTableViewConstraint.constant
        enableKeyboardHideOnTap()
        tableViewScrollToBottom(false)
        
    }
    
    @IBAction func sendMessage(sender: AnyObject) {
        sendUITextView.scrollEnabled = false
        messageTest += [sendUITextView.text]
        sendUITextView.text = ""
        sendButton.userInteractionEnabled = false
        sendButton.tintColor = UIColor.lightGrayColor()
        chatTableView.reloadData()
        tableViewScrollToBottom(false)
        //send message
        //add to table
        
    }
    @IBAction func details(sender: AnyObject) {
        //load user profile
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "detailsSegue"{
            let messageDetailViewController = segue.destinationViewController as! DetailViewController
            messageDetailViewController.user = user
            messageDetailViewController.hiddenName = true
            
        }

    }
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    override var inputAccessoryView: UIView? {
        let adf = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        let aet = AccessoryView.init(decoder: nil, frame: CGRect(x: 0, y: 0, width: adf.frame.width, height: adf.frame.height))
        adf.addSubview(aet)
        return adf
    }
    private func enableKeyboardHideOnTap(){
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func textViewDidChange(textView: UITextView) {
        
        //stop the view at top of screen somehow
        textView.reloadInputViews()
        if textView.text == "" {
            textView.scrollEnabled = false
            textView.sizeToFit()
            textView.layoutIfNeeded()
            sendButton.tintColor = UIColor.lightGrayColor()
            sendButton.userInteractionEnabled = false
        }else{
            sendButton.tintColor = UIColor.blueColor()
            sendButton.userInteractionEnabled = true
        }
        
        if textView.frame.height > 123 {
            textView.scrollEnabled = true

            //sendMessageView.frame.height = 140
        }else{
            textView.scrollEnabled = false
            
        }
        textView.reloadInputViews()
        sendMessageView.reloadInputViews()
        let numLines = textView.contentSize.height / textView.font!.lineHeight;
        if numLines < 6 {
            textView.scrollEnabled = false
        }
        textView.reloadInputViews()

        tableViewScrollToBottom(true)
 
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        
        let info = notification.userInfo!
        
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        

        UIView.animateWithDuration(duration) { () -> Void in
            
            self.toolbarBottomConstraint.constant = keyboardFrame.size.height
            self.chatTableViewConstraint.constant = -50
            self.view.layoutIfNeeded()
            
        }
        tableViewScrollToBottom(true)
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double

        UIView.animateWithDuration(duration) { () -> Void in
            
            self.toolbarBottomConstraint.constant = self.toolbarBottomConstraintInitialValue!
            self.chatTableViewConstraint.constant = self.chatTableViewConstraintInitialValue!
            self.view.layoutIfNeeded()
            
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        
        let cellIdentity = "ChatTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentity, forIndexPath: indexPath) as! ChatTableViewCell
        let message = messageTest[indexPath.row]
        
        cell.chatBubble.text = message
        let color = UIColor.init(red: 0, green: 1, blue: 0, alpha: 0.5)
        
        cell.chatBubble.layer.backgroundColor = color.CGColor
        
        cell.chatBubble.layer.cornerRadius = 5
        if indexPath.row % 2  == 0{ // change to userid
            let color = UIColor.init(red: 0, green: 0, blue: 1, alpha: 0.5)
            
            cell.chatBubble.layer.backgroundColor = color.CGColor
            
            cell.removeConstraint(cell.leftConstraintMessageequal)
            cell.removeConstraint(cell.rightConstraintMessageEqualOrLess)
            cell.addConstraint(cell.rightConstraintMessage)
            cell.addConstraint(cell.leftConstraintMessage)


        }else{
            cell.removeConstraint(cell.rightConstraintMessage)
            cell.removeConstraint(cell.leftConstraintMessage)
            cell.addConstraint(cell.leftConstraintMessageequal)
            cell.addConstraint(cell.rightConstraintMessageEqualOrLess)

        }
 
        
        return cell
    }
    

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messageTest.count
    }
    func loadBorders() {
        let color = UIColor.init(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.7)

        sendMessageView.backgroundColor = color
        sendUITextView.layer.borderWidth = 0.5
        sendUITextView.layer.cornerRadius = 5
        sendMessageView.layer.borderWidth = 0.5
        chatTableViewConstraint.constant = chatTableViewConstraint.constant - 50
    }
    
    func tableViewScrollToBottom(animated: Bool) {
        
        //let delay = 0.01 * Double(NSEC_PER_SEC)
        //let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
       // dispatch_after(time, dispatch_get_main_queue(), {
        dispatch_async(dispatch_get_main_queue(), {
        let numberOfSections = self.chatTableView.numberOfSections
        let numberOfRows = self.chatTableView.numberOfRowsInSection(numberOfSections-1)
            
        if numberOfRows > 0 {
            let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
            self.chatTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
        }
        })
        

    }
    func loadMessages(){
        
        messageTest += ["First Message", "Long ass message incoming HAHAHAHAAHAHAHAHAAHAHAHAHHAAHAHAHAHAHAHHAHAHAHAAHAHAHAHAAHAHAHAHHAAHAHAHAHAHAHHAHAHAHAAHAHAHAHAAHAHAHAHHAAHAHAHAHAHAHHAHAHAHAAHAHAHAHAAHAHAHAHHAAHAHAHAHAHAHHAHAHAHAAHAHAHAHAAHAHAHAHHAAHAHAHAHAHAHHAHAHAHAAHAHAHAHAAHAHAHAHHAAHAHAHAHAHAHHAHAHAHAAHAHAHAHAAHAHAHAHHAAHAHAHAHAHAHHAHAHAHAAHAHAHAHAAHAHAHAHHAAHAHAHAHAHAH", "💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩", " ","aadsfasdfasfafasfajfjidsijijjiafdsjisjifsdijsdfjifij", "asdfjfasjfiaijfijfijdfsjiafsijfasdi", "lets see", "more messages", "being weird" ]
    }
    
    

}