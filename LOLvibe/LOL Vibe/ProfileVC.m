//
//  ProfileVC.m
//  LOL Vibe
//
//  Created by Paras Navadiya on 05/05/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "ProfileVC.h"
#import "ServiceConstant.h"
#import "PostDetails.h"
#import "CommentController.h"
#import "OtherProfileVC.h"
#import "ShareViewController.h"
#import "UIView+SuperView.h"
#import "OptionClass.h"
#import "HashTagVC.h"

@interface ProfileVC ()<UICollectionViewDataSource,UICollectionViewDelegate,WebServiceDelegate,CLLocationManagerDelegate,UIActionSheetDelegate,OptionClassDelegate>
{
    WebService          *serLogout;
    WebService          *getFeed;
    WebService          *serFriendList;
    WebService          *serVisitFriend;
    AppDelegate         *appDel;
    LoggedInUser        *user;
    
    NSMutableArray      *arrPhotoPosts;
    NSMutableArray      *arrLocationPosts;
    NSMutableArray      *arrFriend;
    NSMutableArray      *arrVisitFriend;
    
    CLLocationManager   *locationManager;
    float               sourceLat,sourceLong;
    float               destiLat,destiLong;
    
    NSIndexPath         *indexPathUnfriend;
    
    int                 pageCountPost,pageCountLoc;
    BOOL                isEndPost,isEndLoc;
}
@end

@implementation ProfileVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    serLogout       = [[WebService alloc] initWithView:self.view andDelegate:self];
    getFeed         = [[WebService alloc] initWithView:self.view andDelegate:self];
    serFriendList   = [[WebService alloc] initWithView:self.view andDelegate:self];
    serVisitFriend  = [[WebService alloc] initWithView:self.view andDelegate:self];
    
    arrPhotoPosts       = [[NSMutableArray alloc]init];
    arrLocationPosts    = [[NSMutableArray alloc]init];
    arrFriend           = [[NSMutableArray alloc]init];
    arrVisitFriend      = [[NSMutableArray alloc]init];
    
    appDel = APP_DELEGATE;
    
    self.title = @"";
    
    pageCountPost = pageCountLoc = 1;
    
    [self btnPostPhoto:nil];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    user = [LoggedInUser sharedUser];
    
    lblFullName.text = user.userFullName;
    lblVibeName.text = [NSString stringWithFormat:@"@%@",user.userVibeName];
    
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    NSUInteger code = [CLLocationManager authorizationStatus];
    if (code == kCLAuthorizationStatusNotDetermined && ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]))
    {
        // choose one request according to your business.
        if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"])
        {
            [locationManager requestAlwaysAuthorization];
        }
        else if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"])
        {
            [locationManager  requestWhenInUseAuthorization];
        }
        else
        {
            NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
        }
    }
    [locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil)
    {
        sourceLat =currentLocation.coordinate.latitude;
        sourceLong =currentLocation.coordinate.longitude;
        
        [locationManager stopUpdatingLocation];
    }
}


#pragma mark- Location Permision Method
- (void)requestAlwaysAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied)
    {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
        [alertView show];
    }
    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined)
    {
        [locationManager requestAlwaysAuthorization];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)buttoneDfaultState
{
    [btnPostPhoto setSelected:NO];
    [btnPostGrid setSelected:NO];
    [btnFriends setSelected:NO];
    [btnProfileSeen setSelected:NO];
    [btnLocationPost setSelected:NO];
    [btnEditProfile setSelected:NO];
}

-(void)getFriendList
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [serFriendList callWebServiceWithURLDict:GET_FRIEND_LIST
                               andHTTPMethod:@"POST"
                                 andDictData:dict
                                 withLoading:YES
                            andWebServiceTag:@"getFriendList"
                                    setToken:YES];
}

-(void)getVisitList
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [serVisitFriend callWebServiceWithURLDict:GET_VISIT_MY_PROFILE
                                andHTTPMethod:@"POST"
                                  andDictData:dict
                                  withLoading:YES
                             andWebServiceTag:@"getVisitedFrined"
                                     setToken:YES];
}

#pragma mark --Tableview Delegate Method--
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == tblFriendList)
    {
        return arrFriend.count;
    }
    else if (tableView == tblProfileVisit)
    {
        return arrVisitFriend.count;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tblFriendList)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friend" forIndexPath:indexPath];
        
        UIImageView *imgProfile = (UIImageView *)[cell viewWithTag:101];
        UILabel *lblName        = (UILabel *)[cell viewWithTag:102];
        UIButton *btnUnfriend   = (UIButton *)[cell viewWithTag:1];
        [btnUnfriend addTarget:self action:@selector(btnUnfriend:) forControlEvents:UIControlEventTouchUpInside];
        
        btnUnfriend.layer.cornerRadius = 5.0;
        btnUnfriend.layer.masksToBounds = YES;
        
        [imgProfile sd_setImageWithURL:[NSURL URLWithString:[[arrFriend objectAtIndex:indexPath.row] valueForKey:@"profile_pic"]] placeholderImage:[UIImage imageNamed:@"default_user_image.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            imgProfile.image = image;
        }];
        
        lblName.text = [NSString stringWithFormat:@"%@\n@%@",[[arrFriend objectAtIndex:indexPath.row] valueForKey:@"name"],[[arrFriend objectAtIndex:indexPath.row] valueForKey:@"vibe_name"]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (tableView == tblProfileVisit)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"visit" forIndexPath:indexPath];
        
        UIImageView *imgProfile = (UIImageView *)[cell viewWithTag:101];
        UILabel *lblName        = (UILabel *)[cell viewWithTag:102];
        
        [imgProfile sd_setImageWithURL:[NSURL URLWithString:[[arrVisitFriend objectAtIndex:indexPath.row] valueForKey:@"profile_pic"]] placeholderImage:[UIImage imageNamed:@"default_user_image.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            imgProfile.image = image;
        }];
        
        
        lblName.text = [NSString stringWithFormat:@"%@\n@%@",[[arrVisitFriend objectAtIndex:indexPath.row] valueForKey:@"name"],[[arrVisitFriend objectAtIndex:indexPath.row] valueForKey:@"vibe_name"]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tblFriendList)
    {
        [self performSegueWithIdentifier:@"profile" sender:[arrFriend objectAtIndex:indexPath.row]];
    }
    else if (tableView == tblProfileVisit)
    {
        [self performSegueWithIdentifier:@"profile" sender:[arrVisitFriend objectAtIndex:indexPath.row]];
    }
}



#pragma mark --Collectionview Delegate Method--
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(collectionView == collectionViewPost)
    {
        return [arrPhotoPosts count];
    }
    else if (collectionView == collectionViewGrid)
    {
        return [arrPhotoPosts count];
    }
    else if (collectionView == locationCollection)
    {
        return [arrLocationPosts count];
    }
    return 0;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == collectionViewPost)
    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellPhotos" forIndexPath:indexPath];
        cell.alpha = 0;
        cell.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5);
        [UIView animateWithDuration:0.7 animations:^{
            cell.alpha = 1;
            cell.layer.transform = CATransform3DScale(CATransform3DIdentity, 1, 1, 1);
        }];
        
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
        
        
        UITapGestureRecognizer *tapGestureWebsite = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnWebsite:)];
        tapGestureWebsite.numberOfTapsRequired = 1;
        tapGestureWebsite.cancelsTouchesInView = YES;
        [lblWebsite addGestureRecognizer:tapGestureWebsite];

        btnLike.accessibilityLabel = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
        btnComment.accessibilityLabel = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
        btnOption.accessibilityLabel = @"photo";
        
        NSDictionary *dictObj = [arrPhotoPosts objectAtIndex:indexPath.row];
        
        if([[dictObj valueForKey:@"is_like"] intValue] == 1)
        {
            btnLike.selected= YES;
        }
        
        [btnOption addTarget:self action:@selector(btnOption:) forControlEvents:UIControlEventTouchUpInside];
        [btnComment addTarget:self action:@selector(btnCommentPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [btnLike addTarget:self action:@selector(btnLikePhoto:) forControlEvents:UIControlEventTouchUpInside];
        
        viewMain.layer.cornerRadius = 5.0;
        viewMain.layer.masksToBounds = YES;
        viewMain.layer.borderWidth = 1.0;
        viewMain.layer.borderColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0].CGColor;
        
        imgProfile.layer.cornerRadius = 5.0;
        imgProfile.layer.masksToBounds = YES;
        imgProfile.layer.borderWidth = 1;
        imgProfile.layer.borderColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0].CGColor;
        
        
        PatternTapResponder hashTagTapAction = ^(NSString *tappedString)
        {
            HashTagVC *obj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HashTagVC"];
            obj.strHashTag = tappedString;
            
            [self.navigationController pushViewController:obj animated:YES];
            
        };
        [lblCaption enableHashTagDetectionWithAttributes:@{NSForegroundColorAttributeName:LOL_Vibe_Green_Color,
                                                           RLHighlightedBackgroundColorAttributeName:[UIColor clearColor],NSBackgroundColorAttributeName:[UIColor clearColor],RLHighlightedBackgroundCornerRadius:@5,
                                                           RLTapResponderAttributeName:hashTagTapAction}];
        NSString *strURL = [dictObj valueForKey:@"image"];
        
        [imgMain sd_setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:@"post_bg.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            imgMain.image = image;
        }];
        
        lblLikeCount.text = [NSString stringWithFormat:@"%@",[dictObj valueForKey:@"like"]];
        lblCommentCount.text = [NSString stringWithFormat:@"%@",[dictObj valueForKey:@"comment"]];
        
        
        const char *jsonString = [[dictObj valueForKey:@"feed_text"] UTF8String];
        NSData *jsonData = [NSData dataWithBytes:jsonString length:strlen(jsonString)];
        NSString *goodMsg = [[NSString alloc] initWithData:jsonData encoding:NSNonLossyASCIIStringEncoding];
        lblCaption.text=goodMsg;
        
        lblLocation.text =[dictObj valueForKey:@"location_text"];
        lblTime.text = [dictObj valueForKey:@"created_at"];
        
//        lblUserVibeName.text = [NSString stringWithFormat:@"@%@",[user userVibeName]];
//        lblUserFullName.text = [NSString stringWithFormat:@"%@, %@",[[user userFullName] capitalizedString],[user userAge]];
        
//        if ([[dictObj valueForKey:@"formatted_address"] length] > 0)
//        {
//            NSArray *arr = [[dictObj valueForKey:@"formatted_address"] componentsSeparatedByString:@","];
//            
//            lblCity.text = [NSString stringWithFormat:@"%@,%@",[arr objectAtIndex:0],[arr objectAtIndex:1]];
//        }
//        else
//        {
//            lblCity.text =  @"";
//        }
//        
//        lblWebsite.text = [user userWebsite];
        
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
        NSString *strProfile = [NSString stringWithFormat:@"%@",[LoggedInUser sharedUser].userProfilePic];
        [imgProfile sd_setImageWithURL:[NSURL URLWithString:strProfile] placeholderImage:[UIImage imageNamed:@"default_user_image.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            imgProfile.image = image;
        }];
        
        return cell;
    }
    else if (collectionView == locationCollection)
    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"locationCell" forIndexPath:indexPath];
        cell.alpha = 0;
        cell.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5);
        [UIView animateWithDuration:0.7 animations:^{
            cell.alpha = 1;
            cell.layer.transform = CATransform3DScale(CATransform3DIdentity, 1, 1, 1);
        }];
        
        UIView *viewMain            =(UIView *)     [cell viewWithTag:101];
        UIImageView *imgMain        =(UIImageView *)[cell viewWithTag:102];
        UIImageView *imgCity        =(UIImageView *)[cell viewWithTag:103];
        UILabel *lblCityName        =(UILabel *)    [cell viewWithTag:104];
        UILabel *lblLocatopmCity    =(UILabel *)    [cell viewWithTag:105];
        
        UIView *viewBot             =(UIView *)     [cell viewWithTag:106];
        ResponsiveLabel *lblCaption =(ResponsiveLabel *)[cell viewWithTag:107];
        UILabel *lblLocation        =(UILabel *)    [cell viewWithTag:108];
        UIButton *btnOption         =(UIButton *)   [cell viewWithTag:109];
        UIImageView *imgProfile     =(UIImageView *)[cell viewWithTag:110];
        
        UILabel *lblUserVibeName    =(UILabel *)    [cell viewWithTag:111];
        UILabel *lblUserFullName    =(UILabel *)    [cell viewWithTag:112];
        UILabel *lblCity            =(UILabel *)    [cell viewWithTag:113];
        UILabel *lblWebsite         =(UILabel *)    [cell viewWithTag:114];
        UILabel *lblCommentCount    =(UILabel *)    [cell viewWithTag:115];
        UILabel *lblLikeCount       =(UILabel *)    [cell viewWithTag:116];
        UIButton *btnComment        =(UIButton *)   [cell viewWithTag:117];
        UIButton *btnLike           =(UIButton *)   [cell viewWithTag:118];
        UIButton *btnDirection      =(UIButton *)   [cell viewWithTag:121];
        
        UITapGestureRecognizer *tapGestureWebsite = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnWebsiteLoc:)];
        tapGestureWebsite.numberOfTapsRequired = 1;
        tapGestureWebsite.cancelsTouchesInView = YES;
        [lblWebsite addGestureRecognizer:tapGestureWebsite];
        
        NSDictionary *dictObj = [arrLocationPosts objectAtIndex:indexPath.row];
        btnLike.accessibilityLabel = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
        btnComment.accessibilityLabel = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
        btnOption.accessibilityLabel = @"location";
        
        if([[dictObj valueForKey:@"is_like"] intValue] == 1)
        {
            btnLike.selected= YES;
        }
        
        [btnOption addTarget:self action:@selector(btnOption:) forControlEvents:UIControlEventTouchUpInside];
        [btnComment addTarget:self action:@selector(btnCommentLocation:) forControlEvents:UIControlEventTouchUpInside];
        [btnLike addTarget:self action:@selector(btnLikeLocation:) forControlEvents:UIControlEventTouchUpInside];
        [btnDirection addTarget:self action:@selector(btnDirection:) forControlEvents:UIControlEventTouchUpInside];
        
        viewMain.layer.cornerRadius = 5.0;
        viewMain.layer.masksToBounds = YES;
        viewMain.layer.borderWidth = 1.0;
        viewMain.layer.borderColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0].CGColor;
        
        viewBot.layer.cornerRadius = 5.0;
        viewBot.layer.masksToBounds = YES;
        viewBot.layer.borderWidth = 1.0;
        viewBot.layer.borderColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0].CGColor;
        
        imgProfile.layer.cornerRadius = 5.0;
        imgProfile.layer.masksToBounds = YES;
        imgProfile.layer.borderWidth = 1;
        imgProfile.layer.borderColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0].CGColor;
        
        PatternTapResponder hashTagTapAction = ^(NSString *tappedString)
        {
            HashTagVC *obj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HashTagVC"];
            obj.strHashTag = tappedString;
            
            [self.navigationController pushViewController:obj animated:YES];
            
        };
        [lblCaption enableHashTagDetectionWithAttributes:@{NSForegroundColorAttributeName:LOL_Vibe_Green_Color,
                                                           RLHighlightedBackgroundColorAttributeName:[UIColor clearColor],NSBackgroundColorAttributeName:[UIColor clearColor],RLHighlightedBackgroundCornerRadius:@5,
                                                           RLTapResponderAttributeName:hashTagTapAction}];
        
        NSString *strURL = [dictObj valueForKey:@"image"];
        
        [imgCity sd_setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:@"post_bg.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            imgCity.image = image;
        }];
        
        NSString *strLocURL = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?center=%@,%@&markers=icon:|%@,%@&zoom=12&size=1024x780",
                               [dictObj valueForKey:@"post_latitude"],
                               [dictObj valueForKey:@"post_longitude"],
                               [dictObj valueForKey:@"post_latitude"],
                               [dictObj valueForKey:@"post_longitude"]];
        
        strLocURL = [strLocURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [imgMain sd_setImageWithURL:[NSURL URLWithString:strLocURL] placeholderImage:[UIImage imageNamed:@"post_bg.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            imgMain.image = image;
        }];
        
        lblLikeCount.text = [NSString stringWithFormat:@"%@",[dictObj valueForKey:@"like"]];
        lblCommentCount.text = [NSString stringWithFormat:@"%@",[dictObj valueForKey:@"comment"]];
        
        
        const char *jsonString = [[dictObj valueForKey:@"feed_text"] UTF8String];
        NSData *jsonData = [NSData dataWithBytes:jsonString length:strlen(jsonString)];
        NSString *goodMsg = [[NSString alloc] initWithData:jsonData encoding:NSNonLossyASCIIStringEncoding];
        lblCaption.text=goodMsg;
        
        lblLocation.text =[NSString stringWithFormat:@"%@",[dictObj valueForKey:@"created_at"]];
        
        lblCityName.text = [[[dictObj valueForKey:@"location_text"] componentsSeparatedByString:@","] objectAtIndex:0];
        lblLocatopmCity.text = [[[dictObj valueForKey:@"location_text"] componentsSeparatedByString:@","] objectAtIndex:1];
        
//        lblUserVibeName.text = [NSString stringWithFormat:@"@%@",[user userVibeName]];
//        lblUserFullName.text = [NSString stringWithFormat:@"%@, %@",[[user userFullName] capitalizedString],[user userAge]];
        
//        if ([[dictObj valueForKey:@"formatted_address"] length] > 0)
//        {
//            NSArray *arr = [[dictObj valueForKey:@"formatted_address"] componentsSeparatedByString:@","];
//            
//            lblCity.text = [NSString stringWithFormat:@"%@,%@",[arr objectAtIndex:0],[arr objectAtIndex:1]];
//        }
//        else
//        {
//            lblCity.text =  @"";
//        }
        
//        lblWebsite.text = [user userWebsite];
  
        
//        if ([[dictObj valueForKey:@"vibe_name"] length] > 0)
//        {
//            lblUserVibeName.text = [NSString stringWithFormat:@"@%@",[dictObj valueForKey:@"vibe_name"]];
//        }
//        else
//        {
//            lblUserVibeName.text = @"";
//        }
        
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
        
        NSString *strProfile = [NSString stringWithFormat:@"%@",[LoggedInUser sharedUser].userProfilePic];
        [imgProfile sd_setImageWithURL:[NSURL URLWithString:strProfile] placeholderImage:[UIImage imageNamed:@"default_user_image.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            imgProfile.image = image;
        }];
        
        return cell;
    }
    else if (collectionView == collectionViewGrid)
    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellGrid" forIndexPath:indexPath];
        
        NSDictionary *dictObj = [arrPhotoPosts objectAtIndex:indexPath.row];
        
        NSString *strURL = [dictObj valueForKey:@"image"];
        UIImageView *imgMain        =(UIImageView *)[cell viewWithTag:10];
        
        [imgMain sd_setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:@"post_bg.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            imgMain.image = image;
        }];
        
        return cell;
    }
    
    return nil;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == collectionViewGrid)
    {
        NSString *dictObj = [[arrPhotoPosts objectAtIndex:indexPath.row] valueForKey:@"feed_id"];
        
        [self performSegueWithIdentifier:@"push_to_detail" sender:dictObj];
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == collectionViewPost)
    {
        return collectionViewPost.frame.size;
    }
    else if (collectionView == collectionViewGrid)
    {
        CGFloat sizeflot = collectionViewGrid.frame.size.width-5;
        sizeflot = sizeflot/3;
        CGSize size = CGSizeMake(sizeflot, sizeflot);
        return size;
    }
    else if (collectionView == locationCollection)
    {
        return locationCollection.frame.size;
    }
    return CGSizeZero;
}

-(void)tapOnWebsite:(UITapGestureRecognizer *)sender
{
    CGPoint location = [sender locationInView:collectionViewPost];
    NSIndexPath *indexPath = [collectionViewPost indexPathForItemAtPoint:location];
    
    NSString *strSelectedFriend = [[arrPhotoPosts objectAtIndex:indexPath.row] valueForKey:@"website"];
    
    WebBrowserVc *web = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"WebBrowserVc"];
    
    web.strURL = strSelectedFriend;
    
    [self.navigationController pushViewController:web animated:YES];
}

-(void)tapOnWebsiteLoc:(UITapGestureRecognizer *)sender {
    
    CGPoint location = [sender locationInView:locationCollection];
    NSIndexPath *indexPath = [locationCollection indexPathForItemAtPoint:location];
    
    NSString *strSelectedFriend = [[arrLocationPosts objectAtIndex:indexPath.row] valueForKey:@"website"];
    
    WebBrowserVc *web = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"WebBrowserVc"];
    
    web.strURL = strSelectedFriend;
    
    [self.navigationController pushViewController:web animated:YES];
}

#pragma mark PrepareForSegue Method
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"push_to_detail"])
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (btnPostPhoto.selected)
    {
        if (scrollView.contentOffset.x == roundf(scrollView.contentSize.width-scrollView.frame.size.width))
        {
            if (isEndPost)
            {
                return;
            }
            pageCountPost = pageCountPost+1;
            [self getPhotoFeed];
        }
    }
    else if (btnLocationPost.selected)
    {
        if (scrollView.contentOffset.x == roundf(scrollView.contentSize.width-scrollView.frame.size.width))
        {
            if (isEndLoc)
            {
                return;
            }
            pageCountLoc = pageCountLoc+1;
            [self getLocationFeed];
        }
    }
}

-(void)getPhotoFeed
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"photo" forKey:@"feed_type"];
    [dict setValue:[NSString stringWithFormat:@"%d",pageCountPost] forKey:@"page"];
    [dict setValue:Post_Limit forKey:@"limit"];
    [dict setValue:@"2" forKey:@"is_home_feed"];
    
    [getFeed callWebServiceWithURLDict:GET_POST
                         andHTTPMethod:@"POST"
                           andDictData:dict
                           withLoading:YES
                      andWebServiceTag:@"getPhotoFeed"
                              setToken:YES];
}

-(void)getLocationFeed
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"location" forKey:@"feed_type"];
    [dict setValue:[NSString stringWithFormat:@"%d",pageCountLoc] forKey:@"page"];
    [dict setValue:Post_Limit forKey:@"limit"];
    [dict setValue:@"2" forKey:@"is_home_feed"];
    
    [getFeed callWebServiceWithURLDict:GET_POST
                         andHTTPMethod:@"POST"
                           andDictData:dict
                           withLoading:YES
                      andWebServiceTag:@"getLocationFeed"
                              setToken:YES];
}

-(void)btnLikePhoto:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    NSInteger indexPath = [sender.accessibilityLabel intValue];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[[arrPhotoPosts objectAtIndex:indexPath] valueForKey:@"feed_id"] forKey:@"parent_id"];
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

-(void)btnLikeLocation:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    NSInteger indexPath = [sender.accessibilityLabel intValue];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[[arrLocationPosts objectAtIndex:indexPath] valueForKey:@"feed_id"] forKey:@"parent_id"];
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
    OptionClass *share = [[OptionClass alloc] initWithView:self andDelegate:self];
    
    if([sender.accessibilityLabel isEqualToString:@"photo"])
    {
        NSIndexPath *indexPath;
        indexPath = [collectionViewPost indexPathForItemAtPoint:[collectionViewPost convertPoint:sender.center fromView:sender.superview]];
        
        NSDictionary *dictVal = [arrPhotoPosts objectAtIndex:indexPath.row];
        [share UserProfileSharingOption:dictVal];
        
    }
    else if ([sender.accessibilityLabel isEqualToString:@"location"])
    {
        NSIndexPath *indexPath;
        indexPath = [locationCollection indexPathForItemAtPoint:[locationCollection convertPoint:sender.center fromView:sender.superview]];
        NSDictionary *dictVal = [arrLocationPosts objectAtIndex:indexPath.row];
        [share UserProfileSharingOption:dictVal];
    }
}
-(void)btnCommentPhoto:(UIButton *)sender
{
    NSInteger indexPath = [sender.accessibilityLabel intValue];
    
    CommentController *obj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentController"];
    obj.dictPost = [arrPhotoPosts objectAtIndex:indexPath];
    
    [self.navigationController pushViewController:obj animated:YES];
}

-(void)btnCommentLocation:(UIButton *)sender
{
    NSInteger indexPath = [sender.accessibilityLabel intValue];
    
    CommentController *obj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentController"];
    obj.dictPost = [arrLocationPosts objectAtIndex:indexPath];
    
    [self.navigationController pushViewController:obj animated:YES];
}

-(void)btnDirection:(UIButton *)sender
{
    UICollectionViewCell *cell = (UICollectionViewCell *)[sender findSuperViewWithClass:[UICollectionViewCell class]];
    
    NSIndexPath *indexPath = [locationCollection indexPathForCell:cell];
    
    destiLat = [[[arrLocationPosts objectAtIndex:indexPath.row] valueForKey:@"post_latitude"] floatValue];
    destiLong = [[[arrLocationPosts objectAtIndex:indexPath.row] valueForKey:@"post_longitude"] floatValue];
    
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Directions"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Apple Maps",@"Google Maps", nil];
    sheet.tag = 1111;
    [sheet showInView:self.view];
}

-(void)btnUnfriend:(UIButton *)sender
{
    UITableViewCell *cell = (UITableViewCell *)[sender findSuperViewWithClass:[UITableViewCell class]];
    
    indexPathUnfriend = [tblFriendList indexPathForCell:cell];
    
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:@"Unfriend"
                                              otherButtonTitles:nil];
    sheet.tag = 222;
    [sheet showInView:self.view];
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

#pragma mark - UIActionSheet Delegate Methods
- (void)actionSheet:(UIActionSheet *)menu didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (menu.tag)
    {
        case 1111:
            if (buttonIndex==0)
            {
                //Apple Maps, using the MKMapItem class
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.apple.com/?daddr=%f,%f&saddr=%f,%f",destiLat, destiLong, sourceLat, sourceLong]];
                [[UIApplication sharedApplication] openURL:url];
            }
            else if (buttonIndex==1)
            {
                //Google Maps
                //construct a URL using the comgooglemaps schema
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps-x-callback://?saddr=%f,%f&daddr=%f,%f&x-success=GoKids://?resume=true&x-source=GoKids", destiLat, destiLong,  sourceLat, sourceLong]];
                
                [[UIApplication sharedApplication] openURL:url];
            }
            break;
            
        case 222:
            if (buttonIndex == 0)
            {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setValue:[[arrFriend objectAtIndex:indexPathUnfriend.row] valueForKey:@"friend_id"] forKey:@"friend_id"];
                
                WebService *unfriend = [[WebService alloc] initWithView:self.view andDelegate:self];
                
                [unfriend callWebServiceWithURLDict:UNFRIEND
                                      andHTTPMethod:@"POST"
                                        andDictData:dict
                                        withLoading:YES
                                   andWebServiceTag:@"unfriend"
                                           setToken:YES];
            }
            break;
    }
}

-(void)instaGramWallPost:(UIImage *)imgShare
{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    
    if([[UIApplication sharedApplication] canOpenURL:instagramURL]) //check for App is install or not
    {
        UIImage *imageToUse = imgShare;
        NSString *documentDirectory=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *saveImagePath=[documentDirectory stringByAppendingPathComponent:@"Image.igo"];
        NSData *imageData=UIImagePNGRepresentation(imageToUse);
        [imageData writeToFile:saveImagePath atomically:YES];
        NSURL *imageURL=[NSURL fileURLWithPath:saveImagePath];
        self.documentController=[[UIDocumentInteractionController alloc]init];
        self.documentController = [UIDocumentInteractionController interactionControllerWithURL:imageURL];
        self.documentController.delegate = self;
        self.documentController.annotation = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Testing"], @"InstagramCaption", nil];
        self.documentController.UTI = @"com.instagram.exclusivegram";
        UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
        [self.documentController presentOpenInMenuFromRect:CGRectMake(1, 1, 1, 1) inView:vc.view animated:YES];
    }
    else
    {
        [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Instagram not install in your IPhone"];
    }
}

#pragma mark --Button Action--

- (IBAction)btnPostPhoto:(id)sender
{
    [self buttoneDfaultState];
    [btnPostPhoto setSelected:YES];
    
    [self hideView:viewGrid];
    [self hideView:viewLocation];
    [self hideView:viewFriendList];
    [self hideView:viewProfileVisit];
    [self showView:viewPhoto];
    
    pageCountPost = 1;
    [arrPhotoPosts removeAllObjects];
    
    [self getPhotoFeed];
}
- (IBAction)btnPostGrid:(id)sender
{
    [self buttoneDfaultState];
    [btnPostGrid setSelected:YES];
    
    [self hideView:viewPhoto];
    [self hideView:viewLocation];
    [self hideView:viewFriendList];
    [self hideView:viewProfileVisit];
    [self showView:viewGrid];
    [collectionViewGrid reloadData];
}
- (IBAction)btnFriends:(id)sender
{
    [self buttoneDfaultState];
    [btnFriends setSelected:YES];
    
    [self hideView:viewPhoto];
    [self hideView:viewGrid];
    [self showView:viewFriendList];
    [self hideView:viewLocation];
    [self hideView:viewProfileVisit];
    
     [self getFriendList];
}
- (IBAction)btnProfileSeen:(id)sender
{
    [self buttoneDfaultState];
    [btnProfileSeen setSelected:YES];
    
    [self hideView:viewPhoto];
    [self hideView:viewGrid];
    [self showView:viewProfileVisit];
    [self hideView:viewLocation];
    [self hideView:viewFriendList];
    
    [self getVisitList];
}
- (IBAction)btnLocationPost:(id)sender
{
    [self buttoneDfaultState];
    [btnLocationPost setSelected:YES];
    
    [self hideView:viewPhoto];
    [self hideView:viewGrid];
    [self showView:viewLocation];
    [self hideView:viewFriendList];
    [self hideView:viewProfileVisit];
    
    pageCountLoc = 1;
    [arrLocationPosts removeAllObjects];
    
    [self getLocationFeed];
}
- (IBAction)btnEditProfile:(id)sender
{
    [self buttoneDfaultState];
    [btnEditProfile setSelected:YES];
}

#pragma mark --Show and Hide View--
-(void)showView:(UIView *)viewPost
{
    [viewPost setHidden:NO];
    [self.view bringSubviewToFront:viewPost];
}

-(void)hideView:(UIView *)viewPost
{
    [viewPost setHidden:YES];
    [self.view sendSubviewToBack:viewPost];
}

#pragma mark --Webservice Delegate Method--
-(void)webserviceCallFinishedWithSuccess:(BOOL)success andResponseObject:(id)responseObj andError:(NSError *)error forWebServiceTag:(NSString *)tagStr
{
    if(success)
    {
        NSDictionary *dictResult = (NSDictionary *)responseObj;
        NSLog(@"%@",dictResult);
        if([tagStr isEqualToString:@"getLocationFeed"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                [arrLocationPosts addObjectsFromArray:[dictResult valueForKey:@"feed_info"]];
                [locationCollection reloadData];
                
                if ([[dictResult valueForKey:@"feed_info"] count] < [Post_Limit intValue])
                {
                    isEndLoc = YES;
                }
                else
                {
                    isEndLoc = NO;
                }
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
        else if([tagStr isEqualToString:@"getPhotoFeed"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                [arrPhotoPosts addObjectsFromArray:[dictResult valueForKey:@"feed_info"]];
                
                [collectionViewPost reloadData];
                [collectionViewGrid reloadData];
                
                if ([[dictResult valueForKey:@"feed_info"] count] < [Post_Limit intValue])
                {
                    isEndPost = YES;
                }
                else
                {
                    isEndPost = NO;
                }
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
        else if ([tagStr isEqualToString:@"getFriendList"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                [arrFriend removeAllObjects];
                [arrFriend addObjectsFromArray:[dictResult valueForKey:@"data"]];
                [tblFriendList reloadData];
                lblFriendCount.text = [NSString stringWithFormat:@"(%d)",(int)[arrFriend count]];
                
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
        else if ([tagStr isEqualToString:@"getVisitedFrined"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                [arrVisitFriend removeAllObjects];
                [arrVisitFriend addObjectsFromArray:[dictResult valueForKey:@"data"]];
                [tblProfileVisit reloadData];
                lblVisitCount.text = [NSString stringWithFormat:@"(%d)",(int)[arrVisitFriend count]];
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
        else if ([tagStr isEqualToString:@"unfriend"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                [self getFriendList];
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
                 [[NSNotificationCenter defaultCenter] postNotificationName:kRefressHomeFeed object:nil];
                
                if (btnLocationPost.selected)
                {
                    [self getLocationFeed];
                }
                else
                {
                    [self getPhotoFeed];
                }
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
    }
}
@end
