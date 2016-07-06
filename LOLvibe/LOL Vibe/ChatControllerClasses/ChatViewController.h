//
//  ChatViewController.h
//  LOLvibe
//
//  Created by Jaydip Godhani on 24/05/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ServiceConstant.h"

@interface ChatViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate,UIGestureRecognizerDelegate,ChatDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    IBOutlet UITableView *chatTableView;
    IBOutlet UIView *chatBoxView;
    IBOutlet UITextView *chatTextView;
    IBOutlet UIButton *sendBtn;
    __weak IBOutlet UIButton *profile_pic;
    
    IBOutlet NSLayoutConstraint *chatBoxViewBottomSpaceConstraint;
    IBOutlet NSLayoutConstraint *chatTextViewHeightConstraint;
}

@property (strong, nonatomic) NSDictionary *dictUser;

- (IBAction)sendBtnClicked:(UIButton *)sender;
- (IBAction)btnBack:(UIButton *)sender;
- (IBAction)btnProfilePic:(UIButton *)sender;


@end
