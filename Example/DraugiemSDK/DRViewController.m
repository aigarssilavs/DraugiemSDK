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
    [Draugiem logInWithCompletion:^(NSString *apiKey, NSError *error) {
        if (apiKey) {
            self.textView.text = [NSString stringWithFormat:@"API key: %@\n\nClient data may be requested now.", apiKey];
        } else {
            self.textView.text = [NSString stringWithFormat:@"%@", error];
        }
    }];
}

- (IBAction)logOutButtonTapped:(UIButton *)sender
{
    [Draugiem logOut];
    self.imageView.image = nil;
    self.textView.text = nil;
}

- (IBAction)getClientButtonTapped:(UIButton *)sender
{
    [Draugiem clientWithCompletion:^(DRUser *client, NSError *error) {
        if (client) {
            self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:client.imageLargeURL]];
            self.textView.text = [client.title stringByAppendingFormat:@".%@ %@.",
                                  client.age != 0 ? [NSString stringWithFormat:@" %@ year old", @(client.age)] : @"",
                                  client.sex == DRUserSexFemale ? @"female" :
                                  client.sex == DRUserSexMale ? @"male" : @"individual of unkonwn gender"];
        } else {
            self.imageView.image = nil;
            self.textView.text = [NSString stringWithFormat:@"%@", error];
        }
    }];
}

- (IBAction)buyItemButtonTapped:(UIButton *)sender
{
    DRId demoItemId = 0;
    [Draugiem buyItemWithID:demoItemId completion:^(DRTransaction *transaction, NSError *error) {
        if (transaction) {
            //Transaction was created, but not necessarilly completed. Refer to the "completed" property.
            self.textView.text = [NSString stringWithFormat:@"Transaction with id: %@ was%@ completed.",
                                  @(transaction.identificator),
                                  transaction.completed ? @"" : @"n't"];
        } else {
            self.textView.text = [NSString stringWithFormat:@"%@", error];
        }
    }];
}

@end
