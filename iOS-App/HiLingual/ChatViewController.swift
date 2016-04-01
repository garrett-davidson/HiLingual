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

    @IBOutlet weak var testView: UIView!
    
    @IBOutlet var chatTableViewConstraint: NSLayoutConstraint!
    var chatTableViewConstraintInitialValue: CGFloat?
    

    override func viewDidLoad() {
        self.title = user.name
        print(user.name)
        loadMessages()
        self.chatTableView.estimatedRowHeight = 40
        self.chatTableView.rowHeight = UITableViewAutomaticDimension
        self.tabBarController?.tabBar.hidden = true
        self.chatTableViewConstraintInitialValue = chatTableViewConstraint.constant
        enableKeyboardHideOnTap()
        tableViewScrollToBottom(false)
        
        
        //Code for bringing up audio scren
       // let controller = AudioRecorderViewController()
       // controller.audioRecorderDelegate = self
        //presentViewController(controller, animated: true, completion: nil)
        
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
        let adf = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100))
        let aet = AccessoryView.init(decoder: nil, frame: CGRect(x: 0, y: 0, width: adf.frame.width, height: adf.frame.height))
        adf.addSubview(aet)
        return testView
    }
    private func enableKeyboardHideOnTap(){
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func textViewDidChange(textView: UITextView) {

        tableViewScrollToBottom(true)
        chatTableView.cont
 
    }
    
    
    
    func keyboardWillShow(notification: NSNotification) {
        
        let info = notification.userInfo!
        
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        

        UIView.animateWithDuration(duration) { () -> Void in
            var contentOffset = self.chatTableView.contentOffset
            contentOffset.y = keyboardFrame.height
            self.chatTableView.contentOffset = contentOffset
            //self.chatTableViewConstraint.constant = -50
            //self.view.layoutIfNeeded()
            
        }
        //tableViewScrollToBottom(true)
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double

        UIView.animateWithDuration(duration) { () -> Void in
            
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