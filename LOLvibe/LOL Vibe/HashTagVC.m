//
//  HomeVC.m
//  LOL Vibe
//
//  Created by Paras Navadiya on 05/05/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "HashTagVC.h"
#import "ServiceConstant.h"
#import "CommentController.h"
#import "UIView+SuperView.h"
#import "LocationInvitePlaces.h"
#import "OptionClass.h"
#import "OtherProfileVC.h"

@interface HashTagVC () <WebServiceDelegate,CLLocationManagerDelegate,UIActionSheetDelegate,OptionClassDelegate>
{
    WebService *serGetFeed;
    NSMutableArray *arrFeed;
    NSIndexPath *indexPathSelected;
    BOOL isLike;
    NSInteger likeInteger;
    
    CLLocationManager   *locationManager;
    float   sourceLat,sourceLong;
    float   destiLat,destiLong;
}
@end

@implementation HashTagVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    serGetFeed = [[WebService alloc] initWithView:self.view andDelegate:self];
    isLike = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = self.strHashTag;

    [self getFeed:YES];
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
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.title = @"";
}
#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //NSLog(@"didUpdateToLocation: %@", newLocation);
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

-(void)getFeed:(BOOL)isLoading
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[self.strHashTag stringByReplacingOccurrencesOfString:@"#" withString:@""] forKey:@"string"];
    
    [serGetFeed callWebServiceWithURLDict:HASH_POST
                            andHTTPMethod:@"POST"
                              andDictData:dict
                              withLoading:isLoading
                         andWebServiceTag:@"getFeed"
                                 setToken:YES];
}


#pragma mark --Collectionview Delegate Method--
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return arrFeed.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([[[arrFeed objectAtIndex:indexPath.row] valueForKey:@"post_type"] isEqualToString:@"photo"])
    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellPhotos" forIndexPath:indexPath];
        cell.alpha = 0;
        cell.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5);
        [UIView animateWithDuration:0.3 animations:^{
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
        PatternTapResponder hashTagTapAction = ^(NSString *tappedString)
        {
            HashTagVC *obj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HashTagVC"];
            obj.strHashTag = tappedString;
            
            [self.navigationController pushViewController:obj animated:YES];
            
        };
        [lblCaption enableHashTagDetectionWithAttributes:@{NSForegroundColorAttributeName:LOL_Vibe_Green_Color,
                                                           RLHighlightedBackgroundColorAttributeName:[UIColor clearColor],NSBackgroundColorAttributeName:[UIColor clearColor],RLHighlightedBackgroundCornerRadius:@5,
                                                           RLTapResponderAttributeName:hashTagTapAction}];
        
        
        NSDictionary *dictObj = [arrFeed objectAtIndex:indexPath.row];
        
        NSString *strURL = [dictObj valueForKey:@"image"];
        
        [imgMain sd_setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:@"post_bg.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            imgMain.image = image;
            if (!image)
            {
                imgMain.image =[UIImage imageNamed:@"post_bg.png"];
            }

        }];
        
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
            if (!image)
            {
                imgProfile.image =[UIImage imageNamed:@"default_user_image.png"];
            }
        }];
        
        return cell;
    }
    else if([[[arrFeed objectAtIndex:indexPath.row] valueForKey:@"post_type"] isEqualToString:@"location"])
    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"locationCell" forIndexPath:indexPath];
        cell.alpha = 0;
        cell.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5);
        [UIView animateWithDuration:0.3 animations:^{
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
        UIButton *btnAddFriend      =(UIButton *)   [cell viewWithTag:120];
        UIButton *btnDirection      =(UIButton *)   [cell viewWithTag:121];
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
        
        viewBot.layer.cornerRadius = 5.0;
        viewBot.layer.masksToBounds = YES;
        viewBot.layer.borderWidth = 1.0;
        viewBot.layer.borderColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0].CGColor;
        
        imgProfile.layer.cornerRadius = 5.0;
        imgProfile.layer.masksToBounds = YES;
        imgProfile.layer.borderWidth = 1;
        imgProfile.layer.borderColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0].CGColor;
        
        [btnOption addTarget:self action:@selector(btnOption:) forControlEvents:UIControlEventTouchUpInside];
        [btnComment addTarget:self action:@selector(btnComment:) forControlEvents:UIControlEventTouchUpInside];
        [btnLike addTarget:self action:@selector(btnLike:) forControlEvents:UIControlEventTouchUpInside];
        [btnAddFriend addTarget:self action:@selector(isFriendOrNot:) forControlEvents:UIControlEventTouchUpInside];
        [btnLocationInvite addTarget:self action:@selector(btnLocationInvite:) forControlEvents:UIControlEventTouchUpInside];
        [btnDirection addTarget:self action:@selector(btnDirection:) forControlEvents:UIControlEventTouchUpInside];
        
        NSDictionary *dictObj = [arrFeed objectAtIndex:indexPath.row];
        
        NSString *strURL = [dictObj valueForKey:@"image"];
        
       
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
        
        PatternTapResponder hashTagTapAction = ^(NSString *tappedString)
        {
            HashTagVC *obj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HashTagVC"];
            obj.strHashTag = tappedString;
            
            [self.navigationController pushViewController:obj animated:YES];
            
        };
        [lblCaption enableHashTagDetectionWithAttributes:@{NSForegroundColorAttributeName:LOL_Vibe_Green_Color,
                                                           RLHighlightedBackgroundColorAttributeName:[UIColor clearColor],NSBackgroundColorAttributeName:[UIColor clearColor],RLHighlightedBackgroundCornerRadius:@5,
                                                           RLTapResponderAttributeName:hashTagTapAction}];
        
        
        
        [imgCity sd_setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:@"post_bg.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            imgCity.image = image;
            if (!image)
            {
                imgMain.image =[UIImage imageNamed:@"post_bg.png"];
            }

        }];
        
        NSString *strLocURL = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?center=%@,%@&markers=icon:|%@,%@&zoom=12&size=1024x780",
                               [dictObj valueForKey:@"post_latitude"],
                               [dictObj valueForKey:@"post_longitude"],
                               [dictObj valueForKey:@"post_latitude"],
                               [dictObj valueForKey:@"post_longitude"]];
        
        strLocURL = [strLocURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        
        [imgMain sd_setImageWithURL:[NSURL URLWithString:strLocURL] placeholderImage:[UIImage imageNamed:@"post_bg.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            imgMain.image = image;
            if (!image)
            {
                imgMain.image =[UIImage imageNamed:@"post_bg.png"];
            }

        }];
        
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
            if (!image)
            {
                imgProfile.image =[UIImage imageNamed:@"default_user_image.png"];
            }
        }];
        
        return cell;
    }
    return nil;
}
-(void)tapOnWebsite:(UITapGestureRecognizer *)sender {
    
    CGPoint location = [sender locationInView:coolectionFeed];
    NSIndexPath *indexPath = [coolectionFeed indexPathForItemAtPoint:location];
    
    NSString *strSelectedFriend = [[arrFeed objectAtIndex:indexPath.row] valueForKey:@"website"];
    
    WebBrowserVc *web = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"WebBrowserVc"];
    
    web.strURL = strSelectedFriend;
    
    [self.navigationController pushViewController:web animated:YES];
}

-(void)tapGestureProfile:(UITapGestureRecognizer *)sender
{
    CGPoint location = [sender locationInView:coolectionFeed];
    NSIndexPath *indexPath = [coolectionFeed indexPathForItemAtPoint:location];
    
    if([[[arrFeed objectAtIndex:indexPath.row] valueForKey:@"user_id"] integerValue] != [[LoggedInUser sharedUser].userId integerValue])
    {
        OtherProfileVC *web = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"OtherProfileVC"];
        
        web.dictUser = [arrFeed objectAtIndex:indexPath.row];
        
        [self.navigationController pushViewController:web animated:YES];
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return coolectionFeed.frame.size;
}

-(void)btnLike:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    NSInteger indexPath = [sender.accessibilityLabel intValue];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[[arrFeed objectAtIndex:indexPath] valueForKey:@"feed_id"] forKey:@"parent_id"];
    [dict setValue:@"post" forKey:@"like_type"];
    
    UILabel *lblLikeCount;
    int count = 0;
    UICollectionViewCell *cell = (UICollectionViewCell *) [self superviewWithClassName:@"UICollectionViewCell" fromView:sender];
    if (cell)
    {
        indexPathSelected = [coolectionFeed indexPathForCell:cell];
        
        if([[[arrFeed objectAtIndex:indexPathSelected.row] valueForKey:@"post_type"] isEqualToString:@"photo"])
        {
            lblLikeCount = (UILabel *)[cell viewWithTag:112];
        }
        else
        {
            lblLikeCount = (UILabel *)[cell viewWithTag:116];
        }
        
        count = [[[arrFeed objectAtIndex:indexPathSelected.row] valueForKey:@"like"] intValue];
    }
    
    WebService *serLikePost = [[WebService alloc] initWithView:self.view andDelegate:self];
    if(sender.selected)
    {
        count = count + 1;
        [serLikePost callWebServiceWithURLDict:LIKE_POST andHTTPMethod:@"POST" andDictData:dict withLoading:NO andWebServiceTag:@"likepost" setToken:YES];
    }
    else
    {
        count = count - 1;
        [serLikePost callWebServiceWithURLDict:UNLIKE_POST andHTTPMethod:@"POST" andDictData:dict withLoading:NO andWebServiceTag:@"likepost" setToken:YES];
    }
    
    likeInteger = indexPath;
    
    lblLikeCount.text = [NSString stringWithFormat:@"%d",count];
}
-(void)btnOption:(UIButton *)sender
{
    UICollectionViewCell *cell = (UICollectionViewCell *)[sender findSuperViewWithClass:[UICollectionViewCell class]];
    UIImageView *img = (UIImageView *)[cell viewWithTag:102];
    
    NSIndexPath *indexPath = [coolectionFeed indexPathForCell:cell];
    
    NSDictionary *dictVal = [arrFeed objectAtIndex:indexPath.row];
    OptionClass *share = [[OptionClass alloc] initWithView:self andDelegate:self];
    
    if([[dictVal valueForKey:@"user_id"] integerValue] != [[LoggedInUser sharedUser].userId integerValue])
    {
        [share otherUserPostOptionClass:dictVal Image:img.image];
    }
    else
    {
        [share selfUserPostOptionClass:dictVal Image:img.image];
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


-(void)isFriendOrNot:(UIButton *)sender
{
    //NSLog(@"%d",sender.selected);
    if(!sender.selected)
    {
        NSMutableDictionary *dictval = [[NSMutableDictionary alloc] init];
        
        dictval = [[arrFeed objectAtIndex:[sender.accessibilityLabel intValue]] mutableCopy];
        
        NSMutableDictionary *dictAddFriend = [[NSMutableDictionary alloc]init];
        [dictAddFriend setValue:[dictval valueForKey:@"user_id"] forKey:@"other_user_id"];
        
        WebService *serAddFriend = [[WebService alloc] initWithView:self.view andDelegate:self];
        [serAddFriend callWebServiceWithURLDict:SEND_REQUEST
                                  andHTTPMethod:@"POST"
                                    andDictData:dictAddFriend
                                    withLoading:NO
                               andWebServiceTag:@"addFriend"
                                       setToken:YES];
        
        
        [dictval setValue:@"1" forKey:@"is_friend"];
        
        [arrFeed replaceObjectAtIndex:[sender.accessibilityLabel intValue] withObject:dictval];
        
        //sender.selected = !sender.selected;
    }
}
-(void)btnLocationInvite:(UIButton *)sender
{
    UICollectionViewCell *cell = (UICollectionViewCell *)[sender findSuperViewWithClass:[UICollectionViewCell class]];
    
    NSIndexPath *indexPath = [coolectionFeed indexPathForCell:cell];
    
    NSString *strSelectedFriend = [[arrFeed objectAtIndex:indexPath.row] valueForKey:@"user_id"];
    
    [self performSegueWithIdentifier:@"show_places" sender:strSelectedFriend];
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

#pragma mark PrepareForSegue Method
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"show_places"])
    {
        LocationInvitePlaces *vc = [segue destinationViewController];
        vc.strUsers = sender;
    }
}

-(void)btnDirection:(UIButton *)sender
{
    UICollectionViewCell *cell = (UICollectionViewCell *)[sender findSuperViewWithClass:[UICollectionViewCell class]];
    
    NSIndexPath *indexPath = [coolectionFeed indexPathForCell:cell];
    
    destiLat = [[[arrFeed objectAtIndex:indexPath.row] valueForKey:@"post_latitude"] floatValue];
    destiLong = [[[arrFeed objectAtIndex:indexPath.row] valueForKey:@"post_longitude"] floatValue];
    
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Directions"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Apple Maps",@"Google Maps", nil];
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
    }
}
-(void)btnComment:(UIButton *)sender
{
    NSInteger indexPath = [sender.accessibilityLabel intValue];
    
    CommentController *obj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentController"];
    obj.dictPost = [arrFeed objectAtIndex:indexPath];
    obj.isInvite = NO;
    [self.navigationController pushViewController:obj animated:YES];
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


#pragma mark --Webservice Delegate Method--
-(void)webserviceCallFinishedWithSuccess:(BOOL)success andResponseObject:(id)responseObj andError:(NSError *)error forWebServiceTag:(NSString *)tagStr
{
    if(success)
    {
        NSDictionary *dictResult = (NSDictionary *)responseObj;
        //NSLog(@"%@",dictResult);
        if([tagStr isEqualToString:@"getFeed"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                arrFeed = [[NSMutableArray alloc]init];
                [arrFeed addObjectsFromArray:[dictResult valueForKey:@"post"]];
                [coolectionFeed reloadData];
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
        else if ([tagStr isEqualToString:@"likepost"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                isLike = YES;
                //[self getFeed:NO];
                [self changeLikeInFeedArray:[[dictResult valueForKey:@"like"] intValue]];
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
        else if ([tagStr isEqualToString:@"addFriend"])
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
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"This user is blocked. As of now you will not see any post of this user."];
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }

    }
}

-(void)changeLikeInFeedArray:(int)likes
{
    NSMutableArray *arrTempFeed = [[NSMutableArray alloc] init];
    [arrTempFeed addObjectsFromArray:arrFeed];
    
    NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc]init];
    dictTemp = [[arrTempFeed objectAtIndex:likeInteger] mutableCopy];
    
    [dictTemp setObject:[NSString stringWithFormat:@"%d",likes] forKey:@"like"];
    
    [arrTempFeed replaceObjectAtIndex:likeInteger withObject:dictTemp];
    
    arrFeed = arrTempFeed;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
