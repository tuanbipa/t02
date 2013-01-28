//
//  Link.m
//  SmartCal
//
//  Created by Left Coast Logic on 7/12/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//
#import <sqlite3.h>

#import "Link.h"

#import "Common.h"

#import "DBManager.h"

@implementation Link

@synthesize primaryKey;
@synthesize srcId;
@synthesize destId;
@synthesize status;
@synthesize sdwId;
@synthesize updateTime;

- (id) init
{
    self = [super init];
    
    if (self)
    {
        self.sdwId = @"";
        self.updateTime = nil;
        self.status = LINK_STATUS_NONE;
        
        isExternalUpdate = NO;
    }
    
    return self;
}

- (void) dealloc
{
    self.updateTime = nil;
    
    [super dealloc];
}

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)database 
{
    if (self = [super init]) 
	{
		sqlite3_stmt *statement = nil;
        
        // Compile the query for retrieving book data. See insertNewBookIntoDatabase: for more detail.
        if (statement == nil) {
            // Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
            // This is a great way to optimize because frequently used queries can be compiled once, then with each
            // use new variable values can be bound to placeholders.
			
            const char *sql = "SELECT TaskLink_ID, Source_ID, Dest_ID, Status, SDW_ID, UpdateTime FROM TaskLinkTable WHERE TaskLink_ID = ?";
			
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
			self.srcId = sqlite3_column_int(statement, 1);
			self.destId = sqlite3_column_int(statement, 2);
			self.status = sqlite3_column_int(statement, 3);
            
			char *str = (char *)sqlite3_column_text(statement, 4);
			self.sdwId = (str == NULL? @"":[NSString stringWithUTF8String:str]);
            
			NSTimeInterval updateTimeValue = sqlite3_column_double(statement, 18);
			
			self.updateTime = (updateTimeValue == -1? nil:[Common fromDBDate:[NSDate dateWithTimeIntervalSince1970:updateTimeValue]]);            
            
        }
        
        sqlite3_finalize(statement);
    }
    
    return self;
}

- (void) insertIntoDB:(sqlite3 *)database
{
	sqlite3_stmt *statement = nil;
    
    if (statement == nil) 
	{
        static char *sql = "INSERT INTO TaskLinkTable (Source_ID, Dest_ID, Status, SDW_ID, UpdateTime) \
            VALUES(?,?,?,?,?)";		
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
		
    }
	
	if (!isExternalUpdate)
	{
		self.updateTime = [NSDate date];		
	}
	
	isExternalUpdate = NO;	
	
	sqlite3_bind_int(statement, 1, self.srcId);
	sqlite3_bind_int(statement, 2, self.destId);
	sqlite3_bind_int(statement, 3, self.status);
	sqlite3_bind_text(statement, 4, [self.sdwId UTF8String], -1, SQLITE_TRANSIENT); 
    
	NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);
	
	sqlite3_bind_double(statement, 5, updateTimeValue);
    
    int success = sqlite3_step(statement);

	sqlite3_finalize(statement);
	
    if (success != SQLITE_ERROR) {
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
	sqlite3_stmt *statement = nil;
    
    if (statement == nil) {
        static char *sql = "UPDATE TaskLinkTable SET Source_ID = ?, Dest_ID = ?, Status = ?, SDW_ID = ?, UpdateTime = ? WHERE TaskLink_ID = ?";		
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	sqlite3_bind_int(statement, 1, self.srcId);
	sqlite3_bind_int(statement, 2, self.destId);
	sqlite3_bind_int(statement, 3, self.status);
	sqlite3_bind_text(statement, 4, [self.sdwId UTF8String], -1, SQLITE_TRANSIENT); 
    
	if (!isExternalUpdate)
	{
		self.updateTime = [NSDate date];
	}
	
	isExternalUpdate = NO;    
    
	NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);
	
	sqlite3_bind_double(statement, 5, updateTimeValue);
    
    sqlite3_bind_int(statement, 6, self.primaryKey);
    
    int success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}    
}

- (void) updateSDWIDIntoDB:(sqlite3 *)database
{
	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
		static char *sql = "UPDATE TaskLinkTable SET SDW_ID = ?,UpdateTime = ? WHERE TaskLink_ID=?";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	if (self.sdwId == nil)
	{
		self.sdwId = @"";
	}
    
    NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);	
	
	sqlite3_bind_text(statement, 1, [self.sdwId UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_double(statement, 2, updateTimeValue);
	sqlite3_bind_int(statement, 3, self.primaryKey);
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
}

- (void) modifyUpdateTimeIntoDB:(sqlite3 *)database
{
	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE TaskLinkTable SET UpdateTime = ? WHERE TaskLink_ID = ?";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	if (!isExternalUpdate)
	{
		self.updateTime = [NSDate date];
	}
	
	isExternalUpdate = NO;	
	
	NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);
	
	sqlite3_bind_double(statement, 1, updateTimeValue);
	sqlite3_bind_int(statement, 2, self.primaryKey);
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
}


- (void)cleanFromDatabase:(sqlite3 *)database 
{
	if (self.primaryKey == -1)
	{
		return;
	}
	
    // Compile the delete statement if needed.
	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        const char *sql = "DELETE FROM TaskLinkTable WHERE TaskLink_ID=?";

        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    
    // Bind the primary key variable.
    sqlite3_bind_int(statement, 1, self.primaryKey);
    
    // Execute the query.
    int success = sqlite3_step(statement);
    
    sqlite3_finalize(statement);
    
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }
}

- (void)deleteFromDatabase:(sqlite3 *)database
{
	if (self.primaryKey == -1)
	{
		return;
	}
    
    if (self.sdwId == nil || [self.sdwId isEqualToString:@""])
    {
        [self cleanFromDatabase:database];
        
        return;
    }
	
    // Compile the delete statement if needed.
	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        const char *sql = "UPDATE TaskLinkTable SET Status=?,UpdateTime=? WHERE TaskLink_ID=?";
        
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    
    // Bind the primary key variable.
    
	self.status = LINK_STATUS_DELETED;
	
	if (!isExternalUpdate)
	{
		self.updateTime = [NSDate date];
	}
	
	isExternalUpdate = NO;
	
	NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);
	
	sqlite3_bind_int(statement, 1, self.status);
	sqlite3_bind_double(statement, 2, updateTimeValue);
	sqlite3_bind_int(statement, 3, self.primaryKey);
    
    // Execute the query.
    int success = sqlite3_step(statement);
    
    sqlite3_finalize(statement);
    
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }
}

-(void) externalUpdate
{
	isExternalUpdate = YES;
	
	[self updateIntoDB:[[DBManager getInstance] getDatabase]];
}

-(void) enableExternalUpdate
{
	isExternalUpdate = YES;
}

@end
