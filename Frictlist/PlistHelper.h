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
-(NSString *)getEmail;
-(void)setEmail:(NSString *)email;
-(NSString *)resetEmail;
-(int)getPk;
-(void)setPk:(int)pk;
-(int)resetPk;
-(int)getFirst;
-(void)setFirst:(int)first;

-(NSMutableArray *)getHuIdArray;
-(NSMutableArray *)getFirstNameArray;
-(NSMutableArray *)getLastNameArray;
-(void)addFrict:(int)huid first:(NSString *)fn last:(NSString *)ln;

@end
