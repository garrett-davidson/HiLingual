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
    override func viewDidLoad() {
        loadSamples();
        //check to see if accept and decline need to be there
        
        
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return converstaions.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
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
        let index = sender.tag
        converstaions.removeAtIndex(index)
        //send decline to server
    }
    
    func loadSamples(){
        converstaions += [HLUser.generateTestUser(),HLUser.generateTestUser(),HLUser.generateTestUser() ]
    
    }
    
    
}