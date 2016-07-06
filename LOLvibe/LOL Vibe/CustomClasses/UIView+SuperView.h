//
//  UIView+SuperView.h
//  Checklist
//
//  Created by Harshit Diyora on 25/02/14.
//  Copyright (c) 2014 Checklist. All rights reserved.

#import <UIKit/UIKit.h>

@interface UIView (SuperView)
- (UIView *)findSuperViewWithClass:(Class)superViewClass;
- (UIView *)superviewWithClassName:(NSString *)className fromView:(UIView *)view;

@end
