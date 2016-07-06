//
//  Utility.m
//  Pinngo
//
//  Created by SUNIL on 21/07/14.
//  Copyright (c) 2014 weetech. All rights reserved.
//

#import "Utility.h"

@implementation Utility


+ (UIColor *)colorwithHexString:(NSString *)hexStr alpha:(CGFloat)alpha;
{
    //-----------------------------------------
    // Convert hex string to an integer
    //-----------------------------------------
    unsigned int hexint = 0;
    
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet
                                       characterSetWithCharactersInString:@"#"]];
    [scanner scanHexInt:&hexint];
    
    //-----------------------------------------
    // Create color object, specifying alpha
    //-----------------------------------------
    UIColor *color =
    [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                    green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                     blue:((CGFloat) (hexint & 0xFF))/255
                    alpha:alpha];
    
    return color;
}


+(UIColor *)colorFromHex:(NSString *)hex
{
    return [[self class] colorwithHexString:hex alpha:1.0];
}

+(UIColor *)colorFromHex:(NSString *)hex alpha:(CGFloat)alpha
{
    return [[self class] colorwithHexString:hex alpha:alpha];
}


+(UIActivityIndicatorView *)loadingViewForView:(UIView *)view
{
	UIActivityIndicatorView *lv = (UIActivityIndicatorView *)[view viewWithTag:LOADING_TAG];
	if (lv == nil)
    {
		lv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        //lv.color = NAVIGATION_TINT_COLOR;
		[lv setHidesWhenStopped:TRUE];
		CGRect frame = lv.frame;
		frame.origin.x = round((view.frame.size.width - frame.size.width) / 2.);
		frame.origin.y = round((view.frame.size.height - frame.size.height) / 2.);
		lv.frame = frame;
		lv.tag = LOADING_TAG;
		[view addSubview:lv];
	}
	return lv;
}


+(NSString *)mimeTypeForFileAtPath:(NSString *)path
{
    //if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    //}
    
    //CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
    //CFStringRef mimeType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMETyp e);
    //CFRelease(UTI);
    //if (!mimeType)
    //{
    //    return @"application/octet-stream";
    //}
    //return (__bridge NSString *)mimeType;
}


#pragma mark Display alert
+(void)displayAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
    [alert show];
}


#pragma mark Display HTTP failure error
+(void)displayHttpFailureError:(NSError *)error
{
    NSLog(@"failure error = %@",error);
    
    switch ([error code])
    {
        case NSURLErrorUnknown:
        {
            [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"connection_fail", nil)];
            break;
        }
        case NSURLErrorCancelled:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorBadURL:
        {
            [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"connection_fail", nil)];
            break;
        }
        case NSURLErrorTimedOut:
        {
            [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
            /*case NSURLErrorUnsupportedURL:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }*/
        case NSURLErrorCannotFindHost:
        {
            [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"can_not_find_host", nil)];
            break;
        }
        case NSURLErrorCannotConnectToHost:
        {
            [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"can_not_connect_to_host", nil)];
            break;
        }
        case NSURLErrorDataLengthExceedsMaximum:
        {
            [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"data_length_exceeds_maximum", nil)];
            break;
        }
        case NSURLErrorNetworkConnectionLost:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"network_lost", nil)];
            break;
        }
            /*case NSURLErrorDNSLookupFailed:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorHTTPTooManyRedirects:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }*/
        case NSURLErrorResourceUnavailable:
        {
            [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"resource_not_found", nil)];
            break;
        }
        case NSURLErrorNotConnectedToInternet:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"internet_appears_offline", nil)];
            break;
        }
            /*case NSURLErrorRedirectToNonExistentLocation:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorBadServerResponse:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorUserCancelledAuthentication:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorUserAuthenticationRequired:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorZeroByteResource:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }*/
        case NSURLErrorCannotDecodeRawData:
        {
            [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"server_exception_error", nil)];
            break;
        }
        case NSURLErrorCannotDecodeContentData:
        {
            [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"server_exception_error", nil)];
            break;
        }
             /*case NSURLErrorCannotParseResponse:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorInternationalRoamingOff:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorCallIsActive:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorDataNotAllowed:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorRequestBodyStreamExhausted:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorFileDoesNotExist:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorFileIsDirectory:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorNoPermissionsToReadFile:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorSecureConnectionFailed:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorServerCertificateHasBadDate:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorServerCertificateUntrusted:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorServerCertificateHasUnknownRoot:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorServerCertificateNotYetValid:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorClientCertificateRejected:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorClientCertificateRequired:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorCannotLoadFromNetwork:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorCannotCreateFile:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorCannotOpenFile:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorCannotCloseFile:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorCannotWriteToFile:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorCannotRemoveFile:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorCannotMoveFile:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorDownloadDecodingFailedMidStream:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorDownloadDecodingFailedToComplete:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }*/
            
        default:
        {
            
            if ([[error description] rangeOfString:@"The request timed out."].location != NSNotFound)
            {
                [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            }
            else if ([[error description] rangeOfString:@"The server can not find the requested page"].location != NSNotFound || [[error description] rangeOfString:@"A server with the specified hostname could not be found."].location != NSNotFound)
            {
                [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"server_error", nil)];
            }
            else if([[error description] rangeOfString:@"The network connection was lost."].location != NSNotFound)
            {
                [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"network_lost", nil)];
            }
            else if([[error description] rangeOfString:@"The Internet connection appears to be offline."].location != NSNotFound)
            {
                [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"internet_appears_offline", nil)];
            }
            else if ([[error description] rangeOfString:@"</html>"].location != NSNotFound)
            {
                [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"server_exception_error", nil)];
            }
            else if ([[error description] rangeOfString:@"JSON text did not start with array or object and option to allow fragments not set."].location != NSNotFound)
            {
                [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"server_exception_error", nil)];
            }
            else if ([[error description] rangeOfString:@"Request failed: not found (404)"].location != NSNotFound)
            {
                [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"server_exception_error", nil)];
            }
            else
            {
                [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"connection_fail", nil)];
            }
            
            break;
        }
    }
}



+(NSString *)timeAgoForDate:(NSString *)toDate withTimeZone:(NSString *)timezoneStr
{
    NSString *timeAgoStr;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:timezoneStr];
    [formatter setTimeZone:gmt];
    
    NSDate *date = [formatter dateFromString:toDate];
    NSDate *today = [NSDate date];
    
    NSTimeInterval intervalTime = fabs([date timeIntervalSinceDate:today]);
    NSInteger secondsInterval = (NSInteger)floor(intervalTime);
    NSInteger minutesInterval = (NSInteger)floor(intervalTime/60.0);
    NSInteger hoursInterval = (NSInteger)floor(intervalTime/(60.0*60.0));
    NSInteger daysInterval = (NSInteger)floor(intervalTime/(60.0*60.0*24.0));
    NSInteger weeksInterval = (NSInteger)floor(intervalTime/(60.0*60.0*24.0*7));
    NSInteger monthsInterval = (NSInteger)floor(intervalTime/(60.0*60.0*24.0*30));
    NSInteger yearsInterval = (NSInteger)floor(intervalTime/(60.0*60.0*24.0*30*365));
    
    NSString *period;
    
    if(secondsInterval<3)
    {
        timeAgoStr = @"Just now";
    }
    else if(secondsInterval<60)
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


+(NSString *)timeAgoForDate:(NSDate *)toDate
{
    NSString *timeAgoStr;
    
    NSDate *today = [NSDate date];
    
    NSTimeInterval intervalTime = fabs([toDate timeIntervalSinceDate:today]);
    NSInteger secondsInterval = (NSInteger)floor(intervalTime);
    NSInteger minutesInterval = (NSInteger)floor(intervalTime/60.0);
    NSInteger hoursInterval = (NSInteger)floor(intervalTime/(60.0*60.0));
    NSInteger daysInterval = (NSInteger)floor(intervalTime/(60.0*60.0*24.0));
    NSInteger weeksInterval = (NSInteger)floor(intervalTime/(60.0*60.0*24.0*7));
    NSInteger monthsInterval = (NSInteger)floor(intervalTime/(60.0*60.0*24.0*30));
    NSInteger yearsInterval = (NSInteger)floor(intervalTime/(60.0*60.0*24.0*30*365));
    
    NSString *period;
    
    if(secondsInterval<3)
    {
        timeAgoStr = @"Just now";
    }
    else if(secondsInterval<60)
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


+(NSString *)timeDaysForDate:(NSDate *)toDate
{
    NSString *timeAgoStr;
    
    NSDate *today = [NSDate date];
    
    NSTimeInterval intervalTime = fabs([toDate timeIntervalSinceDate:today]);
    
    NSInteger hoursInterval = (NSInteger)floor(intervalTime/(60.0*60.0));
    
    if(hoursInterval<24 && [toDate earlierDate:today] == toDate)
    {
        timeAgoStr = [NSString stringWithFormat:@"Today"];
    }
    else if(hoursInterval>=24 && hoursInterval<48 && [toDate earlierDate:today] == toDate)
    {
        timeAgoStr = [NSString stringWithFormat:@"Yesterday"];
    }
    else
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        //[formatter setDateFormat:@"MM/dd/yyyy"];
        [formatter setDateFormat:@"dd MMM, yyyy"];
        
        timeAgoStr = [formatter stringFromDate:toDate];
    }
    
    return timeAgoStr;
}



+(NSString *)getLibraryDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    
    return paths[0];
}

+(NSString *)getDocumentDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    return paths[0];
}

+(BOOL)createDirectory:(NSString *)directoryName atFilePath:(NSString *)filePath
{
    NSString *filePathAndDirectory = [filePath stringByAppendingPathComponent:directoryName];
    
    if([[self class] isFileOrDirectoryExistAtPath:filePathAndDirectory])
        return YES;
    
    NSError *error;
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:filePathAndDirectory withIntermediateDirectories:NO attributes:nil error:&error])
    {
        NSLog(@"Create directory error: %@", error);
        return NO;
    }
    else
    {
        return YES;
    }
}


+(BOOL)createDirectoryAtLibraryDirectory:(NSString *)directoryName
{
    NSString *filePathAndDirectory = [[[self class] getLibraryDirectoryPath] stringByAppendingPathComponent:directoryName];
    
    
    if([[self class] isFileOrDirectoryExistAtPath:filePathAndDirectory])
        return YES;
    
    
    NSError *error;
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:filePathAndDirectory withIntermediateDirectories:NO attributes:nil error:&error])
    {
        NSLog(@"Create directory error: %@", error);
        return NO;
    }
    else
    {
        return YES;
    }
}

+(BOOL)createDirectoryAtDocumentDirectory:(NSString *)directoryName
{
    NSString *filePathAndDirectory = [[[self class] getLibraryDirectoryPath] stringByAppendingPathComponent:directoryName];
    
    if([[self class] isFileOrDirectoryExistAtPath:filePathAndDirectory])
        return YES;
    
    
    NSError *error;
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:filePathAndDirectory withIntermediateDirectories:NO attributes:nil error:&error])
    {
        NSLog(@"Create directory error: %@", error);
        return NO;
    }
    else
    {
        return YES;
    }
}

+(BOOL)deleteFileFromPath:(NSString *)filePath
{
    NSLog(@"Path: %@", filePath);
    
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL deleted = [fileManager removeItemAtPath:filePath error:&error];
    
    if (deleted != YES || error != nil)
    {
        NSLog(@"Delete directory error: %@", error);
        
        return NO;
    }
    else
    {
        return YES;
    }
}

+(BOOL)deleteAllFilesAtDirectory:(NSString *)directoryPath
{
    NSLog(@"Path: %@", directoryPath);
    
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL deleted = [fileManager removeItemAtPath:directoryPath error:&error];
    
    if (deleted != YES || error != nil)
    {
         NSLog(@"Delete directory error: %@", error);
        
        return NO;
    }
    else
    {
        [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:&error];
        
        return YES;
    }
}

+(BOOL)isFileOrDirectoryExistAtPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path])
    {
        return YES;
    }
    
    return NO;
}

+(void)deleteFileNameStartWithText:(NSString *)searchText atDirectory:(NSString *)directory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:directory error:nil];
    
    for (NSString *fileString in dirContents)
    {
        if ([[fileString lowercaseString] hasPrefix:[searchText lowercaseString]])
        {
            NSLog(@"delete file = %@",fileString);
            [self deleteFileFromPath:[directory stringByAppendingPathComponent:fileString]];
        }
    }
}


+(NSString *)getCurrentTimeStampStr
{
    return [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
}


+(NSString *)getAsciiUtf8EncodedStringFor:(NSString *)stringToEncode
{
    NSData *data = [stringToEncode dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    NSString *Value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return Value;
}

+(NSString *)getAsciiUtf8DecodedStringFor:(NSString *)stringToDecode
{
    NSData *data = [stringToDecode dataUsingEncoding:NSUTF8StringEncoding];
    NSString *Value = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
    
    return Value;
}



+(NSString*)generateUniqueID
{
    NSString* uniqueIdentifier = nil;
    
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    //uniqueIdentifier = ( NSString*)CFUUIDCreateString(NULL, uuid);- for non- ARC
    uniqueIdentifier = ( NSString*)CFBridgingRelease(CFUUIDCreateString(NULL, uuid));// for ARC
    CFRelease(uuid);
    
    return uniqueIdentifier;
}

+(NSString *)getMimeTypeForID:(NSInteger)mimeId
{
    NSString *mimeTypeStr = @"";
    
    switch (mimeId)
    {
        case kFileMimeTypeBMP:
        {
            mimeTypeStr = @"image/bmp";
            break;
        }
        case kFileMimeTypeCOD:
        {
            mimeTypeStr = @"image/cis-cod";
            break;
        }
        case kFileMimeTypeGIF:
        {
            mimeTypeStr = @"image/gif";
            break;
        }
        case kFileMimeTypeIEF:
        {
            mimeTypeStr = @"image/ief";
            break;
        }
        case kFileMimeTypeJPE:
        {
            mimeTypeStr = @"image/jpeg";
            break;
        }
        case kFileMimeTypeJPEG:
        {
            mimeTypeStr = @"image/jpeg";
            break;
        }
        case kFileMimeTypeJPG:
        {
            mimeTypeStr = @"image/jpeg";
            break;
        }
        case kFileMimeTypeJFIF:
        {
            mimeTypeStr = @"image/pipeg";
            break;
        }
        case kFileMimeTypeSVG:
        {
            mimeTypeStr = @"image/svg+xml";
            break;
        }
        case kFileMimeTypeTIF:
        {
            mimeTypeStr = @"image/tiff";
            break;
        }
        case kFileMimeTypeTIFF:
        {
            mimeTypeStr = @"image/tiff";
            break;
        }
        case kFileMimeTypeRAS:
        {
            mimeTypeStr = @"image/x-cmu-raster";
            break;
        }
        case kFileMimeTypeCMX:
        {
            mimeTypeStr = @"image/x-cmx";
            break;
        }
        case kFileMimeTypeICO:
        {
            mimeTypeStr = @"image/x-icon";
            break;
        }
        case kFileMimeTypePNM:
        {
            mimeTypeStr = @"image/x-portable-anymap";
            break;
        }
        case kFileMimeTypePBM:
        {
            mimeTypeStr = @"image/x-portable-bitmap";
            break;
        }
        case kFileMimeTypePGM:
        {
            mimeTypeStr = @"image/x-portable-graymap";
            break;
        }
        case kFileMimeTypePPM:
        {
            mimeTypeStr = @"image/x-portable-pixmap";
            break;
        }
        case kFileMimeTypePNG:
        {
            mimeTypeStr = @"image/png";
            break;
        }
        case kFileMimeTypeRGB:
        {
            mimeTypeStr = @"image/x-rgb";
            break;
        }
        case kFileMimeTypeXBM:
        {
            mimeTypeStr = @"image/x-xbitmap";
            break;
        }
        case kFileMimeTypeXPM:
        {
            mimeTypeStr = @"image/x-xpixmap";
            break;
        }
        case kFileMimeTypeXWD:
        {
            mimeTypeStr = @"image/x-windowdump";
            break;
        }
            
            
        case kFileMimeTypeCSS:
        {
            mimeTypeStr = @"text/css";
            break;
        }
        case kFileMimeType323:
        {
            mimeTypeStr = @"text/h323";
            break;
        }
        case kFileMimeTypeHTM:
        {
            mimeTypeStr = @"text/html";
            break;
        }
        case kFileMimeTypeHTML:
        {
            mimeTypeStr = @"text/html";
            break;
        }
        case kFileMimeTypeSTM:
        {
            mimeTypeStr = @"text/html";
            break;
        }
        case kFileMimeTypeULS:
        {
            mimeTypeStr = @"text/iuls";
            break;
        }
        case kFileMimeTypeBAS:
        {
            mimeTypeStr = @"text/plain";
            break;
        }
        case kFileMimeTypeC:
        {
            mimeTypeStr = @"text/plain";
            break;
        }
        case kFileMimeTypeH:
        {
            mimeTypeStr = @"text/plain";
            break;
        }
        case kFileMimeTypeTXT:
        {
            mimeTypeStr = @"text/plain";
            break;
        }
        case kFileMimeTypeRTX:
        {
            mimeTypeStr = @"text/richtext";
            break;
        }
        case kFileMimeTypeSCT:
        {
            mimeTypeStr = @"text/scriptlet";
            break;
        }
        case kFileMimeTypeTSV:
        {
            mimeTypeStr = @"text/tab-separated-values";
            break;
        }
        case kFileMimeTypeHTT:
        {
            mimeTypeStr = @"text/webviewhtml";
            break;
        }
        case kFileMimeTypeHTC:
        {
            mimeTypeStr = @"text/x-component";
            break;
        }
        case kFileMimeTypeETX:
        {
            mimeTypeStr = @"text/x-setext";
            break;
        }
        case kFileMimeTypeVCF:
        {
            mimeTypeStr = @"text/x-vcard";
            break;
        }
            
            
        case kFileMimeTypeMP2:
        {
            mimeTypeStr = @"video/mpeg";
            break;
        }
        case kFileMimeTypeMP4:
        {
            mimeTypeStr = @"video/mp4";
            break;
        }
        case kFileMimeTypeMPA:
        {
            mimeTypeStr = @"video/mpeg";
            break;
        }
        case kFileMimeTypeMPE:
        {
            mimeTypeStr = @"video/mpeg";
            break;
        }
        case kFileMimeTypeMPEG:
        {
            mimeTypeStr = @"video/mpeg";
            break;
        }
        case kFileMimeTypeMPG:
        {
            mimeTypeStr = @"video/mpeg";
            break;
        }
        case kFileMimeTypeMPV2:
        {
            mimeTypeStr = @"video/mpeg";
            break;
        }
        case kFileMimeTypeMOV:
        {
            mimeTypeStr = @"video/quicktime";
            break;
        }
        case kFileMimeTypeQT:
        {
            mimeTypeStr = @"video/quicktime";
            break;
        }
        case kFileMimeTypeLSF:
        {
            mimeTypeStr = @"video/x-la-asf";
            break;
        }
        case kFileMimeTypeLSX:
        {
            mimeTypeStr = @"video/x-la-asf";
            break;
        }
        case kFileMimeTypeASF:
        {
            mimeTypeStr = @"video/x-ms-asf";
            break;
        }
        case kFileMimeTypeASR:
        {
            mimeTypeStr = @"video/x-ms-asf";
            break;
        }
        case kFileMimeTypeASX:
        {
            mimeTypeStr = @"video/x-ms-asf";
            break;
        }
        case kFileMimeTypeAVI:
        {
            mimeTypeStr = @"video/x-msvideo";
            break;
        }
        case kFileMimeTypeMOVIE:
        {
            mimeTypeStr = @"video/x-sgi-movie";
            break;
        }
            
            
        case kFileMimeTypeAU:
        {
            mimeTypeStr = @"audio/basic";
            break;
        }
        case kFileMimeTypeSND:
        {
            mimeTypeStr = @"audio/basic";
            break;
        }
        case kFileMimeTypeMID:
        {
            mimeTypeStr = @"audio/mid";
            break;
        }
        case kFileMimeTypeRMI:
        {
            mimeTypeStr = @"audio/mid";
            break;
        }
        case kFileMimeTypeMP3:
        {
            mimeTypeStr = @"audio/mpeg";
            break;
        }
        case kFileMimeTypeAIF:
        {
            mimeTypeStr = @"audio/x-aiff";
            break;
        }
        case kFileMimeTypeAIFC:
        {
            mimeTypeStr = @"audio/x-aiff";
            break;
        }
        case kFileMimeTypeAIFF:
        {
            mimeTypeStr = @"audio/x-aiff";
            break;
        }
        case kFileMimeTypeM3U:
        {
            mimeTypeStr = @"audio/x-mpegurl";
            break;
        }
        case kFileMimeTypeRA:
        {
            mimeTypeStr = @"audio/x-pn-realaudio";
            break;
        }
        case kFileMimeTypeRAM:
        {
            mimeTypeStr = @"audio/x-pn-realaudio";
            break;
        }
        case kFileMimeTypeWAV:
        {
            mimeTypeStr = @"audio/x-wav";
            break;
        }
        default:
            break;
    }
    
    return mimeTypeStr;
}

+(NSString *)getFileNameForMimeTypeID:(NSInteger)mimeId
{
    NSString *fileNameStr = @"";
    
    switch (mimeId)
    {
        case kFileMimeTypeBMP:
        {
            fileNameStr = [NSString stringWithFormat:@"photo%@.bmp", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeCOD:
        {
            fileNameStr = [NSString stringWithFormat:@"photo%@.cod", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeGIF:
        {
            fileNameStr = [NSString stringWithFormat:@"photo%@.gif", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeIEF:
        {
            fileNameStr = [NSString stringWithFormat:@"photo%@.ief", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeJPE:
        {
            fileNameStr = [NSString stringWithFormat:@"photo%@.jpe", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeJPEG:
        {
            fileNameStr = [NSString stringWithFormat:@"photo%@.jpeg", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeJPG:
        {
            fileNameStr = [NSString stringWithFormat:@"photo%@.jpg", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeJFIF:
        {
            fileNameStr = [NSString stringWithFormat:@"photo%@.jfif", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeSVG:
        {
            fileNameStr = [NSString stringWithFormat:@"photo%@.svg", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeTIF:
        {
            fileNameStr = [NSString stringWithFormat:@"photo%@.tif", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeTIFF:
        {
            fileNameStr = [NSString stringWithFormat:@"photo%@.tiff", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeRAS:
        {
            fileNameStr = [NSString stringWithFormat:@"photo%@.ras", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeCMX:
        {
            fileNameStr = [NSString stringWithFormat:@"photo%@.cmx", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeICO:
        {
            fileNameStr = [NSString stringWithFormat:@"photo%@.ico", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypePNM:
        {
            fileNameStr = [NSString stringWithFormat:@"photo%@.pnm", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypePBM:
        {
            fileNameStr = [NSString stringWithFormat:@"photo%@.pbm", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypePGM:
        {
            fileNameStr = [NSString stringWithFormat:@"photo%@.pgm", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypePPM:
        {
            fileNameStr = [NSString stringWithFormat:@"photo%@.ppm", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypePNG:
        {
            fileNameStr = [NSString stringWithFormat:@"photo%@.png", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeRGB:
        {
            fileNameStr = [NSString stringWithFormat:@"photo%@.rgb", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeXBM:
        {
            fileNameStr = [NSString stringWithFormat:@"photo%@.xbm", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeXPM:
        {
            fileNameStr = [NSString stringWithFormat:@"photo%@.xpm", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeXWD:
        {
            fileNameStr = [NSString stringWithFormat:@"photo%@.xwd", [self generateUniqueID]];
            break;
        }
            
            
        case kFileMimeTypeCSS:
        {
            fileNameStr = [NSString stringWithFormat:@"text%@.css", [self generateUniqueID]];
            break;
        }
        case kFileMimeType323:
        {
            fileNameStr = [NSString stringWithFormat:@"text%@.323", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeHTM:
        {
            fileNameStr = [NSString stringWithFormat:@"text%@.htm", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeHTML:
        {
            fileNameStr = [NSString stringWithFormat:@"text%@.html", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeSTM:
        {
            fileNameStr = [NSString stringWithFormat:@"text%@.stm", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeULS:
        {
            fileNameStr = [NSString stringWithFormat:@"text%@.uls", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeBAS:
        {
            fileNameStr = [NSString stringWithFormat:@"text%@.bas", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeC:
        {
            fileNameStr = [NSString stringWithFormat:@"text%@.c", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeH:
        {
            fileNameStr = [NSString stringWithFormat:@"text%@.h", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeTXT:
        {
            fileNameStr = [NSString stringWithFormat:@"text%@.txt", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeRTX:
        {
            fileNameStr = [NSString stringWithFormat:@"text%@.rtx", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeSCT:
        {
            fileNameStr = [NSString stringWithFormat:@"text%@.sct", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeTSV:
        {
            fileNameStr = [NSString stringWithFormat:@"text%@.tsv", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeHTT:
        {
            fileNameStr = [NSString stringWithFormat:@"text%@.htt", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeHTC:
        {
            fileNameStr = [NSString stringWithFormat:@"text%@.htc", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeETX:
        {
            fileNameStr = [NSString stringWithFormat:@"text%@.etx", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeVCF:
        {
            fileNameStr = [NSString stringWithFormat:@"text%@.vcf", [self generateUniqueID]];
            break;
        }
            
            
        case kFileMimeTypeMP2:
        {
            fileNameStr = [NSString stringWithFormat:@"video%@.mp2", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeMP4:
        {
            fileNameStr = [NSString stringWithFormat:@"video%@.mp4", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeMPA:
        {
            fileNameStr = [NSString stringWithFormat:@"video%@.mpa", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeMPE:
        {
            fileNameStr = [NSString stringWithFormat:@"video%@.mpe", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeMPEG:
        {
            fileNameStr = [NSString stringWithFormat:@"video%@.mpeg", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeMPG:
        {
            fileNameStr = [NSString stringWithFormat:@"video%@.mpg", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeMPV2:
        {
            fileNameStr = [NSString stringWithFormat:@"video%@.mpv2", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeMOV:
        {
            fileNameStr = [NSString stringWithFormat:@"video%@.mov", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeQT:
        {
            fileNameStr = [NSString stringWithFormat:@"video%@.qt", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeLSF:
        {
            fileNameStr = [NSString stringWithFormat:@"video%@.lsf", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeLSX:
        {
            fileNameStr = [NSString stringWithFormat:@"video%@.lsx", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeASF:
        {
            fileNameStr = [NSString stringWithFormat:@"video%@.asf", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeASR:
        {
            fileNameStr = [NSString stringWithFormat:@"video%@.asr", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeASX:
        {
            fileNameStr = [NSString stringWithFormat:@"video%@.asx", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeAVI:
        {
            fileNameStr = [NSString stringWithFormat:@"video%@.avi", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeMOVIE:
        {
            fileNameStr = [NSString stringWithFormat:@"video%@.movie", [self generateUniqueID]];
            break;
        }
            
        case kFileMimeTypeAU:
        {
            fileNameStr = [NSString stringWithFormat:@"audio%@.au", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeSND:
        {
            fileNameStr = [NSString stringWithFormat:@"audio%@.snd", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeMID:
        {
            fileNameStr = [NSString stringWithFormat:@"audio%@.mid", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeRMI:
        {
            fileNameStr = [NSString stringWithFormat:@"audio%@.rmi", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeMP3:
        {
            fileNameStr = [NSString stringWithFormat:@"audio%@.mp3", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeAIF:
        {
            fileNameStr = [NSString stringWithFormat:@"audio%@.aif", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeAIFC:
        {
            fileNameStr = [NSString stringWithFormat:@"audio%@.aifc", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeAIFF:
        {
            fileNameStr = [NSString stringWithFormat:@"audio%@.aiff", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeM3U:
        {
            fileNameStr = [NSString stringWithFormat:@"audio%@.m3u", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeRA:
        {
            fileNameStr = [NSString stringWithFormat:@"audio%@.ra", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeRAM:
        {
            fileNameStr = [NSString stringWithFormat:@"audio%@.ram", [self generateUniqueID]];
            break;
        }
        case kFileMimeTypeWAV:
        {
            fileNameStr = [NSString stringWithFormat:@"audio%@.wav", [self generateUniqueID]];
            break;
        }
            
        default:
            break;
    }
    
    return fileNameStr;
}

+(NSString *)getFileTypeForMimeType:(NSString *)mimeType
{
    
    if([[mimeType lowercaseString] isEqualToString:@"image/bmp"] ||
       [[mimeType lowercaseString] isEqualToString:@"image/cis-cod"] ||
       [[mimeType lowercaseString] isEqualToString:@"image/gif"] ||
       [[mimeType lowercaseString] isEqualToString:@"image/ief"] ||
       [[mimeType lowercaseString] isEqualToString:@"image/jpeg"] ||
       [[mimeType lowercaseString] isEqualToString:@"image/pipeg"] ||
       [[mimeType lowercaseString] isEqualToString:@"image/svg+xml"] ||
       [[mimeType lowercaseString] isEqualToString:@"image/tiff"] ||
       [[mimeType lowercaseString] isEqualToString:@"image/x-cmu-raster"] ||
       [[mimeType lowercaseString] isEqualToString:@"image/x-cmx"] ||
       [[mimeType lowercaseString] isEqualToString:@"image/x-icon"] ||
       [[mimeType lowercaseString] isEqualToString:@"image/x-portable-anymap"] ||
       [[mimeType lowercaseString] isEqualToString:@"image/x-portable-bitmap"] ||
       [[mimeType lowercaseString] isEqualToString:@"image/x-portable-graymap"] ||
       [[mimeType lowercaseString] isEqualToString:@"image/x-portable-pixmap"] ||
       [[mimeType lowercaseString] isEqualToString:@"image/png"] ||
       [[mimeType lowercaseString] isEqualToString:@"image/x-rgb"] ||
       [[mimeType lowercaseString] isEqualToString:@"image/x-xbitmap"] ||
       [[mimeType lowercaseString] isEqualToString:@"image/x-xpixmap"] ||
       [[mimeType lowercaseString] isEqualToString:@"image/x-windowdump"])
    {
        return @"image";
    }
    else if([[mimeType lowercaseString] isEqualToString:@"text/css"] ||
            [[mimeType lowercaseString] isEqualToString:@"text/h323"] ||
            [[mimeType lowercaseString] isEqualToString:@"text/html"] ||
            [[mimeType lowercaseString] isEqualToString:@"text/iuls"] ||
            [[mimeType lowercaseString] isEqualToString:@"text/plain"] ||
            [[mimeType lowercaseString] isEqualToString:@"text/richtext"] ||
            [[mimeType lowercaseString] isEqualToString:@"text/scriptlet"] ||
            [[mimeType lowercaseString] isEqualToString:@"text/tab-separated-values"] ||
            [[mimeType lowercaseString] isEqualToString:@"text/webviewhtml"] ||
            [[mimeType lowercaseString] isEqualToString:@"text/x-component"] ||
            [[mimeType lowercaseString] isEqualToString:@"text/x-setext"] ||
            [[mimeType lowercaseString] isEqualToString:@"text/x-vcard"])
    {
        return @"text";
    }
    else if([[mimeType lowercaseString] isEqualToString:@"video/mpeg"] ||
            [[mimeType lowercaseString] isEqualToString:@"video/mp4"] ||
            [[mimeType lowercaseString] isEqualToString:@"video/quicktime"] ||
            [[mimeType lowercaseString] isEqualToString:@"video/x-la-asf"] ||
            [[mimeType lowercaseString] isEqualToString:@"video/x-ms-asf"] ||
            [[mimeType lowercaseString] isEqualToString:@"video/x-msvideo"] ||
            [[mimeType lowercaseString] isEqualToString:@"video/x-sgi-movie"])
    {
        return @"video";
    }
    else if([[mimeType lowercaseString] isEqualToString:@"audio/basic"] ||
            [[mimeType lowercaseString] isEqualToString:@"audio/mid"] ||
            [[mimeType lowercaseString] isEqualToString:@"audio/mpeg"] ||
            [[mimeType lowercaseString] isEqualToString:@"audio/x-aiff"] ||
            [[mimeType lowercaseString] isEqualToString:@"audio/x-mpegurl"] ||
            [[mimeType lowercaseString] isEqualToString:@"audio/x-pn-realaudio"] ||
            [[mimeType lowercaseString] isEqualToString:@"audio/x-wav"])
    {
        return @"audio";
    }
    else
    {
        if([mimeType length]>0)
        {
            NSArray *tempAr = [mimeType componentsSeparatedByString:@"/"];
            if([tempAr count]==1)
            {
                return [tempAr objectAtIndex:0];
            }
            else if([tempAr count]==2)
            {
                return [tempAr objectAtIndex:0];
            }
            else
            {
                return @"other";
            }
        }
        else
        {
            return @"other";
        }
        
    }
        
        
}

@end
