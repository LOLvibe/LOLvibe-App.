//
//  ShareViewController.h
//  LOLvibe
//
//  Created by Jaydip Godhani on 18/06/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceConstant.h"

@interface ShareViewController : UIViewController
{
    
    __weak IBOutlet UIView *viewRepost;
    __weak IBOutlet UIView *viewSocialShare;
    __weak IBOutlet UIView *viewShareURL;
    __weak IBOutlet UIView *viewUserPost;
    __weak IBOutlet UIView *viewReport;
    __weak IBOutlet UIView *viewCancel;
    __weak IBOutlet UIButton *btnFacebook;
}

@property (strong, atomic) NSDictionary *dictPostDetail;
@property (strong, atomic) UIImage *imagPost;

- (IBAction)btnRepost:(UIButton *)sender;
- (IBAction)btnShareURL:(UIButton *)sender;
- (IBAction)btnReport:(UIButton *)sender;
- (IBAction)btnUserPost:(UIButton *)sender;
- (IBAction)btnCancel:(UIButton *)sender;
- (IBAction)btnFacebookShare:(UIButton *)sender;
- (IBAction)btnTwitterShare:(UIButton *)sender;
- (IBAction)btnInstagramShare:(UIButton *)sender;


@end
