//
//  Created by Aigars Silavs
//  Copyright © 2015 Draugiem
//
//  This work is free. You can redistribute it and/or modify it under the
//  terms of the Do What The Fuck You Want To Public License, Version 2,
//  as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
//

#import "DRAppDelegate.h"
#import "DraugiemSDK.h"

@implementation DRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /*
     All Draugiem SDK methods require appKey and appID properties to be set to valid values.
     It is recommended to set them on app startup, but it may be done later in the lifetime of your application as well.
     You may create and manage your draugiem.lv application here: https://www.draugiem.lv/applications/dev/myapps/
     [Draugiem startWithAppID:appKey:] will return an instance of NSError if appID or appKey are clearly wrong.
     */
    [Draugiem startWithAppID:kDraugiemExampleAppId
                      appKey:kDraugiemExampleAppKey];
    
    /*
     Call [Draugiem restoreApiKey:completion:] here, if you have API key saved from previous login.
     For illustration purposes this method is demonstrated on button press.
     See - (IBAction)restoreApiKeyButtonTapped:(UIButton *)sender in DRViewController
     */
    
    /*
     Log requests sent and reveiced by Draugiem SDK in example app for illustration purposes.
     */
    Draugiem.logRequests = YES;
    
    // Override point for customization after application launch.
    return YES;
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    /*
     [Draugiem openURL:sourceApplication:] should be invoked here for the proper processing of responses during interaction
     with the native Draugiem app or Safari as part of SSO authorization flow or Draugiem dialogs.
     This method returns a boolean, telling you if this call was intended for Draugiem SDK or not.
     */
    if ([Draugiem openURL:url sourceApplication:sourceApplication] == NO) {
        //The url was not intended for the Draugiem SDK. Handle other potential calls here.
    }
    return YES;
}

@end
