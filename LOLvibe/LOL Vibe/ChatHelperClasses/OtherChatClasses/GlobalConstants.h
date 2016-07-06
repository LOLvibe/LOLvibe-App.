//
//  GlobalConstants.h
//  nesetchat
//
//  Created by WeeTech Solution on 01/06/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#ifndef nesetchat_GlobalConstants_h
#define nesetchat_GlobalConstants_h


#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)


#define IDIOM                           UI_USER_INTERFACE_IDIOM()
#define IPHONE                          UIUserInterfaceIdiomPhone
#define IPAD                            UIUserInterfaceIdiomPad

#define IS_IPHONE                       ( IDIOM == IPHONE )
#define IS_IPAD                         ( IDIOM == IPAD )
//#define IS_HEIGHT_GTE_568               [[UIScreen mainScreen ] bounds].size.height >= 568.0f
//#define IS_IPHONE_5                     ( IS_IPHONE && IS_HEIGHT_GTE_568 )
#define IS_RETINA_DISPLAY               ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))

#define IOS_VERSION                     [[[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."] objectAtIndex:0] intValue]

#define IS_IOS5                         (IOS_VERSION >= 5 && IOS_VERSION < 6)
#define IS_IOS6                         (IOS_VERSION >= 6 && IOS_VERSION < 7)
#define IS_IOS7                         (IOS_VERSION >= 7)
#define IS_IOS8                         (IOS_VERSION >= 8)


#define APP_PRINT

#ifdef APP_PRINT
#define DLog(fmt, ...)                  NSLog((fmt), ##__VA_ARGS__)
#else
#define DLog(...)
#endif

#define CHAT_CONTENT_DIRECTORY_NAME     @"DemoChatContents"


#define XMPP_BASE_URL       @"http://132.148.16.114:9090"
#define XMPP_SERVER_NAME    @"s132-148-16-114.secureserver.net"
#define XMPP_HOST_NAME      @"132.148.16.114"
#define XMPP_GROUP_DOMAIN   @"conference.s132-148-16-114.secureserver.net"
#define XMPP_GROUP_SERVICE_NAME @""

#define OPENFIRE_ADMIN_NAME     @"admin"
#define OPENFIRE_ADMIN_PASSWORD @"Hangers123$"

#define OPENFIRE_USER_PASSWORD  @"LOLvibe@op!*ssap."

#define COMMON_ROOM_PASSWORD    (@"commonroom" @"pswd")


#endif
