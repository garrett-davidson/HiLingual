//
//  AccountCreationViewController.swift
//  HiLingual
//
//  Created by Garrett Davidson on 2/24/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation

class AccountCreationViewController: UIViewController {

    @IBOutlet weak var profileView: ProfileView!

    override func viewDidLoad() {
        profileView.user = HLUser.generateTestUser()
    }
    @IBAction func saveUser(sender: AnyObject) {
        //Runs when done button is pressed
        //Create a new HLUser user with the information from this view
        //Be sure to call user.save() !!

        performSegueWithIdentifier("DoneEditing", sender: self)
    }
}