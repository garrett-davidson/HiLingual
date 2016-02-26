//
//  MessagesViewController.swift
//  HiLingual
//
//  Created by Garrett Davidson on 2/14/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation
import UIKit

//Displays all user's chats
//Displays a list of users conversed with, even if the chat has been deleted

class MessagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var converstationTable: UITableView!
    var conversations = [HLUser]()
    var messages = [HLMessage]()
    var hiddenButtons = [Bool]()
    override func viewDidLoad() {
        loadSamples();
        // grab any requests from server
        //navigationItem.leftBarButtonItem = editButtonItem()
        //check to see if accept and decline need to be there
        //conversations = getCurrentUser().chattedWith
        //for (getCurrentUser().chattedWith.count)) hiddenButtons+= true
        // hiddenButtons = getCurrentUser().chattedWith
        //grab users.ChattedWith to fill users conversations list
        
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentity = "ConversationTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentity, forIndexPath: indexPath) as! ConversationTableViewCell
        let user = conversations[indexPath.row]
        let hidden = hiddenButtons[indexPath.row]
        //Should it be displayname or name?
        cell.name.text = user.displayName
        cell.profilePicture.layer.masksToBounds = false
        cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.height/2
        cell.profilePicture.clipsToBounds = true
        cell.profilePicture.image = user.profilePicture
        cell.acceptButton.tag = indexPath.row
        cell.declineButton.tag = indexPath.row
        cell.declineButton.hidden = hidden
        cell.acceptButton.hidden = hidden
        //Mark: Fills the view
        if (hidden){
            cell.date.text = "Yeserday"
            cell.lastMessage.text = "This is an already accepted request"
        }else{
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.date.text = ""
            cell.lastMessage.text = ""
            
        }
        return cell
    }
    @IBAction func accept(sender: UIButton) {
        //send accept to server
        let index = sender.tag
        hiddenButtons[index] = true
        converstationTable.reloadData()
        
    }
    @IBAction func decline(sender: UIButton) {
        sender.hidden = true
        let index = sender.tag
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        hiddenButtons.removeAtIndex(index)
        conversations.removeAtIndex(index)
        converstationTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade )
        converstationTable.reloadData()
        //send decline to server
    }
    
    func loadSamples(){
        conversations += [HLUser.generateTestUser(),HLUser.generateTestUser(),HLUser.generateTestUser() ]
        hiddenButtons += [false,true,false]
    
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMessageSegue"{
            let messageDetailViewController = segue.destinationViewController as! ChatViewController
            if let selectedMessageCell = sender as? ConversationTableViewCell {
                let indexPath = converstationTable.indexPathForCell(selectedMessageCell)!
                messageDetailViewController.user = conversations[indexPath.row]
                messageDetailViewController.messageHidden = hiddenButtons[indexPath.row]
                converstationTable.deselectRowAtIndexPath(indexPath, animated: false)
                //Once messages is complete I can use that
                
            }
            
        } else{
            
        }
    
    }
    /*
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = converstationTable.cellForRowAtIndexPath(indexPath)
        if cell?.reuseIdentifier == "ConversationTableViewCell"{
            if hiddenButtons[indexPath.row]{
                performSegueWithIdentifier("testMessageSegue", sender: cell)
            }
        }
        
    }

    override func performSegueWithIdentifier(identifier: String, sender: AnyObject?) {
        if identifier == "testMessageSegue"{
            let messageDetailViewController = ChatViewController()
            if let selectedMessageCell = sender as? ConversationTableViewCell {
                let indexPath = converstationTable.indexPathForCell(selectedMessageCell)!
                converstationTable.deselectRowAtIndexPath(indexPath, animated: false)
                //let selectedMessage = converstaions[indexPath.row]
                messageDetailViewController.message = conversations[indexPath.row].name
                
                //Once messages is complete I can use that
                
            }
            
        }
        
        
    }
    */
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            conversations.removeAtIndex(indexPath.row)
            hiddenButtons.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            converstationTable.reloadData()
        }
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
}