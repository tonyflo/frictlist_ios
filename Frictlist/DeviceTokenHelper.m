//
//  DeviceTokenHelper.m
//  Frictlist
//
//  Created by Tony Flo on 4/30/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import "DeviceTokenHelper.h"

#define DEVICE_TOKEN_PLIST_FILE (@"device_token.plist")
#define DEVICE_TOKEN_KEY (@"token")

@implementation DeviceTokenHelper

NSString *defaultDeviceToken = @"-1";


-(NSString *)getDeviceToken
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSString * token = [plistDict objectForKey:DEVICE_TOKEN_KEY];
    return token;
}

-(void)setDeviceToken:(NSString *)token
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    [data setObject:token forKey:DEVICE_TOKEN_KEY];
    [data writeToFile: path atomically:YES];
}

-(id)initDefaults
{
    [self getPlistData:[self getPlistPath]];
    return self;
}


- (NSString *)getPlistPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:DEVICE_TOKEN_PLIST_FILE];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //create file if not exist
    if (![fileManager fileExistsAtPath: path])
    {
        path = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat: DEVICE_TOKEN_PLIST_FILE] ];
    }
    
    return path;
}

-(NSMutableDictionary *) getPlistData:path
{
    NSMutableDictionary *data;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //populate the plist
    if ([fileManager fileExistsAtPath: path])
    {
        NSLog(@"found device token helper");
        data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    }
    else
    {
        NSLog(@"creating device token helper");
        //file doesn't exist, so set defaults
        data = [[NSMutableDictionary alloc] init];
        [data setObject:defaultDeviceToken forKey:DEVICE_TOKEN_KEY]; //device token for apns
    }
    
    return data;
}


@end
