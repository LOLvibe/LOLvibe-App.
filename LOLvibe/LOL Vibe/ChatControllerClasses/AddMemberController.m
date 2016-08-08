//
//  AddMemberController.m
//  LOLvibe
//
//  Created by Jaydip Godhani on 28/05/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "AddMemberController.h"
#import "ServiceConstant.h"
@interface AddMemberController ()<WebServiceDelegate>
{
    NSArray *arrFrined;
    NSMutableArray *arrSelectedMember;
}

@end

@implementation AddMemberController
@synthesize dataImag,strGroupName,strAddMember,strGroupId;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [tblMember registerNib:[UINib nibWithNibName:@"FriendListCell" bundle:nil] forCellReuseIdentifier:@"FriendListCell"];
    [self getFriendList];
    arrSelectedMember = [[NSMutableArray alloc] init];
}


-(void)getFriendList
{
    WebService *serFriendList = [[WebService alloc] initWithView:self.view andDelegate:self];
    NSMutableDictionary *dictFriend = [[NSMutableDictionary alloc] init];
    [serFriendList callWebServiceWithURLDict:GET_FRIEND_LIST
                               andHTTPMethod:@"POST"
                                 andDictData:dictFriend
                                 withLoading:YES
                            andWebServiceTag:@"friendList"
                                    setToken:YES];
}

#pragma mark Done Button
- (IBAction)btnDone:(UIButton *)sender
{
    if([strAddMember isEqualToString:@"group"])
    {
        if(arrSelectedMember.count >= 2)
        {
            NSArray *arrIds = [self memberId];
            [self createGroup:arrIds];
        }
        else
        {
            [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Please select at least two member."];
        }
    }
    else if ([strAddMember isEqualToString:@"member"])
    {
        if(arrSelectedMember.count >= 1)
        {
            NSArray *arrIds = [self memberId];
            [self createGroup:arrIds];
        }
        else
        {
            [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Please select at least one member."];
        }
    }
    
}

-(NSArray *)memberId
{
    NSMutableArray *arrUserIds = [[NSMutableArray alloc] init];
    for(int i = 0;i<arrSelectedMember.count;i++)
    {
        [arrUserIds addObject:[[arrSelectedMember objectAtIndex:i] valueForKey:@"user_id"]];
    }
    return arrUserIds;
}

-(void)createGroup:(NSArray *)member
{
    if([strAddMember isEqualToString:@"group"])
    {
        NSString *strId = [member componentsJoinedByString:@","];
        
        NSMutableDictionary *dictGroup = [[NSMutableDictionary alloc] init];
        [dictGroup setValue:strGroupName forKey:@"group_name"];
        [dictGroup setValue:strId forKey:@"users"];
        [dictGroup setValue:[LoggedInUser sharedUser].userId forKey:@"admin"];
        
        WebService *serCreate = [[WebService alloc] initWithView:self.view andDelegate:self];
        
        [serCreate callWebServiceWithURL:CREATE_GROUP
                           andHTTPMethod:@"POST"
                             andDictData:dictGroup
                                   Image:dataImag
                                fileName:@"profile.jpg"
                           parameterName:@"group_photo"
                             withLoading:YES
                        andWebServiceTag:@"createGroup"];
    }
    else if ([strAddMember isEqualToString:@"member"])
    {
        NSString *strId = [member componentsJoinedByString:@","];
        
        NSMutableDictionary *dictGroup = [[NSMutableDictionary alloc] init];
        [dictGroup setValue:strId forKey:@"users"];
        [dictGroup setValue:strGroupId forKey:@"group_id"];
        
        WebService *serCreate = [[WebService alloc] initWithView:self.view andDelegate:self];
        [serCreate callWebServiceWithURLDict:ADD_MEMBER_GROUP
                               andHTTPMethod:@"POST"
                                 andDictData:dictGroup
                                 withLoading:YES
                            andWebServiceTag:@"member"
                                    setToken:YES];
    }
}

#pragma mark Tableview Delegate Method

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrFrined.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendListCell"];
    
    UIImageView *imgProfile = (UIImageView *)[cell viewWithTag:101];
    UILabel *lblName        = (UILabel *)[cell viewWithTag:102];
    
    imgProfile.layer.cornerRadius = imgProfile.frame.size.height /2;
    imgProfile.layer.masksToBounds = YES;
    
    [imgProfile sd_setImageWithURL:[NSURL URLWithString:[[arrFrined objectAtIndex:indexPath.row] valueForKey:@"profile_pic"]] placeholderImage:[UIImage imageNamed:@"default_user_image"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        imgProfile.image = image;
        if (!image)
        {
            imgProfile.image =[UIImage imageNamed:@"default_user_image.png"];
        }
        
    }];
    lblName.text = [NSString stringWithFormat:@"%@",[[arrFrined objectAtIndex:indexPath.row] valueForKey:@"vibe_name"]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [arrSelectedMember addObject:[arrFrined objectAtIndex:indexPath.row]];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    [arrSelectedMember removeObject:[arrFrined objectAtIndex:indexPath.row]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}


#pragma mark WebService Delegate Method

-(void)webserviceCallFinishedWithSuccess:(BOOL)success andResponseObject:(id)responseObj andError:(NSError *)error forWebServiceTag:(NSString *)tagStr
{
    if(success)
    {
        NSDictionary *dictResult = (NSDictionary *)responseObj;
//        NSLog(@"%@",dictResult);
        if([tagStr isEqualToString:@"friendList"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                arrFrined = [dictResult valueForKey:@"data"];
                [tblMember reloadData];
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
        else if ([tagStr isEqualToString:@"createGroup"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kRefressGroupList object:nil];
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
        else if ([tagStr isEqualToString:@"member"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
    }
}


#pragma mark Cancel Button
- (IBAction)btnCancel:(UIButton *)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}




@end
