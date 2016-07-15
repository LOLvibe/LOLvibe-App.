//
//  ProfileVC.m
//  LOL Vibe
//
//  Created by Paras Navadiya on 05/05/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "OtherProfileVC.h"
#import "ServiceConstant.h"
#import "PostDetails.h"
#import "CommentController.h"
#import "UIImageView+WebCache.h"
#import "ProfileImageController.h"
#import "UIView+SuperView.h"
#import "LocationInvitePlaces.h"
#import "OptionClass.h"
#import "HashTagVC.h"

@interface OtherProfileVC ()<UICollectionViewDataSource,UICollectionViewDelegate,WebServiceDelegate,CLLocationManagerDelegate,UIActionSheetDelegate,OptionClassDelegate>
{
    WebService *serLogout;
    WebService *getFeed;
    WebService *serFriendList;
    
    AppDelegate *appDel;
    LoggedInUser *user;
    
    NSMutableArray *arrPhotoPosts;
    NSMutableArray *arrLocationPosts;
    NSMutableArray *arrFriend;
    
    BOOL isImagePost;
    BOOL isLocationPost;
    BOOL isGridView;
    
    
    CLLocationManager   *locationManager;
    float   sourceLat,sourceLong;
    float   destiLat,destiLong;
    int                 pageCountPost,pageCountLoc;
    BOOL                isEndPost,isEndLoc;
    
    
}
@end

@implementation OtherProfileVC
@synthesize dictUser;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    pageCountPost = pageCountLoc = 1;
    
    serLogout           = [[WebService alloc]initWithView:self.view andDelegate:self];
    getFeed             = [[WebService alloc]initWithView:self.view andDelegate:self];
    serFriendList       = [[WebService alloc] initWithView:self.view andDelegate:self];
    
    arrPhotoPosts       = [[NSMutableArray alloc]init];
    arrLocationPosts    = [[NSMutableArray alloc]init];
    arrFriend           = [[NSMutableArray alloc]init];
    
    appDel = APP_DELEGATE;
    
    self.title = @"";
    
    [self visitOtherUserProfile];
    [self btnPostGrid:nil];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setDefulatValues];
    
    
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
    }
    [locationManager startUpdatingLocation];
    
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
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


-(void)setDefulatValues
{
    lblFullName.text = [NSString stringWithFormat:@"%@",[dictUser valueForKey:@"name"]];
    lblVibeName.text = [NSString stringWithFormat:@"@%@",[dictUser valueForKey:@"vibe_name"]];
    
    btnProfilePic.layer.cornerRadius = btnProfilePic.frame.size.height/2;
    btnProfilePic.layer.masksToBounds = YES;
    
    UIImageView *imgProfile = [[UIImageView alloc] init];
    [imgProfile sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dictUser valueForKey:@"profile_pic"]]] placeholderImage:[UIImage imageNamed:@""] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [btnProfilePic setImage:image forState:UIControlStateNormal];
    }];
}

-(void)visitOtherUserProfile
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[dictUser valueForKey:@"user_id"] forKey:@"other_user_id"];
    
    WebService *serVisitProfile = [[WebService alloc] initWithView:self.view andDelegate:self];
    [serVisitProfile callWebServiceWithURLDict:VISIT_OTHER_PROFILE
                                 andHTTPMethod:@"POST"
                                   andDictData:dict
                                   withLoading:YES
                              andWebServiceTag:@"visitProfile"
                                      setToken:YES];
}

-(void)buttoneDfaultState
{
    [btnPostPhoto setSelected:NO];
    [btnPostGrid setSelected:NO];
    [btnFriends setSelected:NO];
    [btnLocationPost setSelected:NO];
}

-(void)getFriendList
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[dictUser valueForKey:@"user_id"] forKey:@"other_user_id"];
    
    [serFriendList callWebServiceWithURLDict:GET_FRIEND_LIST
                               andHTTPMethod:@"POST"
                                 andDictData:dict
                                 withLoading:YES
                            andWebServiceTag:@"getFriendList"
                                    setToken:YES];
}

#pragma mark --Tableview Delegate Method--
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrFriend.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friend" forIndexPath:indexPath];
    
    UIImageView *imgProfile = (UIImageView *)[cell viewWithTag:100];
    UILabel *lblName        = (UILabel *)[cell viewWithTag:102];
    UILabel *lblVibeName1    = (UILabel *)[cell viewWithTag:103];
    UIButton *btnAddFrnd    = (UIButton *)[cell viewWithTag:104];
    
    [btnAddFrnd addTarget:self action:@selector(btnAddFrnd:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[[arrFriend objectAtIndex:indexPath.row] valueForKey:@"is_friend"] intValue] == 0)
    {
        [btnAddFrnd setHidden:NO];
        btnAddFrnd.selected = NO;
    }
    else if([[[arrFriend objectAtIndex:indexPath.row] valueForKey:@"is_friend"] intValue] == 1)
    {
        [btnAddFrnd setHidden:YES];
        btnAddFrnd.selected = YES;
    }
    else if([[[arrFriend objectAtIndex:indexPath.row] valueForKey:@"is_friend"] intValue] == 2)
    {
        [btnAddFrnd setHidden:YES];
    }
    else if([[[arrFriend objectAtIndex:indexPath.row] valueForKey:@"is_friend"] intValue] == 3)
    {
        [btnAddFrnd setHidden:NO];
        btnAddFrnd.selected = YES;
    }
    
    [imgProfile sd_setImageWithURL:[NSURL URLWithString:[[arrFriend objectAtIndex:indexPath.row] valueForKey:@"profile_pic"]] placeholderImage:[UIImage imageNamed:@"default_user_image.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        imgProfile.image = image;
    }];
    
    lblName.text = [NSString stringWithFormat:@"%@",[[arrFriend objectAtIndex:indexPath.row] valueForKey:@"name"]];
    
    lblVibeName1.text= [NSString stringWithFormat:@"@%@",[[arrFriend objectAtIndex:indexPath.row] valueForKey:@"vibe_name"]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[[arrFriend objectAtIndex:indexPath.row] valueForKey:@"user_id"] isEqualToString:[LoggedInUser sharedUser].userId]) {
        return;
    }
    
    OtherProfileVC *obj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"OtherProfileVC"];
    obj.dictUser = [arrFriend objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:obj animated:YES];
}

#pragma mark --Collectionview Delegate Method--
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(collectionView == collectionViewPost || collectionView == collectionViewGrid )
    {
        return [arrPhotoPosts count];
    }
    else
    {
        return [arrLocationPosts count];
    }
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
        
        UIView *viewMain            =(UIView *)     [cell viewWithTag:101];
        UIImageView *imgMain        =(UIImageView *)[cell viewWithTag:102];
        ResponsiveLabel *lblCaption =(ResponsiveLabel *)[cell viewWithTag:103];
        UIButton *btnOption         =(UIButton *)   [cell viewWithTag:104];
        UILabel *lblLocation        =(UILabel *)    [cell viewWithTag:105];
        UILabel *lblTime            =(UILabel *)    [cell viewWithTag:106];
        
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
        ResponsiveLabel *lblCaption =(ResponsiveLabel *)    [cell viewWithTag:107];
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
        UIButton *btnLocationInvite =(UIButton *)   [cell viewWithTag:215];
        UIButton *btnDirection      =(UIButton *)   [cell viewWithTag:121];
        UITapGestureRecognizer *tapGestureWebsite = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnWebsiteLoc:)];
        tapGestureWebsite.numberOfTapsRequired = 1;
        tapGestureWebsite.cancelsTouchesInView = YES;
        [lblWebsite addGestureRecognizer:tapGestureWebsite];
        
        
        [btnDirection addTarget:self action:@selector(btnDirection:) forControlEvents:UIControlEventTouchUpInside];
        
        NSDictionary *dictObj = [arrLocationPosts objectAtIndex:indexPath.row];
        btnLike.accessibilityLabel = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
        btnComment.accessibilityLabel = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
        btnOption.accessibilityLabel = @"location";
        
        if([[dictObj valueForKey:@"is_like"] intValue] == 1)
        {
            btnLike.selected= YES;
        }
        
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
        
        [btnOption addTarget:self action:@selector(btnOption:) forControlEvents:UIControlEventTouchUpInside];
        [btnComment addTarget:self action:@selector(btnCommentLocation:) forControlEvents:UIControlEventTouchUpInside];
        [btnLike addTarget:self action:@selector(btnLikeLocation:) forControlEvents:UIControlEventTouchUpInside];
        [btnLocationInvite addTarget:self action:@selector(btnLocationInvite:) forControlEvents:UIControlEventTouchUpInside];
        [btnDirection addTarget:self action:@selector(btnDirection:) forControlEvents:UIControlEventTouchUpInside];
        
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
-(void)tapOnWebsite:(UITapGestureRecognizer *)sender {
    
    
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
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == collectionViewGrid)
    {
        NSDictionary *dictObj = [[arrPhotoPosts objectAtIndex:indexPath.row] valueForKey:@"feed_id"];
        [self performSegueWithIdentifier:@"push_to_detail" sender:dictObj];
    }
    else
    {
        return;
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"push_to_detail"])
    {
        PostDetails *vc = [segue destinationViewController];
        vc.strFeedID = sender;
    }
    else if ([[segue identifier] isEqualToString:@"profile"])
    {
        ProfileImageController *obj = [segue destinationViewController];
        obj.dictinfo = (NSDictionary *)sender;
    }
    else if ([[segue identifier] isEqualToString:@"show_places"])
    {
        LocationInvitePlaces *vc = [segue destinationViewController];
        vc.strUsers = sender;
    }
    else if([[segue identifier] isEqualToString:@"profile"])
    {
        ProfileImageController *obj = [segue destinationViewController];
        obj.dictinfo = (NSDictionary *)sender;
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
        CGFloat sizeflot = collectionViewGrid.frame.size.width - 5;
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
    [dict setValue:[NSString stringWithFormat:@"%d",pageCountPost]     forKey:@"page"];
    [dict setValue:Post_Limit    forKey:@"limit"];
    [dict setValue:@"2"     forKey:@"is_home_feed"];
    [dict setValue:[dictUser valueForKey:@"user_id"] forKey:@"other_user_id"];
    
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
    [dict setValue:@"location"  forKey:@"feed_type"];
    [dict setValue:[NSString stringWithFormat:@"%d",pageCountPost]     forKey:@"page"];
    [dict setValue:Post_Limit    forKey:@"limit"];
    [dict setValue:@"2"         forKey:@"is_home_feed"];
    [dict setValue:[dictUser valueForKey:@"user_id"] forKey:@"other_user_id"];
    
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
    
    UICollectionViewCell *cell = (UICollectionViewCell *) [self superviewWithClassName:@"UICollectionViewCell" fromView:sender];
    UILabel *lblLikeCount;
    NSMutableDictionary *dictReplace;
    int count = 0;
    NSIndexPath *indexPathSelected;
    if (cell)
    {
        lblLikeCount       = (UILabel *)[cell viewWithTag:112];
        indexPathSelected = [collectionViewPost indexPathForCell:cell];
        
        count = [[[arrPhotoPosts objectAtIndex:indexPathSelected.row] valueForKey:@"like"] intValue];
        
    }
    
    WebService *serLikePost = [[WebService alloc] initWithView:self.view andDelegate:self];
    if(sender.selected)
    {
        count = count + 1;
        dictReplace = [[NSMutableDictionary alloc]initWithDictionary:[arrPhotoPosts objectAtIndex:indexPathSelected.row]];
        [dictReplace setValue:[NSString stringWithFormat:@"%d",count] forKey:@"like"];
        
        [arrPhotoPosts replaceObjectAtIndex:indexPathSelected.row withObject:dictReplace];
        
        [serLikePost callWebServiceWithURLDict:LIKE_POST
                                 andHTTPMethod:@"POST"
                                   andDictData:dict
                                   withLoading:NO
                              andWebServiceTag:@"likepost"
                                      setToken:YES];
        
    }
    else
    {
        count = count - 1;
        dictReplace = [[NSMutableDictionary alloc]initWithDictionary:[arrPhotoPosts objectAtIndex:indexPathSelected.row]];
        [dictReplace setValue:[NSString stringWithFormat:@"%d",count] forKey:@"like"];
        
        [arrPhotoPosts replaceObjectAtIndex:indexPathSelected.row withObject:dictReplace];
        
        [serLikePost callWebServiceWithURLDict:UNLIKE_POST
                                 andHTTPMethod:@"POST"
                                   andDictData:dict
                                   withLoading:NO
                              andWebServiceTag:@"likepost"
                                      setToken:YES];
    }
    lblLikeCount.text = [NSString stringWithFormat:@"%d",count];
}

-(void)btnLikeLocation:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    NSInteger indexPath = [sender.accessibilityLabel intValue];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[[arrLocationPosts objectAtIndex:indexPath] valueForKey:@"feed_id"] forKey:@"parent_id"];
    [dict setValue:@"post" forKey:@"like_type"];
    
    UICollectionViewCell *cell = (UICollectionViewCell *) [self superviewWithClassName:@"UICollectionViewCell" fromView:sender];
    UILabel *lblLikeCount;
    NSMutableDictionary *dictReplace;
    
    NSIndexPath *indexPathSelected;
    
    
    int count = 0;
    if (cell)
    {
        lblLikeCount       =(UILabel *)    [cell viewWithTag:116];
        NSIndexPath *indexPathSelected = [collectionViewPost indexPathForCell:cell];
        
        count = [[[arrLocationPosts objectAtIndex:indexPathSelected.row] valueForKey:@"like"] intValue];
    }
    
    WebService *serLikePost = [[WebService alloc] initWithView:self.view andDelegate:self];
    if(sender.selected)
    {
        count = count + 1;
        dictReplace = [[NSMutableDictionary alloc]initWithDictionary:[arrLocationPosts objectAtIndex:indexPathSelected.row]];
        [dictReplace setValue:[NSString stringWithFormat:@"%d",count] forKey:@"like"];
        [arrLocationPosts replaceObjectAtIndex:indexPathSelected.row withObject:dictReplace];
        
        [serLikePost callWebServiceWithURLDict:LIKE_POST andHTTPMethod:@"POST" andDictData:dict withLoading:NO andWebServiceTag:@"likepost" setToken:YES];
    }
    else
    {
        count = count - 1;
        dictReplace = [[NSMutableDictionary alloc]initWithDictionary:[arrLocationPosts objectAtIndex:indexPathSelected.row]];
        [dictReplace setValue:[NSString stringWithFormat:@"%d",count] forKey:@"like"];
        [arrLocationPosts replaceObjectAtIndex:indexPathSelected.row withObject:dictReplace];
        
        [serLikePost callWebServiceWithURLDict:UNLIKE_POST andHTTPMethod:@"POST" andDictData:dict withLoading:NO andWebServiceTag:@"likepost" setToken:YES];
    }
    lblLikeCount.text = [NSString stringWithFormat:@"%d",count];
}


-(void)btnOption:(UIButton *)sender
{
    OptionClass *share = [[OptionClass alloc] initWithView:self andDelegate:self];
    
    if([sender.accessibilityLabel isEqualToString:@"photo"])
    {
        UICollectionViewCell *cell = (UICollectionViewCell *)[sender findSuperViewWithClass:[UICollectionViewCell class]];
        UIImageView *img = (UIImageView *)[cell viewWithTag:102];
        
        NSIndexPath *indexPath = [collectionViewPost indexPathForCell:cell];
        
        
        NSDictionary *dictVal = [arrPhotoPosts objectAtIndex:indexPath.row];
        [share UserProfileSharingOption:dictVal Image:img.image];
        
    }
    else if ([sender.accessibilityLabel isEqualToString:@"location"])
    {
        UICollectionViewCell *cell = (UICollectionViewCell *)[sender findSuperViewWithClass:[UICollectionViewCell class]];
        UIImageView *img = (UIImageView *)[cell viewWithTag:102];
        NSIndexPath *indexPath = [locationCollection indexPathForCell:cell];
        
        NSDictionary *dictVal = [arrLocationPosts objectAtIndex:indexPath.row];
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
        _documentController.UTI = @"com.instagram.exclusivegram";
        
        [_documentController presentOpenInMenuFromRect:self.view.frame inView:self.view animated:YES];
    }
    else
    {
        [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Instagram not install in your IPhone"];
    }
}

-(void)btnCommentPhoto:(UIButton *)sender
{
    NSInteger indexPath = [sender.accessibilityLabel intValue];
    
    CommentController *obj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentController"];
    obj.dictPost = [arrPhotoPosts objectAtIndex:indexPath];
    obj.isInvite = NO;
    [self.navigationController pushViewController:obj animated:YES];
}

-(void)btnCommentLocation:(UIButton *)sender
{
    NSInteger indexPath = [sender.accessibilityLabel intValue];
    
    CommentController *obj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentController"];
    obj.dictPost = [arrLocationPosts objectAtIndex:indexPath];
    obj.isInvite = NO;
    [self.navigationController pushViewController:obj animated:YES];
}

-(void)btnLocationInvite:(UIButton *)sender
{
    UICollectionViewCell *cell = (UICollectionViewCell *)[sender findSuperViewWithClass:[UICollectionViewCell class]];
    
    NSIndexPath *indexPath = [locationCollection indexPathForCell:cell];
    
    NSString *strSelectedFriend = [[arrLocationPosts objectAtIndex:indexPath.row] valueForKey:@"user_id"];
    
    [self performSegueWithIdentifier:@"show_places" sender:strSelectedFriend];
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
        
        [dictPara setValue:[dict valueForKey:@"feed_text"] forKey:@"feed_text"];
        
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
        
        [dictPara setValue:[dict valueForKey:@"feed_text"] forKey:@"feed_text"];
        
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
-(void)btnAddFrnd:(UIButton *)sender
{
    if(!sender.selected)
    {
        UITableViewCell *cell = (UITableViewCell *)[sender findSuperViewWithClass:[UITableViewCell class]];
        
        NSIndexPath *indexPath = [tblFriendList indexPathForCell:cell];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:[[arrFriend objectAtIndex:indexPath.row] valueForKey:@"user_id"] forKey:@"other_user_id"];
        
        WebService *addfriend = [[WebService alloc] initWithView:self.view andDelegate:self];
        
        [addfriend callWebServiceWithURLDict:SEND_REQUEST
                               andHTTPMethod:@"POST"
                                 andDictData:dict
                                 withLoading:YES
                            andWebServiceTag:@"addfriend"
                                    setToken:YES];
    }
}

- (UIView *)superviewWithClassName:(NSString *)className fromView:(UIView *)view
{
    while (view)
    {
        if ([NSStringFromClass([view class]) isEqualToString:className])
        {
            return view;
        }
        view = view.superview;
    }
    return nil;
}

#pragma mark --Button Action--
- (IBAction)btnAddFriend:(id)sender
{
    if (btnAddFriend.isSelected) {
        return;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[dictUser valueForKey:@"user_id"] forKey:@"other_user_id"];
    
    WebService *addfriend = [[WebService alloc] initWithView:self.view andDelegate:self];
    
    [addfriend callWebServiceWithURLDict:SEND_REQUEST
                           andHTTPMethod:@"POST"
                             andDictData:dict
                             withLoading:YES
                        andWebServiceTag:@"addfriend"
                                setToken:YES];
}

- (IBAction)btnPostPhoto:(id)sender
{
    [self buttoneDfaultState];
    [btnPostPhoto setSelected:YES];
    
    [self hideView:viewGrid];
    [self hideView:viewLocation];
    [self hideView:viewFriendList];
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
    [self getFriendList];
}

- (IBAction)btnLocationPost:(id)sender
{
    [self buttoneDfaultState];
    [btnLocationPost setSelected:YES];
    
    [self hideView:viewPhoto];
    [self hideView:viewGrid];
    [self hideView:viewFriendList];
    [self showView:viewLocation];
    
    pageCountLoc = 1;
    [arrLocationPosts removeAllObjects];
    
    [self getLocationFeed];
}

- (IBAction)btnProfilePic:(UIButton *)sender
{
    NSDictionary *dictInfo = @{@"name":[dictUser valueForKey:@"vibe_name"],@"profile_pic":[dictUser valueForKey:@"profile_pic"]};
    [self performSegueWithIdentifier:@"profile" sender:dictInfo];
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
            else if ([[dictResult valueForKey:@"status_code"] intValue] == 13)
            {
                [self.view bringSubviewToFront:lockView];
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
                arrFriend = [dictResult valueForKey:@"data"];
                [tblFriendList reloadData];
                lblFriendCount.text = [NSString stringWithFormat:@"(%d)",(int)[arrFriend count]];
                
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
        else if ([tagStr isEqualToString:@"visitProfile"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                [self getPhotoFeed];
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
                [btnAddFriend setSelected:YES];
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Your friend request sent successfully."];
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
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Repost successful!"];
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
    }
}

@end
