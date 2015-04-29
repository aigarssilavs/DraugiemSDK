//
//  Created by Aigars Silavs
//  Copyright © 2015 Draugiem
//
//  This work is free. You can redistribute it and/or modify it under the
//  terms of the Do What The Fuck You Want To Public License, Version 2,
//  as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
//

#import "DRObject.h"

@implementation DRObject

- (id)init
{
    self = [super init];
    if ([self isMemberOfClass:[DRObject class]]) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"DRObject is an abstract class. Don't use it without subclassing it."];
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    
    if (!object || ![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    if (self.identificator != ((DRObject *)object).identificator) {
        return NO;
    }
    
    return YES;
}

- (BOOL)valid
{
    return self.identificator != 0;
}

@end
