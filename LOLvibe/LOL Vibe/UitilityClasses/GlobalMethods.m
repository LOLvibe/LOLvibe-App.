//
//  AppDelegate.m
//  LOL Vibe
//
//  Created by Paras Navadiya on 26/04/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "GlobalMethods.h"
#import "CustomFonts.h"

@implementation GlobalMethods

+(void)setPdding:(UITextField *)textField
{
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;

    textField.layer.cornerRadius = 5;//half of the width
    textField.layer.borderColor=[UIColor colorWithRed:82.0/255.0 green:164.0/255.0 blue:56.0/255.0 alpha:1.0].CGColor;
    textField.textColor =[UIColor colorWithRed:82.0/255.0 green:164.0/255.0 blue:56.0/255.0 alpha:1.0];
    textField.layer.borderWidth=1.0f;
}

+(NSDate *)getDateFromString:(NSString *)stringDate
{
    NSDate * returnVal;
    NSDateFormatter * dateFromatter = [[NSDateFormatter alloc] init];
    [dateFromatter setDateFormat:@"EEE MMM dd yyyy HH:mm:ss 'GMT'Z '(UTC)'"];
    returnVal = [dateFromatter dateFromString:stringDate];
    return returnVal;
}
+(NSString *)getStringFromDate:(NSDate *)dateVal
{
    NSString * returnVal;
    NSDateFormatter * dateFromatter = [[NSDateFormatter alloc] init];
    [dateFromatter setDateFormat:@"dd MMMM, yyyy"];
    returnVal = [dateFromatter stringFromDate:dateVal];
    return returnVal;
}

+(void)displayAlertWithTitle:(NSString *)title andMessage:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}


@end
