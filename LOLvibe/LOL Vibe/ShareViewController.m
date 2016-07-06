//
//  ShareViewController.m
//  LOLvibe
//
//  Created by Jaydip Godhani on 18/06/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "ShareViewController.h"

@interface ShareViewController ()<FBSDKSharingDelegate>
{
    
}

@end

@implementation ShareViewController
@synthesize dictPostDetail,imagPost;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self roundCorner:viewCancel];
    [self roundCorner:viewUserPost];
    [self roundCorner:viewReport];
    [self roundCorner:viewShareURL];
    [self roundCorner:viewSocialShare];
    [self roundCorner:viewRepost];
    
    NSLog(@"%@",dictPostDetail);
}



-(void)roundCorner:(UIView *)viewRound
{
    viewRound.layer.cornerRadius = 3.0;
    viewRound.layer.masksToBounds = YES;
}

- (IBAction)btnRepost:(UIButton *)sender
{
    
}

- (IBAction)btnShareURL:(UIButton *)sender
{
    
}

- (IBAction)btnReport:(UIButton *)sender
{
    
}

- (IBAction)btnUserPost:(UIButton *)sender
{
    
}

- (IBAction)btnCancel:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnFacebookShare:(UIButton *)sender
{
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]])
    {
        FBSDKShareLinkContent *content = [FBSDKShareLinkContent new];
        content.contentURL = [NSURL URLWithString:@"https://itunes.apple.com/in/app/fix-duplicate-manage-duplicate/id1095988098?mt=8"];
        content.contentTitle = [NSString stringWithFormat:@"%@",[dictPostDetail valueForKey:@"feed_text"]];
        content.contentDescription = @"LoLVibe";
        content.quote = [NSString stringWithFormat:@"%@",[dictPostDetail valueForKey:@"feed_text"]];
        content.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[dictPostDetail valueForKey:@"image"]]];
        FBSDKShareDialog *shareDialog = [FBSDKShareDialog new];
        [shareDialog setMode:FBSDKShareDialogModeNative];
        [shareDialog setShareContent:content];
        [shareDialog setDelegate:self];
        [shareDialog setFromViewController:self];
        [shareDialog show];
    }
    else
    {
        FBSDKShareLinkContent *content = [FBSDKShareLinkContent new];
        content.contentURL = [NSURL URLWithString:@"https://itunes.apple.com/in/app/fix-duplicate-manage-duplicate/id1095988098?mt=8"];
        content.contentTitle = [NSString stringWithFormat:@"%@",[dictPostDetail valueForKey:@"feed_text"]];
        content.contentDescription = @"LoLVibe";
        content.quote = [NSString stringWithFormat:@"%@",[dictPostDetail valueForKey:@"feed_text"]];
        content.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[dictPostDetail valueForKey:@"image"]]];
        FBSDKShareDialog *shareDialog = [FBSDKShareDialog new];
        [shareDialog setMode:FBSDKShareDialogModeFeedWeb];
        [shareDialog setShareContent:content];
        [shareDialog setDelegate:self];
        [shareDialog setFromViewController:self];
        [shareDialog show];
        
    }
    //[self share];
}

-(void)share
{
    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
    photo.image = imagPost;
    // Optionally set user generated to YES only if this image was created by the user
    // You must get approval for this capability in your app's Open Graph configuration
    // photo.userGenerated = YES;
    
    // Create an object
    NSDictionary *properties = @{
                                 @"og:type": @"article",
                                 @"og:url": @"https://itunes.apple.com/in/app/fix-duplicate-manage-duplicate/id1095988098?mt=8",
                                 @"og:quote":@"Jaydip Godhani",
                                 @"og:title": @"A Game of Thrones",
                                 @"og:description": @"In the frozen wastes to the north of Winterfell, sinister and supernatural forces are mustering.",
                                 @"books:isbn": @"0-553-57340-3",
                                 };
    FBSDKShareOpenGraphObject *object = [FBSDKShareOpenGraphObject objectWithProperties:properties];
    
    // Create an action
    FBSDKShareOpenGraphAction *action = [[FBSDKShareOpenGraphAction alloc] init];
    action.actionType = @"books.reads";
    [action setObject:object forKey:@"books:book"];
    
    // Add the photo to the action. Actions
    // can take an array of images.
    [action setArray:@[photo] forKey:@"image"];
    
    // Create the content
    FBSDKShareOpenGraphContent *content = [[FBSDKShareOpenGraphContent alloc] init];
    content.action = action;
    content.previewPropertyName = @"books:book";
    
    [FBSDKShareDialog showFromViewController:self
                                 withContent:content
                                    delegate:nil];
}

- (IBAction)btnTwitterShare:(UIButton *)sender
{
    
}

- (IBAction)btnInstagramShare:(UIButton *)sender
{
    
}


#pragma mark - FBSDKSharingDelegate
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults :(NSDictionary *)results
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Your post successfully post on your wall."];
    NSLog(@"FB: SHARE RESULTS=%@\n",[results debugDescription]);
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Something wrong."];
    NSLog(@"FB: ERROR=%@\n",[error debugDescription]);
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"FB: CANCELED SHARER=%@\n",[sharer debugDescription]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
