//
//  Created by Aigars Silavs
//  Copyright © 2015 Draugiem
//
//  This work is free. You can redistribute it and/or modify it under the
//  terms of the Do What The Fuck You Want To Public License, Version 2,
//  as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
//

#import <Foundation/Foundation.h>

//APIs for external actions
static NSString *const kDraugiemAppApiURL = @"drapi://";
static NSString *const kDraugiemWebApiURL = @"https://m.draugiem.lv/applications/";
static NSString *const kDraugiemNativeApiURL = @"https://m.draugiem.lv/api/";

//External action names (opens draugiem app or web view)
static NSString *const kDraugiemActionAuthorize = @"authorize";
static NSString *const kDraugiemActionPurchase = @"purchase";

//Internal method names (requests go directly to Draugiem API)
static NSString *const kDraugiemMethodGetClient = @"users_client";

//External action query keys
static NSString *const kDraugiemQueryKeyPurchaseId = @"purchase_id";

//External action callback query keys
static NSString *const kDraugiemQueryKeyErrorDomain = @"error_domain";
static NSString *const kDraugiemQueryKeyErrorCode = @"error_code";
static NSString *const kDraugiemQueryKeyErrorMessage = @"error";
static NSString *const kDraugiemQueryKeyApiKey = @"api_key";

//Other constants
static NSInteger const kDraugiemKeyLength = 32;
static CGFloat const kDraugiemRequestTimeout = 50.0f;

@interface DRHelper : NSObject

/**API URL for external actions (Native Draugiem app of Safari)*/
+ (NSString *)apiURL;
+ (NSString *)apiHash;
+ (NSString *)appURLScheme;

/**URL scheme with template of "dr[appID]: is present in CFBundleURLSchemes of .plist file.*/
+ (BOOL)validAppURLScheme;

+ (NSString *)queryStringFromDictionary:(NSDictionary *)dictionary;
+ (NSDictionary *)dictFromQueryString:(NSString *)query;


@end
