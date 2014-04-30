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
#import "version.h"

//ads
#import <MillennialMedia/MMInterstitial.h>

//apns
#import "DeviceTokenHelper.h"

@implementation FrictlistAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //apns
    // Override point for customization after application launch.
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    //mmedia
    [MMSDK initialize]; //Initialize a Millennial Media session
    
    //Create a location manager for passing location data for conversion tracking and ad requests
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager startUpdatingLocation];
    
    return YES;
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
                                apid:APID_INTERSTATIAL_ADD_FRICT //add mate
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

    //load ad into cache
    [self fetchInterstatialAd];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self signout];
}


//get frictlist
-(BOOL) update_apns_token:(int)uid deviceToken:(NSString *)deviceToken
{
    BOOL rc = true;
    
    NSString *post = [NSString stringWithFormat:@"&uid=%d&token=%@",uid, deviceToken];
    
    //2. Encode the post string using NSASCIIStringEncoding and also the post string you need to send in NSData format.
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //You need to send the actual length of your data. Calculate the length of the post string.
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    //3. Create a Urlrequest with all the properties like HTTP method, http header field with length of the post string. Create URLRequest object and initialize it.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //Set the Url for which your going to send the data to that request.
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@update_apns_token.php", SCRIPTS_URL]]];
    
    //Now, set HTTP method (POST or GET). Write this lines as it is in your code
    [request setHTTPMethod:@"POST"];
    
    //Set HTTP header field with length of the post data.
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    //Also set the Encoded value for HTTP header Field.
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
    
    //Set the HTTPBody of the urlrequest with postData.
    [request setHTTPBody:postData];
    
    //4. Now, create URLConnection object. Initialize it with the URLRequest.
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    //It returns the initialized url connection and begins to load the data for the url request. You can check that whether you URL connection is done properly or not using just if/else statement as below.
    if(conn)
    {
        NSLog(@"Connection Successful");
    }
    else
    {
        NSLog(@"Connection could not be made");
        rc = false;
    }
    
    //5. To receive the data from the HTTP request , you can use the delegate methods provided by the URLConnection Class Reference. Delegate methods are as below
    return rc;
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSString *newToken = [deviceToken description];
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
	NSLog(@"My apns token is: %@", newToken);
    
    DeviceTokenHelper * dth = [[DeviceTokenHelper alloc] initDefaults];
    PlistHelper *plist = [PlistHelper alloc];
    int uid = [plist getPk];
    
    if(uid <= 0)
    {
        NSLog(@"user is not signed in");
        //if user is not signed in, save device token to plist
        //devicetoken can be sent to db once user signs in
        [dth setDeviceToken:newToken];
    }
    else
    {
        NSLog(@"user is signed in");
        //if user is signed in, update device token locally and remotly
        [self update_apns_token:uid deviceToken:newToken];
        [dth setDeviceToken:newToken];
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

@end
