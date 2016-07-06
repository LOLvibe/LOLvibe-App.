//
//  WebService.h
//  Panelitx
//
//  Created by Paras Navadiya on 22/09/15.
//  Copyright (c) 2015 Panelitx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "Reachability.h"
#import "MBProgressHUD.h"

@protocol WebServiceDelegate <NSObject>

@required
-(void)webserviceCallFinishedWithSuccess:(BOOL)success andResponseObject:(id)responseObj andError:(NSError *)error forWebServiceTag:(NSString *)tagStr;

@end

@interface WebService : NSObject<MBProgressHUDDelegate>
{
    MBProgressHUD   *mbProcess;
    UIView          *view_Process;
}
@property(nonatomic, retain)id <WebServiceDelegate> delegate;

-(id)initWithView:(UIView *)view andDelegate:(id <WebServiceDelegate>)del;
-(void)callSimpleWebServiceWithURLDict:(NSString *)url
                         andHTTPMethod:(NSString *)method
                           andDictData:(NSDictionary *)dictParameters
                           withLoading:(BOOL)loading
                      andWebServiceTag:(NSString *)tagStr
                              setToken:(BOOL)isSetToken;

-(void)callWebServiceWithURLDict:(NSString *)url
                   andHTTPMethod:(NSString *)method
                     andDictData:(NSDictionary *)dictParameters
                     withLoading:(BOOL)loading
                andWebServiceTag:(NSString *)tagStr
                        setToken:(BOOL)isSetToken;


-(void)callWebServiceWithURL:(NSString *)url
               andHTTPMethod:(NSString *)method
                 andDictData:(NSDictionary *)strParameters
                       Image:(NSData *)imgData
                    fileName:(NSString *)strFileName
               parameterName:(NSString *)strParameterName
                 withLoading:(BOOL)loading
            andWebServiceTag:(NSString *)tagStr;
@end
