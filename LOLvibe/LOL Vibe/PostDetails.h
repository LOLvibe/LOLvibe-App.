//
//  PostDetails.h
//  LOLvibe
//
//  Created by Paras Navadiya on 24/05/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "ViewController.h"
#import <Social/Social.h>

@interface PostDetails : UIViewController<UIDocumentInteractionControllerDelegate>
{
    IBOutlet UICollectionView *collectionViewPost;
}

@property (nonatomic, retain)NSMutableArray *array;
@property (nonatomic, retain)NSString *strFeedID;
@property (strong ,atomic) UIDocumentInteractionController *documentController;

@end
