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
        } else {
            self.title = user.displayName
            
        }
        print(user.displayName)
        profileView.user = user
        
    }
    @IBAction func tapReport(sender: AnyObject) {
        if(self.navigationItem.rightBarButtonItem?.title == "Report/Block".localized){
            print("here")
            let alert = UIAlertController(title: "Reason for reporting?", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addTextFieldWithConfigurationHandler { (textField : UITextField!) -> Void in
            }
            let cancelAction = UIAlertAction(title: "Cancel".localized, style: .Cancel) { (action) in
                return
            }
            alert.addAction(cancelAction)
            let reportAction = UIAlertAction(title: "Report".localized, style: .Default) { (action) in
                let input = alert.textFields![0]
                self.navigationItem.rightBarButtonItem?.title = "Unblock".localized
                HLServer.blockUser(self.user.userId)
                HLServer.reportUser(self.user.userId, reason: input.text!)
                print(input.text)
            }
            alert.addAction(reportAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            let alertController = UIAlertController(title: nil, message: "Are you sure?".localized, preferredStyle: .ActionSheet)
            let cancelAction = UIAlertAction(title: "No".localized, style: .Cancel) { (action) in
                return
            }
            alertController.addAction(cancelAction)
            let unblockAction = UIAlertAction(title: "Yes".localized, style: .Default) { (action) in
                self.navigationItem.rightBarButtonItem?.title = "Report/Block".localized
                HLServer.unblockUser(self.user.userId)
            }
            alertController.addAction(unblockAction)
        }
    }

    
    

}
