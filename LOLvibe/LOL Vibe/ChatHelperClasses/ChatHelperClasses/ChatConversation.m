//
//  ChatConversation.m
//  nesetchat
//
//  Created by WeeTech Solution on 01/06/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import "ChatConversation.h"

@interface ChatConversation ()

@property (nonatomic) NSDate *primitiveMessageDateTime;
@property (nonatomic) NSString *primitiveSectionIdentifier;

@end

@implementation ChatConversation

@dynamic fileData;
@dynamic fileName;
@dynamic fileUrl;
@dynamic hasMedia;
@dynamic imageOpenTime;
@dynamic isGroupMessage;
@dynamic isMessageReceived;
@dynamic isNew;
@dynamic isPending;
@dynamic isSavedItem;
@dynamic localFilePath;
@dynamic messageBody;
@dynamic messageDate;
@dynamic messageDateTime;
@dynamic messageId;
@dynamic messageStatus;
@dynamic messageTime;
@dynamic messageType;
@dynamic mimeType;
@dynamic occupantId;
@dynamic receiverId;
@dynamic sectionIdentifier;
@dynamic senderId;
@dynamic thumbnailData;
@dynamic thumbnailUrl;
@dynamic primitiveMessageDateTime;
@dynamic primitiveSectionIdentifier;
@dynamic senderUserName;
@dynamic indexPath;


#pragma mark - Transient properties

- (NSString *)sectionIdentifier
{
    // Create and cache the section identifier on demand.
    
    [self willAccessValueForKey:@"sectionIdentifier"];
    NSString *tmp = [self primitiveSectionIdentifier];
    [self didAccessValueForKey:@"sectionIdentifier"];
    
    if (!tmp)
    {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[self messageDateTime]];
        tmp = [NSString stringWithFormat:@"%ld_%02ld_%02ld", (long)[components year],(long)[components month],(long)[components day]];
        [self setPrimitiveSectionIdentifier:tmp];
    }
    return tmp;
}


#pragma mark - Time stamp setter

- (void)setMessageDateTime:(NSDate *)messageDateTime
{
    // If the time stamp changes, the section identifier become invalid.
    [self willChangeValueForKey:@"messageDateTime"];
    [self setPrimitiveMessageDateTime:messageDateTime];
    [self didChangeValueForKey:@"messageDateTime"];
    
    [self setPrimitiveSectionIdentifier:nil];
}


#pragma mark - Key path dependencies

+ (NSSet *)keyPathsForValuesAffectingSectionIdentifier
{
    // If the value of timeStamp changes, the section identifier may change as well.
    return [NSSet setWithObject:@"messageDateTime"];
}



-(NSString *)messageDateStr
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    return [formatter stringFromDate:self.messageDateTime];
}

-(NSString *)messageTimeStr
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm a"];
    return [formatter stringFromDate:self.messageDateTime];
}

-(NSAttributedString *)messageFormattedDateTimeStrWithFontSize:(float)fontSize
{
    /*NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM"];
    NSString *dateStr = [formatter stringFromDate:self.messageDateTime];
    dateStr = [dateStr stringByAppendingString:@","];
    
    NSString *timeStr = [self messageTimeStr];
    
    NSString *finalStr = [NSString stringWithFormat:@"%@ %@", dateStr, timeStr];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:finalStr];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13.0] range:[finalStr rangeOfString:dateStr]];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.0] range:[finalStr rangeOfString:timeStr]];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:[finalStr rangeOfString:finalStr]];
    
    return attributedString;*/
    
    return nil;
    
}

@end
