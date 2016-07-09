//
//  AppDelegate.m
//  LOL Vibe
//
//  Created by Paras Navadiya on 26/04/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "AppDelegate.h"
#import "GlobalMethods.h"
#import "WebService.h"
#import "LoggedInUser.h"
#import "XmppHelper.h"
#import "UIImageView+WebCache.h"
#import "GlobalConstants.h"
#import "NKeyChain.h"
#import "Utility.h"
#import "AFNetworking.h"
#import "XmppHelper.h"
#import <CoreData/CoreData.h>
#import "UIImageView+WebCache.h"
#import "ChatConversation.h"
#import "Global.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "ResponsiveLabel.h"
#import "NSAttributedString+Processing.h"
#import "WebBrowserVc.h"



#define App_Name                        @"LOLvibe"
#define Post_Limit                      @"20"

#define GOOGLE_API_KEY                  @"AIzaSyCsWgozT4rX6EF8dWnF0nsY1USbTap_5kU"
#define APP_DELEGATE                    [[UIApplication sharedApplication] delegate]
#define LOL_Vibe_Green_Color            [UIColor colorWithRed:82.0/255.0 green:164.0/255.0 blue:56.0/255.0 alpha:1.0]
#define ServiceDomain                   @"http://lolvibe.com/index.php/lol_vibe/"

#define SIGN_UP                         (ServiceDomain @"signup")
#define FORGOT_PASSWORD                 (ServiceDomain @"forgot_password")
#define LOGIN                           (ServiceDomain @"login")
#define CHANGE_PASSWORD                 (ServiceDomain @"changepassword")
#define EDIT_PROFILE                    (ServiceDomain @"edit_profile")
#define PROFILE_SETTING                 (ServiceDomain @"profile_setting")
#define NOTIFICATION_SETTINGS           (ServiceDomain @"notification_setting")
#define DISCOVERY_SETTINGS              (ServiceDomain @"discovery_setting")
#define GET_PROFILE                     (ServiceDomain @"get_profile")
#define LOGOUT                          (ServiceDomain @"logout")
#define OTHER_LOGIN                     (ServiceDomain @"other_login")
#define CREATE_POST                     (ServiceDomain @"create_feed")
#define GET_POST                        (ServiceDomain @"get_feed")
#define GET_FRIEND_LIST                 (ServiceDomain @"friend_list")
#define GET_VISIT_MY_PROFILE            (ServiceDomain @"who_visit_my_profile")
#define LIKE_POST                       (ServiceDomain @"do_like")
#define UNLIKE_POST                     (ServiceDomain @"do_unlike")
#define VIEW_COMMENT                    (ServiceDomain @"view_comment")
#define ADD_COMMENT                     (ServiceDomain @"add_comment")
#define SEND_REQUEST                    (ServiceDomain @"friend_request_sent")
#define VISIT_OTHER_PROFILE             (ServiceDomain @"visit_other_profile")
#define GET_GROUPS                      (ServiceDomain @"get_group")
#define CREATE_GROUP                    (ServiceDomain @"create_group")
#define NOTIFICATION_LIST               (ServiceDomain @"get_notification_list")
#define INVITE_SEARCH_USER              (ServiceDomain @"invite_search_user")
#define SEND_LOCATION_INVITE            (ServiceDomain @"send_location_invite")
#define LOCATION_INVITATION_ACCEPT      (ServiceDomain @"location_invite_accept")
#define FRIEND_REQUEST_ACCEPT           (ServiceDomain @"friend_request_accept")
#define UNFRIEND                        (ServiceDomain @"unfriend")
#define GET_LOCATION_VIEW               (ServiceDomain @"get_location_invite_view")
#define GET_GROUP_INFO                  (ServiceDomain @"get_single_group")
#define GET_SINGLE_POST                 (ServiceDomain @"single_post")
#define DELETE_FEED                     (ServiceDomain @"delete_feed")
#define HASH_POST                       (ServiceDomain @"hash_post")
#define ADD_MEMBER_GROUP                (ServiceDomain @"add_user_in_group")
#define DELETE_MEMBER_GROUP             (ServiceDomain @"delete_user_from_group")
#define SEARCH_PEOPLE                   (ServiceDomain @"search")
#define TOP_POST                        (ServiceDomain @"most_liked_post")
#define TRENDING_POST                   (ServiceDomain @"most_commented_post")
#define REPORT_POST_COMMENT             (ServiceDomain @"report")
#define CHAT_NOTIFICATION               (ServiceDomain @"chat_notification")
#define GROUP_NOTIFICATION              (ServiceDomain @"group_chat_notification")
#define DELETE_COMMENT                  (ServiceDomain @"delete_comment")
#define VERIFY_USER                     (ServiceDomain @"verify_user")


#define kPref                           [NSUserDefaults standardUserDefaults]

#define kRefressProfile                 @"Refress Profile"
#define kRefressHomeFeed                @"Refress Home Feed"
#define kRecentChatArray                @"Recent Chat Array"
#define kRefressGroupList               @"Refress Group list"
#define kNewMsgRecived                  @"New Message Recived"
#define kPendingMessage                 @"Pending Message"