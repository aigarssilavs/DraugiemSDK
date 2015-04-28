//
//  Created by Aigars Silavs
//  Copyright © 2015 Draugiem
//
//  This work is free. You can redistribute it and/or modify it under the
//  terms of the Do What The Fuck You Want To Public License, Version 2,
//  as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
//

#import <Foundation/Foundation.h>
#import "DRUser.h"

@interface DRTransaction : NSObject

/**
 @abstract The ID of the Draugiem transaction.
 */
@property (nonatomic, readonly) DRId identificator;

/**
 @abstract Whether the transaction has been successfully completed.
 */
@property (nonatomic) BOOL completed;

@end
