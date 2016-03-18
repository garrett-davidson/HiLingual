//
//  ChatViewController.swift
//  HiLingual
//
//  Created by Garrett Davidson on 2/14/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation
import UIKit

//Displays both the sent and received messages in a single chat

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    var user: HLUser!
    @IBOutlet weak var detailsProfile: UIBarButtonItem!

    @IBOutlet weak var chatToolbar: UIToolbar!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var sendTextField: UITextField!
    @IBOutlet weak var chatTableViewConstraint: NSLayoutConstraint!
    
    @IBOutlet var toolbarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldBarButtonItem: UIBarButtonItem!
    var toolbarBottomConstraintInitialValue: CGFloat?
    var chatTableViewConstraintInitialValue: CGFloat?
    override func viewDidLoad() {
        self.title = user.name
        print(user.name)
        self.tabBarController?.tabBar.hidden = true

        self.toolbarBottomConstraintInitialValue = toolbarBottomConstraint.constant
        self.chatTableViewConstraintInitialValue = chatTableViewConstraint.constant
        enableKeyboardHideOnTap()
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        let info = notification.userInfo!
        
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animateWithDuration(duration) { () -> Void in
            
            self.toolbarBottomConstraint.constant = keyboardFrame.size.height
            self.chatTableViewConstraint.constant += keyboardFrame.size.height
            self.view.layoutIfNeeded()
            
        }
        
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
        let cell = UITableViewCell()
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    

}