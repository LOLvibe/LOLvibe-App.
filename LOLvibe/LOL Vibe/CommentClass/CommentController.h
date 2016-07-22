//
//  CommentController.h
//  LOLvibe
//
//  Created by Jaydip Godhani on 01/06/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    __weak IBOutlet UILabel     *lblCount;
    __weak IBOutlet UIButton    *btnSendOut;
    __weak IBOutlet UITextField *txtAddComment;
    __weak IBOutlet NSLayoutConstraint *commentBottomSpaceConstraint;
    __weak IBOutlet UITableView *tblComment;
}

@property (strong, atomic) NSDictionary *dictPost;

@property (atomic) BOOL isInvite;
@property (atomic) BOOL isHOME;

- (IBAction)btnSend:(UIButton *)sender;

@end
