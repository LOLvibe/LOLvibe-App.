//
//  LocationInvitePlaces.m
//  LOLvibe
//
//  Created by Paras Navadiya on 15/06/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "LocationInvitePlaces.h"
#import "ServiceConstant.h"
#import "UIView+SuperView.h"
#import "MWPhotoBrowser.h"

@interface LocationInvitePlaces ()<UITableViewDelegate,UITableViewDataSource,WebServiceDelegate,CLLocationManagerDelegate,MWPhotoBrowserDelegate>
{
    WebService          *serFriendList;
    WebService          *vibePostWS;
    
    NSMutableArray      *arrSelecetedVal;
    
    NSString            *strPublicOrFrnd;
    NSString            *strAddress;
    
    CLLocationManager   *locationManager;
    CLGeocoder          *geocoder;
    CLPlacemark         *placemark;
    
    NSString            *strLon;
    NSString            *strLat;
    NSString            *strCityCountry;
    
    float               Longi;
    float               Latti;
    
    BOOL isLocationFeed,isPageRefreshing;
    
    NSMutableArray *arrNearbyPlaces;
    
    BOOL isSearching,isCurrLocation;
    
    NSString *strCurrentImageURL;
    
    NSMutableDictionary *dictSelected;
}

@property (weak, nonatomic) UITextField *activeField;

@end

@implementation LocationInvitePlaces

- (void)viewDidLoad {
    [super viewDidLoad];

    arrSelecetedVal=[[NSMutableArray alloc]init];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    vibePostWS = [[WebService alloc]initWithView:self.view andDelegate:self];
    arrNearbyPlaces = [[NSMutableArray alloc] init];
    
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
    
    imgRoundCurrLocation.layer.cornerRadius = 10;
    imgRoundCurrLocation.layer.masksToBounds = YES;
    [imgRoundCurrLocation setBackgroundColor:[UIColor whiteColor]];
    imgRoundCurrLocation.layer.borderWidth = 1;
    imgRoundCurrLocation.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [imgRoundCurrLocation setBackgroundColor:[UIColor whiteColor]];
    
    isCurrLocation = NO;
    
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
//    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil)
    {
        strLon = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        strLat = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        
        Latti =currentLocation.coordinate.latitude;
        Longi =currentLocation.coordinate.longitude;
        
        [locationManager stopUpdatingLocation];
        
        [self getGoogleAdrressFromLatLong:strLat lon:strLon];
    }
}

-(void)getGoogleAdrressFromLatLong : (NSString *)lat lon:(NSString *)lon
{
    NSString *str = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&sensor=true",lat,lon];
    
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *result = [str stringByAddingPercentEncodingWithAllowedCharacters:set];
    WebService *getAddress = [[WebService alloc]initWithView:self.view andDelegate:self];
    
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [getAddress callSimpleWebServiceWithURLDict:result
                                  andHTTPMethod:@"POST"
                                    andDictData:dict
                                    withLoading:YES
                               andWebServiceTag:@"getAddress"
                                       setToken:NO];
}
-(void)getNearByPlaces: (NSString *)lat lon:(NSString *)lon
{
    NSString *str = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%@,%@&radius=1500&key=%@",lat,lon,GOOGLE_API_KEY];
    
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *result = [str stringByAddingPercentEncodingWithAllowedCharacters:set];
    WebService *getNearByPlaces = [[WebService alloc]initWithView:self.view andDelegate:self];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [getNearByPlaces callSimpleWebServiceWithURLDict:result
                                       andHTTPMethod:@"POST"
                                         andDictData:dict
                                         withLoading:YES
                                    andWebServiceTag:@"getNearByPlaces"
                                            setToken:NO];
}
-(void)getNearByPlaces : (NSString *)strInput
{
    NSString *str = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?key=%@&input=%@",GOOGLE_API_KEY,strInput];
    
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *result = [str stringByAddingPercentEncodingWithAllowedCharacters:set];
    WebService *getNearByPlaces = [[WebService alloc]initWithView:self.view andDelegate:self];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [getNearByPlaces callSimpleWebServiceWithURLDict:result
                                       andHTTPMethod:@"POST"
                                         andDictData:dict
                                         withLoading:YES
                                    andWebServiceTag:@"search"
                                            setToken:NO];
}

-(void)getPlaceDetails: (NSString *)strInput
{
    NSString *str = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=%@",strInput,GOOGLE_API_KEY];
    
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *result = [str stringByAddingPercentEncodingWithAllowedCharacters:set];
    WebService *getNearByPlaces = [[WebService alloc]initWithView:self.view andDelegate:self];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [getNearByPlaces callSimpleWebServiceWithURLDict:result
                                       andHTTPMethod:@"POST"
                                         andDictData:dict
                                         withLoading:YES
                                    andWebServiceTag:@"placeImage"
                                            setToken:NO];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnDone:(id)sender
{
    [self.activeField resignFirstResponder];
    
    
    if (isCurrLocation)
    {
        if ([txtCaption.text length] == 0)
        {
            [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Please Add a message to complete your invite :)"];
        }
        else
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setValue:self.strUsers forKey:@"other_user_ids"];
            
            NSString *uniText = [NSString stringWithUTF8String:[txtCaption.text UTF8String]];
            NSData *msgData = [uniText dataUsingEncoding:NSNonLossyASCIIStringEncoding];
            NSString *goodMsg = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding] ;
            [dict setValue:goodMsg forKey:@"invite_text"];
            
            [dict setValue:strAddress forKey:@"location_address"];
            [dict setValue:strCurrentImageURL forKey:@"location_photo"];
            [dict setValue:[[strAddress componentsSeparatedByString:@","] objectAtIndex:0] forKey:@"location_name"];
            [dict setValue:strLat forKey:@"latitude"];
            [dict setValue:strLon forKey:@"longitude"];
            
            WebService *sendInvite = [[WebService alloc]initWithView:self.view andDelegate:self];
            
            [sendInvite callWebServiceWithURLDict:SEND_LOCATION_INVITE
                                    andHTTPMethod:@"POST"
                                      andDictData:dict
                                      withLoading:YES
                                 andWebServiceTag:@"sendInvite"
                                         setToken:YES];
        }
    }
    else
    {
        if ([txtCaption.text length] == 0)
        {
            [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Please Add a message to complete your invite :)"];
        }
        else if (![self isSelectedPlace])
        {
            [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Please select place to complete your invite :)"];
        }
        else
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setValue:self.strUsers forKey:@"other_user_ids"];

            
            NSString *uniText = [NSString stringWithUTF8String:[txtCaption.text UTF8String]];
            NSData *msgData = [uniText dataUsingEncoding:NSNonLossyASCIIStringEncoding];
            NSString *goodMsg = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding] ;
            [dict setValue:goodMsg forKey:@"invite_text"];

            if (isSearching)
            {
                NSString *strAddress1 = [dictSelected valueForKey:@"description"];
                [dict setValue:strAddress1 forKey:@"location_address"];
                NSString *strName = [[strAddress1 componentsSeparatedByString:@","] objectAtIndex:0];
                [dict setValue:strName forKey:@"location_name"];
            
                if ([[dictSelected valueForKey:@"photo_reference"] length] == 0)
                {
                    [dict setValue:strCurrentImageURL forKey:@"location_photo"];
                }
                else
                {
                    NSString *strURL = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=%@&key=%@",[dictSelected valueForKey:@"photo_reference"],GOOGLE_API_KEY];
                    
                    strURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    
                    [dict setValue:strURL forKey:@"location_photo"];
                }
            }
            else
            {
                NSString *strAddress1 = [dictSelected valueForKey:@"vicinity"];
                [dict setValue:strAddress1 forKey:@"location_address"];
                NSString *strName = [dictSelected valueForKey:@"name"];
                [dict setValue:strName forKey:@"location_name"];
            
                [dict setValue:[dictSelected valueForKey:@"image_url"] forKey:@"location_photo"];
            }
            
            NSString *strLat11 = [NSString stringWithFormat:@"%@",[dictSelected valueForKey:@"lat"]];
            NSString *strLng11 = [NSString stringWithFormat:@"%@",[dictSelected valueForKey:@"lng"]];
            
            if ([strLat11 length] == 0 && [strLng11 length] == 0 )
            {
                [dict setValue:[dictSelected valueForKeyPath:@"geometry.location.lat"] forKey:@"latitude"];
                [dict setValue:[dictSelected valueForKeyPath:@"geometry.location.lng"] forKey:@"longitude"];
            }
            else
            {
                [dict setValue:[dictSelected valueForKey:@"lat"] forKey:@"latitude"];
                [dict setValue:[dictSelected valueForKey:@"lng"] forKey:@"longitude"];
            }
            
            WebService *sendInvite = [[WebService alloc]initWithView:self.view andDelegate:self];
            
            [sendInvite callWebServiceWithURLDict:SEND_LOCATION_INVITE
                                    andHTTPMethod:@"POST"
                                      andDictData:dict
                                      withLoading:YES
                                 andWebServiceTag:@"sendInvite"
                                         setToken:YES];
        }
    }
}

- (IBAction)btnSearch:(id)sender
{
    [self.activeField resignFirstResponder];
    [self getNearByPlaces:txtSearchPlaces.text];
}

-(void)btnSelectPlace:(id)sender
{
    [self.activeField resignFirstResponder];
    
    isCurrLocation = NO;
    [imgRoundCurrLocation setBackgroundColor:[UIColor whiteColor]];
    
    UITableViewCell *cell = (UITableViewCell *)[sender findSuperViewWithClass:[UITableViewCell class]];
    NSIndexPath *indexPath = [tablePlaces indexPathForCell:cell];
    
    [self resetSelectedArray];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:@"1" forKey:@"isSelected"];
    
    [arrSelecetedVal replaceObjectAtIndex:indexPath.row withObject:dict];
    
    [tablePlaces reloadData];
    
    dictSelected = [[NSMutableDictionary alloc] initWithDictionary:[arrNearbyPlaces objectAtIndex:indexPath.row]];
    
    NSString *strPlaceID=[dictSelected valueForKey:@"place_id"];
    
    
    NSString *str = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=%@",strPlaceID,GOOGLE_API_KEY];
    
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *result = [str stringByAddingPercentEncodingWithAllowedCharacters:set];
    WebService *getNearByPlaces = [[WebService alloc]initWithView:self.view andDelegate:self];
    
    NSMutableDictionary *dict1 = [[NSMutableDictionary alloc] init];
    
    [getNearByPlaces callSimpleWebServiceWithURLDict:result
                                       andHTTPMethod:@"POST"
                                         andDictData:dict1
                                         withLoading:YES
                                    andWebServiceTag:@"testimage"
                                            setToken:NO];
}

-(void)resetSelectedArray
{
    [arrSelecetedVal removeAllObjects];
    
    for(int i = 0 ; i < [arrNearbyPlaces count]; i++)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setValue:@"0" forKey:@"isSelected"];
        
        [arrSelecetedVal addObject:dict];
    }
}

-(BOOL)isSelectedPlace
{
    for(int i = 0 ; i < [arrSelecetedVal count]; i++)
    {
        if ([[[arrSelecetedVal objectAtIndex:i] valueForKey:@"isSelected"] isEqualToString:@"1"]) {
            return YES;
        }
    }
    
    return NO;
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
    if (textField == txtSearchPlaces)
    {
        [txtCaption becomeFirstResponder];
    }
    else if (textField == txtCaption)
    {
        [txtCaption resignFirstResponder];
    }
    return NO;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == txtSearchPlaces)
    {
        NSString * proposedNewString = [[textField text] stringByReplacingCharactersInRange:range withString:string];
        
        if (proposedNewString.length > 0)
        {
            isSearching = YES;
        }
        else
        {
            isSearching = NO;
            [self getGoogleAdrressFromLatLong:strLat lon:strLon];
        }
    }
    return YES;
}

#pragma mark --Tableview Delegate Method--

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrNearbyPlaces.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"
                                                            forIndexPath:indexPath];
    
    UILabel     *lblName        = (UILabel *)[cell viewWithTag:10];
    UILabel     *lblType        = (UILabel *)[cell viewWithTag:11];
    UILabel     *lblLocation    = (UILabel *)[cell viewWithTag:12];
    UIButton    *btnInvite      = (UIButton *)[cell viewWithTag:13];
    UIImageView *imgRound       = (UIImageView *)[cell viewWithTag:14];
    
    UIImageView     *imgPlace       =(UIImageView *)[cell viewWithTag:9];
    
    
    [btnInvite addTarget:self action:@selector(btnSelectPlace:) forControlEvents:UIControlEventTouchUpInside];
    imgRound.layer.cornerRadius = 10;
    imgRound.layer.masksToBounds = YES;
    [imgRound setBackgroundColor:[UIColor whiteColor]];
    imgRound.layer.borderWidth = 1;
    imgRound.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    NSDictionary *dictObj = [arrNearbyPlaces objectAtIndex:indexPath.row];
    
    if (isSearching)
    {
        imgPlace.image =[UIImage imageNamed:@"place_default"];
        
        NSString *strLocation     = [NSString stringWithFormat:@"%@",[dictObj valueForKey:@"description"]];
        
        lblLocation.text = strLocation;
        lblName.text =[[strLocation componentsSeparatedByString:@","] objectAtIndex:0];
        
        lblType.text = [[dictObj valueForKey:@"types"] componentsJoinedByString:@", "];
        
        if ([[[arrSelecetedVal objectAtIndex:indexPath.row] valueForKey:@"isSelected"] isEqualToString:@"0"])
        {
            [imgRound setBackgroundColor:[UIColor whiteColor]];
        }
        else
        {
            [imgRound setBackgroundColor:LOL_Vibe_Green_Color];
        }
    }
    else
    {
        
        NSArray *arrPhotos =[dictObj valueForKey:@"photos"];
        
        NSString *strURL = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=%@&key=%@",[[arrPhotos objectAtIndex:0] valueForKey:@"photo_reference"],GOOGLE_API_KEY];
        
        strURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [imgPlace sd_setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:@"place_default"]];
        
        
        NSString *strLocation     = [NSString stringWithFormat:@"%@",[dictObj valueForKey:@"vicinity"]];
        NSArray *arrType      = [dictObj valueForKey:@"types"];
        
        lblLocation.text = strLocation;
        lblName.text =[dictObj valueForKey:@"name"];
        lblType.text = [arrType componentsJoinedByString:@", "];
        
        if ([[[arrSelecetedVal objectAtIndex:indexPath.row] valueForKey:@"isSelected"] isEqualToString:@"0"])
        {
            [imgRound setBackgroundColor:[UIColor whiteColor]];
        }
        else
        {
            [imgRound setBackgroundColor:LOL_Vibe_Green_Color];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *strPlaceID=[[arrNearbyPlaces objectAtIndex:indexPath.row] valueForKey:@"place_id"];
    [self getPlaceDetails:strPlaceID];
}

#pragma mark - MWPhotoBrowserDelegate
-(void)showPhotos
{
    // Create browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = NO;
    browser.displayNavArrows = YES;
    browser.displaySelectionButtons = NO;
    browser.alwaysShowControls = NO;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = NO;
    browser.startOnGrid = NO;
    browser.enableSwipeToDismiss = NO;
    [browser setCurrentPhotoIndex:0];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];
}
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(tablePlaces.contentOffset.y >= (tablePlaces.contentSize.height - tablePlaces.bounds.size.height))
    {
        //        if(isPageRefreshing==NO)
        //        {
        //            isPageRefreshing=YES;
        //
        //        }
        //  NSLog(@"page End");
    }
}
- (IBAction)btnSelectCurrLocation:(id)sender
{
    [self resetSelectedArray];
    [tablePlaces reloadData];
    
    if (isCurrLocation)
    {
        isCurrLocation = NO;
        [imgRoundCurrLocation setBackgroundColor:[UIColor whiteColor]];
    }
    else
    {
        isCurrLocation = YES;
        [imgRoundCurrLocation setBackgroundColor:LOL_Vibe_Green_Color];
    }
}

-(void)webserviceCallFinishedWithSuccess:(BOOL)success andResponseObject:(id)responseObj andError:(NSError *)error forWebServiceTag:(NSString *)tagStr
{
    if(success)
    {
        NSDictionary *dictResult = (NSDictionary *)responseObj;
        NSLog(@"%@",dictResult);
        if([tagStr isEqualToString:@"sendInvite"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"You have successfully sent your #vibeInvite :)\nTo view go to -> Notifications -> Requests/Invites"];
            }
            else if ([[dictResult valueForKey:@"status_code"] integerValue]== 14)
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
        else  if ([tagStr isEqualToString:@"getAddress"])
        {
            NSArray *results = [dictResult valueForKey:@"results"];
            if ([results count]> 0)
            {
                strAddress = [[results objectAtIndex:0] valueForKey:@"formatted_address"];
                
                strCurrentImageURL = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?center=%@,%@&markers=icon:|%@,%@&zoom=16&size=500x500",strLat,strLon,strLat,strLon];
                
                NSString *strURL = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?center=%@,%@&markers=icon:|%@,%@&zoom=16&size=500x500",strLat,strLon,strLat,strLon];
                
                strURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [imgCurrLocation sd_setImageWithURL:[NSURL URLWithString:strURL]];
                
                lblCurrLocation.text = strAddress;
                
                [self getNearByPlaces:strLat lon:strLon];
            }
        }
        else if ([tagStr isEqualToString:@"getNearByPlaces"])
        {
            [arrNearbyPlaces removeAllObjects];
            
            [arrNearbyPlaces addObjectsFromArray:[dictResult valueForKey:@"results"]];
            
            [self resetSelectedArray];
            
            [tablePlaces reloadData];
        }
        else if ([tagStr isEqualToString:@"search"])
        {
            [arrNearbyPlaces removeAllObjects];
            [arrNearbyPlaces addObjectsFromArray:[dictResult valueForKey:@"predictions"]];
            
            [self resetSelectedArray];
            
            [tablePlaces reloadData];
        }
        else if ([tagStr isEqualToString:@"placeImage"])
        {
            NSArray *arrPhotos =[dictResult valueForKeyPath:@"result.photos"];
            
            if ([arrPhotos count]>0)
            {
                self.photos = [[NSMutableArray alloc] init];
                
                for (int i = 0; i < [arrPhotos count]; i++)
                {
                    NSString *strURL = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=%@&key=%@",[[arrPhotos objectAtIndex:i] valueForKey:@"photo_reference"],GOOGLE_API_KEY];
                    
                    strURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    
                    [self.photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:strURL]]];
                }
                [self showPhotos];
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"No Photos avaliable"];
            }
        }
        else if ([tagStr isEqualToString:@"testimage"])
        {
            NSArray *arrPhotos =[dictResult valueForKeyPath:@"result.photos"];
            
            if ([arrPhotos count]>0)
            {
                NSString *strURL = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=%@&key=%@",[[arrPhotos objectAtIndex:0] valueForKey:@"photo_reference"],GOOGLE_API_KEY];
                
                strURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                [dictSelected setValue:strURL forKey:@"image_url"];
                
//                geometry =         {
//                    location =             {
//                        lat = "21.2270737";
//                        lng = "72.8426858";
//                    };
//                };
    
                [dictSelected setValue:[dictResult valueForKeyPath:@"result.geometry.location.lat"] forKey:@"lat"];
                [dictSelected setValue:[dictResult valueForKeyPath:@"result.geometry.location.lng"] forKey:@"lng"];
            }
        }
    }
}
@end