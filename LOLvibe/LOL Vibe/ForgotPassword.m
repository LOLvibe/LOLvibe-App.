//
//  AppDelegate.m
//  LOL Vibe
//
//  Created by Paras Navadiya on 26/04/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "ForgotPassword.h"
#import "ServiceConstant.h"

@interface ForgotPassword ()<WebServiceDelegate>
{
    AppDelegate *appDel;
    WebService  *forgotPassWS;
}
@end

@implementation ForgotPassword

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [GlobalMethods setPdding:txtEmail];  
    btnSend.layer.cornerRadius = 25;//half of the width
    forgotPassWS    = [[WebService alloc] initWithView:self.view andDelegate:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)pushBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)btnSend:(id)sender
{
    if ([txtEmail.text length] == 0)
    {
        [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Please enter your registered email address"];
    }
    else
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:txtEmail.text forKey:@"email"];
        
        [forgotPassWS callWebServiceWithURLDict:FORGOT_PASSWORD
                             andHTTPMethod:@"POST"
                               andDictData:dict
                               withLoading:YES
                          andWebServiceTag:@"forgotPassWS"
                                  setToken:NO];
        
    }
    [txtEmail resignFirstResponder];
}

#pragma mark - Textfield Delegete Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)webserviceCallFinishedWithSuccess:(BOOL)success andResponseObject:(id)responseObj andError:(NSError *)error forWebServiceTag:(NSString *)tagStr 
{
    if (success)
    {
        NSDictionary *dictResult = (NSDictionary *)responseObj;
        NSLog(@"tempDict = %@",dictResult);
        if([tagStr isEqualToString:@"forgotPassWS"])
        {
            if ([[dictResult valueForKey:@"status_code"] integerValue]== 1)
            {
                txtEmail.text = @"";
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                txtEmail.text = @"";
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"message"]];
            }
        }
    }
}
@end
