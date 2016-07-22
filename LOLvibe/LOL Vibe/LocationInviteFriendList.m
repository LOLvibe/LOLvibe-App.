//
//  LocationInviteFriendList.m
//  LOLvibe
//
//  Created by Paras Navadiya on 14/06/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "LocationInviteFriendList.h"
#import "ServiceConstant.h"
#import "UIView+SuperView.h"
#import "LocationInvitePlaces.h"

@interface LocationInviteFriendList ()<WebServiceDelegate,UITextFieldDelegate>
{
    WebService *serFriendList;
    
    NSMutableArray *arrFriend;
    NSMutableArray *arrFriendCopyArray;
    BOOL searching;
    NSString                *searchStr;
}

@end

@implementation LocationInviteFriendList

- (void)viewDidLoad {
    [super viewDidLoad];
    arrFriend  =[[NSMutableArray alloc]init];
    arrFriendCopyArray=[[NSMutableArray alloc]init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self getFriendList];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    self.title = @"Send Invite To...";
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //self.title = @"Friends";
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)getFriendList
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"0" forKey:@"page"];
    
    serFriendList = [[WebService alloc]initWithView:self.view andDelegate:self];
    [serFriendList callWebServiceWithURLDict:INVITE_SEARCH_USER
                               andHTTPMethod:@"POST"
                                 andDictData:dict
                                 withLoading:YES
                            andWebServiceTag:@"getFriendList"
                                    setToken:YES];
}

#pragma mark --Tableview Delegate Method--
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (searching)
    {
        return [arrFriendCopyArray count];
    }
    else
    {
        return arrFriend.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friend" forIndexPath:indexPath];
    
    UIImageView *imgProfile     = (UIImageView *)[cell viewWithTag:10];
    UILabel *lblName            = (UILabel *)[cell viewWithTag:11];
    UILabel *lblVibeName        = (UILabel *)[cell viewWithTag:12];
    UILabel *lblDistance        = (UILabel *)[cell viewWithTag:13];
    UIButton *btnInvite         = (UIButton *)[cell viewWithTag:14];
    
    btnInvite.layer.cornerRadius = 5.0;
    btnInvite.layer.masksToBounds = YES;
    NSMutableDictionary * techDict;
    
    if(searching)
    {
        techDict = [arrFriendCopyArray objectAtIndex:indexPath.row];
    }
    else
    {
        techDict = [arrFriend objectAtIndex:indexPath.row];
    }
    
    [btnInvite addTarget:self action:@selector(btnInvie:) forControlEvents:UIControlEventTouchUpInside];

    if ([[techDict valueForKey:@"isSelected"] isEqualToString:@"0"])
    {
        [btnInvite setBackgroundColor:[UIColor lightGrayColor]];
    }
    else
    {
        [btnInvite setBackgroundColor:LOL_Vibe_Green_Color];
    }
    
    [imgProfile sd_setImageWithURL:[NSURL URLWithString:[techDict valueForKey:@"profile_pic"]] placeholderImage:[UIImage imageNamed:@"default_user_image.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        imgProfile.image = image;
    }];
    
    
    lblName.text = [techDict valueForKey:@"name"];
    
    lblVibeName.text = [NSString stringWithFormat:@"@%@",[techDict valueForKey:@"vibe_name"]];
    
    lblDistance.text = [NSString stringWithFormat:@"%.1f Miles Away",[[techDict valueForKey:@"distance"] floatValue]];
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0,tableView.frame.size.width,18)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10,5,tableView.frame.size.width,18)];
    [label setFont:[UIFont boldSystemFontOfSize:14]];
    NSString *string =@"Friends nearby...";
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:246.0/255.0 green:247.0/255.0 blue:249.0/255.0 alpha:1.0]];
    return view;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    searching = YES;
    if ([string length] == 0)
    {
        searching = NO;
        [arrFriendCopyArray removeAllObjects];
        [tableInvite reloadData];
        return YES;
    }
    else
    {
        [arrFriendCopyArray removeAllObjects];
        searchStr = [[textField.text stringByReplacingCharactersInRange:range withString:string] copy];
        [self searchTableView];
        return YES;
    }
    
    return YES;
}
- (void)searchTableView
{
    NSMutableArray *searchArray = [[NSMutableArray alloc] init];
    
    [searchArray addObjectsFromArray:arrFriend];
    
    for (NSDictionary *sTempDict in searchArray)
    {
        NSRange titleResultsRange = [[sTempDict valueForKey:@"name"] rangeOfString:searchStr options:NSCaseInsensitiveSearch];
        NSRange titleResultsRangeid = [[sTempDict valueForKey:@"vibe_name"] rangeOfString:searchStr options:NSCaseInsensitiveSearch];
        
        if (titleResultsRange.length > 0 ||  titleResultsRangeid.length > 0)
            [arrFriendCopyArray addObject:sTempDict];
    }
    [tableInvite reloadData];
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    searching = NO;
}


-(void)btnInvie:(id)sender
{
    UITableViewCell *cell = (UITableViewCell *)[sender findSuperViewWithClass:[UITableViewCell class]];
    NSIndexPath *indexPath = [tableInvite indexPathForCell:cell];
    
    if ([[[arrFriend objectAtIndex:indexPath.row] valueForKey:@"isSelected"] isEqualToString:@"1"])
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithDictionary:[arrFriend objectAtIndex:indexPath.row]];
        [dict setValue:@"0" forKey:@"isSelected"];
        [arrFriend replaceObjectAtIndex:indexPath.row withObject:dict];
    }
    else
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithDictionary:[arrFriend objectAtIndex:indexPath.row]];
        [dict setValue:@"1" forKey:@"isSelected"];
        [arrFriend replaceObjectAtIndex:indexPath.row withObject:dict];
    }
    [tableInvite reloadData];
}

#pragma mark --Webservice Delegate Method--
-(void)webserviceCallFinishedWithSuccess:(BOOL)success andResponseObject:(id)responseObj andError:(NSError *)error forWebServiceTag:(NSString *)tagStr
{
    if(success)
    {
        NSDictionary *dictResult = (NSDictionary *)responseObj;
        //NSLog(@"%@",dictResult);
        if([tagStr isEqualToString:@"getFriendList"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                
                [arrFriend addObjectsFromArray:[dictResult valueForKey:@"friend-location"]];
                [arrFriend addObjectsFromArray:[dictResult valueForKey:@"friend-suggetion"]];
                
                
                for(int i = 0 ; i < [arrFriend count]; i++)
                {
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithDictionary:[arrFriend objectAtIndex:i]];
                    [dict setValue:@"0" forKey:@"isSelected"];
                    
                    [arrFriend replaceObjectAtIndex:i withObject:dict];
                }
                
                [tableInvite reloadData];
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
    }
}
-(NSMutableArray *)isSelectedAnyValues
{
    NSMutableArray *arrSelected = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < [arrFriend count]; i++)
    {
        if ([[[arrFriend objectAtIndex:i] valueForKey:@"isSelected"] isEqualToString:@"1"])
        {
            [arrSelected addObject:[[arrFriend objectAtIndex:i] valueForKey:@"user_id"]];
        }
    }
    return arrSelected;
}

- (IBAction)btnPlaces:(id)sender
{
    if ([[self isSelectedAnyValues] count])
    {
        NSString *strSelectedFriend = [[self isSelectedAnyValues] componentsJoinedByString:@","];
        
        [self performSegueWithIdentifier:@"show_places" sender:strSelectedFriend];
    }
    else
    {
        [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Please select at least one friend to send the location invite."];
    }
}

#pragma mark PrepareForSegue Method
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"show_places"])
    {
        LocationInvitePlaces *vc = [segue destinationViewController];
        vc.strUsers = sender;
    }
}
@end