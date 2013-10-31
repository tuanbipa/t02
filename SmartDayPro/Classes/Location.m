//
//  Location.m
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 10/25/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <sqlite3.h>

#import "Location.h"
#import "DBManager.h"

static sqlite3_stmt *loc_init_statement = nil;
static sqlite3_stmt *loc_insert_statement = nil;
static sqlite3_stmt *loc_update_statement = nil;
static sqlite3_stmt *loc_delete_statement = nil;

@implementation Location

@synthesize primaryKey;
@synthesize name;
@synthesize address;
@synthesize latitude;
@synthesize longitude;
@synthesize inside;

- (id)init
{
    if (self = [super init]) {
        self.primaryKey = -1;
        self.name = @"";
        self.address = @"";
        self.latitude = -1;
        self.longitude = -1;
        self.inside = 0;
    }
    return self;
}

- (void)dealloc
{
    self.name = nil;
    self.address = nil;
    
    [super dealloc];
}

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements {
    if (loc_init_statement) sqlite3_finalize(loc_init_statement);
    if (loc_insert_statement) sqlite3_finalize(loc_insert_statement);
    if (loc_update_statement) sqlite3_finalize(loc_update_statement);
	if (loc_delete_statement) sqlite3_finalize(loc_delete_statement);
	
	
	loc_init_statement = nil;
	loc_insert_statement = nil;
	loc_update_statement = nil;
	loc_delete_statement = nil;
}

- (id)copyWithZone:(NSZone*) zone
{
    Location *copy = [[Location alloc] init];
    
    copy.primaryKey = primaryKey;
    copy.name = name;
    copy.address = address;
    copy.latitude = latitude;
    copy.longitude = longitude;
    copy.inside = inside;
    
    return copy;
}

#pragma mark DB methods

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)database
{
    if (self = [super init]) {
		//@synchronized([DBManager getInstance])
		{
            
            // Compile the query for retrieving book data. See insertNewBookIntoDatabase: for more detail.
            //sqlite3_stmt *statement = nil;
			
            sqlite3_stmt *statement = loc_init_statement;
			
            if (statement == nil) {
                // Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
                // This is a great way to optimize because frequently used queries can be compiled once, then with each
                // use new variable values can be bound to placeholders.
                const char *sql = "SELECT Location_ID, Location_Name, Location_Address, Location_Latitude, Location_Longitude, Location_Inside \
                FROM LocationTable \
                WHERE Location_ID = ?";
                if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
                    NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
                }
            }
            // For this query, we bind the primary key to the first (and only) placeholder in the statement.
            // Note that the parameters are numbered from 1, not from 0.
            sqlite3_bind_int(statement, 1, pk);
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                self.primaryKey = sqlite3_column_int(statement, 0);
                
                char *str = (char *)sqlite3_column_text(statement, 1);
                self.name = (str == NULL? @"":[NSString stringWithUTF8String:str]);
                
                str = (char *)sqlite3_column_text(statement, 2);
                self.address = (str == NULL? @"":[NSString stringWithUTF8String:str]);
                
                self.latitude = sqlite3_column_int(statement, 3);
                
                self.longitude = sqlite3_column_int(statement, 4);
                
                self.inside = sqlite3_column_int(statement, 5);
            }
            
            // Reset the statement for future reuse.
            //sqlite3_finalize(statement);
            sqlite3_reset(statement);
			
		}
    }
	
    return self;
}

- (void)insetIntoDB: (sqlite3 *)database
{
    sqlite3_stmt *statement = loc_insert_statement;
    
    if (statement == nil)
	{
        static char *sql = "INSERT INTO LocationTable (Location_Name, Location_Address, Location_Latitude, Location_Longitude, Location_Inside, Location_UpdateTime) VALUES(?,?,?,?,?,?)";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    
	sqlite3_bind_text(statement, 1, [self.name UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 2, [self.address UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(statement, 3, self.latitude);
    sqlite3_bind_int(statement, 4, self.longitude);
    sqlite3_bind_int(statement, 5, self.inside);
    sqlite3_bind_int(statement, 6, [[NSDate date] timeIntervalSince1970]);
    
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    //sqlite3_finalize(statement);
	sqlite3_reset(statement);
    
    if (success != SQLITE_ERROR) {
        // SQLite provides a method which retrieves the value of the most recently auto-generated primary key sequence
        // in the database. To access this functionality, the table should have a column declared of type
        // "INTEGER PRIMARY KEY"
        NSInteger pk = sqlite3_last_insert_rowid(database);
		self.primaryKey = pk;
    }
	else
	{
		NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
	}
}

- (void) updateIntoDB:(sqlite3 *)database
{
    sqlite3_stmt *statement = loc_update_statement;
    if (statement == nil) {
		static char *sql = "UPDATE LocationTable SET Location_Name=?, Location_Address=?, Location_Latitude=?, \
		Location_Longitude=?, Location_Inside=?, Location_UpdateTime=? WHERE Location_ID = ?";
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    
    sqlite3_bind_text(statement, 1, [self.name UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 2, [self.address UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(statement, 3, self.latitude);
    sqlite3_bind_int(statement, 4, self.longitude);
    sqlite3_bind_int(statement, 5, self.inside);
    sqlite3_bind_int(statement, 6, [[NSDate date] timeIntervalSince1970]);
    sqlite3_bind_int(statement, 7, self.primaryKey);
    
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    //sqlite3_finalize(statement);
	sqlite3_reset(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
}

- (void)deleteFromDatabase:(sqlite3 *)database
{
    if (loc_delete_statement == nil) {
        const char *sql = "DELETE FROM LocationTable WHERE Location_ID = ?";
        
        if (sqlite3_prepare_v2(database, sql, -1, &loc_delete_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
    // Bind the primary key variable.
    sqlite3_bind_int(loc_delete_statement, 1, self.primaryKey);
    
    // Execute the query.
    int success = sqlite3_step(loc_delete_statement);
    // Reset the statement for future use.
    sqlite3_reset(loc_delete_statement);
	
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }
}
@end
