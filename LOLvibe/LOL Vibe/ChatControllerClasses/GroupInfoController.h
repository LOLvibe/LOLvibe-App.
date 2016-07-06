//
//  GroupInfoController.h
//  LOLvibe
//
//  Created by Jaydip Godhani on 11/06/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupInfoController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    __weak IBOutlet UIButton *profilePic;
    
    
    __weak IBOutlet UITextField *txtGroupName;
    __weak IBOutlet UITableView *tblGroupMember;
    __weak IBOutlet UIButton *btnAdddMemberOut;
    
}
@property (strong, atomic) NSDictionary *dictGroup;

- (IBAction)btnBack:(UIButton *)sender;
- (IBAction)btnProfilePic:(UIButton *)sender;
- (IBAction)btnAddMember:(UIButton *)sender;

@end
