//
//  AlertData.m
//  SmartCal
//
//  Created by MacBook Pro on 7/26/10.
//  Copyright 2010 LCL. All rights reserved.
//
#import <sqlite3.h>

#import "AlertData.h"

#import "Settings.h"
#import "Task.h"
#import "DBManager.h"

static sqlite3_stmt *alert_init_statement = nil;
static sqlite3_stmt *alert_insert_statement = nil;
static sqlite3_stmt *alert_update_statement = nil;
static sqlite3_stmt *alert_delete_statement = nil;

@implementation AlertData

@synthesize primaryKey;
@synthesize taskKey;

//@synthesize type;
@synthesize absoluteTime;
@synthesize beforeDuration;

- (id)init
{
	if (self = [super init])
	{
		self.primaryKey = -1; 
		self.absoluteTime = nil;
		self.beforeDuration = -15*60; // 15 minutes
	}
	
	return self;
}

// Creates the object with primary key and title is brought into memory.
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)database 
{
    if (self = [super init]) {
		//@synchronized([DBManager getInstance])
		{
		
        // Compile the query for retrieving book data. See insertNewBookIntoDatabase: for more detail.
        if (alert_init_statement == nil) {
            // Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
            // This is a great way to optimize because frequently used queries can be compiled once, then with each
            // use new variable values can be bound to placeholders.
            const char *sql = "SELECT Alert_TaskID, Alert_Data FROM AlertTable WHERE Alert_ID = ?";
            if (sqlite3_prepare_v2(database, sql, -1, &alert_init_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // For this query, we bind the primary key to the first (and only) placeholder in the statement.
        // Note that the parameters are numbered from 1, not from 0.
        sqlite3_bind_int(alert_init_statement, 1, pk);
        if (sqlite3_step(alert_init_statement) == SQLITE_ROW) 
		{
			self.primaryKey = pk;
			self.taskKey = sqlite3_column_int(alert_init_statement, 0);

			//NSString *alertStr = [NSString stringWithUTF8String:(char *)sqlite3_column_text(alert_init_statement, 1)];
			char *str = (char *)sqlite3_column_text(alert_init_statement, 1);
			NSString *alertStr = (str == NULL? @"":[NSString stringWithUTF8String:str]);			
			
			
			AlertData *tmp = [AlertData parseRepeatData:alertStr];
			
			if (tmp != nil)
			{
				[self updateByAlertData:tmp];
			}
        } 
		
        // Reset the statement for future reuse.
        sqlite3_reset(alert_init_statement);
		}
    }
	
    return self;
}

- (void) insertIntoDB:(sqlite3 *)database
{
	//@synchronized([DBManager getInstance])
	{

    if (alert_insert_statement == nil) 
	{
        static char *sql = "INSERT INTO AlertTable (Alert_TaskID, Alert_Data) \
		VALUES(?,?)";
		
        if (sqlite3_prepare_v2(database, sql, -1, &alert_insert_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
		
    }

	sqlite3_bind_int(alert_insert_statement, 1, self.taskKey);
	
	NSString *alertStr = [AlertData stringOfAlertData:self];
	
	sqlite3_bind_text(alert_insert_statement, 2, [alertStr UTF8String], -1, SQLITE_TRANSIENT);	
	
    int success = sqlite3_step(alert_insert_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(alert_insert_statement);
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
		//return -1;
	}
	}
}

- (void) updateIntoDB:(sqlite3 *)database
{
    //@synchronized([DBManager getInstance])
	{
	
    if (alert_update_statement == nil) {
        static char *sql = "UPDATE AlertTable SET Alert_TaskID = ?, Alert_Data = ? WHERE Alert_ID = ?";		
		
        if (sqlite3_prepare_v2(database, sql, -1, &alert_update_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	sqlite3_bind_int(alert_update_statement, 1, self.taskKey);
	
	NSString *alertStr = [AlertData stringOfAlertData:self];
	
	sqlite3_bind_text(alert_update_statement, 2, [alertStr UTF8String], -1, SQLITE_TRANSIENT);
	
	sqlite3_bind_int(alert_update_statement, 3, self.primaryKey);
		
    int success = sqlite3_step(alert_update_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(alert_update_statement);
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
    if (alert_delete_statement == nil) {
        const char *sql = "DELETE FROM AlertTable WHERE Alert_ID=?";

        if (sqlite3_prepare_v2(database, sql, -1, &alert_delete_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
    // Bind the primary key variable.
    sqlite3_bind_int(alert_delete_statement, 1, self.primaryKey);

    // Execute the query.
    int success = sqlite3_step(alert_delete_statement);
    // Reset the statement for future use.
    sqlite3_reset(alert_delete_statement);
	
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }
	}
}


- (id) copyWithZone:(NSZone*) zone{
	AlertData *copy = [[AlertData alloc] init];
	
	copy.primaryKey = primaryKey;
	copy.taskKey = taskKey;
	copy.absoluteTime = absoluteTime;
	copy.beforeDuration = beforeDuration;
	
	return copy;
}

- (void) updateByAlertData:(AlertData *)another
{
	self.absoluteTime = another.absoluteTime;
	self.beforeDuration = another.beforeDuration;
}

- (NSString *) getAlertTimeString:(NSInteger)taskType textDict:(NSDictionary *)textDict
{
	if (self.absoluteTime == nil)
	{
		if (self.beforeDuration == 0)
		{
			return taskType == TYPE_TASK?_onDueOfTaskText:_onDateOfEventText;
		}
		
		NSString *alertStr = [textDict objectForKey:[NSNumber numberWithInt:self.beforeDuration/60]];
		if (alertStr != nil)
		{
			return alertStr;
		}
		
		return [NSString stringWithFormat:@"%@ %@", [Common getDurationString:-self.beforeDuration], _beforeText];
	}
	
	return @"";

}

- (NSString *) getAbsoluteTimeString:(Task *)task
{
	NSDate *time = self.absoluteTime;
	
	if (time == nil)
	{
		time = (task.type == TYPE_TASK? task.deadline: task.startTime);
		
		if (self.beforeDuration != 0)
		{
			time = [Common dateByAddNumSecond:self.beforeDuration toDate:time];
		}
		
	}
	
	return [Common getFullDateTimeString:time];
}

- (void)dealloc 
{	
	self.absoluteTime = nil;
	
    [super dealloc];
}

+ (NSString *) stringOfAlertData:(AlertData *)data
{
	if (data != nil)
	{
		double absTime = (data.absoluteTime == nil?-1:[data.absoluteTime timeIntervalSince1970]);
						  
		return [NSString stringWithFormat:@"%f|%d", absTime, data.beforeDuration];
	}
	
	return @"";
}

+ (AlertData *) parseRepeatData:(NSString *)data
{
	if (data != nil && ![data isEqualToString:@""])
	{
		AlertData *ret = [[[AlertData alloc] init] autorelease]; 
		
		NSArray *parts = [data componentsSeparatedByString:@"|"];
		
		double absTime = [[parts objectAtIndex:0] doubleValue];
		
		if (absTime == -1)
		{
			ret.absoluteTime = nil;
		}
		else 
		{
			ret.absoluteTime = [NSDate dateWithTimeIntervalSince1970:absTime];
		}

		ret.beforeDuration = [[parts objectAtIndex:1] intValue];
		
		return ret;
	}
	
	return nil;
}

+ (NSDictionary *) getAlertTextDictionary
{
	NSString *alertTexts[7]={_15minBeforeText, _30minBeforeText, _45minBeforeText, _1hourBeforeText, _2hourBeforeText, _1dayBeforeText, _2dayBeforeText};
	NSInteger alertDurations[7] = {-15, -30, -45, -60, -120, -1440, -2880};
	
	NSMutableArray *durations = [NSMutableArray arrayWithCapacity:7];
	NSMutableArray *texts = [NSMutableArray arrayWithCapacity:7];
	
	for (int i=0; i<7; i++)
	{
		[durations addObject:[NSNumber numberWithInt:alertDurations[i]]];
		[texts addObject:alertTexts[i]];
	}
	
	return [NSDictionary dictionaryWithObjects:texts forKeys:durations];
	
}

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements {
    if (alert_init_statement) sqlite3_finalize(alert_init_statement);
    if (alert_insert_statement) sqlite3_finalize(alert_insert_statement);
    if (alert_update_statement) sqlite3_finalize(alert_update_statement);
	if (alert_delete_statement) sqlite3_finalize(alert_delete_statement);
	
	
	alert_init_statement = nil;
	alert_insert_statement = nil;
	alert_update_statement = nil;
	alert_delete_statement = nil;
}

@end
