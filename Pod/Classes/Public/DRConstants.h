//
//  Created by Aigars Silavs
//  Copyright © 2015 Draugiem
//
//  This work is free. You can redistribute it and/or modify it under the
//  terms of the Do What The Fuck You Want To Public License, Version 2,
//  as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
//

#import <Foundation/Foundation.h>

static NSString *const kErrorDomainDraugiemSDK = @"lv.draugiem.sdk";

/**
 @abstract Draugiem error code. DRErrorNone signifies absence of errors.
 @note NSError residing in DraugeimSDK error domain may have a code, that is not part of this enumerator.
 Refer to the localizedDescription or userInfo in that case.
 */
typedef NS_ENUM(NSInteger, DRErrorCode) {
    /**
     @abstract No errors were encountered when performing DraugiemSDK operation.
     */
    DRErrorNone = 0,
    /**
     @abstract Unspecified error encountered when performing DraugiemSDK operation.
     */
    DRErrorUnknown = 1,
    /**
     @abstract DraugiemSDK operation was interrupted.
     */
    DRErrorInterrupt = 1<<16 | 2,
    /**
     @abstract Invalid or no appID provided to DraugiemSDK. AppID has to be 8-digit integer with '5' being the second digit.
     */
    DRErrorInvalidAppID = 1<<16 | 3,
    /**
     @abstract Invalid or no appKey provided to DraugiemSDK.
     */
    DRErrorInvalidAppKey = 1<<16 | 4,
    /**
     @abstract Invalid or no url scheme specified in the .plist file of your project. URL scheme has to match 'dr'+15XXXXXX.
     */
    DRErrorInvalidURLScheme = 1<<16 | 5,
    /**
     @abstract Invalid request. Will not be sent to Draugiem API.
     @note This is an internal error.
     */
    DRErrorInvalidRequest = 1<<16 | 6,
    /**
     @abstract Invalid response received from Draugiem app, Draugiem web or Draugiem API.
     @note This is an internal error. The same operation may complete successfully if called again.
     */
    DRErrorInvalidResponse = 1<<16 | 7,
    /**
     @abstract Error received in JSON from Draugiem API. There are no error codes - only messages. Refer to userInfo for more details.
     */
    DRErrorDynamic = 1<<17
};

/*
 const AUTH_INVALID_PARAMS_ERROR = 101;
 const AUTH_INVALID_APP_ERROR = 102;
 const AUTH_INVALID_HASH_ERROR = 103;
 const AUTH_FAILED_CREATING_KEY_ERROR = 104;
 */

@interface DRConstants : NSObject

@end
