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
    var message: String?
    var user: HLUser!
    @IBOutlet weak var detailsProfile: UIBarButtonItem!

    
    override func viewDidLoad() {
        self.title = user.name
        print(user.name)
    }
    
    @IBAction func details(sender: AnyObject) {
        //load user profile
        
    }
}