//
//  XmppHelper.m
//  nesetchat
//
//  Created by WeeTech Solution on 01/06/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import "XmppHelper.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "ChatConversation.h"
#import "UserInfo.h"

#import <AudioToolbox/AudioServices.h>
#import "Global.h"
#import "ServiceConstant.h"
#import "AppDelegate.h"

#define CurrentTimeStamp [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]]


// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@implementation XmppHelper
@synthesize servername;
@synthesize hostname;
@synthesize hostport;
@synthesize username;
@synthesize jId;
@synthesize password;
@synthesize roomChatHistoryFetched;

@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
/*@synthesize xmppCapabilities;
 @synthesize xmppCapabilitiesStorage;*/
@synthesize xmppMUC;
@synthesize xmppRoomCoreDataStore;
@synthesize xmppLastActivity;

@synthesize managedObjectContext_chatMessage = __managedObjectContext_chatMessage;
@synthesize managedObjectModel_chatMessage = __managedObjectModel_chatMessage;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

@synthesize delegate;


#pragma mark - Singleton Methods
+ (XmppHelper *)sharedInstance
{
    static XmppHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark Init
- (id)init
{
    if (self = [super init])
    {
        self.presenceArray = [[NSMutableArray alloc] init];
        self.rooms = [[NSMutableDictionary alloc] init];
        invitionsDict = [[NSMutableDictionary alloc] init];
        global = [Global sharedInstance];
        progessLoading = [[MBProgressHUD alloc] initWithView:[AppDelegate sharedDelegate].window];
        progessLoading.removeFromSuperViewOnHide = YES;
        
        //[self setupStream];
        //self.username = @"admin";
        self.groupChatDomainStr=@"conference.192.169.197.62";
    }
    return self;
}

#pragma mark - Set username and password
- (void)setUsername:(NSString *)name andPassword:(NSString *)pass
{
    self.username = [name lowercaseString];
    self.jId = [name lowercaseString];
    self.password = pass;
}

#pragma mark Add user to roster
-(void)addUserToRosterForUser:(NSString *)frndUsername
{
    [xmppRoster addUser:[XMPPJID jidWithString:[self getActualUsernameForUser:frndUsername]] withNickname:nil];
    [self subscribePresenceForUser:frndUsername];
}

#pragma mark Remove user from roster
-(void)removeUserFromRosterForUser:(NSString *)frndUsername
{
    [xmppRoster removeUser:[XMPPJID jidWithString:[self getActualUsernameForUser:frndUsername]]];
}

#pragma mark Subscribe presence with other user
-(void)subscribePresenceForUser:(NSString *)frndUsername
{
    [xmppRoster subscribePresenceToUser:[XMPPJID jidWithString:[self getActualUsernameForUser:frndUsername]]];
}

#pragma mark Unsubscribe presence with other user
-(void)unsubscribePresenceForUser:(NSString *)frndUsername
{
    [xmppRoster revokePresencePermissionFromUser:[XMPPJID jidWithString:[self getActualUsernameForUser:frndUsername]]];
}


-(void)blockUser:(NSString *)usernameStr
{
    NSData *data = [BlockingMessageStr dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    NSString *msgVal = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    
    NSString *messageID=[self generateUniqueID];
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:msgVal];
    
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithString:[self getActualUsernameForUser:usernameStr]] elementID:messageID child:body];
    
    [[self xmppStream] sendElement:message];
}

-(void)unblockUser:(NSString *)usernameStr
{
    NSData *data = [UnblockingMessageStr dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    NSString *msgVal = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    
    NSString *messageID=[self generateUniqueID];
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:msgVal];
    
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithString:[self getActualUsernameForUser:usernameStr]] elementID:messageID child:body];
    
    [[self xmppStream] sendElement:message];
}


-(void)updateUserBlockingFlag:(BOOL)isBlocked forUser:(NSString *)otherUsernameStr withLoggedInUser:(NSString *)loggedInUsernameStr
{
    NSManagedObjectContext *context = self.managedObjectContext_chatMessage;
    NSEntityDescription *userEntityDescription = [NSEntityDescription entityForName:@"UserInfo"  inManagedObjectContext:context];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"logged_user_phone_number == %@ && phone_number == %@", loggedInUsernameStr, otherUsernameStr];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:userEntityDescription];
    [fetch setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *userAr = [context executeFetchRequest:fetch error:&error];
    
    if([userAr count]==1)
    {
        UserInfo *userObj = [userAr objectAtIndex:0];
        
        [userObj setIs_blocked:@(isBlocked)];
        
        NSError *error;
        
        if (![context save:&error])
        {
            DLog(@"Failed to save user info - error: %@", [error localizedDescription]);
        }
    }
    
}


#pragma mark Check for user presence
-(BOOL)isUserOnline:(NSString *)usernameStr
{
    
    NSPredicate *searchPred = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"user CONTAINS '%@'",[self getActualUsernameForUser:usernameStr]]];
    NSArray *foundUser = [self.presenceArray filteredArrayUsingPredicate:searchPred];
    if([foundUser count]==1)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


#pragma mark Get actual username
-(NSString *)getActualUsernameForUser:(NSString *)nameStr
{
    if([nameStr rangeOfString:[NSString stringWithFormat:@"@%@",self.servername]].location == NSNotFound)
    {
        nameStr = [nameStr stringByAppendingString:[NSString stringWithFormat:@"@%@",self.servername]];
    }
    return nameStr;
}

#pragma mark Get actual group id
-(NSString *)getActualGroupIDForRoom:(NSString *)roomIDStr
{
    if([roomIDStr rangeOfString:[NSString stringWithFormat:@"@%@",XMPP_GROUP_DOMAIN]].location == NSNotFound)
    {
        roomIDStr = [roomIDStr stringByAppendingString:[NSString stringWithFormat:@"@%@",XMPP_GROUP_DOMAIN]];
    }
    return roomIDStr;
}

#pragma mark Generate unique id
-(NSString*)generateUniqueID
{
    NSString* uniqueIdentifier = nil;
    
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    //uniqueIdentifier = ( NSString*)CFUUIDCreateString(NULL, uuid);- for non- ARC
    uniqueIdentifier = ( NSString*)CFBridgingRelease(CFUUIDCreateString(NULL, uuid));// for ARC
    CFRelease(uuid);
    
    return uniqueIdentifier;
}


#pragma mark Play buzz sound

-(void)playBuzzSound
{
    //AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    
    if (buzzSoundId == nil)
    {
        NSString *path = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"GLASS SMASH CRASH.mp3"];
        NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
        SystemSoundID sound;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &sound);
        buzzSoundId = [NSNumber numberWithUnsignedLong:sound];
    }
    AudioServicesPlaySystemSound([buzzSoundId unsignedLongValue]);
}

#pragma mark Delete user conversation from chat ids

-(void)deleteCoversationWithIds:(NSArray *)chatIdAr
{
    NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatConversation"  inManagedObjectContext:context];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"senderId == %@ && (receiverId IN %@)", self.username, chatIdAr];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setPredicate:predicate];
    
    NSError * error = nil;
    
    NSArray *fetchedResults = [context executeFetchRequest:fetchRequest error:&error];
    
    fetchRequest = nil;
    
    for(ChatConversation *chatObj in fetchedResults)
    {
        if([chatObj.messageType isEqualToString:OUT_BOUND_MESSAGE_TYPE_IMAGE] || [chatObj.messageType isEqualToString:OUT_BOUND_MESSAGE_TYPE_AUDIO] || [chatObj.messageType isEqualToString:OUT_BOUND_MESSAGE_TYPE_VIDEO])
        {
            [self deleteFileFromDownloadFileDirectory:[chatObj.fileUrl lastPathComponent]];
            
            /*NSString *filePath = [[self getLocalDownloadFileDirectory] stringByAppendingPathComponent:[chatObj.fileUrl lastPathComponent]];
             
             // if no directory was provided, we look by default in the base cached dir
             if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
             {
             [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
             }*/
            
            if([chatObj.mimeType isEqualToString:@"image/jpeg"])
            {
                
            }
            else
            {
                
            }
        }
        
        [context deleteObject:chatObj];
    }
    NSError *saveError = nil;
    [context save:&saveError];
}

#pragma mark fetch user info object from chat id

//-(UserInfo *)fetchUserInfoObjectForID:(NSString *)chatID
-(id)fetchUserInfoObjectForID:(NSString *)chatID
{
    NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UserInfo"  inManagedObjectContext:context];
    
    NSString * predicteString = [NSString stringWithFormat:@"logged_user_phone_number == '%@' && phone_number == '%@' && isGroup == 0", self.username, chatID];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicteString];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    
    NSError * error = nil;
    
    NSArray *fetchedResults = [context executeFetchRequest:fetchRequest error:&error];
    
    fetchRequest = nil;
    
    if([fetchedResults count]>0)
    {
        return [fetchedResults objectAtIndex:0];
    }
    
    return nil;
}

#pragma mark fetch user info dictionary from chat id

-(NSDictionary *)fetchUserInfoDictionaryForID:(NSString *)chatID
{
    NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UserInfo"  inManagedObjectContext:context];
    
    NSString * predicteString = [NSString stringWithFormat:@"logged_user_phone_number == '%@' && phone_number == '%@' && isGroup == 0", self.username, chatID];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicteString];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    NSError * error = nil;
    
    NSArray *fetchedResults = [context executeFetchRequest:fetchRequest error:&error];
    
    fetchRequest = nil;
    
    if([fetchedResults count]>0)
    {
        return [fetchedResults objectAtIndex:0];
    }
    
    return nil;
}

#pragma mark fetch list info object from chat id

-(id)fetchListInfoObjectForID:(NSString *)chatID
{
    
    NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UserInfo"  inManagedObjectContext:context];
    
    NSString * predicteString = [NSString stringWithFormat:@"logged_user_phone_number == '%@' && phone_number == '%@' && isList == 1", self.username, chatID];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicteString];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    
    NSError * error = nil;
    
    NSArray *fetchedResults = [context executeFetchRequest:fetchRequest error:&error];
    
    fetchRequest = nil;
    
    if([fetchedResults count]>0)
    {
        return [fetchedResults objectAtIndex:0];
    }
    
    return nil;
}


#pragma mark fetch list info dictionary from chat id

-(NSDictionary *)fetchListInfoDictionaryForID:(NSString *)chatID
{
    NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UserInfo"  inManagedObjectContext:context];
    
    NSString * predicteString = [NSString stringWithFormat:@"logged_user_phone_number == '%@' && phone_number == '%@' && isList == 1", self.username, chatID];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicteString];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    NSError * error = nil;
    
    NSArray *fetchedResults = [context executeFetchRequest:fetchRequest error:&error];
    
    fetchRequest = nil;
    
    if([fetchedResults count]>0)
    {
        return [fetchedResults objectAtIndex:0];
    }
    
    return nil;
}


#pragma mark fetch group info dictionary from chat id

-(NSDictionary *)fetchGroupInfoDictionaryForID:(NSString *)chatID
{
    NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UserInfo"  inManagedObjectContext:context];
    
    NSString * predicteString = [NSString stringWithFormat:@"logged_user_phone_number == '%@' && phone_number == '%@' && isGroup == 1", self.username, chatID];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicteString];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    NSError * error = nil;
    
    NSArray *fetchedResults = [context executeFetchRequest:fetchRequest error:&error];
    
    fetchRequest = nil;
    
    if([fetchedResults count]>0)
    {
        return [fetchedResults objectAtIndex:0];
    }
    
    return nil;
}


#pragma mark fetch group info object from chat id

-(id)fetchGroupInfoObjectForID:(NSString *)chatID
{
    NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UserInfo"  inManagedObjectContext:context];
    
    NSString * predicteString = [NSString stringWithFormat:@"logged_user_phone_number == '%@' && phone_number == '%@' && isGroup == 1", self.username, chatID];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicteString];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    
    NSError * error = nil;
    
    NSArray *fetchedResults = [context executeFetchRequest:fetchRequest error:&error];
    
    fetchRequest = nil;
    
    if([fetchedResults count]>0)
    {
        return [fetchedResults objectAtIndex:0];
    }
    
    return nil;
}

#pragma mark Delete diven list
-(BOOL)deleteListWithListId:(NSString *)listId
{
    UserInfo *listInfo = [self fetchListInfoObjectForID:listId];
    
    NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
    
    [context deleteObject:listInfo];
    
    NSError *saveError = nil;
    
    if([context save:&saveError])
    {
        return YES;
    }
    
    return NO;
}


#pragma mark Get local download file path directory
-(NSString *)getLocalDownloadFileDirectory
{
    NSString *localFileDirectory = [[Utility getLibraryDirectoryPath] stringByAppendingPathComponent:CHAT_CONTENT_DIRECTORY_NAME];
    
    if(![Utility isFileOrDirectoryExistAtPath:localFileDirectory])
    {
        [Utility createDirectoryAtLibraryDirectory:CHAT_CONTENT_DIRECTORY_NAME];
    }
    
    return localFileDirectory;
}

-(BOOL)fileExistAtDownloadFileDirectory:(NSString *)fileName
{
    NSString *filePath = [[self getLocalDownloadFileDirectory] stringByAppendingPathComponent:fileName];
    
    // if no directory was provided, we look by default in the base cached dir
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        return YES;
    }
    
    return NO;
}

-(void)deleteFileFromDownloadFileDirectory:(NSString *)fileName
{
    NSString *filePath = [[self getLocalDownloadFileDirectory] stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}


-(void)sendInfoMessageToGroupId:(NSString *)groupChatId withMessage:(NSString *)messageBody
{
    NSString *groupJidStr = [[XmppHelper sharedInstance] getActualGroupIDForRoom:groupChatId];
    
    NSString *messageID = [[XmppHelper sharedInstance] generateUniqueID];
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:messageBody];
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"id" stringValue:messageID];
    [message addAttributeWithName:@"type" stringValue:CHAT_TYPE_GROUP];
    [message addAttributeWithName:@"from" stringValue:[XmppHelper sharedInstance].xmppStream.myJID.full];
    [message addAttributeWithName:@"to" stringValue:groupJidStr];
    [message addChild:body];
    
    NSXMLElement *outOfBand = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:oob"];
    
    NSXMLElement *URLElement = [NSXMLElement elementWithName:@"url" stringValue:@""];
    [outOfBand addChild:URLElement];
    
    NSXMLElement *typeElement = [NSXMLElement elementWithName:@"messageType" stringValue:OUT_BOUND_MESSAGE_TYPE_INFO];
    [outOfBand addChild:typeElement];
    
    [message addChild:outOfBand];
    
    //[[[XmppHelper sharedInstance] xmppStream] sendElement:message];
}


-(void)displayNavigationNotificationForChatObj:(ChatConversation *)msgObj
{
    NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
    NSEntityDescription *userEntityDescription = [NSEntityDescription entityForName:@"UserInfo"  inManagedObjectContext:context];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"logged_user_phone_number == %@ && phone_number == %@", self.username, msgObj.receiverId];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:userEntityDescription];
    [fetch setPredicate:predicate];
    
    [fetch setResultType:NSDictionaryResultType];
    
    NSError *error = nil;
    NSArray *tempAr = [context executeFetchRequest:fetch error:&error];
    
    NSString *nameStr = @"New Message Received";
    
    if([tempAr count] == 1)
    {
        nameStr = [Utility getAsciiUtf8DecodedStringFor:[tempAr objectAtIndex:0][@"user_name"]];
        if([nameStr length] == 0)
        {
            nameStr = [tempAr objectAtIndex:0][@"user_name"];
        }
    }
    
    
    /*if([msgObj.messageType isEqualToString:OUT_BOUND_MESSAGE_TYPE_IMAGE])
     {
     if([tempAr count]==1)
     {
     LNNotification *notification = [LNNotification notificationWithMessage:[NSString stringWithFormat:@"%@ sent you an image.", nameStr]];
     notification.title = nameStr;
     notification.soundName = @"demo.aiff";
     notification.defaultAction = nil;
     
     [[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"XmppHelperNotification"];
     }
     else
     {
     LNNotification *notification = [LNNotification notificationWithMessage:@"You got an image."];
     notification.title = nameStr;
     notification.soundName = @"demo.aiff";
     notification.defaultAction = nil;
     
     [[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"XmppHelperNotification"];
     }
     }
     else if([msgObj.messageType isEqualToString:OUT_BOUND_MESSAGE_TYPE_AUDIO])
     {
     if([tempAr count]==1)
     {
     LNNotification *notification = [LNNotification notificationWithMessage:[NSString stringWithFormat:@"%@ sent you an audio.", nameStr]];
     notification.title = nameStr;
     notification.soundName = @"demo.aiff";
     notification.defaultAction = nil;
     
     [[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"XmppHelperNotification"];
     }
     else
     {
     LNNotification *notification = [LNNotification notificationWithMessage:@"You got an audio."];
     notification.title = nameStr;
     notification.soundName = @"demo.aiff";
     notification.defaultAction = nil;
     
     [[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"XmppHelperNotification"];
     }
     }
     else if([msgObj.messageType isEqualToString:OUT_BOUND_MESSAGE_TYPE_BUZZ])
     {
     if([tempAr count]==1)
     {
     LNNotification *notification = [LNNotification notificationWithMessage:[NSString stringWithFormat:@"%@ sent you a smash!!", nameStr]];
     notification.title = nameStr;
     notification.soundName = @"demo.aiff";
     notification.defaultAction = nil;
     
     [[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"XmppHelperNotification"];
     }
     else
     {
     LNNotification *notification = [LNNotification notificationWithMessage:@"You got a smash!!"];
     notification.title = nameStr;
     notification.soundName = @"demo.aiff";
     notification.defaultAction = nil;
     
     [[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"XmppHelperNotification"];
     }
     }
     else if([msgObj.messageType isEqualToString:OUT_BOUND_MESSAGE_TYPE_VCARD])
     {
     if([tempAr count]==1)
     {
     LNNotification *notification = [LNNotification notificationWithMessage:[NSString stringWithFormat:@"%@ sent you a contact.", nameStr]];
     notification.title = nameStr;
     notification.soundName = @"demo.aiff";
     notification.defaultAction = nil;
     
     [[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"XmppHelperNotification"];
     }
     else
     {
     LNNotification *notification = [LNNotification notificationWithMessage:@"You got a contact."];
     notification.title = nameStr;
     notification.soundName = @"demo.aiff";
     notification.defaultAction = nil;
     
     [[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"XmppHelperNotification"];
     }
     }
     else if([msgObj.messageType isEqualToString:OUT_BOUND_MESSAGE_TYPE_LOCATION])
     {
     if([tempAr count]==1)
     {
     LNNotification *notification = [LNNotification notificationWithMessage:[NSString stringWithFormat:@"%@ sent you a location.", nameStr]];
     notification.title = nameStr;
     notification.soundName = @"demo.aiff";
     notification.defaultAction = nil;
     
     [[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"XmppHelperNotification"];
     }
     else
     {
     LNNotification *notification = [LNNotification notificationWithMessage:@"You got a location."];
     notification.title = nameStr;
     notification.soundName = @"demo.aiff";
     notification.defaultAction = nil;
     
     [[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"XmppHelperNotification"];
     }
     }
     else if([msgObj.messageType isEqualToString:GROUP_MESSAGE_TYPE_SUBJECT_CHANGE] || [msgObj.messageType isEqualToString:OUT_BOUND_MESSAGE_TYPE_INFO] || [msgObj.messageType isEqualToString:OUT_BOUND_MESSAGE_TYPE_REMOVED_FROM_GROUP] || msgObj == nil)
     {
     
     }
     else
     {
     if([tempAr count]==1)
     {
     LNNotification *notification = [LNNotification notificationWithMessage:[NSString stringWithFormat:@"%@: %@", nameStr, msgObj.messageBody]];
     notification.title = nameStr;
     notification.soundName = @"demo.aiff";
     notification.defaultAction = nil;
     
     [[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"XmppHelperNotification"];
     }
     else
     {
     LNNotification *notification = [LNNotification notificationWithMessage:msgObj.messageBody];
     notification.title = nameStr;
     notification.soundName = @"demo.aiff";
     notification.defaultAction = nil;
     
     [[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"XmppHelperNotification"];
     }
     }*/
}


-(ChatConversation *)getSavedItemsObjectWithMessageId:(NSString *)messageID andReceiverId:(NSString *)receiverId
{
    NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"SavedItems"  inManagedObjectContext:context];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"senderId == %@ && receiverId == %@ && messageId == %@", self.username, receiverId, messageID];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setPredicate:predicate];
    
    NSError * error = nil;
    
    NSArray *fetchedResults = [context executeFetchRequest:fetchRequest error:&error];
    
    if([fetchedResults count]>0)
    {
        return [fetchedResults objectAtIndex:0];
    }
    
    return nil;
}

-(void)saveItemWithChatObject:(ChatConversation *)chatObj
{
    ChatConversation *existingSavedItemsObj = [[XmppHelper sharedInstance] getSavedItemsObjectWithMessageId:chatObj.messageId andReceiverId:chatObj.receiverId];
    if(!existingSavedItemsObj)
    {
        ChatConversation *savedItemsObj = [NSEntityDescription insertNewObjectForEntityForName:@"SavedItems" inManagedObjectContext:[XmppHelper sharedInstance].managedObjectContext_chatMessage];
        
        [savedItemsObj setFileData:chatObj.fileData];
        [savedItemsObj setFileName:chatObj.fileName];
        [savedItemsObj setFileUrl:chatObj.fileUrl];
        [savedItemsObj setHasMedia:chatObj.hasMedia];
        [savedItemsObj setImageOpenTime:chatObj.imageOpenTime];
        [savedItemsObj setIsGroupMessage:chatObj.isGroupMessage];
        [savedItemsObj setIsMessageReceived:chatObj.isMessageReceived];
        [savedItemsObj setIsNew:chatObj.isNew];
        [savedItemsObj setIsPending:chatObj.isPending];
        [savedItemsObj setIsSavedItem:@(YES)];
        [savedItemsObj setLocalFilePath:chatObj.localFilePath];
        [savedItemsObj setMessageBody:chatObj.messageBody];
        [savedItemsObj setMessageDate:chatObj.messageDate];
        [savedItemsObj setMessageDateTime:chatObj.messageDateTime];
        [savedItemsObj setMessageId:chatObj.messageId];
        [savedItemsObj setMessageStatus:chatObj.messageStatus];
        [savedItemsObj setMessageTime:chatObj.messageTime];
        [savedItemsObj setMessageType:chatObj.messageType];
        [savedItemsObj setMimeType:chatObj.mimeType];
        [savedItemsObj setOccupantId:chatObj.occupantId];
        [savedItemsObj setReceiverId:chatObj.receiverId];
        [savedItemsObj setSectionIdentifier:chatObj.sectionIdentifier];
        [savedItemsObj setSenderId:chatObj.senderId];
        [savedItemsObj setThumbnailData:chatObj.thumbnailData];
        [savedItemsObj setThumbnailUrl:chatObj.thumbnailUrl];
        [savedItemsObj setSenderUserName:chatObj.senderUserName];
        
        NSError *error;
        
        if (![[XmppHelper sharedInstance].managedObjectContext_chatMessage save:&error])
        {
            NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        }
    }
}


#pragma mark - setup/initialize xmpp stream
- (void)setupStream
{
    customCertEvaluation = YES;
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    xmppStream = [[XMPPStream alloc] init];
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
#if !TARGET_IPHONE_SIMULATOR
    {
        // Want xmpp to run in the background?
        //
        // P.S. - The simulator doesn't support backgrounding yet.
        //        When you try to set the associated property on the simulator, it simply fails.
        //        And when you background an app on the simulator,
        //        it just queues network traffic til the app is foregrounded again.
        //        We are patiently waiting for a fix from Apple.
        //        If you do enableBackgroundingOnSocket on the simulator,
        //        you will simply see an error message from the xmpp stack when it fails to set the property.
        
        xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    
    
    // Optional:
    //
    // Replace me with the proper domain and port.
    // The example below is setup for a typical google talk account.
    //
    // If you don't supply a hostName, then it will be automatically resolved using the JID (below).
    // For example, if you supply a JID like 'user@quack.com/rsrc'
    // then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
    //
    // If you don't specify a hostPort, then the default (5222) will be used.
    
    //	[xmppStream setHostName:@"talk.google.com"];
    //	[xmppStream setHostPort:5222];
    
    [xmppStream setHostName:self.hostname];
    [xmppStream setHostPort:self.hostport];
    
    // You may need to alter these settings depending on the server you're connecting to
    /*allowSelfSignedCertificates = NO;
     allowSSLHostNameMismatch = NO;*/
    
    xmppReconnect = [[XMPPReconnect alloc] init];
    [xmppReconnect activate:xmppStream];
    
    
    ///ROSTER///
    
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    
    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
    xmppRoster.autoFetchRoster = YES;
    xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    [xmppRoster activate:xmppStream];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
    
    ///vCard///
    xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    
    xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
    
    [xmppvCardTempModule   activate:xmppStream];
    [xmppvCardAvatarModule activate:xmppStream];
    
    
    
    /*///MESSAGE STORAGE///
     xmppMessageStorage = [XMPPMessageCoreDataStorage sharedInstance];
     xmppMessageModule = [[XMPPMessageModule alloc] initWithMessageStorage:xmppMessageStorage];
     
     [xmppMessageModule  activate:xmppStream];*/
    
    __managedObjectContext_chatMessage = self.managedObjectContext_chatMessage;
    
    
    /*XMPPStreamInitiation *streamInitiation = [[XMPPStreamInitiation alloc] initWithDispatchQueue:dispatch_get_main_queue()];
     [streamInitiation activate:xmppStream];*/
    
    
    /*xmppFileTransfer = [[XMPPSIFileTransfer alloc] init];
     [xmppFileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];
     [xmppFileTransfer activate:xmppStream];*/
    
    
    
    XMPPMessageDeliveryReceipts* xmppMessageDeliveryRecipts = [[XMPPMessageDeliveryReceipts alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    xmppMessageDeliveryRecipts.autoSendMessageDeliveryReceipts = YES;
    xmppMessageDeliveryRecipts.autoSendMessageDeliveryRequests = YES;
    [xmppMessageDeliveryRecipts activate:xmppStream];
    
    
    xmppMUC = [[XMPPMUC alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    [xmppMUC activate:xmppStream];
    [xmppMUC addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    xmppRoomCoreDataStore = [XMPPRoomCoreDataStorage sharedInstance];
    
    
    xmppLastActivity = [[XMPPLastActivity alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    [xmppLastActivity addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppLastActivity activate:xmppStream];
}

#pragma mark go user to be online
- (void)goOnline
{
    intervalSinceLastLogout = 0;
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"lastLogoutTimeDict"])
    {
        NSDictionary *lastLogoutTimeDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastLogoutTimeDict"];
        
        if(lastLogoutTimeDict[self.xmppStream.myJID.user])
        {
            NSTimeInterval lastLogoutTimeInterval = [lastLogoutTimeDict[self.xmppStream.myJID.user] doubleValue];
            intervalSinceLastLogout = [[NSDate date] timeIntervalSince1970] - lastLogoutTimeInterval;
        }
    }
    
    [self getListOfGroups];
    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
    [self sendPendingMessage];
}

#pragma mark go user to be online
- (void)goOffline
{
    if(([self.xmppStream isAuthenticated] && roomChatHistoryFetched) || roomChatHistoryFetched)
    {
        roomChatHistoryFetched = YES;
        
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"lastLogoutTimeDict"])
        {
            NSMutableDictionary *lastLogoutTimeDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"lastLogoutTimeDict"]];
            
            [lastLogoutTimeDict setObject:@([[NSDate date] timeIntervalSince1970]) forKey:self.username];
            
            [[NSUserDefaults standardUserDefaults] setObject:lastLogoutTimeDict forKey:@"lastLogoutTimeDict"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
            NSMutableDictionary *lastLogoutTimeDict = [NSMutableDictionary dictionary];
            
            [lastLogoutTimeDict setObject:@([[NSDate date] timeIntervalSince1970]) forKey:self.username];
            
            [[NSUserDefaults standardUserDefaults] setObject:lastLogoutTimeDict forKey:@"lastLogoutTimeDict"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}

#pragma mark connect to server with username/jid
- (BOOL)connect
{
    if (![xmppStream isDisconnected])
    {
        return YES;
    }
    
    if (self.username == nil || self.password == nil)
    {
        return NO;
    }
    
    [xmppStream setMyJID:[XMPPJID jidWithString:[self getActualUsernameForUser:self.jId]]];
    
    NSError *error = nil;
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
                                                            message:@"See console for error details."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        return NO;
    }
    
    return YES;
}

#pragma mark disconnect sever connection
- (void)disconnect
{
    
    [self goOffline];
    [xmppStream disconnectAfterSending];
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
   // DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
   // DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    /*if (allowSelfSignedCertificates)
     {
     [settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
     }
     
     if (allowSSLHostNameMismatch)
     {
     [settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
     }
     else
     {
     NSString *expectedCertName = [xmppStream.myJID domain];
     
     if (expectedCertName)
     {
     [settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
     }
     }*/
    
    NSString *expectedCertName = [xmppStream.myJID domain];
    if (expectedCertName)
    {
        settings[(NSString *) kCFStreamSSLPeerName] = expectedCertName;
    }
    
    if (customCertEvaluation)
    {
        settings[GCDAsyncSocketManuallyEvaluateTrust] = @(YES);
    }
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
   // DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    //progessLoading = [MBProgressHUD showHUDAddedTo:window animated:YES];
    progessLoading.labelText = @"Please Wait";
    
    // DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    isXmppConnected = YES;
    
    NSError *error = nil;
    
    if (![[self xmppStream] authenticateWithPassword:self.password error:&error])
    {
       // DDLogError(@"Error authenticating: %@", error);
    }
    //[MBProgressHUD hideHUDForView:window animated:YES];
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    //DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    /*NSDictionary *loggedInUserDict = [NKeyChain objectForKey:@"wUserInfo"];
     
     
     XMPPvCardTemp *myVcardTemp = [xmppvCardTempModule myvCardTemp];
     if (!myVcardTemp)
     {
     NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
     XMPPvCardTemp *myVcardTemp = [XMPPvCardTemp vCardTempFromElement:vCardXML];
     [myVcardTemp setNickname:loggedInUserDict[@"user_name"]];
     [myVcardTemp setTelecomsAddresses:@[loggedInUserDict[@"phone_number"]]];
     [xmppvCardTempModule updateMyvCardTemp:myVcardTemp];
     }
     else
     {
     [myVcardTemp setNickname:loggedInUserDict[@"user_name"]];
     [myVcardTemp setTelecomsAddresses:@[loggedInUserDict[@"phone_number"]]];
     [xmppvCardTempModule updateMyvCardTemp:myVcardTemp];
     }*/
    
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPP_AUTHENTICATED_NOTIFICATION object:nil];
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    [MBProgressHUD hideHUDForView:window animated:YES];
    [self.rooms removeAllObjects];
    [self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
   // DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPP_UNAUTHENTICATED_NOTIFICATION object:nil];
}

/*- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
 {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	return NO;
 }*/

-(NSString *)convertDictionaryToString:(NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString=  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return jsonString;
}


- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    //DLog(@"message = %@", message);
    
    //DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    /*************  Recent Chat List*****************/
    
    if([message isUserDetail])
    {
        NSDateFormatter *dateFormate = [[NSDateFormatter alloc]init];
        [dateFormate setDateFormat:@"dd/MM/yyyy hh:mm a"];
        
        
        NSXMLElement *chatDetail = [message elementForName:@"chatDetail" xmlns:@"jabber:x:oob"];
        NSString *profile_pic = [[chatDetail elementForName:@"profile_pic"] stringValue];
        NSString *name = [[chatDetail elementForName:@"name"] stringValue];
        NSString *strId = [[message from] user];
        NSString *strMsg = [[message elementForName:@"body"] stringValue];
        NSString *strTime = [dateFormate stringFromDate:[NSDate date]];
        
        if ([message isChatMessageWithBody])
        {
            if(![strId isEqualToString:[NSString stringWithFormat:@"%@",[LoggedInUser sharedUser].userId]])
            {
                
                NSArray *arrRec = [[kPref valueForKey:kRecentChatArray] mutableCopy];
                NSMutableArray *arrRecent = [[NSMutableArray alloc]init];
                [arrRecent addObjectsFromArray:arrRec];
                
                BOOL isAlready = false;
                for(int i = 0;i<arrRecent.count;i++)
                {
                    if([[[arrRecent objectAtIndex:i] valueForKey:@"type"] isEqualToString:CHAT_TYPE_SINGLE])
                    {
                        if([strId isEqualToString:[[arrRecent objectAtIndex:i] valueForKey:@"user_id"]])
                        {
                            int count = [[[arrRecent objectAtIndex:i] valueForKey:@"count"] intValue];
                            count = count + 1;
                            [arrRecent removeObjectAtIndex:i];
                            
                            NSMutableDictionary *dictRecent = [[NSMutableDictionary alloc]init];
                            [dictRecent setValue:profile_pic forKey:@"profile_pic"];
                            [dictRecent setValue:strId forKey:@"user_id"];
                            [dictRecent setValue:name forKey:@"name"];
                            [dictRecent setValue:strMsg forKey:@"message"];
                            [dictRecent setValue:strTime forKey:@"time"];
                            [dictRecent setValue:CHAT_TYPE_SINGLE forKey:@"type"];
                            [dictRecent setValue:[NSNumber numberWithInt:count] forKey:@"count"];
                            [arrRecent addObject:dictRecent];
                            [kPref setObject:arrRecent forKey:kRecentChatArray];
                            isAlready = true;
                            break;
                        }
                    }
                }
                if(!isAlready)
                {
                    int count = 1;
                    NSMutableDictionary *dictRecent = [[NSMutableDictionary alloc]init];
                    [dictRecent setValue:profile_pic forKey:@"profile_pic"];
                    [dictRecent setValue:strId forKey:@"user_id"];
                    [dictRecent setValue:name forKey:@"name"];
                    [dictRecent setValue:strMsg forKey:@"message"];
                    [dictRecent setValue:strTime forKey:@"time"];
                    [dictRecent setValue:CHAT_TYPE_SINGLE forKey:@"type"];
                    [dictRecent setValue:[NSNumber numberWithInt:count] forKey:@"count"];
                    [arrRecent addObject:dictRecent];
                    [kPref setObject:arrRecent forKey:kRecentChatArray];
                }
            }
        }
        else if ([message isGroupChatMessage])
        {
            NSString *strId = [[message from] user];
            NSString *strUid = [[message to] user];
            
            NSArray *arrRec = [[kPref valueForKey:kRecentChatArray] mutableCopy];
            NSMutableArray *arrRecent = [[NSMutableArray alloc]init];
            [arrRecent addObjectsFromArray:arrRec];
            
            if([strUid intValue] == [[LoggedInUser sharedUser].userId intValue])
            {
                BOOL isAlready = false;
                for(int i = 0;i<arrRecent.count;i++)
                {
                    if([[[arrRecent objectAtIndex:i] valueForKey:@"type"] isEqualToString:CHAT_TYPE_GROUP])
                    {
                        if([strId isEqualToString:[[arrRecent objectAtIndex:i] valueForKey:@"group_id"]])
                        {
                            int count = [[[arrRecent objectAtIndex:i] valueForKey:@"count"] intValue];
                            count = count + 1;
                            [arrRecent removeObjectAtIndex:i];
                            
                            NSMutableDictionary *dictRecent = [[NSMutableDictionary alloc]init];
                            [dictRecent setValue:profile_pic forKey:@"profile_pic"];
                            [dictRecent setValue:strId forKey:@"group_id"];
                            [dictRecent setValue:name forKey:@"name"];
                            [dictRecent setValue:strMsg forKey:@"message"];
                            [dictRecent setValue:strTime forKey:@"time"];
                            [dictRecent setValue:CHAT_TYPE_GROUP forKey:@"type"];
                            [dictRecent setValue:[NSNumber numberWithInt:count] forKey:@"count"];
                            [arrRecent addObject:dictRecent];
                            [kPref setObject:arrRecent forKey:kRecentChatArray];
                            isAlready = true;
                            break;
                        }
                    }
                }
                if(!isAlready)
                {
                    int count = 1;
                    NSMutableDictionary *dictRecent = [[NSMutableDictionary alloc]init];
                    [dictRecent setValue:profile_pic forKey:@"profile_pic"];
                    [dictRecent setValue:strId forKey:@"group_id"];
                    [dictRecent setValue:name forKey:@"name"];
                    [dictRecent setValue:strMsg forKey:@"message"];
                    [dictRecent setValue:strTime forKey:@"time"];
                    [dictRecent setValue:CHAT_TYPE_GROUP forKey:@"type"];
                    [dictRecent setValue:[NSNumber numberWithInt:count] forKey:@"count"];
                    [arrRecent addObject:dictRecent];
                    [kPref setObject:arrRecent forKey:kRecentChatArray];
                }
            }
        }
    }
    
    /*************  Recent Chat List*****************/
    
    
    if ([message isChatMessageWithBody] && ([[message body] isEqualToString:BlockingMessageStr] || [[message body] isEqualToString:UnblockingMessageStr]))
    {
        if([[message body] isEqualToString:BlockingMessageStr])
        {
            [self updateUserBlockingFlag:YES forUser:[[message from] user] withLoggedInUser:[[message to] user]];
            
            if([self.delegate respondsToSelector:@selector(userBlocked)])
            {
                [self.delegate userBlocked];
            }
        }
        else
        {
            [self updateUserBlockingFlag:NO forUser:[[message from] user] withLoggedInUser:[[message to] user]];
            
            if([self.delegate respondsToSelector:@selector(userUnblocked)])
            {
                [self.delegate userUnblocked];
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_CHAT_LIST_NOTIFICATION object:nil];
        
        return;
    }
    
    
    // A simple example of inbound message handling.
    if([message hasOutOfBandData])
    {
        
        NSTimeInterval _interval=[CurrentTimeStamp doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
        
        if([message wasDelayed])
        {
            _interval= [[message delayedDeliveryDate] timeIntervalSince1970];
            date = [NSDate dateWithTimeIntervalSince1970:_interval];
        }
        
        NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"dd/MM/yyyy"];
        NSString *dateStr = [formatter stringFromDate:date];
        
        
        
        
        NSString *messageTypeStr = [self outOfBandTypeFromMessage:message];
        NSString *messageID = [[message attributeForName:@"id"] stringValue];
        NSString *fileURlPath = [self outOfBandURLPathFromMessage:message];
        NSXMLElement *outOfBand = [message elementForName:@"x" xmlns:@"jabber:x:oob"];
        
        if([message isGroupChatMessage])
        {
            NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatConversation"  inManagedObjectContext:context];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"senderId == %@ && receiverId == %@ && messageId == %@", self.username, [[message from] user], messageID];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:entityDescription];
            [fetchRequest setPredicate:predicate];
            
            NSError * error = nil;
            
            NSArray *fetchedResults = [context executeFetchRequest:fetchRequest error:&error];
            
            if([fetchedResults count]>0)
            {
                fetchRequest = nil;
                return;
            }
            
            fetchRequest = nil;
        }
        
        if([messageTypeStr isEqualToString:OUT_BOUND_MESSAGE_TYPE_INFO])
        {
            NSString *body = [[message elementForName:@"body"] stringValue];
            NSString *messageID = [[message attributeForName:@"id"] stringValue];
            
            NSString *infoTypeStr = [[outOfBand elementForName:@"infoType"] stringValue];
            NSString *urlStr = [[outOfBand elementForName:@"url"] stringValue];
            
            NSTimeInterval _interval=[CurrentTimeStamp doubleValue];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
            
            if([message wasDelayed])
            {
                _interval= [[message delayedDeliveryDate] timeIntervalSince1970];
                date = [NSDate dateWithTimeIntervalSince1970:_interval];
            }
            
            NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"dd/MM/yyyy"];
            NSString *dateStr = [formatter stringFromDate:date];
            
            
            NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
            NSString *msgVal = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
            
            //NSString *msgVal = [body stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            ChatConversation *chatObj = [NSEntityDescription insertNewObjectForEntityForName:@"ChatConversation"
                                                                      inManagedObjectContext:self.managedObjectContext_chatMessage];
            
            [chatObj setFileName:@""];
            [chatObj setFileUrl:@""];
            [chatObj setHasMedia:@(NO)];
            [chatObj setIsMessageReceived:@YES];
            [chatObj setIsNew:@(NO)];
            [chatObj setLocalFilePath:@""];
            [chatObj setMessageBody:msgVal];
            [chatObj setMessageDateTime:date];
            [chatObj setMessageDate:dateStr];
            [chatObj setMessageTime:@""];
            [chatObj setMessageStatus:@""];
            [chatObj setMimeType:@""];
            [chatObj setSenderId:self.username];
            [chatObj setReceiverId:[[message from] user]];
            [chatObj setMessageId:messageID];
            [chatObj setMessageType:messageTypeStr];
            [chatObj setOccupantId:[[message from] resource]];
            [chatObj setIsGroupMessage:@(YES)];
            
            NSError *error;
            
            if (![self.managedObjectContext_chatMessage save:&error])
            {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }
            
            
            if(infoTypeStr && [infoTypeStr isEqualToString:INFO_TYPE_GROUP_ICON_CHANGED])
            {
                UserInfo *exitingGroupInfo = [self getGroupInfoForID:[[message from] user]];
                
                if(exitingGroupInfo != nil)
                {
                    [exitingGroupInfo setProfile_pic:urlStr];
                    
                    NSError *error;
                    
                    if (![self.managedObjectContext_chatMessage save:&error])
                    {
                        DLog(@"Failed to update user info - error: %@", [error localizedDescription]);
                    }
                }
            }
            
            
            //[self.delegate newMessageReceived];
            
            
            if ([self.delegate respondsToSelector:@selector(newMessageReceivedFrom:withChatObj:)])
            {
                //[self.delegate newMessageReceivedFrom:[[message from] user]];
                [self.delegate newMessageReceivedFrom:[[message from] user] withChatObj:chatObj];
            }
            else
            {
                //[self displayNavigationNotificationForChatObj:chatObj];
            }
        }
        else if([messageTypeStr isEqualToString:OUT_BOUND_MESSAGE_TYPE_REMOVED_FROM_GROUP])
        {
            NSString *phoneNumberStr = [[outOfBand elementForName:@"phoneNumber"] stringValue];
            NSString *groupIdStr = [[outOfBand elementForName:@"groupId"] stringValue];
            
            if([self.xmppStream.myJID.user isEqualToString:phoneNumberStr])
            {
                [self deleteGroupIdsFromUserInfo:@[groupIdStr]];
                [self deleteCoversationWithGroupIds:@[groupIdStr]];
                
                NSDictionary *dict = @{@"phone_number" : phoneNumberStr,
                                       @"group_id" : groupIdStr};
                
                [[NSNotificationCenter defaultCenter] postNotificationName:XMPP_USER_REMOVED_FROM_ROOM_NOTIFICATION object:nil userInfo:dict];
                [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_CHAT_LIST_NOTIFICATION object:nil];
            }
        }
        else if([messageTypeStr isEqualToString:OUT_BOUND_MESSAGE_TYPE_IMAGE] || [messageTypeStr isEqualToString:OUT_BOUND_MESSAGE_TYPE_AUDIO] || [messageTypeStr isEqualToString:OUT_BOUND_MESSAGE_TYPE_VIDEO])
        {
            NSString *mimeStr = [[outOfBand elementForName:@"mime-type"] stringValue];
            NSString *captionStr = [[outOfBand elementForName:@"caption"] stringValue];
            
            ChatConversation *chatObj = [NSEntityDescription insertNewObjectForEntityForName:@"ChatConversation"
                                                                      inManagedObjectContext:self.managedObjectContext_chatMessage];
            [self playBuzzSound];
            [chatObj setFileName:@""];
            [chatObj setFileUrl:@""];
            [chatObj setHasMedia:@YES];
            [chatObj setIsMessageReceived:@YES];
            [chatObj setIsNew:@YES];
            [chatObj setMessageDateTime:date];
            [chatObj setMessageDate:dateStr];
            [chatObj setMessageTime:@""];
            [chatObj setMessageStatus:@""];
            [chatObj setMessageBody:captionStr];
            //[chatObj setImageOpenTime:@(IMAGE_VIWE_TIME)];
            [chatObj setMimeType:mimeStr];
            //[chatObj setFileUrl:[message outOfBandURI]];
            [chatObj setFileUrl:fileURlPath];
            [chatObj setFileData:nil];
            [chatObj setThumbnailData:nil];
            [chatObj setSenderId:[[message to] user]];
            [chatObj setReceiverId:[[message from] user]];
            [chatObj setMessageId:messageID];
            [chatObj setMessageType:messageTypeStr];
            //[chatObj setSenderUserName:UName];
            
            if([message isGroupChatMessage])
            {
                if([[[message from] resource] isEqualToString:self.xmppStream.myJID.user])
                {
                    [self.managedObjectContext_chatMessage deleteObject:chatObj];
                    
                    NSError *error = nil;
                    if (![self.managedObjectContext_chatMessage save:&error])
                    {
                        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                    }
                    
                    chatObj = nil;
                    return;
                }
                else
                {
                    [chatObj setOccupantId:[[message from] resource]];
                    //[chatObj setSenderUserName:UName];
                    [chatObj setIsGroupMessage:@(YES)];
                }
            }
            
            NSError *error;
            
            if (![self.managedObjectContext_chatMessage save:&error])
            {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }
            
            //[self.delegate newMessageReceived];
            
            
            if ([self.delegate respondsToSelector:@selector(newMessageReceivedFrom:withChatObj:)])
            {
                //[self.delegate newMessageReceivedFrom:[[message from] user]];
                [self.delegate newMessageReceivedFrom:[[message from] user] withChatObj:chatObj];
            }
            else
            {
                [self displayNavigationNotificationForChatObj:chatObj];
                
                
            }
        }
        else if([messageTypeStr isEqualToString:OUT_BOUND_MESSAGE_TYPE_BUZZ])
        {
            [self playBuzzSound];
            
            ChatConversation *chatObj = [NSEntityDescription insertNewObjectForEntityForName:@"ChatConversation"
                                                                      inManagedObjectContext:self.managedObjectContext_chatMessage];
            
            [chatObj setFileName:@""];
            [chatObj setFileUrl:@""];
            [chatObj setHasMedia:@NO];
            [chatObj setIsMessageReceived:@YES];
            [chatObj setIsNew:@YES];
            [chatObj setMessageDateTime:date];
            [chatObj setMessageDate:dateStr];
            [chatObj setMessageTime:@""];
            [chatObj setMessageStatus:@""];
            [chatObj setMessageBody:@"Smash"];
            //[chatObj setImageOpenTime:@(IMAGE_VIWE_TIME)];
            [chatObj setMimeType:nil];
            [chatObj setFileUrl:[message outOfBandURI]];
            [chatObj setFileData:nil];
            [chatObj setThumbnailData:nil];
            [chatObj setSenderId:[[message to] user]];
            [chatObj setReceiverId:[[message from] user]];
            [chatObj setMessageId:messageID];
            [chatObj setMessageType:messageTypeStr];
            
            
            if([message isGroupChatMessage])
            {
                if([[[message from] resource] isEqualToString:self.xmppStream.myJID.user])
                {
                    
                    [self.managedObjectContext_chatMessage deleteObject:chatObj];
                    
                    NSError *error = nil;
                    if (![self.managedObjectContext_chatMessage save:&error])
                    {
                        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                    }
                    
                    chatObj = nil;
                    return;
                }
                else
                {
                    [chatObj setOccupantId:[[message from] resource]];
                    //[chatObj setSenderUserName:UName];
                    [chatObj setIsGroupMessage:@(YES)];
                }
            }
            
            
            NSError *error;
            
            if (![self.managedObjectContext_chatMessage save:&error])
            {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }
            
            //[self.delegate newMessageReceived];
            
            
            if ([self.delegate respondsToSelector:@selector(newMessageReceivedFrom:withChatObj:)])
            {
                //[self.delegate newMessageReceivedFrom:[[message from] user]];
                [self.delegate newMessageReceivedFrom:[[message from] user] withChatObj:chatObj];
            }
            else
            {
                [self displayNavigationNotificationForChatObj:chatObj];
                
                
            }
        }
        else if([messageTypeStr isEqualToString:OUT_BOUND_MESSAGE_TYPE_VCARD])
        {
            NSString *firstnameStr = [[outOfBand elementForName:@"firstName"] stringValue];
            NSString *lastnameStr = [[outOfBand elementForName:@"lastName"] stringValue];
            NSString *phoneNumberStr = [[outOfBand elementForName:@"phoneNumber"] stringValue];
            NSString *emailStr = [[outOfBand elementForName:@"email"] stringValue];
            NSString *avatarStr = [[outOfBand elementForName:@"avatar"] stringValue];
            
            NSDictionary *contactDict = @{@"firstName" : firstnameStr,
                                          @"lastName" : lastnameStr,
                                          @"phoneNumber" : phoneNumberStr,
                                          @"email" : emailStr,
                                          @"avatar" : avatarStr};
            
            NSString *contactStr = [self convertDictionaryToString:contactDict];
            
            
            ChatConversation *chatObj = [NSEntityDescription insertNewObjectForEntityForName:@"ChatConversation"
                                                                      inManagedObjectContext:self.managedObjectContext_chatMessage];
            
            [chatObj setFileName:@""];
            [chatObj setFileUrl:@""];
            [chatObj setHasMedia:@NO];
            [chatObj setIsMessageReceived:@YES];
            [chatObj setIsNew:@YES];
            [chatObj setMessageDateTime:date];
            [chatObj setMessageDate:dateStr];
            [chatObj setMessageTime:@""];
            [chatObj setMessageStatus:@""];
            [chatObj setMessageBody:contactStr];
            //[chatObj setImageOpenTime:@(IMAGE_VIWE_TIME)];
            [chatObj setMimeType:nil];
            [chatObj setFileUrl:[message outOfBandURI]];
            [chatObj setFileData:nil];
            [chatObj setThumbnailData:nil];
            [chatObj setSenderId:[[message to] user]];
            [chatObj setReceiverId:[[message from] user]];
            [chatObj setMessageId:messageID];
            [chatObj setMessageType:messageTypeStr];
            
            
            if([message isGroupChatMessage])
            {
                if([[[message from] resource] isEqualToString:self.xmppStream.myJID.user])
                {
                    [self.managedObjectContext_chatMessage deleteObject:chatObj];
                    
                    NSError *error = nil;
                    if (![self.managedObjectContext_chatMessage save:&error])
                    {
                        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                    }
                    
                    chatObj = nil;
                    return;
                }
                else
                {
                    [chatObj setOccupantId:[[message from] resource]];
                    //[chatObj setSenderUserName:UName];
                    [chatObj setIsGroupMessage:@(YES)];
                }
            }
            
            
            NSError *error;
            
            if (![self.managedObjectContext_chatMessage save:&error])
            {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }
            
            //[self.delegate newMessageReceived];
            
            
            if ([self.delegate respondsToSelector:@selector(newMessageReceivedFrom:withChatObj:)])
            {
                //[self.delegate newMessageReceivedFrom:[[message from] user]];
                [self.delegate newMessageReceivedFrom:[[message from] user] withChatObj:chatObj];
            }
            else
            {
                [self displayNavigationNotificationForChatObj:chatObj];
                
                
            }
            
            
        }
        else if([messageTypeStr isEqualToString:OUT_BOUND_MESSAGE_TYPE_LOCATION])
        {
            NSString *latitudeStr = [[outOfBand elementForName:@"latitude"] stringValue];
            NSString *longitudeStr = [[outOfBand elementForName:@"longitude"] stringValue];
            
            NSDictionary *locationDict = @{@"latitude" : latitudeStr,
                                           @"longitude" : longitudeStr};
            
            
            
            NSString *locationStr = [self convertDictionaryToString:locationDict];
            
            
            ChatConversation *chatObj = [NSEntityDescription insertNewObjectForEntityForName:@"ChatConversation"
                                                                      inManagedObjectContext:self.managedObjectContext_chatMessage];
            
            [chatObj setFileName:@""];
            [chatObj setFileUrl:@""];
            [chatObj setHasMedia:@NO];
            [chatObj setIsMessageReceived:@YES];
            [chatObj setIsNew:@YES];
            [chatObj setMessageDateTime:date];
            [chatObj setMessageDate:dateStr];
            [chatObj setMessageTime:@""];
            [chatObj setMessageStatus:@""];
            [chatObj setMessageBody:locationStr];
            //[chatObj setImageOpenTime:@(IMAGE_VIWE_TIME)];
            [chatObj setMimeType:nil];
            [chatObj setFileUrl:[message outOfBandURI]];
            [chatObj setFileData:nil];
            [chatObj setThumbnailData:nil];
            [chatObj setSenderId:[[message to] user]];
            [chatObj setReceiverId:[[message from] user]];
            [chatObj setMessageId:messageID];
            [chatObj setMessageType:messageTypeStr];
            
            
            if([message isGroupChatMessage])
            {
                if([[[message from] resource] isEqualToString:self.xmppStream.myJID.user])
                {
                    [self.managedObjectContext_chatMessage deleteObject:chatObj];
                    
                    NSError *error = nil;
                    if (![self.managedObjectContext_chatMessage save:&error])
                    {
                        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                    }
                    
                    chatObj = nil;
                    return;
                }
                else
                {
                    [chatObj setOccupantId:[[message from] resource]];
                    //[chatObj setSenderUserName:UName];
                    [chatObj setIsGroupMessage:@(YES)];
                }
            }
            
            
            NSError *error;
            
            if (![self.managedObjectContext_chatMessage save:&error])
            {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }
            
            //[self.delegate newMessageReceived];
            
            
            if ([self.delegate respondsToSelector:@selector(newMessageReceivedFrom:withChatObj:)])
            {
                //[self.delegate newMessageReceivedFrom:[[message from] user]];
                [self.delegate newMessageReceivedFrom:[[message from] user] withChatObj:chatObj];
            }
            else
            {
                [self displayNavigationNotificationForChatObj:chatObj];
                
                
            }
            
        }
    }
    else if([message hasReceiptResponse])
    {
        NSString *messageID = [message receiptResponseID];
        
        
        NSArray *fetchedObjects;
        NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatConversation"  inManagedObjectContext:context];
        NSString * predicteString = [NSString stringWithFormat:@"messageId == '%@'", messageID];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicteString];
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        [fetch setEntity:entityDescription];
        [fetch setPredicate:predicate];
        NSError * error = nil;
        fetchedObjects = [context executeFetchRequest:fetch error:&error];
        
        if([fetchedObjects count] > 0)
        {
            ChatConversation *chatObj = (ChatConversation *)[fetchedObjects objectAtIndex:0];
            
            [chatObj setIsPending:@(NO)];
            
            NSError *error;
            
            if (![self.managedObjectContext_chatMessage save:&error])
            {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }
            
            if([self.delegate respondsToSelector:@selector(markMessageAsRead:withChatObj:)])
            {
                [self.delegate markMessageAsRead:[[message from] user] withChatObj:chatObj];
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(newMessageReceivedFrom:withChatObj:)])
        {
            //[self.delegate newMessageReceivedFrom:[[message from] user]];
            [self.delegate newMessageReceivedFrom:[[message from] user] withChatObj:nil];
        }
    }
    else if ([message isChatMessageWithBody])
    {
        NSString *body = [[message elementForName:@"body"] stringValue];
        NSString *messageID = [[message attributeForName:@"id"] stringValue];
        
        NSTimeInterval _interval=[CurrentTimeStamp doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
        
        if([message wasDelayed])
        {
            _interval= [[message delayedDeliveryDate] timeIntervalSince1970];
            date = [NSDate dateWithTimeIntervalSince1970:_interval];
        }
        
        NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"dd/MM/yyyy"];
        NSString *dateStr = [formatter stringFromDate:date];
        
        NSString *msgVal = body;
        //        NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
        //        NSString *msgVal = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
        
        //NSString *msgVal = [body stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        ChatConversation *chatObj = [NSEntityDescription insertNewObjectForEntityForName:@"ChatConversation"
                                                                  inManagedObjectContext:self.managedObjectContext_chatMessage];
        [self playBuzzSound];
        [chatObj setFileName:@""];
        [chatObj setFileUrl:@""];
        [chatObj setHasMedia:@(NO)];
        [chatObj setIsMessageReceived:@YES];
        [chatObj setIsNew:@YES];
        [chatObj setLocalFilePath:@""];
        [chatObj setMessageBody:msgVal];
        [chatObj setMessageDateTime:date];
        [chatObj setMessageDate:dateStr];
        [chatObj setMessageTime:@""];
        [chatObj setMessageStatus:@""];
        [chatObj setMimeType:@""];
        [chatObj setSenderId:self.username];
        [chatObj setReceiverId:[[message from] user]];
        [chatObj setMessageId:messageID];
        [chatObj setMessageType:OUT_BOUND_MESSAGE_TYPE_CHAT];
        //[chatObj setSenderUserName:UName];
        
        NSError *error;
        
        if (![self.managedObjectContext_chatMessage save:&error])
        {
            NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        }
        
        //[self.delegate newMessageReceived];
        
        
        if ([self.delegate respondsToSelector:@selector(newMessageReceivedFrom:withChatObj:)])
        {
            //[self.delegate newMessageReceivedFrom:[[message from] user]];
            [self.delegate newMessageReceivedFrom:[[message from] user] withChatObj:chatObj];
        }
        else
        {
            [self displayNavigationNotificationForChatObj:chatObj];
            
            
        }
        
    }
    else if([message isGroupChatMessageWithSubject])
    {
        NSString *subject = [[message elementForName:@"subject"] stringValue];
        NSString *subjectID = [[message attributeForName:@"id"] stringValue];
        
        [self playBuzzSound];
        NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatConversation"  inManagedObjectContext:context];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"senderId == %@ && receiverId == %@ && messageId == %@", self.username, [[message from] user], subjectID];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entityDescription];
        [fetchRequest setPredicate:predicate];
        
        NSError * error = nil;
        
        NSArray *fetchedResults = [context executeFetchRequest:fetchRequest error:&error];
        
        if([fetchedResults count]>0)
        {
            fetchRequest = nil;
            return;
        }
        
        fetchRequest = nil;
        
        
        NSData *data = [subject dataUsingEncoding:NSUTF8StringEncoding];
        NSString *subjectVal = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
        
        //NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
        
        UserInfo *existingGroupInfo = [self getGroupInfoForID:[[message from] user]];
        
        //ChatConversation *lastSubjectInfo = [self getGroupSubjectConversationInfoForID:[[message from] user]];
        
        if(existingGroupInfo)
        {
            if(![existingGroupInfo.user_name isEqualToString:subjectVal] /*|| lastSubjectInfo == nil*/)
            {
                NSTimeInterval _interval=[CurrentTimeStamp doubleValue];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
                
                if([message wasDelayed])
                {
                    _interval= [[message delayedDeliveryDate] timeIntervalSince1970];
                    date = [NSDate dateWithTimeIntervalSince1970:_interval];
                }
                
                NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
                [formatter setDateFormat:@"dd/MM/yyyy"];
                NSString *dateStr = [formatter stringFromDate:date];
                
                
                NSString *msgVal = [NSString stringWithFormat:@"Subject changed to \"%@\"",subject];
                
                NSData *data = [msgVal dataUsingEncoding:NSUTF8StringEncoding];
                msgVal = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
                
                //NSString *msgVal = [body stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                /*ChatConversation *chatObj = [NSEntityDescription insertNewObjectForEntityForName:@"ChatConversation" inManagedObjectContext:context];
                 
                 [chatObj setFileName:@""];
                 [chatObj setFileUrl:@""];
                 [chatObj setHasMedia:@(NO)];
                 [chatObj setIsMessageReceived:@(NO)];
                 [chatObj setIsNew:@(NO)];
                 [chatObj setLocalFilePath:@""];
                 [chatObj setMessageBody:msgVal];
                 [chatObj setMessageDateTime:date];
                 [chatObj setMessageDate:dateStr];
                 [chatObj setMessageTime:@""];
                 [chatObj setMessageStatus:@""];
                 [chatObj setMimeType:@""];
                 [chatObj setSenderId:self.username];
                 [chatObj setReceiverId:[[message from] user]];
                 [chatObj setMessageId:subjectID];
                 [chatObj setMessageType:GROUP_MESSAGE_TYPE_SUBJECT_CHANGE];
                 [chatObj setIsGroupMessage:@(YES)];
                 
                 */
            }
            
            [existingGroupInfo setUser_name:subjectVal];
            
            NSError *error;
            
            if (![context save:&error])
            {
                DLog(@"Failed to update user info - error: %@", [error localizedDescription]);
            }
            
            if ([self.delegate respondsToSelector:@selector(newMessageReceivedFrom:withChatObj:)])
            {
                //[self.delegate newMessageReceivedFrom:[[message from] user]];
                [self.delegate newMessageReceivedFrom:[[message from] user] withChatObj:nil];
            }
        }
        else
        {
            NSTimeInterval _interval=[CurrentTimeStamp doubleValue];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
            
            if([message wasDelayed])
            {
                _interval= [[message delayedDeliveryDate] timeIntervalSince1970];
                date = [NSDate dateWithTimeIntervalSince1970:_interval];
            }
            
            NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"dd/MM/yyyy"];
            NSString *dateStr = [formatter stringFromDate:date];
            
            
            NSString *msgVal = [NSString stringWithFormat:@"Subject changed to \"%@\"",subject];
            
            NSData *data = [msgVal dataUsingEncoding:NSUTF8StringEncoding];
            msgVal = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
            
            //NSString *msgVal = [body stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            /*ChatConversation *chatObj = [NSEntityDescription insertNewObjectForEntityForName:@"ChatConversation" inManagedObjectContext:context];
             
             [chatObj setFileName:@""];
             [chatObj setFileUrl:@""];
             [chatObj setHasMedia:@(NO)];
             [chatObj setIsMessageReceived:@(NO)];
             [chatObj setIsNew:@(NO)];
             [chatObj setLocalFilePath:@""];
             [chatObj setMessageBody:msgVal];
             [chatObj setMessageDateTime:date];
             [chatObj setMessageDate:dateStr];
             [chatObj setMessageTime:@""];
             [chatObj setMessageStatus:@""];
             [chatObj setMimeType:@""];
             [chatObj setSenderId:self.username];
             [chatObj setReceiverId:[[message from] user]];
             [chatObj setMessageId:subjectID];
             [chatObj setMessageType:GROUP_MESSAGE_TYPE_SUBJECT_CHANGE];
             [chatObj setIsGroupMessage:@(YES)];*/
            
            
            
            UserInfo *groupInfoObj = [NSEntityDescription insertNewObjectForEntityForName:@"UserInfo" inManagedObjectContext:context];
            
            [groupInfoObj setLogged_user_phone_number:self.username];
            [groupInfoObj setPhone_number:[[message from] user]];
            [groupInfoObj setUser_name:subjectVal];
            [groupInfoObj setIsGroup:@(YES)];
            //[userInfoObj setUser_id:@""];
            
            NSError *error;
            
            if (![context save:&error])
            {
                DLog(@"Failed to insert user info - error: %@", [error localizedDescription]);
            }
            
            if ([self.delegate respondsToSelector:@selector(newMessageReceivedFrom:withChatObj:)])
            {
                //[self.delegate newMessageReceivedFrom:[[message from] user]];
                [self.delegate newMessageReceivedFrom:[[message from] user] withChatObj:nil];
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_CHAT_LIST_NOTIFICATION object:nil];
    }
    else if([[[message attributeForName:@"type"] stringValue] isEqualToString:@"fileSent"])
    {
        NSString *messageID = [[message attributeForName:@"id"] stringValue];
        
        
        NSArray *fetchedObjects;
        NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatConversation"  inManagedObjectContext:context];
        NSString * predicteString = [NSString stringWithFormat:@"messageId == '%@'  AND hasMedia == 1", messageID];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicteString];
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        [fetch setEntity:entityDescription];
        [fetch setPredicate:predicate];
        NSError * error = nil;
        fetchedObjects = [context executeFetchRequest:fetch error:&error];
        
        if([fetchedObjects count] == 1)
        {
            ChatConversation *chatObj = (ChatConversation *)[fetchedObjects objectAtIndex:0];
            
            [chatObj setIsPending:@(NO)];
            
            NSError *error;
            
            if (![[XmppHelper sharedInstance].managedObjectContext_chatMessage save:&error])
            {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewMsgRecived object:nil];
}

- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender;
{
    /*NSData *data = [@"This is a test broadcast from testgroup" dataUsingEncoding:NSNonLossyASCIIStringEncoding];
     NSString *msgVal = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
     
     
     NSString *messageID=[[XmppHelper sharedInstance] generateUniqueID];
     
     NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
     [body setStringValue:msgVal];
     
     XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithString:@"+911234567890_012c763f-5ea2-44a2-94b5-f7d9fc3d31c3@groupchat.server9.weetechsolution.com@broadcast.server9.weetechsolution.com"] elementID:messageID child:body];
     [self.xmppStream sendElement:message];*/
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterPush:(XMPPIQ *)iq
{
    
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(NSXMLElement *)item
{
    
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    //NSLog(@"presence req: %@", presence);
    
    NSString *presenceType = [presence type];
    NSString *presenceStatus = [[presence status] lowercaseString];
    NSString *presenceFromUser = [[presence from] user];
    
    if (![presenceFromUser isEqualToString:[[xmppStream myJID] user]])
    {
        if ([presenceStatus isEqualToString:@"online"] || [presenceType isEqualToString:@"available"])
        {
            
            //[xmppRoster addUser:[XMPPJID jidWithString:[self getActualUsernameForUser:presenceFromUser]] withNickname:nil groups:@[@"TestGroup123"]];
            
            
            /*NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
             [item addAttributeWithName:@"jid" stringValue:@"+918885555512@server9.weetechsolution.com"];
             
             //for (NSString *group in groups) {
             NSXMLElement *groupElement = [NSXMLElement elementWithName:@"group"];
             [groupElement setStringValue:@"Test_1234567890"];
             [item addChild:groupElement];
             //}
             
             NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
             [query addChild:item];
             
             NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
             [iq addAttributeWithName:@"type" stringValue:@"set"];
             [iq addChild:query];
             
             [xmppStream sendElement:iq];*/
            
            
            
            NSPredicate *searchPred = [NSPredicate predicateWithFormat:
                                       [NSString stringWithFormat:@"user CONTAINS '%@'",[self getActualUsernameForUser:[[presence from] user]]]];
            NSArray *foundUser = [self.presenceArray filteredArrayUsingPredicate:searchPred];
            
            for(NSDictionary *dict in foundUser)
            {
                [self.presenceArray removeObject:dict];
            }
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[presence from] forKey:@"JID"];
            [dict setObject:[[presence from] full] forKey:@"user"];
            [self.presenceArray addObject:dict];
            dict = nil;
            
            //if ([presenceType isEqualToString:@"available"] || [presenceType isEqualToString:@"subscribe"])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:USER_IS_ONLINE_OFFLINE_NOTIFICATION object:presenceFromUser];
                
                if([self.delegate respondsToSelector:@selector(userCameOnline:)])
                {
                    [self.delegate userCameOnline:presenceFromUser];
                }
            }
            
        }
        else if([presenceStatus isEqualToString:@"offline"] || [presenceType isEqualToString:@"unavailable"])
        {
            NSPredicate *searchPred = [NSPredicate predicateWithFormat:
                                       [NSString stringWithFormat:@"user CONTAINS '%@'",[[presence from] full]]];
            NSArray *foundUser = [self.presenceArray filteredArrayUsingPredicate:searchPred];
            
            for(NSDictionary *dict in foundUser)
            {
                [self.presenceArray removeObject:dict];
            }
            
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:USER_IS_ONLINE_OFFLINE_NOTIFICATION object:presenceFromUser];
            
            if([self.delegate respondsToSelector:@selector(userWentOffline:)])
            {
                [self.delegate userWentOffline:presenceFromUser];
            }
        }
        else if ([[presenceType lowercaseString] isEqualToString:@"unsubscribed"])
        {
            /*NSManagedObjectContext *moc = self.managedObjectContext_chatMessage;
             
             NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChatConversation"
             inManagedObjectContext:moc];
             
             NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"messageDateTime" ascending:YES];
             
             NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
             
             NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
             [fetchRequest setEntity:entity];
             [fetchRequest setSortDescriptors:sortDescriptors];
             [fetchRequest setFetchBatchSize:5];
             
             
             
             NSPredicate *predicate = [NSPredicate predicateWithFormat:@"senderId == %@ AND receiverId == %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"of_username"], presenceFromUser];
             [fetchRequest setPredicate:predicate];
             
             
             
             
             NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
             managedObjectContext:moc
             sectionNameKeyPath:nil
             cacheName:nil];
             
             NSError *error = nil;
             if (![fetchedResultsController performFetch:&error])
             {
             NSLog(@"Error performing fetch: %@", error);
             }
             
             
             NSManagedObjectContext *context = self.managedObjectContext_chatMessage;
             
             NSArray *tempAr = [fetchedResultsController fetchedObjects];
             
             for (ChatConversation *chatObj in tempAr)
             {
             [context deleteObject:chatObj];
             }
             NSError *saveError = nil;
             [context save:&saveError];*/
            
            
            [self removeUserFromRosterForUser:presenceFromUser];
        }
        else if ([[presenceType lowercaseString] isEqualToString:@"unsubscribe"])
        {
            [self removeUserFromRosterForUser:presenceFromUser];
        }
    }
    else
    {
        //[xmppLastActivity sendLastActivityQueryToJID:xmppStream.myJID];
    }
    
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
   // DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
  //  DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    [self.presenceArray removeAllObjects];
    
    for(NSString *keyStr in [self.rooms allKeys])
    {
        XMPPRoom *xmppRoom = [self.rooms objectForKey:keyStr];
        [xmppRoom removeDelegate:self delegateQueue:dispatch_get_main_queue()];
        [xmppRoom deactivate];
    }
    [self.rooms removeAllObjects];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPP_DSCONNECTED_NOTIFICATION object:nil];
    
    if([self.delegate respondsToSelector:@selector(xmppChatDisconnected)])
    {
        [self.delegate xmppChatDisconnected];
    }
    
    if (!isXmppConnected)
    {
        DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
    }
}



- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    DLog(@"IQ := %@",iq);
    
    NSString *type = [iq type];
    if ([type isEqualToString:@"result"])
    {
        NSXMLElement *query = [iq elementForName:@"query"];
        
        if (query != nil)
        {
            
            if ([[query xmlns] isEqualToString:@"http://jabber.org/protocol/disco#items"] && [[iq from] isServer] && [[iq fromStr] isEqualToString:self.groupChatDomainStr])
            {
                [self updateRoomListWithIQ:iq];
            }
            
        }
    }
    
    return YES;
}


-(NSString *)outOfBandTypeFromMessage:(XMPPMessage *)message
{
    NSString *typeString = nil;
    
    NSXMLElement *outOfBand = [message elementForName:@"x" xmlns:@"jabber:x:oob"];
    
    NSXMLElement *typeElement = [outOfBand elementForName:@"messageType"];
    
    typeString = [typeElement stringValue];
    
    return typeString;
    
}

-(NSString *)outOfBandURLPathFromMessage:(XMPPMessage *)message
{
    NSString *typeString = nil;
    
    NSXMLElement *outOfBand = [message elementForName:@"x" xmlns:@"jabber:x:oob"];
    
    NSXMLElement *typeElement = [outOfBand elementForName:@"url"];
    
    typeString = [typeElement stringValue];
    
    return typeString;
    
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    DLog(@"Sent Message := %@", message);
    
    //NSString *messageTypeStr = [self outOfBandTypeFromMessage:message];
    
    NSString *msgId = [[message attributeForName:@"id"] stringValue];
    if(![self checkMessageIsSendAlready:msgId])
    {
        if ([message isChatMessageWithBody] && ([[message body] isEqualToString:BlockingMessageStr] || [[message body] isEqualToString:UnblockingMessageStr]))
        {
            if([[message body] isEqualToString:BlockingMessageStr])
            {
                [self updateUserBlockingFlag:YES forUser:[[message to] user] withLoggedInUser:[[message from] user]];
            }
            else
            {
                [self updateUserBlockingFlag:NO forUser:[[message to] user] withLoggedInUser:[[message from] user]];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_CHAT_LIST_NOTIFICATION object:nil];
            
            return;
        }
        
        /*if ([message isChatMessageWithBody] && ([[message body] isEqualToString:BlockingMessageStr] || [[message body] isEqualToString:UnblockingMessageStr]))
         {
         
         return;
         }*/
        
        
        //Change #define XMLNS_OUT_OF_BAND @"jabber:iq:oob" to #define XMLNS_OUT_OF_BAND @"jabber:x:oob" in this method's class
        if([message hasOutOfBandData])
        {
            
            
            NSTimeInterval _interval=[CurrentTimeStamp doubleValue];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
            
            if([message wasDelayed])
            {
                _interval= [[message delayedDeliveryDate] timeIntervalSince1970];
                date = [NSDate dateWithTimeIntervalSince1970:_interval];
            }
            
            NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"dd/MM/yyyy"];
            NSString *dateStr = [formatter stringFromDate:date];
            
            
            if(/*[body isEqualToString:FileSentString] ||*/ [message hasReceiptResponse])
                return;
            
            NSString *messageTypeStr = [self outOfBandTypeFromMessage:message];
            NSString *messageID = [[message attributeForName:@"id"] stringValue];
            NSString *fileURl = [self outOfBandURLPathFromMessage:message];
            NSXMLElement *outOfBand = [message elementForName:@"x" xmlns:@"jabber:x:oob"];
            
            
            if([messageTypeStr isEqualToString:OUT_BOUND_MESSAGE_TYPE_IMAGE] || [messageTypeStr isEqualToString:OUT_BOUND_MESSAGE_TYPE_AUDIO] || [messageTypeStr isEqualToString:OUT_BOUND_MESSAGE_TYPE_VIDEO])
            {
                NSString *mimeStr = [[outOfBand elementForName:@"mime-type"] stringValue];
                NSString *captionStr = [[outOfBand elementForName:@"caption"] stringValue];
                
                
                ChatConversation *chatObj = [NSEntityDescription insertNewObjectForEntityForName:@"ChatConversation"
                                                                          inManagedObjectContext:self.managedObjectContext_chatMessage];
                
                [chatObj setFileName:@""];
                [chatObj setFileUrl:@""];
                [chatObj setHasMedia:@YES];
                [chatObj setIsMessageReceived:@(NO)];
                [chatObj setIsNew:@(NO)];
                [chatObj setMessageDateTime:date];
                [chatObj setMessageDate:dateStr];
                [chatObj setMessageTime:@""];
                [chatObj setMessageStatus:@""];
                [chatObj setMessageBody:captionStr];
                //[chatObj setImageOpenTime:@(IMAGE_VIWE_TIME)];
                [chatObj setMimeType:mimeStr];
                //[chatObj setFileUrl:[message outOfBandURI]];
                [chatObj setFileUrl:fileURl];
                [chatObj setFileData:nil];
                [chatObj setThumbnailData:nil];
                [chatObj setSenderId:self.xmppStream.myJID.user];
                [chatObj setReceiverId:[[message to] user]];
                [chatObj setMessageId:messageID];
                [chatObj setMessageType:messageTypeStr];
                [chatObj setIsPending:@YES];
                
                
                if([message isGroupChatMessage])
                {
                    [chatObj setOccupantId:self.xmppStream.myJID.user];
                    [chatObj setIsGroupMessage:@(YES)];
                }
                
                
                NSError *error;
                
                if (![self.managedObjectContext_chatMessage save:&error])
                {
                    NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                }
                
                
                if ([self.delegate respondsToSelector:@selector(refreshChatMessageTableForChatObj:)])
                {
                    [self.delegate refreshChatMessageTableForChatObj:chatObj];
                }
                else
                {
                    [self displayNavigationNotificationForChatObj:chatObj];
                }
            }
            else if([messageTypeStr isEqualToString:OUT_BOUND_MESSAGE_TYPE_BUZZ])
            {
                //[self playBuzzSound];
                
                ChatConversation *chatObj = [NSEntityDescription insertNewObjectForEntityForName:@"ChatConversation"
                                                                          inManagedObjectContext:self.managedObjectContext_chatMessage];
                
                [chatObj setFileName:@""];
                [chatObj setFileUrl:@""];
                [chatObj setHasMedia:@NO];
                [chatObj setIsMessageReceived:@(NO)];
                [chatObj setIsNew:@(NO)];
                [chatObj setMessageDateTime:date];
                [chatObj setMessageDate:dateStr];
                [chatObj setMessageTime:@""];
                [chatObj setMessageStatus:@""];
                [chatObj setMessageBody:@"Smash"];
                //[chatObj setImageOpenTime:@(IMAGE_VIWE_TIME)];
                [chatObj setMimeType:nil];
                [chatObj setFileUrl:[message outOfBandURI]];
                [chatObj setFileData:nil];
                [chatObj setThumbnailData:nil];
                [chatObj setSenderId:self.xmppStream.myJID.user];
                [chatObj setReceiverId:[[message to] user]];
                [chatObj setMessageId:messageID];
                [chatObj setMessageType:messageTypeStr];
                [chatObj setIsPending:@(YES)];
                
                
                if([message isGroupChatMessage])
                {
                    [chatObj setOccupantId:self.xmppStream.myJID.user];
                    [chatObj setIsGroupMessage:@(YES)];
                }
                
                
                NSError *error;
                
                if (![self.managedObjectContext_chatMessage save:&error])
                {
                    NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                }
                
                if ([self.delegate respondsToSelector:@selector(refreshChatMessageTableForChatObj:)])
                {
                    [self.delegate refreshChatMessageTableForChatObj:chatObj];
                }
                else
                {
                    [self displayNavigationNotificationForChatObj:chatObj];
                }
            }
            else if([messageTypeStr isEqualToString:OUT_BOUND_MESSAGE_TYPE_VCARD])
            {
                NSString *firstnameStr = [[outOfBand elementForName:@"firstName"] stringValue];
                NSString *lastnameStr = [[outOfBand elementForName:@"lastName"] stringValue];
                NSString *phoneNumberStr = [[outOfBand elementForName:@"phoneNumber"] stringValue];
                NSString *emailStr = [[outOfBand elementForName:@"email"] stringValue];
                NSString *avatarStr = [[outOfBand elementForName:@"avatar"] stringValue];
                
                NSDictionary *contactDict = @{@"firstName" : firstnameStr,
                                              @"lastName" : lastnameStr,
                                              @"phoneNumber" : phoneNumberStr,
                                              @"email" : emailStr,
                                              @"avatar" : avatarStr};
                
                NSString *contactStr = [self convertDictionaryToString:contactDict];
                
                
                ChatConversation *chatObj = [NSEntityDescription insertNewObjectForEntityForName:@"ChatConversation"
                                                                          inManagedObjectContext:self.managedObjectContext_chatMessage];
                
                [chatObj setFileName:@""];
                [chatObj setFileUrl:@""];
                [chatObj setHasMedia:@NO];
                [chatObj setIsMessageReceived:@(NO)];
                [chatObj setIsNew:@(NO)];
                [chatObj setMessageDateTime:date];
                [chatObj setMessageDate:dateStr];
                [chatObj setMessageTime:@""];
                [chatObj setMessageStatus:@""];
                [chatObj setMessageBody:contactStr];
                //[chatObj setImageOpenTime:@(IMAGE_VIWE_TIME)];
                [chatObj setMimeType:nil];
                [chatObj setFileUrl:[message outOfBandURI]];
                [chatObj setFileData:nil];
                [chatObj setThumbnailData:nil];
                [chatObj setSenderId:self.xmppStream.myJID.user];
                [chatObj setReceiverId:[[message to] user]];
                [chatObj setMessageId:messageID];
                [chatObj setMessageType:messageTypeStr];
                [chatObj setIsPending:@(YES)];
                
                
                if([message isGroupChatMessage])
                {
                    [chatObj setOccupantId:self.xmppStream.myJID.user];
                    [chatObj setIsGroupMessage:@(YES)];
                }
                
                
                NSError *error;
                
                if (![self.managedObjectContext_chatMessage save:&error])
                {
                    NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                }
                
                
                if ([self.delegate respondsToSelector:@selector(refreshChatMessageTableForChatObj:)])
                {
                    [self.delegate refreshChatMessageTableForChatObj:chatObj];
                }
                else
                {
                    [self displayNavigationNotificationForChatObj:chatObj];
                }
            }
            else if([messageTypeStr isEqualToString:OUT_BOUND_MESSAGE_TYPE_LOCATION])
            {
                NSString *latitudeStr = [[outOfBand elementForName:@"latitude"] stringValue];
                NSString *longitudeStr = [[outOfBand elementForName:@"longitude"] stringValue];
                
                NSDictionary *locationDict = @{@"latitude" : latitudeStr,
                                               @"longitude" : longitudeStr};
                
                
                
                NSString *locationStr = [self convertDictionaryToString:locationDict];
                
                
                ChatConversation *chatObj = [NSEntityDescription insertNewObjectForEntityForName:@"ChatConversation"
                                                                          inManagedObjectContext:self.managedObjectContext_chatMessage];
                
                [chatObj setFileName:@""];
                [chatObj setFileUrl:@""];
                [chatObj setHasMedia:@NO];
                [chatObj setIsMessageReceived:@(NO)];
                [chatObj setIsNew:@(NO)];
                [chatObj setMessageDateTime:date];
                [chatObj setMessageDate:dateStr];
                [chatObj setMessageTime:@""];
                [chatObj setMessageStatus:@""];
                [chatObj setMessageBody:locationStr];
                //[chatObj setImageOpenTime:@(IMAGE_VIWE_TIME)];
                [chatObj setMimeType:nil];
                [chatObj setFileUrl:[message outOfBandURI]];
                [chatObj setFileData:nil];
                [chatObj setThumbnailData:nil];
                [chatObj setSenderId:self.xmppStream.myJID.user];
                [chatObj setReceiverId:[[message to] user]];
                [chatObj setMessageId:messageID];
                [chatObj setMessageType:messageTypeStr];
                [chatObj setIsPending:@(YES)];
                
                
                if([message isGroupChatMessage])
                {
                    [chatObj setOccupantId:self.xmppStream.myJID.user];
                    [chatObj setIsGroupMessage:@(YES)];
                }
                
                
                NSError *error;
                
                if (![self.managedObjectContext_chatMessage save:&error])
                {
                    NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                }
                
                
                if ([self.delegate respondsToSelector:@selector(refreshChatMessageTableForChatObj:)])
                {
                    [self.delegate refreshChatMessageTableForChatObj:chatObj];
                }
                else
                {
                    [self displayNavigationNotificationForChatObj:chatObj];
                }
            }
            
            
            
            return;
        }
        
        
        if([message isChatMessageWithBody])
        {
            NSString *body = [[message elementForName:@"body"] stringValue];
            
            if(/*[body isEqualToString:FileSentString] ||*/ [message hasReceiptResponse])
                return;
            
            NSTimeInterval _interval=[[Utility getCurrentTimeStampStr] doubleValue];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
            
            NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"dd/MM/yyyy"];
            NSString *dateStr = [formatter stringFromDate:date];
            
            
            //NSString *msgVal = [body stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            //        NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
            //        NSString *msgVal = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
            
            NSString *msgVal = body;
            
            ChatConversation *chatObj = [NSEntityDescription insertNewObjectForEntityForName:@"ChatConversation" inManagedObjectContext:[XmppHelper sharedInstance].managedObjectContext_chatMessage];
            
            [chatObj setFileName:@""];
            [chatObj setFileUrl:@""];
            [chatObj setHasMedia:@(NO)];
            [chatObj setIsMessageReceived:@(NO)];
            [chatObj setIsNew:@(NO)];
            [chatObj setLocalFilePath:@""];
            [chatObj setMessageBody:msgVal];
            [chatObj setMessageDateTime:date];
            [chatObj setMessageDate:dateStr];
            [chatObj setMessageStatus:@""];
            [chatObj setMimeType:@""];
            [chatObj setSenderId:self.xmppStream.myJID.user];
            [chatObj setReceiverId:[[message to] user]];
            [chatObj setMessageId:[[message attributeForName:@"id"] stringValue]];
            [chatObj setIsPending:@YES];
            [chatObj setMessageType:OUT_BOUND_MESSAGE_TYPE_CHAT];
            
            NSError *error;
            
            if (![[XmppHelper sharedInstance].managedObjectContext_chatMessage save:&error])
            {
                DLog(@"Failed to save - error: %@", [error localizedDescription]);
            }
            
            
            if ([self.delegate respondsToSelector:@selector(refreshChatMessageTableForChatObj:)])
            {
                [self.delegate refreshChatMessageTableForChatObj:chatObj];
            }
            else
            {
                [self displayNavigationNotificationForChatObj:chatObj];
            }
        }
    }
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error
{
    DLog(@"Failed to send message = %@",error);
    DLog(@"Failed to send message = %@",error);
    NSMutableArray *arrMessage = [[NSMutableArray alloc]init];
    NSData *dataMsg = [kPref objectForKey:kPendingMessage];
    [arrMessage addObjectsFromArray:[NSKeyedUnarchiver unarchiveObjectWithData:dataMsg]];
    [arrMessage addObject:message];
    
    NSData *dataMsg2 = [NSKeyedArchiver archivedDataWithRootObject:arrMessage];
    [kPref setObject:dataMsg2 forKey:kPendingMessage];
    
    [self failTOSendMessageArray:message error:error];
}


- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    NSLog(@"presence req: %@", presence);
    
    // a buddy went offline/online
    
    NSString *presenceType = [presence type];            // online/offline
    NSString *presenceFromUser = [[presence from] user];
    NSString *presenceStatus = [[presence status] lowercaseString];
    
    if(![presenceFromUser isEqualToString:[[xmppStream myJID] user]])
    {
        
        if([presenceStatus isEqualToString:@"online"] || [presenceType isEqualToString:@"available"])
        {
            [xmppRoster acceptPresenceSubscriptionRequestFrom:[XMPPJID jidWithString:[self getActualUsernameForUser:presenceFromUser]] andAddToRoster:YES];
            
        }
        else if([presenceStatus isEqualToString:@"offline"] || [presenceType isEqualToString:@"unavailable"])
        {
            
        }
        else if([presenceType isEqualToString:@"subscribe"])
        {
            [xmppRoster acceptPresenceSubscriptionRequestFrom:[XMPPJID jidWithString:[self getActualUsernameForUser:presenceFromUser]] andAddToRoster:YES];
        }
        else if([presenceType isEqualToString:@"unsubscribed"])
        {
            [self removeUserFromRosterForUser:presenceFromUser];
        }
        else if([presenceType isEqualToString:@"remove"])
        {
            [self removeUserFromRosterForUser:presenceFromUser];
        }
    }
}


- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp forJID:(XMPPJID *)jid
{
    DLog(@"vCardTemp jid = %@", jid.full);
}

- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule
{
    DLog(@"xmppvCardTempModuleDidUpdateMyvCard = %@", vCardTempModule.myvCardTemp);
}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToUpdateMyvCard:(NSXMLElement *)error
{
    DLog(@"xmppvCardTempModuleDidUpdateMyvCard = %@ && error = %@", vCardTempModule.myvCardTemp, error);
}

#pragma mark ----------------Fail to send-----------------------
-(void)failTOSendMessageArray:(XMPPMessage *)message error:(NSError *)error
{
    if ([message isChatMessageWithBody] && ([[message body] isEqualToString:BlockingMessageStr] || [[message body] isEqualToString:UnblockingMessageStr]))
    {
        if([[message body] isEqualToString:BlockingMessageStr])
        {
            [self updateUserBlockingFlag:YES forUser:[[message to] user] withLoggedInUser:[[message from] user]];
        }
        else
        {
            [self updateUserBlockingFlag:NO forUser:[[message to] user] withLoggedInUser:[[message from] user]];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_CHAT_LIST_NOTIFICATION object:nil];
        
        return;
    }
    
    /*if ([message isChatMessageWithBody] && ([[message body] isEqualToString:BlockingMessageStr] || [[message body] isEqualToString:UnblockingMessageStr]))
     {
     
     return;
     }*/
    
    
    //Change #define XMLNS_OUT_OF_BAND @"jabber:iq:oob" to #define XMLNS_OUT_OF_BAND @"jabber:x:oob" in this method's class
    if([message hasOutOfBandData])
    {
        
        
        NSTimeInterval _interval=[CurrentTimeStamp doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
        
        if([message wasDelayed])
        {
            _interval= [[message delayedDeliveryDate] timeIntervalSince1970];
            date = [NSDate dateWithTimeIntervalSince1970:_interval];
        }
        
        NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"dd/MM/yyyy"];
        NSString *dateStr = [formatter stringFromDate:date];
        
        
        if(/*[body isEqualToString:FileSentString] ||*/ [message hasReceiptResponse])
            return;
        
        NSString *messageTypeStr = [self outOfBandTypeFromMessage:message];
        NSString *messageID = [[message attributeForName:@"id"] stringValue];
        NSString *fileURl = [self outOfBandURLPathFromMessage:message];
        NSXMLElement *outOfBand = [message elementForName:@"x" xmlns:@"jabber:x:oob"];
        
        
        if([messageTypeStr isEqualToString:OUT_BOUND_MESSAGE_TYPE_IMAGE] || [messageTypeStr isEqualToString:OUT_BOUND_MESSAGE_TYPE_AUDIO] || [messageTypeStr isEqualToString:OUT_BOUND_MESSAGE_TYPE_VIDEO])
        {
            NSString *mimeStr = [[outOfBand elementForName:@"mime-type"] stringValue];
            NSString *captionStr = [[outOfBand elementForName:@"caption"] stringValue];
            
            
            ChatConversation *chatObj = [self retriveChatConcersation:messageID];
            //[chatObj setIsSendMSg:@YES];
            //[chatObj setIsOnceSend:@YES];
            
            NSError *error;
            
            if (![self.managedObjectContext_chatMessage save:&error])
            {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }
            
            if ([self.delegate respondsToSelector:@selector(refreshChatMessageTableForChatObj:)])
            {
                [self.delegate refreshChatMessageTableForChatObj:chatObj];
            }
            else
            {
                [self displayNavigationNotificationForChatObj:chatObj];
            }
        }
        else if([messageTypeStr isEqualToString:OUT_BOUND_MESSAGE_TYPE_BUZZ])
        {
            //[self playBuzzSound];
            
            ChatConversation *chatObj = [NSEntityDescription insertNewObjectForEntityForName:@"ChatConversation"
                                                                      inManagedObjectContext:self.managedObjectContext_chatMessage];
            
            [chatObj setFileName:@""];
            [chatObj setFileUrl:@""];
            [chatObj setHasMedia:@NO];
            [chatObj setIsMessageReceived:@(NO)];
            [chatObj setIsNew:@(NO)];
            [chatObj setMessageDateTime:date];
            [chatObj setMessageDate:dateStr];
            [chatObj setMessageTime:@""];
            [chatObj setMessageStatus:@""];
            [chatObj setMessageBody:@"Smash"];
            //[chatObj setImageOpenTime:@(IMAGE_VIWE_TIME)];
            [chatObj setMimeType:nil];
            [chatObj setFileUrl:[message outOfBandURI]];
            [chatObj setFileData:nil];
            [chatObj setThumbnailData:nil];
            [chatObj setSenderId:self.xmppStream.myJID.user];
            [chatObj setReceiverId:[[message to] user]];
            [chatObj setMessageId:messageID];
            [chatObj setMessageType:messageTypeStr];
            [chatObj setIsPending:@(YES)];
            
            
            if([message isGroupChatMessage])
            {
                [chatObj setOccupantId:self.xmppStream.myJID.user];
                [chatObj setIsGroupMessage:@(YES)];
            }
            
            
            NSError *error;
            
            if (![self.managedObjectContext_chatMessage save:&error])
            {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }
            
            if ([self.delegate respondsToSelector:@selector(refreshChatMessageTableForChatObj:)])
            {
                [self.delegate refreshChatMessageTableForChatObj:chatObj];
            }
            else
            {
                [self displayNavigationNotificationForChatObj:chatObj];
            }
        }
        else if([messageTypeStr isEqualToString:OUT_BOUND_MESSAGE_TYPE_VCARD])
        {
            NSString *firstnameStr = [[outOfBand elementForName:@"firstName"] stringValue];
            NSString *lastnameStr = [[outOfBand elementForName:@"lastName"] stringValue];
            NSString *phoneNumberStr = [[outOfBand elementForName:@"phoneNumber"] stringValue];
            NSString *emailStr = [[outOfBand elementForName:@"email"] stringValue];
            NSString *avatarStr = [[outOfBand elementForName:@"avatar"] stringValue];
            
            NSDictionary *contactDict = @{@"firstName" : firstnameStr,
                                          @"lastName" : lastnameStr,
                                          @"phoneNumber" : phoneNumberStr,
                                          @"email" : emailStr,
                                          @"avatar" : avatarStr};
            
            NSString *contactStr = [self convertDictionaryToString:contactDict];
            
            
            ChatConversation *chatObj = [NSEntityDescription insertNewObjectForEntityForName:@"ChatConversation"
                                                                      inManagedObjectContext:self.managedObjectContext_chatMessage];
            
            [chatObj setFileName:@""];
            [chatObj setFileUrl:@""];
            [chatObj setHasMedia:@NO];
            [chatObj setIsMessageReceived:@(NO)];
            [chatObj setIsNew:@(NO)];
            [chatObj setMessageDateTime:date];
            [chatObj setMessageDate:dateStr];
            [chatObj setMessageTime:@""];
            [chatObj setMessageStatus:@""];
            [chatObj setMessageBody:contactStr];
            //[chatObj setImageOpenTime:@(IMAGE_VIWE_TIME)];
            [chatObj setMimeType:nil];
            [chatObj setFileUrl:[message outOfBandURI]];
            [chatObj setFileData:nil];
            [chatObj setThumbnailData:nil];
            [chatObj setSenderId:self.xmppStream.myJID.user];
            [chatObj setReceiverId:[[message to] user]];
            [chatObj setMessageId:messageID];
            [chatObj setMessageType:messageTypeStr];
            [chatObj setIsPending:@(YES)];
            
            
            if([message isGroupChatMessage])
            {
                [chatObj setOccupantId:self.xmppStream.myJID.user];
                [chatObj setIsGroupMessage:@(YES)];
            }
            
            
            NSError *error;
            
            if (![self.managedObjectContext_chatMessage save:&error])
            {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }
            
            
            if ([self.delegate respondsToSelector:@selector(refreshChatMessageTableForChatObj:)])
            {
                [self.delegate refreshChatMessageTableForChatObj:chatObj];
            }
            else
            {
                [self displayNavigationNotificationForChatObj:chatObj];
            }
        }
        else if([messageTypeStr isEqualToString:OUT_BOUND_MESSAGE_TYPE_LOCATION])
        {
            NSString *latitudeStr = [[outOfBand elementForName:@"latitude"] stringValue];
            NSString *longitudeStr = [[outOfBand elementForName:@"longitude"] stringValue];
            
            NSDictionary *locationDict = @{@"latitude" : latitudeStr,
                                           @"longitude" : longitudeStr};
            
            
            
            NSString *locationStr = [self convertDictionaryToString:locationDict];
            
            
            ChatConversation *chatObj = [NSEntityDescription insertNewObjectForEntityForName:@"ChatConversation"
                                                                      inManagedObjectContext:self.managedObjectContext_chatMessage];
            
            [chatObj setFileName:@""];
            [chatObj setFileUrl:@""];
            [chatObj setHasMedia:@NO];
            [chatObj setIsMessageReceived:@(NO)];
            [chatObj setIsNew:@(NO)];
            [chatObj setMessageDateTime:date];
            [chatObj setMessageDate:dateStr];
            [chatObj setMessageTime:@""];
            [chatObj setMessageStatus:@""];
            [chatObj setMessageBody:locationStr];
            //[chatObj setImageOpenTime:@(IMAGE_VIWE_TIME)];
            [chatObj setMimeType:nil];
            [chatObj setFileUrl:[message outOfBandURI]];
            [chatObj setFileData:nil];
            [chatObj setThumbnailData:nil];
            [chatObj setSenderId:self.xmppStream.myJID.user];
            [chatObj setReceiverId:[[message to] user]];
            [chatObj setMessageId:messageID];
            [chatObj setMessageType:messageTypeStr];
            [chatObj setIsPending:@(YES)];
            
            
            if([message isGroupChatMessage])
            {
                [chatObj setOccupantId:self.xmppStream.myJID.user];
                [chatObj setIsGroupMessage:@(YES)];
            }
            
            
            NSError *error;
            
            if (![self.managedObjectContext_chatMessage save:&error])
            {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }
            
            
            if ([self.delegate respondsToSelector:@selector(refreshChatMessageTableForChatObj:)])
            {
                [self.delegate refreshChatMessageTableForChatObj:chatObj];
            }
            else
            {
                [self displayNavigationNotificationForChatObj:chatObj];
            }
        }
        
        return;
    }
    
    
    if([message isChatMessageWithBody])
    {
        NSString *body = [[message elementForName:@"body"] stringValue];
        
        if(/*[body isEqualToString:FileSentString] ||*/ [message hasReceiptResponse])
            return;
        
        NSTimeInterval _interval=[[Utility getCurrentTimeStampStr] doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
        
        NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"dd/MM/yyyy"];
        NSString *dateStr = [formatter stringFromDate:date];
        
        NSString *msgVal = body;
        
        
        ChatConversation *chatObj = [NSEntityDescription insertNewObjectForEntityForName:@"ChatConversation" inManagedObjectContext:[XmppHelper sharedInstance].managedObjectContext_chatMessage];
        
        [chatObj setFileName:@""];
        [chatObj setFileUrl:@""];
        [chatObj setHasMedia:@(NO)];
        [chatObj setIsMessageReceived:@(NO)];
        [chatObj setIsNew:@(NO)];
        [chatObj setLocalFilePath:@""];
        [chatObj setMessageBody:msgVal];
        [chatObj setMessageDateTime:date];
        [chatObj setMessageDate:dateStr];
        [chatObj setMessageStatus:@""];
        [chatObj setMimeType:@""];
        [chatObj setSenderId:self.xmppStream.myJID.user];
        [chatObj setReceiverId:[[message to] user]];
        [chatObj setMessageId:[[message attributeForName:@"id"] stringValue]];
        [chatObj setIsPending:@YES];
        [chatObj setMessageType:OUT_BOUND_MESSAGE_TYPE_CHAT];
        
        NSError *error;
        
        if (![[XmppHelper sharedInstance].managedObjectContext_chatMessage save:&error])
        {
            DLog(@"Failed to save - error: %@", [error localizedDescription]);
        }
        
        
        if ([self.delegate respondsToSelector:@selector(refreshChatMessageTableForChatObj:)])
        {
            [self.delegate refreshChatMessageTableForChatObj:chatObj];
        }
        else
        {
            [self displayNavigationNotificationForChatObj:chatObj];
        }
    }
    
    if([message isGroupChatMessage])
    {
        NSString *body = [[message elementForName:@"body"] stringValue];
        
        if(/*[body isEqualToString:FileSentString] ||*/ [message hasReceiptResponse])
            return;
        
        NSTimeInterval _interval=[[Utility getCurrentTimeStampStr] doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
        
        NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"dd/MM/yyyy"];
        NSString *dateStr = [formatter stringFromDate:date];
        
        
        //NSString *msgVal = [body stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        //NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
        //NSString *msgVal = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
        
        NSString *msgVal = body;
        
        ChatConversation *chatObj = [NSEntityDescription insertNewObjectForEntityForName:@"ChatConversation" inManagedObjectContext:[XmppHelper sharedInstance].managedObjectContext_chatMessage];
        
        [chatObj setFileName:@""];
        [chatObj setFileUrl:@""];
        [chatObj setHasMedia:@(NO)];
        [chatObj setIsMessageReceived:@(NO)];
        [chatObj setIsNew:@(NO)];
        [chatObj setLocalFilePath:@""];
        [chatObj setMessageBody:msgVal];
        [chatObj setMessageDateTime:date];
        [chatObj setMessageDate:dateStr];
        [chatObj setMessageStatus:@""];
        [chatObj setMimeType:@""];
        [chatObj setSenderId:self.xmppStream.myJID.user];
        [chatObj setReceiverId:[[message to] user]];
        [chatObj setMessageId:[[message attributeForName:@"id"] stringValue]];
        [chatObj setIsPending:@YES];
        [chatObj setMessageType:OUT_BOUND_MESSAGE_TYPE_CHAT];
        [chatObj setOccupantId:self.xmppStream.myJID.user];
        [chatObj setIsGroupMessage:@(YES)];
        
        NSError *error;
        
        if (![[XmppHelper sharedInstance].managedObjectContext_chatMessage save:&error])
        {
            DLog(@"Failed to save - error: %@", [error localizedDescription]);
        }
        
        
        if ([self.delegate respondsToSelector:@selector(refreshChatMessageTableForChatObj:)])
        {
            [self.delegate refreshChatMessageTableForChatObj:chatObj];
        }
        else
        {
            [self displayNavigationNotificationForChatObj:chatObj];
        }
    }
}

-(void)sendPendingMessage
{
    NSData *dataMsg = [kPref objectForKey:kPendingMessage];
    NSArray  *arrMessage = [NSKeyedUnarchiver unarchiveObjectWithData:dataMsg];
    
    if(arrMessage.count > 0)
    {
        for(int i = 0;i<arrMessage.count;i++)
        {
            [[[XmppHelper sharedInstance] xmppStream] sendElement:[arrMessage objectAtIndex:i]];
        }
    }
}

-(BOOL)checkMessageIsSendAlready:(NSString *)messgeId
{
    NSData *dataMsg = [kPref objectForKey:kPendingMessage];
    NSArray  *arrMessage = [NSKeyedUnarchiver unarchiveObjectWithData:dataMsg];
    NSMutableArray *arrMutableMessage = [[NSMutableArray alloc]init];
    arrMutableMessage = arrMessage.mutableCopy;
    
    for(int j = 0;j<arrMessage.count;j++)
    {
        XMPPMessage *message = [arrMessage objectAtIndex:j];
        NSString *messageID = [[message attributeForName:@"id"] stringValue];
        if([messageID isEqualToString:messgeId])
        {
            [arrMutableMessage removeObjectAtIndex:j];
            NSData *dataMsg2 = [NSKeyedArchiver archivedDataWithRootObject:arrMutableMessage];
            [kPref setObject:dataMsg2 forKey:kPendingMessage];
            return YES;
        }
    }
    return NO;
}

#pragma mark -----Get Chatconversation from message id -------

-(ChatConversation *)retriveChatConcersation:(NSString *)imageId
{
    NSArray *fetchedObjects;
    NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatConversation"  inManagedObjectContext:context];
    NSString * predicteString = [NSString stringWithFormat:@"messageId == '%@'", imageId];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicteString];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:predicate];
    NSError * error = nil;
    fetchedObjects = [context executeFetchRequest:fetch error:&error];
    
    ChatConversation *chatObj;
    
    if([fetchedObjects count] > 0)
    {
        chatObj = (ChatConversation *)[fetchedObjects objectAtIndex:0];
    }
    return chatObj;
}

#pragma mark - Last Activity

-(NSString *)getLastSeenTimeAgoStringFromSeconds:(NSUInteger)seconds
{
    NSString *timeAgoStr;
    
    NSInteger secondsInterval = (NSInteger)floor(seconds);
    NSInteger minutesInterval = (NSInteger)floor(seconds/60.0);
    NSInteger hoursInterval = (NSInteger)floor(seconds/(60.0*60.0));
    NSInteger daysInterval = (NSInteger)floor(seconds/(60.0*60.0*24.0));
    NSInteger weeksInterval = (NSInteger)floor(seconds/(60.0*60.0*24.0*7));
    NSInteger monthsInterval = (NSInteger)floor(seconds/(60.0*60.0*24.0*30));
    NSInteger yearsInterval = (NSInteger)floor(seconds/(60.0*60.0*24.0*30*365));
    
    NSString *period;
    
    if(secondsInterval<60)
    {
        period = (secondsInterval > 1) ? @"seconds" : @"second";
        timeAgoStr = [NSString stringWithFormat:@"%li %@ ago", (long)secondsInterval, period];
    }
    else if(minutesInterval<60)
    {
        period = (minutesInterval > 1) ? @"minutes" : @"minute";
        timeAgoStr = [NSString stringWithFormat:@"%li %@ ago", (long)minutesInterval, period];
    }
    else if(hoursInterval<24)
    {
        period = (hoursInterval > 1) ? @"hours" : @"hour";
        timeAgoStr = [NSString stringWithFormat:@"%li %@ ago", (long)hoursInterval, period];
    }
    else if(hoursInterval>=24 && hoursInterval<48)
    {
        timeAgoStr = [NSString stringWithFormat:@"Yesterday"];
    }
    else if(daysInterval<7)
    {
        period = (daysInterval > 1) ? @"days" : @"day";
        timeAgoStr = [NSString stringWithFormat:@"%li %@ ago", (long)daysInterval, period];
    }
    else if(monthsInterval<1)
    {
        period = (weeksInterval > 1) ? @"weeks" : @"week";
        timeAgoStr = [NSString stringWithFormat:@"%li %@ ago", (long)weeksInterval, period];
    }
    else if(monthsInterval<12)
    {
        period = (monthsInterval > 1) ? @"months" : @"month";
        timeAgoStr = [NSString stringWithFormat:@"%li %@ ago", (long)monthsInterval, period];
    }
    else
    {
        period = (yearsInterval > 1) ? @"years" : @"year";
        timeAgoStr = [NSString stringWithFormat:@"%li %@ ago", (long)yearsInterval, period];
    }
    
    return timeAgoStr;
}

-(void)getLastActivityForUser:(NSString *)phone_number
{
    [xmppLastActivity sendLastActivityQueryToJID:[XMPPJID jidWithString:[self getActualUsernameForUser:phone_number]]];
}

- (void)xmppLastActivity:(XMPPLastActivity *)sender didReceiveResponse:(XMPPIQ *)response
{
    DLog(@"last activity: %lu", (unsigned long)[response lastActivitySeconds]);
    DLog(@"response: %@", response);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPP_LAST_ACTIVITY_RECEIVED_NOTIFICATION object:response];
}

- (void)xmppLastActivity:(XMPPLastActivity *)sender didNotReceiveResponse:(NSString *)queryID dueToTimeout:(NSTimeInterval)timeout
{
    DLog(@"last activity timeout: %lu", (unsigned long)timeout);
}

/*- (NSUInteger)numberOfIdleTimeSecondsForXMPPLastActivity:(XMPPLastActivity *)sender queryIQ:(XMPPIQ *)iq currentIdleTimeSeconds:(NSUInteger)idleSeconds
 {
 
 }*/


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - XMPPMUCDelegate methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *)roomJID didReceiveInvitation:(XMPPMessage *)message
{
    DLog(@"didReceiveInvitation for roomJID = %@ && message = %@",roomJID, message);
    
    if([[message attributeForName:@"type"] stringValue] && [[[message attributeForName:@"type"] stringValue] isEqualToString:@"error"])
    {
        return;
    }
    
    
    NSXMLElement * x = [message elementForName:@"x" xmlns:XMPPMUCUserNamespace];
    NSXMLElement * invite  = [x elementForName:@"invite"];
    if (invite)
    {
        NSDictionary *loggedInUserDict = [NKeyChain objectForKey:@"wUserInfo"];
        NSString * conferenceRoomJID = [[message attributeForName:@"from"] stringValue];
        
        XMPPJID *jid = [XMPPJID jidWithString:conferenceRoomJID];
        
        
        
        
        
        /*NSDictionary *params = @{@"phone_number" : self.username,
         @"user_token" : loggedInUserDict[@"user_token"],
         @"group_ids" : jid.user,
         @"offset" : @"-1"};
         
         DLog(@"params = %@",params);
         
         AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
         
         [manager.operationQueue cancelAllOperations];
         [manager POST:API_FETCH_GROUPS_URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
         DLog(@"JSON: %@", responseObject);
         
         if([responseObject[@"status_code"] integerValue] == 1)
         {
         NSArray *groupInfoArr = responseObject[@"info"];
         
         for(NSDictionary *dict in groupInfoArr)
         {
         NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
         UserInfo *exitingGroupInfo = [self getGroupInfoForID:dict[@"group_id"]];
         
         //[[XmppHelper sharedInstance] addUserToRosterForUser:jidString];
         
         if(exitingGroupInfo == nil)
         {
         UserInfo *groupInfoObj = [NSEntityDescription insertNewObjectForEntityForName:@"UserInfo" inManagedObjectContext:context];
         
         [groupInfoObj setLogged_user_phone_number:self.username];
         [groupInfoObj setPhone_number:dict[@"group_id"]];
         [groupInfoObj setUser_name:dict[@"name"]];
         [groupInfoObj setProfile_pic:dict[@"image"]];
         [groupInfoObj setCover_pic:@""];
         //[groupInfoObj setIs_blocked:@(NO)];
         [groupInfoObj setIs_favourited:@(NO)];
         [groupInfoObj setIsGroup:@(YES)];
         //[userInfoObj setUser_id:@""];
         
         NSError *error;
         
         if (![context save:&error])
         {
         DLog(@"Failed to insert user info - error: %@", [error localizedDescription]);
         }
         }
         else
         {
         [exitingGroupInfo setProfile_pic:dict[@"image"]];
         
         NSError *error;
         
         if (![context save:&error])
         {
         DLog(@"Failed to update user info - error: %@", [error localizedDescription]);
         }
         }
         }
         }
         else if([responseObject[@"status_code"] integerValue] == 2)
         {
         [[AppDelegate sharedDelegate] logoutFromApplication];
         }
         
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         DLog(@"failed response string = %@",operation.responseString);
         
         //[Utility displayHttpFailureError:error];
         }];*/
        
        
        
        /*NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
         UserInfo *exitingGroupInfo = [self getGroupInfoForID:[jid user]];
         
         //[[XmppHelper sharedInstance] addUserToRosterForUser:jidString];
         
         if(exitingGroupInfo == nil)
         {
         UserInfo *groupInfoObj = [NSEntityDescription insertNewObjectForEntityForName:@"UserInfo" inManagedObjectContext:context];
         
         [groupInfoObj setLogged_user_phone_number:self.username];
         [groupInfoObj setPhone_number:[jid user]];
         [groupInfoObj setUser_name:@""];
         [groupInfoObj setProfile_pic:@""];
         [groupInfoObj setCover_pic:@""];
         [groupInfoObj setIs_blocked:@(NO)];
         [groupInfoObj setIs_favourited:@(NO)];
         [groupInfoObj setIsGroup:@(YES)];
         //[userInfoObj setUser_id:@""];
         
         NSError *error;
         
         if (![context save:&error])
         {
         DLog(@"Failed to insert user info - error: %@", [error localizedDescription]);
         }
         }*/
        
        [invitionsDict setObject:[NSString stringWithFormat:@"%@ joined this group", self.username] forKeyedSubscript:[jid user]];
        
        [self joinGroup:[jid user] withNickname:loggedInUserDict[@"user_name"]];
        
        /*//NSDictionary *loggedInUserDict = [NKeyChain objectForKey:@"wUserInfo"];
         [[XmppHelper sharedInstance] sendInfoMessageToGroupId:[jid user] withMessage:[NSString stringWithFormat:@"%@ joined this group", loggedInUserDict[@"user_name"]]];*/
        
    }
}

- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *)roomJID didReceiveInvitationDecline:(XMPPMessage *)message
{
    DLog(@"didReceiveInvitationDecline for roomJID = %@ && message = %@",roomJID, message);
}

- (void) getListOfGroups
{
    //[self.rooms removeAllObjects];
    
    intervalSinceLastLogout = 0;
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"lastLogoutTimeDict"])
    {
        NSDictionary *lastLogoutTimeDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastLogoutTimeDict"];
        
        if(lastLogoutTimeDict[self.xmppStream.myJID.user])
        {
            NSTimeInterval lastLogoutTimeInterval = [lastLogoutTimeDict[self.xmppStream.myJID.user] doubleValue];
            NSLog(@"%f",lastLogoutTimeInterval);
            intervalSinceLastLogout = [[NSDate date] timeIntervalSince1970] - lastLogoutTimeInterval;
        }
    }
    
    XMPPJID *servrJID = [XMPPJID jidWithString:self.groupChatDomainStr];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:servrJID];
    [iq addAttributeWithName:@"from" stringValue:[[self xmppStream] myJID].full];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/disco#items"];
    [iq addChild:query];
    [[self xmppStream] sendElement:iq];
    
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - XMPPMRoom
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


-(void)updateRoomListWithIQ:(XMPPIQ *)iq
{
    
    
    NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
    
    
    NSXMLElement *queryElement = [iq elementForName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
    NSArray *items = [queryElement elementsForName:@"item"];
    
    totalRoomFetched = items.count;
    roomItems = [[NSArray alloc] initWithArray:items];
    
    NSMutableArray *groupIdAr = [NSMutableArray array];
    
    if([items count]==0)
        return;
    
    //[[Global sharedInstance].arrGroup removeAllObjects];
    NSMutableArray *arrGroup=[[NSMutableArray alloc]init];
    for (NSXMLElement *roomElement in items)
    {
        NSString *roomName = [roomElement attributeStringValueForName:@"name"];
        NSString *jidString = [roomElement attributeStringValueForName:@"jid"];
        XMPPJID *jid = [XMPPJID jidWithString:jidString];
        
        [groupIdAr addObject:[jid user]];
        
        
        UserInfo *existingUserObj = [[XmppHelper sharedInstance] fetchGroupInfoObjectForID:[jid user]];
        
        if(existingUserObj==nil)
        {
            UserInfo *userObj = [NSEntityDescription insertNewObjectForEntityForName:@"UserInfo" inManagedObjectContext:context];
            
            [userObj setLogged_user_phone_number:[XmppHelper sharedInstance].username];
            [userObj setPhone_number:[jid user]];
            [userObj setIsGroup:@(YES)];
            
            NSError *error;
            
            if (![context save:&error])
            {
                DLog(@"Failed to insert user info - error: %@", [error localizedDescription]);
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_CHAT_LIST_NOTIFICATION object:nil];
        }
        
        
        /*UserInfo *exitingGroupInfo = [self getGroupInfoForID:[jid user]];
         
         //[[XmppHelper sharedInstance] addUserToRosterForUser:jidString];
         
         if(exitingGroupInfo == nil)
         {
         UserInfo *groupInfoObj = [NSEntityDescription insertNewObjectForEntityForName:@"UserInfo" inManagedObjectContext:context];
         
         [groupInfoObj setLogged_user_phone_number:self.username];
         [groupInfoObj setPhone_number:[jid user]];
         //[groupInfoObj setUser_name:roomName];
         [groupInfoObj setProfile_pic:@""];
         [groupInfoObj setCover_pic:@""];
         [groupInfoObj setIs_blocked:@(NO)];
         [groupInfoObj setIs_favourited:@(NO)];
         [groupInfoObj setIsGroup:@(YES)];
         //[userInfoObj setUser_id:@""];
         
         NSError *error;
         
         if (![context save:&error])
         {
         DLog(@"Failed to insert user info - error: %@", [error localizedDescription]);
         }
         }
         else
         {
         [exitingGroupInfo setLogged_user_phone_number:self.username];
         [exitingGroupInfo setPhone_number:[jid user]];
         //[exitingGroupInfo setUser_name:roomName];
         [exitingGroupInfo setProfile_pic:@""];
         [exitingGroupInfo setCover_pic:@""];
         [exitingGroupInfo setIs_blocked:@(NO)];
         [exitingGroupInfo setIs_favourited:@(NO)];
         [exitingGroupInfo setIsGroup:@(YES)];
         //[userInfoObj setUser_id:@""];
         
         NSError *error;
         
         if (![context save:&error])
         {
         DLog(@"Failed to update user info - error: %@", [error localizedDescription]);
         }
         }*/
        
        [self joinGroup:[jid user] withNickname:self.username];
        
        
        NSDictionary *dict=@{@"groupId":[jid user],@"groupName":roomName,@"nickName":roomName};
        
        [arrGroup addObject:dict];
        
    }
    
    [self deleteGroupIdsNotExistsInArray:groupIdAr];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_CHAT_LIST_NOTIFICATION object:arrGroup];
    
    //===========
    
    /*NSDictionary *params = @{@"phone_number" : self.username,
     @"user_token" : loggedInUserDict[@"user_token"],
     @"group_ids" : [groupIdAr componentsJoinedByString:@","],
     @"offset" : @"-1"};
     
     DLog(@"params = %@",params);
     
     AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
     
     [manager.operationQueue cancelAllOperations];
     [manager POST:API_FETCH_GROUPS_URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
     DLog(@"JSON: %@", responseObject);
     
     if([responseObject[@"status_code"] integerValue] == 1)
     {
     NSArray *groupInfoArr = responseObject[@"info"];
     
     for(NSDictionary *dict in groupInfoArr)
     {
     UserInfo *exitingGroupInfo = [self getGroupInfoForID:dict[@"group_id"]];
     
     //[[XmppHelper sharedInstance] addUserToRosterForUser:jidString];
     
     if(exitingGroupInfo == nil)
     {
     UserInfo *groupInfoObj = [NSEntityDescription insertNewObjectForEntityForName:@"UserInfo" inManagedObjectContext:context];
     
     [groupInfoObj setLogged_user_phone_number:self.username];
     [groupInfoObj setPhone_number:dict[@"group_id"]];
     //[groupInfoObj setUser_name:roomName];
     [groupInfoObj setProfile_pic:dict[@"image"]];
     [groupInfoObj setCover_pic:@""];
     //[groupInfoObj setIs_blocked:@(NO)];
     [groupInfoObj setIs_favourited:@(NO)];
     [groupInfoObj setIsGroup:@(YES)];
     //[userInfoObj setUser_id:@""];
     
     NSError *error;
     
     if (![context save:&error])
     {
     DLog(@"Failed to insert user info - error: %@", [error localizedDescription]);
     }
     }
     else
     {
     [exitingGroupInfo setProfile_pic:dict[@"image"]];
     
     NSError *error;
     
     if (![context save:&error])
     {
     DLog(@"Failed to update user info - error: %@", [error localizedDescription]);
     }
     }
     }
     }
     else if([responseObject[@"status_code"] integerValue] == 2)
     {
     [[AppDelegate sharedDelegate] logoutFromApplication];
     }
     
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     DLog(@"failed response string = %@",operation.responseString);
     
     //[Utility displayHttpFailureError:error];
     }];*/
    
    //===========
    
    
    
    groupIdAr = nil;
    
    //[self createNewGroupWithName:@"New Test Group" withNickname:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_CHAT_LIST_NOTIFICATION object:nil];
    
    intervalSinceLastLogout = 0;
}

-(void)deleteGroupIdsNotExistsInArray:(NSArray *)groupIdAr
{
    NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UserInfo"  inManagedObjectContext:context];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"logged_user_phone_number == %@ && isGroup == 1 && not (phone_number IN %@)", self.username, groupIdAr];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setPredicate:predicate];
    
    NSError * error = nil;
    
    NSArray *fetchedResults = [context executeFetchRequest:fetchRequest error:&error];
    
    fetchRequest = nil;
    
    NSMutableArray *nonExistGroupIdAr = [NSMutableArray array];
    
    for(UserInfo *userInfo in fetchedResults)
    {
        [nonExistGroupIdAr addObject:userInfo.phone_number];
        [context deleteObject:userInfo];
    }
    NSError *saveError = nil;
    [context save:&saveError];
    
    if([fetchedResults count]>0)
    {
        [self deleteCoversationWithGroupIds:nonExistGroupIdAr];
    }
    
    nonExistGroupIdAr = nil;
    groupIdAr = nil;
    fetchedResults = nil;
}


-(void)deleteCoversationWithGroupIds:(NSArray *)groupIdAr
{
    NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatConversation"  inManagedObjectContext:context];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"senderId == %@ && isGroupMessage == 1 && (receiverId IN %@)", self.username, groupIdAr];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setPredicate:predicate];
    
    NSError * error = nil;
    
    NSArray *fetchedResults = [context executeFetchRequest:fetchRequest error:&error];
    
    fetchRequest = nil;
    
    for(ChatConversation *chatObj in fetchedResults)
    {
        if([chatObj.messageType isEqualToString:OUT_BOUND_MESSAGE_TYPE_IMAGE] || [chatObj.messageType isEqualToString:OUT_BOUND_MESSAGE_TYPE_AUDIO] || [chatObj.messageType isEqualToString:OUT_BOUND_MESSAGE_TYPE_VIDEO])
        {
            [self deleteFileFromDownloadFileDirectory:[chatObj.fileUrl lastPathComponent]];
            
            /*NSString *filePath = [[self getLocalDownloadFileDirectory] stringByAppendingPathComponent:[chatObj.fileUrl lastPathComponent]];
             
             // if no directory was provided, we look by default in the base cached dir
             if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
             {
             [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
             }*/
            
            if([chatObj.mimeType isEqualToString:@"image/jpeg"])
            {
                
            }
            else
            {
                
            }
        }
        
        [context deleteObject:chatObj];
    }
    NSError *saveError = nil;
    [context save:&saveError];
}

-(void)deleteGroupIdsFromUserInfo:(NSArray *)groupIdAr
{
    NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UserInfo"  inManagedObjectContext:context];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"logged_user_phone_number == %@ && (phone_number IN %@) && isGroup == 1", self.username, groupIdAr];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setPredicate:predicate];
    
    NSError * error = nil;
    
    NSArray *fetchedResults = [context executeFetchRequest:fetchRequest error:&error];
    
    fetchRequest = nil;
    
    for(UserInfo *userInfoObj in fetchedResults)
    {
        [context deleteObject:userInfoObj];
    }
    NSError *saveError = nil;
    [context save:&saveError];
}


-(UserInfo *)getGroupInfoForID:(NSString *)groupID
{
    NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UserInfo"  inManagedObjectContext:context];
    
    NSString * predicteString = [NSString stringWithFormat:@"logged_user_phone_number == '%@' && phone_number == '%@' && isGroup == 1", self.username, groupID];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicteString];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    
    NSError * error = nil;
    
    NSArray *fetchedResults = [context executeFetchRequest:fetchRequest error:&error];
    
    fetchRequest = nil;
    
    if([fetchedResults count]>0)
    {
        return [fetchedResults objectAtIndex:0];
    }
    
    return nil;
}

-(ChatConversation *)getGroupSubjectConversationInfoForID:(NSString *)groupID
{
    NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatConversation"  inManagedObjectContext:context];
    
    NSString * predicteString = [NSString stringWithFormat:@"senderId == '%@' && receiverId == '%@' && isGroupMessage == 1 && messageType == '%@'", self.username, groupID, GROUP_MESSAGE_TYPE_SUBJECT_CHANGE];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicteString];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"messageDateTime" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    
    NSError * error = nil;
    
    NSArray *fetchedResults = [context executeFetchRequest:fetchRequest error:&error];
    
    fetchRequest = nil;
    
    if([fetchedResults count]>0)
    {
        return [fetchedResults objectAtIndex:0];
    }
    
    return nil;
}


- (void)changeRoomSubject:(NSString *)newRoomSubject forRoomId:(NSString *)roomId withSendMsg:(BOOL)isSendMessage
{
    // Todo
    
    if (newRoomSubject == nil) return;
    
    
    NSData *data = [newRoomSubject dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    NSString *msgVal = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    
    NSString *subjectID=[[XmppHelper sharedInstance] generateUniqueID];
    
    NSXMLElement *subject = [NSXMLElement elementWithName:@"subject"];
    [subject setStringValue:msgVal];
    
    
    NSString *JIDStr = [[XmppHelper sharedInstance] getActualGroupIDForRoom:roomId];
    XMPPJID *roomJID = [XMPPJID jidWithString:JIDStr];
    
    XMPPMessage *message = [XMPPMessage messageWithType:@"groupchat" to:roomJID elementID:subjectID child:subject];
    
    
    [[[XmppHelper sharedInstance] xmppStream] sendElement:message];
    
    if(isSendMessage)
    {
        [self sendInfoMessageToGroupId:roomId withMessage:[NSString stringWithFormat:@"%@ changed the subject to \"%@\"", self.username, msgVal]];
    }
    
}


#pragma mark Create Room/Group
-(void)createNewGroupWithName:(NSString *)groupName withMemberLists:(NSArray *)memberAr
{
    [[AppDelegate sharedDelegate].window addSubview:progessLoading];
    [progessLoading show:YES];
    
    groupMemberArrayToAdd = memberAr;
    groupNameStr = [groupName copy];
    groupChatIdStr = [[NSString stringWithFormat:@"%@_%@", self.xmppStream.myJID.user,[self generateUniqueID]] copy];
    
    [self joinGroup:groupChatIdStr withNickname:self.xmppStream.myJID.user];
}

-(void)createNewGroupWithId:(NSString *)groupId name:(NSString *)groupName withMemberLists:(NSArray *)memberAr
{
    [[AppDelegate sharedDelegate].window addSubview:progessLoading];
    [progessLoading show:YES];
    
    groupMemberArrayToAdd = memberAr;
    groupNameStr = [groupName copy];
    groupChatIdStr = [groupId copy];
    
    [self joinGroup:groupChatIdStr withNickname:self.xmppStream.myJID.user];
}

-(void)joinGroup:(NSString *)roomID withNickname:(NSString *)name
{
    //[[AppDelegate sharedDelegate].window addSubview:progessLoading];
    //[progessLoading show:YES];
    
    XMPPRoomMemoryStorage * _roomMemory = [[XMPPRoomMemoryStorage alloc]init];
    XMPPJID * roomJID = [XMPPJID jidWithString:[self getActualGroupIDForRoom:roomID]];
    XMPPRoom* xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:_roomMemory
                                                           jid:roomJID
                                                 dispatchQueue:dispatch_get_main_queue()];
    
    [xmppRoom activate:self.xmppStream];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    //NSLog(@"%f",intervalSinceLastLogout);
    NSXMLElement *history = [NSXMLElement elementWithName:@"history"];
    [history addAttributeWithName:@"seconds" stringValue:[NSString stringWithFormat:@"%ld", (long)intervalSinceLastLogout]];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [xmppRoom joinRoomUsingNickname:self.xmppStream.myJID.user history:history password:COMMON_ROOM_PASSWORD];
    });
    
}

- (BOOL)configureWithParent:(XMPPRoom *)aParent queue:(dispatch_queue_t)queue
{
    DLog(@"configureWithParent");
    return NO;
}

- (void)handlePresence:(XMPPPresence *)presence room:(XMPPRoom *)room
{
    DLog(@"handlePresence");
}


- (void)handleIncomingMessage:(XMPPMessage *)message room:(XMPPRoom *)room
{
    DLog(@"handleIncomingMessage");
}

- (void)handleOutgoingMessage:(XMPPMessage *)message room:(XMPPRoom *)room
{
    DLog(@"handleOutgoingMessage");
}

- (void)handleDidLeaveRoom:(XMPPRoom *)room
{
    DLog(@"handleDidLeaveRoom");
}


#pragma mark XMPPRoom Delegate methods

- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    DLog(@"xmppRoomDidCreate = %@",sender);
    
    if([self.delegate respondsToSelector:@selector(youHaveJoinedRoom:)])
    {
        [self.delegate youHaveJoinedRoom:sender];
    }
    
    [self.rooms setObject:sender forKey:sender.roomJID.user];
    
    NSString *subjectStr = groupNameStr;
    
    [self changeRoomSubject:groupNameStr forRoomId:sender.roomJID.user withSendMsg:NO];
    
    [sender fetchConfigurationForm];
    
    
    if([groupMemberArrayToAdd count]>0 && [[sender.myRoomJID.user lowercaseString] isEqualToString:[groupChatIdStr lowercaseString]])
    {
        for(int i=0; i<[groupMemberArrayToAdd count]; i++)
        {
            [self inviteUser:[groupMemberArrayToAdd objectAtIndex:i] toRoom:sender.roomJID.user];
        }
        
        groupMemberArrayToAdd = nil;
        groupChatIdStr = nil;
        
        /*NSDictionary *loggedInUserDict = [NKeyChain objectForKey:@"wUserInfo"];
         [[XmppHelper sharedInstance] sendInfoMessageToGroupId:sender.roomJID.user withMessage:[NSString stringWithFormat:@"%@ created group \"%@\"", loggedInUserDict[@"user_name"], subjectStr]];*/
        
    }
    
    
    //[sender fetchMembersList];
    //[self configureThisRoom:sender];
    
    //[progessLoading hide:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPP_ROOM_CREATED_NOTIFICATION object:sender];
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    //progessLoading = [MBProgressHUD showHUDAddedTo:window animated:YES];
    progessLoading.labelText = @"Please Wait";
    
    //DLog(@"xmppRoomDidJoin = %@",sender);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if([self.delegate respondsToSelector:@selector(youHaveJoinedRoom:)])
        {
            [self.delegate youHaveJoinedRoom:sender];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:XMPP_ROOM_JOINED_NOTIFICATION object:sender];
        
        [self.rooms setObject:sender forKey:sender.roomJID.user];
        
        if(self.rooms.count>=totalRoomFetched)
        {
            BOOL allRoomsJoined = YES;
            
            for (NSXMLElement *roomElement in roomItems)
            {
                NSString *jidString = [roomElement attributeStringValueForName:@"jid"];
                XMPPJID *jid = [XMPPJID jidWithString: jidString];
                
                if(![self.rooms objectForKey:jid.user])
                {
                    allRoomsJoined = NO;
                    break;
                }
            }
            
            if(allRoomsJoined)
            {
                intervalSinceLastLogout = 0;
                [self performSelector:@selector(setRoomChatHistoryFetched:) withObject:@(YES) afterDelay:5.0];
            }
        }
        
        if([invitionsDict objectForKey:sender.roomJID.user])
        {
            [[XmppHelper sharedInstance] sendInfoMessageToGroupId:sender.roomJID.user withMessage:[invitionsDict objectForKey:sender.roomJID.user]];
            [invitionsDict removeObjectForKey:sender.roomJID.user];
        }
        
        UserInfo *existingUserObj = [[XmppHelper sharedInstance] fetchGroupInfoObjectForID:sender.roomJID.user];
        
        if(existingUserObj==nil)
        {
            NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
            
            UserInfo *userObj = [NSEntityDescription insertNewObjectForEntityForName:@"UserInfo" inManagedObjectContext:context];
            
            [userObj setLogged_user_phone_number:[XmppHelper sharedInstance].username];
            [userObj setPhone_number:sender.roomJID.user];
            [userObj setIsGroup:@(YES)];
            
            if([sender.roomSubject length]>0)
            {
                [userObj setUser_name:sender.roomSubject];
            }
            
            NSError *error;
            
            if (![context save:&error])
            {
                DLog(@"Failed to insert user info - error: %@", [error localizedDescription]);
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_CHAT_LIST_NOTIFICATION object:nil];
        }
        else
        {
            if([sender.roomSubject length]>0)
            {
                [existingUserObj setUser_name:sender.roomSubject];
            }
            
            NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
            
            NSError *error;
            
            if (![context save:&error])
            {
                DLog(@"Failed to insert user info - error: %@", [error localizedDescription]);
            }
        }
        
    });
    
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    //        if([self.delegate respondsToSelector:@selector(youHaveJoinedRoom:)])
    //        {
    //            [self.delegate youHaveJoinedRoom:sender];
    //        }
    //        [[NSNotificationCenter defaultCenter] postNotificationName:XMPP_ROOM_JOINED_NOTIFICATION object:sender];
    //
    //        [self.rooms setObject:sender forKey:sender.roomJID.user];
    //
    //        if(self.rooms.count>=totalRoomFetched)
    //        {
    //            BOOL allRoomsJoined = YES;
    //
    //            for (NSXMLElement *roomElement in roomItems)
    //            {
    //                NSString *jidString = [roomElement attributeStringValueForName:@"jid"];
    //                XMPPJID *jid = [XMPPJID jidWithString:jidString];
    //
    //                if(![self.rooms objectForKey:jid.user])
    //                {
    //                    allRoomsJoined = NO;
    //                    break;
    //                }
    //            }
    //
    //            if(allRoomsJoined)
    //            {
    //                intervalSinceLastLogout = 0;
    //                [self performSelector:@selector(setRoomChatHistoryFetched:) withObject:@(YES) afterDelay:5.0];
    //            }
    //        }
    //
    //        if([invitionsDict objectForKey:sender.roomJID.user])
    //        {
    //            [[XmppHelper sharedInstance] sendInfoMessageToGroupId:sender.roomJID.user withMessage:[invitionsDict objectForKey:sender.roomJID.user]];
    //            [invitionsDict removeObjectForKey:sender.roomJID.user];
    //        }
    //
    //        UserInfo *existingUserObj = [[XmppHelper sharedInstance] fetchGroupInfoObjectForID:sender.roomJID.user];
    //
    //        if(existingUserObj==nil)
    //        {
    //            NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
    //
    //            UserInfo *userObj = [NSEntityDescription insertNewObjectForEntityForName:@"UserInfo" inManagedObjectContext:context];
    //
    //            [userObj setLogged_user_phone_number:[XmppHelper sharedInstance].username];
    //            [userObj setPhone_number:sender.roomJID.user];
    //            [userObj setIsGroup:@(YES)];
    //
    //            if([sender.roomSubject length]>0)
    //            {
    //                [userObj setUser_name:sender.roomSubject];
    //            }
    //
    //            NSError *error;
    //
    //            if (![context save:&error])
    //            {
    //                DLog(@"Failed to insert user info - error: %@", [error localizedDescription]);
    //            }
    //
    //            [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_CHAT_LIST_NOTIFICATION object:nil];
    //        }
    //        else
    //        {
    //            if([sender.roomSubject length]>0)
    //            {
    //                [existingUserObj setUser_name:sender.roomSubject];
    //            }
    //
    //            NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
    //
    //            NSError *error;
    //
    //            if (![context save:&error])
    //            {
    //                DLog(@"Failed to insert user info - error: %@", [error localizedDescription]);
    //            }
    //        }
    //
    //    });
    
    
    
    /*NSDictionary *loggedInUserDict = [NKeyChain objectForKey:@"wUserInfo"];
     NSString *subject = sender.roomSubject;
     
     if(subject==nil)
     return;
     
     NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
     
     UserInfo *existingGroupInfo = [self getGroupInfoForID:sender.roomJID.user];
     
     ChatConversation *lastSubjectInfo = [self getGroupSubjectConversationInfoForID:sender.roomJID.user];
     
     if(existingGroupInfo)
     {
     if(![existingGroupInfo.user_name isEqualToString:subject] || lastSubjectInfo == nil)
     {
     NSTimeInterval _interval=[CurrentTimeStamp doubleValue];
     NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
     
     NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
     [formatter setDateFormat:@"dd/MM/yyyy"];
     NSString *dateStr = [formatter stringFromDate:date];
     
     NSString *msgVal = NSLocalizedString(@"subject_changed_value", nil);
     msgVal = [msgVal stringByReplacingOccurrencesOfString:@"$#SUBJECT#$" withString:subject];
     
     NSData *data = [msgVal dataUsingEncoding:NSUTF8StringEncoding];
     msgVal = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
     
     //NSString *msgVal = [body stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
     
     ChatConversation *chatObj = [NSEntityDescription insertNewObjectForEntityForName:@"ChatConversation" inManagedObjectContext:context];
     
     [chatObj setFileName:@""];
     [chatObj setFileUrl:@""];
     [chatObj setHasMedia:@(NO)];
     [chatObj setIsMessageReceived:@(NO)];
     [chatObj setIsNew:@(NO)];
     [chatObj setLocalFilePath:@""];
     [chatObj setMessageBody:msgVal];
     [chatObj setMessageDateTime:date];
     [chatObj setMessageDate:dateStr];
     [chatObj setMessageTime:@""];
     [chatObj setMessageStatus:@""];
     [chatObj setMimeType:@""];
     [chatObj setSenderId:self.username];
     [chatObj setReceiverId:sender.roomJID.user];
     [chatObj setMessageId:@""];
     [chatObj setMessageType:GROUP_MESSAGE_TYPE_SUBJECT_CHANGE];
     
     
     if ([self.delegate respondsToSelector:@selector(newMessageReceivedFrom:withChatObj:)])
     {
     [self.delegate newMessageReceivedFrom:sender.roomJID.user withChatObj:nil];
     }
     }
     
     [existingGroupInfo setUser_name:subject];
     
     NSError *error;
     
     if (![context save:&error])
     {
     DLog(@"Failed to update user info - error: %@", [error localizedDescription]);
     }
     }
     else
     {
     NSTimeInterval _interval=[CurrentTimeStamp doubleValue];
     NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
     
     NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
     [formatter setDateFormat:@"dd/MM/yyyy"];
     NSString *dateStr = [formatter stringFromDate:date];
     
     
     NSString *msgVal = NSLocalizedString(@"subject_changed_value", nil);
     msgVal = [msgVal stringByReplacingOccurrencesOfString:@"$#SUBJECT#$" withString:subject];
     
     NSData *data = [msgVal dataUsingEncoding:NSUTF8StringEncoding];
     msgVal = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
     
     //NSString *msgVal = [body stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
     
     ChatConversation *chatObj = [NSEntityDescription insertNewObjectForEntityForName:@"ChatConversation" inManagedObjectContext:context];
     
     [chatObj setFileName:@""];
     [chatObj setFileUrl:@""];
     [chatObj setHasMedia:@(NO)];
     [chatObj setIsMessageReceived:@(NO)];
     [chatObj setIsNew:@(NO)];
     [chatObj setLocalFilePath:@""];
     [chatObj setMessageBody:msgVal];
     [chatObj setMessageDateTime:date];
     [chatObj setMessageDate:dateStr];
     [chatObj setMessageTime:@""];
     [chatObj setMessageStatus:@""];
     [chatObj setMimeType:@""];
     [chatObj setSenderId:self.username];
     [chatObj setReceiverId:sender.roomJID.user];
     [chatObj setMessageId:@""];
     [chatObj setMessageType:GROUP_MESSAGE_TYPE_SUBJECT_CHANGE];
     
     
     
     UserInfo *groupInfoObj = [NSEntityDescription insertNewObjectForEntityForName:@"UserInfo" inManagedObjectContext:context];
     
     [groupInfoObj setLogged_user_phone_number:self.username];
     [groupInfoObj setPhone_number:sender.roomJID.user];
     [groupInfoObj setUser_name:subject];
     [groupInfoObj setProfile_pic:@""];
     [groupInfoObj setCover_pic:@""];
     [groupInfoObj setIs_blocked:@(NO)];
     [groupInfoObj setIs_favourited:@(NO)];
     [groupInfoObj setIsGroup:@(YES)];
     //[userInfoObj setUser_id:@""];
     
     NSError *error;
     
     if (![context save:&error])
     {
     DLog(@"Failed to insert user info - error: %@", [error localizedDescription]);
     }
     
     
     if ([self.delegate respondsToSelector:@selector(newMessageReceivedFrom:withChatObj:)])
     {
     [self.delegate newMessageReceivedFrom:sender.roomJID.user withChatObj:chatObj];
     }
     }*/
    
    
    
    //[sender fetchConfigurationForm];
    //[sender fetchMembersList];
    //[self configureThisRoom:sender];
    
    //UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    [MBProgressHUD hideHUDForView:window animated:YES];
    //[progessLoading hide:YES];
}

-(void)setRoomChatHistoryFetched:(id)fetched
{
    roomChatHistoryFetched = [fetched boolValue];
}

-(BOOL)isRoomChatHistoryFetched
{
    return roomChatHistoryFetched;
}


-(void)configureThisRoom:(XMPPRoom *)sender
{
    //configure the room
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
    //[x addAttributeWithName:@"type" stringValue:@"submit"];
    
    
    NSXMLElement *formType =[NSXMLElement elementWithName:@"field"];
    [formType addAttributeWithName:@"type" stringValue:@"hidden"];
    [formType addAttributeWithName:@"var"  stringValue:@"FORM_TYPE"];
    [formType addAttributeWithName:@"value" stringValue:@"http://jabber.org/protocol/muc#roomconfig"];
    
    if(groupNameStr==nil)
    {
        //
        NSXMLElement *namefield = [NSXMLElement elementWithName:@"field"];
        [namefield addAttributeWithName:@"type" stringValue:@"text-single"];
        [namefield addAttributeWithName:@"label" stringValue:@"Room Name"];
        [namefield addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roomname"];
        [namefield addAttributeWithName:@"value" stringValue:groupNameStr];
        
        [x addChild:namefield];
    }
    
    //
    NSXMLElement *subjectField = [NSXMLElement elementWithName:@"field"];
    [subjectField addAttributeWithName:@"type" stringValue:@"boolean"];
    [subjectField addAttributeWithName:@"label" stringValue:@"Allow Occupants to Change Subject"];
    [subjectField addAttributeWithName:@"var" stringValue:@"muc#roomconfig_changesubject"];
    [subjectField addAttributeWithName:@"value" stringValue:@"1"];
    
    //
    NSXMLElement *maxusersField = [NSXMLElement elementWithName:@"field"];
    [maxusersField addAttributeWithName:@"type" stringValue:@"text-single"];
    [maxusersField addAttributeWithName:@"label" stringValue:@"Maximum Room Occupants"];
    [maxusersField addAttributeWithName:@"var" stringValue:@"muc#roomconfig_maxusers"];
    [maxusersField addAttributeWithName:@"value" stringValue:@"100"];
    
    //
    NSXMLElement *publicroomfield = [NSXMLElement elementWithName:@"field"];
    [publicroomfield addAttributeWithName:@"type" stringValue:@"boolean"];
    [publicroomfield addAttributeWithName:@"label" stringValue:@"List Room in Directory"];
    [publicroomfield addAttributeWithName:@"var" stringValue:@"muc#roomconfig_publicroom"];
    [publicroomfield addAttributeWithName:@"value" stringValue:@"0"];
    
    //
    NSXMLElement *persistentroomfield = [NSXMLElement elementWithName:@"field"];
    [persistentroomfield addAttributeWithName:@"type" stringValue:@"boolean"];
    [persistentroomfield addAttributeWithName:@"label" stringValue:@"Room is Persistent"];
    [persistentroomfield addAttributeWithName:@"var" stringValue:@"muc#roomconfig_persistentroom"];
    [persistentroomfield addAttributeWithName:@"value" stringValue:@"1"];
    
    //
    NSXMLElement *moderatedfield = [NSXMLElement elementWithName:@"field"];
    [moderatedfield addAttributeWithName:@"type" stringValue:@"boolean"];
    [moderatedfield addAttributeWithName:@"label" stringValue:@"Room is Moderated"];
    [moderatedfield addAttributeWithName:@"var" stringValue:@"muc#roomconfig_moderatedroom"];
    [moderatedfield addAttributeWithName:@"value" stringValue:@"1"];
    
    //
    NSXMLElement *membersonlyField = [NSXMLElement elementWithName:@"field"];
    [membersonlyField addAttributeWithName:@"type" stringValue:@"boolean"];
    [membersonlyField addAttributeWithName:@"label" stringValue:@"Room is Members-only"];
    [membersonlyField addAttributeWithName:@"var" stringValue:@"muc#roomconfig_membersonly"];
    [membersonlyField addAttributeWithName:@"value" stringValue:@"1"];
    
    //
    NSXMLElement *ownerField = [NSXMLElement elementWithName:@"field"];
    [ownerField addAttributeWithName:@"type" stringValue:@"jid-multi"];
    [ownerField addAttributeWithName:@"label" stringValue:@"Room Owners"];
    [ownerField addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roomowners"];
    [ownerField addAttributeWithName:@"value" stringValue: self.xmppStream.myJID.bare];
    
    
    //
    NSXMLElement *passwordEnableField = [NSXMLElement elementWithName:@"field"];
    [passwordEnableField addAttributeWithName:@"type" stringValue:@"boolean"];
    //[membersonlyField addAttributeWithName:@"label" stringValue:@"Room is Members-only"];
    [passwordEnableField addAttributeWithName:@"var" stringValue:@"muc#roomconfig_passwordprotectedroom"];
    [passwordEnableField addAttributeWithName:@"value" stringValue:@"1"];
    
    
    //
    NSXMLElement *passwordScretField = [NSXMLElement elementWithName:@"field"];
    [passwordScretField addAttributeWithName:@"type" stringValue:@"text-private"];
    //[membersonlyField addAttributeWithName:@"label" stringValue:@"Room is Members-only"];
    [passwordScretField addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roomsecret"];
    [passwordScretField addAttributeWithName:@"value" stringValue:COMMON_ROOM_PASSWORD];
    
    
    
    [x addChild:formType];
    //[x addChild:namefield];
    [x addChild:subjectField];
    [x addChild:maxusersField];
    [x addChild:publicroomfield];
    [x addChild:persistentroomfield];
    [x addChild:moderatedfield];
    [x addChild:membersonlyField];
    [x addChild:ownerField];
    [x addChild:passwordEnableField];
    [x addChild:passwordScretField];
    
    groupNameStr = nil;
    [sender configureRoomUsingOptions:x];
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm
{
    DLog(@"didFetchConfigurationForm = %@", configForm);
    
    [[AppDelegate sharedDelegate].window addSubview:progessLoading];
    [progessLoading show:YES];
    
    NSXMLElement *newConfig = [configForm copy];
    NSArray *fields = [newConfig elementsForName:@"field"];
    for (NSXMLElement *field in fields) {
        NSString *var = [field attributeStringValueForName:@"var"];
        // Make Room Persistent
        if ([var isEqualToString:@"muc#roomconfig_persistentroom"])
        {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
        }
        
        if(groupNameStr!=nil && [var isEqualToString:@"muc#roomconfig_roomname"] && [[sender.myRoomJID.user lowercaseString] isEqualToString:[groupChatIdStr lowercaseString]])
        {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:groupNameStr]];
            groupNameStr = nil;
        }
        
        if([var isEqualToString:@"muc#roomconfig_passwordprotectedroom"])
        {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"0"]];
        }
        
        if([var isEqualToString:@"muc#roomconfig_roomsecret"])
        {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:COMMON_ROOM_PASSWORD]];
        }
        
        /*if([var isEqualToString:@"muc#roomconfig_roomname"])
         {
         NSArray *values = [field elementsForName:@"value"];
         NSXMLElement *value = (NSXMLElement *)[values objectAtIndex:0];
         [sender changeRoomSubject:[value stringValue]];
         }*/
    }
    [sender configureRoomUsingOptions:newConfig];
}

- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult
{
    DLog(@"didConfigure");
    
    groupNameStr = nil;
    
    [progessLoading hide:YES];
}

-(void)inviteUser:(NSString *)userChatId toRoom:(NSString *)roomId
{
    NSString *inviteMessageStr = @"You are added to this group.";
    NSString *jidStr = [self getActualGroupIDForRoom:roomId];
    
    
    NSXMLElement *invite = [NSXMLElement elementWithName:@"invite"];
    [invite addAttributeWithName:@"to" stringValue:[[XMPPJID jidWithString:[self getActualUsernameForUser:userChatId]] full]];
    
    if ([inviteMessageStr length] > 0)
    {
        [invite addChild:[NSXMLElement elementWithName:@"reason" stringValue:inviteMessageStr]];
    }
    
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:XMPPMUCUserNamespace];
    [x addChild:invite];
    
    XMPPMessage *message = [XMPPMessage message];
    [message addAttributeWithName:@"to" stringValue:[[XMPPJID jidWithString:jidStr] full]];
    [message addChild:x];
    
    [self.xmppStream sendElement:message];
}

-(void)removeUser:(NSString *)userChatId fromRoom:(NSString *)roomId
{
    NSString *inviteMessageStr = @"You have removed from this group.";
    NSString *jidStr = [self getActualGroupIDForRoom:roomId];
    
    
    NSXMLElement *remove = [NSXMLElement elementWithName:@"remove"];
    [remove addAttributeWithName:@"to" stringValue:[[XMPPJID jidWithString:[self getActualUsernameForUser:userChatId]] full]];
    
    if ([inviteMessageStr length] > 0)
    {
        [remove addChild:[NSXMLElement elementWithName:@"reason" stringValue:inviteMessageStr]];
    }
    
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:XMPPMUCUserNamespace];
    [x addChild:remove];
    
    XMPPMessage *message = [XMPPMessage message];
    [message addAttributeWithName:@"to" stringValue:[[XMPPJID jidWithString:jidStr] full]];
    [message addChild:x];
    
    [self.xmppStream sendElement:message];
}



- (void)xmppRoom:(XMPPRoom *)sender didNotConfigure:(XMPPIQ *)iqResult
{
    DLog(@"didNotConfigure");
    
    groupNameStr = nil;
    
    [progessLoading hide:YES];
}

- (void)xmppRoomDidLeave:(XMPPRoom *)sender
{
    DLog(@"xmppRoomDidLeave = %@",sender);
    
    [sender removeDelegate:self delegateQueue:dispatch_get_main_queue()];
    [sender deactivate];
    
    [self.rooms removeObjectForKey:sender.roomJID.user];
    
    sender=nil;
    
    [progessLoading hide:YES];
}

- (void)xmppRoomDidDestroy:(XMPPRoom *)sender
{
    DLog(@"xmppRoomDidDestroy = %@",sender);
    
    NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UserInfo"  inManagedObjectContext:context];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"logged_user_phone_number == %@ && isGroup == 1 && phone_number == %@", self.username, sender.roomJID.user];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setPredicate:predicate];
    
    NSError * error = nil;
    
    NSArray *fetchedResults = [context executeFetchRequest:fetchRequest error:&error];
    
    fetchRequest = nil;
    
    for(UserInfo *userInfo in fetchedResults)
    {
        [context deleteObject:userInfo];
    }
    NSError *saveError = nil;
    [context save:&saveError];
    
    
    [self deleteCoversationWithGroupIds:@[sender.roomJID.user]];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPP_ROOM_DESTROYED_NOTIFICATION object:sender];
    
    
    [sender removeDelegate:self delegateQueue:dispatch_get_main_queue()];
    [sender deactivate];
    
    [self.rooms removeObjectForKey:sender.roomJID.user];
    
    sender=nil;
    
    [progessLoading hide:YES];
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    DLog(@"room = %@ && occupantDidJoin = %@ && presence = %@",sender, occupantJID, presence);
    
    //    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    //    [MBProgressHUD hideHUDForView:window animated:YES];
    
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    DLog(@"room = %@ && occupantDidLeave = %@ && presence = %@",sender, occupantJID, presence);
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidUpdate:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    DLog(@"room = %@ && occupantDidUpdate = %@ && presence = %@",sender, occupantJID, presence);
}
- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID
{
    //DLog(@"room = %@ && didReceiveMessage = %@ && fromOccupant = %@",sender, message, [occupantJID resource]);
    
    if([message hasReceiptResponse] || [message hasOutOfBandData])
        return;
    
    if([message isGroupChatMessageWithBody])
    {
        //NSString *body = [[message elementForName:@"body"] stringValue];
        
        if(/*[body isEqualToString:FileSentString] ||*/ [message hasReceiptResponse])
            return;
        
        
        
        NSString *body = [[message elementForName:@"body"] stringValue];
        NSString *messageID = [[message attributeForName:@"id"] stringValue];
        
        NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
        NSString *msgVal = body;
        
        NSXMLElement *chatDetail = [message elementForName:@"chatDetail" xmlns:@"jabber:x:oob"];
        NSString *UName = [[chatDetail elementForName:@"username"] stringValue];
        
        ChatConversation *existingChatObj = [self getMessageConversationInfoForMessageID:messageID andReceiverId:[[occupantJID bareJID] user] forGroup:YES];
        
        if(existingChatObj==nil)
        {
            NSTimeInterval _interval=[CurrentTimeStamp doubleValue];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
            
            if([message wasDelayed])
            {
                _interval= [[message delayedDeliveryDate] timeIntervalSince1970];
                date = [NSDate dateWithTimeIntervalSince1970:_interval];
            }
            
            NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"dd/MM/yyyy"];
            NSString *dateStr = [formatter stringFromDate:date];
            
            
            ChatConversation *chatObj = [NSEntityDescription insertNewObjectForEntityForName:@"ChatConversation" inManagedObjectContext:[XmppHelper sharedInstance].managedObjectContext_chatMessage];
            
            [chatObj setFileName:@""];
            [chatObj setFileUrl:@""];
            [chatObj setHasMedia:@(NO)];
            if([[occupantJID resource] isEqualToString:self.xmppStream.myJID.user])
            {
                [chatObj setIsMessageReceived:@(NO)];
                [chatObj setIsNew:@(NO)];
            }
            else
            {
                [chatObj setIsMessageReceived:@(YES)];
                [chatObj setIsNew:@(YES)];
            }
            [chatObj setLocalFilePath:@""];
            [chatObj setMessageBody:msgVal];
            [chatObj setMessageDateTime:date];
            [chatObj setMessageDate:dateStr];
            [chatObj setMessageStatus:@""];
            [chatObj setMimeType:@""];
            [chatObj setSenderId:self.xmppStream.myJID.user];
            [chatObj setReceiverId:[[occupantJID bareJID] user]];
            [chatObj setMessageId:[[message attributeForName:@"id"] stringValue]];
            [chatObj setIsPending:@(YES)];
            [chatObj setIsGroupMessage:@(YES)];
            [chatObj setOccupantId:[occupantJID resource]];
            [chatObj setMessageType:OUT_BOUND_MESSAGE_TYPE_CHAT];
            [chatObj setSenderUserName:UName];
            NSError *error;
            
            if (![[XmppHelper sharedInstance].managedObjectContext_chatMessage save:&error])
            {
                DLog(@"Failed to save - error: %@", [error localizedDescription]);
            }
            
            
            if([[occupantJID resource] isEqualToString:self.xmppStream.myJID.user])
            {
                if ([self.delegate respondsToSelector:@selector(refreshChatMessageTableForChatObj:)])
                {
                    [self.delegate refreshChatMessageTableForChatObj:chatObj];
                }
            }
            else
            {
                if ([self.delegate respondsToSelector:@selector(newMessageReceivedFrom:withChatObj:)])
                {
                    //[self.delegate newMessageReceivedFrom:[[message from] user]];
                    [self.delegate newMessageReceivedFrom:[[message from] user] withChatObj:chatObj];
                }
                else
                {
                    [self displayNavigationNotificationForChatObj:chatObj];
                    
                    /*NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
                     NSEntityDescription *userEntityDescription = [NSEntityDescription entityForName:@"UserInfo"  inManagedObjectContext:context];
                     
                     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"logged_user_phone_number == %@ && phone_number == %@", [NKeyChain objectForKey:@"wUserInfo"][@"phone_number"], [[occupantJID bareJID] user]];
                     
                     NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
                     [fetch setEntity:userEntityDescription];
                     [fetch setPredicate:predicate];
                     
                     [fetch setResultType:NSDictionaryResultType];
                     
                     NSError *error = nil;
                     NSArray *tempAr = [context executeFetchRequest:fetch error:&error];
                     
                     if([tempAr count]==1)
                     {
                     UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
                     [window makeToast:[NSString stringWithFormat:@"%@: %@", [tempAr objectAtIndex:0][@"user_name"], body]];
                     }
                     else
                     {
                     UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
                     [window makeToast:@"You got a message."];
                     }*/
                }
            }
        }
    }
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchBanList:(NSArray *)items;
{
    DLog(@"room = %@ && didFetchBanList = %@",sender, items);
}

- (void)xmppRoom:(XMPPRoom *)sender didNotFetchBanList:(XMPPIQ *)iqError
{
    DLog(@"room = %@ && didNotFetchBanList = %@",sender, iqError);
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items
{
    DLog(@"room = %@ && didFetchMembersList = %@",sender, items);
    
    /*for (NSXMLElement *roomElement in items)
     {
     NSString *jidString = [roomElement attributeStringValueForName:@"jid"];
     XMPPJID *jid = [XMPPJID jidWithString:jidString];
     
     [xmppvCardTempModule fetchvCardTempForJID:jid ignoreStorage:YES];
     }*/
    
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPP_ROOM_MEMBER_LIST_FETCHED_NOTIFICATION object:sender userInfo:@{@"list" : items}];
}

- (void)xmppRoom:(XMPPRoom *)sender didNotFetchMembersList:(XMPPIQ *)iqError
{
    DLog(@"room = %@ && didNotFetchMembersList = %@",sender, iqError);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPP_ROOM_MEMBER_LIST_NOT_FETCHED_NOTIFICATION object:sender];
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items
{
    DLog(@"room = %@ && didFetchModeratorsList = %@",sender, items);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPP_ROOM_MODERATOR_LIST_FETCHED_NOTIFICATION object:sender userInfo:@{@"list" : items}];
}

- (void)xmppRoom:(XMPPRoom *)sender didNotFetchModeratorsList:(XMPPIQ *)iqError
{
    DLog(@"room = %@ && didNotFetchModeratorsList = %@",sender, iqError);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPP_ROOM_MODERATOR_LIST_NOT_FETCHED_NOTIFICATION object:sender];
}

- (void)xmppRoom:(XMPPRoom *)sender didEditPrivileges:(XMPPIQ *)iqResult
{
    DLog(@"room = %@ && didEditPrivileges = %@",sender, iqResult);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPP_ROOM_PRIVILEGES_EDITED_NOTIFICATION object:sender];
}

- (void)xmppRoom:(XMPPRoom *)sender didNotEditPrivileges:(XMPPIQ *)iqError
{
    DLog(@"room = %@ && didNotEditPrivileges = %@",sender, iqError);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPP_ROOM_PRIVILEGES_NOT_EDITED_NOTIFICATION object:sender];
}


-(ChatConversation *)getMessageConversationInfoForMessageID:(NSString *)messageId andReceiverId:(NSString *)receiverId forGroup:(BOOL)isGroupMessage
{
    NSManagedObjectContext *context = [XmppHelper sharedInstance].managedObjectContext_chatMessage;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChatConversation"  inManagedObjectContext:context];
    
    NSString * predicteString = [NSString stringWithFormat:@"senderId == '%@' && receiverId == '%@' && isGroupMessage == %@ && messageId == '%@'", self.username, receiverId, @(isGroupMessage), messageId];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicteString];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"messageDateTime" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    
    
    NSError * error = nil;
    
    NSArray *fetchedResults = [context executeFetchRequest:fetchRequest error:&error];
    
    fetchRequest = nil;
    
    if([fetchedResults count]>0)
    {
        return [fetchedResults objectAtIndex:0];
    }
    
    return nil;
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - COREDATA
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext_chatMessage;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)applicationLibraryDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectContext *)managedObjectContext_roster
{
    return [xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_chatMessage
{
    if (__managedObjectContext_chatMessage != nil)
    {
        return __managedObjectContext_chatMessage;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext_chatMessage = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext_chatMessage setPersistentStoreCoordinator:coordinator];
        [__managedObjectContext_chatMessage setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        // subscribe to change notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_mocDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return __managedObjectContext_chatMessage;
}
//

- (void)_mocDidSaveNotification:(NSNotification *)notification
{
    NSManagedObjectContext *savedContext = [notification object];
    
    // ignore change notifications for the main MOC
    if (__managedObjectContext_chatMessage == savedContext)
    {
        return;
    }
    
    if (__managedObjectContext_chatMessage.persistentStoreCoordinator != savedContext.persistentStoreCoordinator)
    {
        // that's another database
        return;
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        [__managedObjectContext_chatMessage mergeChangesFromContextDidSaveNotification:notification];
    });
}
//
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel_chatMessage != nil)
    {
        return __managedObjectModel_chatMessage;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"LOL_Vibe" withExtension:@"momd"];
    __managedObjectModel_chatMessage = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel_chatMessage;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationLibraryDirectory] URLByAppendingPathComponent:@"NesetChatConversation.sqlite"];   NSError *error = nil;
    
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return __persistentStoreCoordinator;
}

#pragma mark - Add message
-(void)addMessageToCoreData:(NSDictionary *)messageDict
{
    ChatConversation *chatObj = [NSEntityDescription insertNewObjectForEntityForName:@"ChatConversation"
                                                              inManagedObjectContext:self.managedObjectContext_chatMessage];
    
    [chatObj setFileName:messageDict[@""]];
    [chatObj setFileUrl:messageDict[@""]];
    [chatObj setHasMedia:messageDict[@""]];
    [chatObj setIsMessageReceived:messageDict[@""]];
    [chatObj setIsNew:messageDict[@""]];
    [chatObj setLocalFilePath:messageDict[@""]];
    [chatObj setMessageBody:messageDict[@""]];
    [chatObj setMessageDateTime:messageDict[@""]];
    [chatObj setMessageStatus:messageDict[@""]];
    [chatObj setMimeType:messageDict[@""]];
    [chatObj setSenderId:messageDict[@""]];
    [chatObj setReceiverId:messageDict[@""]];
    
    
    NSError *error;
    
    if (![self.managedObjectContext_chatMessage save:&error])
    {
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
    }
}




- (void)teardownStream
{
    [xmppStream removeDelegate:self];
    [xmppRoster removeDelegate:self];
    [xmppMUC     removeDelegate:self];
    
    [xmppRoster            deactivate];
    [xmppvCardTempModule   deactivate];
    [xmppvCardAvatarModule deactivate];
    [xmppReconnect         deactivate];
    /*[xmppCapabilities      deactivate];*/
    [xmppMUC     deactivate];
    
    [xmppStream disconnect];
    
    xmppStream = nil;
    xmppRoster = nil;
    xmppRosterStorage = nil;
    xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
    xmppvCardAvatarModule = nil;
    xmppReconnect = nil;
    /*xmppCapabilities = nil;
     xmppCapabilitiesStorage = nil;*/
    xmppMUC=nil;
}

- (void)dealloc
{
    [self teardownStream];
}


@end
