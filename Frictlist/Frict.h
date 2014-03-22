//
//  Frict.h
//  Frictlist
//
//  Created by Tony Flo on 6/16/13.
//  Copyright (c) 2013 FLooReeDA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Frict : NSObject
{
	NSInteger primaryKey;
    NSString *stateName;
    BOOL stateVisited;
}

@property (assign, nonatomic, readonly) NSInteger primaryKey;
@property (nonatomic, retain) NSString *stateName;
@property (nonatomic, assign) BOOL stateVisited;

- (id) initWithName: (NSString *)name AndVisited: (BOOL)visited AndIndex: (NSUInteger) index;
-(NSString *) getName;
-(BOOL) getVisited;
-(NSUInteger) getIndex;

@end