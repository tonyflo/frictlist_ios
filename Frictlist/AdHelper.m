//
//  AdHelper.m
//  Frictlist
//
//  Created by Tony Flo on 4/30/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import "AdHelper.h"
#import "PlistHelper.h"
#import <MillennialMedia/MMAdView.h>

@implementation AdHelper

int gender;
NSNumber *age;

-(void)getAdMetadata
{
    //get metadata for ads
    PlistHelper * plist = [PlistHelper alloc];
    gender = [plist getGender];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate * birthday = [formatter dateFromString:[plist getBirthday]];
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSYearCalendarUnit
                                       fromDate:birthday
                                       toDate:now
                                       options:0];
    age = [NSNumber numberWithInteger:[ageComponents year]];
}

-(NSNumber *) getAge
{
    return age;
}

-(int) getGender
{
    return gender == 0 ? MMGenderMale : MMGenderFemale;;
}

@end
