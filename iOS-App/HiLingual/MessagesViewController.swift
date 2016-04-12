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
    var messages = [HLMessage]()

    let currentUser = HLUser.getCurrentUser()

    var hasPendingChats: Bool {
        get {
            return currentUser.pendingChats.count > 0
        }
    }

    override func viewDidLoad() {
        self.tabBarController?.tabBar.hidden = false
        // grab any requests from server
        //navigationItem.leftBarButtonItem = editButtonItem()
        //check to see if accept and decline need to be there
        //conversations = getCurrentUser().chattedWith
        //for (getCurrentUser().chattedWith.count)) hiddenButtons+= true
        // hiddenButtons = getCurrentUser().chattedWith
        //grab users.ChattedWith to fill users conversations list
        
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return hasPendingChats ? 2 : 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return hasPendingChats ? currentUser.pendingChats.count : currentUser.usersChattedWith.count

        case 1:
            return currentUser.usersChattedWith.count
        default:
            print("Invalid section number")
            return 0
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.tabBarController!.tabBar.hidden = false

        refreshTableView()
    }

    override func viewDidAppear(animated: Bool) {
        refreshTableView()
    }

    func refreshTableView() {

        if let chats = HLServer.getChats() {
            if let pendingChats = chats["pendingChats"] as? [Int] {
                HLUser.getCurrentUser().pendingChats = pendingChats.map({ (i) -> Int64 in
                    Int64(i)
                })
            }

            if let acceptedChats = chats["currentChats"] as? [Int] {
                HLUser.getCurrentUser().usersChattedWith = acceptedChats.map({ (i) -> Int64 in
                    Int64(i)
                })
            }

            converstationTable.reloadData()
        }
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if numberOfSectionsInTableView(tableView) < 2 {
            return nil
        }

        if section == 1 || section == 0 && !hasPendingChats {
            return "Current chats".localized
        }

        else {
            return "Pending chats".localized
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        //Accepted chat
        if indexPath.section == 1 || indexPath.section == 0 && !hasPendingChats {
            let cellIdentity = "ConversationTableViewCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentity, forIndexPath: indexPath) as! ConversationTableViewCell

            let user = HLServer.getUserById(currentUser.usersChattedWith[indexPath.row])!

            cell.name.text = user.name
            cell.profilePicture.layer.masksToBounds = false
            cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.height/2
            cell.profilePicture.clipsToBounds = true
            cell.profilePicture.image = user.profilePicture
            cell.acceptButton.tag = indexPath.row
            cell.declineButton.tag = indexPath.row
            cell.declineButton.hidden = true
            cell.acceptButton.hidden = true


            cell.date.text = "Yesterday".localized
            cell.lastMessage.text = ""
            return cell
        }

        //Pending chats
        else {
            let cellIdentity = "ConversationTableViewCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentity, forIndexPath: indexPath) as! ConversationTableViewCell
            //Should it be displayname or name?
            let user = HLServer.getUserById(currentUser.pendingChats[indexPath.row])!
            cell.name.text = user.name
            cell.profilePicture.layer.masksToBounds = false
            cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.height/2
            cell.profilePicture.clipsToBounds = true
            cell.profilePicture.image = user.profilePicture
            cell.acceptButton.tag = indexPath.row
            cell.declineButton.tag = indexPath.row
            cell.declineButton.hidden = false
            cell.acceptButton.hidden = false
            //Mark: Fills the view
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.date.text = ""
            cell.lastMessage.text = ""
            return cell
        }
    }

    @IBAction func accept(sender: UIButton) {
        //send accept to server
        let index = sender.tag

        let acceptedUser = currentUser.pendingChats[index]

        let request = NSMutableURLRequest(URL: NSURL(string: "https://gethilingual.com/api/chat/\(acceptedUser)/accept")!)
        request.allHTTPHeaderFields = ["Content-Type": "application/json", "Authorization": "HLAT " + (HLUser.getCurrentUser().getSession()?.sessionId)!]
        request.HTTPMethod = "POST"

        var resp: NSURLResponse?
        if let returnedData = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: &resp) {
            if let response = resp as? NSHTTPURLResponse {
                if response.statusCode == 204 {
                    print("Accepted request")
                    refreshTableView()
                    return
                }
            }

            print(returnedData)
            if let returnString = NSString(data: returnedData, encoding: NSUTF8StringEncoding) {
                print(returnString)
            }

        }

        print("Failed to accept request")
    }
    @IBAction func decline(sender: UIButton) {
        sender.hidden = true
        let index = sender.tag
        let indexPath = NSIndexPath(forRow: index, inSection: 0)

        currentUser.pendingChats.removeAtIndex(index)

        converstationTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade )
        converstationTable.reloadData()
        //send decline to server
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SegueToProfile"{
            let messageDetailViewController = segue.destinationViewController as! DetailViewController
            if let selectedMessageCell = sender as? ConversationTableViewCell {
                let indexPath = converstationTable.indexPathForCell(selectedMessageCell)!
                converstationTable.deselectRowAtIndexPath(indexPath, animated: false)
                messageDetailViewController.user = HLServer.getUserById(currentUser.pendingChats[indexPath.row])
                //Once messages is complete I can use that
                
            }

            
        }
            
        else if segue.identifier == "SegueToMessages" {
            let messageDetailViewController = segue.destinationViewController as! ChatViewController
            if let selectedMessageCell = sender as? ConversationTableViewCell {
                let indexPath = converstationTable.indexPathForCell(selectedMessageCell)!
                converstationTable.deselectRowAtIndexPath(indexPath, animated: false)
                messageDetailViewController.user = HLServer.getUserById(currentUser.usersChattedWith[indexPath.row])
                messageDetailViewController.recipientId = currentUser.usersChattedWith[indexPath.row]
                //Once messages is complete I can use that
                
            }
        }
    
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = converstationTable.cellForRowAtIndexPath(indexPath)
        if indexPath.section == 1 || indexPath.section == 0 && !hasPendingChats {
            self.performSegueWithIdentifier("SegueToMessages", sender: cell)
            print("ACCEPTED")
        }
        else{
            
            self.performSegueWithIdentifier("SegueToProfile", sender: cell)
        }
        
    }
    /*
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

            if indexPath.section == 1 || indexPath.section == 0 && !hasPendingChats {
                currentUser.usersChattedWith.removeAtIndex(indexPath.row)
            }

            else {
                currentUser.pendingChats.removeAtIndex(indexPath.row)
            }

            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            converstationTable.reloadData()
        }
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
}