//
//  recentNotificationCell.h
//  LOLvibe
//
//  Created by Jaydip Godhani on 15/06/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface recentNotificationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UIImageView *imgNotiType;
@property (weak, nonatomic) IBOutlet UILabel *lblPostType;
@property (weak, nonatomic) IBOutlet UIImageView *imgOther;
@property (weak, nonatomic) IBOutlet UIButton *btnPostDetails;

@end
