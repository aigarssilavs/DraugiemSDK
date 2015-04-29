//
//  Created by Aigars Silavs
//  Copyright © 2015 Draugiem
//
//  This work is free. You can redistribute it and/or modify it under the
//  terms of the Do What The Fuck You Want To Public License, Version 2,
//  as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
//

#import "DRObject.h"

/**
 @abstract Represents a draugiem.lv transaction.
 @note The fact that transaction exists, doesn't automatically mean that it was completed. Refer to the 'completed'property.
 */
@interface DRTransaction : DRObject

/**
 @abstract Whether the transaction has been successfully completed.
 */
@property (nonatomic, readonly) BOOL completed;

/**
 @abstract Creates a Draugiem transaction object from the dictionary of Draugiem app or web response.
 @param dictionary A parsed dictionary of a single Draugiem transaction response.
 @return An initialized DRTransaction instance.
 */
- (id)initWithJSONDictionary:(NSDictionary *)dictionary;

@end
