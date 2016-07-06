//
//  AddMemberController.h
//  LOLvibe
//
//  Created by Jaydip Godhani on 28/05/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddMemberController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    
    __weak IBOutlet UITableView *tblMember;
}

@property (strong, atomic) NSData *dataImag;
@property (strong, atomic) NSString *strGroupName;
@property (strong, atomic) NSString *strAddMember;
@property (strong, atomic) NSString *strGroupId;
- (IBAction)btnCancel:(UIButton *)sender;
- (IBAction)btnDone:(UIButton *)sender;

@end
