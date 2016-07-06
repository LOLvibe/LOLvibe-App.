//
//  CreateGroupController.m
//  LOLvibe
//
//  Created by Jaydip Godhani on 28/05/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "CreateGroupController.h"
#import "ServiceConstant.h"
#import "AddMemberController.h"

@interface CreateGroupController ()

@end

@implementation CreateGroupController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setDefualtProperties];
}

-(void)setDefualtProperties
{
    imgGroupIcon.layer.cornerRadius = imgGroupIcon.frame.size.height/2;
    imgGroupIcon.layer.masksToBounds = YES;
    
    tapOnImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnGroupIcon:)];
    tapOnImage.numberOfTapsRequired = 1.0;
    tapOnImage.delegate = self;
    [imgGroupIcon addGestureRecognizer:tapOnImage];
}

-(void)tapOnGroupIcon:(UITapGestureRecognizer *)recognizer
{
    [self pickImage];
}

#pragma mark --Image Picker Controller--
-(void)pickImage
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:App_Name
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:@"Choose From Gallery"
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               [self openPhotoAlbum];
                                                           }];
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"Take your Image"
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              [self showCamera];
                                                          }];
    UIAlertAction *thirdAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                          style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                                              
                                                          }];
    
    [alert addAction:firstAction];
    [alert addAction:secondAction];
    [alert addAction:thirdAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *img = info[UIImagePickerControllerEditedImage];
    
    imgGroupIcon.image = img;
    //dataImage = UIImageJPEGRepresentation(imgProfilePic.image, 0.0);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showCamera
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    [controller setAllowsEditing:YES];
    [controller setDelegate:self];
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)openPhotoAlbum
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [controller setAllowsEditing:YES];
    [controller setDelegate:self];
    [self presentViewController:controller animated:YES completion:NULL];
}

#pragma mark Next Button
- (IBAction)btnNext:(UIButton *)sender
{
    if(txtGroupName.text.length == 0)
    {
        [GlobalMethods displayAlertWithTitle:App_Name andMessage:@"Please enter Subject Name."];
    }
    else
    {
        [self performSegueWithIdentifier:@"addMember" sender:self];
    }
}



#pragma mark PrepareForSegue Method
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"addMember"])
    {
        AddMemberController *obj = [segue destinationViewController];
        obj.strGroupName = txtGroupName.text;
        obj.dataImag = UIImageJPEGRepresentation(imgGroupIcon.image, 0.8);
        obj.strAddMember = @"group";
    }
}

#pragma mark Cancel Button
- (IBAction)btnCancel:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark Textfield Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * proposedNewString = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    
    int total = (int)proposedNewString.length;
    
    int remaining =25-total;
    
    if (remaining <= 0 )
    {
        lblCount.text = @"0";
    }
    else
    {
        lblCount.text = [NSString stringWithFormat:@"%d",remaining];
    }
    
    
    return textField.text.length + (string.length - range.length) <= 25;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}





@end
