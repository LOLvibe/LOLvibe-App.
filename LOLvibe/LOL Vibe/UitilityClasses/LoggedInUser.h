//
//  AppDelegate.m
//  LOL Vibe
//
//  Created by Paras Navadiya on 26/04/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface LoggedInUser : NSObject

@property(nonatomic, assign) BOOL isUserLoggedIn;

@property(nonatomic, strong) NSString *userVibeName;
@property(nonatomic, strong) NSString *userDOB;
@property(nonatomic, strong) NSString *userPhone;
@property(nonatomic, strong) NSString *userId;
@property(nonatomic, strong) NSString *userFullName;
@property(nonatomic, strong) NSString *userAuthToken;
@property(nonatomic, strong) NSString *userEmail;
@property(nonatomic, strong) NSString *userProfilePic;
@property(nonatomic, strong) NSString *userCountry;
@property(nonatomic, strong) NSString *userWebsite;
@property(nonatomic, strong) NSString *userLocation;
@property(nonatomic, strong) NSString *userStatus;
@property(nonatomic, strong) NSString *userGender;
@property(nonatomic, strong) NSString *userPassword;
@property(nonatomic, strong) NSString *userZipcode;
@property(nonatomic, strong) NSString *userAge;

+ (LoggedInUser *)sharedUser;
- (void)readFromDisk;
- (void)save;
- (void)logout;

@end
