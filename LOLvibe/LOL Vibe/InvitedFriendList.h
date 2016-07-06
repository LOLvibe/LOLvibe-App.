//
//  FriendListController.h
//  LOLvibe
//
//  Created by Jaydip Godhani on 02/06/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InvitedFriendList : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    
    __weak IBOutlet UITableView *tblFriendList;
}
@property(nonatomic,retain) NSArray *arrFrined;

- (IBAction)btnBack:(UIButton *)sender;

@end
