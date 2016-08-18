//
//  AccountCreationViewController.swift
//  HiLingual
//
//  Created by Garrett Davidson on 2/24/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation

class AccountCreationViewController: UIViewController, LanguageSelectionDelegate {


    @IBOutlet weak var editProfileView: EditProfileView!

    var user: HLUser?
    var selectedLanguages: [Languages]?

    override func viewDidLoad() {
        editProfileView.languageSelectionDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        if user == nil {
            user = HLUser.getCurrentUser()
        }
        editProfileView.user = user
        editProfileView.ageLabel.isUserInteractionEnabled = true
    }

    @IBAction func saveUser(_ sender: AnyObject) {
        //Runs when done button is pressed
        //Create a new HLUser user with the information from this view
        //Be sure to call user.save() !!

        editProfileView.user.save()

        performSegue(withIdentifier: "DoneEditing", sender: self)
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
