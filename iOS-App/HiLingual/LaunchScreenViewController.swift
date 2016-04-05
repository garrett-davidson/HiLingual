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
        //Use guard if it wouldn't make sense to continue a method if a condition is false
        //Guard will guarantee a condition is true
        //If the condition is not true, it will run the else clause and force you to the exit the scope (with break or return)
        guard FBSDKAccessToken.currentAccessToken() != nil || GIDSignIn.sharedInstance().currentUser != nil else {
            print("Need to log in")
            let loginButton = FBSDKLoginButton()
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
        var response: NSURLResponse?
        
        requestFromServer("https://gethilingual.com/api/auth/register", authority: "FACEBOOK")
        /*
        let request = NSMutableURLRequest(URL: NSURL(string: "https://gethilingual.com/api/auth/register")!)
        request.allHTTPHeaderFields = ["Content-Type": "application/json"]
        request.HTTPMethod = "POST"
        
        var bodyDict = ["authority": "FACEBOOK",
                        "authorityAccountId": FBSDKAccessToken.currentAccessToken().userID,
                        "authorityToken": FBSDKAccessToken.currentAccessToken().tokenString]
        
        if let deviceToken = (UIApplication.sharedApplication().delegate as? AppDelegate)?.apnsToken {
            let tokenString = deviceToken.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
            bodyDict["deviceToken"] = tokenString
        }
        
        

        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(NSDictionary(dictionary: bodyDict), options: NSJSONWritingOptions(rawValue: 0))

        if let returnedData = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: &response) {
            if let response2 = response as? NSHTTPURLResponse {
                if response2.statusCode == 403 {
                    let request = NSMutableURLRequest(URL: NSURL(string: "https://gethilingual.com/api/auth/login")!)
                    request.allHTTPHeaderFields = ["Content-Type": "application/json"]
                    request.HTTPMethod = "POST"
                    
                    var bodyDict1 = ["authority": "FACEBOOK",
                                    "authorityAccountId": FBSDKAccessToken.currentAccessToken().userID,
                                    "authorityToken": FBSDKAccessToken.currentAccessToken().tokenString]
                    
                    if let deviceToken = (UIApplication.sharedApplication().delegate as? AppDelegate)?.apnsToken {
                        let tokenString = deviceToken.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                        bodyDict1["deviceToken"] = tokenString
                    }
                    request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(NSDictionary(dictionary: bodyDict1), options: NSJSONWritingOptions(rawValue: 0))
                }
            }
            print(returnedData)
            if let returnString = NSString(data: returnedData, encoding: NSUTF8StringEncoding) {
                print(returnString)
                if let ret = (try? NSJSONSerialization.JSONObjectWithData(returnedData, options: NSJSONReadingOptions(rawValue: 0))) as? NSDictionary {
                    self.didLoginWithSession(HLUserSession(userId: Int64(ret["userId"] as! Int), sessionId: ret["sessionId"] as! String, authority: .Facebook, authorityAccountId: bodyDict["authorityAccountId"]!, authorityToken: bodyDict["authorityToken"]!))
                }
                else {
                    print("Couldn't parse return value")
                }
            }
            else {
                print("Returned data is not a string")
            }
        }
         */
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
        requestFromServer("https://gethilingual.com/api/auth/register", authority: "GOOGLE")
        /*
        let request = NSMutableURLRequest(URL: NSURL(string: "https://gethilingual.com/api/auth/register")!)
        request.allHTTPHeaderFields = ["Content-Type": "application/json"]
        request.HTTPMethod = "POST"


        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            //TODO: Fix this 💩
            //Lazy race condition fix
            while signIn.currentUser == nil {
                sleep(1)
            }


            let bodyDict = ["authority": "GOOGLE",
                            "authorityAccountId": signIn.currentUser.userID,
                            "authorityToken": signIn.currentUser.authentication.idToken,
                            "deviceToken": (UIApplication.sharedApplication().delegate! as! AppDelegate).apnsToken!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))]

            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(NSDictionary(dictionary: bodyDict), options: NSJSONWritingOptions(rawValue: 0))

            if let returnedData = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: nil) {
                print(returnedData)
                if let returnString = NSString(data: returnedData, encoding: NSUTF8StringEncoding) {
                    print(returnString)
                    if let ret = (try? NSJSONSerialization.JSONObjectWithData(returnedData, options: NSJSONReadingOptions(rawValue: 0))) as? NSDictionary {
                        self.didLoginWithSession(HLUserSession(userId: Int64(ret["userId"] as! Int), sessionId: ret["sessionId"] as! String, authority: .Google, authorityAccountId: bodyDict["authorityAccountId"]!, authorityToken: bodyDict["authorityToken"]!))
                    }
                    else {
                        print("Couldn't parse return value")
                    }
                }
                else {
                    print("Returned data is not a string")
                }
            }

        })
         */
    }

    func didLoginWithSession(session: HLUserSession) {
        self.performSegueWithIdentifier("InitialLogin", sender: session)
    }
    func requestFromServer(url: String,authority: String){
        var response: NSURLResponse?
        
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.allHTTPHeaderFields = ["Content-Type": "application/json"]
        request.HTTPMethod = "POST"
        
        var bodyDict = ["authority": authority,
                        "authorityAccountId": FBSDKAccessToken.currentAccessToken().userID,
                        "authorityToken": FBSDKAccessToken.currentAccessToken().tokenString]
        
        if let deviceToken = (UIApplication.sharedApplication().delegate as? AppDelegate)?.apnsToken {
            let tokenString = deviceToken.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
            bodyDict["deviceToken"] = tokenString
        }
        
        
        
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(NSDictionary(dictionary: bodyDict), options: NSJSONWritingOptions(rawValue: 0))
        
        if let returnedData = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: &response) {
            if let response2 = response as? NSHTTPURLResponse {
                if response2.statusCode == 403 && url == "https://gethilingual.com/api/auth/register"  {
                    requestFromServer("https://gethilingual.com/api/auth/login", authority: authority)
                }else{
                    print(returnedData)
                    if let returnString = NSString(data: returnedData, encoding: NSUTF8StringEncoding) {
                        print(returnString)
                        if let ret = (try? NSJSONSerialization.JSONObjectWithData(returnedData, options: NSJSONReadingOptions(rawValue: 0))) as? NSDictionary {
                            self.didLoginWithSession(HLUserSession(userId: Int64(ret["userId"] as! Int), sessionId: ret["sessionId"] as! String, authority: .Facebook,  authorityAccountId: bodyDict["authorityAccountId"]!, authorityToken: bodyDict["authorityToken"]!))
                        } else {
                            print("Couldn't parse return value")
                        }
                    } else {
                        print("Returned data is not a string")
                    }
                }
            }
        }
        
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destNav = segue.destinationViewController as? UINavigationController {
            if let dest = destNav.topViewController as? AccountCreationViewController {
                if let session = sender as? HLUserSession {
                    dest.session = session
                }
            }
        }
    }
}