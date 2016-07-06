//
//  LocationInviteFriendList.h
//  LOLvibe
//
//  Created by Paras Navadiya on 14/06/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationInviteFriendList : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UITableView *tableInvite;
}

- (IBAction)btnPlaces:(id)sender;

@end
