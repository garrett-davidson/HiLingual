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

struct HLChat {
    let receiverId: UInt64
    var lastReceivedMessageId: UInt64
    var lastAckedMessageId: UInt64
    var lastPartnerAckedMessageId: UInt64
}

extension HLChat: Equatable, Comparable { }

func == (lhs: HLChat, rhs: HLChat) -> Bool {
    if let lhsMessage = NSKeyedUnarchiver.unarchiveObjectWithFile(NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent("\(lhs.receiverId).chat.last").path!) as? HLMessage {
        if let rhsMessage = NSKeyedUnarchiver.unarchiveObjectWithFile(NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent("\(rhs.receiverId).chat.last").path!) as? HLMessage {
            return lhsMessage.sentTimestamp == rhsMessage.sentTimestamp
        }
    }
    return false
}

func < (lhs: HLChat, rhs: HLChat) -> Bool {
    if let lhsMessage = NSKeyedUnarchiver.unarchiveObjectWithFile(NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent("\(lhs.receiverId).chat.last").path!) as? HLMessage {
        if let rhsMessage = NSKeyedUnarchiver.unarchiveObjectWithFile(NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent("\(rhs.receiverId).chat.last").path!) as? HLMessage {
            return lhsMessage.sentTimestamp > rhsMessage.sentTimestamp
        }
        return true
    }
    return false
}

func >(lhs: HLChat, rhs: HLChat) -> Bool {
    if let lhsMessage = NSKeyedUnarchiver.unarchiveObjectWithFile(NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent("\(lhs.receiverId).chat.last").path!) as? HLMessage {
        if let rhsMessage = NSKeyedUnarchiver.unarchiveObjectWithFile(NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent("\(rhs.receiverId).chat.last").path!) as? HLMessage {
            return lhsMessage.sentTimestamp < rhsMessage.sentTimestamp
        }
        return false
    }
    return true
}

func > (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSinceReferenceDate > rhs.timeIntervalSinceReferenceDate
}

func < (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSinceReferenceDate < rhs.timeIntervalSinceReferenceDate
}

class MessagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var converstationTable: UITableView!
    var messages = [HLMessage]()

    let currentUser = HLUser.getCurrentUser()
    let timestampFormamter = NSDateFormatter()

    var currentChats = [HLChat]()

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

        timestampFormamter.locale = NSLocale.autoupdatingCurrentLocale()
        timestampFormamter.dateStyle = .ShortStyle
        timestampFormamter.timeStyle = .ShortStyle
        timestampFormamter.doesRelativeDateFormatting = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessagesViewController.refreshTableView), name: AppDelegate.NotificationTypes.newMessage.rawValue, object: nil)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return hasPendingChats ? 2 : 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return hasPendingChats ? currentUser.pendingChats.count : currentChats.count

        case 1:
            return currentChats.count
        default:
            print("Invalid section number")
            return 0
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.tabBarController!.tabBar.hidden = false
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

            if let acceptedChats = chats["currentChats"] as? [NSDictionary] {
                currentChats = []
                for chat in acceptedChats {
                    if let ackDict = chat["ack"] as? NSDictionary {
                        if let lastAckedId = (ackDict["lastAckedMessage"] as? NSNumber)?.unsignedLongLongValue {
                            if let lastPartnerAckedId = (ackDict["lastPartnerAckedMessage"] as? NSNumber)?.unsignedLongLongValue {
                                if let lastReceivedId = (chat["lastReceivedMessage"] as? NSNumber)?.unsignedLongLongValue {
                                    if let receiverId = (chat["receiver"] as? NSNumber)?.unsignedLongLongValue {
                                        let chat = HLChat(receiverId: receiverId, lastReceivedMessageId: lastReceivedId, lastAckedMessageId: lastAckedId, lastPartnerAckedMessageId: lastPartnerAckedId)
                                        currentChats.append(chat)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            currentChats.sortInPlace()
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

            if let user = HLServer.getUserById(Int64(currentChats[indexPath.row].receiverId)) {

                cell.name.text = user.name
                cell.profilePicture.layer.masksToBounds = false
                cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.height/2
                cell.profilePicture.clipsToBounds = true
                cell.profilePicture.image = user.profilePicture
                cell.acceptButton.tag = indexPath.row
                cell.declineButton.tag = indexPath.row
                cell.declineButton.hidden = true
                cell.acceptButton.hidden = true

                let lastMessageURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent("\(user.userId).chat.last")

                if let lastMessage = NSKeyedUnarchiver.unarchiveObjectWithFile(lastMessageURL.path!) as? HLMessage {
                    cell.lastMessage.text = lastMessage.text

                    if UInt64(lastMessage.messageUUID!) < currentChats[indexPath.row].lastAckedMessageId {
                        cell.backgroundColor = UIColor.blueColor()
                    } else {
                        cell.backgroundColor = UIColor.clearColor()
                    }

                    if NSCalendar.currentCalendar().isDateInToday(lastMessage.sentTimestamp) {
                        timestampFormamter.timeStyle = .ShortStyle
                        timestampFormamter.dateStyle = .NoStyle
                    } else {
                        timestampFormamter.timeStyle = .NoStyle
                        timestampFormamter.dateStyle = .ShortStyle
                    }

                    cell.date.text = timestampFormamter.stringFromDate(lastMessage.sentTimestamp)
                }

                else {
                    cell.lastMessage.text = ""
                    cell.date.text = ""
                }
            }

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

        if HLServer.acceptRequestFromUser(acceptedUser) {
            print("Accepted request")
            refreshTableView()
        } else {
            print("Failed to accept request")
        }
    }
    @IBAction func decline(sender: UIButton) {

        if HLServer.deleteRequestFromUser(currentUser.pendingChats[sender.tag]) {

            sender.hidden = true
            let index = sender.tag
            let indexPath = NSIndexPath(forRow: index, inSection: 0)


            currentUser.pendingChats.removeAtIndex(index)

            if currentUser.pendingChats.count > 0 {
                converstationTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            } else {
                converstationTable.deleteSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
                converstationTable.reloadData()
            }
        }
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
                messageDetailViewController.user = HLServer.getUserById(Int64(currentChats[indexPath.row].receiverId))
                messageDetailViewController.recipientId = Int64(currentChats[indexPath.row].receiverId)
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
                if HLServer.deleteConversationWithUser(currentUser.usersChattedWith[indexPath.row]) {
                    currentUser.usersChattedWith.removeAtIndex(indexPath.row)
                } else {
                    print("Failed to delete chat")
                }
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