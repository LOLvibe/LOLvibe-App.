//
//  GlobalVars.m
//  TestingProject
//
//  Created by Paras Navadiya on 11/08/15.
//  Copyright (c) 2015 Crowdplat. All rights reserved.
//

#import "Global.h"

@implementation Global

+ (Global *)sharedInstance {
    static dispatch_once_t onceToken;
    static Global *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[Global alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self)
    {
        _strLat = nil;
        _strLong = nil;
        _strTodayDate = nil;
        _strAllContact = nil;
        
        _arrCategories = [[NSMutableArray alloc]init];
        _arrSubCategories = [[NSMutableArray alloc]init];
        
        _arrArea = [[NSMutableArray alloc]init];
        _arrCity = [[NSMutableArray alloc]init];
        _arrCountry = [[NSMutableArray alloc]init];
        _arrState = [[NSMutableArray alloc]init];
        _arrAllContacts = [[NSMutableArray alloc]init];
        _arrMember = [[NSMutableArray alloc]init];
        _arrGroupIDS = [[NSMutableArray alloc]init];
        if(_arrRecentChat.count == 0)
        {
            _arrRecentChat = [[NSMutableArray alloc]init];

        }
    }
    return self;
}
@end
