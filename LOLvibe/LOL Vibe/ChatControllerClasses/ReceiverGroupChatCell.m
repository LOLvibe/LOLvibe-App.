//
//  ReceiverGroupChatCell.m
//  TalkNShop
//
//  Created by TechnoTech india  on 16/10/15.
//  Copyright © 2015 TechnoTechIndia. All rights reserved.
//

#import "ReceiverGroupChatCell.h"

@implementation ReceiverGroupChatCell

- (void)awakeFromNib
{
    self.chatMessageTxt.delegate = self;
    [self.viewBg.layer setCornerRadius:5.0];
    [self.chatMessageTxt setScrollEnabled:NO];
    self.chatMessageTxt.editable = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(copy:))
    {
        [self.chatMessageTxt selectAll:self];
        return YES;
    }
    else if (action == @selector(cut:))
    {
        return NO;
    }
    else if (action == @selector(paste:))
    {
        return NO;
    }
    else if (action == @selector(definition))
    {
        return NO;
    }
    else if (action == @selector(selectAll:))
    {
        return YES;
    }
    return NO;
}

-(void)copy:(id)sender
{
    [self.chatMessageTxt selectAll:self];
}
-(void)selectAll:(id)sender
{
    [self.chatMessageTxt selectAll:self];
}

@end
