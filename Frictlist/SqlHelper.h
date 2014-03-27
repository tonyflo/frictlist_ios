//
//  SqlHelper.h
//  Frictlist
//
//  Created by Tony Flo on 3/26/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SqlHelper : NSObject

- (void)createEditableCopyOfDatabaseIfNeeded;

- (NSMutableArray *)get_mate_list;

- (void)add_mate:(int)mate_id fn:(NSString *)fn ln:(NSString *)ln gender:(int)gender;

@end
