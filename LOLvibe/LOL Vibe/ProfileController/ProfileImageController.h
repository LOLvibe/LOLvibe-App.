//
//  ProfileImageController.h
//  LOLvibe
//
//  Created by Jaydip Godhani on 11/06/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileImageController : UIViewController
{
    IBOutlet UIImageView *imgProfilePic;
}

@property (strong, atomic) NSDictionary *dictinfo;

@end
