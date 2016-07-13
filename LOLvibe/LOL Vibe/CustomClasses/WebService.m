//
//  WebService.m
//  Panelitx
//
//  Created by Paras Navadiya on 22/09/15.
//  Copyright (c) 2015 Panelitx. All rights reserved.
//

#import "WebService.h"
#import "ServiceConstant.h"


@implementation WebService
@synthesize delegate;

-(id)initWithView:(UIView *)view andDelegate:(id <WebServiceDelegate>)del
{
    self = [super init];
    
    if(self)
    {
        view_Process = view;
        self.delegate = del;
    }
    return self;
}
-(void)showLoader
{
    mbProcess=[MBProgressHUD showHUDAddedTo:view_Process animated:YES];
    mbProcess.labelText = @"Please Wait";
    [mbProcess setDelegate:self];
    [mbProcess show:YES];
}
-(void)hideLoader
{
    [mbProcess hide:YES];
}
-(void)callSimpleWebServiceWithURLDict:(NSString *)url
                         andHTTPMethod:(NSString *)method
                           andDictData:(NSDictionary *)dictParameters
                           withLoading:(BOOL)loading
                      andWebServiceTag:(NSString *)tagStr
                              setToken:(BOOL)isSetToken
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable)
    {
        [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"No Internet Connection"];
        return;
    }

    if (loading)
    {
        [self showLoader];
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:url parameters:dictParameters progress:nil success:^(NSURLSessionTask *task, id responseObject)
    {
        
        if (loading)
        {
            [self hideLoader];
        }
        
        [self.delegate webserviceCallFinishedWithSuccess:YES
                                       andResponseObject:responseObject
                                                andError:nil
                                        forWebServiceTag:tagStr];
        
    }
    failure:^(NSURLSessionTask *operation, NSError *error)
     {
         if (loading)
         {
             [self hideLoader];
         }
         
         [self.delegate webserviceCallFinishedWithSuccess:NO andResponseObject:nil andError:nil forWebServiceTag:tagStr];
         
         if ([[error description] rangeOfString:@"The request timed out."].location != NSNotFound)
         {
             [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"The request timed out, please verify your internet connection and try again."];
         }
         else if ([[error description] rangeOfString:@"The server can not find the requested page"].location != NSNotFound || [[error description] rangeOfString:@"A server with the specified hostname could not be found."].location != NSNotFound)
         {
             [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Unable to reach to the server,please try again after few minutes"];
         }
         else if([[error description] rangeOfString:@"The network connection was lost."].location != NSNotFound)
         {
             [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"The network connection was lost, please try again."];
         }
         else if([[error description] rangeOfString:@"The Internet connection appears to be offline."].location != NSNotFound)
         {
             [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"The Internet connection appears to be offline."];
         }
         else if([[error description] rangeOfString:@"JSON text did not start with array or object and option to allow fragments not set."].location != NSNotFound)
         {
             [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Server error!"];
         }
         else
         {
             [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Unable to connect, please try again!"];
         }
     }];
}

-(void)callWebServiceWithURLDict:(NSString *)url
                   andHTTPMethod:(NSString *)method
                     andDictData:(NSDictionary *)dictParameters
                     withLoading:(BOOL)loading
                andWebServiceTag:(NSString *)tagStr
                        setToken:(BOOL)isSetToken
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable)
    {
        [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"No Internet Connection"];
        return;
    }
    
    if (loading)
    {
        [self showLoader];
    }
    
    if (isSetToken)
    {
        [dictParameters setValue:[LoggedInUser sharedUser].userId forKey:@"user_id"];
        [dictParameters setValue:[LoggedInUser sharedUser].userAuthToken forKey:@"login_token"];
    }
    
    [dictParameters setValue:@"ios" forKey:@"device_type"];
    [dictParameters setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"device_id"] forKey:@"device_id"];
    [dictParameters setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"device_token"] forKey:@"device_token"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:url parameters:dictParameters progress:nil success:^(NSURLSessionTask *task, id responseObject)
     {
         if (loading)
         {
             [self hideLoader];
         }
         if ([[responseObject valueForKey:@"status_code"] integerValue]== 7)
         {
             [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Your sassion has expired.\nPlease login again."];

             AppDelegate *appDel = APP_DELEGATE;
             [[XmppHelper sharedInstance] disconnect];
             [kPref removeObjectForKey:kRecentChatArray];
             [kPref setObject:nil forKey:kRecentChatArray];
             
             [appDel setLoginView];
             
             return;
         }
         [self.delegate webserviceCallFinishedWithSuccess:YES
                                        andResponseObject:responseObject
                                                 andError:nil
                                         forWebServiceTag:tagStr];
         
     }
          failure:^(NSURLSessionTask *operation, NSError *error)
     {
         if (loading)
         {
             [self hideLoader];
         }
         
         [self.delegate webserviceCallFinishedWithSuccess:NO andResponseObject:nil andError:nil forWebServiceTag:tagStr];
         
         if ([[error description] rangeOfString:@"The request timed out."].location != NSNotFound)
         {
             [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"The request timed out, please verify your internet connection and try again."];
         }
         else if ([[error description] rangeOfString:@"The server can not find the requested page"].location != NSNotFound || [[error description] rangeOfString:@"A server with the specified hostname could not be found."].location != NSNotFound)
         {
             [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Unable to reach to the server,please try again after few minutes"];
         }
         else if([[error description] rangeOfString:@"The network connection was lost."].location != NSNotFound)
         {
             [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"The network connection was lost, please try again."];
         }
         else if([[error description] rangeOfString:@"The Internet connection appears to be offline."].location != NSNotFound)
         {
             [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"The Internet connection appears to be offline."];
         }
         else if([[error description] rangeOfString:@"JSON text did not start with array or object and option to allow fragments not set."].location != NSNotFound)
         {
             [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Server error!"];
         }
         else
         {
             [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Unable to connect, please try again!"];
         }
     }];
}


-(void)callWebServiceWithURL:(NSString *)url
               andHTTPMethod:(NSString *)method
                 andDictData:(NSDictionary *)strParameters
                       Image:(NSData *)imgData
                    fileName:(NSString *)strFileName
               parameterName:(NSString *)strParameterName
                 withLoading:(BOOL)loading
            andWebServiceTag:(NSString *)tagStr
{
    if (loading)
    {
        [self showLoader];
    }
    
    [strParameters setValue:[LoggedInUser sharedUser].userId forKey:@"user_id"];
    [strParameters setValue:@"ios" forKey:@"device_type"];
    [strParameters setValue:[kPref objectForKey:@"device_id"] forKey:@"device_id"];
    [strParameters setValue:[kPref objectForKey:@"device_token"] forKey:@"device_token"];
    [strParameters setValue:[LoggedInUser sharedUser].userAuthToken forKey:@"login_token"];
    
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer]multipartFormRequestWithMethod:@"POST" URLString:url parameters:strParameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:method];
        
        [formData appendPartWithFileData:imgData name:strParameterName fileName:strFileName mimeType:@"image/jpeg"];
        
    } error:nil];
    
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress)
                  {
                      if (loading)
                      {
                          [self hideLoader];
                      }
                      
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error)
                  {
                      if (loading)
                      {
                          [self hideLoader];
                      }
                      
                      if ([[responseObject valueForKey:@"status_code"] integerValue]== 7)
                      {
                          [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Your sassion is expire. Please login again."];
                          AppDelegate *appDel = APP_DELEGATE;
                          
                          [[XmppHelper sharedInstance] disconnect];
                          [kPref removeObjectForKey:kRecentChatArray];
                          [kPref setObject:nil forKey:kRecentChatArray];
                          
                          [ appDel setLoginView];
                          return ;
                      }
                      
                      if(error == nil)
                      {
                          [self.delegate webserviceCallFinishedWithSuccess:YES andResponseObject:responseObject andError:nil forWebServiceTag:tagStr];
                      }
                      else
                      {
                          [self.delegate webserviceCallFinishedWithSuccess:NO andResponseObject:nil andError:nil forWebServiceTag:tagStr ];
                          
                          if ([[error description] rangeOfString:@"The request timed out."].location != NSNotFound)
                          {
                              [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"The request timed out, please verify your internet connection and try again."];
                          }
                          else if ([[error description] rangeOfString:@"The server can not find the requested page"].location != NSNotFound || [[error description] rangeOfString:@"A server with the specified hostname could not be found."].location != NSNotFound)
                          {
                              [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Unable to reach to the server,please try again after few minutes"];
                          }
                          else if([[error description] rangeOfString:@"The network connection was lost."].location != NSNotFound)
                          {
                              [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"The network connection was lost, please try again."];
                          }
                          else if([[error description] rangeOfString:@"The Internet connection appears to be offline."].location != NSNotFound)
                          {
                              [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"The Internet connection appears to be offline."];
                          }
                          else if([[error description] rangeOfString:@"JSON text did not start with array or object and option to allow fragments not set."].location != NSNotFound)
                          {
                              [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Server error!"];
                          }
                          else
                          {
                              [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Unable to connect, please try again!"];
                          }
                      }
                  }];
    
    [uploadTask resume];
    
}


@end
