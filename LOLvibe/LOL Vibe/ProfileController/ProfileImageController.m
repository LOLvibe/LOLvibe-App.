//
//  ProfileImageController.m
//  LOLvibe
//
//  Created by Jaydip Godhani on 11/06/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "ProfileImageController.h"
#import "UIImageView+WebCache.h"

@interface ProfileImageController ()
{
    
}
@end

@implementation ProfileImageController

@synthesize dictinfo;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = [NSString stringWithFormat:@"@%@",[dictinfo valueForKey:@"name"]];
    //NSLog(@"%@",[dictinfo valueForKey:@"profile_pic"]);

    [imgProfilePic sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dictinfo valueForKey:@"profile_pic"]]] placeholderImage:[UIImage imageNamed:@""] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        imgProfilePic.image = image;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)btnBack:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
