//
//  RevMobHelper.m
//  Frictlist
//
//  Created by Tony Flo on 5/29/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import "RevMobHelper.h"
#import "version.h"
#import <RevMobAds/RevMobAds.h>
#import "FrictlistAppDelegate.h"
#import "AdHelper.h"

@implementation RevMobHelper

-(void) getUserData
{
    AdHelper * ah = [AdHelper alloc];
    [ah getAdMetadata];
 
    int gender = [ah getGender];
    NSDate * bday = [ah getBday];
    
    [RevMobAds session].userBirthday =  bday;
    [RevMobAds session].userGender = gender;
}

@end
