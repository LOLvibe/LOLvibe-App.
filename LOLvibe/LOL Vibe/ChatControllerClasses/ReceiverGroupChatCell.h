//
//  ReceiverGroupChatCell.h
//  TalkNShop
//
//  Created by TechnoTech india  on 16/10/15.
//  Copyright © 2015 TechnoTechIndia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatConversation.h"

@interface ReceiverGroupChatCell : UITableViewCell<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *chatMessageTxt;
@property (weak, nonatomic) IBOutlet UILabel *chatTimeLbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *msgTxtHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *msgTxtWidthConstraint;
@property (strong, nonatomic) IBOutlet UILabel *chatUserLbl;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *chatTextY;

@property(nonatomic, retain)ChatConversation *chatObj;
@property (strong, nonatomic) IBOutlet UIView *viewBg;

@end
