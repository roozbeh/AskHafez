//
//  HafezAppDelegate.m
//  AskHafezNative4
//
//  Created by Roozbeh on ۱۲/۱۱/۴.
//  Copyright (c) ۲۰۱۲ __MyCompanyName__. All rights reserved.
//

#import "HafezAppDelegate.h"

#import "GhazalsViewController.h"
#import "FaalPhoneViewController.h"
#import "SearchViewController.h"
#import "GAI.h"
#import "HafezAPI.h"

@implementation HafezAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

static NSString *const kAnalyticsAccountId = @"UA-36120510-1";
// Dispatch period in seconds.
static const NSInteger kDispatchPeriodSeconds = 10;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = kDispatchPeriodSeconds;
    [[GAI sharedInstance] trackerWithTrackingId:kAnalyticsAccountId];
    
    NSDictionary *userInfo = [launchOptions valueForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    
    if(apsInfo) {
        NSLog(@"application, didFinishLaunchingWithOptions, has apsInfo");
        
        NSString *link_url = apsInfo[@"link_url"];
        NSLog(@"application, didFinishLaunchingWithOptions, started by PushNote, link_url: %@", link_url);

        NSURL *url = [NSURL URLWithString:link_url];
        if([[url host] isEqualToString:@"ghazals"]) {
            
            NSLog(@"application, didFinishLaunchingWithOptions, url host is ghazals");
            
            NSArray* pathComponents = [link_url pathComponents];
            NSString *ghazalNumber = [pathComponents objectAtIndex:2];
            
            NSLog(@"application, didFinishLaunchingWithOptions, ghazalNumber: %@", ghazalNumber);
            
            [[HafezAPI instance] saveSetting:@"ghazalNumber" withValue:ghazalNumber];
        }
    }
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    // Override point for customization after application launch.
//    UIViewController *viewController1 = [[HafezFirstViewController alloc] initWithNibName:@"HafezFirstViewController" bundle:nil];
//    UIViewController *viewController2 = [[HafezSecondViewController alloc] initWithNibName:@"HafezSecondViewController" bundle:nil];
//    UIViewController *viewController3 = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
//    self.tabBarController = [[UITabBarController alloc] init];
//    self.tabBarController.viewControllers = [NSArray arrayWithObjects:viewController1, viewController2, viewController3, nil];
//    self.window.rootViewController = self.tabBarController;
//    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark -
#pragma mark GANTrackerDelegate methods

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
        NSLog(@"declineAction");
    }
    else if ([identifier isEqualToString:@"answerAction"]){
        NSLog(@"answerAction");
    }
}
#endif

- (void) application:(UIApplication *) application
didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken
{
    HafezAPI *api = [HafezAPI instance];
    
    NSString * deviceTokenString = [[[[deviceToken description]
                                      stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                     stringByReplacingOccurrencesOfString: @">" withString: @""]
                                    stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    [api sendToken:deviceTokenString];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"application, didReceiveRemoteNotification");
    
    if(application.applicationState == UIApplicationStateInactive) {

        NSLog(@"application, applicationState == UIApplicationStateActive");
        
        NSString *link_url = userInfo[@"aps"][@"link_url"];
        
        NSLog(@"application, didReceiveRemoteNotification, link_url: %@", link_url);
        
        NSURL *url = [NSURL URLWithString:link_url];
        if([[url host] isEqualToString:@"ghazals"]) {

            NSLog(@"application, didReceiveRemoteNotification, url host is ghazals");
            
            NSArray* pathComponents = [link_url pathComponents];
            NSString *ghazalNumber = [pathComponents objectAtIndex:2];
            
            NSLog(@"application, didReceiveRemoteNotification, ghazalNumber: %@", ghazalNumber);
            
            if ([GhazalsViewController instance] != nil) {
                NSLog(@"application, view found, navigating");
                
                [[GhazalsViewController instance] viewGhazal:ghazalNumber];
                
            } else {
                NSLog(@"application, view not found, saving in settings");
                
                [[HafezAPI instance] saveSetting:@"ghazalNumber" withValue:ghazalNumber];
            }
            
        }
    }
}

@end
