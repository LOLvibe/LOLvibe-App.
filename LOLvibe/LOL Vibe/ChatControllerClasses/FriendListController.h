//
//  FriendListController.h
//  LOLvibe
//
//  Created by Jaydip Godhani on 02/06/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendListController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    
    __weak IBOutlet UITableView *tblFriendList;
}
- (IBAction)btnBack:(UIButton *)sender;

@end
