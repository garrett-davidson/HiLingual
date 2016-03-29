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
    @IBOutlet weak var detailsProfile: UIBarButtonItem!
    @IBOutlet weak var chatTableView: UITableView!

    @IBOutlet weak var sendUITextView: UITextView!
    
    
    @IBOutlet weak var sendMessageView: UIView!
    
    @IBOutlet var chatTableViewConstraint: NSLayoutConstraint!
    @IBOutlet var toolbarBottomConstraint: NSLayoutConstraint!
    var toolbarBottomConstraintInitialValue: CGFloat?
    var chatTableViewConstraintInitialValue: CGFloat?
    override func viewDidLoad() {
        self.title = user.name
        print(user.name)
        loadBorders()
        self.tabBarController?.tabBar.hidden = true
        self.toolbarBottomConstraintInitialValue = toolbarBottomConstraint.constant
        self.chatTableViewConstraintInitialValue = chatTableViewConstraint.constant
        enableKeyboardHideOnTap()
        tableViewScrollToBottom(false)
    }
    
    @IBAction func sendMessage(sender: AnyObject) {
        sendUITextView.text = ""
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
    private func enableKeyboardHideOnTap(){
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func textViewDidChange(textView: UITextView) {
        
        //stop the view at top of screen somehow
 
 
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
        cell.chatBubble.text = "Test MessagesTest MessagesTest MessagesTest MessagesTest MessagesTest MessagesTest Messages"
        let color = UIColor.init(red: 0, green: 255, blue: 0, alpha: 0.5)
        
        cell.chatBubble.layer.backgroundColor = color.CGColor
        
        cell.chatBubble.layer.cornerRadius = 5
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 30
    }
    func loadBorders() {
        sendUITextView.layer.borderWidth = 0.5
        sendUITextView.layer.cornerRadius = 5
        sendMessageView.layer.borderWidth = 0.5
        chatTableViewConstraint.constant = chatTableViewConstraint.constant - 50
    }
    
    func tableViewScrollToBottom(animated: Bool) {
        
        let delay = 0.01 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(time, dispatch_get_main_queue(), {
        
        let numberOfSections = self.chatTableView.numberOfSections
        let numberOfRows = self.chatTableView.numberOfRowsInSection(numberOfSections-1)
            
        if numberOfRows > 0 {
            let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
            self.chatTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
        }
        })
        

    }
    
    

}