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
- (BOOL)removeSqliteFile;

- (NSMutableArray *)get_mate_list;
- (NSMutableArray *)get_frict_list:(int)mate_id;
- (void)add_mate:(int)mate_id fn:(NSString *)fn ln:(NSString *)ln gender:(int)gender;
- (void)add_frict:(int)frict_id mate_id:(int)mate_id from:(NSString *)from rating:(int)rating base:(int)base notes:(NSString *)notes;
- (void)remove_mate:(int)mate_id;
- (void)remove_frict:(int)frict_id;
- (NSMutableArray *)get_mate:(int)mate_id;
- (NSMutableArray *)get_frict:(int)frict_id;
- (void)update_mate:(int)mate_id fn:(NSString *)fn ln:(NSString *)ln gender:(int)gender;
- (void)update_frict:(int)frict_id from:(NSString *)from rating:(int)rating base:(int)base notes:(NSString *)notes;

@end
