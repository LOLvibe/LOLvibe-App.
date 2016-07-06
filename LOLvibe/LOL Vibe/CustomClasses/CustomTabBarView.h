//
//  CustomTabBarView.h
//  CustomTabBarDemo
//
//  Created by Sunil Zalavadiya on 17/11/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomTabBarViewDelegate <NSObject>

@optional
-(void)tabSelectedAtIndex:(NSInteger)tabIndex;

@end

@interface CustomTabBarView : UIView
{
    NSInteger lastIndex;
}

@property (strong, nonatomic) IBOutlet UIButton *btn1;
@property (strong, nonatomic) IBOutlet UIButton *btn2;
@property (strong, nonatomic) IBOutlet UIButton *btn3;
@property (strong, nonatomic) IBOutlet UIButton *btn4;
@property (strong, nonatomic) IBOutlet UIButton *btn5;

@property(nonatomic, retain)id <CustomTabBarViewDelegate> delegate;

@end
