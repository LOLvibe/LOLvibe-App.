//
//  ProfileViewController.m
//  LOLvibe
//
//  Created by Jaydip Godhani on 12/05/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "ProfileViewController.h"
#import "ServiceConstant.h"
#import "PushNotificationController.h"
#import "DiscoveryController.h"
#import "ProfileImageController.h"

@interface ProfileViewController ()<WebServiceDelegate>
{
    UILabel *lbl;
    WebService *serGetProfile;
    WebService *serUpdateProfile;
    NSDictionary *dictSettingProfile;
    NSArray *arrGender;
    NSString *strGender;
    BOOL isUpdateImage;
    AppDelegate *appDel;
}

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDel = APP_DELEGATE;

    serGetProfile = [[WebService alloc]initWithView:self.view andDelegate:self];
    serUpdateProfile = [[WebService alloc]initWithView:self.view andDelegate:self];
    [self setDefulatProperties];

    
    UIButton *btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSave.frame = CGRectMake(0, 0, 35,35);
    [btnSave setTitle:@"Save" forState:UIControlStateNormal];
    [btnSave setTitleColor:[UIColor colorWithRed:80.0/255.0 green:164.0/255.0 blue:52.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    btnSave.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [btnSave addTarget:self action:@selector(buttonSave:) forControlEvents:UIControlEventTouchUpInside];
    [btnSave setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnSave];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refressProfile:) name:kRefressProfile object:nil];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBackgroundTap:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.cancelsTouchesInView = YES;
    [self.view addGestureRecognizer:tapGesture];
    
    btnLogout.layer.cornerRadius = 5;//half of the width
    btnDiscovery.layer.cornerRadius = 5;//half of the width
    btnPushNotification.layer.cornerRadius = 5  ;//half of the width

    imgUserProfile.layer.cornerRadius = 5.0;
    imgUserProfile.layer.masksToBounds = YES;
    imgUserProfile.layer.borderWidth = 1;
    imgUserProfile.layer.borderColor = [UIColor lightGrayColor].CGColor;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    self.title =@"Edit Profile";
}
-(void)viewWillDisappear:(BOOL)animated
{
   [super viewDidDisappear:animated];
    self.title = @"";
}
- (void)onBackgroundTap:(id)sender
{
    [self.view endEditing:YES];
}

-(void)setDefulatProperties
{
    arrGender = @[@"Male",@"Female"];
    isUpdateImage = NO;
    txtName.text = [NSString stringWithFormat:@"%@",[LoggedInUser sharedUser].userFullName];
    txtVibeName.text = [NSString stringWithFormat:@"@%@",[LoggedInUser sharedUser].userVibeName];
    txtBirthDate.text = [NSString stringWithFormat:@"%@",[LoggedInUser sharedUser].userDOB];
    txtEmail.text = [NSString stringWithFormat:@"%@",[LoggedInUser sharedUser].userEmail];
    txtWebsite.text = [NSString stringWithFormat:@"%@",[LoggedInUser sharedUser].userWebsite];
    txtPhoneNumber.text = [NSString stringWithFormat:@"%@",[LoggedInUser sharedUser].userPhone];
    txtChangePassword.text = [NSString stringWithFormat:@"%@",[LoggedInUser sharedUser].userPassword];
    txtZipCode.text=[NSString stringWithFormat:@"%@",[LoggedInUser sharedUser].userZipcode];

    NSString *strProfile = [NSString stringWithFormat:@"%@",[LoggedInUser sharedUser].userProfilePic];
    [imgUserProfile sd_setImageWithURL:[NSURL URLWithString:strProfile] placeholderImage:[UIImage imageNamed:@"default_user_image"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        imgUserProfile.image = image;
    }];
    

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];


    [serGetProfile callWebServiceWithURLDict:GET_PROFILE
                           andHTTPMethod:@"POST"
                             andDictData:dict
                             withLoading:YES
                        andWebServiceTag:@"getProfile"
                                setToken:YES];
    
    if([[LoggedInUser sharedUser].userGender intValue] == 0)
    {
        txtGender.text = @"Male";
        strGender = @"Male";
    }
    else
    {
        txtGender.text = @"Female";
        strGender = @"Female";
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [scrEditProfile setContentSize:CGSizeMake(scrEditProfile.frame.size.width,btnLogout.frame.origin.y+btnLogout.frame.size.height+10)];
    
    [self hidePicker];
    [self hideDatePicker];
    
    UITapGestureRecognizer *tapOnImage = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOnImageView:)];
    tapOnImage.numberOfTapsRequired = 1.0;
    tapOnImage.delegate = self;
    [imgUserProfile addGestureRecognizer:tapOnImage];
}

-(void)refressProfile:(NSNotification *)notification
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    
    [serGetProfile callWebServiceWithURLDict:GET_PROFILE
                               andHTTPMethod:@"POST"
                                 andDictData:dict
                                 withLoading:YES
                            andWebServiceTag:@"getProfile"
                                    setToken:YES];

}

-(void)setUpdatedProfileView
{
    isUpdateImage = NO;
    txtName.text = [NSString stringWithFormat:@"%@",[LoggedInUser sharedUser].userFullName];
    txtVibeName.text = [NSString stringWithFormat:@"@%@",[LoggedInUser sharedUser].userVibeName];
    txtBirthDate.text = [NSString stringWithFormat:@"%@",[LoggedInUser sharedUser].userDOB];
    txtEmail.text = [NSString stringWithFormat:@"%@",[LoggedInUser sharedUser].userEmail];
    txtWebsite.text = [NSString stringWithFormat:@"%@",[LoggedInUser sharedUser].userWebsite];
    txtPhoneNumber.text = [NSString stringWithFormat:@"%@",[LoggedInUser sharedUser].userPhone];
    txtChangePassword.text = [NSString stringWithFormat:@"%@",[LoggedInUser sharedUser].userPassword];
    txtZipCode.text = [NSString stringWithFormat:@"%@",[LoggedInUser sharedUser].userLocation];
    
    NSString *strProfile = [NSString stringWithFormat:@"%@",[LoggedInUser sharedUser].userProfilePic];
    [imgUserProfile sd_setImageWithURL:[NSURL URLWithString:strProfile] placeholderImage:[UIImage imageNamed:@"default_user_image"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        imgUserProfile.image = image;
    }];
    
    if([[LoggedInUser sharedUser].userGender intValue] == 0)
    {
        txtGender.text = @"Male";
        strGender = @"Male";
    }
    else
    {
        txtGender.text = @"Female";
        strGender = @"Female";
    }
}

#pragma mark -- Open camera or  Gallery for take Photos--
-(void)tapOnImageView:(UITapGestureRecognizer *)recognizer
{
    [self pickImage];
}


#pragma mark Image Selection

-(void)pickImage
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:(id)self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles: nil];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"View Profile Photo", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Camera", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Photo Album", nil)];
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        //        [actionSheet showFromRect:btnupdateLogo.frame inView:self.view animated:YES];
    }
    else
    {
        [actionSheet showFromToolbar:self.navigationController.toolbar];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if ([buttonTitle isEqualToString:NSLocalizedString(@"Photo Album", nil)])
        {
            [self openPhotoAlbum];
        }
        else if ([buttonTitle isEqualToString:NSLocalizedString(@"Camera", nil)])
        {
            [self showCamera];
        }
        else if ([buttonTitle isEqualToString:NSLocalizedString(@"View Profile Photo", nil)])
        {
            NSDictionary *dictInfo1 = @{@"name":[LoggedInUser sharedUser].userVibeName
                                       ,@"profile_pic":[LoggedInUser sharedUser].userProfilePic};
            ProfileImageController *obj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ProfileImageController"];
            
            obj.dictinfo = dictInfo1;
            
            [self.navigationController pushViewController:obj animated:YES];
        }
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    isUpdateImage = YES;
    imgUserProfile.image = info[UIImagePickerControllerEditedImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showCamera
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    [controller setAllowsEditing:YES];
    [controller setDelegate:self];
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)openPhotoAlbum
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [controller setAllowsEditing:YES];
    [controller setDelegate:self];
    [self presentViewController:controller animated:YES completion:NULL];
}

#pragma mark --All Button And Swithc ACtion--
- (IBAction)swLocation:(UISwitch *)sender
{
    
}

- (IBAction)swWebsite:(UISwitch *)sender
{
    
}

- (IBAction)swBirthDate:(UISwitch *)sender
{
    
}

- (IBAction)btnPrivate:(UIButton *)sender
{
    sender.selected = !sender.selected;
}

- (IBAction)btnPushNotiSetting:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"push" sender:self];
}

- (IBAction)btnDiscoverySetting:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"discovery" sender:self];
}


#pragma mark --PrepareForSegue Method--
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"push"])
    {
        PushNotificationController *obj = [segue destinationViewController];
        obj.dictPushSetting = dictSettingProfile;
    }
    else if ([[segue identifier] isEqualToString:@"discovery"])
    {
        DiscoveryController *obj = [segue destinationViewController];
        obj.dictDiscovery = dictSettingProfile;
    }
}

#pragma mark --DatePicker Button Action--
- (IBAction)cancelDate:(UIBarButtonItem *)sender
{
    [self hideDatePicker];
}

- (IBAction)doneDate:(UIBarButtonItem *)sender
{
    
    NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
    [dateFormate setDateFormat:@"yyyy-MM-dd"];
    
    
    NSString *birthDate = [dateFormate stringFromDate:datePicker.date];
    NSDate *todayDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    int time = [todayDate timeIntervalSinceDate:[dateFormatter dateFromString:birthDate]];
    int allDays = (((time/60)/60)/24);
    int days = allDays%365;
    int years = (allDays-days)/365;
    
    if (years >= 18)
    {
        [self hideDatePicker];
        txtBirthDate.text = [NSString stringWithFormat:@"%@",[dateFormate stringFromDate:datePicker.date]];
    }
    else
    {
        [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"You should be 18 year old."];
    }
}

-(void)showDatePicker
{
    [viewDatePicker setHidden:NO];
    [self.view bringSubviewToFront:viewDatePicker];
}

-(void)hideDatePicker
{
    [viewDatePicker setHidden:YES];
    [self.view sendSubviewToBack:viewDatePicker];
}

#pragma mark -- Picker View Method--

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return arrGender.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [arrGender objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    strGender = [arrGender objectAtIndex:row];
    
}

- (IBAction)cancelPicker:(UIBarButtonItem *)sender
{
    [self hidePicker];
}

- (IBAction)doenPicker:(UIBarButtonItem *)sender
{
    txtGender.text = strGender;
    
    [self hidePicker];
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

- (IBAction)btnLogoutAction:(UIButton *)sender
{
    WebService *serLogout = [[WebService alloc]initWithView:self.view andDelegate:self];
   
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [serLogout callWebServiceWithURLDict:LOGOUT
                           andHTTPMethod:@"POST"
                             andDictData:dict
                             withLoading:YES
                        andWebServiceTag:@"logout"
                                setToken:YES];

}

#pragma mark --Webservice Delegate Method--
- (void)webserviceCallFinishedWithSuccess:(BOOL)success andResponseObject:(id)responseObj andError:(NSError *)error forWebServiceTag:(NSString *)tagStr  {
    
    if (success)
    {
        NSDictionary *dictResult = (NSDictionary *)responseObj;
        NSLog(@"tempDict = %@",dictResult);
        
        
        if([tagStr isEqualToString:@"getProfile"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                dictSettingProfile = [dictResult valueForKey:@"setting"];
                [self updateLoggedInUser:dictResult];
                [self setSettingInProfile];
                [self setUpdatedProfileView];
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
        else if ([tagStr isEqualToString:@"editProfile"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
        else if ([tagStr isEqualToString:@"logout"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                LoggedInUser *loggedInUser=[LoggedInUser sharedUser];
                [loggedInUser logout];
                [[XmppHelper sharedInstance] disconnect];
                [kPref removeObjectForKey:kRecentChatArray];
                [kPref setObject:nil forKey:kRecentChatArray];
                [appDel setLoginView];
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
    }
}


-(void)setSettingInProfile
{
    if([[dictSettingProfile valueForKey:@"show_birthdate"] intValue] == 1)
    {
        [swBirthDate setOn:YES animated:YES];
    }
    else
    {
        [swBirthDate setOn:NO animated:NO];
    }
    
    if([[dictSettingProfile valueForKey:@"show_location"] intValue] == 1)
    {
        [swZipCode setOn:YES animated:YES];
    }
    else
    {
        [swZipCode setOn:NO animated:NO];
    }
    
    if([[dictSettingProfile valueForKey:@"show_website"] intValue] == 1)
    {
        [swWebsite setOn:YES animated:YES];
    }
    else
    {
        [swWebsite setOn:NO animated:NO];
    }
    
    if([[dictSettingProfile valueForKey:@"account_type"] intValue] == 1)
    {
        btnPrivateAccount.selected = YES;
    }
}

-(void)updateLoggedInUser:(NSDictionary *)dictResult
{
    LoggedInUser *loggedInUser=[LoggedInUser sharedUser];
    
    loggedInUser.userDOB               = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.birth_date"]];
    loggedInUser.userVibeName          = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.vibe_name"]];
    loggedInUser.userEmail             = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.email"]];
    loggedInUser.userId                = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.user_id"]];
    loggedInUser.userStatus            = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.status"]];
    loggedInUser.userWebsite           = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.website"]];
    loggedInUser.userGender            = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.gender"]];
    loggedInUser.userPhone             = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.phone"]];
    loggedInUser.userPassword          = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.password"]];
    loggedInUser.userLocation          = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.location"]];
    loggedInUser.userProfilePic        = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.profile_pic"]];
    loggedInUser.userFullName          = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.name"]];
    loggedInUser.isUserLoggedIn        = YES;
    
    [loggedInUser save];
}

#pragma mark - Textfield Delegete Methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField == txtBirthDate)
    {
        [self.activeField resignFirstResponder];
        [self showDatePicker];
        return NO;
    }
    else if (textField == txtGender)
    {
        [self.activeField resignFirstResponder];
        [self showPicker];
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark __keyboard Hide and show--
- (void) keyboardDidShow:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    kbRect = [self.view convertRect:kbRect fromView:nil];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbRect.size.height+70.0, 0.0);
    scrEditProfile.contentInset = contentInsets;
    scrEditProfile.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbRect.size.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) )
    {
        [scrEditProfile scrollRectToVisible:self.activeField.frame animated:YES];
    }
}

- (void) keyboardWillBeHidden:(NSNotification *)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrEditProfile.contentInset = contentInsets;
    scrEditProfile.scrollIndicatorInsets = contentInsets;
    [scrEditProfile setContentSize:CGSizeMake(scrEditProfile.frame.size.width,btnDiscovery.frame.origin.y+btnDiscovery.frame.size.height+10)];
}

#pragma mark --Save Button--
-(void)buttonSave:(UIButton *)sender
{
    if(isUpdateImage)
    {
        if(txtName.text.length == 0)
        {
            [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Please enter Name."];
        }
        else if (txtVibeName.text.length == 0)
        {
            [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Please enter your Vibename."];
        }
        else if (txtChangePassword.text.length == 0)
        {
            [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Please enter your password."];
        }
        else if (txtBirthDate.text.length == 0)
        {
            [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Please enter your birth date."];
        }
        else
        {
            NSString *gender;
            if([txtGender.text isEqualToString:@"Male"])
            {
                gender = @"0";
            }
            else
            {
                gender = @"1";
            }
            
            
            NSMutableDictionary *dictPara =[[NSMutableDictionary alloc]init];
            
            [dictPara setValue:txtName.text forKey:@"name"];
            [dictPara setValue:[LoggedInUser sharedUser].userVibeName forKey:@"vibe_name"];
            [dictPara setValue:[LoggedInUser sharedUser].userEmail forKey:@"email"];

            [dictPara setValue:txtZipCode.text forKey:@"location"];
            [dictPara setValue:txtWebsite.text forKey:@"website"];
            [dictPara setValue:txtBirthDate.text forKey:@"birth_date"];
            [dictPara setValue:[NSString stringWithFormat:@"%d",btnPrivateAccount.selected] forKey:@"private_account"];
//            [dictPara setValue:txtPhoneNumber.text forKey:@"phone"];
            [dictPara setValue:gender forKey:@"gender"];
            [dictPara setValue:[NSString stringWithFormat:@"%d",swZipCode.on] forKey:@"show_location"];
            [dictPara setValue:[NSString stringWithFormat:@"%d",swWebsite.on] forKey:@"show_website"];
            [dictPara setValue:[NSString stringWithFormat:@"%d",swBirthDate.on] forKey:@"show_birthdate"];
            [dictPara setValue:txtChangePassword.text forKey:@"password"];
            
            
            NSData *imgData = UIImageJPEGRepresentation(imgUserProfile.image,0.8);
            
            [serUpdateProfile callWebServiceWithURL:EDIT_PROFILE
                                      andHTTPMethod:@"POST"
                                        andDictData:dictPara
                                              Image:imgData
                                           fileName:@"profile.jpg"
                                      parameterName:@"profile_pic"
                                        withLoading:YES
                                   andWebServiceTag:@"editProfile"];
            
        }
    }
    else
    {
        if(txtName.text.length == 0)
        {
            [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Please enter Name."];
        }
        else if (txtVibeName.text.length == 0)
        {
            [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Please enter your Vibename."];
        }
        else if (txtChangePassword.text.length == 0)
        {
            [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Please enter your password."];
        }
        else if (txtBirthDate.text.length == 0)
        {
            [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Please enter your birth date."];
        }
        else
        {
            NSString *gender;
            if([txtGender.text isEqualToString:@"Male"])
            {
                gender = @"0";
            }
            else
            {
                gender = @"1";
            }

            NSMutableDictionary *dictPara =[[NSMutableDictionary alloc]init];
            
            [dictPara setValue:txtName.text forKey:@"name"];
            [dictPara setValue:[LoggedInUser sharedUser].userEmail forKey:@"email"];
            [dictPara setValue:[LoggedInUser sharedUser].userVibeName forKey:@"vibe_name"];
            [dictPara setValue:txtZipCode.text forKey:@"location"];
            [dictPara setValue:txtWebsite.text forKey:@"website"];
            [dictPara setValue:txtBirthDate.text forKey:@"birth_date"];
            [dictPara setValue:[NSString stringWithFormat:@"%d",btnPrivateAccount.selected] forKey:@"private_account"];
//            [dictPara setValue:txtPhoneNumber.text forKey:@"phone"];
            [dictPara setValue:gender forKey:@"gender"];
            [dictPara setValue:[NSString stringWithFormat:@"%d",swZipCode.on] forKey:@"show_location"];
            [dictPara setValue:[NSString stringWithFormat:@"%d",swWebsite.on] forKey:@"show_website"];
            [dictPara setValue:[NSString stringWithFormat:@"%d",swBirthDate.on] forKey:@"show_birthdate"];
            [dictPara setValue:txtChangePassword.text forKey:@"password"];
            [dictPara setValue:[LoggedInUser sharedUser].userProfilePic forKey:@"profile_pic"];
            
            [serUpdateProfile callWebServiceWithURLDict:EDIT_PROFILE
                                   andHTTPMethod:@"POST"
                                     andDictData:dictPara
                                     withLoading:YES
                                andWebServiceTag:@"editProfile"
                                        setToken:YES];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
