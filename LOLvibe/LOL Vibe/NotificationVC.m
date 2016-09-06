//
//  NotificationVC.m
//  LOL Vibe
//
//  Created by Paras Navadiya on 05/05/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "NotificationVC.h"
#import "ServiceConstant.h"
#import "recentNotificationCell.h"
#import "UIImageView+WebCache.h"
#import "UIView+SuperView.h"
#import "LocationInviteDetails.h"
#import "PostDetails.h"
#import "OtherProfileVC.h"
#import "CommentController.h"

@interface NotificationVC ()<WebServiceDelegate>
{
    NSMutableArray *arrRecentNotification;
    NSMutableArray *arrRequest;
    UIRefreshControl *refreshControl;
}

@end

@implementation NotificationVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [segment setSelectedSegmentIndex:0];
    
    [tblRecent registerNib:[UINib nibWithNibName:@"recentNotificationCell" bundle:nil] forCellReuseIdentifier:@"recentNotificationCell"];
    
    refreshControl = [[UIRefreshControl alloc]init];
    [tblRecent addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
}

- (void)refreshTable {
    
    [self getNotifiactionList:NO];
    [refreshControl endRefreshing];
    [tblRecent reloadData];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [self getNotifiactionList:NO];
    self.title =@"Notifications";
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.title = @"";
}
-(void)getNotifiactionList:(BOOL)isLoading
{
    NSMutableDictionary *dictnotifiacation = [[NSMutableDictionary alloc] init];
    
    WebService *sernotifiation = [[WebService alloc] initWithView:self.view andDelegate:self];
    
    [sernotifiation callWebServiceWithURLDict:NOTIFICATION_LIST
                                andHTTPMethod:@"POST"
                                  andDictData:dictnotifiacation
                                  withLoading:isLoading
                             andWebServiceTag:@"notificationList"
                                     setToken:YES];
}


#pragma mark Tabliew Delegate Method


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(segment.selectedSegmentIndex == 0)
    {
        return arrRecentNotification.count;
    }
    else
    {
        return arrRequest.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(segment.selectedSegmentIndex == 0)
    {
        recentNotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recentNotificationCell"];
        
        [cell.btnPostDetails addTarget:self action:@selector(btnPostDetails:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.imgProfile sd_setImageWithURL:[NSURL URLWithString:[[arrRecentNotification objectAtIndex:indexPath.row] valueForKey:@"profile_pic"]] placeholderImage:[UIImage imageNamed:@"default_user_image.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            cell.imgProfile.image = image;
            if (!image)
            {
                cell.imgProfile.image =[UIImage imageNamed:@"default_user_image.png"];
            }
        }];
        
        if([[[arrRecentNotification objectAtIndex:indexPath.row] valueForKey:@"notification_type"] intValue] == 4)
        {
            cell.imgNotiType.highlighted = YES;
            cell.lblPostType.text = @"on your post.";
        }
        else
        {
            cell.imgNotiType.highlighted = NO;
            cell.lblPostType.text = @"your post.";
        }
        
        [cell.imgOther sd_setImageWithURL:[NSURL URLWithString:[[arrRecentNotification objectAtIndex:indexPath.row] valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"default_user_image.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            cell.imgOther.image = image;
            if (!image)
            {
                cell.imgOther.image =[UIImage imageNamed:@"default_user_image.png"];
            }
        }];
        cell.lblTime.text = [[arrRecentNotification objectAtIndex:indexPath.row] valueForKey:@"created_at"];
        
        NSString *strname = [NSString stringWithFormat:@"%@",[[arrRecentNotification objectAtIndex:indexPath.row] valueForKey:@"text"]];
        
        NSString *firstWord = [[strname componentsSeparatedByString:@" "] objectAtIndex:0];
        
        cell.lblName.text = firstWord;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"requestInviteCell"];
        
        UIImageView *imgProfile         = (UIImageView *)[cell viewWithTag:101];
        UILabel *lblText                = (UILabel *)[cell viewWithTag:102];
        UILabel *lblTime                = (UILabel *)[cell viewWithTag:111];
        UIButton *btnAccept             = (UIButton *)[cell viewWithTag:103];
        UIButton *btnDecline            = (UIButton *)[cell viewWithTag:104];
        UIButton *btnLocationInvite     = (UIButton *)[cell viewWithTag:999];
        UIImageView *imgLoation         = (UIImageView *)[cell viewWithTag:105];
        
        btnAccept.layer.cornerRadius = 3.0;
        btnAccept.layer.masksToBounds = YES;
        btnDecline.layer.borderWidth = 1.0;
        btnDecline.layer.borderColor = [UIColor blackColor].CGColor;
        btnDecline.layer.cornerRadius = 3.0;
        btnDecline.layer.masksToBounds = YES;
        [btnLocationInvite addTarget:self action:@selector(btnLocationInvite1:) forControlEvents:UIControlEventTouchUpInside];
        
        NSDictionary *dictvalue = [arrRequest objectAtIndex:indexPath.row];
        
        [imgProfile sd_setImageWithURL:[NSURL URLWithString:[dictvalue valueForKey:@"profile_pic"]] placeholderImage:[UIImage imageNamed:@"default_user_image.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            imgProfile.image = image;
            if (!image)
            {
                imgProfile.image =[UIImage imageNamed:@"default_user_image.png"];
            }
        }];
        
        NSString *fullString = [dictvalue valueForKey:@"text"];
        
        NSString *boldString = [[[dictvalue valueForKey:@"text"] componentsSeparatedByString:@" "] objectAtIndex:0];
        
        NSMutableAttributedString *attributedText =[[NSMutableAttributedString alloc] initWithString:fullString];
        
        [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:12.0]} range:[fullString rangeOfString:boldString]];
        
        lblText.attributedText = attributedText;
        
        lblTime.text = [[arrRequest objectAtIndex:indexPath.row] valueForKey:@"created_at"];
        
        [btnAccept setHidden:NO];
        [btnDecline setHidden:NO];
        
        NSString *strURL = [[dictvalue valueForKey:@"image"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [imgLoation sd_setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:@"default_user_image.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            imgLoation.image = image;
            
            if (!image)
            {
                imgLoation.image =[UIImage imageNamed:@"default_user_image.png"];
            }
        }];
        
        if([[dictvalue valueForKey:@"notification_type"] intValue] == 7)
        {
            [btnAccept setTitle:@"Confirm" forState:UIControlStateNormal];
            [btnDecline setTitle:@"Delete" forState:UIControlStateNormal];
            [lblTime setHidden:YES];
        }
        else if([[dictvalue valueForKey:@"notification_type"] intValue] == 5)
        {
            [btnAccept setTitle:@"Aceept" forState:UIControlStateNormal];
            [btnDecline setTitle:@"Decline" forState:UIControlStateNormal];
            [lblTime setHidden:YES];
        }
        else if([[dictvalue valueForKey:@"notification_type"] intValue] == 2)
        {
            [lblTime setHidden:NO];
            [btnAccept setHidden:YES];
            [btnDecline setHidden:YES];
            [imgLoation setImage:[UIImage imageNamed:@"check"]];
        }
        else if([[dictvalue valueForKey:@"notification_type"] intValue] == 6)
        {
            [lblTime setHidden:NO];
            [btnAccept setHidden:YES];
            [btnDecline setHidden:YES];
        }
        else if([[dictvalue valueForKey:@"notification_type"] intValue] == 1)
        {
            [lblTime setHidden:NO];
            [btnAccept setHidden:YES];
            [btnDecline setHidden:YES];
        }
        else if([[dictvalue valueForKey:@"notification_type"] intValue] == 0)
        {
            [lblTime setHidden:NO];
            [btnAccept setHidden:YES];
            [btnDecline setHidden:YES];
        }
        
        btnDecline.accessibilityLabel = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
        btnAccept.accessibilityLabel = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
        
        [btnAccept addTarget:self action:@selector(btnAcceptrequest:) forControlEvents:UIControlEventTouchUpInside];
        [btnDecline addTarget:self action:@selector(btnDeclineRequest:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(segment.selectedSegmentIndex == 0)
    {
        if ([[[arrRecentNotification objectAtIndex:indexPath.row] valueForKey:@"user_id"] isEqualToString:[LoggedInUser sharedUser].userId])
        {
            return;
        }
        [self performSegueWithIdentifier:@"profile" sender:[arrRecentNotification objectAtIndex:indexPath.row]];
    }
    else
    {
        if ([[[arrRequest objectAtIndex:indexPath.row] valueForKey:@"user_id"] isEqualToString:[LoggedInUser sharedUser].userId])
        {
            return;
        }
        [self performSegueWithIdentifier:@"profile" sender:[arrRequest objectAtIndex:indexPath.row]];
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(segment.selectedSegmentIndex == 0)
    {
        return 60.0;
    }
    else
    {
        return 70.0;
    }
}


#pragma mark --Accept and Decline Button action
-(void)btnAcceptrequest:(UIButton *)sender
{
    NSInteger index = [sender.accessibilityLabel integerValue];
    NSDictionary *dictVale = [arrRequest objectAtIndex:index];
    WebService *serRequest = [[WebService alloc] initWithView:self.view andDelegate:self];
    
    if([[dictVale valueForKey:@"notification_type"] intValue] == 7)
    {
        NSMutableDictionary *dictPara = [[NSMutableDictionary alloc] init];
        [dictPara setValue:[dictVale valueForKey:@"other_user_id"] forKey:@"other_user_id"];
        [dictPara setValue:@"1" forKey:@"is_accept"];
        [dictPara setValue:[dictVale valueForKey:@"notification_id"] forKey:@"notification_id"];
        
        [serRequest callWebServiceWithURLDict:FRIEND_REQUEST_ACCEPT andHTTPMethod:@"POST" andDictData:dictPara withLoading:YES andWebServiceTag:@"requestType" setToken:YES];
    }
    else if ([[dictVale valueForKey:@"notification_type"] intValue] == 5)
    {
        NSMutableDictionary *dictPara = [[NSMutableDictionary alloc] init];
        [dictPara setValue:[dictVale valueForKey:@"parent_id"] forKey:@"invite_id"];
        [dictPara setValue:@"1" forKey:@"is_accept"];
        [dictPara setValue:[dictVale valueForKey:@"notification_id"] forKey:@"notification_id"];
        
        [serRequest callWebServiceWithURLDict:LOCATION_INVITATION_ACCEPT andHTTPMethod:@"POST" andDictData:dictPara withLoading:YES andWebServiceTag:@"requestType" setToken:YES];
    }
    
    NSMutableArray *arrtemp = [[NSMutableArray alloc] init];
    [arrtemp addObjectsFromArray:arrRequest];
    [arrtemp removeObjectAtIndex:index];
    arrRequest = arrtemp;
}

-(void)btnDeclineRequest:(UIButton *)sender
{
    NSInteger index = [sender.accessibilityLabel integerValue];
    NSDictionary *dictVale = [arrRequest objectAtIndex:index];
    
    WebService *serRequest = [[WebService alloc] initWithView:self.view andDelegate:self];
    
    if([[dictVale valueForKey:@"notification_type"] intValue] == 7)
    {
        NSMutableDictionary *dictPara = [[NSMutableDictionary alloc] init];
        [dictPara setValue:[dictVale valueForKey:@"other_user_id"] forKey:@"other_user_id"];
        [dictPara setValue:@"0" forKey:@"is_accept"];
        [dictPara setValue:[dictVale valueForKey:@"notification_id"] forKey:@"notification_id"];
        
        [serRequest callWebServiceWithURLDict:FRIEND_REQUEST_ACCEPT andHTTPMethod:@"POST" andDictData:dictPara withLoading:YES andWebServiceTag:@"requestType" setToken:YES];
    }
    else if ([[dictVale valueForKey:@"notification_type"] intValue] == 5)
    {
        NSMutableDictionary *dictPara = [[NSMutableDictionary alloc] init];
        [dictPara setValue:[dictVale valueForKey:@"parent_id"] forKey:@"invite_id"];
        [dictPara setValue:@"2" forKey:@"is_accept"];
        [dictPara setValue:[dictVale valueForKey:@"notification_id"] forKey:@"notification_id"];
        
        [serRequest callWebServiceWithURLDict:LOCATION_INVITATION_ACCEPT andHTTPMethod:@"POST" andDictData:dictPara withLoading:YES andWebServiceTag:@"requestType" setToken:YES];
    }
    
    NSMutableArray *arrtemp = [[NSMutableArray alloc] init];
    [arrtemp addObjectsFromArray:arrRequest];
    [arrtemp removeObjectAtIndex:index];
    arrRequest = arrtemp;
}
-(void)btnLocationInvite1:(UIButton *)sender
{
    UITableViewCell *cell = (UITableViewCell *)[sender findSuperViewWithClass:[UITableViewCell class]];
    
    NSIndexPath *indexPath = [tblRecent indexPathForCell:cell];
    
    NSString *strSelectedFriend;
    
    if([[[arrRequest objectAtIndex:indexPath.row] valueForKey:@"notification_type"] intValue] == 5 || [[[arrRequest objectAtIndex:indexPath.row] valueForKey:@"notification_type"] intValue] == 1)
    {
        strSelectedFriend = [NSString stringWithFormat:@"%@,%@",[[arrRequest objectAtIndex:indexPath.row] valueForKey:@"parent_id"],[[arrRequest objectAtIndex:indexPath.row] valueForKey:@"text"]];
        [self performSegueWithIdentifier:@"location_invite_details" sender:strSelectedFriend];
    }
    else if([[[arrRequest objectAtIndex:indexPath.row] valueForKey:@"notification_type"] intValue] == 6 || [[[arrRequest objectAtIndex:indexPath.row] valueForKey:@"notification_type"] intValue] == 0)
    {
        strSelectedFriend = [NSString stringWithFormat:@"%@,%@",[[arrRequest objectAtIndex:indexPath.row] valueForKey:@"parent_id"],[[arrRequest objectAtIndex:indexPath.row] valueForKey:@"text"]];
        
        [self performSegueWithIdentifier:@"location_invite_details" sender:strSelectedFriend];
    }
}

-(void)btnPostDetails:(UIButton *)sender
{
    UITableViewCell *cell = (UITableViewCell *)[sender findSuperViewWithClass:[UITableViewCell class]];
    NSIndexPath *indexPath = [tblRecent indexPathForCell:cell];
    
    if([[[arrRecentNotification objectAtIndex:indexPath.row] valueForKey:@"notification_type"] intValue] == 4)
    {
        NSString *dictObj = [[arrRecentNotification objectAtIndex:indexPath.row] valueForKey:@"feed_id"];
        [self performSegueWithIdentifier:@"push_to_detail" sender:dictObj];
    }
    else
    {
        NSString *dictObj = [[arrRecentNotification objectAtIndex:indexPath.row] valueForKey:@"feed_id"];
        [self performSegueWithIdentifier:@"push_to_detail" sender:dictObj];
    }
}

#pragma mark PrepareForSegue Method
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"location_invite_details"])
    {
        LocationInviteDetails *vc = [segue destinationViewController];
        vc.strInviteID = [[sender componentsSeparatedByString:@","] objectAtIndex:0];
        vc.strInviteTopTitle = [[sender componentsSeparatedByString:@","] objectAtIndex:1];
    }
    else if ([[segue identifier] isEqualToString:@"push_to_detail"])
    {
        PostDetails *vc = [segue destinationViewController];
        vc.strFeedID = sender;
    }
    else if([[segue identifier] isEqualToString:@"profile"])
    {
        OtherProfileVC *obj = [segue destinationViewController];
        obj.dictUser = (NSDictionary *)sender;
    }
}

#pragma mark Webservice Delegate
-(void)webserviceCallFinishedWithSuccess:(BOOL)success andResponseObject:(id)responseObj andError:(NSError *)error forWebServiceTag:(NSString *)tagStr
{
    if(success)
    {
        NSDictionary *dictResult = (NSDictionary *)responseObj;
        NSLog(@"%@",dictResult);
        if([tagStr isEqualToString:@"notificationList"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                [self parseRecentNotifiation:[dictResult valueForKey:@"data"]];
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
        else if ([tagStr isEqualToString:@"requestType"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                [self getNotifiactionList:NO];
            }
            else
            {
                [self getNotifiactionList:NO];
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
    }
}

-(void)parseRecentNotifiation:(NSArray *)arrnotification
{
    arrRecentNotification = [[NSMutableArray alloc] init];
    arrRequest = [[NSMutableArray alloc] init];
    
    if(arrnotification > 0)
    {
        for(NSDictionary *dictValue in arrnotification)
        {
            if([[dictValue valueForKey:@"notification_type"] intValue] == 3 || [[dictValue valueForKey:@"notification_type"] intValue] == 4 )
            {
                [arrRecentNotification addObject:dictValue];
            }
            else if([[dictValue valueForKey:@"notification_type"] intValue] == 11 )
            {
                
            }
            else
            {
                [arrRequest addObject:dictValue];
            }
        }
    }
    [tblRecent reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (IBAction)btnReqOrInvite:(id)sender
{
    UISegmentedControl *segControll = (UISegmentedControl *)sender;
    [tblRecent reloadData];
    
    if (segControll.selectedSegmentIndex == 0)
    {
        
    }
    else
    {
        
    }
}
@end
