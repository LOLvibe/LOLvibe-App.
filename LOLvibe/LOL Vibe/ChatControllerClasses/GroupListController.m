//
//  GroupListController.m
//  LOLvibe
//
//  Created by Jaydip Godhani on 06/06/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "GroupListController.h"
#import "ServiceConstant.h"
#import "GroupChatController.h"

@interface GroupListController ()<WebServiceDelegate>
{
    NSArray *arrGroup;
}

@end

@implementation GroupListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [tblGroupList registerNib:[UINib nibWithNibName:@"FriendListCell" bundle:nil] forCellReuseIdentifier:@"FriendListCell"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refressGroupList:) name:kRefressGroupList object:nil];
    [self getGroups];
}


-(void)getGroups
{
    WebService *serGetGroup = [[WebService alloc] initWithView:self.view andDelegate:self];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [serGetGroup callWebServiceWithURLDict:GET_GROUPS
                             andHTTPMethod:@"POST"
                               andDictData:dict
                               withLoading:YES
                          andWebServiceTag:@"groupList" setToken:YES];
}

-(void)refressGroupList:(NSNotification *)notification
{
    WebService *serGetGroup = [[WebService alloc] initWithView:self.view andDelegate:self];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [serGetGroup callWebServiceWithURLDict:GET_GROUPS
                             andHTTPMethod:@"POST"
                               andDictData:dict
                               withLoading:NO
                          andWebServiceTag:@"groupList" setToken:YES];
}

#pragma mark Tableview Delegate Method

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrGroup.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendListCell"];
    
    UIImageView *imgProfile = (UIImageView *)[cell viewWithTag:101];
    UILabel *lblName        = (UILabel *)[cell viewWithTag:102];
    
    imgProfile.layer.cornerRadius = imgProfile.frame.size.height /2;
    imgProfile.layer.masksToBounds = YES;
    
    [imgProfile  sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[arrGroup objectAtIndex:indexPath.row] valueForKey:@"group_photo"]]] placeholderImage:[UIImage imageNamed:@"default_user_image"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        imgProfile.image = image;
        
    }];
    
    lblName.text = [NSString stringWithFormat:@"%@",[[arrGroup objectAtIndex:indexPath.row] valueForKey:@"group_name"]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dictGroup = @{@"group_id":[[arrGroup objectAtIndex:indexPath.row] valueForKey:@"group_id"],@"name":[[arrGroup objectAtIndex:indexPath.row] valueForKey:@"group_name"],@"profile_pic":[[arrGroup objectAtIndex:indexPath.row] valueForKey:@"group_photo"]};
    [self performSegueWithIdentifier:@"groupChat" sender:dictGroup];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

#pragma mark PrepareForSegue Method
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"groupChat"])
    {
        GroupChatController *obj = [segue destinationViewController];
        obj.dictUser = (NSDictionary *)sender;
    }
}

#pragma mark Webservice Delegate Method

-(void)webserviceCallFinishedWithSuccess:(BOOL)success andResponseObject:(id)responseObj andError:(NSError *)error forWebServiceTag:(NSString *)tagStr
{
    if(success)
    {
        NSDictionary *dictResult = (NSDictionary *)responseObj;
        NSLog(@"%@",dictResult);
        if([tagStr isEqualToString:@"groupList"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                arrGroup = [dictResult valueForKey:@"data"];
                if(arrGroup.count > 0)
                {
                    [tblGroupList reloadData];
                }
                else
                {
                    tblGroupList.hidden = true;
                }
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
    }
}

#pragma mark Back Button
- (IBAction)btnBack:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}


@end
