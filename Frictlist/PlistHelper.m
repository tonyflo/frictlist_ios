//
//  PlistHelper.m
//  Frictlist
//
//  Created by Tony Flo on 1/14/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import "PlistHelper.h"

@implementation PlistHelper

int defaultPk = -1;
NSString *defaultEmail = @"Not Signed In";
NSString *defaultBirthday = @"0000-00-00";
NSString *defaultFirstName = @"";
NSString *defaultLastName = @"";
int defaultSaveLogin = 1;
int defaultLoggedIn = 0;

//getters
-(NSString *)getEmail
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSString * email = [plistDict objectForKey:@"email"];
    return email;
}

-(NSString *)getBirthday
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSString * bday = [plistDict objectForKey:@"bday"];
    return bday;
}

-(NSString *)getFirstName
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSString * first = [plistDict objectForKey:@"first"];
    return first;
}

-(NSString *)getLastName
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSString * last = [plistDict objectForKey:@"last"];
    return last;
}

-(int)getPk
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    int uid = [[plistDict objectForKey:@"pk"] intValue];
    if(uid == 0)
    {
        uid = -1;
    }
    return uid;
}

-(int)getSaveLogin
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    int saveLogin = [[plistDict objectForKey:@"save_login"] intValue];

    return saveLogin;
}

-(int)getLoggedIn
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    int loggedIn = [[plistDict objectForKey:@"logged_in"] intValue];
    
    return loggedIn;
}

//setters
-(void)setEmail:(NSString *)email
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    [data setObject:email forKey:@"email"];
    [data writeToFile: path atomically:YES];
}

-(void)setBirthday:(NSString *)bday
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    [data setObject:bday forKey:@"bday"];
    [data writeToFile: path atomically:YES];
}

-(void)setFirstName:(NSString *)first
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    [data setObject:first forKey:@"first"];
    [data writeToFile: path atomically:YES];
}

-(void)setLastName:(NSString *)last
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    [data setObject:last forKey:@"last"];
    [data writeToFile: path atomically:YES];
}

-(void)setPk:(int)pk
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    [data setObject:[NSString stringWithFormat:@"%d", pk] forKey:@"pk"];
    [data writeToFile: path atomically:YES];
}

-(void)setSaveLogin:(int)saveLogin
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    [data setObject:[NSString stringWithFormat:@"%d", saveLogin] forKey:@"save_login"];
    [data writeToFile: path atomically:YES];
}

-(void)setLoggedIn:(int)loggedIn
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    [data setObject:[NSString stringWithFormat:@"%d", loggedIn] forKey:@"logged_in"];
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

-(NSString *)resetBirthday
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    [data setObject:defaultBirthday forKey:@"bday"];
    [data writeToFile: path atomically:YES];
    return defaultBirthday;
}

-(NSString *)resetFirstName
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    [data setObject:defaultFirstName forKey:@"first"];
    [data writeToFile: path atomically:YES];
    return defaultFirstName;
}

-(NSString *)resetLastName
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    [data setObject:defaultLastName forKey:@"last"];
    [data writeToFile: path atomically:YES];
    return defaultLastName;
}

-(int)resetPk
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    [data setObject:[NSNumber numberWithInt:defaultPk ] forKey:@"pk"];
    [data writeToFile: path atomically:YES];
    return defaultPk;
}

-(int)resetSaveLogin
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    [data setObject:[NSNumber numberWithInt:defaultSaveLogin ] forKey:@"save_login"];
    [data writeToFile: path atomically:YES];
    return defaultSaveLogin;
}

-(int)resetLoggedIn
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    [data setObject:[NSNumber numberWithInt:defaultLoggedIn ] forKey:@"logged_in"];
    [data writeToFile: path atomically:YES];
    return defaultLoggedIn;
}


-(id)initDefaults
{
    [self getPlistData:[self getPlistPath]];
    return self;
}

-(id)resetPlist
{
    [self removePlistFile];
    [self getPlistData:[self getPlistPath]];
    return self;
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

- (BOOL)removePlistFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"plist.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
        
    BOOL status = true;
    
    if ([fileManager fileExistsAtPath: path])
    {
        status = [fileManager removeItemAtPath:path error:nil];
    }
    
    return status;
}

-(NSMutableDictionary *) getPlistData:path
{
    NSMutableDictionary *data;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //populate the plist
    if ([fileManager fileExistsAtPath: path])
    {
        NSLog(@"found plist");
        data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    }
    else
    {
         NSLog(@"creating plist");
        //file doesn't exist, so set defaults
        data = [[NSMutableDictionary alloc] init];
        [data setObject:defaultEmail forKey:@"email"]; //email
        [data setObject:defaultFirstName forKey:@"first"]; //first name
        [data setObject:defaultLastName forKey:@"last"]; //last name
        [data setObject:[NSNumber numberWithInt:defaultPk ] forKey:@"pk"]; //primary key
        [data setObject:defaultBirthday forKey:@"bday"]; //birthday
        [data setObject:[NSNumber numberWithInt:defaultSaveLogin ] forKey:@"save_login"]; //save login
        [data setObject:[NSNumber numberWithInt:defaultLoggedIn ] forKey:@"logged_in"]; //currently logged in?

        NSLog(@"default pk is %@", [NSNumber numberWithInt:defaultPk ]);
    }
    
    return data;
}

@end
