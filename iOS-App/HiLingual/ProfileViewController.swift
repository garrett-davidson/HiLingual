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

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LanguageSelectionDelegate {

    @IBOutlet var editProfileView: EditProfileView!
    @IBOutlet var profileView: ProfileView!

    var user: HLUser?
    var selectedLanguages: [Languages]?


    @IBAction func tapEdit(sender: AnyObject) {
        if(editProfileView.hidden == true) {
            editProfileView.hidden = false
            profileView.hidden = true
            self.navigationItem.rightBarButtonItem?.title = "Done".localized
        } else if(editProfileView.isValidUser()) {
            editProfileView.dismissKeyboard(self)
            editProfileView.dismissPickerView(self)
            editProfileView.user.save()
            editProfileView.hidden = true
            profileView.hidden = false
            self.navigationItem.rightBarButtonItem?.title = "Edit".localized
            editProfileView.user = HLUser.getCurrentUser()
            profileView.user = HLUser.getCurrentUser()
        }
    }

    @IBAction func showSettings(sender: AnyObject) {
        performSegueWithIdentifier("SettingsSegue", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        editProfileView.user = HLUser.getCurrentUser()
        profileView.hiddenName = false
        profileView.user = HLUser.getCurrentUser()
        editProfileView.languageSelectionDelegate = self
    }

    func setNewSelectedLanguages(selectedLanguages: [Languages]) {
        self.editProfileView.updateSelectedLanguages(selectedLanguages)
    }

    func performLanguageSelectionSegue(selectedLanguages: [Languages]) {
        self.selectedLanguages = selectedLanguages
        self.performSegueWithIdentifier("SelectLanguagesSegue", sender: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destNav = segue.destinationViewController as? UINavigationController {
            if let dest = destNav.topViewController as? LanguageSelectionTableViewController {
                dest.delegate = self
                dest.selectedLanguages = self.selectedLanguages
            }
        }
    }
}
