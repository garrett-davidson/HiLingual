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
    var spot = 0

    @IBOutlet weak var profileView: ProfileView!

    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        if ((hiddenName) != nil && hiddenName == true) {
            self.title = user.name
            profileView.hiddenName = false
        } else {
            self.title = user.displayName

        }
        for i in 0..<HLUser.getCurrentUser().blockedUsers.count {
            if HLUser.getCurrentUser().blockedUsers[i] == user.userId {
                self.navigationItem.rightBarButtonItem?.title = "Unblock".localized
                spot = i
            }

        }
        print(user.displayName)
        profileView.user = user

    }
    @IBAction func tapReport(_ sender: AnyObject) {
        if(self.navigationItem.rightBarButtonItem?.title == "Report/Block".localized) {
            print("here")
            let alert = UIAlertController(title: "Reason for reporting?", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addTextField { (textField: UITextField!) -> Void in
            }
            let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel) { (action) in
                return
            }
            alert.addAction(cancelAction)
            let reportAction = UIAlertAction(title: "Report".localized, style: .default) { (action) in
                let input = alert.textFields![0]
                self.navigationItem.rightBarButtonItem?.title = "Unblock".localized
                HLServer.blockUser(self.user.userId)
                HLServer.reportUser(self.user.userId, reason: input.text!)
                HLUser.getCurrentUser().blockedUsers = [self.user.userId]
                print(input.text)
            }
            alert.addAction(reportAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: nil, message: "Are you sure?".localized, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "No".localized, style: .cancel) { (action) in
                return
            }
            alertController.addAction(cancelAction)
            let unblockAction = UIAlertAction(title: "Yes".localized, style: .default) { (action) in
                self.navigationItem.rightBarButtonItem?.title = "Report/Block".localized
                HLServer.unblockUser(self.user.userId)
                HLUser.getCurrentUser().blockedUsers.remove(at: self.spot)
            }
            alertController.addAction(unblockAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
