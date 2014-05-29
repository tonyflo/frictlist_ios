//
//  FrictlistAppDelegate.h
//  Frictlist
//
//  Created by Tony Flo on 6/16/13.
//  Copyright (c) 2013 FLooReeDA. All rights reserved.
//

#import <UIKit/UIKit.h>
#if defined(MMEDIA)
//mmedia
#import <MillennialMedia/MMSDK.h>
#endif
#import <CoreLocation/CoreLocation.h>

@interface FrictlistAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UIWindow *window;

@end
