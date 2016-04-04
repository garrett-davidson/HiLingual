//
//  AppDelegate.swift
//  HiLingual
//
//  Created by Garrett Davidson on 1/28/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, GGLInstanceIDDelegate {

    var window: UIWindow?
    var registrationOptions: [String: NSObject]?

    var apnsToken: NSData?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        let isFacebookSetup = setupFacebook(application, didFinishLaunchingWithOptions: launchOptions)
        let isGoogleSetup = setupGoogle()

        registerForNotifications(application)


        return isFacebookSetup && isGoogleSetup
    }

    func registerForNotifications(application: UIApplication) {
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

    func setupFacebook(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Failed to register for notifications")
        print("Error: \(error)")
    }

    func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData ) {
        let string = deviceToken.base64EncodedStringWithOptions(.EncodingEndLineWithLineFeed)
        print(deviceToken)
        apnsToken = deviceToken
        print(string)
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

