//
//  FriendListController.m
//  LOLvibe
//
//  Created by Jaydip Godhani on 02/06/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "InvitedFriendList.h"
#import "ServiceConstant.h"
#import "UIImageView+WebCache.h"
#import "ChatViewController.h"
#import "OtherProfileVC.h"

@interface InvitedFriendList ()<WebServiceDelegate>

@end

@implementation InvitedFriendList
@synthesize arrFrined;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [tblFriendList reloadData];
}



#pragma mark Tableview Delegate Method
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrFrined.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    UIImageView *imgProfile = (UIImageView *)[cell viewWithTag:101];
    UILabel *lblName        = (UILabel *)[cell viewWithTag:102];
    UILabel *lblVibeName        = (UILabel *)[cell viewWithTag:103];
    UILabel *lblStatus        = (UILabel *)[cell viewWithTag:104];
    
    imgProfile.layer.cornerRadius = imgProfile.frame.size.height /2;
    imgProfile.layer.masksToBounds = YES;
    
    [imgProfile sd_setImageWithURL:[NSURL URLWithString:[[arrFrined objectAtIndex:indexPath.row] valueForKey:@"profile_pic"]] placeholderImage:[UIImage imageNamed:@"default_user_image"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        imgProfile.image = image;
    }];
    
    lblName.text = [NSString stringWithFormat:@"%@",[[arrFrined objectAtIndex:indexPath.row] valueForKey:@"name"]];
    
    lblVibeName.text= [NSString stringWithFormat:@"@%@",[[arrFrined objectAtIndex:indexPath.row] valueForKey:@"vibe_name"]];
    
    if ([[[arrFrined objectAtIndex:indexPath.row] valueForKey:@"is_come"] intValue] == 1)
    {
        lblStatus.text = @"Accepted";
        lblStatus.textColor = LOL_Vibe_Green_Color;
    }
    else if ([[[arrFrined objectAtIndex:indexPath.row] valueForKey:@"is_come"] intValue] == 2)
    {
        lblStatus.text = @"Declined";
        lblStatus.textColor = [UIColor redColor];
    }
    else
    {
        
        lblStatus.text = @"Pending";
        lblStatus.textColor = [UIColor blueColor];
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tblFriendList)
    {
        if([[[arrFrined objectAtIndex:indexPath.row] valueForKey:@"user_id"] integerValue] != [[LoggedInUser sharedUser].userId integerValue])
        {
            [self performSegueWithIdentifier:@"profile" sender:[arrFrined objectAtIndex:indexPath.row]];
        }
    }
}

#pragma mark PrepareForSegue Method
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"profile"])
    {
        OtherProfileVC *obj = [segue destinationViewController];
        obj.dictUser = (NSDictionary *)sender;
    }
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
                [tblFriendList reloadData];
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
