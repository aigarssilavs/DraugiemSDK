//
//  Created by Aigars Silavs
//  Copyright © 2015 Draugiem
//
//  This work is free. You can redistribute it and/or modify it under the
//  terms of the Do What The Fuck You Want To Public License, Version 2,
//  as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
//

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import "DRHelper.h"
#import "DraugiemSDK.h"

@implementation DRHelper

+ (NSString *)apiURL
{
    return [self draugiemAppApiSupported] ? kDraugiemAppApiURL : kDraugiemWebApiURL;
}

+ (NSString *)apiHash
{
    NSString *input = [[DraugiemSDK sharedInstance].appKey stringByAppendingString:[self appURLScheme]];
    NSString *apiKey = [DraugiemSDK sharedInstance].apiKey;
    
    if (apiKey.length == kDraugiemKeyLength) {
        input = [input stringByAppendingString:apiKey];
    }
    
    const char *cString = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cString, (CC_LONG)strlen(cString), result);
    
    NSMutableString *hash = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02x", result[i]];
    }
    return hash;
}

+ (NSString *)appURLScheme
{
    return [NSString stringWithFormat:@"dr%@",@([DraugiemSDK sharedInstance].appID)];
}

+ (BOOL)validAppURLScheme
{
    static NSMutableArray *urlSchemes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *mainBundle = [NSBundle mainBundle];
        urlSchemes = [NSMutableArray new];
        for (NSDictionary *fields in [mainBundle objectForInfoDictionaryKey:@"CFBundleURLTypes"]) {
            NSArray *schemesForType = [fields objectForKey:@"CFBundleURLSchemes"];
            if (schemesForType) {
                [urlSchemes addObjectsFromArray:schemesForType];
            }
        }
    });
    
    return [urlSchemes containsObject:[self appURLScheme]];
}

+ (NSString *)queryStringFromDictionary:(NSDictionary *)dictionary
{
    NSMutableString *query = [NSMutableString new];
    for (NSString *key in dictionary.allKeys) {
        NSString *pair = [NSString stringWithFormat:@"&%@=%@", key, dictionary[key]];
        [query appendString:pair];
    }
    
    return query;
}

+ (NSDictionary *)dictFromQueryString:(NSString *)query
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        if (elements.count == 2) {
            NSString *key = elements[0];
            NSString *value = elements[1];
            
            [dict setObject:value forKey:key];
        }
    }
    
    return dict;
}

+ (BOOL)draugiemAppApiSupported
{
    NSURL *url = [NSURL URLWithString:kDraugiemAppApiURL];
    return [[UIApplication sharedApplication] canOpenURL:url];
}

@end
