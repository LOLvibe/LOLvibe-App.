//
//  SearchVc.m
//  LOLvibe
//
//  Created by Paras Navadiya on 26/06/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "SearchVc.h"
#import "ServiceConstant.h"
#import "OtherProfileVC.h"
#import "UIView+SuperView.h"
#import "PostDetails.h"

@interface SearchVc ()<UITableViewDelegate,UITableViewDataSource,WebServiceDelegate,UIActionSheetDelegate>
{
    WebService          *getSearchResult;
    NSMutableArray      *arrPeoples;
    NSMutableArray      *arrPosts;
}
@property (weak, nonatomic) UITextField *activeField;

@end

@implementation SearchVc

- (void)viewDidLoad {
    [super viewDidLoad];
    arrPeoples = [[NSMutableArray alloc] init];
    arrPosts   = [[NSMutableArray alloc] init];
    
    [self showPostView];
    self.title = @"Top Posts";
    [self TopPosts];
}

#pragma mark --Show and Hide View--
-(void)showPeopleView
{
    [viewPeople setHidden:NO];
    [viewPost setHidden:YES];
    [self.view bringSubviewToFront:viewPeople];
    [self.view sendSubviewToBack:viewPost];
}

-(void)showPostView
{
    [viewPost setHidden:NO];
    [viewPeople setHidden:YES];
    [self.view bringSubviewToFront:viewPost];
    [self.view sendSubviewToBack:viewPeople];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnFilter:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Search"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"People",@"Top Posts",@"Trending", nil];
    sheet.tag = 1111;
    [sheet showInView:self.view];
}


#pragma mark - UIActionSheet Delegate Methods
- (void)actionSheet:(UIActionSheet *)menu didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (menu.tag)
    {
        case 1111:
            if (buttonIndex==0)
            {
                [self showPeopleView];
                [self getPeoples:@"" withLoading:YES];
                self.title = @"People";
            }
            else if (buttonIndex==1)
            {
                [self showPostView];
                self.title = @"Top Posts";
                [self TopPosts];
            }
            else if (buttonIndex==2)
            {
                [self showPostView];
                self.title = @"Trending";
                [self Tranding];
            }
            break;
    }
}


- (IBAction)btnSearch:(id)sender
{
    [self.activeField resignFirstResponder];
}

#pragma mark --Tableview Delegate Method--
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrPeoples.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"people" forIndexPath:indexPath];
    
    UIImageView *imgProfile = (UIImageView *)[cell viewWithTag:100];
    UILabel *lblName        = (UILabel *)[cell viewWithTag:102];
    UILabel *lblVibeName    = (UILabel *)[cell viewWithTag:103];
    UIButton *btnAddFrnd    = (UIButton *)[cell viewWithTag:104];
    UILabel *lblDistance    = (UILabel *)[cell viewWithTag:105];
    
    lblDistance.text = [NSString stringWithFormat:@"%.1f Miles Away",[[[arrPeoples objectAtIndex:indexPath.row] valueForKey:@"distance"] floatValue]];
    [btnAddFrnd addTarget:self action:@selector(btnAddFrnd:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[[arrPeoples objectAtIndex:indexPath.row] valueForKey:@"is_friend"] intValue] == 0)
    {
        btnAddFrnd.selected = NO;
    }
    else if([[[arrPeoples objectAtIndex:indexPath.row] valueForKey:@"is_friend"] intValue] == 1)
    {
        btnAddFrnd.selected = YES;
    }
    
    
    [imgProfile sd_setImageWithURL:[NSURL URLWithString:[[arrPeoples objectAtIndex:indexPath.row] valueForKey:@"profile_pic"]] placeholderImage:[UIImage imageNamed:@"default_user_image.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        imgProfile.image = image;
    }];
    
    lblName.text = [NSString stringWithFormat:@"%@",[[arrPeoples objectAtIndex:indexPath.row] valueForKey:@"name"]];
    
    lblVibeName.text= [NSString stringWithFormat:@"@%@",[[arrPeoples objectAtIndex:indexPath.row] valueForKey:@"vibe_name"]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"profile" sender:[arrPeoples objectAtIndex:indexPath.row]];
}

#pragma mark --Collectionview Delegate Method--
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return arrPosts.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellGrid" forIndexPath:indexPath];
    
        NSDictionary *dictObj = [arrPosts objectAtIndex:indexPath.row];
    
        NSString *strURL = [dictObj valueForKey:@"image"];
        UIImageView *imgMain        =(UIImageView *)[cell viewWithTag:10];
    
        [imgMain sd_setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:@"post_bg.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            imgMain.image = image;
        }];
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PostDetails *obj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PostDetails"];
    
    obj.strFeedID = [[arrPosts objectAtIndex:indexPath.row] valueForKey:@"feed_id"];
    
    [self.navigationController pushViewController:obj animated:YES];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat sizeflot = collectionViewGrid.frame.size.width - 5;
    sizeflot = sizeflot/3;
    CGSize size = CGSizeMake(sizeflot, sizeflot);
    return size;
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
-(void)btnAddFrnd:(UIButton *)sender
{
    if(!sender.selected)
    {
        
        UITableViewCell *cell = (UITableViewCell *)[sender findSuperViewWithClass:[UITableViewCell class]];
        
        NSIndexPath *indexPath = [tablePeoples indexPathForCell:cell];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:[[arrPeoples objectAtIndex:indexPath.row] valueForKey:@"user_id"] forKey:@"other_user_id"];
        
        WebService *addfriend = [[WebService alloc] initWithView:self.view andDelegate:self];
        
        [addfriend callWebServiceWithURLDict:SEND_REQUEST
                               andHTTPMethod:@"POST"
                                 andDictData:dict
                                 withLoading:YES
                            andWebServiceTag:@"addfriend"
                                    setToken:YES];
    }
}

#pragma mark - Textfield Delegete Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txtSearchPeople)
    {
        [textField resignFirstResponder];
    }
    return NO;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * proposedNewString = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    
    if (proposedNewString.length > 0)
    {
        [self getPeoples:proposedNewString withLoading:NO];
    }
    return YES;
}

-(void)getPeoples:(NSString *)strInput withLoading:(BOOL)isLoading
{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:strInput forKey:@"string"];
    getSearchResult = [[WebService alloc] initWithView:self.view andDelegate:self];
    
    [getSearchResult callWebServiceWithURLDict:SEARCH_PEOPLE
                                 andHTTPMethod:@"POST"
                                   andDictData:dict
                                   withLoading:isLoading
                              andWebServiceTag:@"getSearchResult"
                                      setToken:YES];
    
}
-(void)Tranding
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    getSearchResult = [[WebService alloc] initWithView:self.view andDelegate:self];

    [getSearchResult callWebServiceWithURLDict:TRENDING_POST
                                 andHTTPMethod:@"POST"
                                   andDictData:dict
                                   withLoading:YES
                              andWebServiceTag:@"trending"
                                      setToken:YES];
    
}
-(void)TopPosts
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    getSearchResult = [[WebService alloc] initWithView:self.view andDelegate:self];

    [getSearchResult callWebServiceWithURLDict:TOP_POST
                                 andHTTPMethod:@"POST"
                                   andDictData:dict
                                   withLoading:YES
                              andWebServiceTag:@"top"
                                      setToken:YES];
    
}

#pragma mark --Webservice Delegate Method--
-(void)webserviceCallFinishedWithSuccess:(BOOL)success andResponseObject:(id)responseObj andError:(NSError *)error forWebServiceTag:(NSString *)tagStr
{
    if(success)
    {
        NSDictionary *dictResult = (NSDictionary *)responseObj;
        NSLog(@"%@",dictResult);
        if([tagStr isEqualToString:@"getSearchResult"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                [arrPeoples removeAllObjects];
                [arrPeoples addObjectsFromArray:[dictResult valueForKey:@"friend"]];
                [tablePeoples reloadData];
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
        else if([tagStr isEqualToString:@"addfriend"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
        else if([tagStr isEqualToString:@"top"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                [arrPosts removeAllObjects];
                [arrPosts addObjectsFromArray:[dictResult valueForKey:@"post"]];
                [collectionViewGrid reloadData];
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
        else if([tagStr isEqualToString:@"trending"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                [arrPosts removeAllObjects];
                [arrPosts addObjectsFromArray:[dictResult valueForKey:@"post"]];
                [collectionViewGrid reloadData];
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
    }
}

@end
