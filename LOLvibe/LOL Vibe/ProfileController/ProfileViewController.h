//
//  ProfileViewController.h
//  LOLvibe
//
//  Created by Jaydip Godhani on 12/05/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController<UIScrollViewDelegate,UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIGestureRecognizerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    
    IBOutlet UIButton *btnAboutUS;
    IBOutlet UIScrollView *scrEditProfile;
    IBOutlet UITextField *txtName;
    IBOutlet UITextField *txtVibeName;
    IBOutlet UITextField *txtZipCode;
    IBOutlet UISwitch *swZipCode;
    IBOutlet UITextField *txtWebsite;
    IBOutlet UISwitch *swWebsite;
    IBOutlet UITextField *txtBirthDate;
    IBOutlet UISwitch *swBirthDate;
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtChangePassword;
    IBOutlet UITextField *txtPhoneNumber;
    IBOutlet UITextField *txtGender;
    IBOutlet UIImageView *imgUserProfile;
    IBOutlet UIButton *btnDiscovery;
    IBOutlet UIButton *btnPushNotification;
    IBOutlet UIButton *btnPrivateAccount;
    IBOutlet UIView *viewDatePicker;
    IBOutlet UIDatePicker *datePicker;
    IBOutlet UIToolbar *toolBar;
    IBOutlet UIView *viewPicker;
    IBOutlet UIPickerView *pickerView;
    IBOutlet UIButton *btnLogout;
    IBOutlet UIButton *btnVerify;
}

@property (weak, nonatomic) UITextField *activeField;
- (IBAction)btnVerify:(id)sender;

- (IBAction)swLocation:(UISwitch *)sender;
- (IBAction)swWebsite:(UISwitch *)sender;
- (IBAction)swBirthDate:(UISwitch *)sender;

- (IBAction)btnPrivate:(UIButton *)sender;
- (IBAction)btnPushNotiSetting:(UIButton *)sender;
- (IBAction)btnDiscoverySetting:(UIButton *)sender;
- (IBAction)cancelDate:(UIBarButtonItem *)sender;
- (IBAction)doneDate:(UIBarButtonItem *)sender;
- (IBAction)cancelPicker:(UIBarButtonItem *)sender;
- (IBAction)doenPicker:(UIBarButtonItem *)sender;
- (IBAction)btnLogoutAction:(UIButton *)sender;

@end
