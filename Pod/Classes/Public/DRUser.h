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
 @brief Draugiem user type.
 */
typedef NS_ENUM (NSInteger, DRUserType) {
    /**
     @brief Unknown user type. Should never be returned, if user has valid identificator.
     */
    DRUserTypeUnknown = -1,
    /**
     @brief The default user type. User ir an individual.
     @note Example user: https://www.draugiem.lv/aigarss
     */
    DRUserTypeDefault = 0,
    /**
     @brief Music user type. User is a musician or music producer.
     @note Example user: https://www.draugiem.lv/pratavetra/
     */
    DRUserTypeMusic = 1,
    /**
     @brief Business user type. User is an enterprise.
     @note Example user: http://www.draugiem.lv/draugiem.lv/
     */
    DRUserTypeBusiness = 4,
    /**
     @brief API user type. User is an application.
     @note Example user: http://www.draugiem.lv/api_sandbox/
     */
    DRUserTypeAPI = 6,
    /**
     @brief Group user type. User is a group of likeminded users.
     @note Example user: https://www.draugiem.lv/group/16014072
     */
    DRUserTypeGroup = 7,
    /**
     @brief Event user type. User is an event, for instance a concert or conference.
     @note Example user: https://www.draugiem.lv/ev/18650178
     */
    DRUserTypeEvent = 9,
    /**
     @brief Movie user type. User is a movie.
     @note Example user: https://www.draugiem.lv/kino/vella-kalpi-vella-dzirnavas
     */
    DRUserTypeMovie = 10,
};

/**
 @brief Gender of Draugiem user.
 */
typedef NS_ENUM (NSUInteger, DRUserSex) {
    /**
     @brief Gender of Draugiem user is unknown.
     */
    DRUserSexUnknown = 0,
    /**
     @brief Draugiem user is a man or a boy.
     */
    DRUserSexMale = 1,
    /**
     @brief Draugiem user is a woman or a girl.
     */
    DRUserSexFemale = 2,
};

/**
 @brief Represents a user on draugiem.lv.
 */
@interface DRUser : DRObject

/**
 @brief The type of the Draugiem user.
 */
@property (nonatomic, readonly) DRUserType type;

/**
 @brief The gender of the Draugiem user.
 */
@property (nonatomic, readonly) DRUserSex sex;

/**
 @brief The age of the Draugiem user (optional).
 */
@property (nonatomic, readonly) NSUInteger age;

/**
 @brief The age of the Draugiem User (optional).
 */
@property (nonatomic, retain, readonly) NSDate *birthday;

/**
 @brief Full name or title of the Draugiem user.
 */
@property (nonatomic, retain, readonly) NSString *title;

/**
 @brief The nick specified by the user (optional).
 */
@property (nonatomic, retain, readonly) NSString *nick;

/**
 @brief The city of residence specified by the user (optional).
 */
@property (nonatomic, retain, readonly) NSString *city;

/**
 @brief The URL of a small version of the user's profile image.
 */
@property (nonatomic, retain, readonly) NSURL *imageSmallURL;

/**
 @brief The URL of a large version of the user's profile image.
 */
@property (nonatomic, retain, readonly) NSURL *imageLargeURL;


/**
 @brief Creates a Draugiem user object from the identificator.
 @note The only two valid properties of DRUser instance created using this method are identificator and type.
 @param identificator A valid Draugiem user ID.
 @return An initialized DRUser instance.
 */
- (id)initWithIdentificator:(DRId)identificator;

/**
 @brief Creates a Draugiem user object from the dictionary of Draugiem API JSON response.
 @param dictionary A parsed dictionary of a single Draugiem user API JSON response.
 @return An initialized DRUser instance.
 */
- (id)initWithJSONDictionary:(NSDictionary *)dictionary;

@end
