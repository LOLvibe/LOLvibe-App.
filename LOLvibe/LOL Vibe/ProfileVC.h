//
//  ProfileVC.h
//  LOL Vibe
//
//  Created by Paras Navadiya on 05/05/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>

@interface ProfileVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UIDocumentInteractionControllerDelegate>
{
    IBOutlet UILabel *lblFullName;
    IBOutlet UILabel *lblVibeName;
    IBOutlet UIButton *btnLockProfile;
    
    IBOutlet UIButton *btnPostPhoto;
    IBOutlet UIButton *btnPostGrid;
    
    IBOutlet UIButton *btnFriends;
    IBOutlet UIButton *btnProfileSeen;
    
    IBOutlet UIButton *btnLocationPost;
    IBOutlet UIButton *btnEditProfile;
    
    IBOutlet UICollectionView *collectionViewPost;
    IBOutlet UICollectionView *collectionViewGrid;
    IBOutlet UICollectionView *locationCollection;

    IBOutlet UIView *viewPhoto;
    IBOutlet UIView *viewGrid;
    IBOutlet UIView *viewLocation;
    
    IBOutlet UIView *viewFriendList;
    __weak IBOutlet UITableView *tblFriendList;
    IBOutlet UIView *viewProfileVisit;
    
    __weak IBOutlet UITableView *tblProfileVisit;
}
- (IBAction)btnPostPhoto:(id)sender;
- (IBAction)btnPostGrid:(id)sender;

- (IBAction)btnFriends:(id)sender;
- (IBAction)btnProfileSeen:(id)sender;
- (IBAction)btnLocationPost:(id)sender;
- (IBAction)btnEditProfile:(id)sender;
@property (strong ,atomic) UIDocumentInteractionController *documentController;

@end
