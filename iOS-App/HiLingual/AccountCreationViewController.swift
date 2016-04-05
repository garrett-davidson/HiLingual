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
    var session: HLUserSession?

    override func viewDidLoad() {
        editProfileView.languageSelectionDelegate = self

        switch session?.authority {
        case .None:
            break

        case .Some(.Facebook):
            loadFacebookData()

        case .Some(.Google):
            loadGoogleData()
        }
    }

    @IBAction func saveUser(sender: AnyObject) {
        //Runs when done button is pressed
        //Create a new HLUser user with the information from this view
        //Be sure to call user.save() !!

        if isValidUser(editProfileView.user) {

        editProfileView.user.setSession(session)
        editProfileView.user.userId = session!.userId
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

    func loadFacebookData() {
        let halfScreenWidth = Int(view.frame.size.width/2)
        let fields = ["fields": "bio,birthday,first_name,gender,languages,last_name,link,picture.width(\(halfScreenWidth)).height(\(halfScreenWidth))"];
        let request = FBSDKGraphRequest(graphPath: "me", parameters: fields)

        request.startWithCompletionHandler({ (connection, result, error) -> Void in
            guard error == nil else {
                print("Error: \(error!)")
                return
            }

            print("fetched user: \(result)")

            let bio: String
            let birthday: NSDate
            let firstName: String
            let gender: Gender
            var languages: [Languages]
            let lastName: String
            let picture: UIImage

            //Bio
            if let bioString = result.valueForKey("bio") as? String {
                bio = bioString
            }
            else {
                bio = "Bio"
            }

            //Birthday
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            if let birthdayString = result.valueForKey("birthday") as? String {
                if let fbBirthday = formatter.dateFromString(birthdayString) {
                    birthday = fbBirthday
                }
                else {
                    birthday = NSDate()
                }
            }
            else {
                birthday = NSDate()
            }


            //First name
            if let fbFirstName = result.valueForKey("first_name") as? String {
                firstName = fbFirstName
            }
            else {
                firstName = ""
            }

            //Gender
            if let genderString = result.valueForKey("gender") as? String {
                switch (genderString) {
                case "male":
                    gender = .Male

                case "female":
                    gender = .Female

                default:
                    gender = .NotSpecified
                }
            }
            else {
                gender = .NotSpecified
            }

            //Languages
            languages = []
            if let languageStrings = result.valueForKey("languages")?.valueForKey("name") as? [String] {
                for langString in languageStrings {
                    if let lang = Languages(rawValue: langString) {
                        languages.append(lang)
                    }
                }
            }

            //Last name
            if let fbLastName = result.valueForKey("last_name") as? String {
                lastName = fbLastName
            }
            else {
                lastName = ""
            }

            //Profile picture
            //Written this way for debug purposes
            //I don't think this can be nil, so we're leaving it like this for now
            let profilePictureURLString = result.valueForKey("picture")?.valueForKey("data")?.valueForKey("url") as! String
                let profilePictureURL = NSURL(string: profilePictureURLString)!
                let profilePictureData = NSData(contentsOfURL: profilePictureURL)!
                picture = UIImage(data: profilePictureData)!

            let user = HLUser(userId: 5, name: firstName + " " + lastName, displayName: firstName+lastName, knownLanguages: languages, learningLanguages: [], bio: bio, gender: gender, birthdate: birthday, profilePicture: picture)
            self.editProfileView.user = user
        })
    }

    func loadGoogleData() {

        //TODO: Fix this 💩
        //Lazy way to fix race condition
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            while GIDSignIn.sharedInstance().currentUser == nil {
                sleep(1)
            }

            let googleUser = GIDSignIn.sharedInstance().currentUser

            let picture: UIImage?
            let userName = googleUser.profile.name

            if googleUser.profile.hasImage {
                picture = UIImage(data: NSData(contentsOfURL: googleUser.profile.imageURLWithDimension(100))!)
            }
            else {
                picture = nil
            }

            let user = HLUser(userId: 1, name: userName, displayName: userName, knownLanguages: nil, learningLanguages: nil, bio: nil, gender: nil, birthdate: nil, profilePicture: picture)
            self.editProfileView.user = user
        })
    }
}