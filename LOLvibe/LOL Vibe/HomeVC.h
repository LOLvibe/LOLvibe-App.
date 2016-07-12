//
//  HomeVC.h
//  LOL Vibe
//
//  Created by Paras Navadiya on 05/05/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>

@interface HomeVC : UIViewController<UIDocumentInteractionControllerDelegate>
{
    IBOutlet UICollectionView *coolectionFeed;
}

@property (strong ,atomic) UIDocumentInteractionController *documentController;
- (IBAction)RefreshScreen:(id)sender;

@end
