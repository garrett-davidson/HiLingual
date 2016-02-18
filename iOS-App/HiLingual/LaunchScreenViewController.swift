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
class LaunchScreenViewController: UIViewController , FBSDKLoginButtonDelegate, GIDSignInDelegate, GIDSignInUIDelegate{
    override func viewDidLoad() {
        super.viewDidLoad();

        //Use guard if it wouldn't make sense to continue a method if a condition is false
        //Guard will guarantee a condition is true
        //If the condition is not true, it will run the else clause and force you to the exit the scope (with break or return)
        guard FBSDKAccessToken.currentAccessToken() != nil else {
            print("User has already logged in")
            return
        }

        print("Need to log in")
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email"]
        loginButton.center = self.view.center
        loginButton.delegate = self
        self.view.addSubview(loginButton)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signInSilently()
    }
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User logged in fam")

        guard error == nil else {
            //If you know that an optional is not nil, you should force unwrap it when you print it
            print(error!.localizedDescription)
            return
        }

        print("Login complete.")
        getUserInfo()
        self.performSegueWithIdentifier("LoggedIn", sender: self)
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    
    func getUserInfo()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in

            guard error != nil else {
                print("Error: \(error!)")
                return
            }

            print("fetched user: \(result)")
            let userName : String = result.valueForKey("name") as! String
            print("User Name is: \(userName)")
            let userEmail : String = result.valueForKey("email") as! String
            print("User Email is: \(userEmail)")
        })
    }
    
    func application(application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
            // Initialize sign-in
            var configureError: NSError?
            GGLContext.sharedInstance().configureWithError(&configureError)
            assert(configureError == nil, "Error configuring Google services: \(configureError)")
            
            GIDSignIn.sharedInstance().delegate = self
            
            return true
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
        withError error: NSError!) {
            if (error == nil) {
                // Perform any operations on signed in user here.
                // ...
            } else {
                print("\(error.localizedDescription)")
            }
    }

}