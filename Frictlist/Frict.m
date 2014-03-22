//
//  Frict.m
//  Frictlist
//
//  Created by Tony Flo on 6/16/13.
//  Copyright (c) 2013 FLooReeDA. All rights reserved.
//

#import "Frict.h"

@implementation Frict
@synthesize primaryKey, stateName, stateVisited;


- (id) initWithName: (NSString *)name AndVisited: (BOOL)visited AndIndex: (NSUInteger) index
{
    stateName = name;
    stateVisited = visited;
    primaryKey = index;
    
    return self;
}

//name getter
-(NSString *) getName
{
    return stateName;
}

//visited getter
-(BOOL) getVisited
{
    return stateVisited;
}

//index getter
-(NSUInteger) getIndex
{
    return primaryKey;
}


@end
