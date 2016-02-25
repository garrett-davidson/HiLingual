//
//  AccountCreationViewController.swift
//  HiLingual
//
//  Created by Garrett Davidson on 2/24/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation

class AccountCreationViewController: UIViewController {

    @IBOutlet weak var profileView: ProfileView!

    var user: HLUser?

    override func viewDidLoad() {
        profileView.user = HLUser.generateTestUser()
        loadFacebookData()
        loadGoogleData()
    }

    @IBAction func saveUser(sender: AnyObject) {
        //Runs when done button is pressed
        //Create a new HLUser user with the information from this view
        //Be sure to call user.save() !!

        performSegueWithIdentifier("DoneEditing", sender: self)
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
                bio = ""
            }

            //Birthday
            //This force unwrapping is bad practice, but we'll fix it later 😅
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            birthday = formatter.dateFromString(result.valueForKey("birthday") as! String)!

            //First name
            firstName = result.valueForKey("first_name") as! String

            //Gender
            let genderString = result.valueForKey("gender") as! String
            switch (genderString) {
            case "male":
                gender = .Male

            case "female":
                gender = .Female

            default:
                gender = .NotSpecified
            }

            //Languages
            languages = []
            if let languageStrings = result.valueForKey("languages")!.valueForKey("name") as? [String] {
                for langString in languageStrings {
                    if let lang = Languages(rawValue: langString) {
                        languages.append(lang)
                    }
                }
            }

            //Last name
            lastName = result.valueForKey("last_name") as! String

            //Profile picture
            //Written this way for debug purposes
            let profilePictureURLString = result.valueForKey("picture")!.valueForKey("data")!.valueForKey("url") as! String
            let profilePictureURL = NSURL(string: profilePictureURLString)!
            let profilePictureData = NSData(contentsOfURL: profilePictureURL)!
            picture = UIImage(data: profilePictureData)!

            let user = HLUser(UUID: "", name: firstName + " " + lastName, displayName: firstName+lastName, knownLanguages: languages, learningLanguages: [], bio: bio, gender: gender, birthdate: birthday, profilePicture: picture)
            self.profileView.user = user
        })
    }

    func loadGoogleData() {

    }
}