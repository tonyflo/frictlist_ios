//
//  PlistHelper.m
//  Frictlist
//
//  Created by Tony Flo on 1/14/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import "PlistHelper.h"

@implementation PlistHelper

NSString *defaultPk = @"-1";
NSString *defaultEmail = @"Not Signed In";
NSMutableArray *defaultHuId;
NSMutableArray *defaultFirst;
NSMutableArray *defaultLast;
NSMutableArray *defaultBase;
NSMutableArray *defaultAccepted;

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

-(int)getPk
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    int uid = [[plistDict objectForKey:@"pk"] intValue];
    return uid;
}

-(int)getFirst
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    int first = [[plistDict objectForKey:@"first"] intValue];
    return first;
}

-(NSMutableArray *)getHuIdArray
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSMutableArray * huidArray = [plistDict objectForKey:@"huid"];
    NSLog(@"plist: %@", huidArray);
    return huidArray;
}

-(NSMutableArray *)getFirstNameArray
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSMutableArray * firstNameArray = [plistDict objectForKey:@"fn"];
    return firstNameArray;
}

-(NSMutableArray *)getLastNameArray
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSMutableArray * lastNameArray = [plistDict objectForKey:@"ln"];
    return lastNameArray;
}

//setters
-(void)setEmail:(NSString *)email
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    [data setObject:email forKey:@"email"];
    [data writeToFile: path atomically:YES];
}

-(void)setPk:(int)pk
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    [data setObject:[NSString stringWithFormat:@"%d", pk] forKey:@"pk"];
    [data writeToFile: path atomically:YES];
}

-(void)setFirst:(int)first
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    [data setObject:[NSString stringWithFormat:@"%d", first] forKey:@"first"];
    [data writeToFile: path atomically:YES];
}

//adders

-(void)addHuId:(int)huid
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * huidArray =[data objectForKey:@"huid"];
    [huidArray addObject:[NSString stringWithFormat:@"%d", huid]];
    [data setObject:huidArray forKey:@"huid"];
    [data writeToFile: path atomically:YES];
}

-(void)addFirst:(NSString *)fn
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * fnArray =[data objectForKey:@"fn"];
    [fnArray addObject:fn];
    [data setObject:fnArray forKey:@"fn"];
    [data writeToFile: path atomically:YES];
}

-(void)addLast:(NSString *)ln
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * lnArray =[data objectForKey:@"ln"];
    [lnArray addObject:ln];
    [data setObject:lnArray forKey:@"ln"];
    [data writeToFile: path atomically:YES];
}

-(void)addFrict:(int)huid first:(NSString *)fn last:(NSString *)ln
{
    [self addHuId:huid];
    [self addFirst:fn];
    [self addLast:ln];
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

-(int)resetPk
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    [data setObject:defaultPk forKey:@"pk"];
    [data writeToFile: path atomically:YES];
    return [defaultPk integerValue];
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
        defaultHuId = [[NSMutableArray alloc] initWithObjects:@"-1", nil];
        defaultFirst = [[NSMutableArray alloc] initWithObjects:@"Jena", nil];
        defaultLast = [[NSMutableArray alloc] initWithObjects:@"Nooch", nil];
        defaultBase = [[NSMutableArray alloc] initWithObjects:@"3", nil];
        defaultAccepted = [[NSMutableArray alloc] initWithObjects:@"1", nil];
        
        // If the file doesn’t exist, create an empty dictionary
        data = [[NSMutableDictionary alloc] init];
        [data setObject:defaultEmail forKey:@"email"]; //email
        [data setObject:defaultPk forKey:@"pk"]; //primary key
        [data setObject:@"1" forKey:@"first"]; //1 if first time opening app
        [data setObject:defaultHuId forKey:@"huid"]; //hookup ids
        [data setObject:defaultFirst forKey:@"fn"]; //first name array
        [data setObject:defaultLast forKey:@"ln"]; //last name array
        [data setObject:defaultBase forKey:@"base"]; //bases
        [data setObject:defaultAccepted forKey:@"accept"]; //accepted status
        [data writeToFile: path atomically:YES];
    }
    
    return data;
}

@end
