//
//  PostDetails.m
//  LOLvibe
//
//  Created by Paras Navadiya on 24/05/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "PostDetails.h"
#import "ServiceConstant.h"
#import "CommentController.h"
#import "OptionClass.h"
#import "UIView+SuperView.h"
#import "LocationInvitePlaces.h"
#import "HashTagVC.h"
#import "OtherProfileVC.h"

@interface PostDetails ()<WebServiceDelegate,OptionClassDelegate>
{
    WebService *serLogout;
    WebService *getFeed;
    
    AppDelegate *appDel;
    LoggedInUser *user;
    
    BOOL isImagePost;
    BOOL isLocationPost;
    BOOL isGridView;
}
@end

@implementation PostDetails

- (void)viewDidLoad {
    [super viewDidLoad];
    user = [LoggedInUser sharedUser];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getPostDetails:YES];
}

-(void)getPostDetails:(BOOL)loading
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:self.strFeedID forKey:@"feed_id"];
    
    WebService *getPostDetails = [[WebService alloc] initWithView:self.view andDelegate:self];
    [getPostDetails callWebServiceWithURLDict:GET_SINGLE_POST
                                andHTTPMethod:@"POST"
                                  andDictData:dict
                                  withLoading:loading
                             andWebServiceTag:@"getPostDetails"
                                     setToken:YES];
}

-(void)pushBackButton
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- Collectionviews Delegate Method--
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.array count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    UIView *viewMain            =(UIView *)[cell viewWithTag:101];
    UIImageView *imgMain        =(UIImageView *)[cell viewWithTag:102];
    ResponsiveLabel *lblCaption =(ResponsiveLabel *)[cell viewWithTag:103];
    UIButton *btnOption         =(UIButton *)[cell viewWithTag:104];
    UILabel *lblLocation        =(UILabel *)[cell viewWithTag:105];
    UILabel *lblTime            =(UILabel *)[cell viewWithTag:106];
    
    UIImageView *imgProfile     =(UIImageView *)[cell viewWithTag:107];
    UILabel *lblUserVibeName    =(UILabel *)    [cell viewWithTag:108];
    UILabel *lblUserFullName    =(UILabel *)    [cell viewWithTag:109];
    UILabel *lblCity            =(UILabel *)    [cell viewWithTag:110];
    UILabel *lblWebsite         =(UILabel *)    [cell viewWithTag:111];
    UILabel *lblLikeCount       =(UILabel *)    [cell viewWithTag:112];
    UILabel *lblCommentCount    =(UILabel *)    [cell viewWithTag:113];
    UIButton *btnComment        =(UIButton *)   [cell viewWithTag:114];
    UIButton *btnLike           =(UIButton *)   [cell viewWithTag:115];
    UIButton *btnAddFriend      =(UIButton *)   [cell viewWithTag:120];
    UIButton *btnLocationInvite =(UIButton *)   [cell viewWithTag:215];
    
    UITapGestureRecognizer *tapGestureWebsite = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnWebsite:)];
    tapGestureWebsite.numberOfTapsRequired = 1;
    tapGestureWebsite.cancelsTouchesInView = YES;
    [lblWebsite addGestureRecognizer:tapGestureWebsite];
    
    
    UITapGestureRecognizer *tapGestureProfile = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureProfile:)];
    tapGestureProfile.numberOfTapsRequired = 1;
    tapGestureProfile.cancelsTouchesInView = YES;
    [imgProfile addGestureRecognizer:tapGestureProfile];
    
    btnLike.accessibilityLabel = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    btnComment.accessibilityLabel = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    btnAddFriend.accessibilityLabel = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    btnOption.accessibilityLabel = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    
    viewMain.layer.cornerRadius = 5.0;
    viewMain.layer.masksToBounds = YES;
    viewMain.layer.borderWidth = 1.0;
    viewMain.layer.borderColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0].CGColor;
    
    imgProfile.layer.cornerRadius = 5.0;
    imgProfile.layer.masksToBounds = YES;
    imgProfile.layer.borderWidth = 1;
    imgProfile.layer.borderColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0].CGColor;
    
    if ([_array count] != 0)
    {
        NSDictionary *dictObj = [_array objectAtIndex:indexPath.row];
        
        NSString *strURL = [dictObj valueForKey:@"image"];
        
        if (strURL.length != 0) {
            
            [imgMain sd_setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:@"post_bg.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                imgMain.image = image;
            }];
        }
        PatternTapResponder hashTagTapAction = ^(NSString *tappedString)
        {
            HashTagVC *obj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HashTagVC"];
            obj.strHashTag = tappedString;
            
            [self.navigationController pushViewController:obj animated:YES];
            
        };
        
        [lblCaption enableHashTagDetectionWithAttributes:@{NSForegroundColorAttributeName:LOL_Vibe_Green_Color,
                                                           RLHighlightedBackgroundColorAttributeName:[UIColor clearColor],NSBackgroundColorAttributeName:[UIColor clearColor],RLHighlightedBackgroundCornerRadius:@5,
                                                           RLTapResponderAttributeName:hashTagTapAction}];
        if ([[dictObj valueForKey:@"like"] intValue] <= 0)
        {
            btnLike.selected= NO;
            lblLikeCount.text = @"0";
        }
        else
        {
            if([[dictObj valueForKey:@"is_like"] intValue] == 1)
            {
                btnLike.selected= YES;
            }
            else
            {
                btnLike.selected= NO;
            }
        }
        lblLikeCount.text = [NSString stringWithFormat:@"%@",[dictObj valueForKey:@"like"]];
        lblCommentCount.text = [NSString stringWithFormat:@"%@",[dictObj valueForKey:@"comment"]];
        
        
        if ([[dictObj valueForKey:@"is_friend"] intValue] == 0)
        {
            btnAddFriend.hidden = NO;
            btnLocationInvite.hidden = YES;
            btnAddFriend.selected = NO;
        }
        else if([[dictObj valueForKey:@"is_friend"] intValue] == 1)
        {
            btnLocationInvite.hidden = NO;
            btnAddFriend.hidden = YES;
        }
        else if ([[dictObj valueForKey:@"is_friend"] intValue] == 2)
        {
            btnAddFriend.hidden = YES;
            btnLocationInvite.hidden = YES;
        }
        else if ([[dictObj valueForKey:@"is_friend"] intValue] == 3)
        {
            btnAddFriend.hidden = NO;
            btnAddFriend.selected = YES;
            btnLocationInvite.hidden = YES;
        }
        
        const char *jsonString = [[dictObj valueForKey:@"feed_text"] UTF8String];
        NSData *jsonData = [NSData dataWithBytes:jsonString length:strlen(jsonString)];
        NSString *goodMsg = [[NSString alloc] initWithData:jsonData encoding:NSNonLossyASCIIStringEncoding];
        lblCaption.text=goodMsg;
        
        lblLocation.text =[dictObj valueForKey:@"location_text"];
        lblTime.text = [dictObj valueForKey:@"created_at"];
        
        [btnOption addTarget:self action:@selector(btnOption:) forControlEvents:UIControlEventTouchUpInside];
        [btnComment addTarget:self action:@selector(btnComment:) forControlEvents:UIControlEventTouchUpInside];
        [btnLike addTarget:self action:@selector(btnLike:) forControlEvents:UIControlEventTouchUpInside];
        [btnAddFriend addTarget:self action:@selector(isFriendOrNot:) forControlEvents:UIControlEventTouchUpInside];
        [btnLocationInvite addTarget:self action:@selector(btnLocationInvite:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([[dictObj valueForKey:@"vibe_name"] length] > 0)
        {
            lblUserVibeName.text = [NSString stringWithFormat:@"@%@",[dictObj valueForKey:@"vibe_name"]];
        }
        else
        {
            lblUserVibeName.text = @"";
        }
        
        if ([[dictObj valueForKey:@"formatted_address"] length] > 0)
        {
            NSArray *arr = [[dictObj valueForKey:@"formatted_address"] componentsSeparatedByString:@","];
            
            lblCity.text = [NSString stringWithFormat:@"%@,%@",[arr objectAtIndex:0],[arr objectAtIndex:1]];
        }
        else
        {
            lblCity.text =  @"";
        }
        
        if ([[dictObj valueForKey:@"website"] length] > 0)
        {
            lblWebsite.text = [NSString stringWithFormat:@"%@",[dictObj valueForKey:@"website"]];
        }
        else
        {
            lblWebsite.text =  @"";
        }
        
        if ([[dictObj valueForKey:@"age"] length] > 0)
        {
            lblUserFullName.text = [NSString stringWithFormat:@"%@, %@",[dictObj valueForKey:@"name"],[dictObj valueForKey:@"age"]];
        }
        else
        {
            lblUserFullName.text = [NSString stringWithFormat:@"%@",[dictObj valueForKey:@"name"]];
        }
        
        NSString *strProfile = [dictObj valueForKey:@"profile_pic"];
        
        [imgProfile sd_setImageWithURL:[NSURL URLWithString:strProfile] placeholderImage:[UIImage imageNamed:@"default_user_image.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            imgProfile.image = image;
        }];

    }
    
    return cell;
}

-(void)tapOnWebsite:(UITapGestureRecognizer *)sender {
    
    CGPoint location = [sender locationInView:collectionViewPost];
    NSIndexPath *indexPath = [collectionViewPost indexPathForItemAtPoint:location];
    
    NSString *strSelectedFriend = [[_array objectAtIndex:indexPath.row] valueForKey:@"website"];
    
    WebBrowserVc *web = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"WebBrowserVc"];
    
    web.strURL = strSelectedFriend;
    
    [self.navigationController pushViewController:web animated:YES];
}
-(void)tapGestureProfile:(UITapGestureRecognizer *)sender
{
    CGPoint location = [sender locationInView:collectionViewPost];
    NSIndexPath *indexPath = [collectionViewPost indexPathForItemAtPoint:location];
    
    if([[[_array objectAtIndex:indexPath.row] valueForKey:@"user_id"] integerValue] != [[LoggedInUser sharedUser].userId integerValue])
    {
        [self performSegueWithIdentifier:@"profile" sender:[_array objectAtIndex:indexPath.row]];
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
    else  if([[segue identifier] isEqualToString:@"profile"])
    {
        OtherProfileVC *obj = [segue destinationViewController];
        obj.dictUser = (NSDictionary *)sender;
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView.frame.size;
}

-(void)btnLike:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    NSInteger indexPath = [sender.accessibilityLabel intValue];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[[self.array objectAtIndex:indexPath] valueForKey:@"feed_id"] forKey:@"parent_id"];
    [dict setValue:@"post" forKey:@"like_type"];
    
    WebService *serLikePost = [[WebService alloc] initWithView:self.view andDelegate:self];
    if(sender.selected)
    {
        [serLikePost callWebServiceWithURLDict:LIKE_POST andHTTPMethod:@"POST" andDictData:dict withLoading:NO andWebServiceTag:@"likepost" setToken:YES];
        
    }
    else
    {
        [serLikePost callWebServiceWithURLDict:UNLIKE_POST andHTTPMethod:@"POST" andDictData:dict withLoading:NO andWebServiceTag:@"likepost" setToken:YES];
    }
}
-(void)btnOption:(UIButton *)sender
{
    UICollectionViewCell *cell = (UICollectionViewCell *)[sender findSuperViewWithClass:[UICollectionViewCell class]];
    UIImageView *img = (UIImageView *)[cell viewWithTag:102];
    
    NSIndexPath *indexPath = [collectionViewPost indexPathForCell:cell];
    
    NSDictionary *dictVal = [self.array objectAtIndex:indexPath.row];
    OptionClass *share = [[OptionClass alloc] initWithView:self andDelegate:self];
    
    if([[dictVal valueForKey:@"user_id"] integerValue] != [[LoggedInUser sharedUser].userId integerValue])
    {
        [share otherUserPostOptionClass:dictVal Image:img.image];
    }
    else
    {
        [share UserProfileSharingOption:dictVal Image:img.image];
    }
}

-(void)callInstagramMethod:(NSDictionary *)dict Image:(UIImage *)image
{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    
    if([[UIApplication sharedApplication] canOpenURL:instagramURL])
    {
        NSString *imagePath = [NSString stringWithFormat:@"%@/image.igo",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject]];
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
        
        [UIImageJPEGRepresentation(image, 1) writeToFile:imagePath atomically:YES];
        
        _documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:imagePath]];
        _documentController.delegate = self;
        [_documentController setAnnotation:@{@"InstagramCaption" : @"#LOLvibe"}];
        _documentController.UTI = @"com.instagram.exclusivegram";
        
        [_documentController presentOpenInMenuFromRect:self.view.frame inView:self.view animated:YES];
    }
    else
    {
        [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Instagram not install in your IPhone"];
    }
}

-(void)btnComment:(UIButton *)sender
{
    NSInteger indexPath = [sender.accessibilityLabel intValue];
    
    CommentController *obj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentController"];
    obj.dictPost = [self.array objectAtIndex:indexPath];
    obj.isInvite = NO;
    [self.navigationController pushViewController:obj animated:YES];
}

-(void)isFriendOrNot:(UIButton *)sender
{
    if(!sender.selected)
    {
        NSMutableDictionary *dictval = [[NSMutableDictionary alloc] init];
        
        dictval = [[self.array objectAtIndex:[sender.accessibilityLabel intValue]] mutableCopy];
        
        NSMutableDictionary *dictAddFriend = [[NSMutableDictionary alloc]init];
        [dictAddFriend setValue:[dictval valueForKey:@"user_id"] forKey:@"other_user_id"];
        
        WebService *serAddFriend = [[WebService alloc] initWithView:self.view andDelegate:self];
        [serAddFriend callWebServiceWithURLDict:SEND_REQUEST
                                  andHTTPMethod:@"POST"
                                    andDictData:dictAddFriend
                                    withLoading:NO
                               andWebServiceTag:@"addfriend"
                                       setToken:YES];
        
        
        [dictval setValue:@"1" forKey:@"is_friend"];
        
        [self.array replaceObjectAtIndex:[sender.accessibilityLabel intValue] withObject:dictval];
    }
}
-(void)btnLocationInvite:(UIButton *)sender
{
    UICollectionViewCell *cell = (UICollectionViewCell *)[sender findSuperViewWithClass:[UICollectionViewCell class]];
    
    NSIndexPath *indexPath = [collectionViewPost indexPathForCell:cell];
    
    NSString *strSelectedFriend = [[self.array objectAtIndex:indexPath.row] valueForKey:@"user_id"];
    
    [self performSegueWithIdentifier:@"show_places" sender:strSelectedFriend];
}

-(void)callRepostMethod:(NSDictionary *)dict
{
    NSMutableDictionary *dictPara =[[NSMutableDictionary alloc]init];
    WebService *vibePostWS = [[WebService alloc]initWithView:self.view andDelegate:self];
    
    if([[dict valueForKey:@"post_type"] isEqualToString:@"photo"])
    {
        [dictPara setValue:[dict valueForKey:@"post_type"] forKey:@"post_type"];
        [dictPara setValue:[dict valueForKey:@"location_text"] forKey:@"location_text"];
        
        [dictPara setValue:[dict valueForKey:@"post_share"] forKey:@"post_share"];
        [dictPara setValue:[dict valueForKey:@"image"] forKey:@"image"];
        
        [dictPara setValue:[NSString stringWithFormat:@"#REPOSTED \n%@",[dict valueForKey:@"feed_text"]] forKey:@"feed_text"];
        
        [vibePostWS callWebServiceWithURLDict:CREATE_POST
                                andHTTPMethod:@"POST"
                                  andDictData:dictPara
                                  withLoading:NO
                             andWebServiceTag:@"vibePostWS"
                                     setToken:YES];
    }
    else
    {
        [dictPara setValue:[dict valueForKey:@"post_latitude"] forKey:@"latitude"];
        [dictPara setValue:[dict valueForKey:@"post_longitude"] forKey:@"longitude"];
        [dictPara setValue:[dict valueForKey:@"post_type"] forKey:@"post_type"];
        [dictPara setValue:[dict valueForKey:@"location_text"] forKey:@"location_text"];
        [dictPara setValue:[dict valueForKey:@"post_share"] forKey:@"post_share"];
        [dictPara setValue:[dict valueForKey:@"image"] forKey:@"image"];
        
        [dictPara setValue:[NSString stringWithFormat:@"#REPOSTED \n%@",[dict valueForKey:@"feed_text"]] forKey:@"feed_text"];
        
        [vibePostWS callWebServiceWithURLDict:CREATE_POST
                                andHTTPMethod:@"POST"
                                  andDictData:dictPara
                                  withLoading:NO
                             andWebServiceTag:@"vibePostWS"
                                     setToken:YES];
    }
}
-(void)callReportMethod:(NSDictionary *)dict
{
    NSMutableDictionary *dictPara = [[NSMutableDictionary alloc] init];
    [dictPara setValue:[dict valueForKey:@"feed_id"] forKey:@"report_for_id"];
    [dictPara setValue:[dict valueForKey:@"user_id"] forKey:@"to_user_id"];
    [dictPara setValue:@"post" forKey:@"report_for"];
    
    WebService *report = [[WebService alloc] initWithView:self.view andDelegate:self];
    
    [report callWebServiceWithURLDict:REPORT_POST_COMMENT
                        andHTTPMethod:@"POST"
                          andDictData:dictPara
                          withLoading:YES
                     andWebServiceTag:@"report"
                             setToken:YES];
}
-(void)callBlockUserMethod:(NSDictionary *)dict
{
    NSMutableDictionary *dictPara = [[NSMutableDictionary alloc] init];
    [dictPara setValue:[dict valueForKey:@"feed_id"] forKey:@"report_for_id"];
    [dictPara setValue:[dict valueForKey:@"user_id"] forKey:@"to_user_id"];
    [dictPara setValue:@"post" forKey:@"report_for"];
    
    WebService *report = [[WebService alloc] initWithView:self.view andDelegate:self];
    
    [report callWebServiceWithURLDict:REPORT_POST_COMMENT
                        andHTTPMethod:@"POST"
                          andDictData:dictPara
                          withLoading:YES
                     andWebServiceTag:@"block"
                             setToken:YES];
}
-(void)callDeleteMethod:(NSDictionary *)dict
{
    NSMutableDictionary *dictPara = [[NSMutableDictionary alloc] init];
    [dictPara setValue:[dict valueForKey:@"feed_id"] forKey:@"feed_id"];
    
    WebService *unfriend = [[WebService alloc] initWithView:self.view andDelegate:self];
    
    [unfriend callWebServiceWithURLDict:DELETE_FEED
                          andHTTPMethod:@"POST"
                            andDictData:dictPara
                            withLoading:YES
                       andWebServiceTag:@"deletefeed"
                               setToken:YES];
}

#pragma mark Werbservice Delegate Method
-(void)webserviceCallFinishedWithSuccess:(BOOL)success andResponseObject:(id)responseObj andError:(NSError *)error forWebServiceTag:(NSString *)tagStr
{
    if(success)
    {
        NSDictionary *dictResult = (NSDictionary *)responseObj;
        //NSLog(@"%@",dictResult);
        if([tagStr isEqualToString:@"likepost"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                [self getPostDetails:NO];
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
        else if ([tagStr isEqualToString:@"getPostDetails"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                self.array = [[NSMutableArray alloc]init];
                if ([[dictResult valueForKey:@"post"] isKindOfClass:[NSArray class]])
                {
                    if ([[dictResult valueForKey:@"post"] count] != 0)
                    {
                        self.array =[dictResult valueForKey:@"post"];
                        [collectionViewPost reloadData];
                    }
                }
                else
                {
                    [self.array addObject:[dictResult valueForKey:@"post"]];
                    [collectionViewPost reloadData];
                }
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
        else if ([tagStr isEqualToString:@"report"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                [self.navigationController popToRootViewControllerAnimated:YES];
                
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"This post is reported. Admin will review the post and take the action."];
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
        else if ([tagStr isEqualToString:@"vibePostWS"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Repost Successful!"];
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
        
        else if ([tagStr isEqualToString:@"block"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"This user is blocked. As of now you will not see any post of this user."];
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
        else if ([tagStr isEqualToString:@"deletefeed"])
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

@end
