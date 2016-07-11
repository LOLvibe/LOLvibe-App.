//
//  CustomTabBarController.m
//  CustomTabBarDemo
//
//  Created by Sunil Zalavadiya on 17/11/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import "CustomTabBarController.h"
#import "CustomTabBarView.h"
#import "VibeUpdateVc.h"

@interface CustomTabBarController () <CustomTabBarViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{

}
@property (strong, nonatomic) CustomTabBarView *tabBarView;
@end

@implementation CustomTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    NSMutableArray *viewControllers = [NSMutableArray array];
    
    UINavigationController *navHome = [self.storyboard instantiateViewControllerWithIdentifier:@"navHome"];
    
    [viewControllers addObject:navHome];
    

    UINavigationController *navNotification = [self.storyboard instantiateViewControllerWithIdentifier:@"navNotification"];
    
    [viewControllers addObject:navNotification];
    
    UINavigationController *navCamera = [self.storyboard instantiateViewControllerWithIdentifier:@"navCamera"];
    
    [viewControllers addObject:navCamera];
    
    UINavigationController *navChats = [self.storyboard instantiateViewControllerWithIdentifier:@"navChat"];
    
    [viewControllers addObject:navChats];
    UINavigationController *navProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"navProfile"];
    
    [viewControllers addObject:navProfile];
    
    self.viewControllers =viewControllers;
    
    self.tabBarView = [[[NSBundle mainBundle] loadNibNamed:@"CustomTabBarView" owner:nil options:nil] lastObject]; // "MyTabBar" is the name of the .xib file
    self.tabBarView.frame = CGRectMake(0.0,
                                   self.view.frame.size.height - self.tabBarView.frame.size.height,
                                   self.view.frame.size.width,
                                   self.tabBarView.frame.size.height); // make it overlay your actual tab bar
    
    self.tabBarView.lblNotif.layer.cornerRadius = 5.0;
    self.tabBarView.lblNotif.layer.masksToBounds = YES;
    
    self.tabBarView.lblNotifChat.layer.cornerRadius = 5.0;
    self.tabBarView.lblNotifChat.layer.masksToBounds = YES;
    
    [self.tabBarView.lblNotif setHidden:YES];
    [self.tabBarView.lblNotifChat setHidden:YES];
    
    self.tabBarView.delegate = self;
    
    [self.view addSubview:self.tabBarView];

    [self.tabBarView layoutIfNeeded];
    
    [self.tabBarView.btn1 setSelected:YES];
    
    [self setSelectedViewController:self.viewControllers[0]];
}
-(void)showNotification
{
    [self.tabBarView.btn1 setSelected:NO];
    [self.tabBarView.btn3 setSelected:NO];
    [self.tabBarView.btn4 setSelected:NO];
    [self.tabBarView.btn5 setSelected:NO];
    
    [self.tabBarView.btn2 setSelected:YES];
    [self setSelectedViewController:self.viewControllers[1]];
}

-(void)showChatScreen
{
    [self.tabBarView.btn1 setSelected:NO];
    [self.tabBarView.btn2 setSelected:NO];
    [self.tabBarView.btn3 setSelected:NO];
    [self.tabBarView.btn4 setSelected:YES];
    [self.tabBarView.btn5 setSelected:NO];
    
    [self setSelectedViewController:self.viewControllers[3]];
}
-(void)showNotifIcon
{
    [self.tabBarView.lblNotif setHidden:NO];
}

-(void)hideNotifIcon
{
    [self.tabBarView.lblNotif setHidden:YES];
}

-(void)showNotifIconCHAT
{
    [self.tabBarView.lblNotifChat setHidden:NO];
}

-(void)hideNotifIconCHAT
{
    [self.tabBarView.lblNotifChat setHidden:YES];
}

-(void)tabSelectedAtIndex:(NSInteger)tabIndex
{
    if (tabIndex == 1)
    {
        [self hideNotifIcon];
    }
    else if (tabIndex == 3)
    {
        [self hideNotifIconCHAT];
    }
    
    [self setSelectedViewController:[self.viewControllers objectAtIndex:tabIndex]];
}


- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    if ([self.viewControllers indexOfObject:selectedViewController] == 2)
    {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        [controller setAllowsEditing:YES];
        [controller setDelegate:self];
        [self presentViewController:controller animated:YES completion:NULL];
    }
    else
    {
        if (self.selectedViewController == selectedViewController)
        {
            [(UINavigationController *)self.selectedViewController popToRootViewControllerAnimated:NO]; // pop to root if tapped the same controller twice
        }
        [super setSelectedViewController:selectedViewController];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
//    dummyImage.image = info[UIImagePickerControllerEditedImage];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self performSegueWithIdentifier:@"show_vibe_post" sender:info[UIImagePickerControllerEditedImage]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"show_vibe_post"])
    {
        UINavigationController *navc =[segue destinationViewController];
        
        VibeUpdateVc *vc = [navc.viewControllers objectAtIndex:0];
        vc.cameraImage = sender;
        vc.isFromCameraTab = YES;
    }
}


@end
