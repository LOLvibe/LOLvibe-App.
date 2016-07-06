//
//  GroupChatController.h
//  LOLvibe
//
//  Created by Jaydip Godhani on 08/06/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceConstant.h"

@interface GroupChatController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    
    __weak IBOutlet UIButton *sendBtn;
    __weak IBOutlet UITextView *chatTextView;
    __weak IBOutlet UIView *chatBoxView;
    __weak IBOutlet UITableView *chatTableView;
    __weak IBOutlet NSLayoutConstraint *chatBoxViewBottomSpaceConstraint;
    __weak IBOutlet NSLayoutConstraint *chatTextViewHeightConstraint;
    __weak IBOutlet UIButton *profile_pic;
    
}
- (IBAction)btnProfilePic:(UIButton *)sender;
- (IBAction)btnBack:(UIButton *)sender;
- (IBAction)sendBnClick:(UIButton *)sender;
@property (strong, nonatomic) NSDictionary *dictUser;
@property (nonatomic,strong) XMPPRoom *currentRoom;


@end
