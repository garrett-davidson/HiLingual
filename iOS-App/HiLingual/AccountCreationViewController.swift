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

    override func viewWillAppear(animated: Bool) {
        if user == nil {
            user = HLUser.getCurrentUser()
        }
        editProfileView.user = user
        editProfileView.ageLabel.userInteractionEnabled = true
    }

    @IBAction func saveUser(sender: AnyObject) {
        //Runs when done button is pressed
        //Create a new HLUser user with the information from this view
        //Be sure to call user.save() !!

        editProfileView.user.save()

        performSegueWithIdentifier("DoneEditing", sender: self)
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
