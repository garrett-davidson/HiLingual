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

class ChatViewController: UIViewController {
    var messageHidden: Bool!
    var user: HLUser!
    @IBOutlet weak var detailsProfile: UIBarButtonItem!

    @IBOutlet weak var userCanMessageLabel: UILabel!
    
    override func viewDidLoad() {
        
        if((messageHidden) != nil && messageHidden == true){
            self.title = user.name
        }else{
            self.title = user.displayName
        }
        userCanMessageLabel.hidden = messageHidden
        print(user.name)
    }
    
    @IBAction func details(sender: AnyObject) {
        //load user profile
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "detailsSegue"{
            let messageDetailViewController = segue.destinationViewController as! DetailViewController
            messageDetailViewController.user = user
            
        }

    }
}