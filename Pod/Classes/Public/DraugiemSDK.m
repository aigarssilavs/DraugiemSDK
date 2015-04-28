//
//  Created by Aigars Silavs
//  Copyright © 2015 Draugiem
//
//  This work is free. You can redistribute it and/or modify it under the
//  terms of the Do What The Fuck You Want To Public License, Version 2,
//  as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
//

#import <UIKit/UIKit.h>

#import "DraugiemSDK.h"
#import "DRHelper.h"
#import "DRError.h"

@implementation DraugiemSDK
{
    id <NSObject> _observer;
    NSString *_pendingAction;
    void (^_pendingActionCompletionHandler)(id object, NSError *error);
    NSURLSession *_session;
}


#pragma mark - PUBLIC METHODS
#pragma mark Setup

+ (DraugiemSDK *)sharedInstance
{
    static DraugiemSDK *sharedDraugiemSDK = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDraugiemSDK = [self new];
    });
    return sharedDraugiemSDK;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (NSError *)startWithAppID:(DRId)appID appKey:(NSString *)appKey
{
    if ([[DRUser alloc] initWithIdentificator:appID].type != DRUserTypeAPI) {
        if (appID < 1000000 && appID > 0) {
            
            //Unmissable warning to the developer ir order to avoid a common pitfall.
            NSString *message = [NSString stringWithFormat:@"WARNING: You may have a deprecated Draugiem appID. Try the following appID: %@. Update your .plists URL scheme to \"dr%@\" as well.", @(15000000 + appID), @(15000000 + appID)];
            
            [[[UIAlertView alloc] initWithTitle:@"Draugiem SDK"
                                        message:message
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
        return [DRError errorWithCode:DRErrorInvalidAppID];
    }
    if (appKey.length != kDraugiemKeyLength) {
        return [DRError errorWithCode:DRErrorInvalidAppKey];
    }
    _appID = appID;
    _appKey = appKey;
    
    return nil;
}

- (BOOL)openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
{
    if (_observer != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:_observer];
        _observer = nil;
    }
    
    // verify the URL is intended as a callback for the SDK's log in
    BOOL draugiemURL = [[url scheme] isEqualToString:[DRHelper appURLScheme]];
    BOOL expectedSourceApplication = [sourceApplication hasPrefix:@"lv.draugiem"] || [sourceApplication hasPrefix:@"com.apple"];
    
    if (draugiemURL && expectedSourceApplication) {
        
        //URL was intended for DraugiemSDK
        [self processCallback:url];
        return YES;
    }
    
    //URL was not intended for DraugiemSDK
    return NO;
}

- (void)processCallback:(NSURL *)url
{
    NSLog(@"Action response: %@", url.absoluteString);
    
    id object = nil;
    NSError *error = nil;
    NSString *action = [url host];
    
    if ([action isEqualToString:_pendingAction]) {
        
        NSDictionary *queryDict = [DRHelper dictFromQueryString:url.query];
        
        error = [DRError errorWithCode:[queryDict[kDraugiemQueryKeyErrorCode] integerValue]
                               message:queryDict[kDraugiemQueryKeyErrorMessage]
                                domain:queryDict[kDraugiemQueryKeyErrorDomain]];
        
        if ([action isEqualToString:kDraugiemActionAuthorize]) {
            
            object = queryDict[kDraugiemQueryKeyApiKey];
            _apiKey = object;
            
        } else if ([action isEqualToString:kDraugiemActionPurchase]) {
            
        } else if (error.domain == kErrorDomainDraugiemSDK && error.code == DRErrorNone) {
            
            //No errors until now, but there is no handler for received callback. Should never end up here.
            error = [DRError errorWithCode:DRErrorUnknown];
        }
        
    } else {
        //expected action does not match the actual one.
        error = [DRError errorWithCode:DRErrorInvalidResponse];
    }
    
    if ((error.domain == kErrorDomainDraugiemSDK && error.code == DRErrorNone)) {
        error = nil;
    }
    
    if (_pendingActionCompletionHandler) {
        _pendingActionCompletionHandler(object, error);
        _pendingActionCompletionHandler = nil;
    }
    _pendingAction = nil;
    
}

#pragma mark External actions

- (void)logInWithCompletion:(void (^)(NSString *apiKey, NSError *error))completionHandler
{
    if (_apiKey) {
        //someone is already logged in
        completionHandler(_apiKey, nil);
    } else {
        [self performAction:kDraugiemActionAuthorize
                 parameters:nil
                 completion:completionHandler];
    }
}

- (void)logOut
{
    _apiKey = nil;
}

- (void)buyItemWithID:(DRId)itemId completion:(void (^)(DRTransaction *transaction, NSError *error))completionHandler
{
    [self performAction:kDraugiemActionPurchase
             parameters:@{kDraugiemQueryKeyPurchaseId:@(itemId)}
             completion:completionHandler];
}

#pragma mark Direct API calls

- (void)clientWithCompletion:(void (^)(DRUser *client, NSError *error))completionHandler
{
    [self callAPIMethod:kDraugiemMethodGetClient parameters:nil completion:^(NSDictionary *responseJSON, NSError *error) {
        
        DRUser *client = nil;
        if (responseJSON) {
            client = [[DRUser alloc] initWithJSONDictionary:responseJSON[kDraugiemMethodGetClient]];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionHandler(client, error);
        }];
    }];
}

#pragma mark - PRIVATE METHODS

#pragma mark External actions

- (void)performAction: (NSString *) action parameters: (NSDictionary *) parameters completion:(void (^)(id object, NSError *error))completionHandler
{
    _pendingAction = action;
    _pendingActionCompletionHandler = completionHandler;
    
    DRErrorCode errorCode = DRErrorNone;
    
    if (!self.appID) {
        errorCode = DRErrorInvalidAppID;
    }
    if (!self.appKey && errorCode == DRErrorNone) {
        errorCode = DRErrorInvalidAppKey;
    }
    if (![DRHelper validAppURLScheme] && errorCode == DRErrorNone) {
        errorCode = DRErrorInvalidURLScheme;
    }
    
    if (errorCode == DRErrorNone) {
        
        NSString *urlString = [NSString stringWithFormat:@"%@%@/?app=%lld&hash=%@&native=ios", [DRHelper apiURL], _pendingAction, [self appID], [DRHelper apiHash]];
        NSString *additionalParameters = [DRHelper queryStringFromDictionary:parameters];
        urlString = [urlString stringByAppendingString: additionalParameters];
        NSURL *url = [NSURL URLWithString:urlString];
        
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            
            _observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^ (NSNotification *notification) {
                [self applicationDidBecomeActive:notification];
            }];
            NSLog(@"Action request: %@",url.absoluteString);
            [[UIApplication sharedApplication] openURL:url];
            //No errors encountered. openURL and return from function.
            //Response should be handled in [[DraugiemSDK sharedInstance] openURL:sourceApplication:]
            return;
        } else {
            //Even if native Draugiem app is not installed, Safari should be installed.
            //Should never end up here.
            errorCode = DRErrorUnknown;
        }
    }
    
    //Error has been encountered along the way.
    _pendingActionCompletionHandler(nil, [DRError errorWithCode:errorCode]);
    _pendingActionCompletionHandler = nil;
    _pendingAction = nil;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    //External action was cancelled / interrupted, since this method was called
    //in stead of [[DraugiemSDK sharedInstance] openURL:sourceApplication:]
    
    if (_observer != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:_observer];
        _observer = nil;
    }
    
    if (_pendingActionCompletionHandler) {
        _pendingActionCompletionHandler(nil, [DRError errorWithCode:DRErrorInterrupt]);
        _pendingActionCompletionHandler = nil;
    }
    _pendingAction = nil;
}

#pragma mark Direct API calls

- (NSURLRequest *)requestWithJSONDictionary:(NSDictionary *)JSONDictionary error:(NSError **)error
{
    NSData *data = nil;
    
    if ([NSJSONSerialization isValidJSONObject:JSONDictionary]) {
        data = [NSJSONSerialization dataWithJSONObject:JSONDictionary options:0 error:error];
    } else {
        *error = [DRError errorWithCode:DRErrorInvalidRequest];
    }
    
    if (!data) {
        return nil;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kDraugiemNativeApiURL]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    [request setTimeoutInterval:kDraugiemRequestTimeout];
    
    NSLog(@"API request: %@?data=%@", kDraugiemNativeApiURL, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    return request;
}

- (NSError *)errorWithJSONDictionary:(NSDictionary *)JSONDictionary
{
    for (NSString *key in JSONDictionary.allKeys) {
        if ([key respondsToSelector:@selector(isEqualToString:)] && [key isEqualToString:@"error"]) {
            return [DRError errorWithCode:DRErrorDynamic message:JSONDictionary[key]];
        } else if ([JSONDictionary[key] isKindOfClass:[NSDictionary class]]) {
            return [self errorWithJSONDictionary:JSONDictionary[key]];
        }
    }
    return nil;
}

- (void)callAPIMethod:(NSString *) method
           parameters:(NSDictionary *) parameters
           completion:(void (^)(NSDictionary *responseJSON, NSError *error))completionHandler
{
    NSError *error = nil;
    if (!method) {
        error = [DRError errorWithCode:DRErrorInvalidRequest];
    }
    if (_appKey.length != kDraugiemKeyLength && !error) {
        error = [DRError errorWithCode:DRErrorInvalidAppKey];
    }
    if (_apiKey.length != kDraugiemKeyLength && !error) {
        error = [DRError errorWithCode:DRErrorInvalidAppKey];
    }
    
    if (error) {
        completionHandler(nil, error);
    } else {
        [self performAPIRequestWithJSON:@{@"method": @{method: parameters ? parameters : @{}},
                                          @"auth": @{@"app":_appKey, @"apikey": _apiKey}}
                             completion:completionHandler];
    }
}

- (void)performAPIRequestWithJSON:(NSDictionary *)requestJSON
                       completion:(void (^)(NSDictionary *responseJSON, NSError *error))completionHandler
{
    NSError *error = nil;
    NSURLRequest *request = [self requestWithJSONDictionary:requestJSON error:&error];
    
    if (!request && error) {
        completionHandler(nil, error);
    }
    
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                                                 delegate:nil
                                            delegateQueue:nil];
    }
    
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request
                                             completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      
                                      NSDictionary *JSONDictionary = nil;
                                      
                                      if (data.length > 0) {
                                          JSONDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                          error = [self errorWithJSONDictionary:JSONDictionary];
                                          if (error) {
                                              JSONDictionary = nil;
                                          }
                                      } else if (!error) {
                                          //no data, but also no error. We provide our own.
                                          error = [DRError errorWithCode:DRErrorInvalidResponse];
                                      }
                                      
                                      completionHandler(JSONDictionary, error);
                                  }];
    
    [task resume];
}

@end
