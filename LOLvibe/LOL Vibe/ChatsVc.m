//
//  ChatsVc.m
//  LOL Vibe
//
//  Created by Paras Navadiya on 05/05/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "ChatsVc.h"
#import "ServiceConstant.h"
#import "ChatViewController.h"
#import "GroupChatController.h"

@interface ChatsVc ()
{
    NSMutableArray *arrRecentChat;
}

@end

@implementation ChatsVc

- (void)viewDidLoad
{
    [super viewDidLoad];
    [tblRecentChat registerNib:[UINib nibWithNibName:@"RecentChatCell" bundle:nil] forCellReuseIdentifier:@"RecentChatCell"];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveNewMessage:) name:kNewMsgRecived object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    arrRecentChat = [[NSMutableArray alloc]init];
    arrRecentChat = [[[kPref valueForKey:kRecentChatArray] reverseObjectEnumerator] allObjects];
    [tblRecentChat reloadData];
}

#pragma mark -Reload Tableview When New Message Received

-(void)receiveNewMessage:(NSNotification *)notification
{
    arrRecentChat = [[NSMutableArray alloc]init];
    arrRecentChat = [[[kPref valueForKey:kRecentChatArray] reverseObjectEnumerator] allObjects];
    [tblRecentChat reloadData];
}

#pragma mark Tableview Delegate Method

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  arrRecentChat.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecentChatCell"];
    
    UIImageView *imgProfilePic  = (UIImageView *)[cell viewWithTag:101];
    UILabel *lblPersonName      = (UILabel *)[cell viewWithTag:102];
    UILabel *lblMsg             = (UILabel *)[cell viewWithTag:103];
    UILabel *lblTime            = (UILabel *)[cell viewWithTag:104];
    UILabel *lblCount           = (UILabel *)[cell viewWithTag:105];
    
    
    imgProfilePic.layer.cornerRadius = imgProfilePic.frame.size.height /2;
    imgProfilePic.layer.masksToBounds = YES;
    
    lblCount.layer.cornerRadius = lblCount.frame.size.height/2;
    lblCount.layer.masksToBounds = YES;
    
    [imgProfilePic  sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[arrRecentChat objectAtIndex:indexPath.row] valueForKey:@"profile_pic"]]] placeholderImage:[UIImage imageNamed:@"default_user_image"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        imgProfilePic.image = image;
        
    }];
    
    lblPersonName.text = [[arrRecentChat objectAtIndex:indexPath.row] valueForKey:@"name"];
    lblMsg.text = [[arrRecentChat objectAtIndex:indexPath.row] valueForKey:@"message"];
    
    lblTime.text = [self getDateAndTime:[[arrRecentChat objectAtIndex:indexPath.row] valueForKey:@"time"]];
    
    if([[[arrRecentChat objectAtIndex:indexPath.row] valueForKey:@"count"] intValue] > 0)
    {
        lblCount.hidden = false;
        lblCount.text = [NSString stringWithFormat:@"%d",[[[arrRecentChat objectAtIndex:indexPath.row]   valueForKey:@"count"] intValue]];
        lblTime.textColor = [UIColor colorWithRed:80.0/255.0 green:164.0/255.0 blue:52.0/255.0 alpha:1.0];
    }
    else
    {
        lblTime.textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
        lblCount.hidden = true;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    dict = [[arrRecentChat objectAtIndex:indexPath.row] mutableCopy];
    int count = 0;
    [dict removeObjectForKey:@"count"];
    [dict setValue:[NSNumber numberWithInt:count] forKey:@"count"];
    [arrRecentChat replaceObjectAtIndex:indexPath.row withObject:dict];
    [kPref setObject:[[arrRecentChat reverseObjectEnumerator] allObjects] forKey:kRecentChatArray];
    
    NSDictionary *dictRecent = [arrRecentChat objectAtIndex:indexPath.row];
    
    if([[dictRecent valueForKey:@"type"] isEqualToString:CHAT_TYPE_SINGLE])
    {
        [self performSegueWithIdentifier:@"chatController" sender:dictRecent];
    }
    else if ([[dictRecent valueForKey:@"type"] isEqualToString:CHAT_TYPE_GROUP])
    {
        [self performSegueWithIdentifier:@"groupChat" sender:dictRecent];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self deleteObject:[arrRecentChat objectAtIndex:indexPath.row]];
        [arrRecentChat removeObjectAtIndex:indexPath.row];
        [tblRecentChat reloadData];
        [kPref setObject:arrRecentChat forKey:kRecentChatArray];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75.0;
}


-(void)deleteObject:(NSDictionary *)dictUser
{
    
    if([[dictUser valueForKey:@"type"]isEqualToString:CHAT_TYPE_SINGLE])
    {
        NSManagedObjectContext *moc = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"ChatConversation" inManagedObjectContext:moc]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"senderId == %@ AND receiverId == %@", [XmppHelper sharedInstance].username, [dictUser valueForKey:@"user_id"]];
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *array = [moc executeFetchRequest:fetchRequest error:&error];
        
        if (array != nil)
        {
            for(NSManagedObject* object in array)
            {
                [moc deleteObject:object];
            }
            [moc save:&error];
        }
    }
    else if ([[dictUser valueForKey:@"type"] isEqualToString:CHAT_TYPE_GROUP])
    {
        
        NSManagedObjectContext *moc = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"ChatConversation" inManagedObjectContext:moc]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"senderId == %@ AND receiverId == %@ AND isGroupMessage == 1", [XmppHelper sharedInstance].username, [dictUser valueForKey:@"group_id"]];
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *array = [moc executeFetchRequest:fetchRequest error:&error];
        
        if (array != nil)
        {
            for(NSManagedObject* object in array)
            {
                [moc deleteObject:object];
            }
            [moc save:&error];
        }
    }
}

#pragma mark PrepareForSegue Method
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"chatController"])
    {
        ChatViewController *obj = [segue destinationViewController];
        obj.dictUser = (NSDictionary *)sender;
    }
    else if ([[segue identifier] isEqualToString:@"groupChat"])
    {
        GroupChatController *obj = [segue destinationViewController];
        obj.dictUser = (NSDictionary *)sender;
    }
}

#pragma mark --Date calculation---

-(NSString *)getDateAndTime:(NSString *)dateTime
{
    NSString *strLabel;
    NSDateFormatter *dateFormate1 = [[NSDateFormatter alloc]init];
    [dateFormate1 setDateFormat:@"dd/MM/yyyy hh:mm a"];
    NSDate *daterecent = [dateFormate1 dateFromString:dateTime];
    [dateFormate1 setDateFormat:@"dd/MM/yyyy"];
    NSString *strDate1 = [dateFormate1 stringFromDate:daterecent];
    NSString *strTodaydate = [dateFormate1 stringFromDate:[NSDate date]];
    
    NSDate *dateRecent = [dateFormate1 dateFromString:strDate1];
    NSDate *dateToday = [dateFormate1 dateFromString:strTodaydate];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [gregorianCalendar setTimeZone:timeZone];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:dateToday
                                                          toDate:dateRecent
                                                         options:NSCalendarWrapComponents];
    
    if([components day] == 0)
    {
        NSDateFormatter *dateFormate2 = [[NSDateFormatter alloc]init];
        [dateFormate2 setDateFormat:@"hh:mm a"];
        strLabel = [dateFormate2 stringFromDate:daterecent];
        return strLabel;
    }
    else if ([components day] == -1)
    {
        strLabel = @"Yesterday";
        return strLabel;
    }
    else
    {
        strLabel = strDate1;
        return strLabel;
    }
    return strLabel;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}





@end
