//
//  LocationInviteDetails.m
//  LOLvibe
//
//  Created by Paras Navadiya on 26/06/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "LocationInviteDetails.h"
#import <Social/Social.h>
#import "CommentController.h"
#import "InvitedFriendList.h"
#import "HashTagVC.h"
#import "OtherProfileVC.h"

@interface LocationInviteDetails ()<WebServiceDelegate,CLLocationManagerDelegate,UIActionSheetDelegate>
{
    WebService *getLocatoinDetails;
    
    AppDelegate *appDel;
    
    NSDictionary *dictObj;
    
    CLLocationManager   *locationManager;
    float   sourceLat,sourceLong;
    float   destiLat,destiLong;

}

@end

@implementation LocationInviteDetails

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"#vibeInvite";
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
    
    getLocatoinDetails = [[WebService alloc]initWithView:self.view andDelegate:self];
    
    NSString *fullString = self.strInviteTopTitle;
    
    NSString *boldString = [[self.strInviteTopTitle componentsSeparatedByString:@" "] objectAtIndex:0];
    
    NSMutableAttributedString *attributedText =[[NSMutableAttributedString alloc] initWithString:fullString];
    
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15.0]} range:[fullString rangeOfString:boldString]];
    
    lblInviteText.attributedText = attributedText;

    
    [self getInvite];
    
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
    
    UITapGestureRecognizer *tapGestureWebsite = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnWebsite:)];
    tapGestureWebsite.numberOfTapsRequired = 1;
    tapGestureWebsite.cancelsTouchesInView = YES;
    [lblWebsite addGestureRecognizer:tapGestureWebsite];
    
    UITapGestureRecognizer *tapGestureProfile = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureProfile:)];
    tapGestureProfile.numberOfTapsRequired = 1;
    tapGestureProfile.cancelsTouchesInView = YES;
    [imgProfile addGestureRecognizer:tapGestureProfile];
}


-(void)tapOnWebsite:(UITapGestureRecognizer *)sender
{
    NSString *strSelectedFriend = lblWebsite.text;
    
    WebBrowserVc *web = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"WebBrowserVc"];
    
    web.strURL = strSelectedFriend;
    
    [self.navigationController pushViewController:web animated:YES];
}

-(void)tapGestureProfile:(UITapGestureRecognizer *)sender
{
    if([[dictObj valueForKey:@"user_id"] integerValue] != [[LoggedInUser sharedUser].userId integerValue])
    {
        OtherProfileVC *obj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"OtherProfileVC"];
        obj.dictUser = dictObj;
        
        [self.navigationController pushViewController:obj animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)btnInfo:(id)sender
{
    [self performSegueWithIdentifier:@"show_friends" sender:[dictObj valueForKey:@"to_user"]];
}

#pragma mark PrepareForSegue Method
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"show_friends"])
    {
        InvitedFriendList *vc = [segue destinationViewController];
        vc.arrFrined = sender;
    }
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

- (IBAction)btnLocation:(id)sender
{
}

- (IBAction)btnOption:(id)sender
{
    
}

- (IBAction)btnComment:(id)sender
{
    CommentController *obj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentController"];
    obj.dictPost = @{@"feed_id":self.strInviteID};
    
    [self.navigationController pushViewController:obj animated:YES];
}

- (IBAction)btnLike:(id)sender
{
    UIButton *btnlike = (UIButton *)sender;
    
    btnlike.selected = !btnlike.selected;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:self.strInviteID forKey:@"parent_id"];
    [dict setValue:@"post" forKey:@"like_type"];
    
    WebService *serLikePost = [[WebService alloc] initWithView:self.view andDelegate:self];
    int count = 0;
    count = [lblLikeCount.text intValue];
    if(btnlike.selected)
    {
        count = count + 1;
        [serLikePost callWebServiceWithURLDict:LIKE_POST andHTTPMethod:@"POST" andDictData:dict withLoading:NO andWebServiceTag:@"likepost" setToken:YES];
    }
    else
    {
        count = count - 1;
        [serLikePost callWebServiceWithURLDict:UNLIKE_POST andHTTPMethod:@"POST" andDictData:dict withLoading:NO andWebServiceTag:@"likepost" setToken:YES];
    }
    lblLikeCount.text = [NSString stringWithFormat:@"%d",count];
}

-(void)getInvite
{
    NSMutableDictionary *dictAddFriend = [[NSMutableDictionary alloc]init];
    [dictAddFriend setValue:self.strInviteID forKey:@"invite_id"];
    
    [getLocatoinDetails callWebServiceWithURLDict:GET_LOCATION_VIEW
                                    andHTTPMethod:@"POST"
                                      andDictData:dictAddFriend
                                      withLoading:YES
                                 andWebServiceTag:@"getLocatoinDetails"
                                         setToken:YES];
}

-(IBAction)btnDirection:(UIButton *)sender
{
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

#pragma mark --Webservice Delegate Method--
-(void)webserviceCallFinishedWithSuccess:(BOOL)success andResponseObject:(id)responseObj andError:(NSError *)error forWebServiceTag:(NSString *)tagStr
{
    if(success)
    {
        NSDictionary *dictResult = (NSDictionary *)responseObj;
        NSLog(@"%@",dictResult);
        if([tagStr isEqualToString:@"getLocatoinDetails"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                dictObj = [dictResult valueForKey:@"data"];
                
                destiLat = [[dictObj valueForKey:@"latitude"] floatValue];
                destiLong = [[dictObj valueForKey:@"longitude"] floatValue];

                lblLikeCount.text = [NSString stringWithFormat:@"%@",[dictObj valueForKey:@"like"]];
                lblCommentCount.text = [NSString stringWithFormat:@"%@",[dictObj valueForKey:@"comment"]];
                
                const char *jsonString = [[dictObj valueForKey:@"invite_text"] UTF8String];
                NSData *jsonData = [NSData dataWithBytes:jsonString length:strlen(jsonString)];
                NSString *goodMsg = [[NSString alloc] initWithData:jsonData encoding:NSNonLossyASCIIStringEncoding];
                lblCaption.text=goodMsg;
                
                
                lblLocation.text =[dictObj valueForKey:@"address"];
                
//                NSString * returnVal;
//                NSDateFormatter * dateFromatter = [[NSDateFormatter alloc] init];
//                [dateFromatter setDateFormat:@"dd MMMM, yyyy"];
//                returnVal = [dateFromatter stringFromDate:[GlobalMethods getDateFromString:[dictObj valueForKey:@"create_at"]]];


                lblDate.text = [[[dictObj valueForKey:@"create_at"] componentsSeparatedByString:@" "] objectAtIndex:0];
                
                NSString *strURL = [dictObj valueForKey:@"photo"];
                
                strURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                
                [imgMain sd_setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:@"post_bg.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    imgMain.image = image;
                }];
                
                
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
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
    }
}
@end