//
//  AppDelegate.swift
//  HiLingual
//
//  Created by Garrett Davidson on 1/28/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import UIKit
import AudioToolbox

extension String {
    func localizedWithComment(comment:String) -> String {
        return NSLocalizedString(self, comment: comment)
    }

    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, GGLInstanceIDDelegate {

    var window: UIWindow?
    var registrationOptions: [String: NSObject]?

    var apnsToken: String?

    enum NotificationTypes: String {
        case newMessage = "NEW_MESSAGE"
        case editedMessage = "EDITED_MESSAGE"
        case requestReceived = "REQUEST_RECEIVED"
        case requestAccepted = "REQUEST_ACCEPTED"
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        setupFacebook(application, didFinishLaunchingWithOptions: launchOptions)
        setupGoogle()

        FBSDKLoginManager.renewSystemCredentials { (result:ACAccountCredentialRenewResult, error:NSError?) -> Void in
            print(result)
            print(error)
        }

        registerForRemoteNotifications(application)


        return true
    }

    func registerForRemoteNotifications(application: UIApplication) {
        //        if #available(iOS 8.0, *) {
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        //        } else {
        //            // Fallback
        //            let types: UIRemoteNotificationType = [.Alert, .Badge, .Sound]
        //            application.registerForRemoteNotificationTypes(types)
        //        }
    }

    func stringToDict(text: String) -> [String:AnyObject]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("Received remote notification")
        print(userInfo)

        if let typeString = userInfo["type"] as? String {

            switch NotificationTypes(rawValue:typeString) {
            case .None:
                break

            case .Some(.newMessage):
                if let messageDictString = userInfo["msgContent"] as? String {
                    if let messageDict = stringToDict(messageDictString) {
                        if let message = HLMessage.fromDict(messageDict) {
                            let lastMessageURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent("\(message.senderID).chat.last")
                            if NSKeyedArchiver.archiveRootObject(message, toFile: lastMessageURL.path!) {
                                print("Wrote new message to disk")
                            } else {
                                print("Failed to write message to disk")
                            }
                        }
                    }
                }
                break

            default:
                break
            }

            UIApplication.sharedApplication().applicationIconBadgeNumber = (userInfo["badge"] as? NSNumber)?.integerValue ?? 0
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

            NSNotificationCenter.defaultCenter().postNotificationName(typeString, object: nil, userInfo: userInfo)
        }
    }

    func setupFacebook(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Failed to register for notifications")
        print("Error: \(error)")
    }

    func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData ) {
        print(deviceToken)
        apnsToken = "\(deviceToken)"
//        print("Notification token: \(deviceToken.base64EncodedStringWithOptions(NSB))")
        // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
        let instanceIDConfig = GGLInstanceIDConfig.defaultConfig()
        instanceIDConfig.delegate = self
        // Start the GGLInstanceID shared instance with that config and request a registration
        // token to enable reception of notifications
//        GGLInstanceID.sharedInstance().startWithConfig(instanceIDConfig)
//        registrationOptions = [kGGLInstanceIDRegisterAPNSOption:deviceToken,
//                               kGGLInstanceIDAPNSServerTypeSandboxOption:true]
//        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity("527151665741", scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: nil)
    }

    func onTokenRefresh() {
        // A rotation of the registration tokens is happening, so the app needs to request a new token.
        print("The GCM registration token needs to be changed.")
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity("527151665741", scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: nil)
    }


    func setupGoogle() -> Bool {
        var error: NSError?
        GGLContext.sharedInstance().configureWithError(&error)

        guard error == nil else {
            print("Error configuring Google services: %@", error!)
            return false
        }

        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signInSilently()

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        if (url.scheme == "fb1016061888432481") {
            return FBSDKApplicationDelegate.sharedInstance().application(app, openURL: url, sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String, annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
        }

        else if (url.scheme == "com.googleusercontent.apps.527151665741-g9epag3c49hs0ecd4gqlu49hg3bpii46") {
                return GIDSignIn.sharedInstance().handleURL(url, sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as! String, annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
        }

        print("Unrecognized url: ", url)
        return false
    }

    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if (error == nil) {
            print("Google user signed in")
            print(signIn)
            print(user)
        }
        else {
            print(error)
        }
    }

    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        print("Google user logged out")
        print(user)
    }
}

