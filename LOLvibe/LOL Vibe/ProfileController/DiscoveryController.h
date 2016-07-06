//
//  DiscoveryController.h
//  LOLvibe
//
//  Created by Jaydip Godhani on 14/05/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMRangeSlider.h"



@interface DiscoveryController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate>
{
    __weak IBOutlet UILabel *lblLocationName;
    __weak IBOutlet UISlider *slideDistance;
    __weak IBOutlet UILabel *lblDistance;
    __weak IBOutlet UILabel *lowerAge;
    __weak IBOutlet UILabel *uperAge;
    
    __weak IBOutlet UILabel *lblViebeName;
    __weak IBOutlet UIView *viewPicker;
    __weak IBOutlet UIPickerView *pickerView;
    __weak IBOutlet UIToolbar *toolBar;
    __weak IBOutlet UIButton *btnGender;
}

@property (strong, nonatomic) NSDictionary *dictDiscovery;

@property (weak, nonatomic) IBOutlet NMRangeSlider *labelSlider;
- (IBAction)labelSliderChanged:(NMRangeSlider*)sender;

- (IBAction)btnShowMeinSearch:(UIButton *)sender;
- (IBAction)btnChooseGender:(UIButton *)sender;
- (IBAction)cancelPicker:(UIBarButtonItem *)sender;
- (IBAction)sliderDistance:(UISlider *)sender;
- (IBAction)btnGetLocation:(UIButton *)sender;
- (IBAction)donePicker:(UIBarButtonItem *)sender;
@end
