//
//  FlashcardTableViewController.swift
//  HiLingual
//
//  Created by Noah Maxey on 4/17/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation
import UIKit

class FlashcardTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var flashcards = [HLFlashCard]()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        enableKeyboardHideOnTap()
        navigationItem.rightBarButtonItem = editButtonItem()
        self.tableView.tableFooterView = UIView();
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FlashcardCell", forIndexPath: indexPath) as! FlashcardCell
        cell.front.text = flashcards[indexPath.row].frontText
        cell.back.text = flashcards[indexPath.row].backText
        cell.front.tag = indexPath.row
        cell.back.tag = indexPath.row
        cell.front.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        cell.back.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flashcards.count
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    

    @IBAction func addFlashcard(sender: AnyObject) {
        flashcards.append(HLFlashCard(frontText: "", backText: ""))
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: tableView.numberOfRowsInSection(0), inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
        

    }
    func keyboardWillChangeFrame(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animateWithDuration(duration) { () -> Void in
            if let height = self.navigationController?.navigationBar.frame.height {

                let inset = UIEdgeInsetsMake(height + 20, 0, keyboardFrame.size.height, 0)
                self.tableView.contentInset = inset
                self.tableView.scrollIndicatorInsets = inset
            }
        }
    }
    private func enableKeyboardHideOnTap(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillChangeFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            flashcards.removeAtIndex(indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.endUpdates()
            
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "beginViewing" {
            let messageDetailViewController = segue.destinationViewController as! FlashcardSetViewController
            print(flashcards.count)
            messageDetailViewController.flashcards = flashcards
            messageDetailViewController.title = title
                
            
            
            
        }
        
    }
    func textFieldDidChange(textField: UITextField) {
        let i = textField.tag
        let index = NSIndexPath(forRow: i, inSection: 0)
        tableView.scrollToRowAtIndexPath(index, atScrollPosition: .Bottom, animated: true)
        if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as? FlashcardCell {
            if textField === cell.front{
                flashcards[i].frontText = textField.text
            } else {
                flashcards[i].backText = textField.text
            }
        }
    }
    func textFieldDidEndEditing(textField: UITextField) {
        let i = textField.tag
        
        if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as? FlashcardCell {
            if textField === cell.front{
                flashcards[i].frontText = textField.text
            } else {
                flashcards[i].backText = textField.text
            }
        }
    }
    func tableView(tableView: UITableView,
                   moveRowAtIndexPath sourceIndexPath: NSIndexPath,
                                      toIndexPath destinationIndexPath: NSIndexPath) {
        // remove the dragged row's model
        let val1 = self.flashcards.removeAtIndex(sourceIndexPath.row)
        
        // insert it into the new position
        self.flashcards.insert(val1, atIndex: destinationIndexPath.row)
    }

    
    
    
}
