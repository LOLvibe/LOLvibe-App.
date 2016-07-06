//
//  AppDelegate.m
//  LOL Vibe
//
//  Created by Paras Navadiya on 26/04/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//


#import "LoggedInUser.h"


static LoggedInUser *sharedInstance = nil;

@implementation LoggedInUser

+ (LoggedInUser *)sharedUser
{
    if(!sharedInstance)
    {
        sharedInstance = [[LoggedInUser alloc] init];
        [sharedInstance readFromDisk];
    }
    
    return sharedInstance;
}

- (void)readFromDisk
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    _userVibeName = [userDefaults objectForKey:@"userVibeName"];
    if(!_userVibeName)
        _userVibeName = @"";
    
    _userFullName = [userDefaults objectForKey:@"userFullName"];
    if(!_userFullName)
        _userFullName = @"";
    
    _userAuthToken = [userDefaults objectForKey:@"userAuthToken"];
    if(!_userAuthToken)
        _userAuthToken = @"";
    
    _userEmail = [userDefaults objectForKey:@"userEmail"];
    if(!_userEmail)
        _userEmail = @"";
    
    _userWebsite= [userDefaults objectForKey:@"userWebsite"];
    if(!_userWebsite)
        _userWebsite = @"";
    
    _userStatus = [userDefaults objectForKey:@"userStatus"];
    if(!_userStatus)
        _userStatus = @"";
    
    _isUserLoggedIn = [[userDefaults objectForKey:@"isUserLoggedIn"] boolValue];
    
    _userId = [userDefaults objectForKey:@"userId"];
    if(!_userId)
        _userId = @"";
    
    _userPhone = [userDefaults objectForKey:@"userPhone"];
    if(!_userPhone)
        _userPhone = @"";
    
    _userCountry = [userDefaults objectForKey:@"userCountry"];
    if(!_userCountry)
        _userCountry = @"";
    
    _userProfilePic= [userDefaults objectForKey:@"userProfilePic"];
    if (!_userProfilePic) {
        _userProfilePic = nil;
    }
    
    _userDOB = [userDefaults objectForKey:@"userDOB"];
    if (!_userDOB) {
        _userDOB = nil;
    }
    
    _userLocation = [userDefaults objectForKey:@"userLocation"];
    if (!_userLocation) {
        _userLocation = nil;
    }
    
    _userGender = [userDefaults objectForKey:@"userGender"];
    if (!_userGender) {
        _userGender = nil;
    }
    
    _userPassword = [userDefaults objectForKey:@"userPassword"];
    if (!_userPassword) {
        _userPassword = nil;
    }
    
    _userZipcode = [userDefaults objectForKey:@"userZipcode"];
    if (!_userZipcode) {
        _userZipcode = nil;
    }
    
    _userAge = [userDefaults objectForKey:@"userAge"];
    if (!_userAge) {
        _userAge = nil;
    }
    
}

- (void)save
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_userVibeName forKey:@"userVibeName"];
    [userDefaults setObject:_userDOB forKey:@"userDOB"];
    [userDefaults setObject:_userFullName forKey:@"userFullName"];
    [userDefaults setObject:_userAuthToken forKey:@"userAuthToken"];
    [userDefaults setObject:_userEmail forKey:@"userEmail"];
    [userDefaults setObject:_userLocation forKey:@"userLocation"];
    [userDefaults setObject:_userWebsite forKey:@"userWebsite"];
    [userDefaults setObject:_userId forKey:@"userId"];
    [userDefaults setObject:[NSNumber numberWithBool:_isUserLoggedIn] forKey:@"isUserLoggedIn"];
    [userDefaults setObject:_userPhone forKey:@"userPhone"];
    [userDefaults setObject:_userCountry forKey:@"userCountry"];
    [userDefaults setObject:_userProfilePic forKey:@"userProfilePic"];
    [userDefaults setObject:_userStatus forKey:@"userStatus"];
    [userDefaults setObject:_userGender forKey:@"userGender"];
    [userDefaults setObject:_userPassword forKey:@"userPassword"];
    [userDefaults setObject:_userZipcode forKey:@"userZipcode"];
    [userDefaults setObject:_userAge   forKey:@"userAge"];
    
    [userDefaults synchronize];
}
- (void)logout
{
    _userVibeName=@"";
    _userDOB=@"";
    _userWebsite = @"";
    _userAuthToken = @"";
    _userEmail = @"";
    _userFullName = @"";
    _isUserLoggedIn=NO;
    _userPhone=@"";
    _userId = @"";
    _userCountry= @"";
    _userProfilePic = @"";
    _userStatus = @"";
    _userLocation = @"";
    _userGender= @"";
    _userPassword = @"";
    _userZipcode = @"";
    _userAge =@"";
    
    [self save];
}
@end
