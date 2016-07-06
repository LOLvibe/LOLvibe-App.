//
//  ChatConversation.h
//  nesetchat
//
//  Created by WeeTech Solution on 01/06/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ChatConversation : NSManagedObject

@property (nonatomic, retain) NSData * fileData;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSString * fileUrl;
@property (nonatomic, retain) NSNumber * hasMedia;
@property (nonatomic, retain) NSNumber * imageOpenTime;
@property (nonatomic, retain) NSNumber * isGroupMessage;
@property (nonatomic, retain) NSNumber * isMessageReceived;
@property (nonatomic, retain) NSNumber * isNew;
@property (nonatomic, retain) NSNumber * isPending;
@property (nonatomic, retain) NSNumber * isSavedItem;
@property (nonatomic, retain) NSString * localFilePath;
@property (nonatomic, retain) NSString * messageBody;
@property (nonatomic, retain) NSString * messageDate;
@property (nonatomic, retain) NSDate * messageDateTime;
@property (nonatomic, retain) NSString * messageId;
@property (nonatomic, retain) NSString * messageStatus;
@property (nonatomic, retain) NSString * messageTime;
@property (nonatomic, retain) NSString * messageType;
@property (nonatomic, retain) NSString * mimeType;
@property (nonatomic, retain) NSString * occupantId;
@property (nonatomic, retain) NSString * receiverId;
@property (nonatomic, retain) NSString * sectionIdentifier;
@property (nonatomic, retain) NSString * senderId;
@property (nonatomic, retain) NSData * thumbnailData;
@property (nonatomic, retain) NSString * thumbnailUrl;
@property (nonatomic, retain) NSString * senderUserName;
@property (nonatomic, retain) NSString *indexPath;

-(NSString *)messageTimeStr;

-(NSAttributedString *)messageFormattedDateTimeStrWithFontSize:(float)fontSize;

@end
