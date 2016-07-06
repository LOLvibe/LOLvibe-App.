//
//  AppDelegate.m
//  LOL Vibe
//
//  Created by Paras Navadiya on 26/04/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUp : UIViewController<UITextFieldDelegate>
{
    
    IBOutlet UIScrollView *scrollVw;
    IBOutlet UIView *contentVw;
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtVibeUsername;
    IBOutlet UITextField *txtPassword;
    IBOutlet UIButton *btnSignUp;
  
    
    IBOutlet NSLayoutConstraint *gapConst;

    IBOutlet UITextField *txtZipcode;
}

- (IBAction)btnSignUp:(id)sender;

@end
