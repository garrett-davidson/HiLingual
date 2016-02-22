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
    var converstaions = [HLUser]()
    var messages = [HLMessage]()
    override func viewDidLoad() {
        loadSamples();
        //navigationItem.leftBarButtonItem = editButtonItem()
        //check to see if accept and decline need to be there
        
        
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return converstaions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentity = "ConversationTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentity, forIndexPath: indexPath) as! ConversationTableViewCell
        let user = converstaions[indexPath.row]
        cell.name.text = user.name
        cell.profilePicture.layer.masksToBounds = false
        cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.height/2
        cell.profilePicture.clipsToBounds = true
        cell.profilePicture.image = user.profilePicture
        //Mark: Fills the view
        cell.date.text = "Yesterday"
        cell.lastMessage.text = "HEY WAHTS UP THIS MESSAGE IS JUST HERE TO SEE HOW THE WORD WRAPS AT THE END OF THE LINE SOME IGNORE IT"
        return cell
    }
    @IBAction func accept(sender: UIButton) {
        //send accept to server
        
        sender.hidden = true
        
    }
    @IBAction func decline(sender: UIButton) {
        sender.hidden = true
        //let index = sender.tag
        //converstaions.removeAtIndex(index)
        //send decline to server
    }
    
    func loadSamples(){
        converstaions += [HLUser.generateTestUser(),HLUser.generateTestUser(),HLUser.generateTestUser() ]
    
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMessageSegue"{
            let messageDetailViewController = segue.destinationViewController as! ChatViewController
            if let selectedMessageCell = sender as? ConversationTableViewCell {
                let indexPath = converstationTable.indexPathForCell(selectedMessageCell)!
                //let selectedMessage = converstaions[indexPath.row]
                messageDetailViewController.message = converstaions[indexPath.row].name
                
                //Once messages is complete I can use that
                
            }
            
        }
    
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            converstaions.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
}