//
//  GeneralValidation.m
//  What's it
//
//  Created by SUNIL on 05/10/13.
//  Copyright (c) 2013 weetech. All rights reserved.
//

#import "GeneralValidation.h"

@implementation GeneralValidation

+(BOOL)validateString:(NSString *)str withLastAddedCharacter:(NSString *)lastChar forValidationName:(NSInteger)validationName andValidationType:(NSInteger)validationType
{
    if(lastChar==nil)
        lastChar = @"";
    
    switch (validationName)
    {
        case kValidationNameFirstName:{
            
            if(validationType==kValidationTypeLength)
            {
                if([str length]<2 || [str length]>16)
                {
                    return NO;
                }
                else
                {
                    return YES;
                }
            }
            else
            {
                
                if([str length]==16 && ![lastChar isEqualToString:@""])
                    return NO;
                
                unichar c = [self getLastAddedStringAsCharacter:lastChar];
                
                if([str length]==0)
                {
                    if ([[NSCharacterSet letterCharacterSet] characterIsMember:c])
                    {
                        return YES;
                    }
                }
                else if([[NSCharacterSet whitespaceCharacterSet] characterIsMember:c] && [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[str characterAtIndex:[str length]-1]])
                {
                    return NO;
                }
                else if ([[NSCharacterSet letterCharacterSet] characterIsMember:c] || [[NSCharacterSet whitespaceCharacterSet] characterIsMember:c])
                {
                    return YES;
                }
                else if ([lastChar isEqualToString:@""])
                {
                    return YES;
                }
            }
            
            return NO;
            
            break;
        }
            
        case kValidationNameLastName:{
            
            if(validationType==kValidationTypeLength)
            {
                if([str length]<1 || [str length]>16)
                {
                    return NO;
                }
                else
                {
                    return YES;
                }
            }
            else
            {
                
                if([str length]==16 && ![lastChar isEqualToString:@""])
                    return NO;
                
                unichar c = [self getLastAddedStringAsCharacter:lastChar];
                
                if ([[NSCharacterSet letterCharacterSet] characterIsMember:c])
                {
                    return YES;
                }
                else if ([lastChar isEqualToString:@""])
                {
                    return YES;
                }
            }
            
            return NO;
            
            break;
        }
            
        case kValidationNameUsername:{
            
            if(validationType==kValidationTypeLength)
            {
                if([str length]<4 || [str length]>16)
                {
                    return NO;
                }
                else
                {
                    return YES;
                }
            }
            else
            {
                if([str length]==16 && ![lastChar isEqualToString:@""])
                    return NO;
                
                unichar c = [self getLastAddedStringAsCharacter:lastChar];
                
                if([str length]==0)
                {
                    if ([[NSCharacterSet letterCharacterSet] characterIsMember:c])
                    {
                        return YES;
                    }
                }
                else
                {
                    NSCharacterSet *usernameCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_."];
                    
                    NSCharacterSet *specialCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"_."];
                    
                    if([specialCharacterSet characterIsMember:c] && [specialCharacterSet characterIsMember:[str characterAtIndex:[str length]-1]])
                    {
                        return NO;
                    }
                    else if ([usernameCharacterSet characterIsMember:c])
                    {
                        return YES;
                    }
                    else if ([lastChar isEqualToString:@""])
                    {
                        return YES;
                    }
                }
            }
            
            return NO;
            
            break;
        }
            
        case kValidationNameEmail:{
            
            if(validationType==kValidationTypeLength)
            {
                return YES;
            }
            else
            {
                
                unichar c = [self getLastAddedStringAsCharacter:lastChar];
                
                
                if([str length]==0)
                {
                    if ([[NSCharacterSet alphanumericCharacterSet] characterIsMember:c])
                    {
                        return YES;
                    }
                }
                else
                {
                    NSCharacterSet *emailCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_."];
                    
                    NSCharacterSet *symbolCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"@"];
                    NSCharacterSet *specialCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"_.@"];
                    
                    
                    if([specialCharacterSet characterIsMember:c] && [specialCharacterSet characterIsMember:[str characterAtIndex:[str length]-1]])
                    {
                        return NO;
                    }
                    else if([str rangeOfString:@"@"].location == NSNotFound && [symbolCharacterSet characterIsMember:c])
                    {
                        return YES;
                    }
                    else if ([emailCharacterSet characterIsMember:c])
                    {
                        return YES;
                    }
                    else if ([lastChar isEqualToString:@""])
                    {
                        return YES;
                    }
                }
            }
            
            return NO;
            
            break;
        }
            
        case kValidationNamePassword:{
            
            if(validationType==kValidationTypeLength)
            {
                if([str length]<4 || [str length]>16)
                {
                    return NO;
                }
                else
                {
                    return YES;
                }
            }
            else
            {
                if([str length]==16 && ![lastChar isEqualToString:@""])
                    return NO;
                
                return YES;
            }
            
            break;
        }
            
        case kValidationNameConfirmPassword:{
            
            if(validationType==kValidationTypeLength)
            {
                return YES;
            }
            else
            {
                return YES;
            }
            
            break;
        }
        default:
            break;
    }
    return YES;
}
+(unichar)getLastAddedStringAsCharacter:(NSString *)lastChar
{
    if ([lastChar length]>0)
    {
        return [lastChar characterAtIndex:0];
    }
    else
    {
        return '\0';
    }
}
+(BOOL)isValidEmailID:(NSString *)email
{
    NSString *regExPattern = @"[_A-Za-z0-9-]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9][A-Za-z0-9]+(\\.[A-Za-z0-9][A-Za-z0-9]+)*(\\.[a-zA-Z]{2,4})+";
    NSPredicate * emailValidator = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regExPattern];
    BOOL isValid = [emailValidator evaluateWithObject:email];
    return isValid;
}
+(BOOL)isPasswordMatched:(NSString *)password andConfirmPassword:(NSString *)confirmPassword
{
    if([password length]!= [confirmPassword length] || ![password isEqualToString:confirmPassword])
    {
        return NO;
    }
    
    return YES;
}

@end


