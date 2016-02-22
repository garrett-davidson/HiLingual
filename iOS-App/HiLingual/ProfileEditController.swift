//
//  ProfileEditController.swift
//  HiLingual
//
//  Created by Riley Shaw on 2/22/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation
//Displays the current user's profile
//Facilitates editing of any aspect of the profile

class ProfileEditController: UIViewController {
    
    @IBOutlet weak var profileEdit: ProfileEdit!
    
    override func viewDidLoad() {
        profileEdit.user = HLUser.generateTestUser()
    }
}