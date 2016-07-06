//
//  WebBrowserVc.h
//  LOLvibe
//
//  Created by Paras Navadiya on 02/07/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebBrowserVc : UIViewController
{
    IBOutlet UIWebView *webView;
}
@property(nonatomic, retain) NSString *strURL;
@end
