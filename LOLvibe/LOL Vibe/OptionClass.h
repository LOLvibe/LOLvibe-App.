//
//  OptionClass.h
//  LOLvibe
//
//  Created by Jaydip Godhani on 26/06/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ServiceConstant.h"
#import <Social/Social.h>

@protocol OptionClassDelegate <NSObject>
@optional
-(void)callDeleteMethod:(NSDictionary *)dict;
-(void)callRepostMethod:(NSDictionary *)dict;
-(void)callReportMethod:(NSDictionary *)dict;
@end

@interface OptionClass : NSObject <FBSDKSharingDelegate,UIDocumentInteractionControllerDelegate>
{
    UIViewController          *view_Process;
}
@property (strong ,atomic) UIDocumentInteractionController *documentController;

@property(nonatomic, retain)id <OptionClassDelegate> delegate;

-(id)initWithView:(UIViewController *)myView andDelegate:(id <OptionClassDelegate>)del;

-(void)otherUserPostOptionClass:(NSDictionary *)dictPostDetail;

-(void)selfUserPostOptionClass:(NSDictionary *)dictPostDetail;

-(void)UserProfileSharingOption:(NSDictionary *)dictPostDetail;

@end
