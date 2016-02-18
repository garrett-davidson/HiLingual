//
//  HiLingual-Bridging-Header.h
//  HiLingual
//
//  Created by Garrett Davidson on 2/16/16.
//  Copyright © 2016 Team3. All rights reserved.
//

#ifndef HiLingual_Bridging_Header_h
#define HiLingual_Bridging_Header_h
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Google/SignIn.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet FBSDKLoginButton *loginButton;
@end

#endif /* HiLingual_Bridging_Header_h */
