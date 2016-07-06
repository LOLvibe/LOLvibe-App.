//
//  UIView+SuperView.m
//  Checklist
//
//  Created by Harshit Diyora on 25/02/14.
//  Copyright (c) 2014 Checklist. All rights reserved.

#import "UIView+SuperView.h"

@implementation UIView (SuperView)

- (UIView *)findSuperViewWithClass:(Class)superViewClass {
    
    UIView *superView = self.superview;
    UIView *foundSuperView = nil;
    
    while (nil != superView && nil == foundSuperView)
    {
        if ([superView isKindOfClass:superViewClass])
        {
            foundSuperView = superView;
        }
        else
        {
            superView = superView.superview;
        }
    }
    return foundSuperView;
}

- (UIView *)superviewWithClassName:(NSString *)className fromView:(UIView *)view
{
    while (view)
    {
        if ([NSStringFromClass([view class]) isEqualToString:className])
        {
            return view;
        }
        view = view.superview;
    }
    return nil;
}

@end