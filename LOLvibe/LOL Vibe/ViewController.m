//
//  ViewController.m
//  LOL Vibe
//
//  Created by Paras Navadiya on 26/04/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "ViewController.h"
#import "ServiceConstant.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface ViewController ()<UITextFieldDelegate,WebServiceDelegate>
{
    UITextField *lastTextField;
    WebService *loginWS;

    AppDelegate *appDel;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480) // 4s
        {
            //gapConst.constant = 11.0;
            scrollview_height.constant = 100;
        }
        else if(result.height == 568) // 5 5s
        {
            gapConst.constant = 11;
            midGapConst.constant  = 4;
            topConst.constant = 0.0;
        }
        else if (result.height == 667) // iphone 6
        {
            topConst.constant = 20;
            gapConst.constant = 20;
            midGapConst.constant = 40;
        }
        else if (result.height == 736) // iphone 6+
        {
            topConst.constant = 30;
            gapConst.constant = 30;
            midGapConst.constant  = 60;
        }
    }
    
    [GlobalMethods setPdding:txtEmail];
    [GlobalMethods setPdding:txtPassword];
    
    btnLogIn.layer.cornerRadius = 25;//half of the width
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    loginWS = [[WebService alloc] initWithView:self.view andDelegate:self];
    appDel  = [[UIApplication sharedApplication] delegate];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBackgroundTap:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.cancelsTouchesInView = YES;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)onBackgroundTap:(id)sender
{
    [self.view endEditing:YES];
}

- (void) keyboardDidShow:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    kbRect = [self.view convertRect:kbRect fromView:nil];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbRect.size.height+30.0, 0.0);
    scrollVw.contentInset = contentInsets;
    scrollVw.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbRect.size.height;
    if (!CGRectContainsPoint(aRect, lastTextField.frame.origin) )
    {
        [scrollVw scrollRectToVisible:lastTextField.frame animated:YES];
    }
}

- (void) keyboardWillBeHidden:(NSNotification *)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollVw.contentInset = contentInsets;
    scrollVw.scrollIndicatorInsets = contentInsets;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)btnLogIn:(id)sender
{
    [lastTextField resignFirstResponder];
    
    if ([txtEmail.text length] == 0)
    {
        [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Please enter your registered email id."];
    }
    else if ([txtPassword.text length] == 0)
    {
        [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Please enter your password."];
    }
    else
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:txtEmail.text forKey:@"email"];
        [dict setObject:txtPassword.text forKey:@"password"];
        
        [loginWS callWebServiceWithURLDict:LOGIN
                             andHTTPMethod:@"POST"
                               andDictData:dict
                               withLoading:YES
                          andWebServiceTag:@"login"
                                  setToken:NO];
    }
}

#pragma mark --Facebook Login--
- (IBAction)btnFB:(id)sender
{
    [[NSUserDefaults standardUserDefaults]setValue:@"fb" forKey:@"social"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut];
    
    [login logInWithReadPermissions:@[@"public_profile",@"email"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error)
        {
//            NSLog(@"%@",error);
        }
        else if (result.isCancelled)
        {
            // Handle cancellations
        }
        else
        {
            if ([result.grantedPermissions containsObject:@"email"])
            {
                if ([FBSDKAccessToken currentAccessToken])
                {
                    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                                   parameters:@{@"fields": @"id,email,first_name,last_name,gender"}];
                    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result1, NSError *error)
                     {
                         if (!error)
                         {
//                             NSLog(@"fetched user:%@", result);
                             
                             NSDictionary *result = (NSDictionary *)result1;
                             
                             NSString *strUserName = [result valueForKey:@"first_name"];
                             
                             WebService *serFBLogin = [[WebService alloc]initWithView:self.view andDelegate:self];
                             
                             NSString *strProfile = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",[result valueForKey:@"id"]];
                             
                             NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                             
                             [dict setObject:[result valueForKey:@"email"] forKey:@"email"];
                             [dict setObject:strUserName forKey:@"vibe_name"];
                             [dict setObject:[result valueForKey:@"id"] forKey:@"fb_login"];
                             [dict setObject:strProfile forKey:@"profile_pic"];
                             
                             [serFBLogin callWebServiceWithURLDict:OTHER_LOGIN
                                                     andHTTPMethod:@"POST"
                                                       andDictData:dict
                                                       withLoading:YES
                                                  andWebServiceTag:@"fbLogin"
                                                          setToken:NO];
                         }
                     }];
                }
            }
        }
    }];
}

#pragma mark - Textfield Delegete Methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    lastTextField = nil;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txtEmail)
    {
        [txtPassword becomeFirstResponder];
    }
    else if (textField == txtPassword)
    {
        [txtPassword resignFirstResponder];
    }
    return NO;
}

- (void)webserviceCallFinishedWithSuccess:(BOOL)success andResponseObject:(id)responseObj andError:(NSError *)error forWebServiceTag:(NSString *)tagStr{
    
    if (success)
    {
        NSDictionary *dictResult = (NSDictionary *)responseObj;
//        NSLog(@"tempDict = %@",dictResult);
        
        if ([tagStr isEqualToString:@"login"])
        {
            if ([[dictResult valueForKey:@"status_code"] integerValue]== 1)
            {
                LoggedInUser *loggedInUser=[LoggedInUser sharedUser];
                
                loggedInUser.userAuthToken         = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.login_token"]];
                loggedInUser.userDOB               = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.birth_date"]];
                loggedInUser.userVibeName          = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.vibe_name"]];
                loggedInUser.userEmail             = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.email"]];
                loggedInUser.userId                = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.user_id"]];
                loggedInUser.userWebsite           = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.website"]];
                loggedInUser.userGender            = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.gender"]];
                loggedInUser.userPhone             = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.phone"]];
                loggedInUser.userPassword          = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.password"]];
                loggedInUser.userLocation          = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.location"]];
                loggedInUser.userProfilePic        = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.profile_pic"]];
                loggedInUser.userFullName          = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.name"]];
                loggedInUser.userZipcode           = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.location"]];
                loggedInUser.userAge               = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.age"]];
                loggedInUser.isUserLoggedIn        = YES;
                loggedInUser.userStatus            = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.status"]];
                [loggedInUser save];
                
                [[XmppHelper sharedInstance] disconnect];
                
                [[XmppHelper sharedInstance] setUsername:[LoggedInUser sharedUser].userId andPassword:OPENFIRE_USER_PASSWORD];
                
                [[XmppHelper sharedInstance] connect];
                
                [appDel createTabbar];
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
        else if ([tagStr isEqualToString:@"fbLogin"])
        {
            if ([[dictResult valueForKey:@"status_code"] integerValue]== 1)
            {
                LoggedInUser *loggedInUser=[LoggedInUser sharedUser];
                
                loggedInUser.userAuthToken         = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.login_token"]];
                loggedInUser.userDOB               = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.birth_date"]];
                loggedInUser.userVibeName          = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.vibe_name"]];
                loggedInUser.userEmail             = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.email"]];
                loggedInUser.userId                = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.user_id"]];
                
                loggedInUser.userWebsite           = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.website"]];
                loggedInUser.userGender            = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.gender"]];
                loggedInUser.userPhone             = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.phone"]];
                loggedInUser.userPassword          = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.password"]];
                loggedInUser.userLocation          = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.location"]];
                loggedInUser.userProfilePic        = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.profile_pic"]];
                loggedInUser.userFullName          = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.name"]];
                loggedInUser.userZipcode           = [NSString stringWithFormat:@"%@",[dictResult valueForKeyPath:@"data.location"]];
                loggedInUser.isUserLoggedIn        = YES;
                
                [loggedInUser save];
                
                
                [[XmppHelper sharedInstance] disconnect];
                
                [[XmppHelper sharedInstance] setUsername:[LoggedInUser sharedUser].userId andPassword:OPENFIRE_USER_PASSWORD];
                
                [[XmppHelper sharedInstance] connect];
                
                [appDel createTabbar];
                
            }
            else
            {
                 [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
    }
}
@end
