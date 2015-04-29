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
}

- (void)tearDown
{
    [Draugiem logOut];
    [super tearDown];
}

- (void)testInvalidStartups
{
    XCTAssertNotNil([Draugiem startWithAppID:0 appKey:nil]);
    XCTAssertNotNil([Draugiem startWithAppID:15019040 appKey:nil]);
    XCTAssertNotNil([Draugiem startWithAppID:0 appKey:@"068411db50ed4d0de895d4405461f112"]);
    XCTAssertNotNil([Draugiem startWithAppID:19040 appKey:@"068411db50ed4d0de895d4405461f112"]);
    XCTAssertNotNil([Draugiem startWithAppID:15019040 appKey:@"123456789"]);
}

- (void)testValidStartup
{
    XCTAssertNil([Draugiem startWithAppID:15019040 appKey:@"068411db50ed4d0de895d4405461f112"]);
}

- (void)testLoginCallbackWithNoQuery
{
    [Draugiem startWithAppID:15019040 appKey:@"068411db50ed4d0de895d4405461f112"];
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
    
    [Draugiem startWithAppID:15019040 appKey:@"068411db50ed4d0de895d4405461f112"];
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
    [Draugiem startWithAppID:15019040 appKey:@"068411db50ed4d0de895d4405461f112"];
    [Draugiem logInWithCompletion:^(NSString *apiKey, NSError *error) {
        XCTAssertNotNil(apiKey);
    }];
    
    NSURL *mockCallbackURL = [NSURL URLWithString: @"dr15019040://authorize?api_key=5b23d7c059565aacb9b5f273029ade56"];
    [Draugiem openURL:mockCallbackURL sourceApplication:@"lv.draugiem.app"];
}


@end
