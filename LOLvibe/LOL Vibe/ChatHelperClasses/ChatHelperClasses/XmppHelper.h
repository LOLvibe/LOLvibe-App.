//
//  XmppHelper.h
//  nesetchat
//
//  Created by WeeTech Solution on 01/06/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "MBProgressHUD.h"
#import "Global.h"
#import "GlobalConstants.h"
#import "Utility.h"
#import "ServiceConstant.h"
#import "NKeyChain.h"

#define OUT_BOUND_MESSAGE_TYPE_CHAT                 @"chat"
#define OUT_BOUND_MESSAGE_TYPE_IMAGE                @"image"
#define OUT_BOUND_MESSAGE_TYPE_AUDIO                @"audio"
#define OUT_BOUND_MESSAGE_TYPE_VIDEO                @"video"
#define OUT_BOUND_MESSAGE_TYPE_BUZZ                 @"buzz"
#define OUT_BOUND_MESSAGE_TYPE_VCARD                @"vCard"
#define OUT_BOUND_MESSAGE_TYPE_LOCATION             @"location"
#define OUT_BOUND_MESSAGE_TYPE_REMOVED_FROM_GROUP   @"removed_from_group"
#define OUT_BOUND_MESSAGE_TYPE_INFO                 @"info"
#define OUT_BOUND_MESSAGE_TYPE_FILE                 @"file"

#define INFO_TYPE_GROUP_ICON_CHANGED                @"group_icon_changed"

#define GROUP_MESSAGE_TYPE_GROUP_CREATED        @"group_created"
#define GROUP_MESSAGE_TYPE_ADDED_TO_GROUP       @"added_to_group"
#define GROUP_MESSAGE_TYPE_REMOVED_FROM_GROUP   @"removed_from_group"
#define GROUP_MESSAGE_TYPE_LEFT_GROUP           @"left_group"
#define GROUP_MESSAGE_TYPE_SUBJECT_CHANGE       @"subject_changed"

#define LIST_MESSAGE_TYPE_LIST_CREATED          @"list_created"

#define USER_IS_ONLINE_OFFLINE_NOTIFICATION     @"USER_IS_ONLINE_OFFLINE_NOTIFICATION"
#define LOGGED_USER_IS_OFFLINE_NOTIFICATION     @"LOGGED_USER_IS_OFFLINE_NOTIFICATION"
#define XMPP_DSCONNECTED_NOTIFICATION           @"XMPP_DSCONNECTED_NOTIFICATION"
#define RELOAD_CHAT_LIST_NOTIFICATION           @"RELOAD_CHAT_LIST_NOTIFICATION"
#define XMPP_AUTHENTICATED_NOTIFICATION         @"XMPP_AUTHENTICATED_NOTIFICATION"
#define XMPP_UNAUTHENTICATED_NOTIFICATION       @"XMPP_UNAUTHENTICATED_NOTIFICATION"
#define XMPP_DID_RECEIVE_ERROR_NOTIFICATION     @"XMPP_DID_RECEIVE_ERROR_NOTIFICATION"
#define XMPP_ROOM_CREATED_NOTIFICATION          @"XMPP_ROOM_CREATED_NOTIFICATION"
#define XMPP_ROOM_JOINED_NOTIFICATION           @"XMPP_ROOM_JOINED_NOTIFICATION"

#define XMPP_ROOM_PRIVILEGES_EDITED_NOTIFICATION        @"XMPP_ROOM_PRIVILEGES_EDITED_NOTIFICATION"
#define XMPP_ROOM_PRIVILEGES_NOT_EDITED_NOTIFICATION    @"XMPP_ROOM_PRIVILEGES_NOT_EDITED_NOTIFICATION"

#define XMPP_ROOM_MEMBER_LIST_FETCHED_NOTIFICATION      @"XMPP_ROOM_MEMBER_LIST_FETCHED_NOTIFICATION"
#define XMPP_ROOM_MODERATOR_LIST_FETCHED_NOTIFICATION   @"XMPP_ROOM_MODERATOR_LIST_FETCHED_NOTIFICATION"

#define XMPP_ROOM_MEMBER_LIST_NOT_FETCHED_NOTIFICATION      @"XMPP_ROOM_MEMBER_LIST_NOT_FETCHED_NOTIFICATION"
#define XMPP_ROOM_MODERATOR_LIST_NOT_FETCHED_NOTIFICATION   @"XMPP_ROOM_MODERATOR_LIST_NOT_FETCHED_NOTIFICATION"

#define XMPP_USER_REMOVED_FROM_ROOM_NOTIFICATION   @"XMPP_USER_REMOVED_FROM_ROOM_NOTIFICATION"

#define XMPP_ROOM_DESTROYED_NOTIFICATION        @"XMPP_ROOM_DESTROYED_NOTIFICATION"

#define XMPP_LAST_ACTIVITY_RECEIVED_NOTIFICATION    @"XMPP_LAST_ACTIVITY_RECEIVED_NOTIFICATION"


#define CHAT_TYPE_GROUP     @"groupchat"
#define CHAT_TYPE_SINGLE    @"chat"


#define BlockingMessageStr  @"~Winapp!Chat@Block#User$"
#define UnblockingMessageStr  @"~Winapp!Chat@Unblock#User$"



@protocol ChatDelegate <NSObject>

@optional
- (void)userCameOnline:(NSString *)usernameStr;
- (void)userWentOffline:(NSString *)usernameStr;
-(void)newMessageReceived;
-(void)newMessageReceivedFrom:(NSString *)user;
-(void)newMessageReceivedFrom:(NSString *)user withChatObj:(id)msgObj;
- (void)xmppChatDisconnected;
-(void)userBlocked;
-(void)userUnblocked;
-(void)refreshChatMessageTableForChatObj:(id)msgObj;
-(void)markMessageAsRead:(NSString *)user withChatObj:(id)msgObj;
-(void)youHaveJoinedRoom:(XMPPRoom *)room;

@end


@interface XmppHelper : NSObject
{
    XMPPStream *xmppStream;
    XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
    XMPPvCardTempModule *xmppvCardTempModule;
    XMPPvCardAvatarModule *xmppvCardAvatarModule;
    /*XMPPCapabilities *xmppCapabilities;
     XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;*/
    XMPPMUC *xmppMUC;
    XMPPRoomCoreDataStorage *xmppRoomCoreDataStore;
    XMPPLastActivity *xmppLastActivity;
    
    NSString *password;
    
    BOOL customCertEvaluation;
    //BOOL allowSelfSignedCertificates;
    //BOOL allowSSLHostNameMismatch;
    
    BOOL isXmppConnected;
    
    
    BOOL isRoomCreating;
    NSString *groupNameStr;
    NSString *groupChatIdStr;
    
    NSArray *groupMemberArrayToAdd;
    MBProgressHUD *progessLoading;
    
    NSNumber *buzzSoundId;
    
    NSTimeInterval intervalSinceLastLogout;
    
    NSInteger totalRoomFetched;
    NSArray *roomItems;
    BOOL roomChatHistoryFetched;
    
    NSMutableDictionary *invitionsDict;
    Global *global;
}
@property (nonatomic, strong) NSString *servername;
@property (nonatomic, strong) NSString *hostname;
@property (nonatomic) UInt16 hostport;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *jId;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *groupChatDomainStr;
@property (nonatomic, strong) NSMutableArray *presenceArray;
@property (nonatomic, strong) NSMutableDictionary *rooms;
@property (assign) BOOL roomChatHistoryFetched;

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
/*@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
 @property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;*/
@property (nonatomic, strong, readonly) XMPPMUC *xmppMUC;
@property (nonatomic,strong, readonly) XMPPRoomCoreDataStorage *xmppRoomCoreDataStore;
@property (nonatomic,strong, readonly) XMPPLastActivity *xmppLastActivity;

//CoreData
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext_chatMessage;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel_chatMessage;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong)  id <ChatDelegate> delegate;


-(void)getListOfGroups;
+ (XmppHelper *)sharedInstance;
- (void)setUsername:(NSString *)name andPassword:(NSString *)pass;
-(NSString *)getActualUsernameForUser:(NSString *)nameStr;
-(void)addUserToRosterForUser:(NSString *)frndUsername;
-(void)removeUserFromRosterForUser:(NSString *)frndUsername;
-(void)subscribePresenceForUser:(NSString *)frndUsername;
-(void)unsubscribePresenceForUser:(NSString *)frndUsername;
-(BOOL)isUserOnline:(NSString *)usernameStr;
//-(NSString *)sendFileData:(NSData *)data withMimeTypeID:(NSInteger)type andFileName:(NSString *)filename to:(XMPPJID *)jid;
-(void)getLastActivityForUser:(NSString *)phone_number;
-(NSString *)getLastSeenTimeAgoStringFromSeconds:(NSUInteger)seconds;

-(void)addMessageToCoreData:(NSDictionary *)messageDict;
-(NSString*)generateUniqueID;
//-(BOOL)isUserOnline:(NSString *)usernameStr;

- (void)setupStream;
- (void)goOnline;
- (void)goOffline;
- (BOOL)connect;
- (void)disconnect;
- (NSManagedObjectContext *)managedObjectContext_roster;
- (void)teardownStream;

-(void)blockUser:(NSString *)usernameStr;
-(void)unblockUser:(NSString *)usernameStr;
-(void)updateUserBlockingFlag:(BOOL)isBlocked forUser:(NSString *)otherUsernameStr withLoggedInUser:(NSString *)loggedInUsernameStr;

//-(void)removeUselistForLoggedInUser:(NSString *)loggedInUsernameStr;

-(NSString *)getActualGroupIDForRoom:(NSString *)roomIDStr;
-(void)createNewGroupWithName:(NSString *)groupName withMemberLists:(NSArray *)memberAr;
-(void)createNewGroupWithId:(NSString *)groupId name:(NSString *)groupName withMemberLists:(NSArray *)memberAr;
-(void)inviteUser:(NSString *)userChatId toRoom:(NSString *)roomId;
-(void)removeUser:(NSString *)userChatId fromRoom:(NSString *)roomId;
-(void)joinGroup:(NSString *)roomID withNickname:(NSString *)name;
- (void)changeRoomSubject:(NSString *)newRoomSubject forRoomId:(NSString *)roomId withSendMsg:(BOOL)isSendMessage;

-(NSString *)getLocalDownloadFileDirectory;
-(BOOL)fileExistAtDownloadFileDirectory:(NSString *)fileName;
-(void)deleteFileFromDownloadFileDirectory:(NSString *)fileName;

-(id)fetchUserInfoObjectForID:(NSString *)chatID;
-(NSDictionary *)fetchUserInfoDictionaryForID:(NSString *)chatID;

-(id)fetchListInfoObjectForID:(NSString *)chatID;
-(BOOL)deleteListWithListId:(NSString *)listId;

-(NSDictionary *)fetchListInfoDictionaryForID:(NSString *)chatID;
-(NSDictionary *)fetchGroupInfoDictionaryForID:(NSString *)chatID;
-(id)fetchGroupInfoObjectForID:(NSString *)chatID;

-(void)deleteGroupIdsFromUserInfo:(NSArray *)groupIdAr;

-(void)deleteCoversationWithIds:(NSArray *)chatIdAr;
-(void)deleteCoversationWithGroupIds:(NSArray *)groupIdAr;

-(void)sendInfoMessageToGroupId:(NSString *)groupChatId withMessage:(NSString *)messageBody;

-(void)displayNavigationNotificationForChatObj:(id)msgObj;

-(id)getSavedItemsObjectWithMessageId:(NSString *)messageID andReceiverId:(NSString *)receiverId;
-(void)saveItemWithChatObject:(id)chatObj;

@end
