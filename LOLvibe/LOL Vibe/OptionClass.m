//
//  OptionClass.m
//  LOLvibe
//
//  Created by Jaydip Godhani on 26/06/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "OptionClass.h"
#import "ServiceConstant.h"

@implementation OptionClass
@synthesize delegate;

-(id)initWithView:(UIViewController *)myView andDelegate:(id <OptionClassDelegate>)del
{
    self = [super init];
    
    if(self)
    {
        view_Process = myView;
        self.delegate = del;
    }
    return self;
}


#pragma mark Other User Opetoin
-(void)otherUserPostOptionClass:(NSDictionary *)dictPostDetail
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *repost = [UIAlertAction actionWithTitle:@"Repost It!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self repostThisPost:dictPostDetail];
    }];

    UIAlertAction *facebook = [UIAlertAction actionWithTitle:@"Share to Facebook"
                                                       style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                           
                                                           [self shareInFacebook:dictPostDetail];
                                                       }];
    
    UIAlertAction *twitter = [UIAlertAction actionWithTitle:@"Tweet" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self twitterShare:dictPostDetail];
    }];
    
    UIAlertAction *instagram = [UIAlertAction actionWithTitle:@"Instagram" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
    
    UIAlertAction *report = [UIAlertAction actionWithTitle:@"REPORT!" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self reportThisPost:dictPostDetail];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:repost];
    [alert addAction:facebook];
    [alert addAction:twitter];
    [alert addAction:instagram];
    [alert addAction:report];
    [alert addAction:cancel];
    
    [view_Process presentViewController:alert animated:YES completion:nil];
}


#pragma mark --Selt Opetion
-(void)selfUserPostOptionClass:(NSDictionary *)dictPostDetail
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    
    UIAlertAction *facebook = [UIAlertAction actionWithTitle:@"Share to Facebook"
                                                       style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                           
                                                           [self shareInFacebook:dictPostDetail];
                                                       }];
    
    UIAlertAction *twitter = [UIAlertAction actionWithTitle:@"Twitter" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self twitterShare:dictPostDetail];
    }];
    
    UIAlertAction *instagram = [UIAlertAction actionWithTitle:@"Tweet" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    
    }];
    
//    UIAlertAction *report = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
//    {
//        [self deleteThisPost:dictPostDetail];
//    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:facebook];
    [alert addAction:twitter];
    [alert addAction:instagram];
//  [alert addAction:report];
    [alert addAction:cancel];
    [view_Process presentViewController:alert animated:YES completion:nil];
}


#pragma mark --Selt Opetion
-(void)UserProfileSharingOption:(NSDictionary *)dictPostDetail
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    
    UIAlertAction *facebook = [UIAlertAction actionWithTitle:@"Share to Facebook"
                                                       style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                           
                                                           [self shareInFacebook:dictPostDetail];
                                                       }];
    
    UIAlertAction *twitter = [UIAlertAction actionWithTitle:@"Twitter" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self twitterShare:dictPostDetail];
    }];
    
    UIAlertAction *instagram = [UIAlertAction actionWithTitle:@"Instagram" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction *report = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
                             {
                                 [self deleteThisPost:dictPostDetail];
                             }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    
    [alert addAction:facebook];
    [alert addAction:twitter];
    [alert addAction:instagram];
    [alert addAction:report];
    [alert addAction:cancel];
    
    [view_Process presentViewController:alert animated:YES completion:nil];
}

-(void)shareInFacebook:(NSDictionary *)dictPostDetail
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
        [shareDialog setFromViewController:view_Process];
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
        [shareDialog setFromViewController:view_Process];
        [shareDialog show];
    }
}

-(void)deleteThisPost:(NSDictionary *)dict
{
    [self.delegate callDeleteMethod:dict];
}
-(void)repostThisPost:(NSDictionary *)dict
{
    [self.delegate callRepostMethod:dict];
}
-(void)reportThisPost:(NSDictionary *)dict
{
    [self.delegate callReportMethod:dict];
}
#pragma marm --Twitter Share

-(void)twitterShare:(NSDictionary *)dictValue
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [controller setInitialText:[NSString stringWithFormat:@"%@",[dictValue valueForKey:@"location_text"]]];
        //[controller addImage:imgSahre];
        [controller addURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dictValue valueForKey:@"image"]]]];
        
        [view_Process presentViewController:controller animated:YES completion:Nil];
    }
}

#pragma mark - FBSDKSharingDelegate
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults :(NSDictionary *)results
{
    [view_Process dismissViewControllerAnimated:YES completion:nil];
    [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Your post successfully post on your wall."];
    NSLog(@"FB: SHARE RESULTS=%@\n",[results debugDescription]);
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    [view_Process dismissViewControllerAnimated:YES completion:nil];
    [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Something wrong."];
    NSLog(@"FB: ERROR=%@\n",[error debugDescription]);
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    [view_Process dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"FB: CANCELED SHARER=%@\n",[sharer debugDescription]);
}
@end
