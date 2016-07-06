//
//  ChatViewController.m
//  LOLvibe
//
//  Created by Jaydip Godhani on 24/05/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "ChatViewController.h"
#import "SenderChatMsgCell.h"
#import "ReceiverChatMsgCell.h"
#import "ServiceConstant.h"
#import "ProfileImageController.h"

@interface ChatViewController ()<ChatDelegate,NSFetchedResultsControllerDelegate,WebServiceDelegate>
{
    NSFetchedResultsController *fetchedResultsController;
    CGFloat maxChatTextWidth;
    NSMutableDictionary *chatScreenCells;
}

@end

@implementation ChatViewController
@synthesize dictUser;

- (void)viewDidLoad
{
    [super viewDidLoad];
    maxChatTextWidth = self.view.bounds.size.width - 30.0;
    chatTextView.text = [NSLocalizedString(@"Type Message", nil) uppercaseString];
    chatScreenCells = [NSMutableDictionary dictionary];
    chatTableView.userInteractionEnabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self setDefualtProperties];
    
    
    [chatTableView registerNib:[UINib nibWithNibName:@"ChatSectionHeaderCell" bundle:nil] forCellReuseIdentifier:@"ChatSectionHeaderCell"];
    [chatTableView registerNib:[UINib nibWithNibName:@"SenderChatMsgCell" bundle:nil] forCellReuseIdentifier:@"SenderChatMsgCell"];
    [chatTableView registerNib:[UINib nibWithNibName:@"ReceiverChatMagCell" bundle:nil] forCellReuseIdentifier:@"ReceiverChatMsgCell"];
    
    
    [[[XmppHelper sharedInstance] xmppStream] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self makeReadStatusForAllUnreadMessage];
    [XmppHelper sharedInstance].delegate = self;
    
    CGPoint offset = CGPointMake(0, CGFLOAT_MAX);
    [chatTableView setContentOffset:offset animated:YES];
}



-(void)setDefualtProperties
{
    chatTextView.layer.cornerRadius = 3.0;
    chatTextView.layer.masksToBounds = YES;
    
    chatTextView.layer.borderColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0].CGColor;
    chatTextView.layer.borderWidth = 1.0;
    
    sendBtn.layer.cornerRadius = 3.0;
    sendBtn.layer.masksToBounds = YES;
    
    self.navigationItem.title = [NSString stringWithFormat:@"@%@",[dictUser valueForKey:@"name"]];
    
    profile_pic.layer.cornerRadius = profile_pic.frame.size.height/2;
    profile_pic.layer.masksToBounds = YES;
    
    UIImageView *imgProfile = [[UIImageView alloc] init];
    [imgProfile sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dictUser valueForKey:@"profile_pic"]]] placeholderImage:[UIImage imageNamed:@""] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [profile_pic setBackgroundImage:image forState:UIControlStateNormal];
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(![[XmppHelper sharedInstance].xmppStream isAuthenticated])
    {
        if(![[XmppHelper sharedInstance].xmppStream isConnecting] && ![[XmppHelper sharedInstance].xmppStream isConnected])
        {
            [[XmppHelper sharedInstance] connect];
        }
    }
}

-(void)makeReadStatusForAllUnreadMessage
{
    NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatConversation"  inManagedObjectContext:context];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"senderId == %@ AND receiverId == %@ AND isGroupMessage == 0 AND isNew == 1", [XmppHelper sharedInstance].username,[dictUser valueForKey:@"user_id"]];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"messageDateTime" ascending:NO];
    [fetch setSortDescriptors:@[sortDescriptor]];
    
    NSArray *unreadMsgArray = [context executeFetchRequest:fetch error:nil];
    
    for(ChatConversation *chatObj in unreadMsgArray)
    {
        chatObj.isNew = @(NO);
        [[XmppHelper sharedInstance].managedObjectContext_chatMessage save:nil];
    }
}

-(void)refreshChatMessageTableForChatObj:(id)msgObj
{
    ChatConversation *chatObj = (ChatConversation *)msgObj;
    
    if([chatObj.receiverId isEqualToString:[dictUser valueForKey:@"user_id"]])
    {
        
        //[chatTableView reloadData];
        [self updateChatTable];
        
        if (chatTableView.contentSize.height > chatTableView.frame.size.height-(chatTableView.contentInset.top+chatTableView.contentInset.bottom))
        {
            CGPoint offset = CGPointMake(0, chatTableView.contentSize.height -  (chatTableView.frame.size.height-(chatTableView.contentInset.top+chatTableView.contentInset.bottom)));
            [chatTableView setContentOffset:offset animated:YES];
        }
    }
}

-(void)newMessageReceivedFrom:(NSString *)user withChatObj:(ChatConversation *)msgObj
{
    if([user isEqualToString:[dictUser valueForKey:@"user_id"]])
    {
        //[chatTableView reloadData];
        
        [self updateChatTable];
        
        if (chatTableView.contentSize.height > chatTableView.frame.size.height-(chatTableView.contentInset.top+chatTableView.contentInset.bottom))
        {
            CGPoint offset = CGPointMake(0, chatTableView.contentSize.height -  (chatTableView.frame.size.height-(chatTableView.contentInset.top+chatTableView.contentInset.bottom)));
            [chatTableView setContentOffset:offset animated:YES];
        }
    }
    else
    {
        [[XmppHelper sharedInstance] displayNavigationNotificationForChatObj:msgObj];
    }
}

-(void)markMessageAsRead:(NSString *)user withChatObj:(id)msgObj
{
    if([user isEqualToString:[dictUser valueForKey:@"user_id"]])
    {
        ChatConversation *chatObj = (ChatConversation *)msgObj;
        NSString *strIndexPath = chatObj.indexPath;
        
        NSArray *tmp = [strIndexPath componentsSeparatedByString:@":"];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[tmp[1] integerValue] inSection:[tmp[0] integerValue]];
        
        NSArray* rowsToReload = [NSArray arrayWithObjects:indexPath, nil];
        [chatTableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark --User is online--
- (void)userCameOnline:(NSString *)usernameStr
{
    if([[XmppHelper sharedInstance] isUserOnline:[dictUser valueForKey:@"user_id"]])
    {
        //lblUserOnlineStatus.text = @"Online";
    }
}

- (void)userWentOffline:(NSString *)usernameStr
{
    //lblUserOnlineStatus.text = @"Offline";
}

#pragma mark NSFetchedResultsController---------------------------------
- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController == nil)
    {
        
        NSManagedObjectContext *moc = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChatConversation"
                                                  inManagedObjectContext:moc];
        
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"messageDateTime" ascending:YES];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:@[sd1]];
        [fetchRequest setFetchBatchSize:100];
        //[fetchRequest setFetchLimit:20];
        
        
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"senderId == %@ AND receiverId == %@", [XmppHelper sharedInstance].username, [dictUser valueForKey:@"user_id"]];
        [fetchRequest setPredicate:predicate];
        
        
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                       managedObjectContext:moc
                                                                         sectionNameKeyPath:@"sectionIdentifier"
                                                                                  cacheName:nil];
        [fetchedResultsController setDelegate:self];
        
        
        NSError *error = nil;
        if (![fetchedResultsController performFetch:&error])
        {
            NSLog(@"Error performing fetch: %@", error);
        }
    }
    return fetchedResultsController;
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    //[chatTableView reloadData];
    [self updateChatTable];
    
    if (chatTableView.contentSize.height > chatTableView.frame.size.height-(chatTableView.contentInset.top+chatTableView.contentInset.bottom))
    {
        CGPoint offset = CGPointMake(0, chatTableView.contentSize.height - (chatTableView.frame.size.height-(chatTableView.contentInset.top+chatTableView.contentInset.bottom)));
        [chatTableView setContentOffset:offset animated:YES];
    }
}



-(NSString *)getUserJidStr
{
    XMPPUserCoreDataStorageObject *user = [[XmppHelper sharedInstance].xmppRosterStorage userForJID:[XMPPJID jidWithString:[[XmppHelper sharedInstance] getActualUsernameForUser:[dictUser valueForKey:@"user_id"]]] xmppStream:[XmppHelper sharedInstance].xmppStream managedObjectContext:[XmppHelper sharedInstance].managedObjectContext_roster];

    
//    XMPPUserCoreDataStorageObject *user = [[XmppHelper sharedInstance].xmppRosterStorage userForJID:[XMPPJID jidWithString:[[XmppHelper sharedInstance] getActualUsernameForUser:@"2"]] xmppStream:[XmppHelper sharedInstance].xmppStream managedObjectContext:[XmppHelper sharedInstance].managedObjectContext_roster];
    
    NSString *jidStr = [[XmppHelper sharedInstance] getActualUsernameForUser:[dictUser valueForKey:@"user_id"]];
    
    if(user.primaryResource)
    {
        jidStr = user.primaryResource.jid.full;
    }
    return jidStr;
}


-(void)updateChatTable
{
    NSArray *sections = [[self fetchedResultsController] sections];
    id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sections.count-1];
    
    NSInteger rows = [chatTableView numberOfRowsInSection:sections.count-1];
    //NSLog(@"%lu",(unsigned long)sectionInfo.numberOfObjects);
    //NSLog(@"%ld",(long)rows);
    
    NSInteger sectionCount = [chatTableView numberOfSections];
    
    NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:sectionInfo.numberOfObjects-1 inSection:sections.count-1]];
    if(sections.count == sectionCount)
    {
        if(sectionInfo.numberOfObjects > rows)
        {
            [chatTableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
            [self setIndexPathIntoObject:[paths objectAtIndex:0]];
        }
    }
    else if (sectionCount == sections.count-1)
    {
        [self setIndexPathIntoObject:[paths objectAtIndex:0]];
        [chatTableView reloadData];
    }
    else
    {
        [chatTableView reloadData];
    }
}


-(void)setIndexPathIntoObject:(NSIndexPath *)indexPath
{
    ChatConversation *chatObj = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    NSString *strIndexPath = [NSString stringWithFormat:@"%ld:%ld", (long)indexPath.section, (long)indexPath.row];
    NSLog(@"%@",strIndexPath);
    [chatObj setIndexPath:strIndexPath];
    
    //    NSError *error;
    //    if(![[XmppHelper sharedInstance].managedObjectContext_chatMessage save:&error])
    //    {
    //        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
    //    }
}


#pragma mark --Send Button Action--

- (IBAction)sendBtnClicked:(UIButton *)sender
{
    if([[chatTextView.text lowercaseString] isEqualToString:[NSLocalizedString(@"Type Message", nil) lowercaseString]])
    {
        return;
    }
    
    if([chatTextView.text length]==0)
    {
        chatTextViewHeightConstraint.constant = 35.0;
        return;
    }
    
    NSString *messageID=[[XmppHelper sharedInstance] generateUniqueID];
    
    chatTextView.text = [chatTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *msgVal = chatTextView.text;
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:msgVal];
    
    NSXMLElement *chatDetail = [NSXMLElement elementWithName:@"chatDetail" xmlns:@"jabber:x:oob"];
    NSXMLElement *name = [NSXMLElement elementWithName:@"name" stringValue:[NSString stringWithFormat:@"%@",[LoggedInUser sharedUser].userVibeName]];
    [chatDetail addChild:name];
    
    NSXMLElement *profile_pic1 = [NSXMLElement elementWithName:@"profile_pic" stringValue:[LoggedInUser sharedUser].userProfilePic];
    [chatDetail addChild:profile_pic1];
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:CHAT_TYPE_SINGLE];
    [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@",[XMPPJID jidWithString:[self getUserJidStr]]]];
    [message addAttributeWithName:@"id" stringValue:messageID];
    [message addChild:body];
    [message addChild:chatDetail];
    
    [[[XmppHelper sharedInstance] xmppStream] sendElement:message];
    //[self sendNotification:msgVal];
    chatTextViewHeightConstraint.constant = 35.0;
    [chatTextView resignFirstResponder];
    
    chatTextView.text = [NSLocalizedString(@"Type Message", nil) uppercaseString];
    chatTextView.textColor = [UIColor colorWithRed:93.0/255.0 green:93.0/255.00 blue:93.0/255.00 alpha:1.0];
    [self createRecentChatArray:msgVal];
    //[arrIndePathDeleted removeAllObjects];
}


#pragma mark Header button
- (IBAction)btnBack:(UIButton *)sender
{
    [self chageCountStatusOfRecentArray];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnProfilePic:(UIButton *)sender
{
    NSDictionary *dictInfo = @{@"name":[dictUser valueForKey:@"name"],@"profile_pic":[dictUser valueForKey:@"profile_pic"]};
    
    [self performSegueWithIdentifier:@"profile" sender:dictInfo];
}

-(void)chageCountStatusOfRecentArray
{
    NSMutableArray *arrRecent = [[NSMutableArray alloc]init];
    arrRecent = [[kPref valueForKey:kRecentChatArray] mutableCopy];
    for(int k = 0;k<arrRecent.count;k++)
    {
        if([[[arrRecent objectAtIndex:k] valueForKey:@"type"] isEqualToString:CHAT_TYPE_SINGLE])
        {
            if([[dictUser valueForKey:@"user_id"] isEqualToString:[[arrRecent objectAtIndex:k] valueForKey:@"user_id"]])
            {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                dict = [[arrRecent objectAtIndex:k] mutableCopy];
                int count = 0;
                [dict removeObjectForKey:@"count"];
                [dict setValue:[NSNumber numberWithInt:count] forKey:@"count"];
                [arrRecent replaceObjectAtIndex:k withObject:dict];
                [kPref setObject:arrRecent forKey:kRecentChatArray];
                break;
            }
        }
    }
}

#pragma mark --PrepareForSegue Method
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"profile"])
    {
        ProfileImageController *obj = [segue destinationViewController];
        obj.dictinfo = (NSDictionary *)sender;
    }
}

#pragma mark --Recent Array--

-(void)createRecentChatArray:(NSString *)strMsg
{
    BOOL isAlready = false;
    
    NSDateFormatter *dateFormate = [[NSDateFormatter alloc]init];
    [dateFormate setDateFormat:@"dd/MM/yyyy hh:mm a"];
    NSString *time = [dateFormate stringFromDate:[NSDate date]];
    
    NSArray *recentMag = [[kPref valueForKey:kRecentChatArray] mutableCopy];
    NSMutableArray *arrRecent = [[NSMutableArray alloc]init];
    [arrRecent addObjectsFromArray:recentMag];
    
    for(int i = 0;i<arrRecent.count;i++)
    {
        if([[[arrRecent objectAtIndex:i] valueForKey:@"type"] isEqualToString:CHAT_TYPE_SINGLE])
        {
            if([[dictUser valueForKey:@"user_id"] isEqualToString:[[arrRecent objectAtIndex:i] valueForKey:@"user_id"] ])
            {
                int count = 0;
                [arrRecent removeObjectAtIndex:i];
                
                NSMutableDictionary *dictRecent = [[NSMutableDictionary alloc]init];
                [dictRecent setValue:[dictUser valueForKey:@"profile_pic"] forKey:@"profile_pic"];
                [dictRecent setValue:[dictUser valueForKey:@"user_id"] forKey:@"user_id"];
                [dictRecent setValue:[dictUser valueForKey:@"name"] forKey:@"name"];
                [dictRecent setValue:strMsg forKey:@"message"];
                [dictRecent setValue:time forKey:@"time"];
                [dictRecent setValue:CHAT_TYPE_SINGLE forKey:@"type"];
                [dictRecent setValue:[NSNumber numberWithInt:count] forKey:@"count"];
                [arrRecent addObject:dictRecent];
                [kPref setObject:arrRecent forKey:kRecentChatArray];
                isAlready = true;
                break;
            }
        }
    }
    if(!isAlready)
    {
        int count = 0;
        NSMutableDictionary *dictRecent = [[NSMutableDictionary alloc]init];
        [dictRecent setValue:[dictUser valueForKey:@"profile_pic"] forKey:@"profile_pic"];
        [dictRecent setValue:[dictUser valueForKey:@"user_id"] forKey:@"user_id"];
        [dictRecent setValue:[dictUser valueForKey:@"name"] forKey:@"name"];
        [dictRecent setValue:strMsg forKey:@"message"];
        [dictRecent setValue:time forKey:@"time"];
        [dictRecent setValue:CHAT_TYPE_SINGLE forKey:@"type"];
        [dictRecent setValue:[NSNumber numberWithInt:count] forKey:@"count"];
        [arrRecent addObject:dictRecent];
        [kPref setObject:arrRecent forKey:kRecentChatArray];
    }
}

#pragma mark --Tableview Delegate Method--

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *sections = [[self fetchedResultsController] sections];
    return [sections count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *CellIdentifier = @"ChatSectionHeaderCell";
    UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    UILabel *headerLabel = (UILabel *)[headerView viewWithTag:100];
    NSArray *sections = [[self fetchedResultsController] sections];
    
    if (section < [sections count])
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        
        NSString *sectionNameStr = [sectionInfo name];
        
        NSArray *componentArray = [sectionNameStr componentsSeparatedByString:@"_"];
        
        NSInteger year = [[componentArray objectAtIndex:0] integerValue];
        NSInteger month = [[componentArray objectAtIndex:1] integerValue];
        NSInteger day = [[componentArray objectAtIndex:2] integerValue];
        
        
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        dateComponents.year = year;
        dateComponents.month = month;
        dateComponents.day = day;
        NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
        
        headerLabel.text = [NSString stringWithFormat:@" %@  ",[Utility timeDaysForDate:date]];
        
        headerLabel.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        headerLabel.layer.cornerRadius = 4.0;
        headerLabel.layer.masksToBounds = YES;
        [headerView layoutIfNeeded];
        
        return headerView;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = [[self fetchedResultsController] sections];
    
    if (section < [sections count])
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        return sectionInfo.numberOfObjects;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatConversation *chatObj = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    //NSLog(@"%@",chatObj.messageType);
    if([chatObj.messageType isEqualToString:OUT_BOUND_MESSAGE_TYPE_IMAGE] || [chatObj.messageType isEqualToString:OUT_BOUND_MESSAGE_TYPE_VIDEO])
    {
        return 142.0;
    }
    else
    {
        if([chatObj.isMessageReceived boolValue])
        {
            ReceiverChatMsgCell *cell = [chatScreenCells objectForKey:@"ReceiverChatMsgCell"];
            if (!cell && cell.tag!=-1)
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"ReceiverChatMsgCell"];
                cell.tag = -1;
                [chatScreenCells setObject:cell forKey:@"ReceiverChatMsgCell"];
            }
            
            //cell.chatMessageTxt.selectable = NO;
            cell.chatMessageTxt.text = chatObj.messageBody;
            cell.chatMessageTxt.font = [UIFont systemFontOfSize:14.0];
            
            CGSize sizeThatFitsTextView = [cell.chatMessageTxt sizeThatFits:CGSizeMake(maxChatTextWidth, MAXFLOAT)];
            cell.msgTxtWidthConstraint.constant = sizeThatFitsTextView.width;
            cell.msgTxtHeightConstraint.constant = sizeThatFitsTextView.height;
            NSLog(@"%f",cell.msgTxtWidthConstraint.constant);
            
            [cell setNeedsLayout];
            [cell layoutIfNeeded];
            
            if(cell.msgTxtWidthConstraint.constant + 50.0 <= maxChatTextWidth)
            {
                CGFloat height = cell.msgTxtHeightConstraint.constant;
                return height;
            }
            
            return cell.msgTxtHeightConstraint.constant + 13.0;
        }
        else
        {
            SenderChatMsgCell *cell = [chatScreenCells objectForKey:@"SenderChatMsgCell"];
            if (!cell && cell.tag!=-1)
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"SenderChatMsgCell"];
                cell.tag = -1;
            }
            
            //cell.chatMessageTxt.selectable = NO;
            cell.chatMessageTxt.text = chatObj.messageBody;
            
            cell.chatMessageTxt.font = [UIFont systemFontOfSize:14.0];
            
            CGSize sizeThatFitsTextView = [cell.chatMessageTxt sizeThatFits:CGSizeMake(maxChatTextWidth, MAXFLOAT)];
            cell.msgTxtWidthConstraint.constant = sizeThatFitsTextView.width;
            cell.msgTxtHeightConstraint.constant = sizeThatFitsTextView.height;
            
            [cell setNeedsLayout];
            [cell layoutIfNeeded];
            if(cell.msgTxtWidthConstraint.constant + 58.0 <= maxChatTextWidth)
            {
                CGFloat height = cell.msgTxtHeightConstraint.constant;
                return height;
            }
            
            return cell.msgTxtHeightConstraint.constant + 13.0;
        }
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatConversation *chatObj = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    if([chatObj.messageType isEqualToString:OUT_BOUND_MESSAGE_TYPE_IMAGE])
    {
        return nil;
    }
    else
    {
        if([chatObj.isMessageReceived boolValue])
        {
            ReceiverChatMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReceiverChatMsgCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.chatObj = chatObj;
            
            cell.chatTimeLbl.text = chatObj.messageTimeStr;
            //NSLog(@"Chat Emoji : %@",chatObj.messageTimeStr);
            cell.chatTimeLbl.hidden = false;
            //cell.chatMessageTxt.selectable = YES;
            cell.chatMessageTxt.text = chatObj.messageBody;
            
            CGSize sizeThatFitsTextView = [cell.chatMessageTxt sizeThatFits:CGSizeMake(maxChatTextWidth, MAXFLOAT)];
            cell.msgTxtWidthConstraint.constant = sizeThatFitsTextView.width;
            cell.msgTxtHeightConstraint.constant = sizeThatFitsTextView.height;
            
            if(cell.msgTxtWidthConstraint.constant + 50.0 <= maxChatTextWidth)
            {
                cell.chatMessageTxt.text = chatObj.messageBody;
                cell.msgTxtWidthConstraint.constant = sizeThatFitsTextView.width + 50.0;
            }
            
            if([chatObj.isNew boolValue])
            {
                //DLog(@"New message");
                [chatObj setIsNew:@(NO)];
                
                [[XmppHelper sharedInstance].managedObjectContext_chatMessage save:nil];
                
            }
            [cell layoutIfNeeded];
            
            return cell;
        }
        else
        {
            SenderChatMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SenderChatMsgCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.chatObj = chatObj;
            
            cell.chatTimeLbl.text = chatObj.messageTimeStr;
            cell.chatTimeLbl.hidden = false;
            cell.msgReadStatusImage.hidden = false;
            
            //cell.chatMessageTxt.selectable = YES;
            cell.chatMessageTxt.text = chatObj.messageBody;
            
            //NSLog(@"%@",cell.chatMessageTxt.text);
            
            CGSize sizeThatFitsTextView = [cell.chatMessageTxt sizeThatFits:CGSizeMake(maxChatTextWidth, MAXFLOAT)];
            cell.msgTxtWidthConstraint.constant = sizeThatFitsTextView.width;
            cell.msgTxtHeightConstraint.constant = sizeThatFitsTextView.height;
            //NSLog(@"%f",cell.msgTxtWidthConstraint.constant+58.0);
            if(cell.msgTxtWidthConstraint.constant + 58.0 <= maxChatTextWidth)
            {
                cell.chatMessageTxt.text = chatObj.messageBody;
                //NSLog(@"%f",cell.msgTxtWidthConstraint.constant);
                cell.msgTxtWidthConstraint.constant = sizeThatFitsTextView.width + 65.0;
                //NSLog(@"%f",cell.msgTxtWidthConstraint.constant);
                
                //NSLog(@"%@",cell.chatMessageTxt);
            }
            
            if([chatObj.isNew boolValue])
            {
                //DLog(@"New message");
                [chatObj setIsNew:@(NO)];
                [[XmppHelper sharedInstance].managedObjectContext_chatMessage save:nil];
            }
            
            if([chatObj.isPending boolValue])
            {
                cell.msgReadStatusImage.highlighted = NO;
            }
            else
            {
                cell.msgReadStatusImage.highlighted = YES;
            }
            
            [cell setNeedsLayout];
            [cell layoutIfNeeded];
            
            return cell;
        }
    }
    return nil;
}

#pragma mark --Keyboard show/hide notifications--

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note
{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    chatBoxViewBottomSpaceConstraint.constant = keyboardBounds.size.height - 50;
    
    // commit animations
    [UIView commitAnimations];
    
    [self.view layoutIfNeeded];
    
    
    if (chatTableView.contentSize.height > chatTableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, chatTableView.contentSize.height - chatTableView.frame.size.height);
        [chatTableView setContentOffset:offset animated:YES];
    }
    
}

-(void) keyboardWillHide:(NSNotification *)note
{
    
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    chatBoxViewBottomSpaceConstraint.constant = 0;
    
    // commit animations
    [UIView commitAnimations];
}

#pragma mark --UITextView delegate methods--
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if([[textView.text lowercaseString] isEqualToString:[NSLocalizedString(@"Type Message", nil) lowercaseString]])
    {
        textView.text = @"";
    }
    textView.textColor = [UIColor blackColor];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    textView.text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([textView.text length]==0)
    {
        textView.text = [NSLocalizedString(@"Type Message", nil) uppercaseString];
    }
    
    textView.textColor = [UIColor colorWithRed:93.0/255.0 green:93.0/255.00 blue:93.0/255.00 alpha:1.0];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if([textView contentSize].height <120.0)
    {
        chatTextViewHeightConstraint.constant = [textView contentSize].height;
        
        CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.end];
        cursorRect= CGRectMake(cursorRect.origin.x, cursorRect.origin.y-3, cursorRect.size.width, cursorRect.size.height);
        [chatTextView scrollRectToVisible:cursorRect animated:YES];
        //WLog(@"height = %f", chatTextViewHeightConstraint.constant);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



@end
