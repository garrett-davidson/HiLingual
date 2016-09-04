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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)


        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signInSilently()

        checkSignedIn()
    }

    func checkSignedIn() {

        guard FBSDKAccessToken.current() != nil || GIDSignIn.sharedInstance().currentUser != nil else {
            print("Need to log in")
            let loginButton = FBSDKLoginButton()
            loginButton.loginBehavior = FBSDKLoginBehavior.systemAccount
            loginButton.readPermissions = ["public_profile", "user_about_me", "user_birthday", "user_likes"]
            loginButton.center = self.view.center
            loginButton.delegate = self
            self.view.addSubview(loginButton)
            return
        }

        //TODO: Should this be _?
        if let _ = HLUser.getCurrentUser() {
            // if let _ = user.getSession() {
            self.performSegue(withIdentifier: "previousLogin", sender: self)
            // }
        }

        print("ViewDidLoadHere")
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "user_about_me", "user_birthday", "user_likes"]
        loginButton.center = self.view.center
        loginButton.delegate = self
        self.view.addSubview(loginButton)
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        checkSignedIn()
    }

    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
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

        if (HLServer.authenticate(authority: .Facebook, authorityAccountId: FBSDKAccessToken.current().userID, authorityToken: FBSDKAccessToken.current().tokenString, deviceToken: (UIApplication.shared.delegate as! AppDelegate).apnsToken)) {
            if HLUser.getCurrentUser().gender == Gender.not_Set {
                //Initial register
                //Because don't allow NotSpecified as an option
                self.populateUserFromFacebook(HLUser.getCurrentUser())

            } else {
                //Logging in to existing user
                self.performSegue(withIdentifier: "previousLogin", sender: nil)
            }
        }
    }

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }


    func getUserInfo() {
        let fields = ["fields": "id,name,email"]
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: fields)
        graphRequest?.start(completionHandler: { (connection, result, error) -> Void in
            guard error == nil else {
                print("Error: \(error!)")
                return
            }
            guard let result = result as? NSDictionary else {
                return
            }

            print("Facebook user id: \(result.value(forKey: "id") as! String)")
            print("Facebook acess token: " + FBSDKAccessToken.current().tokenString)
        })
    }

    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        viewController.dismiss(animated: true, completion: nil)
//        requestFromServer("https://gethilingual.com/api/auth/register", authority: "GOOGLE", signIn: signIn)
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            while GIDSignIn.sharedInstance().currentUser == nil {
                sleep(1)
            }
            if (HLServer.authenticate(authority: .Google, authorityAccountId: signIn.currentUser.userID, authorityToken: signIn.currentUser.authentication.idToken, deviceToken: (UIApplication.shared.delegate as! AppDelegate).apnsToken)) {
                if HLUser.getCurrentUser().gender == Gender.not_Set {
                    //Initial register
                    //Because don't allow NotSpecified as an option
                    self.populateUserFromGoogle(user: HLUser.getCurrentUser())
                    self.performSegue(withIdentifier: "InitialLogin", sender: nil)

                } else {
                    //Logging in to existing user
                    self.performSegue(withIdentifier: "previousLogin", sender: nil)
                }
            }
        })
    }

    func populateUserFromFacebook(_ user: HLUser) {
        let halfScreenWidth = Int(view.frame.size.width/2)
        let fields = ["fields": "bio,birthday,first_name,gender,languages,last_name,link,picture.width(\(halfScreenWidth)).height(\(halfScreenWidth))"]
        let request = FBSDKGraphRequest(graphPath: "me", parameters: fields)

        request?.start(completionHandler: { (connection, result, error) -> Void in
            guard error == nil else {
                print("Error: \(error!)")
                return
            }

            guard let result = result as? NSDictionary else {
                return
            }

            print("fetched user: \(result)")

            let bio: String
            let birthday: Date
            let firstName: String
            let gender: Gender
            var languages: [Languages]
            let lastName: String
            var picture: UIImage?

            //Bio
            if let bioString = result.value(forKey: "bio") as? String {
                bio = bioString
            } else {
                bio = "Bio".localized
            }

            //Birthday
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            if let birthdayString = result.value(forKey: "birthday") as? String {
                if let fbBirthday = formatter.date(from: birthdayString) {
                    birthday = fbBirthday
                } else {
                    birthday = Date()
                }
            } else {
                birthday = Date()
            }


            //First name
            if let fbFirstName = result.value(forKey: "first_name") as? String {
                firstName = fbFirstName
            } else {
                firstName = ""
            }

            //Gender
            if let genderString = result.value(forKey: "gender") as? String {
                switch (genderString) {
                case "male":
                    gender = .male

                case "female":
                    gender = .female

                default:
                    gender = .not_Set
                }
            } else {
                gender = .not_Set
            }

            //Languages
            languages = []
            if let languagesArray = result.value(forKey: "languages") as? NSDictionary {
                if let languageStrings = languagesArray.value(forKey: "name") as? [String] {
                    for langString in languageStrings {
                        if let lang = Languages(rawValue: langString) {
                            languages.append(lang)
                        }
                    }
                }
            }

            //Last name
            if let fbLastName = result.value(forKey: "last_name") as? String {
                lastName = fbLastName
            } else {
                lastName = ""
            }

            //Profile picture
            //Written this way for debug purposes
            //I don't think this can be nil, so we're leaving it like this for now
            picture = nil
            if let pictureDictionary = result.value(forKey: "picture") as? NSDictionary {
                if let pictureData = pictureDictionary.value(forKey: "data") as? NSDictionary {
                    if let profilePictureURLString = pictureData.value(forKey: "url") as? String {
                        let profilePictureURL = URL(string: profilePictureURLString)!
                        let profilePictureData = try! Data(contentsOf: profilePictureURL)
                        picture = UIImage(data: profilePictureData)!
                    }
                }
            }

            user.name = firstName + " " + lastName
            user.displayName = firstName+lastName
            user.knownLanguages = languages
            user.bio = bio
            user.gender = gender
            user.birthdate = birthday
            user.profilePicture = picture

            DispatchQueue.main.async(execute: {
                self.performSegue(withIdentifier: "InitialLogin", sender: nil)
            })
        })
    }

    func populateUserFromGoogle(user: HLUser) {
        //TODO: Fix this 💩
        //Lazy way to fix race condition
        while GIDSignIn.sharedInstance().currentUser == nil {
            sleep(1)
        }

        let googleUser = GIDSignIn.sharedInstance().currentUser

        let picture: UIImage?
        let userName = googleUser?.profile.name

        if (googleUser?.profile.hasImage)! {
            picture = UIImage(data: try! Data(contentsOf: (googleUser?.profile.imageURL(withDimension: 100))!))
        } else {
            picture = nil
        }

        user.name = userName
        user.displayName = userName
        user.profilePicture = picture

        user.save(toServer: false)
    }

    func didRegisterWithSession(_ session: HLUserSession) {
        self.performSegue(withIdentifier: "InitialLogin", sender: session)
    }

    func didLoginWithSession(_ session: HLUserSession) {
        HLServer.getUserById(session.userId, session: session)?.save(session)
        HLUser.getCurrentUser().setSession(session)
        HLUser.getCurrentUser().save()
        self.performSegue(withIdentifier: "previousLogin", sender: session)
    }

    func requestFromServer(_ url: String, authority: String, signIn: GIDSignIn!) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {

            var response: URLResponse?
            var bodyDict = [String: String]()

            if authority == "FACEBOOK" {
                bodyDict = ["authority": "FACEBOOK",
                                "authorityAccountId": FBSDKAccessToken.current().userID,
                                "authorityToken": FBSDKAccessToken.current().tokenString]
            }
            if authority == "GOOGLE" {
                    while GIDSignIn.sharedInstance().currentUser == nil {
                        sleep(1)
                    }

                    bodyDict = ["authority": "GOOGLE",
                                    "authorityAccountId": signIn.currentUser.userID,
                                    "authorityToken": signIn.currentUser.authentication.idToken]
            }

            let request = NSMutableURLRequest(url: URL(string: url)!)
            request.allHTTPHeaderFields = ["Content-Type": "application/json"]
            request.httpMethod = "POST"

            if let deviceToken = (UIApplication.shared.delegate as? AppDelegate)?.apnsToken {
                bodyDict["deviceToken"] = deviceToken
            }

            request.httpBody = try? JSONSerialization.data(withJSONObject: NSDictionary(dictionary: bodyDict), options: JSONSerialization.WritingOptions(rawValue: 0))

            //TODO: Make this properly asynchronous
            if let returnedData = try? NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: &response) {
                if let response2 = response as? HTTPURLResponse {
                    if response2.statusCode == 403 && url == "https://gethilingual.com/api/auth/register" {
                        self.requestFromServer("https://gethilingual.com/api/auth/login", authority: authority, signIn: signIn)
                    } else {
                        print(returnedData)
                        if let returnString = NSString(data: returnedData, encoding: String.Encoding.utf8.rawValue) {
                            print(returnString)
                            //FIXME: What is ret used for?
                            if let ret = (try? JSONSerialization.jsonObject(with: returnedData, options: JSONSerialization.ReadingOptions(rawValue: 0))) as? NSDictionary {
                                if url == "https://gethilingual.com/api/auth/register" {
//                                    self.didRegisterWithSession(HLUserSession(userId: Int64(ret["userId"] as! Int), sessionId: ret["sessionId"] as! String, authority: LoginAuthority(rawValue: authority)!,  authorityAccountId: bodyDict["authorityAccountId"]!, authorityToken: bodyDict["authorityToken"]!))
                                } else if  url == "https://gethilingual.com/api/auth/login"{
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
