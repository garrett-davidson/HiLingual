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


    @IBAction func tapEdit(_ sender: AnyObject) {
        if(editProfileView.isHidden == true) {
            editProfileView.isHidden = false
            profileView.isHidden = true
            self.navigationItem.rightBarButtonItem?.title = "Done".localized
        } else if(editProfileView.isValidUser()) {
            editProfileView.dismissKeyboard(self)
            editProfileView.dismissPickerView(self)
            editProfileView.user.save()
            editProfileView.isHidden = true
            profileView.isHidden = false
            self.navigationItem.rightBarButtonItem?.title = "Edit".localized
            editProfileView.user = HLUser.getCurrentUser()
            profileView.user = HLUser.getCurrentUser()
        }
    }

    @IBAction func showSettings(_ sender: AnyObject) {
        performSegue(withIdentifier: "SettingsSegue", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        editProfileView.user = HLUser.getCurrentUser()
        profileView.hiddenName = false
        profileView.user = HLUser.getCurrentUser()
        editProfileView.languageSelectionDelegate = self
    }

    func setNewSelectedLanguages(_ selectedLanguages: [Languages]) {
        self.editProfileView.updateSelectedLanguages(selectedLanguages)
    }

    func performLanguageSelectionSegue(_ selectedLanguages: [Languages]) {
        self.selectedLanguages = selectedLanguages
        self.performSegue(withIdentifier: "SelectLanguagesSegue", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destNav = segue.destination as? UINavigationController {
            if let dest = destNav.topViewController as? LanguageSelectionTableViewController {
                dest.delegate = self
                dest.selectedLanguages = self.selectedLanguages
            }
        }
    }
}
