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
    }

    @IBAction func saveUser(sender: AnyObject) {
        //Runs when done button is pressed
        //Create a new HLUser user with the information from this view
        //Be sure to call user.save() !!

        if isValidUser(editProfileView.user) {
            editProfileView.user.save()

            performSegueWithIdentifier("DoneEditing", sender: self)
        }
    }

    enum UserValidationError: ErrorType {
        case userId, name, displayName, knownLanguages, learningLanguages, bio, gender, birthdata, profilePicture
    }

    func isValidUser(user: HLUser, showDialogOnInvalid: Bool=false) -> Bool {

        let errorMessage: String

        do {

            func validateUser() throws {
                //userId
                if user.userId < 1 {
                    throw UserValidationError.userId
                }

                if user.name == nil || user.name == "" {
                    throw UserValidationError.name
                }

                //TODO: Check unique
                if user.displayName == nil || user.displayName == "" {
                    throw UserValidationError.displayName
                }
            }

            try validateUser()
        }

        catch UserValidationError.userId {
            errorMessage = "Invalid user id"
        }

        catch UserValidationError.name {
        }

        catch UserValidationError.displayName {

        }

        catch {

        }

            
            
            return true
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