//
//  CustomTabBarController.h
//  CustomTabBarDemo
//
//  Created by Sunil Zalavadiya on 17/11/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomTabBarController : UITabBarController


-(void)showNotification;
-(void)tabSelectedAtIndex:(NSInteger)tabIndex;
-(void)setSelectedViewController:(UIViewController *)selectedViewController;
@end
