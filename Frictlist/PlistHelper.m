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
NSMutableArray *defaultFrom;
NSMutableArray *defaultTo;
NSMutableArray *defaultNotes;
NSMutableArray *defaultGender;

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

-(NSMutableArray *)getBaseArray
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSMutableArray * baseArray = [plistDict objectForKey:@"base"];
    return baseArray;
}

-(NSMutableArray *)getAcceptedArray
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSMutableArray * accepted = [plistDict objectForKey:@"accept"];
    return accepted;
}

-(NSMutableArray *)getFromArray
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSMutableArray * from = [plistDict objectForKey:@"from"];
    return from;
}

-(NSMutableArray *)getToArray
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSMutableArray * to = [plistDict objectForKey:@"to"];
    return to;
}

-(NSMutableArray *)getNoteArray
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSMutableArray * notes = [plistDict objectForKey:@"note"];
    return notes;
}

-(NSMutableArray *)getGenderArray
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSMutableArray * gender = [plistDict objectForKey:@"gender"];
    return gender;
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

-(void)addBase:(int)base
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * baseArray =[data objectForKey:@"base"];
    [baseArray addObject:[NSString stringWithFormat:@"%d", base]];
    [data setObject:baseArray forKey:@"base"];
    [data writeToFile: path atomically:YES];
}

-(void)addAccepted:(int)accept
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * acceptArray =[data objectForKey:@"accept"];
    [acceptArray addObject:[NSString stringWithFormat:@"%d", accept]];
    [data setObject:acceptArray forKey:@"accept"];
    [data writeToFile: path atomically:YES];
}

-(void)addFrom:(NSString *)from
{
    NSLog(@"From date: %@", from);
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * fromArray =[data objectForKey:@"from"];
    [fromArray addObject:from];
    [data setObject:fromArray forKey:@"from"];
    [data writeToFile: path atomically:YES];
}

-(void)addTo:(NSString *)to
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * toArray =[data objectForKey:@"to"];
    [toArray addObject:to];
    [data setObject:toArray forKey:@"to"];
    [data writeToFile: path atomically:YES];
}

-(void)addNote:(NSString *)note
{
    NSLog(@"set note: %@", note);
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * noteArray =[data objectForKey:@"note"];
    [noteArray addObject:note];
    [data setObject:noteArray forKey:@"note"];
    [data writeToFile: path atomically:YES];
}

-(void)addGender:(int)gender
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * genderArray =[data objectForKey:@"gender"];
    [genderArray addObject:[NSString stringWithFormat:@"%d", gender]];
    [data setObject:genderArray forKey:@"gender"];
    [data writeToFile: path atomically:YES];
}

-(void)addFrict:(int)huid first:(NSString *)fn last:(NSString *)ln base:(int)base accepted:(int)accepted from:(NSString *)from to:(NSString *)to notes:(NSString *)notes gender:(int)gender
{
    [self addHuId:huid];
    [self addFirst:fn];
    [self addLast:ln];
    [self addBase:base];
    [self addAccepted:accepted];
    [self addFrom:from];
    [self addTo:to];
    [self addNote:notes];
    [self addGender:gender];
}

//updaters
-(void)updateHuId:(int)index huid:(int)huid
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * huidArray =[data objectForKey:@"huid"];
    [huidArray setObject:[NSString stringWithFormat:@"%d", huid] atIndexedSubscript:index];
    [data setObject:huidArray forKey:@"huid"];
    [data writeToFile: path atomically:YES];
}

-(void)updateFirst:(int)index fn:(NSString *)fn
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * fnArray =[data objectForKey:@"fn"];
    [fnArray setObject:fn atIndexedSubscript:index];
    [data setObject:fnArray forKey:@"fn"];
    [data writeToFile: path atomically:YES];
}

-(void)updateLast:(int)index ln:(NSString *)ln
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * lnArray =[data objectForKey:@"ln"];
    [lnArray setObject:ln atIndexedSubscript:index];
    [data setObject:lnArray forKey:@"ln"];
    [data writeToFile: path atomically:YES];
}

-(void)updateBase:(int)index base:(int)base
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * baseArray =[data objectForKey:@"base"];
    [baseArray setObject:[NSString stringWithFormat:@"%d", base] atIndexedSubscript:index];
    [data setObject:baseArray forKey:@"base"];
    [data writeToFile: path atomically:YES];
}

-(void)updateAccepted:(int)index accept:(int)accept
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * acceptArray =[data objectForKey:@"accept"];
    [acceptArray setObject:[NSString stringWithFormat:@"%d", accept] atIndexedSubscript:index];
    [data setObject:acceptArray forKey:@"accept"];
    [data writeToFile: path atomically:YES];
}

-(void)updateFrom:(int)index from:(NSString *)from
{
    NSLog(@"From date: %@", from);
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * fromArray =[data objectForKey:@"from"];
    [fromArray setObject:from atIndexedSubscript:index];
    [data setObject:fromArray forKey:@"from"];
    [data writeToFile: path atomically:YES];
}

-(void)updateTo:(int)index to:(NSString *)to
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * toArray =[data objectForKey:@"to"];
    [toArray setObject:to atIndexedSubscript:index];
    [data setObject:toArray forKey:@"to"];
    [data writeToFile: path atomically:YES];
}

-(void)updateNote:(int)index note:(NSString *)note
{
    NSLog(@"set note: %@", note);
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * noteArray =[data objectForKey:@"note"];
    [noteArray setObject:note atIndexedSubscript:index];
    [data setObject:noteArray forKey:@"note"];
    [data writeToFile: path atomically:YES];
}

-(void)updateGender:(int)index gender:(int)gender
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * genderArray =[data objectForKey:@"gender"];
    [genderArray setObject:[NSString stringWithFormat:@"%d", gender] atIndexedSubscript:index];
    [data setObject:genderArray forKey:@"gender"];
    [data writeToFile: path atomically:YES];
}

-(void)updateFrict:(int)huid index:(int)index first:(NSString *)fn last:(NSString *)ln base:(int)base accepted:(int)accepted from:(NSString *)from to:(NSString *)to notes:(NSString *)notes gender:(int)gender
{

    [self updateHuId:index huid:huid];
    [self updateFirst:index fn:fn];
    [self updateLast:index ln:ln];
    [self updateBase:index base:base];
    [self updateAccepted:index accept:accepted];
    [self updateFrom:index from:from];
    [self updateTo:index to:to];
    [self updateNote:index note:notes];
    [self updateGender:index gender:gender];
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
        defaultHuId = [[NSMutableArray alloc] initWithObjects:@"0", nil];
        defaultFirst = [[NSMutableArray alloc] initWithObjects:@"0", nil];
        defaultLast = [[NSMutableArray alloc] initWithObjects:@"0", nil];
        defaultBase = [[NSMutableArray alloc] initWithObjects:@"0", nil];
        defaultAccepted = [[NSMutableArray alloc] initWithObjects:@"0", nil];
        defaultFrom = [[NSMutableArray alloc] initWithObjects:@"0", nil];;
        defaultTo = [[NSMutableArray alloc] initWithObjects:@"0", nil];;
        defaultNotes = [[NSMutableArray alloc] initWithObjects:@"0", nil];;
        defaultGender = [[NSMutableArray alloc] initWithObjects:@"0", nil];;
        
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
        [data setObject:defaultFrom forKey:@"from"]; //from date
        [data setObject:defaultTo forKey:@"to"]; //to date
        [data setObject:defaultNotes forKey:@"note"]; //notes
        [data setObject:defaultGender forKey:@"gender"]; //gender
        [data writeToFile: path atomically:YES];
    }
    
    return data;
}

@end
