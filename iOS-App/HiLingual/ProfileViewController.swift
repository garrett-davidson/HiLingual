//
//  ProfileViewController.swift
//  HiLingual
//
//  Created by Garrett Davidson on 2/14/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation
import UIKit

//Displays the current user's profile
//Facilitates editing of any aspect of the profile

class ProfileViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate
{

    @IBOutlet var editProfileView: EditProfileView!
    @IBOutlet var profileView: ProfileView!
    var user: HLUser?
    @IBAction func tapEdit(sender: AnyObject) {
        if(editProfileView.hidden == true){
            editProfileView.hidden = false
            profileView.hidden = true
            self.navigationItem.rightBarButtonItem?.title = "Done"
        }else{
            editProfileView.user.save()
            editProfileView.hidden = true
            profileView.hidden = false
            self.navigationItem.rightBarButtonItem?.title = "Edit"
        }
        
    
    }
    
    @IBAction func showSettings(sender: AnyObject) {
        performSegueWithIdentifier("SettingsSegue", sender: self)
    }
    override func viewDidLoad() {
        editProfileView.user = HLUser.generateTestUser();
        profileView.user = HLUser.generateTestUser();
    }

}