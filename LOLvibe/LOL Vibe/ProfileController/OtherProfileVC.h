//
//  ProfileVC.h
//  LOL Vibe
//
//  Created by Paras Navadiya on 05/05/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>

@interface OtherProfileVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UIDocumentInteractionControllerDelegate>
{
    IBOutlet UILabel *lblFullName;
    IBOutlet UILabel *lblVibeName;
    __weak IBOutlet UIButton *btnProfilePic;
    
    IBOutlet UIButton *btnPostPhoto;
    IBOutlet UIButton *btnPostGrid;
    
    IBOutlet UIButton *btnFriends;
    
    IBOutlet UIButton *btnLocationPost;
    
    IBOutlet UICollectionView *collectionViewPost;
    IBOutlet UICollectionView *collectionViewGrid;
    IBOutlet UICollectionView *locationCollection;
    
    IBOutlet UIView *viewPhoto;
    IBOutlet UIView *viewGrid;
    IBOutlet UIView *viewLocation;
    
    IBOutlet UIView *viewFriendList;
    IBOutlet UITableView *tblFriendList;
    IBOutlet UIView *lockView;
    IBOutlet UIButton *btnAddFriend;
    IBOutlet UILabel *lblFriendCount;
    
    IBOutlet UIButton *btnUserBlock;

}
@property (atomic) BOOL isProfileFrnd;
@property (atomic) BOOL isProfile;
@property (strong,atomic) NSDictionary *dictUser;
@property (strong ,atomic) UIDocumentInteractionController *documentController;

- (IBAction)btnUserBlock:(id)sender;
- (IBAction)btnAddFriend:(id)sender;

- (IBAction)btnPostPhoto:(id)sender;
- (IBAction)btnPostGrid:(id)sender;
- (IBAction)btnFriends:(id)sender;
- (IBAction)btnLocationPost:(id)sender;
- (IBAction)btnProfilePic:(UIButton *)sender;


@end
