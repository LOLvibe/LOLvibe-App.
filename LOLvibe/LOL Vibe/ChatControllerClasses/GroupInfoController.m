//
//  GroupInfoController.m
//  LOLvibe
//
//  Created by Jaydip Godhani on 11/06/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "GroupInfoController.h"
#import "ProfileImageController.h"
#import "ServiceConstant.h"
#import "AddMemberController.h"

@interface GroupInfoController ()<WebServiceDelegate>
{
    NSArray *arrMember;
    NSString *strAdmin;
}

@end

@implementation GroupInfoController
@synthesize dictGroup;

- (void)viewDidLoad
{
    [super viewDidLoad];
    btnAdddMemberOut.hidden = true;
    [tblGroupMember registerNib:[UINib nibWithNibName:@"FriendListCell" bundle:nil] forCellReuseIdentifier:@"FriendListCell"];
    [self SetDefualtValue];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self getGroupInfo:YES];
}

-(void)SetDefualtValue
{
    
    txtGroupName.text = [NSString stringWithFormat:@"%@",[dictGroup valueForKey:@"name"]];
    
    profilePic.layer.cornerRadius = profilePic.frame.size.height/2;
    profilePic.layer.masksToBounds = YES;
    
    UIImageView *imgTemp = [[UIImageView alloc] init];
    
    [imgTemp sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dictGroup valueForKey:@"profile_pic"]]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [profilePic setBackgroundImage:image forState:UIControlStateNormal];
    }];
}

#pragma mark --Get Group info

-(void)getGroupInfo:(BOOL)isLoading
{
    WebService *serGroupInfo = [[WebService alloc] initWithView:self.view andDelegate:self];
    
    NSMutableDictionary *dictInfo = [[NSMutableDictionary alloc] init];
    [dictInfo setValue:[dictGroup valueForKey:@"group_id"] forKey:@"group_id"];
    
    [serGroupInfo callWebServiceWithURLDict:GET_GROUP_INFO
                              andHTTPMethod:@"POST"
                                andDictData:dictInfo
                                withLoading:isLoading
                           andWebServiceTag:@"groupInfo"
                                   setToken:YES];
}


#pragma mark --Tableview Delegate Method
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrMember.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendListCell"];
    
    UIImageView *imgProfile = (UIImageView *)[cell viewWithTag:101];
    UILabel *lblName        = (UILabel *)[cell viewWithTag:102];
    
    imgProfile.layer.cornerRadius = imgProfile.frame.size.height /2;
    imgProfile.layer.masksToBounds = YES;
    
    [imgProfile sd_setImageWithURL:[NSURL URLWithString:[[arrMember objectAtIndex:indexPath.row] valueForKey:@"profile_pic"]] placeholderImage:[UIImage imageNamed:@"default_user_image"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        imgProfile.image = image;
    }];
    lblName.text = [NSString stringWithFormat:@"%@",[[arrMember objectAtIndex:indexPath.row] valueForKey:@"vibe_name"]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([strAdmin intValue] == [[LoggedInUser sharedUser].userId intValue])
    {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dictVal = [arrMember objectAtIndex:indexPath.row];
    
    NSMutableDictionary *dictpara = [[NSMutableDictionary alloc] init];
    [dictpara setValue:[dictGroup valueForKey:@"group_id"] forKey:@"group_id"];
    [dictpara setValue:[dictVal valueForKey:@"user_id"] forKey:@"user_id"];
    
    
    WebService *serDelete = [[WebService alloc] initWithView:self.view andDelegate:self];
    [serDelete callWebServiceWithURLDict:DELETE_MEMBER_GROUP andHTTPMethod:@"POST" andDictData:dictpara withLoading:NO andWebServiceTag:@"deleteMember" setToken:YES];
    
    NSMutableArray *arrTEmp = [[NSMutableArray alloc] init];
    [arrTEmp addObjectsFromArray:arrMember];
    [arrTEmp removeObjectAtIndex:indexPath.row];
    arrMember = arrTEmp;
    
    [tblGroupMember reloadData];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Members";
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}


#pragma mark --TextField Delegate Method

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(![txtGroupName.text isEqualToString:[dictGroup valueForKey:@"name"]])
    {
        NSMutableDictionary *dictPara = [[NSMutableDictionary alloc] init];
        
        [dictPara setValue:txtGroupName.text forKey:@"group_name"];
        [dictPara setValue:[dictGroup valueForKey:@"group_id"] forKey:@"group_id"];
        
        
        WebService *serEditname = [[WebService alloc] initWithView:self.view andDelegate:self];
        [serEditname callWebServiceWithURLDict:ADD_MEMBER_GROUP andHTTPMethod:@"POST" andDictData:dictPara withLoading:NO andWebServiceTag:@"editName" setToken:YES];
    }
    
    
    [textField resignFirstResponder];
    return YES;
}

#pragma mark --Tap on profile pic
- (IBAction)btnProfilePic:(UIButton *)sender
{
    NSDictionary *dictInfo1 = @{@"name":[dictGroup valueForKey:@"name"],@"profile_pic":[dictGroup valueForKey:@"profile_pic"]};
    
    [self performSegueWithIdentifier:@"profile" sender:dictInfo1];
}

#pragma mark --Addmemer Button
- (IBAction)btnAddMember:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"member" sender:self];
}




#pragma mark --PrepareForSegue Method
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"profile"])
    {
        ProfileImageController *obj = [segue destinationViewController];
        obj.dictinfo = (NSDictionary *)sender;
    }
    else if([[segue identifier] isEqualToString:@"member"])
    {
        AddMemberController *obj = [segue destinationViewController];
        obj.strAddMember = @"member";
        obj.strGroupId = [dictGroup valueForKey:@"group_id"];
    }
}


#pragma mark --WebService Delegate Method
-(void)webserviceCallFinishedWithSuccess:(BOOL)success andResponseObject:(id)responseObj andError:(NSError *)error forWebServiceTag:(NSString *)tagStr
{
    if(success)
    {
        NSDictionary *dictResult = (NSDictionary *)responseObj;
        NSLog(@"%@",dictResult);
        if([tagStr isEqualToString:@"groupInfo"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                arrMember = [[[dictResult valueForKey:@"data"] objectAtIndex:0] valueForKey:@"member"];
                strAdmin = [[[dictResult valueForKey:@"data"] objectAtIndex:0] valueForKey:@"admin"];
                
                
                if([strAdmin intValue] == [[LoggedInUser sharedUser].userId intValue])
                {
                    btnAdddMemberOut.hidden = false;
                }
                
                [tblGroupMember reloadData];
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
    }
}




#pragma mark --Bck Button
- (IBAction)btnBack:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
