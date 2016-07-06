//
//  ViewController.h
//  LOL Vibe
//
//  Created by Paras Navadiya on 26/04/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{    
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtPassword;
    IBOutlet UIButton *btnLogIn;
    IBOutlet UIButton *btnForgotPassword;
    
    IBOutlet UIScrollView *scrollVw;
    IBOutlet UIView *containerVw;
    
    IBOutlet UIButton *btnFB;
    IBOutlet UIButton *btnSignUp;
    
    IBOutlet NSLayoutConstraint *gapConst;

    IBOutlet NSLayoutConstraint *topConst;
    IBOutlet NSLayoutConstraint *midGapConst;
    
    IBOutlet NSLayoutConstraint *scrollview_height;
    
}
- (IBAction)btnLogIn:(id)sender;

- (IBAction)btnFB:(id)sender;

@end

