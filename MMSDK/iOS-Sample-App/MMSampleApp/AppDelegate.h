//
//  AppDelegate.h
//  MMSampleApp
//
//
//  Copyright (c) 2010-2013 Millennial Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

@property (strong, nonatomic) CLLocationManager *locationManager;

@end
