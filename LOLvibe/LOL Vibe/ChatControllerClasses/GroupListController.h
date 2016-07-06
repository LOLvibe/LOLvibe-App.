//
//  GroupListController.h
//  LOLvibe
//
//  Created by Jaydip Godhani on 06/06/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupListController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    
    __weak IBOutlet UITableView *tblGroupList;
}
- (IBAction)btnBack:(UIButton *)sender;

@end
