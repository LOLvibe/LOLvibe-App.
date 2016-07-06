//
//  DiscoveryController.m
//  LOLvibe
//
//  Created by Jaydip Godhani on 14/05/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "DiscoveryController.h"
#import "ServiceConstant.h"
#import <CoreLocation/CoreLocation.h>

@interface DiscoveryController ()<WebServiceDelegate,CLLocationManagerDelegate>
{
    UILabel             *lbl;
    NSArray             *arrGender;
    NSString            *strGender;
    NSString            *strDistance;
    CLLocationManager   *locationManager;
    CLGeocoder          *geocoder;
    CLPlacemark         *placemark;
    NSString            *SOSCurrentAddress;
    int                 resultContactCount;
    NSString            *strLon;
    NSString            *strLat;
    float               Longi;
    float               Latti;
}

@end

@implementation DiscoveryController
@synthesize dictDiscovery;

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%@",dictDiscovery);
    
    arrGender = @[@"Only Men",@"Only Women",@"Not Specified"];
    strDistance = @"0";
    lblViebeName.text = [NSString stringWithFormat:@"@%@",[LoggedInUser sharedUser].userVibeName];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
   
        NSUInteger code = [CLLocationManager authorizationStatus];
        if (code == kCLAuthorizationStatusNotDetermined && ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]))
        {
            // choose one request according to your business.
            if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]){
                [locationManager requestAlwaysAuthorization];
            } else if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
                [locationManager  requestWhenInUseAuthorization];
            } else {
                NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
            }
        }
    
    [locationManager startUpdatingLocation];
    
    UIButton *btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSave.frame = CGRectMake(0, 0, 35,35);
    [btnSave setTitle:@"Save" forState:UIControlStateNormal];
    [btnSave setTitleColor:[UIColor colorWithRed:80.0/255.0 green:164.0/255.0 blue:52.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    btnSave.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [btnSave addTarget:self action:@selector(buttonSave:) forControlEvents:UIControlEventTouchUpInside];
    [btnSave setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnSave];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
    
    
    self.title = @"Discovery Setting";
    
    [self configureLabelSlider];
    
    [self setDefualtValue];
}

-(void)setDefualtValue
{
    
    if ([[dictDiscovery valueForKey:@"age_setting"] rangeOfString:@","].location == NSNotFound)
    {
        lowerAge.text = @"18";
        uperAge.text = @"55";
        
        self.labelSlider.lowerValue = 0;
        self.labelSlider.upperValue = 55;
    }
    else
    {
        NSArray *arrAgesetting = [[dictDiscovery valueForKey:@"age_setting"] componentsSeparatedByString:@","];
        
        if(arrAgesetting.count > 0)
        {
            lowerAge.text = [arrAgesetting objectAtIndex:0];
            uperAge.text = [arrAgesetting objectAtIndex:1];
        }
        
        self.labelSlider.lowerValue = [[arrAgesetting objectAtIndex:0] intValue];
        self.labelSlider.upperValue = [[arrAgesetting objectAtIndex:1] intValue];
    }
    
    NSString *strLocation = [dictDiscovery valueForKey:@"location_setting"];
    if(strLocation.length > 0)
    {
        lblDistance.text = [NSString stringWithFormat:@"%@",strLocation];
        slideDistance.value = strLocation.floatValue;
        strDistance = strLocation;
    }
    else
    {
        lblDistance.text = @"0";
    }
    lblDistance.text = strLocation;
    
    if([[dictDiscovery valueForKey:@"gender_setting"] isEqualToString:@"0"])
    {
        [btnGender setTitle:@"Only Men" forState:UIControlStateNormal];
        strGender = @"0";
    }
    else if ([[dictDiscovery valueForKey:@"gender_setting"] isEqualToString:@"1"])
    {
        [btnGender setTitle:@"Only Women" forState:UIControlStateNormal];
        strGender = @"1";
    }
    else
    {
        [btnGender setTitle:@"Not Specified" forState:UIControlStateNormal];
        strGender = @"2";
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
    NSLog(@"didUpdateToLocation: %@", newLocation);
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
                 NSLog(@"Geocode failed with error: %@", error);
                 return;
             }
            
             placemark = [placemarks objectAtIndex:0];
         
             lblLocationName.text = [NSString stringWithFormat:@"%@,%@",[placemark.addressDictionary valueForKey:@"City"],[placemark.addressDictionary valueForKey:@"CountryCode"]];
         }];
    }
}

-(void)getGoogleAdrressFromLatLong : (NSString *)lat lon:(NSString *)lon
{
    NSString *str = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&sensor=true",lat,lon];
    
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *result = [str stringByAddingPercentEncodingWithAllowedCharacters:set];
    WebService *getAddress = [[WebService alloc]initWithView:self.view andDelegate:self];

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [getAddress callWebServiceWithURLDict:result
                            andHTTPMethod:@"POST"
                              andDictData:dict
                              withLoading:YES
                         andWebServiceTag:@"getAddress"
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

#pragma mark - Label  Slider
- (void) configureLabelSlider
{
    self.labelSlider.trackImage = [UIImage imageNamed:@"slider-default7-track"];
    self.labelSlider.minimumValue = 0;
    self.labelSlider.maximumValue = 55;

    
    self.labelSlider.lowerValue = 0;
    self.labelSlider.upperValue = 55;
    
    self.labelSlider.minimumRange =0;
}

- (void) updateSliderLabels
{
    CGPoint lowerCenter;
    lowerCenter.x = (self.labelSlider.lowerCenter.x + self.labelSlider.frame.origin.x);
    lowerCenter.y = (self.labelSlider.center.y - 30.0f);
    
    lowerAge.text = [NSString stringWithFormat:@"%d", (int)self.labelSlider.lowerValue];
    
    CGPoint upperCenter;
    upperCenter.x = (self.labelSlider.upperCenter.x + self.labelSlider.frame.origin.x);
    upperCenter.y = (self.labelSlider.center.y - 30.0f);
    
    uperAge.text = [NSString stringWithFormat:@"%d", (int)self.labelSlider.upperValue];
}

// Handle control value changed events just like a normal slider
- (IBAction)labelSliderChanged:(NMRangeSlider*)sender
{
    [self updateSliderLabels];
}

#pragma mark --Picker Delegate Method--
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return arrGender.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [arrGender objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    strGender = [NSString stringWithFormat:@"%@",[arrGender objectAtIndex:row]];
    [btnGender setTitle:[NSString stringWithFormat:@"%@",[arrGender objectAtIndex:row]] forState:UIControlStateNormal];
}

-(void)showPicker
{
    [viewPicker setHidden:NO];
    [self.view bringSubviewToFront:viewPicker];
}
-(void)hidePicker
{
    [viewPicker setHidden:YES];
    [self.view sendSubviewToBack:viewPicker];
}

#pragma mark --Get New Location--
- (IBAction)btnGetLocation:(UIButton *)sender
{
    [locationManager startUpdatingLocation];
}


#pragma mark --Webservice Delegate Method--
- (void)webserviceCallFinishedWithSuccess:(BOOL)success andResponseObject:(id)responseObj andError:(NSError *)error forWebServiceTag:(NSString *)tagStr  {
    
    if (success)
    {
        NSDictionary *dictResult = (NSDictionary *)responseObj;
        NSLog(@"tempDict = %@",dictResult);
        
        if ([tagStr isEqualToString:@"getAddress"])
        {
            NSArray *results = [dictResult valueForKey:@"results"];
            if ([results count]> 0)
            {
                SOSCurrentAddress = [[results objectAtIndex:0] valueForKey:@"formatted_address"];
                NSLog(@"%@",SOSCurrentAddress);
            }
        }
        else if ([tagStr isEqualToString:@"discovery"])
        {
            if ([[dictResult valueForKey:@"status_code"] integerValue]== 1)
            {
                [self pushBackButton:nil];
            }
            else if ([[dictResult valueForKey:@"status"] integerValue]== 0)
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
    }
}


#pragma mark --Save Button--
-(void)buttonSave:(UIButton *)sender
{
    NSString *strAge = [NSString stringWithFormat:@"%@,%@",lowerAge.text,uperAge.text];

    WebService *serDiscoverySetting = [[WebService alloc]initWithView:self.view andDelegate:self];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:strDistance forKey:@"location_setting"];
    [dict setValue:strAge forKey:@"age_setting"];
    [dict setValue:strGender forKey:@"gender_setting"];
    
    [serDiscoverySetting callWebServiceWithURLDict:DISCOVERY_SETTINGS
                            andHTTPMethod:@"POST"
                              andDictData:dict
                              withLoading:YES
                         andWebServiceTag:@"discovery"
                                 setToken:YES];
}

-(void)pushBackButton:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)btnShowMeinSearch:(UIButton *)sender
{
    
}

- (IBAction)btnChooseGender:(UIButton *)sender
{
    [self showPicker];
}


- (IBAction)cancelPicker:(UIBarButtonItem *)sender
{
    [self hidePicker];
}

- (IBAction)sliderDistance:(UISlider *)sender
{
    if ((int)round(sender.value) < 1)
    {
        lblDistance.text = @"0";
        strDistance = @"0";
    }
   else
   {
       lblDistance.text = [NSString stringWithFormat:@"%.0d",(int)round(sender.value)];
       strDistance = [NSString stringWithFormat:@"%.0d",(int)round(sender.value)];
   }
}


- (IBAction)donePicker:(UIBarButtonItem *)sender
{
    [self hidePicker];
    if([strGender isEqualToString:@"Only Men"])
    {
        strGender = @"0";
    }
    else if ([strGender isEqualToString:@"Only Women"])
    {
        strGender = @"1";
    }
    else
    {
        strGender = @"2";
    }
}
@end
