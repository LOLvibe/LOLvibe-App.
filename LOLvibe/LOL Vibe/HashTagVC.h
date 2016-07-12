//
//  HomeVC.h
//  LOL Vibe
//
//  Created by Paras Navadiya on 05/05/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>

@interface HashTagVC : UIViewController<UIDocumentInteractionControllerDelegate>
{
    IBOutlet UICollectionView *coolectionFeed;
}
@property (strong ,atomic) UIDocumentInteractionController *documentController;

@property (nonatomic, retain) NSString *strHashTag;
@end
