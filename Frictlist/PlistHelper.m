//
//  PlistHelper.m
//  Frictlist
//
//  Created by Tony Flo on 1/14/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import "PlistHelper.h"

@implementation PlistHelper

NSString *defaultIvisited = @"00000000000000000000000000000000000000000000000000";
NSString *defaultPk = @"-1";
NSString *defaultEmail = @"Not Signed In";
NSString *defaultSync = @"Never";

-(id)initDefaults
{
    [self getPlistData:[self getPlistPath]];
    return self;
}

//getters
-(NSString *)getEmail
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSString * email = [plistDict objectForKey:@"email"];
    return email;
}

-(NSString *)getLastSyncDateTime
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSString * sync = [plistDict objectForKey:@"sync"];
    return sync;
}

-(int)getPk
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    int uid = [[plistDict objectForKey:@"pk"] intValue];
    return uid;
}

-(NSString *)getIvisited
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSString * visits = [plistDict objectForKey:@"ivisited"];
    return visits;
}

-(int)getFirst
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    int first = [[plistDict objectForKey:@"first"] intValue];
    return first;
}

//setters
-(void)setEmail:(NSString *)email
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    [data setObject:email forKey:@"email"];
    [data writeToFile: path atomically:YES];
}

-(void)setLastSyncDateTime:(NSString *)sync
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    [data setObject:sync forKey:@"sync"];
    [data writeToFile: path atomically:YES];
}

-(void)setPk:(int)pk
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    [data setObject:[NSString stringWithFormat:@"%d", pk] forKey:@"pk"];
    [data writeToFile: path atomically:YES];
}

-(void)setIvisited:(NSString *)ivisited
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    [data setObject:ivisited forKey:@"ivisited"];
    [data writeToFile: path atomically:YES];
}

-(void)setFirst:(int)first
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    [data setObject:[NSString stringWithFormat:@"%d", first] forKey:@"first"];
    [data writeToFile: path atomically:YES];
}

//resetters
-(NSString *)resetEmail
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    [data setObject:defaultEmail forKey:@"email"];
    [data writeToFile: path atomically:YES];
    return defaultEmail;
}

-(NSString *)resetLastSyncDateTime
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    [data setObject:defaultSync forKey:@"sync"];
    [data writeToFile: path atomically:YES];
    return defaultSync;
}

-(int)resetPk
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    [data setObject:defaultPk forKey:@"pk"];
    [data writeToFile: path atomically:YES];
    return [defaultPk integerValue];
}

-(NSString *)resetIvisited
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    [data setObject:defaultIvisited forKey:@"ivisited"];
    [data writeToFile: path atomically:YES];
    return defaultIvisited;
}

- (NSString *)getPlistPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"plist.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //create file if not exist
    if (![fileManager fileExistsAtPath: path])
    {
        path = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat: @"plist.plist"] ];
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
        data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    }
    else
    {
        // If the file doesn’t exist, create an empty dictionary
        data = [[NSMutableDictionary alloc] init];
        [data setObject:defaultEmail forKey:@"email"]; //email
        [data setObject:defaultPk forKey:@"pk"]; //primary key
        [data setObject:defaultIvisited forKey:@"ivisited"]; //ivisted
        [data setObject:defaultSync forKey:@"sync"]; //last sync datetime
        [data setObject:@"1" forKey:@"first"]; //1 if first time opening app
        [data writeToFile: path atomically:YES];
    }
    
    return data;
}

@end
