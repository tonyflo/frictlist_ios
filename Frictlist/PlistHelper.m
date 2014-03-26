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
NSString *defaultBirthday = @"0000-00-00";
NSMutableArray *defaultHuId;
NSMutableArray *defaultFirst;
NSMutableArray *defaultLast;
NSMutableArray *defaultGender;

NSMutableArray *defaultFrictId;
NSMutableArray *defaultBase;
NSMutableArray *defaultAccepted;
NSMutableArray *defaultFrom;
NSMutableArray *defaultTo;
NSMutableArray *defaultNotes;


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

-(NSMutableArray *)getGenderArray
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSMutableArray * gender = [plistDict objectForKey:@"gender"];
    return gender;
}

-(NSMutableArray *)getFrictIdArray
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSMutableArray * frictidArray = [plistDict objectForKey:@"frictid"];
    return frictidArray;
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

-(void)addGender:(int)gender
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * genderArray =[data objectForKey:@"gender"];
    [genderArray addObject:[NSString stringWithFormat:@"%d", gender]];
    [data setObject:genderArray forKey:@"gender"];
    [data writeToFile: path atomically:YES];
}

//index for the following add functions is the local index of the mate
-(void)addFrictId:(int)index frictid:(int)frictid
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * frictidArray =[data objectForKey:@"frictid"];
    [[frictidArray objectAtIndex:index] addObject:[NSString stringWithFormat:@"%d", frictid]];
    [data setObject:frictidArray forKey:@"frictid"];
    [data writeToFile: path atomically:YES];
}

-(void)addBase:(int)index base:(int)base
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * baseArray =[data objectForKey:@"base"];
    [[baseArray objectAtIndex:index] addObject:[NSString stringWithFormat:@"%d", base]];
    [data setObject:baseArray forKey:@"base"];
    [data writeToFile: path atomically:YES];
}

-(void)addAccepted:(int)index accept:(int)accept
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * acceptArray =[data objectForKey:@"accept"];
    [[acceptArray objectAtIndex:index] addObject:[NSString stringWithFormat:@"%d", accept]];
    [data setObject:acceptArray forKey:@"accept"];
    [data writeToFile: path atomically:YES];
}

-(void)addFrom:(int)index from:(NSString *)from
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * fromArray =[data objectForKey:@"from"];
    [[fromArray objectAtIndex:index] addObject:from];
    [data setObject:fromArray forKey:@"from"];
    [data writeToFile: path atomically:YES];
}

-(void)addTo:(int)index to:(NSString *)to
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * toArray =[data objectForKey:@"to"];
    [[toArray objectAtIndex:index] addObject:to];
    [data setObject:toArray forKey:@"to"];
    [data writeToFile: path atomically:YES];
}

-(void)addNote:(int)index note:(NSString *)note
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * noteArray =[data objectForKey:@"note"];
    [[noteArray objectAtIndex:index] addObject:note];
    [data setObject:noteArray forKey:@"note"];
    [data writeToFile: path atomically:YES];
}

-(void)addFrict:(int)frictid huid:(int)huid base:(int)base accepted:(int)accepted from:(NSString *)from to:(NSString *)to notes:(NSString *)notes
{
    //get huid's index into the huid array
    NSArray * mateIdArray = [self getHuIdArray];
    
    int index = 0; //local mate index
    //get local index of mate's id
    for(; index < mateIdArray.count; index++)
    {
        if(huid == [[mateIdArray objectAtIndex:index] intValue])
        {
            break;
        }
    }
    
    NSLog(@"index into huid array is %d", index);
    //add frict data for this mate
    [self addFrictId:index frictid:frictid];
    NSLog(@"added frict id");
    [self addBase:index base:base];
    [self addAccepted:index accept:accepted];
    [self addFrom:index from:from];
    [self addTo:index to:to];
    [self addNote:index note:notes];
}

-(void)addMate:(int)mid first:(NSString *)fn last:(NSString *)ln gender:(int)gender

{
    [self addHuId:mid];
    [self addFirst:fn];
    [self addLast:ln];
    [self addGender:gender];
    
    [self addEmptyFrictArrays];
}

-(void)addEmptyFrictArrays
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    
    NSMutableArray * frictidArray =[data objectForKey:@"frictid"];
    NSMutableArray * baseArry =[data objectForKey:@"base"];
    NSMutableArray * acceptArray =[data objectForKey:@"accept"];
    NSMutableArray * fromArray =[data objectForKey:@"from"];
    NSMutableArray * toArray =[data objectForKey:@"to"];
    NSMutableArray * noteArray =[data objectForKey:@"note"];
    
    [frictidArray addObject:[[NSMutableArray alloc] initWithObjects:nil]];
    [baseArry addObject:[[NSMutableArray alloc] initWithObjects:nil]];
    [acceptArray addObject:[[NSMutableArray alloc] initWithObjects:nil]];
    [fromArray addObject:[[NSMutableArray alloc] initWithObjects:nil]];
    [toArray addObject:[[NSMutableArray alloc] initWithObjects:nil]];
    [noteArray addObject:[[NSMutableArray alloc] initWithObjects:nil]];
    
    [data setObject:frictidArray forKey:@"frictid"];
    [data setObject:baseArry forKey:@"base"];
    [data setObject:acceptArray forKey:@"accept"];
    [data setObject:fromArray forKey:@"from"];
    [data setObject:toArray forKey:@"to"];
    [data setObject:noteArray forKey:@"note"];
    
    NSLog(@"base array size: %d", [baseArry count]);
    
    [data writeToFile: path atomically:YES];
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

-(void)updateGender:(int)index gender:(int)gender
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * genderArray =[data objectForKey:@"gender"];
    [genderArray setObject:[NSString stringWithFormat:@"%d", gender] atIndexedSubscript:index];
    [data setObject:genderArray forKey:@"gender"];
    [data writeToFile: path atomically:YES];
}

-(void)updateBase:(int)mid_index frictid:(int)frictid_index base:(int)base
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * baseArray =[data objectForKey:@"base"];
    [[baseArray objectAtIndex:mid_index] setObject:[NSString stringWithFormat:@"%d", base] atIndexedSubscript:frictid_index];
    [data setObject:baseArray forKey:@"base"];
    [data writeToFile: path atomically:YES];
}

-(void)updateAccepted:(int)mid_index frictid:(int)frictid_index accept:(int)accept
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * acceptArray =[data objectForKey:@"accept"];
    [[acceptArray objectAtIndex:mid_index] setObject:[NSString stringWithFormat:@"%d", accept] atIndexedSubscript:frictid_index];
    [data setObject:acceptArray forKey:@"accept"];
    [data writeToFile: path atomically:YES];
}

-(void)updateFrom:(int)mid_index frictid:(int)frictid_index from:(NSString *)from
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * fromArray =[data objectForKey:@"from"];
    [[fromArray objectAtIndex:mid_index] setObject:from atIndexedSubscript:frictid_index];
    [data setObject:fromArray forKey:@"from"];
    [data writeToFile: path atomically:YES];
}

-(void)updateTo:(int)mid_index frictid:(int)frictid_index to:(NSString *)to
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * toArray =[data objectForKey:@"to"];
    [[toArray objectAtIndex:mid_index] setObject:to atIndexedSubscript:frictid_index];
    [data setObject:toArray forKey:@"to"];
    [data writeToFile: path atomically:YES];
}

-(void)updateNote:(int)mid_index frictid:(int)frictid_index note:(NSString *)note
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * noteArray =[data objectForKey:@"note"];
    [[noteArray objectAtIndex:mid_index] setObject:note atIndexedSubscript:frictid_index];
    [data setObject:noteArray forKey:@"note"];
    [data writeToFile: path atomically:YES];
}

//todo
-(void)updateFrict:(int)mid frict_id:(int)frict_id base:(int)base accepted:(int)accepted from:(NSString *)from to:(NSString *)to notes:(NSString *)notes
{
    //convert int to object
    NSNumber *mid_as_number = [NSNumber numberWithInt:mid];
    //get mid's index into the huid array
    int mid_index_as_int = [[self getHuIdArray] indexOfObject:mid_as_number];
    NSNumber *mid_index_as_number = [NSNumber numberWithInt:mid_index_as_int];
    //get frict_id's index into the frict_id array
    int frictid_index_as_int = [[self getFrictIdArray] indexOfObject:mid_index_as_number];
    
    //update frict data for this mate
    [self updateBase:mid_index_as_int frictid:(int)frictid_index_as_int base:base];
    [self updateAccepted:mid_index_as_int frictid:(int)frictid_index_as_int accept:accepted];
    [self updateFrom:mid_index_as_int frictid:(int)frictid_index_as_int from:from];
    [self updateTo:mid_index_as_int frictid:(int)frictid_index_as_int to:to];
    [self updateNote:mid_index_as_int frictid:(int)frictid_index_as_int note:notes];
}

-(void)updateMate:(int)mid index:(int)index first:(NSString *)fn last:(NSString *)ln gender:(int)gender
{
    [self updateHuId:index huid:mid];
    [self updateFirst:index fn:fn];
    [self updateLast:index ln:ln];
    [self updateGender:index gender:gender];
}

//removers
-(void)removeHuId:(int)index
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * huidArray =[data objectForKey:@"huid"];
    [huidArray removeObjectAtIndex:index];
    [data setObject:huidArray forKey:@"huid"];
    [data writeToFile: path atomically:YES];
}

-(void)removeFirst:(int)index
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * fnArray =[data objectForKey:@"fn"];
    [fnArray removeObjectAtIndex:index];
    [data setObject:fnArray forKey:@"fn"];
    [data writeToFile: path atomically:YES];
}

-(void)removeLast:(int)index
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * lnArray =[data objectForKey:@"ln"];
    [lnArray removeObjectAtIndex:index];
    [data setObject:lnArray forKey:@"ln"];
    [data writeToFile: path atomically:YES];
}

-(void)removeBase:(int)index
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * baseArray =[data objectForKey:@"base"];
    [baseArray removeObjectAtIndex:index];
    [data setObject:baseArray forKey:@"base"];
    [data writeToFile: path atomically:YES];
}

-(void)removeAccepted:(int)index
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * acceptArray =[data objectForKey:@"accept"];
    [acceptArray removeObjectAtIndex:index];
    [data setObject:acceptArray forKey:@"accept"];
    [data writeToFile: path atomically:YES];
}

-(void)removeFrom:(int)index
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * fromArray =[data objectForKey:@"from"];
    [fromArray removeObjectAtIndex:index];
    [data setObject:fromArray forKey:@"from"];
    [data writeToFile: path atomically:YES];
}

-(void)removeTo:(int)index
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * toArray =[data objectForKey:@"to"];
    [toArray removeObjectAtIndex:index];
    [data setObject:toArray forKey:@"to"];
    [data writeToFile: path atomically:YES];
}

-(void)removeNote:(int)index
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * noteArray =[data objectForKey:@"note"];
    [noteArray removeObjectAtIndex:index];
    [data setObject:noteArray forKey:@"note"];
    [data writeToFile: path atomically:YES];
}

-(void)removeGender:(int)index
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    NSMutableArray * genderArray =[data objectForKey:@"gender"];
    [genderArray removeObjectAtIndex:index];
    [data setObject:genderArray forKey:@"gender"];
    [data writeToFile: path atomically:YES];
}

-(void)removeFrict:(int)index
{
    [self removeHuId:index];
    [self removeFirst:index];
    [self removeLast:index];
    [self removeBase:index];
    [self removeAccepted:index];
    [self removeFrom:index];
    [self removeTo:index];
    [self removeNote:index];
    [self removeGender:index];
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

-(int)resetPk
{
    NSString * path = [self getPlistPath];
    NSMutableDictionary *data = [self getPlistData:path];
    [data setObject:defaultPk forKey:@"pk"];
    [data writeToFile: path atomically:YES];
    return [defaultPk integerValue];
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
        data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    }
    else
    {
        defaultHuId = [[NSMutableArray alloc] initWithObjects:nil];
        defaultFirst = [[NSMutableArray alloc] initWithObjects:nil];
        defaultLast = [[NSMutableArray alloc] initWithObjects:nil];
        defaultGender = [[NSMutableArray alloc] initWithObjects:nil];
        
        defaultFrictId = [[NSMutableArray alloc] initWithObjects:[[NSMutableArray alloc] initWithObjects:nil], nil];
        defaultBase = [[NSMutableArray alloc] initWithObjects:[[NSMutableArray alloc] initWithObjects:nil], nil];
        defaultAccepted = [[NSMutableArray alloc] initWithObjects:[[NSMutableArray alloc] initWithObjects:nil], nil];
        defaultFrom = [[NSMutableArray alloc] initWithObjects:[[NSMutableArray alloc] initWithObjects:nil], nil];;
        defaultTo = [[NSMutableArray alloc] initWithObjects:[[NSMutableArray alloc] initWithObjects:nil], nil];;
        defaultNotes = [[NSMutableArray alloc] initWithObjects:[[NSMutableArray alloc] initWithObjects:nil], nil];;
        
        // If the file doesn’t exist, create an empty dictionary
        data = [[NSMutableDictionary alloc] init];
        [data setObject:defaultEmail forKey:@"email"]; //email
        [data setObject:defaultPk forKey:@"pk"]; //primary key
        [data setObject:defaultBirthday forKey:@"bday"]; //birthday
        [data setObject:@"1" forKey:@"first"]; //1 if first time opening app
        
        [data setObject:defaultHuId forKey:@"huid"]; //hookup ids
        [data setObject:defaultFirst forKey:@"fn"]; //first name array
        [data setObject:defaultLast forKey:@"ln"]; //last name array
        [data setObject:defaultGender forKey:@"gender"]; //gender
        
        [data setObject:defaultFrictId forKey:@"frictid"]; //frict ids
        [data setObject:defaultBase forKey:@"base"]; //bases
        [data setObject:defaultAccepted forKey:@"accept"]; //accepted status
        [data setObject:defaultFrom forKey:@"from"]; //from date
        [data setObject:defaultTo forKey:@"to"]; //to date
        [data setObject:defaultNotes forKey:@"note"]; //notes
        [data writeToFile: path atomically:YES];
    }
    
    return data;
}

@end
