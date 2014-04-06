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
- (NSMutableArray *)get_frict_list:(int)mate_id; //todo: only need to return frict_id, date, base
- (NSMutableArray *)get_notifications_list;
- (NSMutableArray *)get_accepted_list;
- (NSMutableArray *)get_rejected_list;

- (void)add_mate:(int)mate_id fn:(NSString *)fn ln:(NSString *)ln gender:(int)gender accepted:(int)accepted mates_uid:(int)mates_uid;
- (void)add_frict:(int)frict_id mate_id:(int)mate_id from:(NSString *)from rating:(int)rating base:(int)base notes:(NSString *)notes mate_rating:(int)mate_rating mate_notes:(NSString *)mate_notes mate_deleted:(int)mate_deleted; //updated
- (void)add_notification:(int)request_id mate_id:(int)mate_id first:(NSString *)first last:(NSString *)last un:(NSString *)un gender:(int)gender birthdate:(NSString *)birthdate;
- (void)add_accepted:(int)request_id mate_id:(int)mate_id first:(NSString *)first last:(NSString *)last un:(NSString *)un gender:(int)gender birthdate:(NSString *)birthdate;
- (void)add_rejected:(int)request_id mate_id:(int)mate_id first:(NSString *)first last:(NSString *)last un:(NSString *)un gender:(int)gender birthdate:(NSString *)birthdate;

- (void)remove_mate:(int)mate_id;
- (void)remove_frict:(int)frict_id; //no update needed
- (void)remove_notification:(int)request_id;
- (void)remove_accepted:(int)request_id;
- (void)remove_rejected:(int)request_id;

- (NSMutableArray *)get_mate:(int)mate_id;
- (NSMutableArray *)get_frict:(int)frict_id; //3 more columns
- (NSMutableArray *)get_notification:(int)request_id;
- (NSMutableArray *)get_accepted:(int)request_id;
- (NSMutableArray *)get_rejected:(int)request_id;

- (void)update_mate:(int)mate_id fn:(NSString *)fn ln:(NSString *)ln gender:(int)gender;
- (void)update_frict:(int)frict_id from:(NSString *)from rating:(int)rating base:(int)base notes:(NSString *)notes; //no update needed

- (NSArray *) getOutgoingRequestStatus;
- (void)update_mate_status:(int)mate_id accepted:(int)accepted request:(int)request;

@end
