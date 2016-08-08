//
//  VibeUpdateVc.m
//  LOLvibe
//
//  Created by Paras Navadiya on 22/05/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "VibeUpdateVc.h"
#import "ServiceConstant.h"
#import <CoreLocation/CoreLocation.h>

#define PlaceholderText @"What's vibin'?"

@interface VibeUpdateVc ()<WebServiceDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLLocationManagerDelegate>
{
    WebService *vibePostWS;
    NSString *strPublicOrFrnd;
    NSString *strAddress;
    NSMutableDictionary *dictcurrLoc;
    
    CLLocationManager   *locationManager;
    CLGeocoder          *geocoder;
    CLPlacemark         *placemark;
    NSString            *strLon;
    NSString            *strLat;
    
    NSString            *strCityCountry;
    
    float               Longi;
    float               Latti;
    
    BOOL isLocationFeed;
    NSMutableArray *arrNearbyPlaces;
    NSDictionary *dictSelected;
}
@end

@implementation VibeUpdateVc

- (void)viewDidLoad {
    [super viewDidLoad];
    vibePostWS = [[WebService alloc]initWithView:self.view andDelegate:self];
    arrNearbyPlaces = [[NSMutableArray alloc] init];
    
    btnPublic.layer.cornerRadius = 5.0;
    btnPublic.layer.masksToBounds = YES;
    btnPublic.layer.borderWidth = 1;
    btnPublic.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    btnFriends.layer.cornerRadius = 5.0;
    btnFriends.layer.masksToBounds = YES;
    btnFriends.layer.borderWidth = 1;
    btnFriends.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    textCaption.text = PlaceholderText;
    textCaption.textColor = [UIColor lightGrayColor]; //optional
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self btnPublic:nil];
    
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
    
    if (self.isFromCameraTab)
    {
        dummyImage.image = _cameraImage;
        [btnVibePost setSelected:YES];
    }
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //    NSLog(@"didFailWithError: %@", error);
    //    UIAlertView *errorAlert = [[UIAlertView alloc]
    //                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil)
    {
        strLon = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        strLat = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        
        Latti =currentLocation.coordinate.latitude;
        Longi =currentLocation.coordinate.longitude;
        
        [locationManager stopUpdatingLocation];
        
        geocoder= [[CLGeocoder alloc]init];
        
        [geocoder reverseGeocodeLocation:newLocation
                       completionHandler:^(NSArray *placemarks, NSError *error)
         {
             if (error){
                 return;
             }
             
             placemark = [placemarks objectAtIndex:0];
             
             strAddress = [NSString stringWithFormat:@"%@, %@, %@",[placemark.addressDictionary valueForKey:@"City"],[placemark.addressDictionary valueForKey:@"State"],[placemark.addressDictionary valueForKey:@"Country"]];
             
             NSString *strURL = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?center=%@,%@&markers=icon:|%@,%@&zoom=16&size=500x500",strLat,strLon,strLat,strLon];
             
             dictcurrLoc = [[NSMutableDictionary alloc]init];
             [dictcurrLoc setValue:strURL forKey:@"icon"];
             [dictcurrLoc setValue:[[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "] forKey:@"address"];
             NSDictionary *dictLatLon = @{@"location":@{@"lat":strLat,@"lng":strLon}};
             [dictcurrLoc setValue:dictLatLon forKey:@"geometry"];
         }];
    }
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

#pragma mark- TableView Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrNearbyPlaces count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier forIndexPath:indexPath];
    
    UIImageView     *imgPlace       =(UIImageView *)[cell viewWithTag:10];
    UILabel         *lblPlace       =(UILabel *)    [cell viewWithTag:11];
    
    NSDictionary *dictObj =[arrNearbyPlaces objectAtIndex:indexPath.row];
    
    if (indexPath.row == 0)
    {
        NSString *strURL = [dictObj valueForKey:@"icon"];
        
        strURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [imgPlace sd_setImageWithURL:[NSURL URLWithString:strURL]];
        lblPlace.text = @"Current Location";
    }
    else
    {
        if ([dictObj valueForKey:@"photos"])
        {
            NSArray *arrPhotos =[dictObj valueForKey:@"photos"];
            
            NSString *strURL = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=%@&key=%@",[[arrPhotos objectAtIndex:0] valueForKey:@"photo_reference"],GOOGLE_API_KEY];
            
            strURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [imgPlace sd_setImageWithURL:[NSURL URLWithString:strURL]];
        }
        else
        {
            NSString *strURL = [dictObj valueForKey:@"icon"];
            strURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [imgPlace sd_setImageWithURL:[NSURL URLWithString:strURL]];
        }
        
        NSString *strName = [NSString stringWithFormat:@"%@\n%@",[dictObj valueForKey:@"name"],[dictObj valueForKey:@"vicinity"]];
        
        lblPlace.text = strName;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navigationController setNavigationBarHidden:NO];
    dictSelected =[arrNearbyPlaces objectAtIndex:indexPath.row];
    
    if (indexPath.row == 0)
    {
        NSString *strURL = [dictSelected valueForKey:@"icon"];
        
        strURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [dummyImage sd_setImageWithURL:[NSURL URLWithString:strURL]];
        textCaption.text = [dictSelected valueForKey:@"address"];
    }
    else
    {
        NSString *strURL = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?center=%@,%@&markers=icon:|%@,%@&zoom=12&size=1024x780",
                            [dictSelected valueForKeyPath:@"geometry.location.lat"],
                            [dictSelected valueForKeyPath:@"geometry.location.lng"],
                            [dictSelected valueForKeyPath:@"geometry.location.lat"],
                            [dictSelected valueForKeyPath:@"geometry.location.lng"]];
        
        strURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [dummyImage sd_setImageWithURL:[NSURL URLWithString:strURL]];
        
        NSString *strName = [NSString stringWithFormat:@"%@\n%@",[dictSelected valueForKey:@"name"],[dictSelected valueForKey:@"vicinity"]];
        
        textCaption.text = strName;
    }
    
    [self btnCancelNearByPlaes:nil];
    [btnVibePost setSelected:YES];
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

- (IBAction)btnFriends:(id)sender
{
    [btnFriends setBackgroundColor:LOL_Vibe_Green_Color];
    [btnPublic setBackgroundColor:[UIColor colorWithRed:232.0/255.0 green:232.0/255.0 blue:232.0/255.0 alpha:1.0]];
    strPublicOrFrnd = @"friend";
}

- (IBAction)btnPublic:(id)sender
{
    [btnPublic setBackgroundColor:LOL_Vibe_Green_Color];
    [btnFriends setBackgroundColor:[UIColor colorWithRed:232.0/255.0 green:232.0/255.0 blue:232.0/255.0 alpha:1.0]];
    strPublicOrFrnd = @"public";
}

- (IBAction)btnCancel:(id)sender
{
    [textCaption resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnVibePost:(id)sender
{
    [textCaption resignFirstResponder];
    
    if ([textCaption.text length] == 0)
    {
        [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Please enter caption."];
    }
    else
    {
        NSMutableDictionary *dictPara =[[NSMutableDictionary alloc]init];
        
        if (isLocationFeed)
        {
            [dictPara setValue:[dictSelected valueForKeyPath:@"geometry.location.lng"] forKey:@"longitude"];
            [dictPara setValue:[dictSelected valueForKeyPath:@"geometry.location.lat"] forKey:@"latitude"];
            [dictPara setValue:@"location" forKey:@"post_type"];
            [dictPara setValue:strAddress forKey:@"location_text"];
            
            [dictPara setValue:strPublicOrFrnd forKey:@"post_share"];
            
            NSString *uniText = [NSString stringWithUTF8String:[textCaption.text UTF8String]];
            NSData *msgData = [uniText dataUsingEncoding:NSNonLossyASCIIStringEncoding];
            NSString *goodMsg = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding] ;
            
            [dictPara setValue:goodMsg forKey:@"feed_text"];
            
            UIImageView *image = [[UIImageView alloc] init];
            
            if ([dictSelected valueForKey:@"photos"])
            {
                NSArray *arrPhotos =[dictSelected valueForKey:@"photos"];
                
                NSString *strURL = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=%@&key=%@",[[arrPhotos objectAtIndex:0] valueForKey:@"photo_reference"],GOOGLE_API_KEY];
                
                strURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [image sd_setImageWithURL:[NSURL URLWithString:strURL]];
            }
            else
            {
                NSString *strURL = [dictSelected valueForKey:@"icon"];
                strURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [image sd_setImageWithURL:[NSURL URLWithString:strURL]];
            }
            NSData *imgData = UIImageJPEGRepresentation(image.image,0.6);
            
            if (!imgData)
            {
                return;
            }
            
            [vibePostWS callWebServiceWithURL:CREATE_POST
                                andHTTPMethod:@"POST"
                                  andDictData:dictPara
                                        Image:imgData
                                     fileName:@"imagePost.jpg"
                                parameterName:@"image"
                                  withLoading:YES
                             andWebServiceTag:@"vibePostWS"];
        }
        else
        {
            NSData *imgData = UIImageJPEGRepresentation(dummyImage.image,0.6);
            
            if (!imgData)
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Please attach image from the Camera or Photo Gallery."];
                return;
            }
            [dictPara setValue:@"photo" forKey:@"post_type"];
            [dictPara setValue:strAddress forKey:@"location_text"];
            [dictPara setValue:strPublicOrFrnd forKey:@"post_share"];
            
            NSString *uniText = [NSString stringWithUTF8String:[textCaption.text UTF8String]];
            NSData *msgData = [uniText dataUsingEncoding:NSNonLossyASCIIStringEncoding];
            NSString *goodMsg = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding] ;
            
            [dictPara setValue:goodMsg forKey:@"feed_text"];
            
            [vibePostWS callWebServiceWithURL:CREATE_POST
                                andHTTPMethod:@"POST"
                                  andDictData:dictPara
                                        Image:imgData
                                     fileName:@"imagePost.jpg"
                                parameterName:@"image"
                                  withLoading:YES
                             andWebServiceTag:@"vibePostWS"];
        }
    }
}

- (IBAction)btnLocation:(id)sender
{
    [self.navigationController setNavigationBarHidden:YES];
    isLocationFeed = YES;
    [self.view bringSubviewToFront:viewNearByPlaces];
    [viewNearByPlaces setHidden:NO];
    [self getNearByPlaces:strLat lon:strLon];
}

- (IBAction)btnCamera:(id)sender
{
    isLocationFeed = NO;
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    [controller setAllowsEditing:YES];
    [controller setDelegate:self];
    [self presentViewController:controller animated:YES completion:NULL];
}

- (IBAction)btnPhotoGallery:(id)sender
{
    isLocationFeed = NO;
    
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [controller setAllowsEditing:YES];
    [controller setDelegate:self];
    [self presentViewController:controller animated:YES completion:NULL];
}

- (IBAction)btnCancelNearByPlaes:(id)sender
{
    [self.navigationController setNavigationBarHidden:NO];
    [self.view sendSubviewToBack:viewNearByPlaces];
    [viewNearByPlaces setHidden:YES];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:PlaceholderText]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = PlaceholderText;
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}
CGFloat _currentKeyboardHeight = 0.0f;

- (void) keyboardDidShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _currentKeyboardHeight = kbSize.height;
    
    bottomConst.constant =_currentKeyboardHeight;
    [dummyImage setHidden:YES];
    
}

- (void) keyboardWillBeHidden:(NSNotification *)notification
{
    [dummyImage setHidden:NO];
    bottomConst.constant =0.0;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    else
    {
        NSString * proposedNewString = [[textView text] stringByReplacingCharactersInRange:range withString:text];
        
        int total = (int)proposedNewString.length;
        
        int remaining =177-total;
        
        if (remaining <= 0 )
        {
            lblCaptionCount.text = @"0";
        }
        else
        {
            lblCaptionCount.text = [NSString stringWithFormat:@"%d",remaining];
        }
        return textView.text.length + (text.length - range.length) <= 176;
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    dummyImage.image = info[UIImagePickerControllerEditedImage];
    [self dismissViewControllerAnimated:YES completion:nil];
    [btnVibePost setSelected:YES];
}

#pragma mark --Webservice Delegate Method--
- (void)webserviceCallFinishedWithSuccess:(BOOL)success andResponseObject:(id)responseObj andError:(NSError *)error forWebServiceTag:(NSString *)tagStr  {
    
    if (success)
    {
        NSDictionary *dictResult = (NSDictionary *)responseObj;
        //        NSLog(@"tempDict = %@",dictResult);
        
        if ([tagStr isEqualToString:@"getNearByPlaces"])
        {
            [arrNearbyPlaces removeAllObjects];
            if (dictcurrLoc)
            {
                [arrNearbyPlaces addObject:dictcurrLoc];    
            }
            [arrNearbyPlaces addObjectsFromArray:[dictResult valueForKey:@"results"]];
            [tableNearbyPlaces reloadData];
        }
        else if ([tagStr isEqualToString:@"vibePostWS"])
        {
            if ([[dictResult valueForKey:@"status_code"] integerValue]== 1)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kRefressHomeFeed object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kRefressProfile object:nil];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else if ([[dictResult valueForKey:@"status_code"] integerValue]== 14)
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
}

@end
