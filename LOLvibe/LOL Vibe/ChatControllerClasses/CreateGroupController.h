//
//  CreateGroupController.h
//  LOLvibe
//
//  Created by Jaydip Godhani on 28/05/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateGroupController : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    IBOutlet UILabel *lblCount;
    __weak IBOutlet UIImageView *imgGroupIcon;
    __weak IBOutlet UITextField *txtGroupName;
    UITapGestureRecognizer *tapOnImage;
}
- (IBAction)btnCancel:(UIButton *)sender;
- (IBAction)btnNext:(UIButton *)sender;


@end
