//
//  Created by Aigars Silavs
//  Copyright © 2015 Draugiem
//
//  This work is free. You can redistribute it and/or modify it under the
//  terms of the Do What The Fuck You Want To Public License, Version 2,
//  as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "DraugiemSDK.h"
#import "DRAppDelegate.h"

@interface DraugiemTests : XCTestCase

@end

@implementation DraugiemTests

- (void)setUp
{
    [super setUp];
    [Draugiem startWithAppID:kDraugiemExampleAppId
                      appKey:kDraugiemExampleAppKey];
}

- (void)tearDown
{
    [Draugiem logOut];
    [super tearDown];
}

- (void)testInvalidStartups
{
    XCTAssertNotNil([Draugiem startWithAppID:0 appKey:nil]);
    XCTAssertNotNil([Draugiem startWithAppID:kDraugiemExampleAppId appKey:nil]);
    XCTAssertNotNil([Draugiem startWithAppID:0 appKey:kDraugiemExampleAppKey]);
    XCTAssertNotNil([Draugiem startWithAppID:19040 appKey:kDraugiemExampleAppKey]);
    XCTAssertNotNil([Draugiem startWithAppID:kDraugiemExampleAppId appKey:@"123456789"]);
}

- (void)testValidStartup
{
    XCTAssertNil([Draugiem startWithAppID:kDraugiemExampleAppId
                                   appKey:kDraugiemExampleAppKey]);
}

- (void)testLoginCallbackWithNoQuery
{
    [Draugiem logInWithCompletion:^(NSString *apiKey, NSError *error) {
        XCTAssertNotNil(error);
        XCTAssertNil(apiKey);
    }];
    
    NSURL *mockCallbackURL = [NSURL URLWithString: @"dr15019040://authorize"];
    [Draugiem openURL:mockCallbackURL sourceApplication:@"lv.draugiem.app"];
}

- (void)testLoginCallbackWithFailure
{
    NSString *errorMessage = @"mockErrorMessage";
    
    [Draugiem logInWithCompletion:^(NSString *apiKey, NSError *error) {
        XCTAssertTrue([error.localizedDescription isEqualToString: errorMessage]);
        XCTAssertNil(apiKey);
    }];
    
    NSString *mockCallbackURLString = [NSString stringWithFormat:@"dr15019040://authorize?error=%@",errorMessage];
    NSURL *mockCallbackURL = [NSURL URLWithString: mockCallbackURLString];
    [Draugiem openURL:mockCallbackURL sourceApplication:@"lv.draugiem.app"];
}

- (void)testLoginWithSuccess
{
    [Draugiem logInWithCompletion:^(NSString *apiKey, NSError *error) {
        XCTAssertNotNil(apiKey);
    }];
    
    NSURL *mockCallbackURL = [NSURL URLWithString: @"dr15019040://authorize?api_key=5b23d7c059565aacb9b5f273029ade56"];
    [Draugiem openURL:mockCallbackURL sourceApplication:@"lv.draugiem.app"];
}

- (void)testGetClientWithFailure
{
    __block BOOL responseReceived = NO;
    
    [Draugiem clientWithCompletion:^(DRUser *client, NSError *error) {
        XCTAssertNil(client);
        XCTAssertNotNil(error);
        responseReceived = YES;
    }];
    
    while (responseReceived == NO)  {
        [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode
                              beforeDate:[NSDate distantFuture]];
    }
}

- (void)testGetClientWithSuccess
{
    __block BOOL responseReceived = NO;
    const DRId kMatissMillersId = 61334;
    
    [Draugiem logInWithCompletion:^(NSString *apiKey, NSError *error) {
        [Draugiem clientWithCompletion:^(DRUser *client, NSError *error) {
            
            if (!error || [error.domain isEqualToString:kErrorDomainDraugiemSDK]) {
                //avoid connection related errors.
                XCTAssertTrue(client.identificator == kMatissMillersId);
                XCTAssertNil(error);
            } else {
                //Most likley this is a connection related error
                XCTAssertNil(client);
                XCTAssertNotNil(error);
            }
            responseReceived = YES;
        }];
    }];
    
    NSURL *mockCallbackURL = [NSURL URLWithString: @"dr15019040://authorize?api_key=5b23d7c059565aacb9b5f273029ade56"];
    [Draugiem openURL:mockCallbackURL sourceApplication:@"lv.draugiem.app"];
    
    while (responseReceived == NO)  {
        [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode
                              beforeDate:[NSDate distantFuture]];
    }
}

@end
