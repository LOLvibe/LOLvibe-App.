//
//  AppDelegate.m
//  LOL Vibe
//
//  Created by Paras Navadiya on 26/04/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GlobalMethods : NSObject

+(void)setPdding:(UITextField *)textField;
+(void)displayAlertWithTitle:(NSString *)title andMessage:(NSString *)msg;



+(NSDate *)getDateFromString:(NSString *)stringDate;
+(NSString *)getStringFromDate:(NSDate *)dateVal;


@end
