//
//  Created by Aigars Silavs
//  Copyright © 2015 Draugiem
//
//  This work is free. You can redistribute it and/or modify it under the
//  terms of the Do What The Fuck You Want To Public License, Version 2,
//  as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
//

#import <Foundation/Foundation.h>
#import "DRConstants.h"
#import "DRUser.h"
#import "DRTransaction.h"

/**Macro for convenience*/
#define Draugiem [DraugiemSDK sharedInstance]

/**
 @abstract DraugiemSDK provides methods for integrating with draugiem.lv.
 @discussion You should always use the shared instance when working with the SDK.
 
 All DraugiemSDK methods require appKey and appID properties to be set to valid values.
 You may manage your draugiem.lv application here: https://www.draugiem.lv/applications/dev/myapps/
 
 All DraugiemSDK external actions require that you specify at least one URL scheme for your app in
 the .plist file of your project. The scheme expected by DraugeimSDK has to mathch the template of dr[appID] (your applications identificator prefixed with "dr"). This scheme is used when performing callbacks from native Draugiem iOS app or Safari web browser.
 */
@interface DraugiemSDK : NSObject

#pragma mark Setup

/**
 @abstract The application ID.
 Set with [[DraugiemSDK sharedInstance] startWithAppID:appKey:] method.
 */
@property (nonatomic, readonly) DRId appID;

/**
 @abstract The application API key.
 Set with [[DraugiemSDK sharedInstance] startWithAppID:appKey:] method.
 */
@property (nonatomic, retain, readonly) NSString *appKey;

/**
 @abstract API key of client (user), that is currently authorized.
 Set on successful completion of [[DraugiemSDK sharedInstance] authorizeWithCompletion:] method.
 If no user is currently authorized with DraugeimSDK this property is nil.
 */
@property (nonatomic, retain, readonly) NSString *apiKey;

/**
 @abstract Controls whether requests made and received by Draugiem SDK are logged in console. 
 Used for debugging purposes. NO by default.
 */
@property (nonatomic) BOOL logRequests;

/**
 @abstract Gets the singleton instance. You may use "Draugiem" macro in stead of "[DraugiemSDK sharedInstance]" for added convenience.
 */
+ (DraugiemSDK *)sharedInstance;

/**
 @abstract Sets appId and appKey properties, if they appear to be valid.
 @warning nil may be returned even if appID, appKey or both of them are invalid. This method only performs initial check locally.
 @warning If your appID isn't an 8 digit integer - refer to error returned by this method or alert displayed by this method to obtain a valid appID.
 @param appID The application ID.
 @param appKey The application API key.
 @return Instance of NSError in case of obviously invalid parameters or nil, if parameters appear to be valid.
 */
- (NSError *)startWithAppID:(DRId)appID appKey:(NSString *)appKey;

/**
 @abstract Call this method from the [UIApplicationDelegate application:openURL:sourceApplication:annotation:] method
 of the AppDelegate for your app. It should be invoked for the proper processing of responses during interaction
 with the native Draugiem app or Safari as part of SSO authorization flow or Draugiem dialogs.
 @param url The URL as passed to [UIApplicationDelegate application:openURL:sourceApplication:annotation:].
 @param sourceApplication The sourceApplication as passed to [UIApplicationDelegate application:openURL:sourceApplication:annotation:].
 @return YES if the url was intended for the Draugiem SDK, NO if not.
 */
- (BOOL)openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

#pragma mark External actions (Temporarily exits current app)

/**
 @abstract Requests access to Draugiem account.
 @note apiKey of DraugiemSDK shared instance will be set on successful completion of this method.
 @param completionHandler the handler that will be invoked on completion. The apiKey is nil on failure.
 @warning [[DraugiemSDK sharedInstance] openURL:sourceApplication:] has to be called from [UIApplicationDelegate application:openURL:sourceApplication:annotation:] method, in order for this method to function.
 */
- (void)logInWithCompletion:(void (^)(NSString *apiKey, NSError *error))completionHandler;

/**
 @abstract Deletes the local Draugiem client apiKey. This will not void the permissions granted to your app by the user.
 */
- (void)logOut;

/**
@warning Not implemented
*/
- (void)buyItemWithID:(DRId)itemId completion:(void (^)(DRTransaction *transaction, NSError *error))completionHandler;

#pragma mark Direct API calls

/**
 @abstract Requests details for the client, that is currently authorized with DraugiemSDK.
 @param completionHandler the handler that will be invoked on completion. The user is nil on failure.
 */
- (void)clientWithCompletion:(void (^)(DRUser *client, NSError *error))completionHandler;

@end
