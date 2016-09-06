//
//  AboutUS.h
//  LOLvibe
//
//  Created by Paras Navadiya on 7/11/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutUS : UIViewController


@property (strong, nonatomic) IBOutlet UIButton *btnRateUS;
- (IBAction)AboutUS:(id)sender;
- (IBAction)btnFeedback:(id)sender;
- (IBAction)btnICON:(id)sender;
- (IBAction)btnTutorial:(id)sender;
- (IBAction)btnFB:(id)sender;
- (IBAction)btnTwitter:(id)sender;
- (IBAction)btnInsta:(id)sender;


@property (strong, nonatomic) IBOutlet UIButton *btnFeedback;

- (IBAction)btnTerms:(id)sender;

@end
