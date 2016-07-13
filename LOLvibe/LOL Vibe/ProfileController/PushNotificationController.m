//
//  PushNotificationController.m
//  LOLvibe
//
//  Created by Jaydip Godhani on 14/05/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "PushNotificationController.h"
#import "ServiceConstant.h"

@interface PushNotificationController ()<WebServiceDelegate>
{
    UILabel  *lbl;
    WebService *serUpdateSetting;
}

@end

@implementation PushNotificationController
@synthesize dictPushSetting;

- (void)viewDidLoad
{
    [super viewDidLoad];
    serUpdateSetting = [[WebService alloc]initWithView:self.view andDelegate:self];
    UIButton *btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSave.frame = CGRectMake(0, 0, 35,35);
    [btnSave setTitle:@"Save" forState:UIControlStateNormal];
    [btnSave setTitleColor:[UIColor colorWithRed:80.0/255.0 green:164.0/255.0 blue:52.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    btnSave.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [btnSave addTarget:self action:@selector(buttonSave:) forControlEvents:UIControlEventTouchUpInside];
    [btnSave setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnSave];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
    
    self.title = @"Push Notification";

    [self setDefualtSetting];
    //NSLog(@"%@",dictPushSetting);
}

-(void)setDefualtSetting
{
    if([[dictPushSetting valueForKey:@"chat_noty"]intValue] == 0)
    {
        [swChat setOn:NO animated:YES];
    }
    
    if([[dictPushSetting valueForKey:@"comment_my_post_noty"]intValue] == 0)
    {
        [swComment setOn:NO animated:YES];
    }
    
    if([[dictPushSetting valueForKey:@"contact_join_noty"]intValue] == 0)
    {
        [swContact setOn:NO animated:YES];
    }
    
    if([[dictPushSetting valueForKey:@"like_my_post_noty"]intValue] == 0)
    {
        [swLike setOn:NO animated:YES];
    }
    
    if([[dictPushSetting valueForKey:@"receive_invite_noty"]intValue] == 0)
    {
        [swReceiveInvite setOn:NO animated:YES];
    }
    
    if([[dictPushSetting valueForKey:@"respond_your_invite_noty"]intValue] == 0)
    {
        [swRespondInvite setOn:NO animated:YES];
    }
    
    if([[dictPushSetting valueForKey:@"sent_you_friend_request_noty"]intValue] == 0)
    {
        [swRequest setOn:NO animated:YES];
    }
    
    if([[dictPushSetting valueForKey:@"tagged_in_post_noty"]intValue] == 0)
    {
        [swTaged setOn:NO animated:YES];
    }
    
    if([[dictPushSetting valueForKey:@"trading_area_noty"]intValue] == 0)
    {
        [swTradeArea setOn:NO animated:YES];
    }
}

#pragma mark --Webservice Delegaet Method--
-(void)webserviceCallFinishedWithSuccess:(BOOL)success andResponseObject:(id)responseObj andError:(NSError *)error forWebServiceTag:(NSString *)tagStr 
{
    if(success)
    {
        NSDictionary *dictResult = (NSDictionary *)responseObj;
        //NSLog(@"tempDict = %@",dictResult);
        if([tagStr isEqualToString:@"notification"])
        {
            if([[dictResult valueForKey:@"status_code"] intValue] == 1)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kRefressProfile object:nil];
                [self pushBackButton:nil];
            }
            else
            {
                [GlobalMethods displayAlertWithTitle:App_Name andMessage:[dictResult valueForKey:@"msg"]];
            }
        }
    }
}



#pragma mark --Save Button--
-(void)buttonSave:(UIButton *)sender
{
    NSMutableDictionary *dictPara =[[NSMutableDictionary alloc]init];
    
    [dictPara setValue:[NSNumber numberWithBool:swLike.on] forKey:@"like_my_post_noty"];
    [dictPara setValue:[NSNumber numberWithBool:swComment.on] forKey:@"comment_my_post_noty"];

    [dictPara setValue:[NSNumber numberWithBool:swTaged.on] forKey:@"tagged_in_post_noty"];

    [dictPara setValue:[NSNumber numberWithBool:swContact.on] forKey:@"contact_join_noty"];

    [dictPara setValue:[NSNumber numberWithBool:swReceiveInvite.on] forKey:@"receive_invite_noty"];

    [dictPara setValue:[NSNumber numberWithBool:swRespondInvite.on] forKey:@"respond_your_invite_noty"];

    [dictPara setValue:[NSNumber numberWithBool:swRequest.on] forKey:@"sent_you_friend_request_noty"];

    [dictPara setValue:[NSNumber numberWithBool:swTradeArea.on] forKey:@"trading_area_noty"];
    [dictPara setValue:[NSNumber numberWithBool:swChat.on] forKey:@"chat_noty"];
    
    
    [serUpdateSetting callWebServiceWithURLDict:NOTIFICATION_SETTINGS
                                  andHTTPMethod:@"POST"
                                    andDictData:dictPara
                                    withLoading:YES
                               andWebServiceTag:@"notification"
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



@end
