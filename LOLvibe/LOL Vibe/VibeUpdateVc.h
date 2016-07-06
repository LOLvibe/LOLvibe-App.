//
//  VibeUpdateVc.h
//  LOLvibe
//
//  Created by Paras Navadiya on 22/05/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VibeUpdateVc : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UILabel *lblCaptionCount;
    
    IBOutlet UIButton *btnCancel;
    
    IBOutlet UIButton *btnVibePost;
    
    IBOutlet UIButton *btnPublic;
    
    IBOutlet UITextView *textCaption;
    
    IBOutlet UIButton *btnFriends;
    
    IBOutlet UIButton *btnLocation;
    
    IBOutlet UIButton *btnCamera;
    
    IBOutlet UIButton *btnPhotoGallery;
    
    IBOutlet NSLayoutConstraint *bottomConst;
    
    IBOutlet UIImageView *dummyImage;
    
    IBOutlet UIView *viewNearByPlaces;
    
    IBOutlet UITableView *tableNearbyPlaces;

}
@property(nonatomic,retain) UIImage *cameraImage;
@property(nonatomic,assign) BOOL isFromCameraTab;

- (IBAction)btnFriends:(id)sender;
- (IBAction)btnPublic:(id)sender;
- (IBAction)btnCancel:(id)sender;
- (IBAction)btnVibePost:(id)sender;

- (IBAction)btnLocation:(id)sender;

- (IBAction)btnCamera:(id)sender;
- (IBAction)btnPhotoGallery:(id)sender;

- (IBAction)btnCancelNearByPlaes:(id)sender;
@end
