//
//  ChatsVc.h
//  LOL Vibe
//
//  Created by Paras Navadiya on 05/05/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatsVc : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    
    __weak IBOutlet UITableView *tblRecentChat;
}


@end
