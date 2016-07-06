//
//  NotificationVC.h
//  LOL Vibe
//
//  Created by Paras Navadiya on 05/05/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UISegmentedControl *segment;
    
    IBOutlet UITableView *tblRecent;
}
- (IBAction)btnReqOrInvite:(id)sender;

@end
