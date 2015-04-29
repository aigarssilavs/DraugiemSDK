//
//  Created by Aigars Silavs
//  Copyright © 2015 Draugiem
//
//  This work is free. You can redistribute it and/or modify it under the
//  terms of the Do What The Fuck You Want To Public License, Version 2,
//  as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
//

#import "DRUser.h"

@implementation DRUser

- (id)initWithIdentificator:(DRId)identificator
{
    if (self = [super init]) {
        _identificator = identificator;
    }
    return self;
}

- (id)initWithJSONDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        if (dictionary) {
            _identificator = [dictionary[@"id"] longLongValue];
            _sex = (DRUserSex)[dictionary[@"sex"] integerValue];
            _title = dictionary[@"title"];
            _nick = dictionary[@"nick"];
            _city = dictionary[@"city"];
            _imageSmallURL = [NSURL URLWithString:dictionary[@"imageSmall"]];
            _imageLargeURL = [NSURL URLWithString:dictionary[@"imageLarge"]];
            
            NSTimeInterval birthdayTimestamp = [dictionary[@"birthday"] doubleValue];
            
            if (birthdayTimestamp != 0) {
                _birthday = [NSDate dateWithTimeIntervalSince1970:birthdayTimestamp];
                _age = [[NSCalendar currentCalendar] components:NSYearCalendarUnit
                                                       fromDate:_birthday
                                                         toDate:[NSDate date]
                                                        options:0].year;
            }
        }
    }
    return self;
}

- (DRUserType)type
{
    if (self.identificator > 10000000) {
        /*
         DRUserType is equal to 2nd most significant digit of user identificator + 1.
         With identificator of 1XYYYYYY DRUserType is X+1.
         */
        int userType = ceill((self.identificator - (double)10000000)/1000000);
        if (userType == 2 || userType == 3 || userType == 5 || userType == 8) {
            //undefined user type
            return DRUserTypeUnknown;
        }
        return (DRUserType)userType;
    } else {
        return DRUserTypeDefault;
    }
}

@end
