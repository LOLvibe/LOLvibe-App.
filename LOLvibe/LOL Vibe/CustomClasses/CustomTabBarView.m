//
//  CustomTabBarView.m
//  CustomTabBarDemo
//
//  Created by Sunil Zalavadiya on 17/11/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import "CustomTabBarView.h"

@implementation CustomTabBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        lastIndex = 0;
    }
    return self;
}

-(void)awakeFromNib
{
    lastIndex = 0;
}

-(IBAction)tabBtnClicked:(id)sender
{
    lastIndex = [sender tag];
    
    if (lastIndex != 2)
    { // check if it's not the action button
        for (UIButton *btn in [self subviews])
        {
            if ([btn isKindOfClass:[UIButton class]])
            {
                if ([btn tag] == lastIndex)
                {
                    btn.selected = YES;
                }
                else
                {
                    btn.selected = NO;
                }
            }
        }
    }
    
    if([self.delegate respondsToSelector:@selector(tabSelectedAtIndex:)])
    {
        [self.delegate tabSelectedAtIndex:lastIndex];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
