//
//  SqlHelper.m
//  Frictlist
//
//  Created by Tony Flo on 3/26/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import "SqlHelper.h"
#import <sqlite3.h>

@implementation SqlHelper

sqlite3 *database;
NSString * dbName = @"frictlist.sqlite";

// Creates a writable copy of the bundled default database in the application Documents directory.
- (void)createEditableCopyOfDatabaseIfNeeded {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:dbName];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success)
    {
        NSLog(@"db exists");
        return;
    }
    else
    {
        // The writable database does not exist, so copy the default to the appropriate location.
        NSLog(@"Creating database");
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbName];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
        if (!success) {
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
        }
    }
    
}

-(NSString *)getDbPath
{
    // The database is stored in the application bundle.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:dbName];
    return path;
}

- (NSMutableArray *)get_mate_list
{
    NSMutableArray * mate_id_array = [[NSMutableArray alloc] initWithObjects: nil];
    NSMutableArray * mate_fn_array = [[NSMutableArray alloc] initWithObjects: nil];
    NSMutableArray * mate_ln_array = [[NSMutableArray alloc] initWithObjects: nil];
    NSMutableArray * mate_gender_array = [[NSMutableArray alloc] initWithObjects: nil];
    NSMutableArray * mate_list;
    
    NSString * path = [self getDbPath];
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK)
    {
        // Get the primary key for all books.
        const char *sql = "select * from mate";
        sqlite3_stmt *statement;
        // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
        // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.
        int result = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
        if (result == SQLITE_OK)
        {
            // We "step" through the results - once for each row.
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                // The second parameter indicates the column index into the result set.
                NSNumber *mate_id = [NSNumber numberWithInt: sqlite3_column_int(statement, 0)];
                NSString *mate_fn = [NSString stringWithUTF8String:sqlite3_column_text(statement, 1)];
                NSString *mate_ln = [NSString stringWithUTF8String:sqlite3_column_text(statement, 2)];
                NSNumber *mate_gender = [NSNumber numberWithInt: sqlite3_column_int(statement, 3)];
                [mate_id_array addObject:mate_id];
                [mate_fn_array addObject:mate_fn];
                [mate_ln_array addObject:mate_ln];
                [mate_gender_array addObject:mate_gender];
            }
            
            mate_list = [[NSMutableArray alloc] initWithObjects:mate_id_array, mate_fn_array, mate_ln_array, mate_gender_array, nil];
        }
        else
        {
            NSLog(@"Prepare* error #%i: %s", result, sqlite3_errmsg(database));
        }
        // "Finalize" the statement - releases the resources associated with the statement.
        sqlite3_finalize(statement);
    }
    else
    {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
    }

    return mate_list;
}

- (NSMutableArray *)get_frict_list:(int)mate_id
{
    NSMutableArray * frict_id_array = [[NSMutableArray alloc] initWithObjects: nil];
    NSMutableArray * from_array = [[NSMutableArray alloc] initWithObjects: nil];
    NSMutableArray * to_array = [[NSMutableArray alloc] initWithObjects: nil];
    NSMutableArray * base_array = [[NSMutableArray alloc] initWithObjects: nil];
    NSMutableArray * notes_array = [[NSMutableArray alloc] initWithObjects: nil];
    NSMutableArray * frict_list;
    
    NSString * path = [self getDbPath];
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK)
    {
        // Get the primary key for all books.
        const char *sql = [[NSString stringWithFormat:@"select frict_id, frict_from_date, frict_to_date, frict_base, notes from frict where mate_id='%d'", mate_id] UTF8String];
        sqlite3_stmt *statement;
        // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
        // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.
        int result = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
        if (result == SQLITE_OK)
        {
            // We "step" through the results - once for each row.
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSLog(@"out");
                // The second parameter indicates the column index into the result set.
                NSNumber *frict_id = [NSNumber numberWithInt: sqlite3_column_int(statement, 0)];
                NSString *from = [NSString stringWithUTF8String:sqlite3_column_text(statement, 1)];
                NSString *to = [NSString stringWithUTF8String:sqlite3_column_text(statement, 2)];
                NSNumber *base = [NSNumber numberWithInt: sqlite3_column_int(statement, 3)];
                NSString *notes = [NSString stringWithUTF8String:sqlite3_column_text(statement, 4)];
                [frict_id_array addObject:frict_id];
                [from_array addObject:from];
                [to_array addObject:to];
                [base_array addObject:base];
                [notes_array addObject:notes];
            }
            
            frict_list = [[NSMutableArray alloc] initWithObjects:frict_id_array, from_array, to_array, base_array, notes_array, nil];
        }
        else
        {
            NSLog(@"Prepare! error #%i: %s", result, sqlite3_errmsg(database));
        }
        // "Finalize" the statement - releases the resources associated with the statement.
        sqlite3_finalize(statement);
    }
    else
    {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
    }
    NSLog(@"sql get_frict_list: %@", frict_list);
    return frict_list;
}


- (void)add_mate:(int)mate_id fn:(NSString *)fn ln:(NSString *)ln gender:(int)gender
{
    NSString * path = [self getDbPath];
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK)
    {
        const char *sql = [[NSString stringWithFormat:@"INSERT INTO mate(mate_id, mate_first_name, mate_last_name, mate_gender) VALUES('%d', '%@', '%@', '%d')", mate_id, fn, ln, gender] UTF8String];
        sqlite3_stmt *updateStmt = nil;
        if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
        {
            NSLog(@"Error while creating insert statement. '%s'", sqlite3_errmsg(database));
        }
        if (SQLITE_DONE != sqlite3_step(updateStmt)){
            NSLog(@"Error while creating database. '%s'", sqlite3_errmsg(database));
        }
        sqlite3_reset(updateStmt);
        sqlite3_finalize(updateStmt);
    }
    else
    {
        NSLog(@"Error while opening database '%s'", sqlite3_errmsg(database));
    }
    sqlite3_close(database);
}

- (void)add_frict:(int)frict_id mate_id:(int)mate_id from:(NSString *)from to:(NSString *)to base:(int)base notes:(NSString *)notes
{
    NSString * path = [self getDbPath];
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK)
    {
        const char *sql = [[NSString stringWithFormat:@"INSERT INTO frict(frict_id, mate_id, frict_from_date, frict_to_date, frict_base, notes) VALUES('%d', '%d', '%@', '%@', '%d', '%@')", frict_id, mate_id, from, to, base, [self sanatize:notes]] UTF8String];
        sqlite3_stmt *updateStmt = nil;
        if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
        {
            NSLog(@"Error while creating insert statement. '%s'", sqlite3_errmsg(database));
        }
        if (SQLITE_DONE != sqlite3_step(updateStmt)){
            NSLog(@"Error while creating database. '%s'", sqlite3_errmsg(database));
        }
        sqlite3_reset(updateStmt);
        sqlite3_finalize(updateStmt);
    }
    else
    {
        NSLog(@"Error while opening database '%s'", sqlite3_errmsg(database));
    }
    sqlite3_close(database);
}

- (void)update_mate:(int)mate_id fn:(NSString *)fn ln:(NSString *)ln gender:(int)gender
{
    NSString * path = [self getDbPath];
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK)
    {
        const char *sql = [[NSString stringWithFormat:@"UPDATE mate SET mate_first_name='%@', mate_last_name='%@', mate_gender='%d' where mate_id='%d'", fn, ln, gender, mate_id] UTF8String];
        sqlite3_stmt *updateStmt = nil;
        if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
        {
            NSLog(@"Error while creating insert statement. '%s'", sqlite3_errmsg(database));
        }
        if (SQLITE_DONE != sqlite3_step(updateStmt)){
            NSLog(@"Error while creating database. '%s'", sqlite3_errmsg(database));
        }
        sqlite3_reset(updateStmt);
        sqlite3_finalize(updateStmt);
    }
    else
    {
        NSLog(@"Error while opening database '%s'", sqlite3_errmsg(database));
    }
    sqlite3_close(database);
}


- (void)update_frict:(int)frict_id from:(NSString *)from to:(NSString *)to base:(int)base notes:(NSString *)notes
{
    NSString * path = [self getDbPath];
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK)
    {
        const char *sql = [[NSString stringWithFormat:@"UPDATE frict SET frict_from_date='%@', frict_to_date='%@', frict_base='%d', notes='%@' where frict_id='%d'", from, to, base, [self sanatize:notes], frict_id] UTF8String];
        sqlite3_stmt *updateStmt = nil;
        if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
        {
            NSLog(@"Error while creating insert statement. '%s'", sqlite3_errmsg(database));
            NSLog(@"done update frict");
        }
        if (SQLITE_DONE != sqlite3_step(updateStmt)){
            NSLog(@"Error while creating database. '%s'", sqlite3_errmsg(database));
        }
        sqlite3_reset(updateStmt);
        sqlite3_finalize(updateStmt);
    }
    else
    {
        NSLog(@"Error while opening database '%s'", sqlite3_errmsg(database));
    }
    sqlite3_close(database);
    NSLog(@"by update frict");
}


- (void)remove_mate:(int)mate_id
{
    NSString * path = [self getDbPath];
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK)
    {
        {
            //remove fricts associated with this mate
            const char *sql = [[NSString stringWithFormat:@"DELETE FROM frict WHERE mate_id='%d'", mate_id] UTF8String];
            sqlite3_stmt *removeStatement = nil;
            if(sqlite3_prepare_v2(database, sql, -1, &removeStatement, NULL) != SQLITE_OK)
            {
                NSLog(@"Error while creating remove statement. '%s'", sqlite3_errmsg(database));
            }
            if (SQLITE_DONE != sqlite3_step(removeStatement)){
                NSLog(@"Error while remove database. '%s'", sqlite3_errmsg(database));
            }
            sqlite3_reset(removeStatement);
            sqlite3_finalize(removeStatement);

        }
        
        const char *sql = [[NSString stringWithFormat:@"DELETE FROM mate WHERE mate_id='%d'", mate_id] UTF8String];
        sqlite3_stmt *removeStatement = nil;
        if(sqlite3_prepare_v2(database, sql, -1, &removeStatement, NULL) != SQLITE_OK)
        {
            NSLog(@"Error while creating remove statement. '%s'", sqlite3_errmsg(database));
        }
        if (SQLITE_DONE != sqlite3_step(removeStatement)){
            NSLog(@"Error while remove database. '%s'", sqlite3_errmsg(database));
        }
        sqlite3_reset(removeStatement);
        sqlite3_finalize(removeStatement);
    }
    else
    {
        NSLog(@"Error while opening database '%s'", sqlite3_errmsg(database));
    }
    sqlite3_close(database);
}

- (void)remove_frict:(int)frict_id
{
    NSString * path = [self getDbPath];
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK)
    {
        const char *sql = [[NSString stringWithFormat:@"DELETE FROM frict WHERE frict_id='%d'", frict_id] UTF8String];
        sqlite3_stmt *removeStatement = nil;
        if(sqlite3_prepare_v2(database, sql, -1, &removeStatement, NULL) != SQLITE_OK)
        {
            NSLog(@"Error while creating remove statement. '%s'", sqlite3_errmsg(database));
        }
        if (SQLITE_DONE != sqlite3_step(removeStatement)){
            NSLog(@"Error while remove database. '%s'", sqlite3_errmsg(database));
        }
        sqlite3_reset(removeStatement);
        sqlite3_finalize(removeStatement);
    }
    else
    {
        NSLog(@"Error while opening database '%s'", sqlite3_errmsg(database));
    }
    sqlite3_close(database);
}

- (NSMutableArray *)get_frict:(int)frict_id
{
    NSMutableArray * frict;
    
    NSString * path = [self getDbPath];
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK)
    {
        // Get the primary key for all books.
        const char *sql = [[NSString stringWithFormat:@"select frict_from_date, frict_to_date, frict_base, notes from frict where frict_id='%d'", frict_id] UTF8String];
        sqlite3_stmt *statement;
        // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
        // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.
        int result = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
        if (result == SQLITE_OK)
        {
            // We "step" through the results - once for each row.
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSLog(@"found a frict for %d", frict_id);
                // The second parameter indicates the column index into the result set.
                NSString *from = [NSString stringWithUTF8String:sqlite3_column_text(statement, 0)];
                NSString *to = [NSString stringWithUTF8String:sqlite3_column_text(statement, 1)];
                NSNumber *base = [NSNumber numberWithInt: sqlite3_column_int(statement, 2)];
                NSString *notes = [NSString stringWithUTF8String:sqlite3_column_text(statement, 3)];
            
                frict = [[NSMutableArray alloc] initWithObjects:from, to, base, notes, nil];
            }
            NSLog(@"end frict getting");
        }
        else
        {
            NSLog(@"Prepare# error #%i: %s", result, sqlite3_errmsg(database));
        }
        // "Finalize" the statement - releases the resources associated with the statement.
        sqlite3_finalize(statement);
    }
    else
    {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
    }
    NSLog(@"get a frict: %@", frict);
    return frict;
}

- (NSMutableArray *)get_mate:(int)mate_id
{
    NSMutableArray * mate;
    
    NSString * path = [self getDbPath];
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK)
    {
        // Get the primary key for all books.
        const char *sql = [[NSString stringWithFormat:@"select mate_first_name, mate_last_name, mate_gender from mate where mate_id='%d'", mate_id] UTF8String];
        sqlite3_stmt *statement;
        // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
        // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.
        int result = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
        if (result == SQLITE_OK)
        {
            // We "step" through the results - once for each row.
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                // The second parameter indicates the column index into the result set.
                NSString *fn = [NSString stringWithUTF8String:sqlite3_column_text(statement, 0)];
                NSNumber *ln = [NSString stringWithUTF8String:sqlite3_column_text(statement, 1)];
                NSNumber *gender = [NSNumber numberWithInt: sqlite3_column_int(statement, 2)];
                
                mate = [[NSMutableArray alloc] initWithObjects:fn, ln, gender, nil];
            }
        }
        else
        {
            NSLog(@"Prepare$ error #%i: %s", result, sqlite3_errmsg(database));
        }
        // "Finalize" the statement - releases the resources associated with the statement.
        sqlite3_finalize(statement);
    }
    else
    {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
    }
    
    return mate;
}

- (NSString *) sanatize:(NSString*)input
{
    return [[input stringByReplacingOccurrencesOfString:@"'" withString:@"\'"] stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
}

@end
