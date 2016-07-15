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
-(void)callInstagramMethod:(NSDictionary *)dict Image:(UIImage *)image;
@end

@interface OptionClass : NSObject <FBSDKSharingDelegate>
{
    UIViewController          *view_Process;
}
@property(nonatomic, retain)id <OptionClassDelegate> delegate;

-(id)initWithView:(UIViewController *)myView andDelegate:(id <OptionClassDelegate>)del;

-(void)otherUserPostOptionClass:(NSDictionary *)dictPostDetail Image:(UIImage *)image;

-(void)selfUserPostOptionClass:(NSDictionary *)dictPostDetail Image:(UIImage *)image;

-(void)UserProfileSharingOption:(NSDictionary *)dictPostDetail Image:(UIImage *)image;


@end
