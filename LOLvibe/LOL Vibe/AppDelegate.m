//
//  AppDelegate.m
//  LOL Vibe
//
//  Created by Paras Navadiya on 26/04/16.
//  Copyright © 2016 Dreamcodesolution. All rights reserved.
//

#import "AppDelegate.h"
#import "LoggedInUser.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "ServiceConstant.h"
#import <CoreLocation/CoreLocation.h>


@interface AppDelegate ()<CLLocationManagerDelegate,UIAlertViewDelegate>
{
    CLLocationManager   *locationManager;
    CLGeocoder          *geocoder;
    CLPlacemark         *placemark;
    NSString            *strLon;
    NSString            *strLat;
    float               Longi;
    float               Latti;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    NSString *UUID = [[NSUserDefaults standardUserDefaults] objectForKey:@"device_id"];
    if (!UUID)
    {
        CFUUIDRef theUUID = CFUUIDCreate(NULL);
        CFStringRef string = CFUUIDCreateString(NULL, theUUID);
        CFRelease(theUUID);
        UUID = [(__bridge NSString*)string stringByReplacingOccurrencesOfString:@"-"withString:@""];
        
        [[NSUserDefaults standardUserDefaults] setValue:UUID forKey:@"device_id"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    self.storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    //----Push Notification Starts----
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    //----Push Notification Ends----
    
    [XmppHelper sharedInstance].servername = XMPP_SERVER_NAME;
    [XmppHelper sharedInstance].hostname = XMPP_HOST_NAME;
    [XmppHelper sharedInstance].groupChatDomainStr = XMPP_GROUP_DOMAIN;
    [XmppHelper sharedInstance].hostport = 5222;
    [[XmppHelper sharedInstance] setupStream];

    LoggedInUser *loggedInUser=[LoggedInUser sharedUser];
    if(loggedInUser.isUserLoggedIn)
    {
        [[XmppHelper sharedInstance] disconnect];
        
        [[XmppHelper sharedInstance] setUsername:[LoggedInUser sharedUser].userId andPassword:OPENFIRE_USER_PASSWORD];
        
        [[XmppHelper sharedInstance] connect];
        
        [self createTabbar];
    }
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    NSUInteger code = [CLLocationManager authorizationStatus];
    
    if (code == kCLAuthorizationStatusNotDetermined && ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]))
    {
        // choose one request according to your business.
        if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"])
        {
            [locationManager requestAlwaysAuthorization];
        }
        else if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"])
        {
            [locationManager  requestWhenInUseAuthorization];
        }
        else
        {
            NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
        }
    }
    
    [locationManager startUpdatingLocation];
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]!=nil)
    {
        self.pushNotifInfo =[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        [_tabbarController showNotification];
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if ([[kPref valueForKey:@"social"] isEqualToString:@"fb"])
    {
        BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                      openURL:url
                                                            sourceApplication:sourceApplication
                                                                   annotation:annotation];
        return handled;
    }
    
    return YES;
}

-(void)setLoginView
{
     UINavigationController *navChats = [self.storyboard instantiateViewControllerWithIdentifier:@"navController"];

    [self.window setRootViewController:navChats];
    [self.window makeKeyAndVisible];
}

-(void)createTabbar
{
    _tabbarController = [self.storyboard instantiateViewControllerWithIdentifier:@"CustomTabBarController"];
        
    [self.window setRootViewController:_tabbarController];
    [self.window makeKeyAndVisible];
}

+(AppDelegate *)sharedDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
//    NSString *message = @"Please allow to LOLvibe to use your Location in the Location Services Settings";
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:App_Name message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
//    alertView.tag = 1;
//    [alertView show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];

        }
    }
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil)
    {
        strLon = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        strLat = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        
        Latti =currentLocation.coordinate.latitude;
        Longi =currentLocation.coordinate.longitude;
        
        [locationManager stopUpdatingLocation];
    }
}
#pragma mark- Location Permision Method
- (void)requestAlwaysAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied)
    {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
        [alertView show];
    }
    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined)
    {
        [locationManager requestAlwaysAuthorization];
    }
}

#pragma mark -- Pushnotification Methods
-(void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"TokenNumber:-%@",[[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""]);
    
    NSString *StrdeviceToken=[[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (StrdeviceToken == nil || [StrdeviceToken length] == 0)
    {
        StrdeviceToken = @"";
    }
    if ([StrdeviceToken length] != 0)
    {
        [[NSUserDefaults standardUserDefaults] setValue:StrdeviceToken forKey:@"device_token"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"device_token"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
//    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"device_token"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
}

//For interactive notification only
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"])
    {
    }
    else if ([identifier isEqualToString:@"answerAction"])
    {
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"%@",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    self.pushNotifInfo = userInfo;
    
    [_tabbarController showNotification];
    
   // UIApplicationState state = [application applicationState];
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if([[[XmppHelper sharedInstance] xmppStream] isDisconnected] || ![[[XmppHelper sharedInstance] xmppStream] isAuthenticated])
        {
            if([[[XmppHelper sharedInstance] xmppStream] isConnected])
            {
                [[[XmppHelper sharedInstance] xmppStream] disconnect];
            }
            [[XmppHelper sharedInstance] connect];
        }
        else
        {
            //[[XmppHelper sharedInstance] goOnline];
        }
    });
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSDKAppEvents activateApp];
    
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self saveContext];
    [self setLastLogoutTimeForUser];
    [[XmppHelper sharedInstance] goOffline];
}




#pragma mark Logoot Time Out
-(void)setLastLogoutTimeForUser
{
    NSLog(@"JAYDIP GODHANI");
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"lastLogoutTimeDict"])
    {
        NSLog(@"dfdsfsdfasf GODHANI1");
        NSMutableDictionary *lastLogoutTimeDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"lastLogoutTimeDict"]];
        
        [lastLogoutTimeDict setObject:@([[NSDate date] timeIntervalSince1970]) forKey:[XmppHelper sharedInstance].username];
        NSLog(@"Time Stamp : %@",lastLogoutTimeDict);
        [[NSUserDefaults standardUserDefaults] setObject:lastLogoutTimeDict forKey:@"lastLogoutTimeDict"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        NSLog(@"dfdsfsdfasf GODHANI2");
        NSMutableDictionary *lastLogoutTimeDict = [NSMutableDictionary dictionary];
        
        [lastLogoutTimeDict setObject:@([[NSDate date] timeIntervalSince1970]) forKey:[XmppHelper sharedInstance].username];
        NSLog(@"Time Stamp : %@",lastLogoutTimeDict);
        [[NSUserDefaults standardUserDefaults] setObject:lastLogoutTimeDict forKey:@"lastLogoutTimeDict"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.dc.LOL_Vibe" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"LOL_Vibe" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"LOL_Vibe.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
