//
//  Created by Aigars Silavs
//  Copyright © 2015 Draugiem
//
//  This work is free. You can redistribute it and/or modify it under the
//  terms of the Do What The Fuck You Want To Public License, Version 2,
//  as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
//

#import <UIKit/UIKit.h>
#import <SafariServices/SafariServices.h>
#import "DraugiemSDK.h"
#import "DRHelper.h"
#import "DRError.h"

@interface DraugiemSDK () <SFSafariViewControllerDelegate>
{
    id <NSObject> _observer;
    NSString *_pendingAction;
    void (^_pendingActionCompletionHandler)(id object, NSError *error);
    NSURLSession *_session;
    UIWindow *_draugiemWindow;
}
@end

@implementation DraugiemSDK

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

- (NSError *)startWithAppID:(DRId)appID appKey:(NSString *)appKey
{
    if ([[DRUser alloc] initWithIdentificator:appID].type != DRUserTypeAPI) {
        if (appID < 1000000 && appID > 0) {
            
            //Unmissable warning to the developer ir order to avoid a common pitfall.
            NSString *message = [NSString stringWithFormat:@"WARNING: You may have a deprecated Draugiem appID. Try the following appID: %@. Update your .plists URL scheme to \"dr%@\" as well.", @(15000000 + appID), @(15000000 + appID)];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Draugiem SDK"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{[alert show];}];
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
    BOOL expectedSourceApplication = ([sourceApplication hasPrefix:@"lv.draugiem"] ||
                                      [sourceApplication hasPrefix:@"com.apple"]);
    
    if (draugiemURL && expectedSourceApplication) {
        
        if (_draugiemWindow.rootViewController.presentedViewController) {
            [_draugiemWindow.rootViewController.presentedViewController dismissViewControllerAnimated:YES completion:^{
                _draugiemWindow.hidden = YES;
                _draugiemWindow = nil;
            }];
        }
        
        //URL was intended for DraugiemSDK
        [self processCallback:url];
        return YES;
    }
    
    //URL was not intended for DraugiemSDK
    return NO;
}

- (void)processCallback:(NSURL *)url
{
    if (Draugiem.logRequests) NSLog(@"Draugiem action callback: %@", url.absoluteString);
    
    id object = nil;
    NSError *error = nil;
    NSString *action = [url host];
    
    if ([action isEqualToString:_pendingAction]) {
        
        NSDictionary *queryDict = [DRHelper dictFromQueryString:url.query];
        
        error = [DRError errorWithCode:[queryDict[kDraugiemQueryKeyErrorCode] integerValue]
                               message:queryDict[kDraugiemQueryKeyErrorMessage]
                                domain:queryDict[kDraugiemQueryKeyErrorDomain]];
        
        if ([action isEqualToString:kDraugiemActionAuthorize]) {
            
            NSString *apiKey = queryDict[kDraugiemQueryKeyApiKey];
            object = apiKey.length == kDraugiemKeyLength ? apiKey : nil;
            _apiKey = object;
            
        } else if ((error.domain == kErrorDomainDraugiemSDK && error.code == DRErrorNone) || !error) {
            
            //No errors until now, and there is no handler for received callback. Should never end up here.
            error = [DRError errorWithCode:DRErrorUnknown];
        }
        
    } else {
        //expected action does not match the actual one.
        error = [DRError errorWithCode:DRErrorInvalidResponse];
    }
    
    if ((error.domain == kErrorDomainDraugiemSDK && error.code == DRErrorNone)) {
        error = nil;
    }
    
    if (!object && !error) {
        error = [DRError errorWithCode:DRErrorUnknown];
    }
    
    if (_pendingActionCompletionHandler) {
        _pendingActionCompletionHandler(object, error);
        _pendingActionCompletionHandler = NULL;
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

#pragma mark Direct API calls

- (void)restoreApiKey:(NSString *)apiKey completion:(void (^)(BOOL success, NSError *error))completionHandler
{
    _apiKey = apiKey;
    
    [self callAPIMethod:kDraugiemMethodGetClient parameters:nil completion:^(NSDictionary *responseJSON, NSError *error) {
        
        BOOL apiKeyValid = NO;

        if (responseJSON) {
            DRUser *user = [[DRUser alloc] initWithJSONDictionary:responseJSON[kDraugiemMethodGetClient]];
            apiKeyValid = user.valid;
        }
        
        _apiKey = apiKeyValid ? apiKey : nil;
    
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionHandler(apiKeyValid, error);
        }];
    }];
}

- (void)clientWithCompletion:(void (^)(DRUser *client, NSError *error))completionHandler
{
    [self callAPIMethod:kDraugiemMethodGetClient parameters:nil completion:^(NSDictionary *responseJSON, NSError *error) {
        
        DRUser *client = nil;
        if (responseJSON) {
            DRUser *user = [[DRUser alloc] initWithJSONDictionary:responseJSON[kDraugiemMethodGetClient]];
            client = user.valid ? user : nil;
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionHandler(client, error);
        }];
    }];
}

#pragma mark - PRIVATE METHODS

- (void)performAction:(NSString *)action
           parameters:(NSDictionary *)parameters
           completion:(void (^)(id object, NSError *error))completionHandler
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
        
        if ([SFSafariViewController class]) {
            [self performModalAction:action parameters:parameters completion:completionHandler];
        } else {
            [self performExternalAction:action parameters:parameters completion:completionHandler];
        }
        
    } else {
        _pendingActionCompletionHandler(nil, [DRError errorWithCode:errorCode]);
        _pendingActionCompletionHandler = NULL;
        _pendingAction = nil;
    }
}

#pragma mark External app actions

- (void)performExternalAction:(NSString *)action
                   parameters:(NSDictionary *)parameters
                   completion:(void (^)(id object, NSError *error))completionHandler
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@/?app=%lld&hash=%@&native=ios", [DRHelper apiURL], _pendingAction, [self appID], [DRHelper apiHash]];
    NSString *additionalParameters = [DRHelper queryStringFromDictionary:parameters];
    urlString = [urlString stringByAppendingString: additionalParameters];
    NSURL *url = [NSURL URLWithString:urlString];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        
        _observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^ (NSNotification *notification) {
            [self applicationDidBecomeActive:notification];
        }];
        
        if (Draugiem.logRequests) NSLog(@"Draugiem action request: %@",url.absoluteString);
        
        [[UIApplication sharedApplication] openURL:url];
        //No errors encountered. openURL and return from function.
        //Response should be handled in [[DraugiemSDK sharedInstance] openURL:sourceApplication:]
        return;
    } else {
        //Even if native Draugiem app is not installed, Safari should be installed.
        //Should never end up here.
        
        //Error has been encountered along the way.
        _pendingActionCompletionHandler(nil, [DRError errorWithCode:DRErrorUnknown]);
        _pendingActionCompletionHandler = NULL;
        _pendingAction = nil;
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    //External action was cancelled / interrupted, since this method was called
    //in stead of [[DraugiemSDK sharedInstance] openURL:sourceApplication:]
    
    if (_observer != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:_observer];
        _observer = nil;
    }
    
    [self sendInterruptErrorToActionCompletionHandler];
}

- (void)sendInterruptErrorToActionCompletionHandler
{
    if (_pendingActionCompletionHandler) {
        _pendingActionCompletionHandler(nil, [DRError errorWithCode:DRErrorInterrupt]);
        _pendingActionCompletionHandler = NULL;
    }
    _pendingAction = nil;
}

#pragma mark Modal view actions

- (void)performModalAction:(NSString *)action
                parameters:(NSDictionary *)parameters
                completion:(void (^)(id object, NSError *error))completionHandler
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@/?app=%lld&hash=%@&native=ios", kDraugiemWebApiURL, _pendingAction, [self appID], [DRHelper apiHash]];
    NSString *additionalParameters = [DRHelper queryStringFromDictionary:parameters];
    urlString = [urlString stringByAppendingString: additionalParameters];
    NSURL *url = [NSURL URLWithString:urlString];
    
    SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:url];
    safariViewController.delegate = self;
    
    if (!_draugiemWindow) {
        _draugiemWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _draugiemWindow.rootViewController = [UIViewController new];
        _draugiemWindow.rootViewController.view.backgroundColor = [UIColor clearColor];
    }
    
    [_draugiemWindow makeKeyAndVisible];
    [_draugiemWindow.rootViewController performSelector:@selector(presentModalViewController:animated:) withObject:safariViewController afterDelay:0.0f];
    
    return;
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller
{
    //Modal action was cancelled / interrupted, since this method was called
    //in stead of [[DraugiemSDK sharedInstance] openURL:sourceApplication:]
    
    _draugiemWindow = nil;
    [self sendInterruptErrorToActionCompletionHandler];
}

#pragma mark Direct API calls

- (NSURLRequest *)requestWithJSONDictionary:(NSDictionary *)JSONDictionary error:(NSError **)error
{
    NSData *data = nil;
    
    if ([NSJSONSerialization isValidJSONObject:JSONDictionary]) {
        data = [NSJSONSerialization dataWithJSONObject:JSONDictionary options:0 error:error];
    } else {
        if (*error != nil) {
            *error = [DRError errorWithCode:DRErrorInvalidRequest];
        }
    }
    
    if (!data) {
        return nil;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kDraugiemNativeApiURL]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    [request setTimeoutInterval:kDraugiemRequestTimeout];
    
    if (Draugiem.logRequests) NSLog(@"Draugiem API request: %@?data=%@",
                                    kDraugiemNativeApiURL,
                                    [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
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
        error = [DRError errorWithCode:DRErrorInvalidApiKey];
    }
    
    if (error || !method) {
        if (completionHandler) {
            completionHandler(nil, error);
        }
        return;
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
