//
//  AppDelegate.h
//  LOL Vibe
//
//  Created by Paras Navadiya on 26/04/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CustomTabBarController.h"
#import "ViewController.h"



@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (retain, nonatomic)NSDictionary *pushNotifInfo;
@property (strong, nonatomic)CustomTabBarController *tabbarController;
@property (strong, nonatomic)ViewController *vc;
@property (strong, nonatomic)NSString   *strLon;
@property (strong, nonatomic)NSString   *strLat;
@property (strong, nonatomic)NSString   *strCityStateCountry;
@property (retain, nonatomic)UIStoryboard *storyboard;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(void)createTabbar;
-(void)setLoginView;

+(AppDelegate *)sharedDelegate;


@end

