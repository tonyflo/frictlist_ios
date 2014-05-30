//
//  AdHelper.m
//  Frictlist
//
//  Created by Tony Flo on 4/30/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import "version.h"
#import "AdHelper.h"
#import "PlistHelper.h"
#if defined(MMEDIA)
#import <MillennialMedia/MMAdView.h>
#endif

#if defined(REVMOB)
#import <RevMobAds/RevMobAds.h>
#endif

@implementation AdHelper

int gender;
NSNumber *age;
NSDate *bday;

-(void)getAdMetadata
{
    //get metadata for ads
    PlistHelper * plist = [PlistHelper alloc];
    gender = [plist getGender];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    bday = [formatter dateFromString:[plist getBirthday]];

    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSYearCalendarUnit
                                       fromDate:bday
                                       toDate:now
                                       options:0];
    age = [NSNumber numberWithInteger:[ageComponents year]];
}

-(NSDate *) getBday
{
    return bday;
}

-(NSNumber *) getAge
{
    return age;
}

-(int) getGender
{
#if defined(MMEDIA)
    return gender == 0 ? MMGenderMale : MMGenderFemale;;
#elif defined(REVMOB)
    return gender == 0 ? RevMobUserGenderMale : RevMobUserGenderFemale;
#else
    return gender;
#endif
}

@end
