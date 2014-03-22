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
-(NSString *)getLastSyncDateTime;
-(void)setLastSyncDateTime:(NSString *)sync;
-(NSString *)resetLastSyncDateTime;
-(int)getPk;
-(void)setPk:(int)pk;
-(int)resetPk;
-(NSString *)getIvisited;
-(void)setIvisited:(NSString *)ivisited;
-(NSString *)resetIvisited;
-(int)getFirst;
-(void)setFirst:(int)first;

@end
