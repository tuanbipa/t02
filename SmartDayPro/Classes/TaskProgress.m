//
//  TaskProgress.m
//  SmartPlan
//
//  Created by Huy Le on 12/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <sqlite3.h>

#import "TaskProgress.h"

#import "Common.h"
#import "Task.h"
#import "DBManager.h"

static sqlite3_stmt *task_progress_init_statement = nil;
static sqlite3_stmt *task_progress_insert_statement = nil;
static sqlite3_stmt *task_progress_update_statement = nil;
static sqlite3_stmt *task_progress_endtime_update_statement = nil;
static sqlite3_stmt *task_progress_delete_statement = nil;

@implementation TaskProgress

@synthesize primaryKey;
@synthesize task;
@synthesize startTime;
@synthesize endTime;

- (id)init
{
	if (self = [super init])
	{
		self.primaryKey = -1;
		
		self.task = nil;
		self.startTime = nil;
		self.endTime = nil;
	}
	
	return self;
}

- (void)dealloc 
{
	self.startTime = nil;
	self.endTime = nil;
	
	[super dealloc];
}

- (id) copyWithZone:(NSZone*) zone{
	TaskProgress *copy = [[TaskProgress alloc] init];
	
	copy.primaryKey = primaryKey;
	copy.task = task;
	copy.startTime = startTime;
	copy.endTime = endTime;
	
	return copy;
}

// Creates the object with primary key and title is brought into memory.
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)database 
{
    if (self = [super init]) {
		
		//@synchronized([DBManager getInstance])
		{
		
		self.primaryKey = pk;
		
        // Compile the query for retrieving book data. See insertNewBookIntoDatabase: for more detail.
        if (task_progress_init_statement == nil) {
            // Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
            // This is a great way to optimize because frequently used queries can be compiled once, then with each
            // use new variable values can be bound to placeholders.
            const char *sql = "SELECT Task_StartTime, Task_EndTime FROM TaskProgressTable WHERE TaskProgress_ID=?";
            if (sqlite3_prepare_v2(database, sql, -1, &task_progress_init_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // For this query, we bind the primary key to the first (and only) placeholder in the statement.
        // Note that the parameters are numbered from 1, not from 0.
        sqlite3_bind_int(task_progress_init_statement, 1, pk);
        if (sqlite3_step(task_progress_init_statement) == SQLITE_ROW) 
		{
			NSTimeInterval startTimeValue = sqlite3_column_double(task_progress_init_statement, 0);
			NSTimeInterval endTimeValue = sqlite3_column_double(task_progress_init_statement, 1);			
			
  			self.startTime = (startTimeValue == -1? nil:[Common fromDBDate:[NSDate dateWithTimeIntervalSince1970:startTimeValue]]);
			self.endTime = (endTimeValue == -1? nil:[Common fromDBDate:[NSDate dateWithTimeIntervalSince1970:endTimeValue]]);
      } 
		
        // Reset the statement for future reuse.
        sqlite3_reset(task_progress_init_statement);
		}
    }
    return self;
}

- (void) insertIntoDB:(sqlite3 *)database
{
	//@synchronized([DBManager getInstance])
	{

    if (task_progress_insert_statement == nil) 
	{
        static char *sql = "INSERT INTO TaskProgressTable (Task_ID, Task_StartTime, Task_EndTime) VALUES(?,?,?)";
		
        if (sqlite3_prepare_v2(database, sql, -1, &task_progress_insert_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
		
    }
	
	NSTimeInterval startTimeValue = (self.startTime == nil? -1: [[Common toDBDate:self.startTime] timeIntervalSince1970]);
	NSTimeInterval endTimeValue = (self.endTime == nil? -1: [[Common toDBDate:self.endTime] timeIntervalSince1970]);	
	
	sqlite3_bind_int(task_progress_insert_statement, 1, self.task.primaryKey);
	sqlite3_bind_double(task_progress_insert_statement, 2, startTimeValue);
	sqlite3_bind_double(task_progress_insert_statement, 3, endTimeValue);
	
    int success = sqlite3_step(task_progress_insert_statement);
	
	sqlite3_reset(task_progress_insert_statement);	
	
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
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
}

- (void) updateIntoDB:(sqlite3 *)database
{
	//@synchronized([DBManager getInstance])
	{

    if (task_progress_update_statement == nil) {
        static char *sql = "UPDATE TaskProgressTable SET Task_StartTime = ?,Task_EndTime = ?,Task_ID = ? WHERE TaskProgress_ID = ?";		
		
        if (sqlite3_prepare_v2(database, sql, -1, &task_progress_update_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	NSTimeInterval startTimeValue = (self.startTime == nil? -1: [[Common toDBDate:self.startTime] timeIntervalSince1970]);
	NSTimeInterval endTimeValue = (self.endTime == nil? -1: [[Common toDBDate:self.endTime] timeIntervalSince1970]);	
	
	sqlite3_bind_int(task_progress_update_statement, 1, startTimeValue);
	sqlite3_bind_int(task_progress_update_statement, 2, endTimeValue);
    sqlite3_bind_int(task_progress_update_statement, 3, task.primaryKey);
	sqlite3_bind_int(task_progress_update_statement, 4, self.primaryKey);
	
    int success = sqlite3_step(task_progress_update_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(task_progress_update_statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
		
	}
}

- (void) updateEndTimeIntoDB:(sqlite3 *)database
{
	//@synchronized([DBManager getInstance])
	{

    if (task_progress_endtime_update_statement == nil) {
        static char *sql = "UPDATE TaskProgressTable SET Task_EndTime = ? WHERE TaskProgress_ID = ?";		
		
        if (sqlite3_prepare_v2(database, sql, -1, &task_progress_endtime_update_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	NSTimeInterval endTimeValue = (self.endTime == nil? -1: [[Common toDBDate:self.endTime] timeIntervalSince1970]);		
	
	sqlite3_bind_int(task_progress_endtime_update_statement, 1, endTimeValue);
	sqlite3_bind_int(task_progress_endtime_update_statement, 2, self.primaryKey);
	
    int success = sqlite3_step(task_progress_endtime_update_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(task_progress_endtime_update_statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
		
	}
}

- (void)deleteFromDatabase:(sqlite3 *)database 
{
	//@synchronized([DBManager getInstance])
	{

    // Compile the delete statement if needed.
    if (task_progress_delete_statement == nil) {
        const char *sql = "DELETE FROM TaskProgressTable WHERE TaskProgress_ID=?";
		//NSString *sql =[NSString stringWithFormat:@"DELETE FROM iVo_Tasks WHERE Task_ID=?",tableName];
        if (sqlite3_prepare_v2(database, sql, -1, &task_progress_delete_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
    // Bind the primary key variable.
    sqlite3_bind_int(task_progress_delete_statement, 1, self.primaryKey);
    // Execute the query.
    int success = sqlite3_step(task_progress_delete_statement);
    // Reset the statement for future use.
    sqlite3_reset(task_progress_delete_statement);
	
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }
	}
}

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements {
	if (task_progress_init_statement) sqlite3_finalize(task_progress_init_statement);				
    if (task_progress_insert_statement) sqlite3_finalize(task_progress_insert_statement);
    if (task_progress_update_statement) sqlite3_finalize(task_progress_update_statement);
    if (task_progress_endtime_update_statement) sqlite3_finalize(task_progress_endtime_update_statement);	
    if (task_progress_delete_statement) sqlite3_finalize(task_progress_delete_statement);
	
	task_progress_init_statement = nil;
	task_progress_insert_statement = nil;
	task_progress_update_statement = nil;
	task_progress_endtime_update_statement = nil;
	task_progress_delete_statement = nil;
}

@end
