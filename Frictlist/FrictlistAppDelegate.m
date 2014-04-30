//
//  FrictlistAppDelegate.m
//  Frictlist
//
//  Created by Tony Flo on 6/16/13.
//  Copyright (c) 2013 FLooReeDA. All rights reserved.
//

#import "FrictlistAppDelegate.h"
#import "PlistHelper.h"
#import "SqlHelper.h"
#import "StatisticsViewController.h"

#import <MillennialMedia/MMInterstitial.h>

@implementation FrictlistAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //mmedia
    [MMSDK initialize]; //Initialize a Millennial Media session
    
    //Create a location manager for passing location data for conversion tracking and ad requests
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager startUpdatingLocation];
    
    //apns
    // Override point for customization after application launch.
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    return YES;
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

//determine if the user wants to be signed out, and sign out if so
-(void)signout
{
    PlistHelper *plist = [[PlistHelper alloc] initDefaults];
    if([plist getSaveLogin] != 1)
    {
        //sign out
        [plist resetPlist];
        
        SqlHelper *sql = [[SqlHelper alloc] init];
        [sql removeSqliteFile];
        
        //go to home screen
        [self goToHomeTab];
        
        //logout
        [plist resetLoggedIn];
        
        NSLog(@"Bye");
    }
}

-(void)goToHomeTab
{
    UITabBarController *tbc = (UITabBarController *)self.window.rootViewController;
    [tbc setSelectedIndex:1];
}

-(void)fetchInterstatialAd
{
    //Location Object
    FrictlistAppDelegate *appDelegate = (FrictlistAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //MMRequest Object
    MMRequest *request = [MMRequest requestWithLocation:appDelegate.locationManager.location];
    
    //Replace YOUR_APID with the APID provided to you by Millennial Media
    [MMInterstitial fetchWithRequest:request
                                apid:@"161158" //add mate
                        onCompletion:^(BOOL success, NSError *error) {
                            if (success) {
                                NSLog(@"Ad available");
                            }
                            else {
                                NSLog(@"Error fetching ad: %@", error);
                            }
                        }];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    //[self signout];
    //pull down of the notification bar triggers this
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self signout];
    
}



- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    PlistHelper *plist = [[PlistHelper alloc] initDefaults];
    //if user was logged in and wants to login everytime
    if([plist getSaveLogin] != 1 && [plist getPk] <= 0)
    {
        NSLog(@"Application did become active");
        [self goToHomeTab];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self signout];
}

@end
