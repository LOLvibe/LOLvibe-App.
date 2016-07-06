//
//  PushNotificationController.h
//  LOLvibe
//
//  Created by Jaydip Godhani on 14/05/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PushNotificationController : UIViewController
{
    
    __weak IBOutlet UISwitch *swChat;
    __weak IBOutlet UISwitch *swTradeArea;
    __weak IBOutlet UISwitch *swRequest;
    __weak IBOutlet UISwitch *swRespondInvite;
    __weak IBOutlet UISwitch *swReceiveInvite;
    __weak IBOutlet UISwitch *swComment;
    __weak IBOutlet UISwitch *swLike;
    __weak IBOutlet UISwitch *swTaged;
    __weak IBOutlet UISwitch *swContact;
}

@property (strong, nonatomic) NSDictionary *dictPushSetting;

@end
