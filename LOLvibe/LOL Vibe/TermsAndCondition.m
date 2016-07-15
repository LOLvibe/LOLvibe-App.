//
//  TermsAndCondition.m
//  LOLvibe
//
//  Created by Paras Navadiya on 05/05/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "TermsAndCondition.h"

@interface TermsAndCondition ()

@end

@implementation TermsAndCondition

- (void)viewDidLoad {
    [super viewDidLoad];

    [webVw loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.lolvibe.com/index.php/en/terms"]]];
    
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
