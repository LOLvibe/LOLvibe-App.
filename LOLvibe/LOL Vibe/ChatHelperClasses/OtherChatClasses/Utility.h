//
//  Utility.h
//  Pinngo
//
//  Created by SUNIL on 21/07/14.
//  Copyright (c) 2014 weetech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>



typedef enum
{
    kFileMimeTypeBMP = 0,
    kFileMimeTypeCOD,
    kFileMimeTypeGIF,
    kFileMimeTypeIEF,
    kFileMimeTypeJPE,
    kFileMimeTypeJPEG,
    kFileMimeTypeJPG,
    kFileMimeTypeJFIF,
    kFileMimeTypeSVG,
    kFileMimeTypeTIF,
    kFileMimeTypeTIFF,
    kFileMimeTypeRAS,
    kFileMimeTypeCMX,
    kFileMimeTypeICO,
    kFileMimeTypePNM,
    kFileMimeTypePBM,
    kFileMimeTypePGM,
    kFileMimeTypePPM,
    kFileMimeTypePNG,
    kFileMimeTypeRGB,
    kFileMimeTypeXBM,
    kFileMimeTypeXPM,
    kFileMimeTypeXWD,
    
    kFileMimeTypeCSS,
    kFileMimeType323,
    kFileMimeTypeHTM,
    kFileMimeTypeHTML,
    kFileMimeTypeSTM,
    kFileMimeTypeULS,
    kFileMimeTypeBAS,
    kFileMimeTypeC,
    kFileMimeTypeH,
    kFileMimeTypeTXT,
    kFileMimeTypeRTX,
    kFileMimeTypeSCT,
    kFileMimeTypeTSV,
    kFileMimeTypeHTT,
    kFileMimeTypeHTC,
    kFileMimeTypeETX,
    kFileMimeTypeVCF,
    
    kFileMimeTypeMP2,
    kFileMimeTypeMP4,
    kFileMimeTypeMPA,
    kFileMimeTypeMPE,
    kFileMimeTypeMPEG,
    kFileMimeTypeMPG,
    kFileMimeTypeMPV2,
    kFileMimeTypeMOV,
    kFileMimeTypeQT,
    kFileMimeTypeLSF,
    kFileMimeTypeLSX,
    kFileMimeTypeASF,
    kFileMimeTypeASR,
    kFileMimeTypeASX,
    kFileMimeTypeAVI,
    kFileMimeTypeMOVIE,
    
    kFileMimeTypeAU,
    kFileMimeTypeSND,
    kFileMimeTypeMID,
    kFileMimeTypeRMI,
    kFileMimeTypeMP3,
    kFileMimeTypeAIF,
    kFileMimeTypeAIFC,
    kFileMimeTypeAIFF,
    kFileMimeTypeM3U,
    kFileMimeTypeRA,
    kFileMimeTypeRAM,
    kFileMimeTypeWAV,
}mimeType;



#define RGB(r, g, b)        [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a)    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define LOADING_TAG 10000

@interface Utility : NSObject

+(UIColor *)colorFromHex:(NSString *)hex;
+(UIColor *)colorFromHex:(NSString *)hex alpha:(CGFloat)alpha;

+(UIActivityIndicatorView *)loadingViewForView:(UIView *)view;

+(void)displayAlertWithTitle:(NSString *)title andMessage:(NSString *)message;
+(void)displayHttpFailureError:(NSError *)error;

+(NSString *)timeAgoForDate:(NSString *)toDate withTimeZone:(NSString *)timezoneStr;
+(NSString *)timeAgoForDate:(NSDate *)toDate;
+(NSString *)timeDaysForDate:(NSDate *)toDate;

+(NSString *)getLibraryDirectoryPath;
+(NSString *)getDocumentDirectoryPath;

+(BOOL)createDirectory:(NSString *)directoryName atFilePath:(NSString *)filePath;
+(BOOL)createDirectoryAtLibraryDirectory:(NSString *)directoryName;
+(BOOL)createDirectoryAtDocumentDirectory:(NSString *)directoryName;

+(BOOL)deleteFileFromPath:(NSString *)filePath;
+(BOOL)deleteAllFilesAtDirectory:(NSString *)directoryPath;

+(BOOL)isFileOrDirectoryExistAtPath:(NSString *)path;

+(void)deleteFileNameStartWithText:(NSString *)searchText atDirectory:(NSString *)directory;

+(NSString *)getCurrentTimeStampStr;

+(NSString *)getAsciiUtf8EncodedStringFor:(NSString *)stringToEncode;
+(NSString *)getAsciiUtf8DecodedStringFor:(NSString *)stringToDecode;

+(NSString *)mimeTypeForFileAtPath:(NSString *)path;
+(NSString *)getFileTypeForMimeType:(NSString *)mimeType;

@end
