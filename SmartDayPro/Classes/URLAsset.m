//
//  URLAsset.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 7/29/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//
#import <sqlite3.h>

#import "URLAsset.h"

#import "DBManager.h"

@implementation URLAsset

@synthesize primaryKey;
@synthesize status;
@synthesize urlValue;
@synthesize sdwId;
@synthesize updateTime;

- (id)init
{
	if (self = [super init])
	{
        self.primaryKey = -1;
        self.urlValue = @"";
        self.sdwId = @"";
        self.status = URL_STATUS_NONE;
        self.updateTime = nil;
    }
    
    return self;
}

- (void) dealloc
{
    self.urlValue = nil;
    self.sdwId = nil;
    self.updateTime = nil;
    
    [super dealloc];
}

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)database
{
    if (self = [super init])
	{
        sqlite3 *database = [[DBManager getInstance] getDatabase];
        
        sqlite3_stmt *statement;
        
        static char *sql = "SELECT URL_Status, URL_Value, URL_SDWID, URL_UpdateTime FROM URLTable WHERE URL_ID=?";
        
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
        
        sqlite3_bind_int(statement, 1, pk);
        
        int result = sqlite3_step(statement);
        
        if (result == SQLITE_ERROR)
        {
            NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
        }
        else if (result == SQLITE_ROW)
        {
            self.primaryKey = pk;
            self.status = sqlite3_column_int(statement, 0);
            
            char *str = (char *)sqlite3_column_text(statement, 1);
            self.urlValue = (str == NULL? @"":[NSString stringWithUTF8String:str]);
            
            str = (char *)sqlite3_column_text(statement, 2);
            self.sdwId = (str == NULL? @"":[NSString stringWithUTF8String:str]);

            NSTimeInterval updateTimeValue = sqlite3_column_double(statement, 3);
			self.updateTime = (updateTimeValue == -1? nil:[NSDate dateWithTimeIntervalSince1970:updateTimeValue]);

        }
        
        sqlite3_finalize(statement);
    }
    
    return self;
}

- (void) insertIntoDB:(sqlite3 *)database
{
    sqlite3_stmt *statement;
    
    static char *sql = "INSERT INTO URLTable (URL_Status, URL_Value, URL_SDWID, URL_UpdateTime) VALUES (?,?,?,?)";
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)
    {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
    
	if (!isExternalUpdate)
	{
		self.updateTime = [NSDate date];
	}
	
	isExternalUpdate = NO;
    
    sqlite3_bind_int(statement, 1, self.status);
    sqlite3_bind_text(statement, 2, [self.urlValue UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 3, [self.sdwId UTF8String], -1, SQLITE_TRANSIENT);
    
    NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);
    sqlite3_bind_double(statement, 4, updateTimeValue);
    
    int result = sqlite3_step(statement);
    
    if (result == SQLITE_ERROR)
    {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
    }
    
    sqlite3_finalize(statement);
}

- (void) updateIntoDB:(sqlite3 *)database
{
    sqlite3_stmt *statement;
    
    static char *sql = "UPDATE URLTable SET URL_Status=?, URL_Value=?, URL_SDWID=?, URL_UpdateTime=? WHERE URL_ID=?";
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)
    {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
    
	if (!isExternalUpdate)
	{
		self.updateTime = [NSDate date];
	}
	
	isExternalUpdate = NO;
    
	NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);
    
    sqlite3_bind_int(statement, 0, self.status);
    sqlite3_bind_text(statement, 1, [self.urlValue UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 2, [self.sdwId UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_double(statement, 4, updateTimeValue);
    sqlite3_bind_int(statement, 4, self.primaryKey);
    
    if (sqlite3_step(statement) == SQLITE_ERROR)
    {
        NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
    }
    
    sqlite3_finalize(statement);
}

- (void) updateSDWIDIntoDB:(sqlite3 *)database
{
	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
		static char *sql = "UPDATE URLTable SET URL_SDWID = ?, URL_UpdateTime = ? WHERE URL_ID=?";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	if (self.sdwId == nil)
	{
		self.sdwId = @"";
	}
    
	if (!isExternalUpdate)
	{
		self.updateTime = [NSDate date];
	}
	
	isExternalUpdate = NO;    
    
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
        static char *sql = "UPDATE URLTable SET URL_UpdateTime = ? WHERE URL_ID = ?";
		
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
        const char *sql = "DELETE FROM URLTable WHERE URL_ID=?";
        
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
        const char *sql = "UPDATE URLTable SET URL_Status=?, URL_UpdateTime=? WHERE URL_ID=?";
        
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    
    // Bind the primary key variable.
    
	self.status = URL_STATUS_DELETED;
	
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
