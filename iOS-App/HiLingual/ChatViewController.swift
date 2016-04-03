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

//Displays both the sent and receivedvarssages in a single chat

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate{
    var user: HLUser!
    var currentUser = HLUser.getCurrentUser()
    var messageTest = [String]()
    var messages = [HLMessage]()

    @IBOutlet weak var detailsProfile: UIBarButtonItem!
    @IBOutlet weak var chatTableView: UITableView!

    @IBOutlet weak var testView: AccessoryView!
    
    var selectedCellIndex: Int?

    override func viewDidLoad() {
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
        
        //Code for bringing up audio scren
       // let controller = AudioRecorderViewController()
       // controller.audioRecorderDelegate = self
        //presentViewController(controller, animated: true, completion: nil)
        
    }

    func setupEditMenuButtons() {
        let menuController = UIMenuController.sharedMenuController()

        let editItem = UIMenuItem(title: "Edit", action: #selector(ChatViewController.testEdit))
        menuController.menuItems = [editItem]
    }

    func testEdit() {
        print("Edit")
    }

    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        switch (action) {
        case #selector(ChatViewController.testEdit):
            return canEditMessage()

        default:
            return super.canPerformAction(action, withSender: sender)
        }
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
    }
    
    func textViewDidChange(textView: UITextView) {
        tableViewScrollToBottom(true)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let menuController = UIMenuController.sharedMenuController()
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? ChatTableViewCell {
            selectedCellIndex = indexPath.row
            let rect = cell.convertRect(cell.chatBubbleLeft.frame, toView: self.view)
            menuController.setTargetRect(rect, inView: self.view)
            menuController.setMenuVisible(true, animated: true)
        }
    }

    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double

        UIView.animateWithDuration(duration) { () -> Void in
            self.chatTableView.contentInset = UIEdgeInsetsMake((self.navigationController?.navigationBar.frame.height)! + 20, 0, keyboardFrame.height, 0)
            self.view.layoutIfNeeded()
        }
        
        tableViewScrollToBottom(true)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double

        UIView.animateWithDuration(duration) { () -> Void in
            self.chatTableView.contentInset = UIEdgeInsetsMake((self.navigationController?.navigationBar.frame.height)! + 20, 0, 0, 0);
            self.view.layoutIfNeeded()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cellIdentity = "ChatTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentity, forIndexPath: indexPath) as! ChatTableViewCell
        let message = messages[indexPath.row].text

        if messages[indexPath.row].senderID  ==  currentUser.userId {
            
            cell.chatBubbleRight.layer.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.5).CGColor
            cell.chatBubbleRight.text = message
            cell.chatBubbleRight.hidden = false
            cell.chatBubbleRight.layer.cornerRadius = 5
        }

        else {
            cell.chatBubbleLeft.layer.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.5).CGColor
            cell.chatBubbleLeft.text = message
            cell.chatBubbleLeft.hidden = false
            cell.chatBubbleLeft.layer.cornerRadius = 5
        }
        
        return cell
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
        let message5 = HLMessage(text: "HA Messages are working", senderID: 69, receiverID: 68)
        
        messages = [message1,message2,message3, message4,message5]
    }
    
}