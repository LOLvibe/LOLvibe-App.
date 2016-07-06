//
//  LocationInvitePlaces.h
//  LOLvibe
//
//  Created by Paras Navadiya on 15/06/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationInvitePlaces : UIViewController<UITextFieldDelegate>
{
    IBOutlet UITextField *txtSearchPlaces;
    IBOutlet UITextField *txtCaption;
    IBOutlet UITableView *tablePlaces;
    
    IBOutlet UILabel *lblCurrLocation;
    IBOutlet UIView *viewLocation;
    IBOutlet UIImageView *imgCurrLocation;
    IBOutlet UILabel *lblAddr;
    
    IBOutlet UIButton *btnSelectCurrLocation;

    IBOutlet UIImageView *imgRoundCurrLocation;
}
@property (nonatomic,retain)NSString *strUsers;
@property (nonatomic, strong) NSMutableArray *photos;

- (IBAction)btnDone:(id)sender;
- (IBAction)btnSearch:(id)sender;
- (IBAction)btnSelectCurrLocation:(id)sender;

@end