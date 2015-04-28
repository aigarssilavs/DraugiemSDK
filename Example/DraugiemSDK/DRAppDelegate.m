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
    [Draugiem startWithAppID:15019040 appKey:@"068411db50ed4d0de895d4405461f112"];
    // Override point for customization after application launch.
    return YES;
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([Draugiem openURL:url sourceApplication:sourceApplication] == NO) {
        //The url was not intended for the Draugiem SDK. Handle other potential calls here.
    }
    return YES;
}

@end
