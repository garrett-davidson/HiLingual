//
//  DetailViewController.swift
//  HiLingual
//
//  Created by Noah Maxey on 2/24/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var user: HLUser!
    var hiddenName: Bool!
    
    @IBOutlet weak var profileView: ProfileView!
    
    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        if ((hiddenName) != nil && hiddenName == true){
            self.title = user.name
            profileView.hiddenName = false
        }else {
            self.title = user.displayName
            
        }
        print(user.displayName)
        profileView.user = user
        
    }

}
