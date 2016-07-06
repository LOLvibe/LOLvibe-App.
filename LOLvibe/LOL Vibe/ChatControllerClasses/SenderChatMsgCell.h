//
//  SenderChatMsgCell.h
//  MingleZambia
//
//  Created by Jaydip on 24/02/16.
//  Copyright © 2016 TechnoTechIndia-HrctD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatConversation.h"

@interface SenderChatMsgCell : UITableViewCell<UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView *chatMessageTxt;
@property (strong, nonatomic) IBOutlet UILabel *chatTimeLbl;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *msgTxtHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *msgTxtWidthConstraint;
@property (strong, nonatomic) IBOutlet UIImageView *msgReadStatusImage;
@property (strong, nonatomic) IBOutlet UIView *viewBg;
@property (strong, nonatomic) IBOutlet UIView *viewBottom;

@property(nonatomic, retain)ChatConversation *chatObj;
@property (nullable, readwrite, copy) UITextRange *selectedTextRange;

@end
