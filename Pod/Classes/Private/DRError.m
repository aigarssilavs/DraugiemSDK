//
//  Created by Aigars Silavs
//  Copyright © 2015 Draugiem
//
//  This work is free. You can redistribute it and/or modify it under the
//  terms of the Do What The Fuck You Want To Public License, Version 2,
//  as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
//

#import "DRError.h"
#import "DRConstants.h"

@implementation DRError

+ (NSError *)errorWithCode:(NSInteger)code
{
    return [self errorWithCode:code message:nil];
}

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message
{
    return [self errorWithCode:code message:message domain:nil];
}

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message domain:(NSString *)domain
{
    if (code == DRErrorNone && message.length > 0 &&
        (domain == kErrorDomainDraugiemSDK || domain == nil)) {
        code = DRErrorDynamic;
    }
    NSDictionary *userInfo = [self userInfoForErrorMessage:message];
    
    if (!userInfo) {
        userInfo = [self userInfoForErrorCode:code];
    }
    
    if (!userInfo) {
        code = DRErrorUnknown;
        userInfo = [self userInfoForErrorCode:code];
    }
    
    if (!domain) {
        domain = kErrorDomainDraugiemSDK;
    }
    
    return [[NSError alloc] initWithDomain:domain code:code userInfo:userInfo];
}

+ (NSDictionary *)userInfoForErrorCode:(DRErrorCode)errorCode
{
    switch (errorCode) {
        case DRErrorNone:
            return @{NSLocalizedDescriptionKey: @"No errors were encountered.",
                     NSLocalizedRecoverySuggestionErrorKey: @"Move along, nothing to see here."};
        case DRErrorUnknown:
            return @{NSLocalizedDescriptionKey: @"Unknown error encountered."};
        case DRErrorInterrupt:
            return @{NSLocalizedDescriptionKey: @"Operation was interrupted.",
                     NSLocalizedFailureReasonErrorKey: @"The user probably canceled the operation."};
        case DRErrorInvalidAppID:
            return @{NSLocalizedDescriptionKey: @"Invalid or absent appID",
                     NSLocalizedRecoverySuggestionErrorKey: @"Assign your appID to DraugiemSDK by calling [[DraugiemSDK sharedInstance] startWithAppID:appKey:] method. AppID has to be 8-digit integer with '5' being the second digit. If your appID has less than 7-digits try prefexing it with '15' followed by appropriate number of zeros followed by your original appID. For instance '3573' translates to '15003573'."};
        case DRErrorInvalidAppKey:
            return @{NSLocalizedDescriptionKey: @"Invalid or absent appKey",
                     NSLocalizedRecoverySuggestionErrorKey: @"Assign your appKey to DraugiemSDK by calling [[DraugiemSDK sharedInstance] startWithAppID:appKey:] method."};
        case DRErrorInvalidApiKey:
            return @{NSLocalizedDescriptionKey: @"Invalid or absent apiKey",
                     NSLocalizedRecoverySuggestionErrorKey: @"Api key is set on successful login. Use [[DraugiemSDK sharedInstance] logInWithCompletion:] method to log in."};
        case DRErrorInvalidURLScheme:
            return @{NSLocalizedDescriptionKey: @"Invalid or absent url scheme.",
                     NSLocalizedRecoverySuggestionErrorKey: @"Specify url scheme for your app in the .plist file of your project. The scheme should be your appID prefixed with 'dr'."};
        case DRErrorInvalidRequest:
            return @{NSLocalizedDescriptionKey: @"Invalid JSON object set to be sent to Draugiem API.",
                     NSLocalizedRecoverySuggestionErrorKey: @"Make sure that your JSON object is valid."};
        case DRErrorInvalidResponse:
            return @{NSLocalizedDescriptionKey: @"Invalid response received from Draugiem.",
                     NSLocalizedRecoverySuggestionErrorKey: @"Did you try turning it off and on again?"};
        default:
            return nil;
    }
    return nil;
}

+ (NSDictionary *)userInfoForErrorMessage:(NSString *)message
{
    if (message.length > 0) {
        return @{NSLocalizedDescriptionKey: message};
    } else {
        return nil;
    }
}

@end
