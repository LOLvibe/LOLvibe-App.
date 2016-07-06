//
//  WebBrowserVc.m
//  LOLvibe
//
//  Created by Paras Navadiya on 02/07/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "WebBrowserVc.h"

@interface WebBrowserVc ()

@end

@implementation WebBrowserVc

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = _strURL;
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@",_strURL]]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
