//
//  AppDelegate.m
//  LOL Vibe
//
//  Created by Paras Navadiya on 26/04/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "SignUp.h"
#import "ServiceConstant.h"
#import "GeneralValidation.h"

@interface SignUp ()<WebServiceDelegate>
{
    WebService  *signupWS;
    
    AppDelegate *appDel;
    
    UITextField *lastTextField;
    
    NSMutableDictionary *dictSocial;
}
@property (weak, nonatomic) UITextField *activeField;
@end

@implementation SignUp

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480) // 4s
        {
            gapConst.constant = 11.0;
        }
        else if(result.height == 568) // 5 5s
        {
            gapConst.constant = 11.0;
        }
        else if (result.height == 667) // iphone 6
        {
            gapConst.constant = 40;
        }
        else if (result.height == 736) // iphone 6+
        {
            gapConst.constant = 60;
        }
    }
    
    [GlobalMethods setPdding:txtEmail];
    [GlobalMethods setPdding:txtPassword];
    [GlobalMethods setPdding:txtVibeUsername];
    [GlobalMethods setPdding:txtZipcode];
    
    btnSignUp.layer.cornerRadius = 25;//half of the width
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
    signupWS = [[WebService alloc] initWithView:self.view andDelegate:self];
    appDel  = [[UIApplication sharedApplication] delegate];
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

-(void)pushBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLayoutSubviews
{
    [scrollVw setContentSize:CGSizeMake(contentVw.frame.size.width, contentVw.frame.size.height)];
}
- (void)onBackgroundTap:(id)sender
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)btnSignUp:(id)sender
{
    [self.activeField resignFirstResponder];
    
    if ([txtVibeUsername.text length] == 0)
    {
        [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Please enter your Vibe username."];
    }
    else if ([txtEmail.text length] == 0)
    {
        [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Please enter your Email ID."];
    }
    else if ([txtZipcode.text length] == 0)
    {
        [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Please enter your Zipcode."];
    }
    else if ([txtPassword.text length] == 0)
    {
        [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Please enter your Password."];
    }
    else
    {
        if ([GeneralValidation isValidEmailID:txtEmail.text])
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            [dict setObject:txtEmail.text forKey:@"email"];
            [dict setObject:txtPassword.text forKey:@"password"];
            [dict setObject:txtVibeUsername.text forKey:@"vibe_name"];
            [dict setObject:txtZipcode.text forKey:@"location"];
            if ([appDel.strLat length] != 0 && [appDel.strLon length] != 0)
            {
                [dict setObject:[NSString stringWithFormat:@"%@",appDel.strLat] forKey:@"latitude"];
                [dict setObject:[NSString stringWithFormat:@"%@",appDel.strLon] forKey:@"longitude"];
            }
            
            [signupWS callWebServiceWithURLDict:SIGN_UP
                                  andHTTPMethod:@"POST"
                                    andDictData:dict
                                    withLoading:YES
                               andWebServiceTag:@"signupWS"
                                       setToken:NO];
        }
        else
        {
            [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Please enter your valid Email ID."];
        }
    }
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
    if (textField == txtVibeUsername)
    {
        [txtEmail becomeFirstResponder];
    }
    else if (textField == txtEmail)
    {
        [txtZipcode becomeFirstResponder];
    }
    else if (textField == txtZipcode)
    {
        [txtPassword becomeFirstResponder];
    }
    
    else if (textField == txtPassword)
    {
        [txtPassword resignFirstResponder];
    }
    return NO;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([string isEqualToString:@" "] )
    {
        return NO;
    }
    
    return YES;
}
- (void)webserviceCallFinishedWithSuccess:(BOOL)success andResponseObject:(id)responseObj andError:(NSError *)error forWebServiceTag:(NSString *)tagStr  {
    if (success)
    {
        NSDictionary *dictResult = (NSDictionary *)responseObj;
        //NSLog(@"tempDict = %@",dictResult);
        
        if([tagStr isEqualToString:@"signupWS"])
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
                
                [loggedInUser save];
                [[XmppHelper sharedInstance] disconnect];
                [[XmppHelper sharedInstance] setUsername:[LoggedInUser sharedUser].userId andPassword:OPENFIRE_USER_PASSWORD];
                [[XmppHelper sharedInstance] connect];
                [appDel createTabbar];
            }
            else if ([[dictResult valueForKey:@"status"] integerValue]== 0)
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Invalid Email Address or Vibe Username"];
            }
        }
    }
}
@end