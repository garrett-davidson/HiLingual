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
    @IBOutlet weak var test: UILabel!
    
    override func viewDidLoad() {
        test.text = message
    }
}