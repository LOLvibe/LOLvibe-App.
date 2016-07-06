//
//  UserInfo.h
//  nesetchat
//
//  Created by WeeTech Solution on 01/06/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserInfo : NSManagedObject

@property (nonatomic, retain) NSString * cover_pic;
@property (nonatomic, retain) NSNumber * is_blocked;
@property (nonatomic, retain) NSNumber * is_favourited;
@property (nonatomic, retain) NSNumber * isGroup;
@property (nonatomic, retain) NSString * logged_user_phone_number;
@property (nonatomic, retain) NSString * profile_pic;
@property (nonatomic, retain) NSString * phone_number;
@property (nonatomic, retain) NSString * user_id;
@property (nonatomic, retain) NSString * user_name;
@property (nonatomic, retain) NSString * list_phone_numbers;
@property (nonatomic, retain) NSNumber * isList;

@end
