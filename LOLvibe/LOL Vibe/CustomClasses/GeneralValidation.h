//
//  GeneralValidation.h
//  What's it
//
//  Created by SUNIL on 05/10/13.
//  Copyright (c) 2013 weetech. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    kValidationNameFirstName = 0,
    kValidationNameLastName,
    kValidationNameUsername,
    kValidationNameEmail,
    kValidationNamePassword,
    kValidationNameConfirmPassword,
}kValidationName;

typedef enum
{
    kValidationTypeLength = 0,
    kValidationTypeInput,
}kValidationType;

@interface GeneralValidation : NSObject

+(BOOL)validateString:(NSString *)str withLastAddedCharacter:(NSString *)lastChar forValidationName:(NSInteger)validationName andValidationType:(NSInteger)validationType;
+(BOOL)isValidEmailID:(NSString *)email;
+(BOOL)isPasswordMatched:(NSString *)password andConfirmPassword:(NSString *)confirmPassword;

@end
