//
//  DeviceTokenHelper.h
//  Frictlist
//
//  Created by Tony Flo on 4/30/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceTokenHelper : NSObject

-(id)initDefaults;

-(NSString *)getDeviceToken;
-(void)setDeviceToken:(NSString *)last;

@end
