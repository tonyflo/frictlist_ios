//
//  AppDelegate.m
//  MMSampleApp
//
//
//  Copyright (c) 2010-2013 Millennial Media. All rights reserved.
//

#import "AppDelegate.h"
#import "BannerExampleViewController.h"
#import "CacheExampleViewController.h"
#import <MillennialMedia/MMSDK.h>

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MMSDK initialize]; // Initialize a Millennial Media session
    
    // Create a location manager for passing location data for conversion tracking and ad requests
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager startUpdatingLocation];
    
    // Create an MMRequest object to pass location and metadata for conversion tracking
    MMRequest *request = [MMRequest requestWithLocation:self.locationManager.location];
    
    // Track a conversion for your Goal ID
    [MMSDK trackConversionWithGoalId:@"YOUR_GOAL_ID" requestData:request];
    
    // Create the window and views
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    UIViewController *tab1VC, *tab2VC;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        tab1VC = [[BannerExampleViewController alloc] initWithNibName:@"BannerExampleViewController_iPhone" bundle:nil];
        tab2VC = [[CacheExampleViewController alloc] initWithNibName:@"CacheExampleViewController_iPhone" bundle:nil];

    } else {
        tab1VC = [[BannerExampleViewController alloc] initWithNibName:@"BannerExampleViewController_iPad" bundle:nil];
        tab2VC = [[CacheExampleViewController alloc] initWithNibName:@"CacheExampleViewController_iPad" bundle:nil];

    }
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:tab1VC, tab2VC, nil];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];

    return YES;
}

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
    // Fetch an interstitial when the app becomes active after launch, interruption, or when
    // resuming from a background state. This is good practice to ensure that you always have
    // an interstitial to display.
    
//    [MMInterstitial fetchWithRequest:[MMRequest requestWithLocation:self.locationManager.location]
//                                apid:INTERSTITIAL_APID
//                        onCompletion:^(BOOL success, NSError *error) {
//                            if (success) {
//                                NSLog(@"Ad available");
//                            }
//                            else {
//                                NSLog(@"Error fetching ad: %@", error);
//                            }
//                        }];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
