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

class ProfileViewController: UIViewController {

    @IBOutlet weak var editProfileView: EditProfileView!
    
    var user: HLUser?
    
    override func viewDidLoad() {
        //editProfileView.user = HLUser.getCurrentUser();
        editProfileView.user = HLUser.generateTestUser();
    }

}