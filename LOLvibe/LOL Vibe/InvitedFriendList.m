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
    [tblFriendList registerNib:[UINib nibWithNibName:@"FriendListCell" bundle:nil] forCellReuseIdentifier:@"FriendListCell"];
    [tblFriendList reloadData];
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
    }];
    lblName.text = [NSString stringWithFormat:@"%@\n@%@",[[arrFrined objectAtIndex:indexPath.row] valueForKey:@"name"],[[arrFrined objectAtIndex:indexPath.row] valueForKey:@"vibe_name"]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tblFriendList)
    {
        [self performSegueWithIdentifier:@"profile" sender:[arrFrined objectAtIndex:indexPath.row]];
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
        NSLog(@"%@",dictResult);
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
