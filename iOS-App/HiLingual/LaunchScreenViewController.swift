//
//  LaunchScreenViewController.swift
//  HiLingual
//
//  Created by Garrett Davidson on 2/14/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation
import UIKit

//Displays a welcome message when the user first install the app
//Check to make sure the user's session is still valid
//Shows Log In and Sign Up buttons 
class LaunchScreenViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInDelegate, GIDSignInUIDelegate {
    @IBOutlet weak var googleSignInButton: GIDSignInButton!

    override func viewDidLoad() {
//        GIDSignIn.sharedInstance().signOut()
    }

    override func viewDidAppear(animated:Bool) {
        super.viewDidAppear(animated);


        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signInSilently()

        checkSignedIn()
    }

    func checkSignedIn() {

        guard FBSDKAccessToken.currentAccessToken() != nil || GIDSignIn.sharedInstance().currentUser != nil else {
            print("Need to log in")
            let loginButton = FBSDKLoginButton()
            loginButton.loginBehavior = FBSDKLoginBehavior.SystemAccount
            loginButton.readPermissions = ["public_profile", "user_about_me", "user_birthday", "user_likes"]
            loginButton.center = self.view.center
            loginButton.delegate = self
            self.view.addSubview(loginButton)
            return
        }

        if let user = HLUser.getCurrentUser() {
            // if let _ = user.getSession() {
            self.performSegueWithIdentifier("previousLogin", sender: self)
            // }
        }

        print("ViewDidLoadHere")
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "user_about_me", "user_birthday", "user_likes"]
        loginButton.center = self.view.center
        loginButton.delegate = self
        self.view.addSubview(loginButton)
    }

    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        checkSignedIn()
    }

    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError?) {
        guard error == nil else {
            //If you know that an optional is not nil, you should force unwrap it when you print it
            print(error!.localizedDescription)
            return
        }
        guard !result.isCancelled else {
            print("User cancelled login")
            return
        }
        print("Login complete.")
        getUserInfo()

        if (HLServer.authenticate(authority: .Facebook, authorityAccountId: FBSDKAccessToken.currentAccessToken().userID, authorityToken: FBSDKAccessToken.currentAccessToken().tokenString, deviceToken: (UIApplication.sharedApplication().delegate as! AppDelegate).apnsToken)) {
            if HLUser.getCurrentUser().gender == Gender.Not_Set {
                //Initial register
                //Because don't allow NotSpecified as an option
                self.populateUserFromFacebook(HLUser.getCurrentUser())

            } else {
                //Logging in to existing user
                self.performSegueWithIdentifier("previousLogin", sender: nil)
            }
        }
    }

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    
    func getUserInfo()
    {
        let fields = ["fields": "id,name,email"]
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: fields)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            guard error == nil else {
                print("Error: \(error!)")
                return
            }
            print("Facebook user id: \(result.valueForKey("id") as! String)")
            print("Facebook acess token: " + FBSDKAccessToken.currentAccessToken().tokenString)
        })
    }

    func signIn(signIn: GIDSignIn!, dismissViewController viewController: UIViewController!) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
//        requestFromServer("https://gethilingual.com/api/auth/register", authority: "GOOGLE", signIn: signIn)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            while GIDSignIn.sharedInstance().currentUser == nil {
                sleep(1)
            }
            if (HLServer.authenticate(authority: .Google, authorityAccountId: signIn.currentUser.userID, authorityToken: signIn.currentUser.authentication.idToken, deviceToken: (UIApplication.sharedApplication().delegate as! AppDelegate).apnsToken)) {
                if HLUser.getCurrentUser().gender == Gender.Not_Set {
                    //Initial register
                    //Because don't allow NotSpecified as an option
                    self.populateUserFromGoogle(user: HLUser.getCurrentUser())
                    self.performSegueWithIdentifier("InitialLogin", sender: nil)

                } else {
                    //Logging in to existing user
                    self.performSegueWithIdentifier("previousLogin", sender: nil)
                }
            }
        })
    }

    func populateUserFromFacebook(user: HLUser) {
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
                bio = "Bio".localized
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
                    gender = .Not_Set
                }
            }
            else {
                gender = .Not_Set
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

            user.name = firstName + " " + lastName
            user.displayName = firstName+lastName
            user.knownLanguages = languages
            user.bio = bio
            user.gender = gender
            user.birthdate = birthday
            user.profilePicture = picture

            dispatch_async(dispatch_get_main_queue(), {
                self.performSegueWithIdentifier("InitialLogin", sender: nil)

            })
        })
    }

    func populateUserFromGoogle(user user: HLUser) {
        //TODO: Fix this 💩
        //Lazy way to fix race condition
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

        user.name = userName
        user.displayName = userName
        user.profilePicture = picture

        user.save(toServer: false)
    }

    func didRegisterWithSession(session: HLUserSession) {
        self.performSegueWithIdentifier("InitialLogin", sender: session)
    }
    func didLoginWithSession(session: HLUserSession) {
        HLServer.getUserById(session.userId, session: session)?.save(session)
        HLUser.getCurrentUser().setSession(session)
        HLUser.getCurrentUser().save()
        self.performSegueWithIdentifier("previousLogin", sender: session)
    }
    func requestFromServer(url: String,authority: String, signIn: GIDSignIn!){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {

            var response: NSURLResponse?
            var bodyDict = [String: String]()
            
            if authority == "FACEBOOK" {
                bodyDict = ["authority": "FACEBOOK",
                                "authorityAccountId": FBSDKAccessToken.currentAccessToken().userID,
                                "authorityToken": FBSDKAccessToken.currentAccessToken().tokenString]
            }
            if authority == "GOOGLE" {
                    while GIDSignIn.sharedInstance().currentUser == nil {
                        sleep(1)
                    }
                    
                    bodyDict = ["authority": "GOOGLE",
                                    "authorityAccountId": signIn.currentUser.userID,
                                    "authorityToken": signIn.currentUser.authentication.idToken]            
            }
            
            let request = NSMutableURLRequest(URL: NSURL(string: url)!)
            request.allHTTPHeaderFields = ["Content-Type": "application/json"]
            request.HTTPMethod = "POST"
            
            
            if let deviceToken = (UIApplication.sharedApplication().delegate as? AppDelegate)?.apnsToken {
                bodyDict["deviceToken"] = deviceToken
            }
            
            
            
            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(NSDictionary(dictionary: bodyDict), options: NSJSONWritingOptions(rawValue: 0))
            
            if let returnedData = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: &response) {
                if let response2 = response as? NSHTTPURLResponse {
                    if response2.statusCode == 403 && url == "https://gethilingual.com/api/auth/register"  {
                        self.requestFromServer("https://gethilingual.com/api/auth/login", authority: authority, signIn: signIn)
                    }else{
                        print(returnedData)
                        if let returnString = NSString(data: returnedData, encoding: NSUTF8StringEncoding) {
                            print(returnString)
                            if let ret = (try? NSJSONSerialization.JSONObjectWithData(returnedData, options: NSJSONReadingOptions(rawValue: 0))) as? NSDictionary {
                                if url == "https://gethilingual.com/api/auth/register" {
//                                    self.didRegisterWithSession(HLUserSession(userId: Int64(ret["userId"] as! Int), sessionId: ret["sessionId"] as! String, authority: LoginAuthority(rawValue: authority)!,  authorityAccountId: bodyDict["authorityAccountId"]!, authorityToken: bodyDict["authorityToken"]!))
                                }else if  url == "https://gethilingual.com/api/auth/login"{
//                                    self.didLoginWithSession(HLUserSession(userId: Int64(ret["userId"] as! Int)))
                                }
                            } else {
                                print("Couldn't parse return value")
                            }
                        } else {
                            print("Returned data is not a string")
                        }
                    }
                }
            }
        
        })
    }
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let destNav = segue.destinationViewController as? UINavigationController {
//            if let dest = destNav.topViewController as? AccountCreationViewController {
//                if let session = sender as? HLUserSession {
//                    dest.session = session
//                }
//            }
//        }
//    }
}