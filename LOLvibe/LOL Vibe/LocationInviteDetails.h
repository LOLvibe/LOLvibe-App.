//
//  LocationInviteDetails.h
//  LOLvibe
//
//  Created by Paras Navadiya on 26/06/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceConstant.h"

@interface LocationInviteDetails : UIViewController
{
    IBOutlet    UILabel     *lblInviteText;
    IBOutlet    UIView      *viewMain;
    IBOutlet    UIImageView *imgMain;
    IBOutlet    ResponsiveLabel     *lblCaption;
    
    IBOutlet    UILabel     *lblLocation;
    IBOutlet    UIImageView *imgProfile;
    IBOutlet    UILabel     *lblUserVibeName;
    IBOutlet    UILabel     *lblUserFullName;
    IBOutlet    UILabel     *lblCity;
    IBOutlet    UILabel     *lblWebsite;
    IBOutlet    UILabel     *lblLikeCount;
    IBOutlet    UILabel     *lblCommentCount;
    IBOutlet    UIButton    *btnComment;
    IBOutlet    UIButton    *btnLike;
    IBOutlet    UILabel     *lblDate;
    
}
- (IBAction)btnLocation:(id)sender;
- (IBAction)btnDirection:(UIButton *)sender;
- (IBAction)btnInfo:(id)sender;
- (IBAction)btnComment:(id)sender;
- (IBAction)btnLike:(id)sender;

@property(nonatomic,retain)NSString *strInviteID;
@property(nonatomic,retain)NSString *strInviteTopTitle;
@end
