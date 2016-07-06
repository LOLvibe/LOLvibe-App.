//
//  GlobalVars.h
//  TestingProject
//
//  Created by Paras Navadiya on 11/08/15.
//  Copyright (c) 2015 Crowdplat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Global : NSObject

+ (Global *)sharedInstance;

//lat long
@property(strong, nonatomic, readwrite) NSString *strLat;
@property(strong, nonatomic, readwrite) NSString *strLong;
@property(strong, nonatomic, readwrite) NSString *strTodayDate;
@property(strong, nonatomic, readwrite) NSString *strAllContact;

@property(strong, nonatomic, readwrite) NSMutableArray *arrCategories;
@property(strong, nonatomic, readwrite) NSMutableArray *arrSubCategories;
@property(strong, nonatomic, readwrite) NSMutableArray *arrArea;
@property(strong, nonatomic, readwrite) NSMutableArray *arrCity;
@property(strong, nonatomic, readwrite) NSMutableArray *arrCountry;
@property(strong, nonatomic, readwrite) NSMutableArray *arrState;
@property(strong, nonatomic, readwrite) NSMutableArray *arrGroupIDS;
@property(strong, nonatomic, readwrite) NSMutableArray *arrAllContacts;
@property(strong, nonatomic, readwrite) NSMutableArray *arrRecentChat;
@property(retain,nonatomic)NSMutableArray *arrMember,*arrGroup;
@end
