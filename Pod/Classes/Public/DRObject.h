//
//  Created by Aigars Silavs
//  Copyright © 2015 Draugiem
//
//  This work is free. You can redistribute it and/or modify it under the
//  terms of the Do What The Fuck You Want To Public License, Version 2,
//  as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
//

#import <Foundation/Foundation.h>

/**
 @brief Draugiem Identificator.
 */
typedef long long DRId;

/**
 @brief Abstract Draugiem object class. Subclasses of DRObject represent draugiem objects returned by DraugiemSDK method calls.
 @warning Don't use it without subclassing it.
 */
@interface DRObject : NSObject
{
    DRId _identificator;
}

/**
 @brief Whether the current instance is valid. 
 @note In most cases instance of DRObject subclass is considered valid if it has a non-zero identificator.
 */
@property (nonatomic, readonly) BOOL valid;

/**
 @brief The ID of the Draugiem object.
 */
@property (nonatomic, readonly) DRId identificator;

@end
