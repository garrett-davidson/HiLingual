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
    if let lhsMessage = NSKeyedUnarchiver.unarchiveObject(withFile: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(lhs.receiverId).chat.last").path) as? HLMessage {
        if let rhsMessage = NSKeyedUnarchiver.unarchiveObject(withFile: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(rhs.receiverId).chat.last").path) as? HLMessage {
            return lhsMessage.sentTimestamp == rhsMessage.sentTimestamp
        }
    }
    return false
}

func < (lhs: HLChat, rhs: HLChat) -> Bool {
    if let lhsMessage = NSKeyedUnarchiver.unarchiveObject(withFile: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(lhs.receiverId).chat.last").path) as? HLMessage {
        if let rhsMessage = NSKeyedUnarchiver.unarchiveObject(withFile: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(rhs.receiverId).chat.last").path) as? HLMessage {
            return lhsMessage.sentTimestamp > rhsMessage.sentTimestamp
        }
        return true
    }
    return false
}

func >(lhs: HLChat, rhs: HLChat) -> Bool {
    if let lhsMessage = NSKeyedUnarchiver.unarchiveObject(withFile: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(lhs.receiverId).chat.last").path) as? HLMessage {
        if let rhsMessage = NSKeyedUnarchiver.unarchiveObject(withFile: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(rhs.receiverId).chat.last").path) as? HLMessage {
            return lhsMessage.sentTimestamp < rhsMessage.sentTimestamp
        }
        return false
    }
    return true
}

class MessagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var converstationTable: UITableView!
    var messages = [HLMessage]()

    let currentUser = HLUser.getCurrentUser()
    let timestampFormamter = DateFormatter()

    var currentChats = [HLChat]()

    var hasPendingChats: Bool {
        get {
            return currentUser!.pendingChats.count > 0
        }
    }

    override func viewDidLoad() {
        self.tabBarController?.tabBar.isHidden = false
        // grab any requests from server
        //navigationItem.leftBarButtonItem = editButtonItem()
        //check to see if accept and decline need to be there
        //conversations = getCurrentUser().chattedWith
        //for (getCurrentUser().chattedWith.count)) hiddenButtons+= true
        // hiddenButtons = getCurrentUser().chattedWith
        //grab users.ChattedWith to fill users conversations list

        timestampFormamter.locale = NSLocale.autoupdatingCurrent
        timestampFormamter.dateStyle = .short
        timestampFormamter.timeStyle = .short
        timestampFormamter.doesRelativeDateFormatting = true
        NotificationCenter.default.addObserver(self, selector: #selector(MessagesViewController.refreshTableView), name: NSNotification.Name(rawValue: AppDelegate.NotificationTypes.newMessage.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MessagesViewController.refreshTableView), name: NSNotification.Name(rawValue: AppDelegate.NotificationTypes.requestReceived.rawValue), object: nil)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return hasPendingChats ? 2 : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return hasPendingChats ? currentUser!.pendingChats.count : currentChats.count

        case 1:
            return currentChats.count
        default:
            print("Invalid section number")
            return 0
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController!.tabBar.isHidden = false
    }

    override func viewDidAppear(_ animated: Bool) {
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
                        if let lastAckedId = (ackDict["lastAckedMessage"] as? NSNumber)?.uint64Value {
                            if let lastPartnerAckedId = (ackDict["lastPartnerAckedMessage"] as? NSNumber)?.uint64Value {
                                if let lastReceivedId = (chat["lastReceivedMessage"] as? NSNumber)?.uint64Value {
                                    if let receiverId = (chat["receiver"] as? NSNumber)?.uint64Value {
                                        let chat = HLChat(receiverId: receiverId, lastReceivedMessageId: lastReceivedId, lastAckedMessageId: lastAckedId, lastPartnerAckedMessageId: lastPartnerAckedId)
                                        currentChats.append(chat)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            currentChats.sort()
            converstationTable.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if numberOfSections(in: tableView) < 2 {
            return nil
        }

        if section == 1 || section == 0 && !hasPendingChats {
            return "Current chats".localized
        } else {
            return "Pending chats".localized
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //Accepted chat
        if (indexPath as NSIndexPath).section == 1 || (indexPath as NSIndexPath).section == 0 && !hasPendingChats {
            let cellIdentity = "ConversationTableViewCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentity, for: indexPath) as! ConversationTableViewCell

            if let user = HLServer.getUserById(Int64(currentChats[(indexPath as NSIndexPath).row].receiverId)) {
                cell.haveMessageDot.layer.cornerRadius = cell.haveMessageDot.frame.height/2 + 1
                cell.haveMessageDot.layer.borderWidth = 0.5
                cell.haveMessageDot.isHidden = true
                cell.name.text = user.name
                cell.loadingImageView.layer.masksToBounds = false
                cell.loadingImageView.layer.cornerRadius = cell.loadingImageView.frame.height/2
                cell.loadingImageView.clipsToBounds = true
                if user.profilePicture != nil {
                    cell.loadingImageView.image = user.profilePicture
                } else {
                    HLServer.loadImageWithURL(user.profilePictureURL!, forCell: cell, inTableView: tableView, atIndexPath: indexPath, withCallback: { (image) in
                        user.profilePicture = image
                    })
                }

                cell.acceptButton.tag = (indexPath as NSIndexPath).row
                cell.declineButton.tag = (indexPath as NSIndexPath).row
                cell.declineButton.isHidden = true
                cell.acceptButton.isHidden = true

                let lastMessageURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(user.userId).chat.last")

                if let lastMessage = NSKeyedUnarchiver.unarchiveObject(withFile: lastMessageURL.path) as? HLMessage {
                    if lastMessage.text != "" {
                        cell.lastMessage.font = UIFont.systemFont(ofSize: 13)
                        cell.lastMessage.text = lastMessage.text
                    } else if lastMessage.audioURL != nil {
                        cell.lastMessage.font = UIFont(name: "FontAwesome", size: 24)
                        cell.lastMessage.text = "\u{f130}"
                    } else if lastMessage.pictureURL != nil {
                        cell.lastMessage.font = UIFont(name: "FontAwesome", size: 24)
                        cell.lastMessage.text = "\u{f083}"
                    }

                    if UInt64(lastMessage.messageUUID!) < currentChats[(indexPath as NSIndexPath).row].lastAckedMessageId {
                        cell.backgroundColor = UIColor.blue
                    } else {
                        cell.backgroundColor = UIColor.clear
                    }

                    if NSCalendar.current.isDateInToday(lastMessage.sentTimestamp) {
                        timestampFormamter.timeStyle = .short
                        timestampFormamter.dateStyle = .none
                    } else {
                        timestampFormamter.timeStyle = .none
                        timestampFormamter.dateStyle = .short
                    }

                    cell.date.text = timestampFormamter.string(from: lastMessage.sentTimestamp)
                } else {
                    cell.lastMessage.text = ""
                    cell.date.text = ""
                }
            }

            return cell
        }

        //Pending chats
        else {
            let cellIdentity = "ConversationTableViewCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentity, for: indexPath) as! ConversationTableViewCell
            //Should it be displayname or name?
            let user = HLServer.getUserById((currentUser?.pendingChats[(indexPath as NSIndexPath).row])!)!
            cell.name.text = user.name
            cell.haveMessageDot.layer.cornerRadius = cell.haveMessageDot.frame.height/2 + 1
            cell.haveMessageDot.layer.borderWidth = 0.5
            cell.haveMessageDot.isHidden = true
            cell.loadingImageView.layer.masksToBounds = false
            cell.loadingImageView.layer.cornerRadius = cell.loadingImageView.frame.height/2
            cell.loadingImageView.clipsToBounds = true
            cell.loadingImageView.image = user.profilePicture
            cell.acceptButton.tag = (indexPath as NSIndexPath).row
            cell.declineButton.tag = (indexPath as NSIndexPath).row
            cell.declineButton.isHidden = false
            cell.acceptButton.isHidden = false
            //Mark: Fills the view
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.date.text = ""
            cell.lastMessage.text = ""
            return cell
        }
    }

    @IBAction func accept(_ sender: UIButton) {
        //send accept to server
        let index = sender.tag

        let acceptedUser = currentUser?.pendingChats[index]

        if HLServer.acceptRequestFromUser(acceptedUser!) {
            print("Accepted request")
            refreshTableView()
        } else {
            print("Failed to accept request")
        }
    }
    @IBAction func decline(_ sender: UIButton) {

        if HLServer.deleteRequestFromUser((currentUser?.pendingChats[sender.tag])!) {

            sender.isHidden = true
            let index = sender.tag
            let indexPath = IndexPath(row: index, section: 0)
            currentUser?.pendingChats.remove(at: index)

            if (currentUser?.pendingChats.count)! > 0 {
                converstationTable.deleteRows(at: [indexPath], with: .automatic)
            } else {
                converstationTable.deleteSections(IndexSet(integer: 0), with: .automatic)
                converstationTable.reloadData()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToProfile"{
            let messageDetailViewController = segue.destination as! DetailViewController
            if let selectedMessageCell = sender as? ConversationTableViewCell {
                let indexPath = converstationTable.indexPath(for: selectedMessageCell)!
                converstationTable.deselectRow(at: indexPath, animated: false)
                messageDetailViewController.user = HLServer.getUserById((currentUser?.pendingChats[(indexPath as NSIndexPath).row])!)
                //Once messages is complete I can use that

            }

        } else if segue.identifier == "SegueToMessages" {
            let messageDetailViewController = segue.destination as! ChatViewController
            if let selectedMessageCell = sender as? ConversationTableViewCell {
                let indexPath = converstationTable.indexPath(for: selectedMessageCell)!
                converstationTable.deselectRow(at: indexPath, animated: false)
                messageDetailViewController.user = HLServer.getUserById(Int64(currentChats[(indexPath as NSIndexPath).row].receiverId))
                messageDetailViewController.recipientId = Int64(currentChats[(indexPath as NSIndexPath).row].receiverId)
                //Once messages is complete I can use that

            }
        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = converstationTable.cellForRow(at: indexPath)
        if (indexPath as NSIndexPath).section == 1 || (indexPath as NSIndexPath).section == 0 && !hasPendingChats {
            self.performSegue(withIdentifier: "SegueToMessages", sender: cell)
            print("ACCEPTED")
        } else {

            self.performSegue(withIdentifier: "SegueToProfile", sender: cell)
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
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source

            if (indexPath as NSIndexPath).section == 1 || (indexPath as NSIndexPath).section == 0 && !hasPendingChats {
                if HLServer.deleteConversationWithUser(Int64(currentChats[(indexPath as NSIndexPath).row].receiverId)) {
                    currentChats.remove(at: (indexPath as NSIndexPath).row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                } else {
                    print("Failed to delete chat")
                }
            } else {
                if let cell = tableView.cellForRow(at: indexPath) as? ConversationTableViewCell {
                    decline(cell.declineButton)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
}
