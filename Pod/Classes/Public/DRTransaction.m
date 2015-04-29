//
//  Created by Aigars Silavs
//  Copyright © 2015 Draugiem
//
//  This work is free. You can redistribute it and/or modify it under the
//  terms of the Do What The Fuck You Want To Public License, Version 2,
//  as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
//

#import "DRTransaction.h"
#import "DRHelper.h"

@implementation DRTransaction

- (id)initWithJSONDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        if (dictionary) {
            _identificator = [dictionary[kDraugiemQueryKeyTransactionId] longLongValue];
            _completed = [dictionary[kDraugiemQueryKeyTransactionCompleted] boolValue];
        }
    }
    return self;
}

@end
