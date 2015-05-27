//
//  Created by Aigars Silavs
//  Copyright © 2015 Draugiem
//
//  This work is free. You can redistribute it and/or modify it under the
//  terms of the Do What The Fuck You Want To Public License, Version 2,
//  as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
//

#import <Foundation/Foundation.h>

//This file contains public constants

static NSString *const kErrorDomainDraugiemSDK = @"lv.draugiem.sdk";

/**
 @brief Draugiem error code. DRErrorNone signifies absence of errors.
 @note NSError residing in DraugeimSDK error domain may have a code, that is not part of this enumerator.
 Refer to the localizedDescription or userInfo in that case.
 */
typedef NS_ENUM(NSInteger, DRErrorCode) {
    /**
     @brief No errors were encountered when performing DraugiemSDK operation.
     */
    DRErrorNone = 0,
    /**
     @brief Unspecified error encountered when performing DraugiemSDK operation.
     */
    DRErrorUnknown = 1,
    /**
     @brief DraugiemSDK operation was interrupted.
     */
    DRErrorInterrupt = 1<<16 | 2,
    /**
     @brief Invalid or no appID provided to DraugiemSDK. AppID has to be 8-digit integer with '5' being the second digit.
     */
    DRErrorInvalidAppID = 1<<16 | 3,
    /**
     @brief Invalid or no appKey provided to DraugiemSDK.
     */
    DRErrorInvalidAppKey = 1<<16 | 4,
    /**
     @brief Invalid or no apiKey available to DraugiemSDK. No user is currently logged in.
     */
    DRErrorInvalidApiKey = 1<<16 | 5,
    /**
     @brief Invalid or no url scheme specified in the .plist file of your project. URL scheme has to match 'dr'+[yourAppId].
     */
    DRErrorInvalidURLScheme = 1<<16 | 6,
    /**
     @brief Invalid request. Will not be sent to Draugiem API.
     @note This is an internal error.
     */
    DRErrorInvalidRequest = 1<<16 | 7,
    /**
     @brief Invalid response received from Draugiem app, Draugiem web or Draugiem API.
     @note This is an internal error. The same operation may complete successfully if called again.
     */
    DRErrorInvalidResponse = 1<<16 | 8,
    /**
     @brief Error messagge received without error code. Refer to userInfo for more details.
     */
    DRErrorDynamic = 1<<17
};
