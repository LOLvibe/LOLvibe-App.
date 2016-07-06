//
//  AppDelegate.m
//  LOL Vibe
//
//  Created by Paras Navadiya on 26/04/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface ForgotPassword : UIViewController<UITextFieldDelegate>
{
    IBOutlet UITextField *txtEmail;
    
    IBOutlet UIButton *btnSend;
}
- (IBAction)btnSend:(id)sender;

@end
