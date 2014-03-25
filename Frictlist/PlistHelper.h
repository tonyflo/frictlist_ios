//
//  PlistHelper.h
//  Frictlist
//
//  Created by Tony Flo on 1/14/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlistHelper : NSObject
{
    
}

-(id)initDefaults;
-(id)resetPlist;

-(NSString *)getEmail;
-(void)setEmail:(NSString *)email;
-(NSString *)resetEmail;
-(NSString *)getBirthday;
-(void)setBirthday:(NSString *)email;
-(NSString *)resetBirthday;
-(int)getPk;
-(void)setPk:(int)pk;
-(int)resetPk;
-(int)getFirst;
-(void)setFirst:(int)first;

-(NSMutableArray *)getHuIdArray;
-(NSMutableArray *)getFirstNameArray;
-(NSMutableArray *)getLastNameArray;
-(NSMutableArray *)getBaseArray;
-(NSMutableArray *)getAcceptedArray;
-(NSMutableArray *)getGenderArray;
-(NSMutableArray *)getFromArray;
-(NSMutableArray *)getToArray;
-(NSMutableArray *)getNoteArray;

-(void)addFrict:(int)huid first:(NSString *)fn last:(NSString *)ln base:(int)base accepted:(int)accepted from:(NSString *)from to:(NSString *)to notes:(NSString *)notes gender:(int)gender;
-(void)updateFrict:(int)huid index:(int)index first:(NSString *)fn last:(NSString *)ln base:(int)base accepted:(int)accepted from:(NSString *)from to:(NSString *)to notes:(NSString *)notes gender:(int)gender;
-(void)removeFrict:(int)index;

-(void)addMate:(int)mid first:(NSString *)fn last:(NSString *)ln gender:(int)gender;
-(void)updateMate:(int)mid index:(int)index first:(NSString *)fn last:(NSString *)ln gender:(int)gender;

@end
