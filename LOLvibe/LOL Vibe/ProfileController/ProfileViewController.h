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
    
    __weak IBOutlet UIScrollView *scrEditProfile;
    __weak IBOutlet UITextField *txtName;
    __weak IBOutlet UITextField *txtVibeName;
    __weak IBOutlet UITextField *txtZipCode;
    __weak IBOutlet UISwitch *swZipCode;
    __weak IBOutlet UITextField *txtWebsite;
    __weak IBOutlet UISwitch *swWebsite;
    __weak IBOutlet UITextField *txtBirthDate;
    __weak IBOutlet UISwitch *swBirthDate;
    __weak IBOutlet UITextField *txtEmail;
    __weak IBOutlet UITextField *txtChangePassword;
    __weak IBOutlet UITextField *txtPhoneNumber;
    __weak IBOutlet UITextField *txtGender;
    __weak IBOutlet UIImageView *imgUserProfile;
    __weak IBOutlet UIButton *btnDiscovery;
    __weak IBOutlet UIButton *btnPushNotification;
    __weak IBOutlet UIButton *btnPrivateAccount;
    __weak IBOutlet UIView *viewDatePicker;
    __weak IBOutlet UIDatePicker *datePicker;
    __weak IBOutlet UIToolbar *toolBar;
    __weak IBOutlet UIView *viewPicker;
    __weak IBOutlet UIPickerView *pickerView;
    __weak IBOutlet UIButton *btnLogout;
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
