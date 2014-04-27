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
-(void)setBirthday:(NSString *)birthday;
-(NSString *)resetBirthday;

-(NSString *)getFirstName;
-(void)setFirstName:(NSString *)first;
-(NSString *)resetFirstName;

-(NSString *)getLastName;
-(void)setLastName:(NSString *)last;
-(NSString *)resetLastName;

-(int)getPk;
-(void)setPk:(int)pk;
-(int)resetPk;

-(int)getSaveLogin;
-(void)setSaveLogin:(int)pk;
-(int)resetSaveLogin;

@end
