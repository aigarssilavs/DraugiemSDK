//
//  Created by Aigars Silavs
//  Copyright © 2015 Draugiem
//
//  This work is free. You can redistribute it and/or modify it under the
//  terms of the Do What The Fuck You Want To Public License, Version 2,
//  as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
//

#import "DRViewController.h"
#import "DraugiemSDK.h"

@interface DRViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation DRViewController

- (IBAction)logInButtonTapped:(UIButton *)sender
{
    /*
     Draugiem iOS app or Safari with mobile draugiem web will be opened. If the user allows your app to access their account,
     the SDK will return users apiKey in completion handler. From that moment on the api key will also be accessible through
     DraugiemSDK shared instance.
     
     When the user has successfully authenticated you may use their apiKey for integrating with your own web backend as you see
     fit. Note that apiKey may become invalid with time - if users password is changed for instance.
     
     In most cases you will need additional information about user, that has authenticated - his/her name, age, gender and so on.
     To obtain this information call [Draugiem clientWithCompletion:] method when login has successfully completed.
     
     To avoid confusion, the user that has authenticated with Draugiem SDK is refered to as "client".
     */
    [Draugiem logInWithCompletion:^(NSString *apiKey, NSError *error) {
        if (apiKey) {
            //Log in was successful.
            self.textView.text = [NSString stringWithFormat:@"API key: %@\n\nClient data may be requested now.", apiKey];
        } else {
            //Log in was unccessful. Refer to error for details.
            self.textView.text = [NSString stringWithFormat:@"%@", error];
        }
    }];
}

- (IBAction)logOutButtonTapped:(UIButton *)sender
{
    /*
     [Draugiem logOut] only deletes local apiKey. 
     No requests are made to invalidate permissions granted to your app by the user.
     */
    [Draugiem logOut];
    self.imageView.image = nil;
    self.textView.text = nil;
}

- (IBAction)getClientButtonTapped:(UIButton *)sender
{
    /*
     You may call this method when Draugiem.apiKey is set (after a successful login).
     */
    [Draugiem clientWithCompletion:^(DRUser *client, NSError *error) {
        if (client) {
            //Client data was received.
            self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:client.imageLargeURL]];
            self.textView.text = [client.title stringByAppendingFormat:@".%@ %@.",
                                  client.age != 0 ? [NSString stringWithFormat:@" %@ year old", @(client.age)] : @"??",
                                  client.sex == DRUserSexFemale ? @"female" :
                                  client.sex == DRUserSexMale ? @"male" : @"individual of unkonwn gender"];
        } else {
            //Something went wrong. Refer to error for details.
            self.imageView.image = nil;
            self.textView.text = [NSString stringWithFormat:@"%@", error];
        }
    }];
}

- (IBAction)buyItemButtonTapped:(UIButton *)sender
{
    /*
     You may call this method when Draugiem.apiKey is set (after a successful login).
     In order to add payments to your application, contact api@draugiem.lv.
     Once your draugiem.lv application has paid products (items), you can use their IDs, to purchase them from your iOS app.
     */
    const DRId demoItemId = 1;
    [Draugiem buyItemWithID:demoItemId completion:^(DRTransaction *transaction, NSError *error) {
        if (transaction) {
            //Transaction was created, but not necessarilly completed. Refer to the "completed" property.
            self.textView.text = [NSString stringWithFormat:@"Transaction with id: %@ was%@ completed.",
                                  @(transaction.identificator),
                                  transaction.completed ? @"" : @"n't"];
        } else {
            //Something went wrong. Refer to error for details.
            self.textView.text = [NSString stringWithFormat:@"%@", error];
        }
    }];
}

- (IBAction)infoButtonTapped:(UIButton *)sender
{
    /*
     appID is the public identificator of your draugiem.lv application.
     appKey is the private key of your draugiem.lv applicatiom.
     apiKey is the private key of the user, that has granted permissions to your app.
     
     Both appID and appKey must be set in order for Draugiem SDK login to work.
     Both appKey and apiKey must be set for everything, except for login and logout to work.
     apiKey is set automatically on successfull login.
     */
    self.textView.text = [NSString stringWithFormat:@"appID: %lld\nappKey: %@\napiKey: %@",
                          Draugiem.appID,
                          Draugiem.appKey,
                          Draugiem.apiKey];
}

@end
