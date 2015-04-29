# Draugiem SDK for iOS

[![CI Status](http://img.shields.io/travis/aigarssilavs/DraugiemSDK.svg?style=flat)](https://travis-ci.org/aigarssilavs/DraugiemSDK)
[![Version](https://img.shields.io/cocoapods/v/DraugiemSDK.svg?style=flat)](http://cocoapods.org/pods/DraugiemSDK)
[![License](https://img.shields.io/cocoapods/l/DraugiemSDK.svg?style=flat)](http://www.wtfpl.net/)
[![Platform](https://img.shields.io/cocoapods/p/DraugiemSDK.svg?style=flat)](https://developer.apple.com/ios)

This open-source library allows you to integrate Draugiem into your iOS app.

Installation
===============
### 0. Create your draugiem.lv application, if you haven't yet. 

Navigate to [your draugiem developer page](https://www.draugiem.lv/applications/dev/myapps/) and create a new application.
Fill in the details. You should end up with something like this:

![App creation form](/Documents/appCreationForm.png)

Take note of your application ID (15019040 in example) and application API key (068411db50ed4d0de895d4405461f112 in example).

**Warning:** Application ID is an 8 digit integer. If your application ID has less than 8 digits, prepend "15" followed by appropriate number of zeros to it. For instance - if your appID was "19040" you would use "**150**19040" as the appID in DraugiemSDK.

### 1. Add DraugiemSDK to your Xcode project. 

If you are using git for version control in your app, you may add this repo as a submodule to yours to make it easier to get future updates. DraugiemSDK is also available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "DraugiemSDK"
```

### 2. Configure your Xcode Project

Create an array key called URL types with a single array sub-item called URL Schemes in the .plist file of your project. Give this a single item with your app ID prefixed with 'dr'. The according fragment of finished .plist should look like this:

![Plist fragment](/Documents/plistFragment.png)

This is used to ensure the application will receive a callback from native Draugiem iOS app or Safari web browser when performing external actions.

Your app may support multiple url schemes. DraugiemSDK will use the one, which matches the required pattern.

Usage
===============
### Setup

Assign your unique application id and application key to DraugiemSDK instance. We recommend doing this on app startup, but you may do it later in the lifetime of your application.

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    [Draugiem startWithAppID:15019040 appKey:@"068411db50ed4d0de895d4405461f112"];
    // Override point for customization after application launch.
    return YES;
}
```

Call [Draugiem openURL:sourceApplication:] method from the [UIApplicationDelegate application:openURL:sourceApplication:annotation:] method of the AppDelegate for your app. It should be invoked for the proper processing of responses during interaction with the native Draugiem app or Safari as part of SSO authorization flow or Draugiem dialogs.

```objective-c
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([Draugiem openURL:url sourceApplication:sourceApplication] == NO) {
        //The url was not intended for the Draugiem SDK. Handle other potential calls here.
    }
    return YES;
}
```

### Authentication

Authentication is a matter of single method call. 

```objective-c
[Draugiem logInWithCompletion:^(NSString *apiKey, NSError *error) {
    if (apiKey) {
        //Valid apiKey has been received. Client data may be requested now.
    } else {
        //Something went wrong. Refer to the error object for more information.
    }
}];
```

If no errors are encountered, you may request user object of the current client. We refer to the user, that is currently logged in with DraugiemSDK as "client".

```objective-c
[Draugiem clientWithCompletion:^(DRUser *client, NSError *error) {
    if (client) {
        //Valid user object has been received. You may display this information in your app.
    } else {
        //Something went wrong. Refer to the error object for more information.
    }
}];
```

Appendix
===============

**Help:** Refer to the example project provided in [this repo](https://github.com/aigarssilavs/DraugiemSDK/tree/master/Example) and [draugiem developer portal](https://www.draugiem.lv/applications/dev/) for more information.

**License:** DraugiemSDK is available under the WTFPL license. See the [LICENSE](https://github.com/aigarssilavs/DraugiemSDK/blob/master/LICENSE) file for more info.