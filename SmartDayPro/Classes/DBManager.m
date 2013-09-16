//
//  DBManager.m
//  SmartPlan
//
//  Created by Huy Le on 12/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DBManager.h"
#import "Settings.h"

#import "Common.h"

#import "Project.h"
#import "Task.h"
#import "Link.h"
#import "TaskProgress.h"
#import "ProjectManager.h"
#import "TaskManager.h"
#import "AlertData.h"
#import "URLAsset.h"
#import "Comment.h"
#import "UnreadComment.h"

extern BOOL _versionUpgrade;
extern BOOL _firstLaunch;
extern BOOL _dbUpgrade;

extern BOOL _isiPad;

DBManager *_dbManagerSingleton;

static sqlite3_stmt *_event_list_statement = nil;
static sqlite3_stmt *_ade_list_statement = nil;
static sqlite3_stmt *_all_task_list_statement = nil;
static sqlite3_stmt *_due_task_list_statement = nil;
static sqlite3_stmt *_start_task_list_statement = nil;
static sqlite3_stmt *_top_task_statement = nil;

@implementation DBManager

- (id) init
{
	if (self = [super init])
	{
	}
	
	return self;
}

- (void)dealloc 
{
	[super dealloc];
}

- (sqlite3 *) getDatabase
{
	return database;
}

- (void)createEditableCopyOfDatabaseIfNeeded {
	BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"SmartCalDB.sql"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
    // The writable database does not exist, so copy the default to the appropriate location.
  	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"SmartCalDB.sql"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }	
}

- (void)initializeDatabase {
    // The database is stored in the application bundle. 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"SmartCalDB.sql"];
    // Open the database. The database was prepared outside the application.
	
	if (sqlite3_config(SQLITE_CONFIG_SERIALIZED) == SQLITE_OK) {
		////NSLog(@"Can now use sqlite on multiple threads, using the same connection");
	}
	
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {		
		[self upgrade];
		
    } else {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
        // Additional error handling, as appropriate...
    }
}

#pragma mark SmartCal Support

- (NSMutableArray *) searchTitle:(NSString *)text
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:200];
    
    NSString *likeOp = [NSString stringWithFormat:@"%%%@%%", text];
    
    NSString *typeStr = [self getItemTypeString];
    
    ////printf("likeOp: %s\n", [likeOp UTF8String]);
	
	//const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_Type IN (0,4,5,8) AND Task_Status <> ? AND Task_Name LIKE ?";
    NSString *sql = @"SELECT Task_ID FROM TaskTable WHERE Task_Type IN (_TYPE_LIST) AND Task_Status <> ? AND Task_Name LIKE ?";
	
    sql = [sql stringByReplacingOccurrencesOfString:@"_TYPE_LIST" withString:typeStr];
    
    sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database,[sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TASK_STATUS_DELETED);
        sqlite3_bind_text(statement, 2, [likeOp UTF8String], -1, SQLITE_TRANSIENT);
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
            
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;    
}

/*
- (NSMutableArray *) searchLinkSource:(NSInteger)linkId
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:10];
    
    NSString *likeOp = [NSString stringWithFormat:@"%%%d%%", linkId];
    
    ////printf("likeOp: %s\n", [likeOp UTF8String]);
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_Type IN (0,4,5,8) AND Task_Link LIKE ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1, [likeOp UTF8String], -1, SQLITE_TRANSIENT);
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
            
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;    
}
*/
- (NSMutableArray *) getAllNotes
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:200];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_Status <> ? ORDER BY Task_StartTime DESC";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_NOTE);
		sqlite3_bind_int(statement, 2, TASK_STATUS_DELETED);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getTodayNotes
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:200];
    
    NSTimeInterval todayValue = [[Common toDBDate:[Common clearTimeForDate:[NSDate date]]] timeIntervalSince1970];
	
	NSString *sql = [NSString stringWithFormat:@"SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_Status <> ? AND Task_StartTime > %f AND (Task_StartTime - %f) < 86400 ORDER BY Task_StartTime DESC", todayValue, todayValue];
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_NOTE);
		sqlite3_bind_int(statement, 2, TASK_STATUS_DELETED);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

/*
- (NSMutableArray *) getNotesByDate:(NSDate *)date
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:200];
    
    NSTimeInterval dtValue = [[Common toDBDate:[Common clearTimeForDate:date]] timeIntervalSince1970];
	
	NSString *sql = [NSString stringWithFormat:@"SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_Status <> ? AND Task_StartTime > %f AND (Task_StartTime - %f) < 86400 ORDER BY Task_StartTime DESC", dtValue, dtValue];
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_NOTE);
		sqlite3_bind_int(statement, 2, TASK_STATUS_DELETED);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}
*/

- (NSMutableArray *) getNotesByThisWeek
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:200];
    
    Settings *settings = [Settings getInstance];
    
    NSDate *date = [Common getFirstWeekDate:[NSDate date] mondayAsWeekStart:(settings.weekStart==1)];
    
    NSTimeInterval dtValue = [[Common toDBDate:[Common clearTimeForDate:date]] timeIntervalSince1970];
	
	NSString *sql = [NSString stringWithFormat:@"SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_Status <> ? AND Task_StartTime > %f AND (Task_StartTime - %f) < 7*86400 ORDER BY Task_StartTime DESC", dtValue, dtValue];
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_NOTE);
		sqlite3_bind_int(statement, 2, TASK_STATUS_DELETED);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getAllTasks
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:200];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE (Task_Type = ? OR Task_Type = ?) AND Task_Status <> ? ORDER BY Task_SeqNo ASC";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_int(statement, 2, TYPE_SHOPPING_ITEM);
		sqlite3_bind_int(statement, 3, TASK_STATUS_DELETED);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getAllTasksEventsHaveLocation
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:200];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE (Task_Type = ? OR Task_Type = ?) AND Task_Status <> ? AND Task_Status <> ? AND (Task_Location IS NOT NULL AND Task_Location NOT LIKE '') ORDER BY Task_SeqNo ASC";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_int(statement, 2, TYPE_EVENT);
		sqlite3_bind_int(statement, 3, TASK_STATUS_DELETED);
        sqlite3_bind_int(statement, 4, TASK_STATUS_DONE);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getTasks2Sync
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:200];
    
    NSString *invisibleProjectListStr = [[ProjectManager getInstance] stringOfInvisibleProjectList];
	
	//const char *sql = invisibleProjectListStr == nil?"SELECT Task_ID FROM TaskTable WHERE (Task_Type = ? OR Task_Type = ?) AND Task_Status <> ? ORDER BY Task_SeqNo ASC":
    //    "SELECT Task_ID FROM TaskTable WHERE (Task_Type = ? OR Task_Type = ?) AND Task_Status <> ? AND Task_ProjectID NOT IN (?) ORDER BY Task_SeqNo ASC";

	NSString *sql = invisibleProjectListStr == nil?@"SELECT Task_ID FROM TaskTable WHERE (Task_Type = ? OR Task_Type = ?) AND Task_Status <> ? ORDER BY Task_SeqNo ASC":
    @"SELECT Task_ID FROM TaskTable WHERE (Task_Type = ? OR Task_Type = ?) AND Task_Status <> ? AND Task_ProjectID NOT IN (_PROJECT_LIST) ORDER BY Task_SeqNo ASC";

    if (invisibleProjectListStr != nil)
    {
        sql = [sql stringByReplacingOccurrencesOfString:@"_PROJECT_LIST" withString:invisibleProjectListStr];
    }    
    
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_int(statement, 2, TYPE_SHOPPING_ITEM);
		sqlite3_bind_int(statement, 3, TASK_STATUS_DELETED);
        
        /*
        if (invisibleProjectListStr != nil)
        {
            sqlite3_bind_text(statement, 4, [invisibleProjectListStr UTF8String], -1, SQLITE_TRANSIENT);
        }
        */
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getModifiedTasks2Sync:(NSDate *)afterDate
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	if (afterDate == nil)
	{
		//taskList = [self getAllTasks];
        taskList = [self getTasks2Sync];
	}
	else 
	{
        NSString *invisibleProjectListStr = [[ProjectManager getInstance] stringOfInvisibleProjectList];

		//const char *sql = invisibleProjectListStr == nil?"SELECT Task_ID FROM TaskTable WHERE (Task_Type = ? OR Task_Type = ?) AND (Task_SyncID = '' OR Task_UpdateTime >= ?)":
        //    "SELECT Task_ID FROM TaskTable WHERE (Task_Type = ? OR Task_Type = ?) AND (Task_SyncID = '' OR Task_UpdateTime >= ?) AND Task_ProjectID NOT IN (_PROJECT_LIST)";
        
		NSString *sql = invisibleProjectListStr == nil?@"SELECT Task_ID FROM TaskTable WHERE (Task_Type = ? OR Task_Type = ?) AND (Task_SyncID = '' OR Task_UpdateTime >= ?)":
        @"SELECT Task_ID FROM TaskTable WHERE (Task_Type = ? OR Task_Type = ?) AND (Task_SyncID = '' OR Task_UpdateTime >= ?) AND Task_ProjectID NOT IN (_PROJECT_LIST)";
        
        if (invisibleProjectListStr != nil)
        {
            sql = [sql stringByReplacingOccurrencesOfString:@"_PROJECT_LIST" withString:invisibleProjectListStr];
        }    
        
		sqlite3_stmt *statement;
		
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			sqlite3_bind_int(statement, 1, TYPE_TASK);
            sqlite3_bind_int(statement, 2, TYPE_SHOPPING_ITEM);
			sqlite3_bind_double(statement, 3, [afterDate timeIntervalSince1970]);
            
            /*
            if (invisibleProjectListStr != nil)
            {
                sqlite3_bind_text(statement, 4, [invisibleProjectListStr UTF8String], -1, SQLITE_TRANSIENT);
            }    
            */
			
			while (sqlite3_step(statement) == SQLITE_ROW) {
				int primaryKey = sqlite3_column_int(statement, 0);
				Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
				
				[taskList addObject:task];
				[task release];
			}
		}
		// "Finalize" the statement - releases the resources associated with the statement.
		sqlite3_finalize(statement);		
	}
	
	return taskList;	
}

- (NSString *) getItemNameByKey:(NSInteger)taskKey
{
	NSString *ret = @"";
	
	const char *sql = "SELECT Task_Name FROM TaskTable WHERE Task_ID = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, taskKey);

		if (sqlite3_step(statement) == SQLITE_ROW)
        {
			char *str = (char *)sqlite3_column_text(statement, 0);
            
            ret = (str == NULL? @"":[NSString stringWithUTF8String:str]);
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return ret;
}

- (NSString *) getProjectNameByKey:(NSInteger)prjKey
{
	NSString *ret = @"";
	
	const char *sql = "SELECT Project_Name FROM ProjectTable WHERE Project_ID = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, prjKey);
        
		if (sqlite3_step(statement) == SQLITE_ROW)
        {
			char *str = (char *)sqlite3_column_text(statement, 0);
            
            ret = (str == NULL? @"":[NSString stringWithUTF8String:str]);
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return ret;
}

- (NSMutableArray *) getTasks
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_Status <> ? AND Task_Status <> ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_int(statement, 2, TASK_STATUS_DONE);
		sqlite3_bind_int(statement, 3, TASK_STATUS_DELETED);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getVisibleTasks
{
    Settings *settings = [Settings getInstance];
    
    NSDate *start = [Common toDBDate:[Common getEndDate:[NSDate date]]];
    
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:200];
	
	sqlite3_stmt *statement = _all_task_list_statement;
	
	if (statement == nil)
	{
		const char *sql = settings.hideFutureTasks?"SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_Status <> ? AND Task_Status <> ? AND (Task_StartTime = -1 OR (Task_StartTime <> -1 AND Task_StartTime < ?)) ORDER BY Task_SeqNo ASC":"SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_Status <> ? AND Task_Status <> ? ORDER BY Task_SeqNo ASC";
        
        //printf("start time:%f\n", [start timeIntervalSince1970]);
		
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)	
		{
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));	
		}
	}
	
	sqlite3_bind_int(statement, 1, TYPE_TASK);
	sqlite3_bind_int(statement, 2, TASK_STATUS_DONE);
	sqlite3_bind_int(statement, 3, TASK_STATUS_DELETED);
	sqlite3_bind_double(statement, 4, [start timeIntervalSince1970]);
	
	while (sqlite3_step(statement) == SQLITE_ROW) {
		int primaryKey = sqlite3_column_int(statement, 0);
		Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
		
		[taskList addObject:task];
		[task release];
	}
	
	// "Finalize" the statement - releases the resources associated with the statement.
	//sqlite3_finalize(statement);
	sqlite3_reset(statement);
	
	return taskList;
}

- (NSMutableArray *) getVisibleTasks_old
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:200];
	
	sqlite3_stmt *statement = _all_task_list_statement;
	
	if (statement == nil)
	{
		const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_Status <> ? AND Task_Status <> ? AND Task_MergedSeqNo > -1 ORDER BY Task_MergedSeqNo ASC";
		
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)	
		{
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));	
		}
	}
	
	sqlite3_bind_int(statement, 1, TYPE_TASK);
	sqlite3_bind_int(statement, 2, TASK_STATUS_DONE);
	sqlite3_bind_int(statement, 3, TASK_STATUS_DELETED);
	
	while (sqlite3_step(statement) == SQLITE_ROW) {
		int primaryKey = sqlite3_column_int(statement, 0);
		Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
		
		[taskList addObject:task];
		[task release];
	}

	// "Finalize" the statement - releases the resources associated with the statement.
	//sqlite3_finalize(statement);
	sqlite3_reset(statement);
	
	return taskList;
}

- (NSMutableArray *) getRecurringTasks
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_RepeatData <> '' AND Task_Type = ? AND Task_Status <> ? AND Task_Status <> ? AND Task_MergedSeqNo > -1 ORDER BY Task_MergedSeqNo ASC";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_int(statement, 2, TASK_STATUS_DONE);
		sqlite3_bind_int(statement, 3, TASK_STATUS_DELETED);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getMustDoTasks
{
    Settings *settings = [Settings getInstance];
    
    int mustDoDays = settings.mustDoDays;
    
    if (mustDoDays <= 0)
    {
        return [NSMutableArray arrayWithCapacity:0];
    }
    
    NSDate *due = [Common toDBDate:[Common getEndDate:[Common dateByAddNumDay:mustDoDays-1 toDate:[NSDate date]]]];
    NSDate *start = [Common toDBDate:[Common getEndDate:[NSDate date]]];
    
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:100];
	
	sqlite3_stmt *statement = nil;
	
	if (statement == nil)
	{
		const char *sql = settings.hideFutureTasks?"SELECT Task_ID FROM TaskTable WHERE Task_Deadline <> -1 AND Task_Type = ? AND Task_Status <> ? AND Task_Status <> ?  AND Task_Deadline < ? AND (Task_StartTime = -1 OR (Task_StartTime <> -1 AND Task_StartTime < ?)) ORDER BY Task_Deadline ASC":"SELECT Task_ID FROM TaskTable WHERE Task_Deadline <> -1 AND Task_Type = ? AND Task_Status <> ? AND Task_Status <> ?  AND Task_Deadline < ? ORDER BY Task_Deadline ASC";
        
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)	
		{
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));	
		}
	}
	
	sqlite3_bind_int(statement, 1, TYPE_TASK);
	sqlite3_bind_int(statement, 2, TASK_STATUS_DONE);
	sqlite3_bind_int(statement, 3, TASK_STATUS_DELETED);
    sqlite3_bind_double(statement, 4, [due timeIntervalSince1970]);
    sqlite3_bind_double(statement, 5, [start timeIntervalSince1970]);
    
	while (sqlite3_step(statement) == SQLITE_ROW) {
		int primaryKey = sqlite3_column_int(statement, 0);
		Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
        
        //task.mustDo = YES;
		
		[taskList addObject:task];
		[task release];
	}
    
	// "Finalize" the statement - releases the resources associated with the statement.
	//sqlite3_finalize(statement);
	sqlite3_reset(statement);
	
	return taskList;
}

- (NSMutableArray *) getDueTasks
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:100];
	
	sqlite3_stmt *statement = _due_task_list_statement;

    Settings *settings = [Settings getInstance];
    
    NSDate *start = [Common toDBDate:[Common getEndDate:[NSDate date]]];
    
	if (statement == nil)
	{
		const char *sql = settings.hideFutureTasks?"SELECT Task_ID FROM TaskTable WHERE Task_Deadline <> -1 AND Task_Type = ? AND Task_Status <> ? AND Task_Status <> ? AND (Task_StartTime = -1 OR (Task_StartTime <> -1 AND Task_StartTime < ?)) ORDER BY Task_SeqNo ASC":"SELECT Task_ID FROM TaskTable WHERE Task_Deadline <> -1 AND Task_Type = ? AND Task_Status <> ? AND Task_Status <> ? ORDER BY Task_SeqNo ASC";
				
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)	
		{
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));	
		}
	}
	
	sqlite3_bind_int(statement, 1, TYPE_TASK);
	sqlite3_bind_int(statement, 2, TASK_STATUS_DONE);
	sqlite3_bind_int(statement, 3, TASK_STATUS_DELETED);
    sqlite3_bind_double(statement, 4, [start timeIntervalSince1970]);
    
	while (sqlite3_step(statement) == SQLITE_ROW) {
		int primaryKey = sqlite3_column_int(statement, 0);
		Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
		
		[taskList addObject:task];
		[task release];
	}

	// "Finalize" the statement - releases the resources associated with the statement.
	//sqlite3_finalize(statement);
	sqlite3_reset(statement);
	
	return taskList;
}

- (NSMutableArray *) getDueTasks_old
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:100];
	
	sqlite3_stmt *statement = _due_task_list_statement;
	
	if (statement == nil)
	{
		const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_Deadline <> -1 AND Task_Type = ? AND Task_Status <> ? AND Task_Status <> ? AND Task_MergedSeqNo > -1 ORDER BY Task_MergedSeqNo ASC";
		
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)	
		{
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));	
		}
	}
	
	sqlite3_bind_int(statement, 1, TYPE_TASK);
	sqlite3_bind_int(statement, 2, TASK_STATUS_DONE);
	sqlite3_bind_int(statement, 3, TASK_STATUS_DELETED);
	while (sqlite3_step(statement) == SQLITE_ROW) {
		int primaryKey = sqlite3_column_int(statement, 0);
		Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
		
		[taskList addObject:task];
		[task release];
	}
	
	// "Finalize" the statement - releases the resources associated with the statement.
	//sqlite3_finalize(statement);
	sqlite3_reset(statement);
	
	return taskList;
}

- (NSMutableArray *) getOverdueTasks
{
	NSDate *start = [Common toDBDate:[Common clearTimeForDate:[NSDate date]]];
	
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:5];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_GroupID = -1 AND \
	Task_Deadline <> -1 AND Task_Deadline <= ? AND Task_Status <> ? AND Task_Status <> ? ORDER BY Task_Deadline ASC";
	
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_double(statement, 2, [start timeIntervalSince1970]);
		sqlite3_bind_int(statement, 3, TASK_STATUS_DONE);
		sqlite3_bind_int(statement, 4, TASK_STATUS_DELETED);
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getStartTasks
{
    Settings *settings = [Settings getInstance];
    
    NSDate *start = [Common toDBDate:[Common getEndDate:[NSDate date]]];
    
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:200];
	
	sqlite3_stmt *statement = _start_task_list_statement;
	
	if (statement == nil)
	{
		const char *sql = settings.hideFutureTasks?"SELECT Task_ID FROM TaskTable WHERE Task_StartTime <> -1 AND Task_Type = ? AND Task_Status <> ? AND Task_Status <> ? AND (Task_StartTime = -1 OR (Task_StartTime <> -1 AND Task_StartTime < ?)) ORDER BY Task_SeqNo ASC":"SELECT Task_ID FROM TaskTable WHERE Task_StartTime <> -1 AND Task_Type = ? AND Task_Status <> ? AND Task_Status <> ? ORDER BY Task_SeqNo ASC";
		
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)	
		{
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));	
		}
	}
	
	sqlite3_bind_int(statement, 1, TYPE_TASK);
	sqlite3_bind_int(statement, 2, TASK_STATUS_DONE);
	sqlite3_bind_int(statement, 3, TASK_STATUS_DELETED);
    sqlite3_bind_double(statement, 4, [start timeIntervalSince1970]);
    
	while (sqlite3_step(statement) == SQLITE_ROW) {
		int primaryKey = sqlite3_column_int(statement, 0);
		Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
		
		[taskList addObject:task];
		[task release];
	}
	
	// "Finalize" the statement - releases the resources associated with the statement.
	//sqlite3_finalize(statement);
	sqlite3_reset(statement);
	
	return taskList;
}

- (NSMutableArray *) getStartTasks_old
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:200];
	
	sqlite3_stmt *statement = _start_task_list_statement;
	
	if (statement == nil)
	{
		const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_StartTime <> -1 AND Task_Type = ? AND Task_Status <> ? AND Task_Status <> ? AND Task_MergedSeqNo > -1 ORDER BY Task_MergedSeqNo ASC";
				
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)	
		{
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));	
		}
	}
	
	sqlite3_bind_int(statement, 1, TYPE_TASK);
	sqlite3_bind_int(statement, 2, TASK_STATUS_DONE);
	sqlite3_bind_int(statement, 3, TASK_STATUS_DELETED);
	while (sqlite3_step(statement) == SQLITE_ROW) {
		int primaryKey = sqlite3_column_int(statement, 0);
		Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
		
		[taskList addObject:task];
		[task release];
	}

	// "Finalize" the statement - releases the resources associated with the statement.
	//sqlite3_finalize(statement);
	sqlite3_reset(statement);
	
	return taskList;
}

- (NSMutableArray *) getActiveTasks
{
	NSDate *tomorrow = [Common dateByAddNumDay:1 toDate:[NSDate date]];
	
	NSDate *start = [Common toDBDate:[Common clearTimeForDate:tomorrow]];
	
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_Status <> ? AND Task_Status <> ? AND Task_StartTime <> -1 AND Task_StartTime < ? AND Task_MergedSeqNo > -1 ORDER BY Task_MergedSeqNo ASC";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_int(statement, 2, TASK_STATUS_DONE);
		sqlite3_bind_int(statement, 3, TASK_STATUS_DELETED);
		sqlite3_bind_double(statement, 4, [start timeIntervalSince1970]);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	else 
	{
		 NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}

	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getInActiveTasks
{
	NSDate *tomorrow = [Common dateByAddNumDay:1 toDate:[NSDate date]];
	
	NSDate *start = [Common toDBDate:[Common clearTimeForDate:tomorrow]];
	
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_Status <> ? AND Task_Status <> ? AND Task_StartTime <> -1 AND Task_StartTime >= ? AND Task_MergedSeqNo > -1 ORDER BY Task_MergedSeqNo ASC";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_int(statement, 2, TASK_STATUS_DONE);
		sqlite3_bind_int(statement, 3, TASK_STATUS_DELETED);
		sqlite3_bind_double(statement, 4, [start timeIntervalSince1970]);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getPinnedTasks
{
    Settings *settings = [Settings getInstance];
    
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
    
    NSDate *start = [Common toDBDate:[Common getEndDate:[NSDate date]]];
	
	const char *sql = settings.hideFutureTasks?"SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_Status == ? AND (Task_StartTime = -1 OR (Task_StartTime <> -1 AND Task_StartTime < ?)) ORDER BY Task_SeqNo ASC":"SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_Status == ? ORDER BY Task_SeqNo ASC";
    
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_int(statement, 2, TASK_STATUS_PINNED);
        sqlite3_bind_double(statement, 3, [start timeIntervalSince1970]);
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
    
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getPinnedTasks_old
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_Status == ? AND Task_MergedSeqNo > -1 ORDER BY Task_MergedSeqNo ASC";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_int(statement, 2, TASK_STATUS_PINNED);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getDoneTasks
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_Status = ? AND (Task_RepeatData = '' OR (Task_RepeatData <> '' AND Task_GroupID > -1)) ORDER BY Task_CompletionTime DESC";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_int(statement, 2, TASK_STATUS_DONE);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getDoneTasks4Plan:(NSInteger)planKey
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_Status = ? AND Task_ProjectID = ? AND (Task_RepeatData = '' OR (Task_RepeatData <> '' AND Task_GroupID > -1)) ORDER BY Task_CompletionTime DESC";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_int(statement, 2, TASK_STATUS_DONE);
        sqlite3_bind_int(statement, 3, planKey);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getDoneTasksToday
{
	NSDate *tmp = [Common clearTimeForDate:[NSDate date]];
	NSDate *start = [Common toDBDate:tmp];
	NSDate *end = [Common dateByAddNumDay:1 toDate:start];
    
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_Status = ? AND (Task_RepeatData = '' OR (Task_RepeatData <> '' AND Task_GroupID > -1)) \
        AND (Task_CompletionTime >= ? AND Task_CompletionTime < ?) ORDER BY Task_CompletionTime DESC";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_int(statement, 2, TASK_STATUS_DONE);
		sqlite3_bind_int(statement, 3, [start timeIntervalSince1970]);
		sqlite3_bind_int(statement, 4, [end timeIntervalSince1970]);
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getDoneTasksOnDate: (NSDate*) date
{
	NSDate *tmp = [Common clearTimeForDate:date];
	NSDate *start = [Common toDBDate:tmp];
	NSDate *end = [Common dateByAddNumDay:1 toDate:start];
    
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_Status = ? AND (Task_RepeatData = '' OR (Task_RepeatData <> '' AND Task_GroupID > -1)) \
    AND (Task_CompletionTime >= ? AND Task_CompletionTime < ?) ORDER BY Task_CompletionTime DESC";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_int(statement, 2, TASK_STATUS_DONE);
		sqlite3_bind_int(statement, 3, [start timeIntervalSince1970]);
		sqlite3_bind_int(statement, 4, [end timeIntervalSince1970]);
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getAllItemsForPlan:(NSInteger)planKey
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_Status <> ? AND Task_ProjectID = ? ORDER BY Task_SeqNo ASC";
	
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TASK_STATUS_DELETED);
		sqlite3_bind_int(statement, 2, planKey);
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getTasksForPlan:(NSInteger)planKey
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE (Task_Type = ? OR Task_Type = ?) AND Task_Status <> ? AND Task_ProjectID = ? ORDER BY Task_SeqNo ASC";
	
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_int(statement, 2, TYPE_SHOPPING_ITEM);		
		sqlite3_bind_int(statement, 3, TASK_STATUS_DELETED);
		sqlite3_bind_int(statement, 4, planKey);
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getTasksForPlan_old:(NSInteger)planKey
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_Status <> ? AND Task_ProjectID = ? ORDER BY Task_SeqNo ASC";
	
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_int(statement, 2, TASK_STATUS_DELETED);
		sqlite3_bind_int(statement, 3, planKey);
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getPinnedTasksForPlan:(NSInteger)planKey
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_RepeatData = '' AND (Task_Type = ? OR Task_Type = ?) AND Task_Status = ? AND Task_ProjectID = ? ORDER BY Task_SeqNo ASC";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_int(statement, 2, TYPE_SHOPPING_ITEM);
		sqlite3_bind_int(statement, 3, TASK_STATUS_PINNED);
		sqlite3_bind_int(statement, 4, planKey);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getPinnedTasksForPlan_old:(NSInteger)planKey
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_RepeatData = '' AND Task_Type = ? AND Task_Status = ? AND Task_ProjectID = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_int(statement, 2, TASK_STATUS_PINNED);
		sqlite3_bind_int(statement, 3, planKey);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getActiveTasksForPlan:(NSInteger)planKey
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE (Task_Type = ? OR Task_Type = ?) AND Task_Status <> ? AND Task_Status <> ? AND Task_ProjectID = ? ORDER BY Task_SeqNo ASC";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_int(statement, 2, TYPE_SHOPPING_ITEM);
		sqlite3_bind_int(statement, 3, TASK_STATUS_DONE);
		sqlite3_bind_int(statement, 4, TASK_STATUS_DELETED);
		sqlite3_bind_int(statement, 5, planKey);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSInteger) countItems: (NSInteger)type inPlan:(NSInteger)inPlan
{
    NSInteger count = 0;
    
    BOOL eventQuery = (type == TYPE_EVENT || type == TASK_FILTER_PINNED);
    
	/*const char *sql = (eventQuery?
                       "SELECT Count(Task_ID) FROM TaskTable WHERE Task_Status <> ? AND Task_Status <> ? AND (Task_Type = ? OR Task_Type = ?) AND Task_ProjectID = ? ORDER BY Task_SeqNo ASC"
                       :"SELECT Count(Task_ID) FROM TaskTable WHERE Task_Status <> ? AND Task_Status <> ? AND Task_Type = ? AND Task_ProjectID = ? ORDER BY Task_SeqNo ASC");*/
    NSString *string = nil;
    if (eventQuery) {
        NSString *exstraParam = (type == TYPE_EVENT)? [NSString stringWithFormat:@"Task_ExtraStatus <> %d", TASK_EXTRA_STATUS_ANCHORED] : [NSString stringWithFormat:@"Task_ExtraStatus = %d", TASK_EXTRA_STATUS_ANCHORED];
        
        string = [NSString stringWithFormat:@"SELECT Count(Task_ID) FROM TaskTable WHERE Task_Status <> %d AND Task_Status <> %d AND (Task_Type = %d OR Task_Type = %d) AND Task_ProjectID = %d AND %@ ORDER BY Task_SeqNo ASC", TASK_STATUS_DONE, TASK_STATUS_DELETED, TYPE_EVENT, TYPE_ADE, inPlan, exstraParam];
    } else {
        string = [NSString stringWithFormat:@"SELECT Count(Task_ID) FROM TaskTable WHERE Task_Status <> %d AND Task_Status <> %d AND Task_Type = %d AND Task_ProjectID = %d ORDER BY Task_SeqNo ASC", TASK_STATUS_DONE, TASK_STATUS_DELETED, type, inPlan];
    }
    const char *sql = [string cStringUsingEncoding:NSASCIIStringEncoding];
    
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		/*sqlite3_bind_int(statement, 1, TASK_STATUS_DONE);
		sqlite3_bind_int(statement, 2, TASK_STATUS_DELETED);
		sqlite3_bind_int(statement, 3, type);        
		sqlite3_bind_int(statement, 4, eventQuery?TYPE_ADE:inPlan);
        
        if (eventQuery)
        {
            sqlite3_bind_int(statement, 5, inPlan);
        }*/
        
		if (sqlite3_step(statement) == SQLITE_ROW) 
        {
			count = sqlite3_column_int(statement, 0);
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return count;
}


- (NSMutableArray *) getItems: (NSInteger)type inPlan:(NSInteger)inPlan
{
    BOOL eventQuery = (type == TYPE_EVENT || type == TASK_FILTER_PINNED);
    
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	/*const char *sql = (eventQuery?
                       "SELECT Task_ID FROM TaskTable WHERE Task_Status <> ? AND Task_Status <> ? AND (Task_Type = ? OR Task_Type = ?) AND Task_ExtraStatus != ? AND Task_ProjectID = ? ORDER BY Task_SeqNo ASC"
                       :"SELECT Task_ID FROM TaskTable WHERE Task_Status <> ? AND Task_Status <> ? AND ((Task_Type = ? AND Task_Type = ?) OR Task_ExtraStatus == ?) AND Task_ProjectID = ? ORDER BY Task_SeqNo ASC");*/
    
    NSString *string = nil;
    if (eventQuery) {
        NSString *exstraParam = (type == TYPE_EVENT)? [NSString stringWithFormat:@"Task_ExtraStatus <> %d", TASK_EXTRA_STATUS_ANCHORED] : [NSString stringWithFormat:@"Task_ExtraStatus = %d", TASK_EXTRA_STATUS_ANCHORED];
        
        string = [NSString stringWithFormat:@"SELECT Task_ID FROM TaskTable WHERE Task_Status <> %d AND Task_Status <> %d AND (Task_Type = %d OR Task_Type = %d) AND Task_ProjectID = %d AND %@ ORDER BY Task_SeqNo ASC", TASK_STATUS_DONE, TASK_STATUS_DELETED, TYPE_EVENT, TYPE_ADE, inPlan, exstraParam];
    } else {
        string = [NSString stringWithFormat:@"SELECT Task_ID FROM TaskTable WHERE Task_Status <> %d AND Task_Status <> %d AND Task_Type = %d AND Task_ProjectID = %d ORDER BY Task_SeqNo ASC", TASK_STATUS_DONE, TASK_STATUS_DELETED, type, inPlan];
    }
    const char *sql = [string cStringUsingEncoding:NSASCIIStringEncoding];
    
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		/*sqlite3_bind_int(statement, 1, TASK_STATUS_DONE);
		sqlite3_bind_int(statement, 2, TASK_STATUS_DELETED);
		sqlite3_bind_int(statement, 3, type);
        sqlite3_bind_int(statement, 4, type==TYPE_EVENT?TYPE_ADE:type);
        sqlite3_bind_int(statement, 5, TASK_EXTRA_STATUS_ANCHORED);
        sqlite3_bind_int(statement, 6, inPlan);*/
        
        /*if (eventQuery)
        {
            sqlite3_bind_int(statement, 6, inPlan);
        }*/
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getTasksInGroup:(NSInteger)groupKey
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_GroupID = ? AND Task_Status <> ? AND Task_Status <> ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, groupKey);
		sqlite3_bind_int(statement, 2, TASK_STATUS_DONE);
		sqlite3_bind_int(statement, 3, TASK_STATUS_DELETED);		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (Task *) getDeletedExceptionForRE:(NSInteger)reKey
{
    Task *ret = nil;
    
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_GroupID = ? AND Task_Type = ? AND Task_Status <> ? AND Task_Status <> ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
    {
		sqlite3_bind_int(statement, 1, reKey);
		sqlite3_bind_int(statement, 2, TYPE_RE_DELETED_EXCEPTION);
		sqlite3_bind_int(statement, 3, TASK_STATUS_DONE);
		sqlite3_bind_int(statement, 4, TASK_STATUS_DELETED);		
		
		int success = sqlite3_step(statement);
        
        if (success == SQLITE_ROW) 
        {
			int primaryKey = sqlite3_column_int(statement, 0);
			ret = [[[Task alloc] initWithPrimaryKey:primaryKey database:database] autorelease];
		}
        
        sqlite3_finalize(statement);
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	
	return ret;
}

- (NSMutableArray *) getExceptionsForRE:(NSInteger)reKey
{
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:10];
    
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_GroupID = ? AND Task_Type = ? AND Task_Status <> ? AND Task_Status <> ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK)
    {
		sqlite3_bind_int(statement, 1, reKey);
		sqlite3_bind_int(statement, 2, TYPE_EVENT);
		sqlite3_bind_int(statement, 3, TASK_STATUS_DONE);
		sqlite3_bind_int(statement, 4, TASK_STATUS_DELETED);
		
		int success = sqlite3_step(statement);
        
        if (success == SQLITE_ROW)
        {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *exc = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
            
            [ret addObject:exc];
            [exc release];
		}
        
        sqlite3_finalize(statement);
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	
	return ret;
}

- (NSMutableArray *) getREs
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:10];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_RepeatData <> '' AND Task_GroupID = -1 AND Task_Type = ? \
	AND Task_Status <> ? AND Task_Status <> ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_EVENT);
		sqlite3_bind_int(statement, 2, TASK_STATUS_DONE);
		sqlite3_bind_int(statement, 3, TASK_STATUS_DELETED);		
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getRADEs
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:10];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_RepeatData <> '' AND Task_GroupID = -1 AND Task_Type = ? \
	AND Task_Status <> ? AND Task_Status <> ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_ADE);
		sqlite3_bind_int(statement, 2, TASK_STATUS_DONE);
		sqlite3_bind_int(statement, 3, TASK_STATUS_DELETED);		
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getNotesOnDate:(NSDate *)date
{
	NSDate *tmp = [Common clearTimeForDate:date];
	NSDate *start = [Common toDBDate:tmp];
	NSDate *end = [Common dateByAddNumDay:1 toDate:start];
	
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_RepeatData = '' AND Task_GroupID = -1 AND Task_Type = ? AND \
	(Task_StartTime >= ? AND Task_StartTime < ?) AND Task_Status <> ? AND Task_Status <> ?";
	
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_NOTE);
		sqlite3_bind_double(statement, 2, [start timeIntervalSince1970]);
		sqlite3_bind_double(statement, 3, [end timeIntervalSince1970]);
		sqlite3_bind_int(statement, 4, TASK_STATUS_DONE);
		sqlite3_bind_int(statement, 5, TASK_STATUS_DELETED);		
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getNotesFromDate:(NSDate *)fromDate toDate:(NSDate *) toDate
{
	NSDate *start = [Common toDBDate:fromDate];
	NSDate *end = [Common toDBDate:toDate];
	
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_RepeatData = '' AND Task_GroupID = -1 AND Task_Type = ? AND \
	(Task_StartTime >= ? AND Task_StartTime < ?) AND Task_Status <> ? AND Task_Status <> ?";
	
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_NOTE);
		sqlite3_bind_double(statement, 2, [start timeIntervalSince1970]);
		sqlite3_bind_double(statement, 3, [end timeIntervalSince1970]);
		sqlite3_bind_int(statement, 4, TASK_STATUS_DONE);
		sqlite3_bind_int(statement, 5, TASK_STATUS_DELETED);
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getEventsOnDate:(NSDate *)date
{
	NSDate *tmp = [Common clearTimeForDate:date];
	NSDate *start = [Common toDBDate:tmp];
	NSDate *end = [Common dateByAddNumDay:1 toDate:start];
	
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];

    NSInteger defaultOffset = [[NSTimeZone defaultTimeZone] secondsFromGMT];
    
    const char *sql = "SELECT Task_ID, CASE WHEN Task_TimeZoneID = 0 THEN Task_StartTime ELSE (Task_StartTime + ? - Task_TimeZoneOffset) END AS StartTime, CASE WHEN Task_TimeZoneID = 0 THEN Task_EndTime ELSE (Task_EndTime + ? - Task_TimeZoneOffset) END AS EndTime FROM TaskTable WHERE ((Task_RepeatData = '' AND Task_GroupID = -1) OR (Task_GroupID <> -1)) AND Task_Type = ? AND \
	((StartTime >= ? AND StartTime < ?) OR \
	(StartTime < ? AND EndTime > ?)) AND Task_Status <> ? AND Task_Status <> ?";
	
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK)
    {
		sqlite3_bind_int(statement, 1, defaultOffset);
		sqlite3_bind_int(statement, 2, defaultOffset);
		sqlite3_bind_int(statement, 3, TYPE_EVENT);
		sqlite3_bind_double(statement, 4, [start timeIntervalSince1970]);
		sqlite3_bind_double(statement, 5, [end timeIntervalSince1970]);
		sqlite3_bind_double(statement, 6, [start timeIntervalSince1970]);
		sqlite3_bind_double(statement, 7, [start timeIntervalSince1970]);
		sqlite3_bind_int(statement, 8, TASK_STATUS_DONE);
		sqlite3_bind_int(statement, 9, TASK_STATUS_DELETED);
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getADEsOnDate:(NSDate *)date
{
	NSDate *start = [Common toDBDate:[Common clearTimeForDate:date]];
	
	NSDate *end = [Common dateByAddNumDay:1 toDate:start];
	
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:5];
	
	//const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_RepeatData = '' AND Task_GroupID = -1 AND Task_Type = ? AND \
	((Task_StartTime >= ? AND Task_StartTime < ?) OR \
	(Task_StartTime < ? AND Task_EndTime > ?)) AND Task_Status <> ? AND Task_Status <> ?";

	const char *sql = "SELECT Task_ID FROM TaskTable WHERE  ((Task_RepeatData = '' AND Task_GroupID = -1) OR (Task_GroupID <> -1)) AND Task_Type = ? AND \
	((Task_StartTime >= ? AND Task_StartTime < ?) OR \
	(Task_StartTime < ? AND Task_EndTime > ?)) AND Task_Status <> ? AND Task_Status <> ?";
	
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_ADE);
		sqlite3_bind_double(statement, 2, [start timeIntervalSince1970]);
		sqlite3_bind_double(statement, 3, [end timeIntervalSince1970]);
		sqlite3_bind_double(statement, 4, [start timeIntervalSince1970]);
		sqlite3_bind_double(statement, 5, [start timeIntervalSince1970]);
		sqlite3_bind_int(statement, 6, TASK_STATUS_DONE);
		sqlite3_bind_int(statement, 7, TASK_STATUS_DELETED);		
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
            
            //printf("ade %s from DB - pk:%d - sdwid: %s\n", [task.name UTF8String], task.primaryKey, [task.sdwId UTF8String]);
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getSTasksOnDate:(NSDate *)date
{
	NSDate *start = [Common toDBDate:[Common clearTimeForDate:date]];
	NSDate *end = [Common dateByAddNumDay:1 toDate:start];
	
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:5];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_RepeatData = '' AND Task_GroupID = -1 AND \
	(Task_StartTime >= ? AND Task_StartTime < ?) AND Task_Status <> ? AND Task_Status <> ?";
	
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_double(statement, 2, [start timeIntervalSince1970]);
		sqlite3_bind_double(statement, 3, [end timeIntervalSince1970]);
		sqlite3_bind_int(statement, 4, TASK_STATUS_DONE);
		sqlite3_bind_int(statement, 5, TASK_STATUS_DELETED);
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getSTasksFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
	NSDate *start = [Common toDBDate:fromDate];
	NSDate *end = [Common toDBDate:toDate];	
	
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:5];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_RepeatData = '' AND Task_GroupID = -1 AND \
	(Task_StartTime >= ? AND Task_StartTime < ?) AND Task_Status <> ? AND Task_Status <> ?";
	
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_double(statement, 2, [start timeIntervalSince1970]);
		sqlite3_bind_double(statement, 3, [end timeIntervalSince1970]);
		sqlite3_bind_int(statement, 4, TASK_STATUS_DONE);
		sqlite3_bind_int(statement, 5, TASK_STATUS_DELETED);
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getDueTasksOnDate:(NSDate *)date
{
	NSDate *start = [Common toDBDate:[Common clearTimeForDate:date]];
	NSDate *end = [Common dateByAddNumDay:1 toDate:start];
	
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:5];
	
	//const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_RepeatData = '' AND Task_GroupID = -1 AND \
	(Task_Deadline >= ? AND Task_Deadline < ?) AND Task_Status <> ? AND Task_Status <> ?";

	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_GroupID = -1 AND \
	(Task_Deadline >= ? AND Task_Deadline < ?) AND Task_Status <> ? AND Task_Status <> ?";
	
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_double(statement, 2, [start timeIntervalSince1970]);
		sqlite3_bind_double(statement, 3, [end timeIntervalSince1970]);
		sqlite3_bind_int(statement, 4, TASK_STATUS_DONE);
		sqlite3_bind_int(statement, 5, TASK_STATUS_DELETED);
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getDueTasksFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
	NSDate *start = [Common toDBDate:fromDate];
	NSDate *end = [Common toDBDate:toDate];
	
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:5];
	
	//const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_RepeatData = '' AND Task_GroupID = -1 AND \
	(Task_Deadline >= ? AND Task_Deadline < ?) AND Task_Status <> ? AND Task_Status <> ?";
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_GroupID = -1 AND \
	(Task_Deadline >= ? AND Task_Deadline < ?) AND Task_Status <> ? AND Task_Status <> ?";
    
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_double(statement, 2, [start timeIntervalSince1970]);
		sqlite3_bind_double(statement, 3, [end timeIntervalSince1970]);
		sqlite3_bind_int(statement, 4, TASK_STATUS_DONE);
		sqlite3_bind_int(statement, 5, TASK_STATUS_DELETED);
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (BOOL) checkDueTasksOnDate:(NSDate *)date
{
	BOOL ret = NO;
	
	NSDate *start = [Common toDBDate:[Common clearTimeForDate:date]];
	NSDate *end = [Common dateByAddNumDay:1 toDate:start];
	
	const char *sql = "SELECT Count(*) FROM TaskTable WHERE Task_Type = ? AND Task_RepeatData = '' AND Task_GroupID = -1 AND \
	(Task_Deadline >= ? AND Task_Deadline < ?) AND Task_Status <> ? AND Task_Status <> ?";
	
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_double(statement, 2, [start timeIntervalSince1970]);
		sqlite3_bind_double(statement, 3, [end timeIntervalSince1970]);
		sqlite3_bind_int(statement, 4, TASK_STATUS_DONE);
		sqlite3_bind_int(statement, 5, TASK_STATUS_DELETED);
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int count = sqlite3_column_int(statement, 0);
			
			if (count > 0)
			{
				ret = YES;
			}
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return ret;
}

- (NSMutableArray *) getEventsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
	NSDate *start = [Common toDBDate:fromDate];
	NSDate *end = [Common toDBDate:toDate];
	
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];

	sqlite3_stmt *statement = _event_list_statement;

    NSInteger defaultOffset = [[NSTimeZone defaultTimeZone] secondsFromGMT];
    	
	if (statement == nil)
	{
        /*
		const char *sql = "SELECT Task_ID, (Task_StartTime + ? - Task_TimeZoneOffset) AS StartTime, (Task_EndTime + ? - Task_TimeZoneOffset) AS EndTime FROM TaskTable WHERE ((Task_RepeatData = '' AND Task_GroupID = -1) OR (Task_GroupID <> -1)) AND Task_Type = ?  AND \
		((StartTime >= ? AND StartTime < ?) OR \
		(StartTime < ? AND EndTime > ?)) AND Task_Status <> ? AND Task_Status <> ?";*/
        
		const char *sql = "SELECT Task_ID, CASE WHEN Task_TimeZoneID = 0 THEN Task_StartTime ELSE (Task_StartTime + ? - Task_TimeZoneOffset) END AS StartTime, CASE WHEN Task_TimeZoneID = 0 THEN Task_EndTime ELSE (Task_EndTime + ? - Task_TimeZoneOffset) END AS EndTime FROM TaskTable WHERE ((Task_RepeatData = '' AND Task_GroupID = -1) OR (Task_GroupID <> -1)) AND Task_Type = ?  AND \
		((StartTime >= ? AND StartTime < ?) OR \
		(StartTime < ? AND EndTime > ?)) AND Task_Status <> ? AND Task_Status <> ?";        
		
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)	
		{
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));	
		}
	}

	sqlite3_bind_int(statement, 1, defaultOffset);
	sqlite3_bind_int(statement, 2, defaultOffset);
	sqlite3_bind_int(statement, 3, TYPE_EVENT);
	sqlite3_bind_double(statement, 4, [start timeIntervalSince1970]);
	sqlite3_bind_double(statement, 5, [end timeIntervalSince1970]);
	sqlite3_bind_double(statement, 6, [start timeIntervalSince1970]);
	sqlite3_bind_double(statement, 7, [start timeIntervalSince1970]);
	sqlite3_bind_int(statement, 8, TASK_STATUS_DONE);
	sqlite3_bind_int(statement, 9, TASK_STATUS_DELETED);
	
	while (sqlite3_step(statement) == SQLITE_ROW) {
		int primaryKey = sqlite3_column_int(statement, 0);
		Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
		
		[taskList addObject:task];
		[task release];
	}
	
	// "Finalize" the statement - releases the resources associated with the statement.
	//sqlite3_finalize(statement);
	sqlite3_reset(statement);

	return taskList;
}

- (NSMutableArray *) getADEsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
	NSDate *start = [Common toDBDate:fromDate];
	NSDate *end = [Common toDBDate:toDate];
	
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:50];
	
	sqlite3_stmt *statement = _ade_list_statement;
	
	if (statement == nil)
	{
		//const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_RepeatData = '' AND Task_GroupID = -1 AND Task_Type = ? AND \
		((Task_StartTime >= ? AND Task_StartTime < ?) OR \
		(Task_StartTime < ? AND Task_EndTime > ?)) AND Task_Status <> ? AND Task_Status <> ?";

		const char *sql = "SELECT Task_ID FROM TaskTable WHERE ((Task_RepeatData = '' AND Task_GroupID = -1) OR Task_GroupID <> -1) AND Task_Type = ? AND \
		((Task_StartTime >= ? AND Task_StartTime < ?) OR \
		(Task_StartTime < ? AND Task_EndTime > ?)) AND Task_Status <> ? AND Task_Status <> ?";
		
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)	
		{
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));	
		}
	}

	sqlite3_bind_int(statement, 1, TYPE_ADE);
	sqlite3_bind_double(statement, 2, [start timeIntervalSince1970]);
	sqlite3_bind_double(statement, 3, [end timeIntervalSince1970]);
	sqlite3_bind_double(statement, 4, [start timeIntervalSince1970]);
	sqlite3_bind_double(statement, 5, [start timeIntervalSince1970]);
	sqlite3_bind_int(statement, 6, TASK_STATUS_DONE);
	sqlite3_bind_int(statement, 7, TASK_STATUS_DELETED);
	
	while (sqlite3_step(statement) == SQLITE_ROW) {
		int primaryKey = sqlite3_column_int(statement, 0);
		Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
		
		[taskList addObject:task];
		[task release];
	}
	
	// "Finalize" the statement - releases the resources associated with the statement.
	//sqlite3_finalize(statement);
	sqlite3_reset(statement);
	
	return taskList;
}

- (NSMutableArray *) getAllEvents //get all non-repeating events
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_RepeatData = '' AND Task_GroupID = -1 AND (Task_Type = ? OR Task_Type = ?) \
	AND Task_Status <> ? AND Task_Status <> ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_EVENT);
		sqlite3_bind_int(statement, 2, TYPE_ADE);
		sqlite3_bind_int(statement, 3, TASK_STATUS_DONE);
		sqlite3_bind_int(statement, 4, TASK_STATUS_DELETED);
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getEvents2Sync //get all events to sync
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:100];
    
    NSString *invisibleProjectListStr = [[ProjectManager getInstance] stringOfInvisibleProjectList];

	/*
    NSString *sql = invisibleProjectListStr==nil?@"SELECT Task_ID FROM TaskTable WHERE (Task_Type = ? OR Task_Type = ?) AND Task_Status <> ?":
    @"SELECT Task_ID FROM TaskTable WHERE (Task_Type = ? OR Task_Type = ?) AND Task_Status <> ? AND Task_ProjectID NOT IN (_PROJECT_LIST)";
    */
    
    NSString *sql = invisibleProjectListStr==nil?@"SELECT Task_ID FROM TaskTable WHERE (Task_Type = ? OR Task_Type = ?) AND Task_Status <> ? AND ((Task_ExtraStatus & ?) = 0)":
    @"SELECT Task_ID FROM TaskTable WHERE (Task_Type = ? OR Task_Type = ?) AND Task_Status <> ? AND ((Task_ExtraStatus & ?) = 0) AND Task_ProjectID NOT IN (_PROJECT_LIST)";    

    if (invisibleProjectListStr != nil)
    {
        sql = [sql stringByReplacingOccurrencesOfString:@"_PROJECT_LIST" withString:invisibleProjectListStr];
    }    	
    
    sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_EVENT);
		sqlite3_bind_int(statement, 2, TYPE_ADE);
		sqlite3_bind_int(statement, 3, TASK_STATUS_DELETED);
 		sqlite3_bind_int(statement, 4, TASK_EXTRA_STATUS_ANCHORED | TASK_EXTRA_STATUS_SHARED);
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getEvents2SyncFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
	NSDate *start = [Common toDBDate:fromDate];
	NSDate *end = [Common toDBDate:toDate];

	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
    
    NSInteger defaultOffset = [[NSTimeZone defaultTimeZone] secondsFromGMT];
    
    NSString *invisibleProjectListStr = [[ProjectManager getInstance] stringOfInvisibleProjectList];    

    /*
	NSString *sql = invisibleProjectListStr== nil?@"SELECT Task_ID, CASE WHEN Task_TimeZoneOffset = 0 THEN Task_StartTime ELSE (Task_StartTime + ? - Task_TimeZoneOffset) END AS StartTime, CASE WHEN Task_TimeZoneOffset = 0 THEN Task_EndTime ELSE (Task_EndTime + ? - Task_TimeZoneOffset) END AS EndTime FROM TaskTable WHERE \
	Task_GroupID = -1 AND (Task_Type = ? OR Task_Type = ?) AND \
	((StartTime >= ? AND StartTime < ?) OR \
	(StartTime < ? AND EndTime > ?))":
    @"SELECT Task_ID, CASE WHEN Task_TimeZoneOffset = 0 THEN Task_StartTime ELSE (Task_StartTime + ? - Task_TimeZoneOffset) END AS StartTime, CASE WHEN Task_TimeZoneOffset = 0 THEN Task_EndTime ELSE (Task_EndTime + ? - Task_TimeZoneOffset) END AS EndTime FROM TaskTable WHERE \
	Task_GroupID = -1 AND (Task_Type = ? OR Task_Type = ?) AND \
	((StartTime >= ? AND StartTime < ?) OR \
	(StartTime < ? AND EndTime > ?)) AND Task_ProjectID NOT IN (_PROJECT_LIST)"; 
    */
    
	NSString *sql = invisibleProjectListStr== nil?@"SELECT Task_ID, CASE WHEN Task_TimeZoneOffset = 0 THEN Task_StartTime ELSE (Task_StartTime + ? - Task_TimeZoneOffset) END AS StartTime, CASE WHEN Task_TimeZoneOffset = 0 THEN Task_EndTime ELSE (Task_EndTime + ? - Task_TimeZoneOffset) END AS EndTime FROM TaskTable WHERE \
	Task_GroupID = -1 AND (Task_Type = ? OR Task_Type = ?) AND \
	((StartTime >= ? AND StartTime < ?) OR \
	(StartTime < ? AND EndTime > ?)) AND ((Task_ExtraStatus & ?) = 0)":
    @"SELECT Task_ID, CASE WHEN Task_TimeZoneOffset = 0 THEN Task_StartTime ELSE (Task_StartTime + ? - Task_TimeZoneOffset) END AS StartTime, CASE WHEN Task_TimeZoneOffset = 0 THEN Task_EndTime ELSE (Task_EndTime + ? - Task_TimeZoneOffset) END AS EndTime FROM TaskTable WHERE \
	Task_GroupID = -1 AND (Task_Type = ? OR Task_Type = ?) AND \
	((StartTime >= ? AND StartTime < ?) OR \
	(StartTime < ? AND EndTime > ?)) AND ((Task_ExtraStatus & ?) = 0) AND Task_ProjectID NOT IN (_PROJECT_LIST)";    
    
    if (invisibleProjectListStr != nil)
    {
        sql = [sql stringByReplacingOccurrencesOfString:@"_PROJECT_LIST" withString:invisibleProjectListStr];
    }    	
    
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, defaultOffset);
		sqlite3_bind_int(statement, 2, defaultOffset);
		sqlite3_bind_int(statement, 3, TYPE_EVENT);
		sqlite3_bind_int(statement, 4, TYPE_ADE);
		sqlite3_bind_double(statement, 5, [start timeIntervalSince1970]);
		sqlite3_bind_double(statement, 6, [end timeIntervalSince1970]);
		sqlite3_bind_double(statement, 7, [start timeIntervalSince1970]);
		sqlite3_bind_double(statement, 8, [start timeIntervalSince1970]);
        sqlite3_bind_int(statement, 9, TASK_EXTRA_STATUS_ANCHORED | TASK_EXTRA_STATUS_SHARED);
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getDeletedEvents
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_Type <> ? AND Task_Status = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_int(statement, 2, TASK_STATUS_DELETED);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getDeletedTasks
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_Status = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_int(statement, 2, TASK_STATUS_DELETED);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (void) deleteTasksInGroup:(NSInteger)groupKey
{
	const char *sql = "DELETE FROM TaskTable WHERE Task_GroupID = ?";
	
	sqlite3_stmt *statement;		
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
    // Bind the primary key variable.
    sqlite3_bind_int(statement, 1, groupKey);
    // Execute the query.
    int success = sqlite3_step(statement);
    // Reset the statement for future use.
    sqlite3_finalize(statement);
	
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }	
}

- (void) cleanTasksForProject:(NSInteger)prjKey
{
	const char *sql = "DELETE FROM TaskTable WHERE Task_ProjectID = ? AND Task_Type = ?";
	
	sqlite3_stmt *statement;		
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
    // Bind the primary key variable.
    sqlite3_bind_int(statement, 1, prjKey);
	sqlite3_bind_int(statement, 2, TYPE_TASK);
    // Execute the query.
    int success = sqlite3_step(statement);
    // Reset the statement for future use.
    sqlite3_finalize(statement);
	
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }	
}

- (void) cleanTasksToDate:(NSDate *)toDate
{
	//NSDate *toDate = [Common toDBDate:date];	
	
	const char *sql = "DELETE FROM TaskTable WHERE Task_Status = ? AND Task_UpdateTime < ?";
	
	sqlite3_stmt *statement;		
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
    sqlite3_bind_int(statement, 1, TASK_STATUS_DELETED);
	sqlite3_bind_double(statement, 2, [toDate timeIntervalSince1970]);
	
    // Execute the query.
    int success = sqlite3_step(statement);
    // Reset the statement for future use.
    sqlite3_finalize(statement);
	
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }	
}

- (NSMutableArray *) getAlertsForTask:(NSInteger)taskKey
{
	NSMutableArray *alertList = [NSMutableArray arrayWithCapacity:5];
	
	const char *sql = "SELECT Alert_ID FROM AlertTable WHERE Alert_TaskID = ? ORDER BY Alert_ID ASC";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, taskKey);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			AlertData *alert = [[AlertData alloc] initWithPrimaryKey:primaryKey database:database];
			
			[alertList addObject:alert];
			[alert release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return alertList;
}

- (void) deleteAlertsForTask:(NSInteger)taskKey
{
	const char *sql = "DELETE FROM AlertTable WHERE Alert_TaskID = ?";
	
	sqlite3_stmt *statement;		
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
    // Bind the primary key variable.
    sqlite3_bind_int(statement, 1, taskKey);
    // Execute the query.
    int success = sqlite3_step(statement);
    // Reset the statement for future use.
    sqlite3_finalize(statement);
	
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }	
}

- (BOOL) checkNeedResort
{
	int maxSeqNo = 0;
	int minSeqNo = 0;
	int count = 0;
	
	const char *sql = "SELECT Max(Task_SeqNo),Min(Task_SeqNo),Count(*) FROM TaskTable WHERE Task_Type = ? OR Task_Type = ? AND Task_Status <> ?";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_int(statement, 2, TYPE_SHOPPING_ITEM);
		sqlite3_bind_int(statement, 3, TASK_STATUS_DELETED);
		
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// The second parameter indicates the column index into the result set.
			maxSeqNo = sqlite3_column_int(statement, 0);
			minSeqNo = sqlite3_column_int(statement, 1);
			count = sqlite3_column_int(statement, 2);
			// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
			// autorelease is slightly more expensive than release. This design choice has nothing to do with
			// actual memory management - at the end of this block of code, all the book objects allocated
			// here will be in memory regardless of whether we use autorelease or release, because they are
			// retained by the books array.
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return (maxSeqNo - minSeqNo > count + 1000);
}

- (NSInteger) getTaskMaxSortSeqNo
{
	int maxSeqNo = -1;
	int count = 0;
	
	const char *sql = "SELECT Max(Task_SeqNo), Count(*) FROM TaskTable WHERE Task_Type = ? OR Task_Type = ?";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_int(statement, 2, TYPE_SHOPPING_ITEM);
		
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// The second parameter indicates the column index into the result set.
			maxSeqNo = sqlite3_column_int(statement, 0);
			count = sqlite3_column_int(statement, 1);
			// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
			// autorelease is slightly more expensive than release. This design choice has nothing to do with
			// actual memory management - at the end of this block of code, all the book objects allocated
			// here will be in memory regardless of whether we use autorelease or release, because they are
			// retained by the books array.
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	if (count == 0)
	{
		maxSeqNo = -1;
	}
	
	return maxSeqNo;
}

- (NSInteger) getTaskMinSortSeqNo
{
	int minSeqNo = 0;
	int count = 0;
	
	const char *sql = "SELECT Min(Task_SeqNo), Count(*) FROM TaskTable WHERE Task_Type = ? OR Task_Type = ?";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_int(statement, 2, TYPE_SHOPPING_ITEM);
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// The second parameter indicates the column index into the result set.
			minSeqNo = sqlite3_column_int(statement, 0);
			count = sqlite3_column_int(statement, 1);
			// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
			// autorelease is slightly more expensive than release. This design choice has nothing to do with
			// actual memory management - at the end of this block of code, all the book objects allocated
			// here will be in memory regardless of whether we use autorelease or release, because they are
			// retained by the books array.
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	if (count == 0)
	{
		minSeqNo = 0;
	}
	
	return minSeqNo;
}

- (NSInteger) getTaskMaxSeqNo
{
	int maxSeqNo = -1;
	int count = 0;
	
	const char *sql = "SELECT Max(Task_MergedSeqNo), Count(*) FROM TaskTable WHERE Task_Type = ?";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// The second parameter indicates the column index into the result set.
			maxSeqNo = sqlite3_column_int(statement, 0);
			count = sqlite3_column_int(statement, 1);
			// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
			// autorelease is slightly more expensive than release. This design choice has nothing to do with
			// actual memory management - at the end of this block of code, all the book objects allocated
			// here will be in memory regardless of whether we use autorelease or release, because they are
			// retained by the books array.
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	if (count == 0)
	{
		maxSeqNo = -1;
	}
	
	return maxSeqNo;
}

- (NSInteger) getTaskMaxSeqNoForPlan:(NSInteger)key
{
	int maxSeqNo = -1;
	int count = 0;
	
	const char *sql = "SELECT Max(Task_SeqNo), Count(*) FROM TaskTable WHERE Task_Type = ? AND Task_ProjectID = ?";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_int(statement, 2, key);
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// The second parameter indicates the column index into the result set.
			maxSeqNo = sqlite3_column_int(statement, 0);
			count = sqlite3_column_int(statement, 1);
			// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
			// autorelease is slightly more expensive than release. This design choice has nothing to do with
			// actual memory management - at the end of this block of code, all the book objects allocated
			// here will be in memory regardless of whether we use autorelease or release, because they are
			// retained by the books array.
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);

	if (count == 0)
	{
		maxSeqNo = -1;
	}
	
	return maxSeqNo;
}

- (NSInteger) getPlanMaxSeqNo
{
	int maxSeqNo = -1;
	int count = 0;
	
	int success = SQLITE_DONE;
	
	const char *sql = "SELECT Max(Project_SeqNo), Count(*) FROM ProjectTable";
	sqlite3_stmt *statement;
	
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {

		// We "step" through the results - once for each row.
		while ((success = sqlite3_step(statement)) == SQLITE_ROW) {
			// The second parameter indicates the column index into the result set.
			maxSeqNo = sqlite3_column_int(statement, 0);
			count = sqlite3_column_int(statement, 1);
			// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
			// autorelease is slightly more expensive than release. This design choice has nothing to do with
			// actual memory management - at the end of this block of code, all the book objects allocated
			// here will be in memory regardless of whether we use autorelease or release, because they are
			// retained by the books array.
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}	
		
	if (count == 0)
	{
		maxSeqNo = -1;
	}
	
	return maxSeqNo;
}

- (NSMutableArray *) getPlanList
{
	NSMutableArray *planList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT Project_ID FROM ProjectTable WHERE Project_Type = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_PLAN);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Project *plan = [[Project alloc] initWithPrimaryKey:primaryKey database:database];
			
			[planList addObject:plan];
			[plan release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return planList;
}

- (NSInteger) getColorOfProject:(NSInteger)prjKey
{
	NSInteger colorId = -1;
	
	const char *sql = "SELECT Project_ColorID FROM ProjectTable WHERE Project_ID = ?";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, prjKey);
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// The second parameter indicates the column index into the result set.
			colorId = sqlite3_column_int(statement, 0);
			// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
			// autorelease is slightly more expensive than release. This design choice has nothing to do with
			// actual memory management - at the end of this block of code, all the book objects allocated
			// here will be in memory regardless of whether we use autorelease or release, because they are
			// retained by the books array.
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return colorId;
}


- (NSMutableArray *)getProjects
{
	NSMutableArray *projectList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT Project_ID FROM ProjectTable WHERE Project_Status <> ? ORDER BY Project_SeqNo";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		// We "step" through the results - once for each row.
		sqlite3_bind_int(statement, 1, PROJECT_STATUS_DELETED);
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// The second parameter indicates the column index into the result set.
			int primaryKey = sqlite3_column_int(statement, 0);
			// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
			// autorelease is slightly more expensive than release. This design choice has nothing to do with
			// actual memory management - at the end of this block of code, all the book objects allocated
			// here will be in memory regardless of whether we use autorelease or release, because they are
			// retained by the books array.
			Project *project = [[Project alloc] initWithPrimaryKey:primaryKey database:database];
			//project.tbdTask = [self getTBDTaskForProject:primaryKey];
			
			//[project refreshPlan];
			
			[projectList addObject:project];
			[project release];
			
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return projectList;
}

- (NSMutableArray *)getPlans
{
	NSMutableArray *projectList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT Project_ID FROM ProjectTable WHERE Project_Type = ?";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		// We "step" through the results - once for each row.
		sqlite3_bind_int(statement, 1, TYPE_PLAN);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// The second parameter indicates the column index into the result set.
			int primaryKey = sqlite3_column_int(statement, 0);
			// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
			// autorelease is slightly more expensive than release. This design choice has nothing to do with
			// actual memory management - at the end of this block of code, all the book objects allocated
			// here will be in memory regardless of whether we use autorelease or release, because they are
			// retained by the books array.
			Project *project = [[Project alloc] initWithPrimaryKey:primaryKey database:database];
			//project.tbdTask = [self getTBDTaskForProject:primaryKey];
			
			//[project refreshPlan];
			
			[projectList addObject:project];
			[project release];
			
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return projectList;
}

- (NSMutableArray *) getDeletedPlans
{
	NSMutableArray *planList = [NSMutableArray arrayWithCapacity:10];
	
	const char *sql = "SELECT Project_ID FROM ProjectTable WHERE Project_Status = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, PROJECT_STATUS_DELETED);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Project *plan = [[Project alloc] initWithPrimaryKey:primaryKey database:database];
			
			[planList addObject:plan];
			[plan release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return planList;
}

- (Task *) getTopTaskForPlan:(NSInteger)key excludeFutureTasks:(BOOL)excludeFutureTasks
{
	Task *ret = nil;
    	
	sqlite3_stmt *statement = _top_task_statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        

    Settings *settings = [Settings getInstance];
    
    NSDate *start = [Common toDBDate:[Common getEndDate:[NSDate date]]];
    
	if (statement == nil)
	{
		const char *sql = (excludeFutureTasks && settings.hideFutureTasks)?"SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_Status <> ? AND Task_Status <> ? AND Task_ProjectID = ? AND (Task_StartTime = -1 OR (Task_StartTime <> -1 AND Task_StartTime < ?)) ORDER BY Task_SeqNo ASC LIMIT 1":"SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_Status <> ? AND Task_Status <> ? AND Task_ProjectID = ? ORDER BY Task_SeqNo ASC LIMIT 1";
		
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)	
		{
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));	
		}
	}
	
	sqlite3_bind_int(statement, 1, TYPE_TASK);
	sqlite3_bind_int(statement, 2, TASK_STATUS_DONE);
	sqlite3_bind_int(statement, 3, TASK_STATUS_DELETED);		
	sqlite3_bind_int(statement, 4, key);
    sqlite3_bind_double(statement, 5, [start timeIntervalSince1970]);
	// We "step" through the results - once for each row.
	while (sqlite3_step(statement) == SQLITE_ROW) {
		// The second parameter indicates the column index into the result set.
		int taskId = sqlite3_column_int(statement, 0);
		
		ret = [[[Task alloc] initWithPrimaryKey:taskId database:database] autorelease];
	}

	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_reset(statement);

	return ret;
}

- (void) resetEventSyncIdForProject:(NSInteger) prjKey
{
	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        //static char *sql = "UPDATE TaskTable SET Task_SyncID = '', Task_UpdateTime = ? WHERE Task_ProjectID = ? AND Task_Type = ?";
		static char *sql = "UPDATE TaskTable SET Task_SyncID = '', Task_UpdateTime = ? WHERE Task_ProjectID = ? AND (Task_Type = ? OR Task_Type = ?)";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	NSTimeInterval updateTimeValue = [[NSDate date] timeIntervalSince1970];
	
	sqlite3_bind_double(statement, 1, updateTimeValue);
	sqlite3_bind_int(statement, 2, prjKey);
	sqlite3_bind_int(statement, 3, TYPE_EVENT);
	sqlite3_bind_int(statement, 4, TYPE_ADE);
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}	
}

- (void) resetProjectSyncIds
{
	sqlite3_stmt *statement;
	
    static char *sql = "UPDATE ProjectTable SET Project_TaskMappingName = '', Project_SyncID = '', Project_UpdateTime = ?";
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
	
	NSTimeInterval updateTimeValue = [[NSDate date] timeIntervalSince1970];
	
	sqlite3_bind_double(statement, 1, updateTimeValue);
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}    
}

- (void) resetTaskSyncIds
{
	sqlite3_stmt *statement;
	
    static char *sql = "UPDATE TaskTable SET Task_SyncID = '', Task_UpdateTime = ? WHERE Task_Type = ?";
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
    
    NSTimeInterval updateTimeValue = [[NSDate date] timeIntervalSince1970];
	
	sqlite3_bind_double(statement, 1, updateTimeValue);
	sqlite3_bind_int(statement, 2, TYPE_TASK);
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}	
}

- (void) resetSDWIds
{
	sqlite3_stmt *statement;
	
    static char *sql = "UPDATE ProjectTable SET Project_SDWID = '', Project_UpdateTime = ?";
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
	
	NSTimeInterval updateTimeValue = [[NSDate date] timeIntervalSince1970];
	
	sqlite3_bind_double(statement, 1, updateTimeValue);
    
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}    

    sql = "UPDATE TaskTable SET Task_SDWID = '', Task_UpdateTime = ?";
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
	
	sqlite3_bind_double(statement, 1, updateTimeValue);
	
    success = sqlite3_step(statement);
    
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}	
}

- (NSInteger) getTaskCountForProject:(NSInteger) prjKey
{
	NSInteger count = 0;
	const char *sql = "SELECT Count(Task_ID) FROM TaskTable WHERE Task_ProjectID = ? AND Task_Status <> ? AND TASK_TYPE = ?";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, prjKey);
		sqlite3_bind_int(statement, 2, TASK_STATUS_DELETED);
		sqlite3_bind_int(statement, 3, TYPE_TASK);

		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// The second parameter indicates the column index into the result set.
			count += sqlite3_column_int(statement, 0);
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return count;
}

- (NSInteger) getEventCountForProject:(NSInteger) prjKey
{
	NSInteger count = 0;
	const char *sql = "SELECT Count(Task_ID) FROM TaskTable WHERE Task_ProjectID = ? AND Task_Status <> ? AND (TASK_TYPE = ? OR TASK_TYPE = ?)";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, prjKey);
		sqlite3_bind_int(statement, 2, TASK_STATUS_DELETED);
		sqlite3_bind_int(statement, 3, TYPE_EVENT);
		sqlite3_bind_int(statement, 4, TYPE_ADE);
		
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// The second parameter indicates the column index into the result set.
			count += sqlite3_column_int(statement, 0);
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return count;
}

#pragma mark SmartPlans Support
- (NSInteger) countTasksForProject:(NSInteger) prjKey
{
	NSInteger count = 0;
	const char *sql = "SELECT Count(Task_ID) FROM TaskTable WHERE Task_ProjectID = ? AND Task_Type <> ? AND Task_Type <> ?";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, prjKey);
		sqlite3_bind_int(statement, 2, TYPE_TBD);
		sqlite3_bind_int(statement, 3, TYPE_GROUP);
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// The second parameter indicates the column index into the result set.
			count += sqlite3_column_int(statement, 0);
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return count;
}

- (NSMutableArray *) getTasksForProject:(NSInteger) prjKey isInitial:(BOOL)isInitial groupExcluded:(BOOL)groupExcluded
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = (groupExcluded?"SELECT Task_ID FROM TaskTable WHERE Task_ProjectID = ? AND Task_Type <> ? AND Task_Type <> ?":
					   "SELECT Task_ID FROM TaskTable WHERE Task_ProjectID = ? AND Task_Type <> ?");
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, prjKey);
		sqlite3_bind_int(statement, 2, TYPE_TBD);
		if (groupExcluded)
		{
			sqlite3_bind_int(statement, 3, TYPE_GROUP);
		}
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// The second parameter indicates the column index into the result set.
			int primaryKey = sqlite3_column_int(statement, 0);
			// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
			// autorelease is slightly more expensive than release. This design choice has nothing to do with
			// actual memory management - at the end of this block of code, all the book objects allocated
			// here will be in memory regardless of whether we use autorelease or release, because they are
			// retained by the books array.
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			if (isInitial)
			{
				[task initialUpdate];
			}
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getTasksWithDurationForProject:(NSInteger) prjKey estimatedOnly:(BOOL)estimatedOnly
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT Task_ID, Task_Duration, Task_Status FROM TaskTable WHERE Task_ProjectID = ? AND Task_Type <> ? AND Task_Type <> ?";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, prjKey);
		sqlite3_bind_int(statement, 2, TYPE_TBD);
		sqlite3_bind_int(statement, 3, TYPE_GROUP);		
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			Task *task = [[Task alloc] init];
			
			task.primaryKey = sqlite3_column_int(statement, 0);
			task.duration = sqlite3_column_double(statement, 1);
			task.status = sqlite3_column_int(statement, 2);
			
			if (!estimatedOnly && task.status == TASK_STATUS_DONE)
			{
				task.actualDuration = [self getActualDurationForTask:task.primaryKey];
			}
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (ProgressInfo) getProgressInfoForProject:(NSInteger) prjKey
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT Task_ID, Task_Duration, Task_Status FROM TaskTable WHERE Task_ProjectID = ?";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, prjKey);
		
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			Task *task = [[Task alloc] init];
			
			task.primaryKey = sqlite3_column_int(statement, 0);
			task.duration = sqlite3_column_double(statement, 1);
			task.status = sqlite3_column_int(statement, 2);
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);	
	
	ProgressInfo progress;
	
	progress.planDuration = 0;
	progress.actualDuration = 0;
	progress.totalDuration = 0;
	
	for (Task *task in taskList)
	{
		CGFloat actualDuration = (task.status == TASK_STATUS_DONE?[self getActualDurationForTask:task.primaryKey]:0);
		
		progress.totalDuration += (task.status == TASK_STATUS_DONE? actualDuration: task.duration);		
		
		progress.actualDuration += actualDuration;
		
		progress.planDuration += (task.status == TASK_STATUS_DONE? task.duration:0);
	}
	
	return progress;
}

- (CGFloat) getActualDurationForTask:(NSInteger) taskKey
{
	CGFloat duration = 0;
	const char *sql = "SELECT SUM(Task_EndTime-Task_StartTime) FROM TaskProgressTable WHERE Task_ID = ? AND Task_EndTime <> -1";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, taskKey);
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// The second parameter indicates the column index into the result set.
			duration += sqlite3_column_double(statement, 0);
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return duration;
}

- (NSMutableArray *) getAllProgressHistoryForTask:(NSInteger) taskKey
{
	NSMutableArray *progressList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT TaskProgress_ID, Task_StartTime, Task_EndTime FROM TaskProgressTable WHERE Task_ID = ? ORDER BY TaskProgress_ID DESC";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, taskKey);
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// The second parameter indicates the column index into the result set.
			int primaryKey = sqlite3_column_int(statement, 0);
			
			NSTimeInterval startTimeValue = sqlite3_column_double(statement, 1);
			NSTimeInterval endTimeValue = sqlite3_column_double(statement, 2);			
			
			// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
			// autorelease is slightly more expensive than release. This design choice has nothing to do with
			// actual memory management - at the end of this block of code, all the book objects allocated
			// here will be in memory regardless of whether we use autorelease or release, because they are
			// retained by the books array.
			TaskProgress *progress = [[TaskProgress alloc] init];
			
			progress.primaryKey = primaryKey;
			
			progress.startTime = (startTimeValue == -1? nil:[Common fromDBDate:[NSDate dateWithTimeIntervalSince1970:startTimeValue]]);
			progress.endTime = (endTimeValue == -1? nil:[Common fromDBDate:[NSDate dateWithTimeIntervalSince1970:endTimeValue]]);			
			
			[progressList addObject:progress];
			[progress release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return progressList;
}

- (NSMutableArray *) getProgressHistoryForTask:(NSInteger) taskKey
{
	NSMutableArray *progressList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT TaskProgress_ID, Task_StartTime, Task_EndTime FROM TaskProgressTable WHERE Task_ID = ? AND Task_EndTime <> -1 ORDER BY TaskProgress_ID DESC";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, taskKey);
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// The second parameter indicates the column index into the result set.
			int primaryKey = sqlite3_column_int(statement, 0);
			
			NSTimeInterval startTimeValue = sqlite3_column_double(statement, 1);
			NSTimeInterval endTimeValue = sqlite3_column_double(statement, 2);			
			
			// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
			// autorelease is slightly more expensive than release. This design choice has nothing to do with
			// actual memory management - at the end of this block of code, all the book objects allocated
			// here will be in memory regardless of whether we use autorelease or release, because they are
			// retained by the books array.
			TaskProgress *progress = [[TaskProgress alloc] init];
			
			progress.primaryKey = primaryKey;
			
			progress.startTime = (startTimeValue == -1? nil:[Common fromDBDate:[NSDate dateWithTimeIntervalSince1970:startTimeValue]]);
			progress.endTime = (endTimeValue == -1? nil:[Common fromDBDate:[NSDate dateWithTimeIntervalSince1970:endTimeValue]]);
			
			
			[progressList addObject:progress];
			[progress release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return progressList;
}

- (Task *)getTBDTaskForProject:(NSInteger)prjKey
{
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_ProjectID = ? AND Task_Type = ?";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, prjKey);
		sqlite3_bind_int(statement, 2, TYPE_TBD);
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// The second parameter indicates the column index into the result set.
			int primaryKey = sqlite3_column_int(statement, 0);
			// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
			// autorelease is slightly more expensive than release. This design choice has nothing to do with
			// actual memory management - at the end of this block of code, all the book objects allocated
			// here will be in memory regardless of whether we use autorelease or release, because they are
			// retained by the books array.
			Task *tbdTask = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			return [tbdTask autorelease];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return nil;
}

- (NSInteger) getTaskMaxSeqNoForProject:(NSInteger) prjKey
{
	int maxSeqNo = -1;
	int count = 0;
	
	const char *sql = "SELECT Max(Task_SeqNo), Count(*) FROM TaskTable WHERE Task_ProjectID = ?";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, prjKey);
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// The second parameter indicates the column index into the result set.
			maxSeqNo = sqlite3_column_int(statement, 0);
			count = sqlite3_column_int(statement, 1);
			// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
			// autorelease is slightly more expensive than release. This design choice has nothing to do with
			// actual memory management - at the end of this block of code, all the book objects allocated
			// here will be in memory regardless of whether we use autorelease or release, because they are
			// retained by the books array.
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	if (count == 0)
	{
		maxSeqNo = -1;
	}
	
	////////printf("get max seq no for project: %d -> %d\n", prjKey, maxSeqNo);
	
	return maxSeqNo;
}

- (void) cleanTaskByToodledoId:(NSString *)toodledoId
{
	const char *sql = "DELETE FROM TaskTable WHERE Task_SyncID = ?";
	
	sqlite3_stmt *statement;		
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	sqlite3_bind_text(statement, 1, [toodledoId UTF8String], -1, SQLITE_TRANSIENT);
	
    // Execute the query.
    int success = sqlite3_step(statement);
    // Reset the statement for future use.
    sqlite3_finalize(statement);
	
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }	
}

- (void) cleanAllEventsForProject:(NSInteger)prjKey
{
	const char *sql = "DELETE FROM TaskTable WHERE Task_ProjectID = ? AND (Task_Type = ? OR Task_Type = ?)";
	
	sqlite3_stmt *statement;		
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
    sqlite3_bind_int(statement, 1, prjKey);
    sqlite3_bind_int(statement, 2, TYPE_EVENT);
    sqlite3_bind_int(statement, 3, TYPE_ADE);
    
    // Execute the query.
    int success = sqlite3_step(statement);
    // Reset the statement for future use.
    sqlite3_finalize(statement);
	
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }	
}

- (void) cleanAllTasksForProject:(NSInteger)prjKey
{
	NSMutableArray *taskList = [self getTasksForPlan:prjKey];
	
	for (Task *task in taskList)
	{
		[self deleteAllProgressForTask:task.primaryKey];
	}
    
	const char *sql = "DELETE FROM TaskTable WHERE Task_ProjectID = ? AND Task_TYPE = ?";
	
	sqlite3_stmt *statement;		
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
    sqlite3_bind_int(statement, 1, prjKey);
    sqlite3_bind_int(statement, 2, TYPE_TASK);
    
    // Execute the query.
    int success = sqlite3_step(statement);
    // Reset the statement for future use.
    sqlite3_finalize(statement);
	
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }	
}

- (void) cleanAllItemsForProject:(NSInteger)prjKey
{
	const char *sql = "DELETE FROM TaskTable WHERE Task_ProjectID = ?";
	
	sqlite3_stmt *statement;		
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
    sqlite3_bind_int(statement, 1, prjKey);
    // Execute the query.
    int success = sqlite3_step(statement);
    // Reset the statement for future use.
    sqlite3_finalize(statement);
	
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }	
}

- (void) cleanAllProjects
{
	const char *sql = "DELETE FROM ProjectTable WHERE Project_Status = ?";
	
	sqlite3_stmt *statement;		
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
    sqlite3_bind_int(statement, 1, PROJECT_STATUS_DELETED);
    // Execute the query.
    int success = sqlite3_step(statement);
    // Reset the statement for future use.
    sqlite3_finalize(statement);
	
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }	
}

- (void) deleteAllItemsForProject:(NSInteger)prjKey
{
	const char *sql = "UPDATE TaskTable SET Task_Status=?,Task_UpdateTime=? WHERE Task_ProjectID=?";
	
	sqlite3_stmt *statement;		
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	NSTimeInterval updateTimeValue = [[NSDate date] timeIntervalSince1970];
	
	sqlite3_bind_int(statement, 1, TASK_STATUS_DELETED);
	sqlite3_bind_double(statement, 2, updateTimeValue);	
	
    sqlite3_bind_int(statement, 3, prjKey);
    // Execute the query.
    int success = sqlite3_step(statement);
    // Reset the statement for future use.
    sqlite3_finalize(statement);
	
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }
}

- (void) deleteAllProgressForTask:(NSInteger)taskKey
{
	const char *sql = "DELETE FROM TaskProgressTable WHERE Task_ID = ?";
	
	sqlite3_stmt *statement;		
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
    // Bind the primary key variable.
    sqlite3_bind_int(statement, 1, taskKey);
    // Execute the query.
    int success = sqlite3_step(statement);
    // Reset the statement for future use.
    sqlite3_finalize(statement);
	
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }	
}

- (void) deleteAllComments:(NSInteger)itemKey
{
	const char *sql = "DELETE FROM CommentTable WHERE Comment_ItemID = ?";
	
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
    // Bind the primary key variable.
    sqlite3_bind_int(statement, 1, itemKey);
    // Execute the query.
    int success = sqlite3_step(statement);
    // Reset the statement for future use.
    sqlite3_finalize(statement);
	
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }
}

-(NSMutableArray *) getActiveTaskList
{
	NSMutableArray *activeTaskList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT a.Task_ID, Task_ProjectID, Task_TimerStatus, Task_Name, Task_Deadline  \
	FROM TaskTable a, TaskProgressTable b WHERE Task_Type = ? AND (Task_Status <> ? AND Task_Status <> ?) AND (Task_TimerStatus = ? OR Task_TimerStatus = ?) \
	AND a.Task_ID = b.Task_ID GROUP BY a.Task_ID ORDER BY TaskProgress_ID DESC";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_int(statement, 2, TASK_STATUS_DELETED);
		sqlite3_bind_int(statement, 3, TASK_STATUS_DONE);
		sqlite3_bind_int(statement, 4, TASK_TIMER_STATUS_START);
		sqlite3_bind_int(statement, 5, TASK_TIMER_STATUS_INTERRUPT);
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// The second parameter indicates the column index into the result set.
			// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
			// autorelease is slightly more expensive than release. This design choice has nothing to do with
			// actual memory management - at the end of this block of code, all the book objects allocated
			// here will be in memory regardless of whether we use autorelease or release, because they are
			// retained by the books array.
			Task *task = [[Task alloc] init];
			
			task.primaryKey = sqlite3_column_int(statement, 0);
			task.project = sqlite3_column_int(statement, 1);
			task.timerStatus = sqlite3_column_int(statement, 2);
            task.listSource = SOURCE_TIMER;
			
			char *name = (char *) sqlite3_column_text(statement, 3);	
			task.name = [NSString stringWithUTF8String:name];
            
            NSTimeInterval deadlineValue = sqlite3_column_double(statement, 4);
			task.deadline = (deadlineValue == -1? nil:[Common fromDBDate:[NSDate dateWithTimeIntervalSince1970:deadlineValue]]);
			
			task.lastProgress = [self getLastProgressForTask:task.primaryKey];
			
			[activeTaskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return activeTaskList;
}

-(NSMutableArray *) getInProgressTaskList
{
	NSMutableArray *inProgressTaskList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT a.Task_ID, Task_ProjectID, Task_Name, Task_Deadline FROM TaskTable a, TaskProgressTable b \
	WHERE Task_Type = ? AND (Task_Status <> ? AND Task_Status <> ?) AND Task_TimerStatus = ? AND a.Task_ID = b.Task_ID GROUP BY a.Task_ID ORDER BY TaskProgress_ID DESC";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_int(statement, 1, TYPE_TASK);
        sqlite3_bind_int(statement, 2, TASK_STATUS_DELETED);
        sqlite3_bind_int(statement, 3, TASK_STATUS_DONE);
		sqlite3_bind_int(statement, 4, TASK_TIMER_STATUS_PAUSE);
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// The second parameter indicates the column index into the result set.
			int primaryKey = sqlite3_column_int(statement, 0);
			int projectKey = sqlite3_column_int(statement, 1);
			char *name = (char *)sqlite3_column_text(statement, 2);			
            NSTimeInterval deadlineValue = sqlite3_column_double(statement, 3);
			// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
			// autorelease is slightly more expensive than release. This design choice has nothing to do with
			// actual memory management - at the end of this block of code, all the book objects allocated
			// here will be in memory regardless of whether we use autorelease or release, because they are
			// retained by the books array.
			Task *task = [[Task alloc] init];
			
			task.primaryKey = primaryKey;
			task.project = projectKey;
			task.name = [NSString stringWithUTF8String:name];
			task.timerStatus = TASK_TIMER_STATUS_PAUSE;
            task.listSource = SOURCE_TIMER;
            
			task.deadline = (deadlineValue == -1? nil:[Common fromDBDate:[NSDate dateWithTimeIntervalSince1970:deadlineValue]]);
            
			
			[inProgressTaskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return inProgressTaskList;
}

-(TaskProgress *)getLastProgressForTask:(NSInteger) taskKey
{
	TaskProgress *progress = [[[TaskProgress alloc] init] autorelease];
	
	const char *sql = "SELECT Max(TaskProgress_ID) FROM TaskProgressTable WHERE Task_ID = ?";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, taskKey);
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// The second parameter indicates the column index into the result set.
			progress.primaryKey = sqlite3_column_int(statement, 0);
			
			[progress initWithPrimaryKey:progress.primaryKey database:database];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return progress;
}

- (GoalInfo) getGoalFromDate:(NSDate *)startDate toDate:(NSDate *)endDate
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	NSTimeInterval startTime = [startDate timeIntervalSince1970];
	NSTimeInterval endTime = [endDate timeIntervalSince1970];
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_Type <> ? AND Task_Type <> ? AND Task_Status = ? AND \
	((Task_StartTime >= ? AND Task_StartTime < ?) OR (Task_EndTime > ? AND Task_EndTime <= ?)) ";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, TYPE_TBD);
		sqlite3_bind_int(statement, 2, TYPE_GROUP);
		sqlite3_bind_int(statement, 3, TASK_STATUS_DONE);
		sqlite3_bind_double(statement, 4, startTime);
		sqlite3_bind_double(statement, 5, endTime);		
		sqlite3_bind_double(statement, 6, startTime);
		sqlite3_bind_double(statement, 7, endTime);		
		// We "step" through the results - once for each row.
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// The second parameter indicates the column index into the result set.
			int primaryKey = sqlite3_column_int(statement, 0);
			// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
			// autorelease is slightly more expensive than release. This design choice has nothing to do with
			// actual memory management - at the end of this block of code, all the book objects allocated
			// here will be in memory regardless of whether we use autorelease or release, because they are
			// retained by the books array.
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	CGFloat durations[6];
	
	CGFloat totalDuration = 0;
	
	for (int i=0; i<6; i++)
	{
		durations[i] = 0;
	}
	
	for (Task *task in taskList)
	{
		NSMutableArray *progressList = [self getProgressHistoryForTask:task.primaryKey];
		
		CGFloat taskDuration = 0;
		
		for (TaskProgress *progress in progressList)
		{
			NSTimeInterval progressStartTime = [progress.startTime timeIntervalSince1970];
			NSTimeInterval progressEndTime = [progress.endTime timeIntervalSince1970];
			
			if (progressStartTime < startTime && progressEndTime > startTime && progressEndTime <= endTime)
			{
				taskDuration += progressEndTime - startTime;
			}
			else if (progressStartTime >= startTime && progressStartTime < endTime && progressEndTime > endTime)
			{
				taskDuration += endTime - progressStartTime;
			}
			else if (progressStartTime >= startTime && progressEndTime <= endTime)
			{
				taskDuration += progressEndTime - progressStartTime;
			}
		}
		
		durations[task.goal] += taskDuration;
		
		totalDuration += taskDuration;
	}
	
	GoalInfo ret;
	
	ret.goal0 = durations[0]/totalDuration;
	ret.goal1 = durations[1]/totalDuration;
	ret.goal2 = durations[2]/totalDuration;
	ret.goal3 = durations[3]/totalDuration;
	ret.goal4 = durations[4]/totalDuration;
	ret.goal5 = durations[5]/totalDuration;
	
	return ret;
}

#pragma mark SDW Sync
- (NSMutableArray *) getAllComments
{
	NSMutableArray *list = [NSMutableArray arrayWithCapacity:200];
	
	const char *sql = "SELECT Comment_ID FROM CommentTable WHERE Comment_Status <> ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, COMMENT_STATUS_DELETED);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Comment *comment = [[Comment alloc] initWithPrimaryKey:primaryKey database:database];
			
			[list addObject:comment];
			[comment release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return list;
}

- (NSMutableArray *) getComments4Item:(NSInteger)itemId
{
	NSMutableArray *list = [NSMutableArray arrayWithCapacity:200];
	
	const char *sql = "SELECT Comment_ID FROM CommentTable WHERE Comment_Status <> ? AND Comment_ItemID = ? ORDER BY Comment_CreateTime DESC";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, COMMENT_STATUS_DELETED);
        sqlite3_bind_int(statement, 2, itemId);
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Comment *comment = [[Comment alloc] initWithPrimaryKey:primaryKey database:database];
            
			[list addObject:comment];
			[comment release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return list;
}

- (NSInteger) countCommentsForItem:(NSInteger) itemId
{
	NSInteger count = 0;
    
	const char *sql = "SELECT Count(Comment_ID) FROM CommentTable WHERE Comment_Status <> ? AND Comment_ItemID = ?";
    
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, COMMENT_STATUS_DELETED);
		sqlite3_bind_int(statement, 2, itemId);

		while (sqlite3_step(statement) == SQLITE_ROW) {
			// The second parameter indicates the column index into the result set.
			count += sqlite3_column_int(statement, 0);
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return count;
}

- (void) updateCommentStatus:(NSInteger)status forItem:(NSInteger)itemId
{
    sqlite3_stmt *statement;
    
    static char *sql = "UPDATE CommentTable SET Comment_Status=? WHERE Comment_ItemID=?";
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)
    {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
    
    sqlite3_bind_int(statement, 1, status);
    sqlite3_bind_int(statement, 2, itemId);
    
    if (sqlite3_step(statement) == SQLITE_ERROR)
    {
        NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
    }
    
    sqlite3_finalize(statement);
    
}

- (NSInteger) countUnreadComments
{
	NSInteger count = 0;
    
	const char *sql = "SELECT Count(Comment_ID) FROM CommentTable WHERE Comment_Status = ?";
    
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, COMMENT_STATUS_UNREAD);
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// The second parameter indicates the column index into the result set.
			count += sqlite3_column_int(statement, 0);
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return count;
}

- (NSMutableArray *) getUnreadComments
{
	NSMutableArray *list = [NSMutableArray arrayWithCapacity:200];
	
	const char *sql = "SELECT Count(Comment_ID), Comment_ItemID, Comment_Type  FROM CommentTable WHERE Comment_Status = ? GROUP BY Comment_ItemID, Comment_Type";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, COMMENT_STATUS_UNREAD);
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
            UnreadComment *comment = [[UnreadComment alloc] init];
            
            comment.count = sqlite3_column_int(statement, 0);
            comment.itemKey = sqlite3_column_int(statement, 1);
            comment.itemType = sqlite3_column_int(statement, 2);
            
			[list addObject:comment];
			[comment release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return list;
}

- (NSMutableArray *) getAllURLAssets
{
	NSMutableArray *list = [NSMutableArray arrayWithCapacity:200];
	
	const char *sql = "SELECT URL_ID FROM URLTable WHERE URL_Status <> ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, URL_STATUS_DELETED);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			URLAsset *urlAsset = [[URLAsset alloc] initWithPrimaryKey:primaryKey database:database];
			
			[list addObject:urlAsset];
			[urlAsset release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return list;
}

- (NSMutableArray *) getDeletedURLAssets
{
	NSMutableArray *list = [NSMutableArray arrayWithCapacity:10];
	
	const char *sql = "SELECT URL_ID FROM URLTable WHERE URL_Status = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, URL_STATUS_DELETED);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			URLAsset *asset = [[URLAsset alloc] initWithPrimaryKey:primaryKey database:database];
			
			[list addObject:asset];
			[asset release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return list;
}

- (NSString *) getItemTypeString
{
    return [NSString stringWithFormat:@"%d,%d,%d,%d", TYPE_TASK, TYPE_EVENT, TYPE_ADE, TYPE_NOTE];
}

- (NSMutableArray *) getItems2Sync
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:200];
    
    NSString *invisibleProjectListStr = [[ProjectManager getInstance] stringOfInvisibleProjectList];
    
    NSString *typeStr = [self getItemTypeString];
    
	//const char *sql = (invisibleProjectListStr == nil?"SELECT Task_ID FROM TaskTable WHERE Task_Type IN (?) AND Task_Status <> ? ORDER BY Task_SeqNo ASC":
    //"SELECT Task_ID FROM TaskTable WHERE Task_Type IN (?) AND Task_Status <> ? AND Task_ProjectID NOT IN (?) ORDER BY Task_SeqNo ASC");
	
    NSString *sql = (invisibleProjectListStr == nil?@"SELECT Task_ID FROM TaskTable WHERE Task_Type IN (_TYPE_LIST) AND Task_Status <> ? ORDER BY Task_SeqNo ASC":
                     @"SELECT Task_ID FROM TaskTable WHERE Task_Type IN (_TYPE_LIST) AND Task_Status <> ? AND Task_ProjectID NOT IN (_PROJECT_LIST) ORDER BY Task_SeqNo ASC");
    
    sql = [sql stringByReplacingOccurrencesOfString:@"_TYPE_LIST" withString:typeStr];
    
    if (invisibleProjectListStr != nil)
    {
        sql = [sql stringByReplacingOccurrencesOfString:@"_PROJECT_LIST" withString:invisibleProjectListStr];
    }
    
    //printf("getItems2Sync SQL: %s\n", [sql UTF8String]);
    
    sqlite3_stmt *statement;
    
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {

		sqlite3_bind_int(statement, 1, TASK_STATUS_DELETED);
        
        /*
        if (invisibleProjectListStr != nil)
        {
            sqlite3_bind_text(statement, 3, [invisibleProjectListStr UTF8String], -1, SQLITE_TRANSIENT);
        }
        */
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getModifiedItems2Sync:(NSDate *)afterDate
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	if (afterDate == nil)
	{
        taskList = [self getItems2Sync];
    }
	else 
	{
        NSString *invisibleProjectListStr = [[ProjectManager getInstance] stringOfInvisibleProjectList];
        
        NSString *typeStr = [self getItemTypeString];
        
        //const char *sql = (invisibleProjectListStr == nil?"SELECT Task_ID FROM TaskTable WHERE Task_Type IN (?) AND (Task_SDWID = '' OR Task_UpdateTime >= ?)":
        //                   "SELECT Task_ID FROM TaskTable WHERE Task_Type IN (?) AND (Task_SDWID = '' OR Task_UpdateTime >= ?) AND Task_ProjectID NOT IN (?)");
        
        NSString *sql = (invisibleProjectListStr == nil?@"SELECT Task_ID FROM TaskTable WHERE Task_Type IN (_TYPE_LIST) AND (Task_SDWID = '' OR Task_UpdateTime >= ?)":
                           @"SELECT Task_ID FROM TaskTable WHERE Task_Type IN (_TYPE_LIST) AND (Task_SDWID = '' OR Task_UpdateTime >= ?) AND Task_ProjectID NOT IN (_PROJECT_LIST)");
		
        sql = [sql stringByReplacingOccurrencesOfString:@"_TYPE_LIST" withString:typeStr];
        
        if (invisibleProjectListStr != nil)
        {
            sql = [sql stringByReplacingOccurrencesOfString:@"_PROJECT_LIST" withString:invisibleProjectListStr];
        }
        
        sqlite3_stmt *statement;
		
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            
			sqlite3_bind_double(statement, 1, [afterDate timeIntervalSince1970]);
            
            /*
            if (invisibleProjectListStr != nil)
            {
                sqlite3_bind_text(statement, 3, [invisibleProjectListStr UTF8String], -1, SQLITE_TRANSIENT);
            }            
			*/
			while (sqlite3_step(statement) == SQLITE_ROW) {
				int primaryKey = sqlite3_column_int(statement, 0);
				Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
				
				[taskList addObject:task];
				[task release];
			}
		}
		// "Finalize" the statement - releases the resources associated with the statement.
		sqlite3_finalize(statement);		
	}
	
	return taskList;	
}

- (NSMutableArray *) getDeletedItems2Sync
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	//const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_Type IN (?) AND Task_Status = ?";
    
    NSString *sql = @"SELECT Task_ID FROM TaskTable WHERE Task_Type IN (_TYPE_LIST) AND Task_Status = ?";
	
    sqlite3_stmt *statement;
    
    NSString *typeStr = [self getItemTypeString];
    
    sql = [sql stringByReplacingOccurrencesOfString:@"_TYPE_LIST" withString:typeStr];
    
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        
		sqlite3_bind_int(statement, 1, TASK_STATUS_DELETED);
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return taskList;
}

- (NSMutableArray *) getDeletedLinks
{
	NSMutableArray *linkList = [NSMutableArray arrayWithCapacity:10];
	
	const char *sql = "SELECT TaskLink_ID FROM TaskLinkTable WHERE Status = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, LINK_STATUS_DELETED);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Link *link = [[Link alloc] initWithPrimaryKey:primaryKey database:database];
			
			[linkList addObject:link];
			[link release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return linkList;
}

- (NSMutableArray *) getAllLinks
{
	NSMutableArray *linkList = [NSMutableArray arrayWithCapacity:200];
	
	const char *sql = "SELECT TaskLink_ID FROM TaskLinkTable WHERE Status <> ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, LINK_STATUS_DELETED);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Link *link = [[Link alloc] initWithPrimaryKey:primaryKey database:database];
			
			[linkList addObject:link];
			[link release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	return linkList;
}

- (NSMutableArray *) getModifiedLinks2Sync:(NSDate *)afterDate
{
	NSMutableArray *linkList = [NSMutableArray arrayWithCapacity:20];
	
	if (afterDate == nil)
	{
        linkList = [self getAllLinks];
    }
	else 
	{
        const char *sql = "SELECT TaskLink_ID FROM TaskLinkTable WHERE SDW_ID = '' OR UpdateTime >= ?";
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_double(statement, 1, [afterDate timeIntervalSince1970]);
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                int primaryKey = sqlite3_column_int(statement, 0);
                Link *link = [[Link alloc] initWithPrimaryKey:primaryKey database:database];
                
                [linkList addObject:link];
                [link release];
            }
        }
        // "Finalize" the statement - releases the resources associated with the statement.
        sqlite3_finalize(statement);        
    }
    
    return linkList;
}

- (NSString *) getSDWId4Key:(NSInteger)key
{
    NSString *sdwId = nil;
    
    sqlite3_stmt *statement;
    
    const char *sql = "SELECT Task_SDWID FROM TaskTable WHERE Task_ID = ?";
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) 
    {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
    
    sqlite3_bind_int(statement, 1, key);
    
    int success = sqlite3_step(statement);
    
    if (success == SQLITE_ROW)
    {
        char *str = (char *)sqlite3_column_text(statement, 0);
        sdwId = (str == NULL? nil:[NSString stringWithUTF8String:str]);        
    }
    else if (success == SQLITE_ERROR)
    {
        NSAssert1(0, @"Error: failed to select from the database with message '%s'.", sqlite3_errmsg(database));        
    }    
    
    sqlite3_finalize(statement);
    
    return sdwId;
}

- (NSInteger) getKey4SDWId:(NSString *)sdwId
{
    NSInteger key = -1;
    
    sqlite3_stmt *statement;
    
    const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_SDWID = ?";
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) 
    {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
    
    sqlite3_bind_text(statement, 1, [sdwId UTF8String], -1, SQLITE_TRANSIENT);
    
    int success = sqlite3_step(statement);
    
    if (success == SQLITE_ROW)
    {
        key = sqlite3_column_int(statement, 0);
        
        //printf("root key %d found for sdw id:%s\n", key, [sdwId UTF8String]);
    }
    else if (success == SQLITE_ERROR)
    {
        NSAssert1(0, @"Error: failed to select from the database with message '%s'.", sqlite3_errmsg(database));        
    }
    
    sqlite3_finalize(statement);
    
    return key;
}

- (NSString *) getSDWId4ProjectKey:(NSInteger)key
{
    NSString *sdwId = nil;
    
    sqlite3_stmt *statement;
    
    const char *sql = "SELECT Project_SDWID FROM ProjectTable WHERE Project_ID = ?";
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)
    {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
    
    sqlite3_bind_int(statement, 1, key);
    
    int success = sqlite3_step(statement);
    
    if (success == SQLITE_ROW)
    {
        char *str = (char *)sqlite3_column_text(statement, 0);
        sdwId = (str == NULL? nil:[NSString stringWithUTF8String:str]);
    }
    else if (success == SQLITE_ERROR)
    {
        NSAssert1(0, @"Error: failed to select from the database with message '%s'.", sqlite3_errmsg(database));
    }
    
    sqlite3_finalize(statement);
    
    return sdwId;
}

- (NSInteger) getProjectKey4SDWId:(NSString *)sdwId
{
    NSInteger key = -1;
    
    sqlite3_stmt *statement;
    
    const char *sql = "SELECT Project_ID FROM ProjectTable WHERE Project_SDWID = ?";
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)
    {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
    
    sqlite3_bind_text(statement, 1, [sdwId UTF8String], -1, SQLITE_TRANSIENT);
    
    int success = sqlite3_step(statement);
    
    if (success == SQLITE_ROW)
    {
        key = sqlite3_column_int(statement, 0);
        
        //printf("root key %d found for sdw id:%s\n", key, [sdwId UTF8String]);
    }
    else if (success == SQLITE_ERROR)
    {
        NSAssert1(0, @"Error: failed to select from the database with message '%s'.", sqlite3_errmsg(database));
    }
    
    sqlite3_finalize(statement);
    
    return key;
}


- (NSString *) getSDWId4URLAssetKey:(NSInteger)key
{
    NSString *sdwId = nil;
    
    sqlite3_stmt *statement;
    
    const char *sql = "SELECT URL_SDWID FROM URLTable WHERE URL_ID = ?";
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)
    {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
    
    sqlite3_bind_int(statement, 1, key);
    
    int success = sqlite3_step(statement);
    
    if (success == SQLITE_ROW)
    {
        char *str = (char *)sqlite3_column_text(statement, 0);
        sdwId = (str == NULL? nil:[NSString stringWithUTF8String:str]);
    }
    else if (success == SQLITE_ERROR)
    {
        NSAssert1(0, @"Error: failed to select from the database with message '%s'.", sqlite3_errmsg(database));
    }
    
    sqlite3_finalize(statement);
    
    return sdwId;
}

- (NSInteger) getURLAssetKey4SDWId:(NSString *)sdwId
{
    NSInteger key = -1;
    
    sqlite3_stmt *statement;
    
    const char *sql = "SELECT URL_ID FROM URLTable WHERE URL_SDWID = ?";
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)
    {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
    
    sqlite3_bind_text(statement, 1, [sdwId UTF8String], -1, SQLITE_TRANSIENT);
    
    int success = sqlite3_step(statement);
    
    if (success == SQLITE_ROW)
    {
        key = sqlite3_column_int(statement, 0);
        
        //printf("root key %d found for sdw id:%s\n", key, [sdwId UTF8String]);
    }
    else if (success == SQLITE_ERROR)
    {
        NSAssert1(0, @"Error: failed to select from the database with message '%s'.", sqlite3_errmsg(database));
    }
    
    sqlite3_finalize(statement);
    
    return key;
}

- (NSDate *) getLastestTaskUpdateTime
{
    NSDate *ret = nil;
    
    sqlite3_stmt *statement;
    
    const char *sql = "SELECT Max(Task_UpdateTime) FROM TaskTable";
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) 
    {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
    int success = sqlite3_step(statement);
    
    if (success == SQLITE_ROW)
    {
        NSInteger dt = sqlite3_column_int(statement, 0);
        
        if (dt != -1)
        {
            ret = [NSDate dateWithTimeIntervalSince1970:dt];
        }
    }
    else if (success == SQLITE_ERROR)
    {
        NSAssert1(0, @"Error: failed to select from the database with message '%s'.", sqlite3_errmsg(database));        
    }
    
    sqlite3_finalize(statement);
    
    return ret;
}


- (void)deleteSuspectedDuplication 
{
    NSMutableArray *sourceList = [self getItems2Sync];
	NSMutableDictionary *taskDict = [NSMutableDictionary dictionaryWithCapacity:sourceList.count];
	
	for (Task *task in sourceList)
	{
		if (task.primaryKey >= 0)
		{
            NSInteger value1 = -1;
            NSInteger value2 = -1;
            NSString *rrule = @"";
            
            if ([task isRE])
            {
                rrule = [task getRepeatString];
            }
            else if ([task isTask])
            {
                if (task.startTime != nil)
                {
                    value1 = [task.startTime timeIntervalSince1970];
                }
                
                if (task.deadline != nil)
                {
                    value2 = [task.deadline timeIntervalSince1970];
                }
            }
            else if ([task isEvent])
            {
                if (task.startTime != nil)
                {                
                    value1 = [task.startTime timeIntervalSince1970];
                }
                
                if (task.endTime != nil)
                {
                    value2 = [task.endTime timeIntervalSince1970];
                }
            }
            else if ([task isNote])
            {
                if (task.startTime != nil)
                {                
                    value1 = [task.startTime timeIntervalSince1970];
                }                
            }
            
            NSString *keyStr = [NSString stringWithFormat:@"%@|%d|%d|%d|%d|%@", task.name, task.type, task.project, value1, value2, rrule];
            
			NSMutableArray *arr = [taskDict objectForKey:keyStr];
			
			if (arr == nil)
			{
				arr = [NSMutableArray arrayWithCapacity:2];
				
				[taskDict setObject:arr forKey:keyStr];
			}
			
			[arr addObject:task];			
		}
	}
	
	NSEnumerator *enumerator = [taskDict objectEnumerator];
	
	NSMutableArray *arr;
	
	NSMutableArray *delList = [NSMutableArray arrayWithCapacity:10];
	
	while (arr = [enumerator nextObject]) 
	{
		if (arr.count >= 2)
		{
			for (int i=1; i<arr.count; i++)
			{
				Task *tmp = [arr objectAtIndex:i];
				
                [delList addObject:tmp];
			}
            
		}
	}
    
    if (delList.count > 0) 
    {
        for (Task *task in delList)
        {
            [task deleteFromDatabase:[self getDatabase]];
        }
    }
}

- (void) deleteAllCategories
{
	const char *sql = "DELETE FROM ProjectTable";
	
	sqlite3_stmt *statement;		
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
    // Execute the query.
    int success = sqlite3_step(statement);
    // Reset the statement for future use.
    sqlite3_finalize(statement);
	
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }	
}

- (void) deleteAllTasks
{
	const char *sql = "DELETE FROM TaskTable";
	
	sqlite3_stmt *statement;		
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
    // Execute the query.
    int success = sqlite3_step(statement);
    // Reset the statement for future use.
    sqlite3_finalize(statement);
	
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }	
}

- (void) deleteAllLinks
{
	const char *sql = "DELETE FROM TaskLinkTable";
	
	sqlite3_stmt *statement;		
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
    // Execute the query.
    int success = sqlite3_step(statement);
    // Reset the statement for future use.
    sqlite3_finalize(statement);
	
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }	
}

- (void) deleteAllProgresses
{
	const char *sql = "DELETE FROM TaskProgressTable";
	
	sqlite3_stmt *statement;		
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
    // Execute the query.
    int success = sqlite3_step(statement);
    // Reset the statement for future use.
    sqlite3_finalize(statement);
	
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }	
}

- (void) updateCategoryTime
{
	const char *sql1 = "UPDATE ProjectTable SET Project_UpdateTime = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql1, -1, &statement, NULL) == SQLITE_OK)
	{
        NSTimeInterval updateTimeValue = [[NSDate date] timeIntervalSince1970];
        
        sqlite3_bind_double(statement, 1, updateTimeValue);

		int success = sqlite3_step(statement);
        
		if (success != SQLITE_DONE)
		{
			NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
		}
	}
    
	sqlite3_finalize(statement);
    
}

- (void) cleanDB
{
    [self deleteAllProgresses];
    [self deleteAllLinks];
    [self deleteAllTasks];
    [self deleteAllCategories];
}

#pragma mark Upgrade
- (void)upgrade
{
	//NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    Settings *settings = [Settings getInstance];
    
	//NSString *dbVersion = settings.dbVersion;
    
    if (_firstLaunch)
    {
        [self updateCategoryTime];
        [settings modifyUpdateTime];
    }
    
    if (!_versionUpgrade || !_dbUpgrade)
    {
        return;
    }
    
	/*if ([dbVersion isEqualToString:@"1.0"] && [appVersion isEqualToString:@"1.0.2"])
	{
		[self upgradeDBv1_0_2];
	}	
	else if ([dbVersion compare:@"1.0.2"] != NSOrderedDescending && [appVersion compare:@"2.0"] != NSOrderedDescending)
	{
		[self upgradeDBv2_0];
	}
	else if ([dbVersion compare:@"2.0"] != NSOrderedDescending && [appVersion compare:@"3.0"] != NSOrderedDescending)
	{
		[self upgradeDBv3_0];
	}
	else if ([dbVersion compare:@"3.0"] != NSOrderedDescending && [appVersion compare:@"3.1"] != NSOrderedDescending)
	{
		[self upgradeDBv3_1];
	}
	else if ([dbVersion isEqualToString:@"3.0"] && [appVersion isEqualToString:@"3.2"])
	{
		[self upgradeDBv3_2];
	}
	else if ([dbVersion isEqualToString:@"3.0"] && [appVersion isEqualToString:@"4.0"])
	{
		[self upgradeDBv4_0];
	}*/
    
	if (_dbUpgrade && (!_isiPad && [settings.appVersion isEqualToString:@"1.1"]))
	{
        // upgrade for SD iPhone v1.0.1 to v1.1
		[self upgradeDBv5_0];
	}
    
    _versionUpgrade = NO;
    _dbUpgrade = NO;
}

- (void)upgradeDBv1_0_2
{
	NSInteger gmtSeconds = [[NSTimeZone defaultTimeZone] secondsFromGMT];
	
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:20];
	
	const char *sql = "SELECT Task_ID, Task_StartTime, Task_EndTime, Task_Deadline, Task_UpdateTime FROM TaskTable";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			Task *task = [[Task alloc] init];
			task.primaryKey = sqlite3_column_int(statement, 0);
			
			NSTimeInterval startTimeValue = sqlite3_column_double(statement, 1);
			NSTimeInterval endTimeValue = sqlite3_column_double(statement, 2);
			NSTimeInterval deadlineValue = sqlite3_column_double(statement, 3);
			NSTimeInterval updateTimeValue = sqlite3_column_double(statement, 4);
			
			task.startTime = (startTimeValue == -1? nil:[Common dateByAddNumSecond:-gmtSeconds toDate:[NSDate dateWithTimeIntervalSince1970:startTimeValue]]);
			task.endTime = (endTimeValue == -1? nil:[Common dateByAddNumSecond:-gmtSeconds toDate:[NSDate dateWithTimeIntervalSince1970:endTimeValue]]);
			task.deadline = (deadlineValue == -1? nil:[Common dateByAddNumSecond:-gmtSeconds toDate:[NSDate dateWithTimeIntervalSince1970:deadlineValue]]);
			task.updateTime = (updateTimeValue == -1? nil:[Common dateByAddNumSecond:-gmtSeconds toDate:[NSDate dateWithTimeIntervalSince1970:updateTimeValue]]);
			
			[taskList addObject:task];
			[task release];
		}
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	for (Task *task in taskList)
	{
		[task enableExternalUpdate];
		[task updateTimeIntoDB:database];
	}
	
	Settings *settings = [Settings getInstance];
	
	[settings changeDBVersion:@"1.0.2"];
}

- (void)upgradeDBv2_0
{
	//////printf("upgrade DB v2.0\n");
	
	//step1 - add new column Task_MergedSeqNo, Task_CompletionTime to TaskTable
	//sqlite3_exec(database, "ALTER TABLE TaskTable ADD COLUMN Task_ToodledoID TEXT;", nil, nil, nil);
	sqlite3_exec(database, "ALTER TABLE TaskTable ADD COLUMN Task_MergedSeqNo NUMERIC;", nil, nil, nil);
	sqlite3_exec(database, "ALTER TABLE TaskTable ADD COLUMN Task_CompletionTime NUMERIC;", nil, nil, nil);
	
	//step2 - change default calendar project type to TYPE_PLAN [-10000 -> 0]
	
	const char *sql1 = "UPDATE ProjectTable SET Project_Type = ? WHERE Project_Type = -10000";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql1, -1, &statement, NULL) == SQLITE_OK) 
	{
		sqlite3_bind_int(statement, 1, TYPE_PLAN);	
		
		int success = sqlite3_step(statement);

		if (success != SQLITE_DONE) 
		{
			NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
		}	
	}

	sqlite3_finalize(statement);
	
	//step3 - create new Shopping List plan to store all existing check list items
	
	Project *checkList = [[Project alloc] init];
	checkList.name = @"Check List";
	checkList.colorId = 20;
	checkList.sequenceNo = [self getPlanMaxSeqNo] + 1;
	checkList.type = TYPE_PLAN;
	checkList.primaryKey = -1;
	
	[checkList insertIntoDB:database];
	
	NSInteger key =	checkList.primaryKey;
	[checkList release];
	
	//step4 - assign shopping plan to all existing check list items
	const char *sql2 = "UPDATE TaskTable SET Task_ProjectID = ?, Task_Type = ?, Task_MergedSeqNo = -1 WHERE Task_ProjectID = -1";
	
	if (sqlite3_prepare_v2(database, sql2, -1, &statement, NULL) == SQLITE_OK) 
	{
		sqlite3_bind_int(statement, 1, key);
		sqlite3_bind_int(statement, 2, TYPE_TASK);
		
		int success = sqlite3_step(statement);
		
		if (success != SQLITE_DONE) 
		{
			NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
		}	
	}
	
	sqlite3_finalize(statement);
	
	//step5 - show top check list item in Task View
	Task *task = [self getTopTaskForPlan:key];
	
	if (task != nil)
	{
		task.mergedSeqNo = [self getTaskMaxSeqNo] + 1;
		[task updateMergedSeqNoIntoDB:database];
	}
	
	//step6 - change seqNo and merged seqNo of all tasks
	NSMutableArray *projects = [self getProjects];
	
	for (Project *project in projects)
	{
		NSMutableArray *tasks = [self getTasksForPlan:project.primaryKey];
		
		for (int i=0; i<tasks.count; i++)
		{
			Task *task = [tasks objectAtIndex:i];
			
			task.mergedSeqNo = task.sequenceNo;
			task.sequenceNo = i;
			
			if (task.status == TASK_STATUS_DONE)
			{
				task.completionTime = task.updateTime;
			}
			
			//[task updateMergedSeqNoIntoDB:database];
			//[task updateSeqNoIntoDB:database];
			[task updateIntoDB:database];
		}
	}
	
	Settings *settings = [Settings getInstance];
	
	[settings changeDBVersion:@"2.0"];
}

- (void)upgradeDBv3_0
{
	sqlite3_exec(database, "ALTER TABLE ProjectTable ADD COLUMN Project_Tag NUMERIC;", nil, nil, nil);
	sqlite3_exec(database, "ALTER TABLE ProjectTable ADD COLUMN Project_SyncID TEXT;", nil, nil, nil);
	sqlite3_exec(database, "ALTER TABLE ProjectTable ADD COLUMN Project_Status NUMERIC;", nil, nil, nil);
	sqlite3_exec(database, "ALTER TABLE ProjectTable ADD COLUMN Project_UpdateTime NUMERIC;", nil, nil, nil);

	sqlite3_exec(database, "CREATE INDEX Project_SeqNo_idx ON ProjectTable(Project_SeqNo);", nil, nil, nil);
	sqlite3_exec(database, "CREATE INDEX Task_SeqNo_idx ON TaskTable(Task_SeqNo);", nil, nil, nil);
	sqlite3_exec(database, "CREATE INDEX Task_MergedSeqNo_idx ON TaskTable(Task_MergedSeqNo);", nil, nil, nil);
	sqlite3_exec(database, "CREATE INDEX TaskProgress_ID_idx ON TaskProgressTable(TaskProgress_ID);", nil, nil, nil);
	
	//update project status to PROJECT_STATUS_NONE and update time to nil
	const char *sql = "UPDATE ProjectTable SET Project_Status = ?, Project_UpdateTime = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
	{
		sqlite3_bind_int(statement, 1, PROJECT_STATUS_NONE);
		sqlite3_bind_double(statement, 2, -1);
		
		int success = sqlite3_step(statement);
		
		if (success != SQLITE_DONE) 
		{
			NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
		}	
	}
	
	sqlite3_finalize(statement);
	
	NSMutableArray *projects = [self getProjects];
	
	for (Project *project in projects)
	{
		NSMutableArray *tasks = [self getTasksForPlan:project.primaryKey];
		
		[Common sortList:tasks byKey:@"mergedSeqNo" ascending:YES];
		
		for (int i=0; i<tasks.count; i++)
		{
			Task *task = [tasks objectAtIndex:i];
			
			task.sequenceNo = i;
			
			[task updateSeqNoIntoDB:database];
            
            task.mergedSeqNo = i;
            [task updateMergedSeqNoIntoDB:database];
		}
		
		//project.tdId = project.syncId;
		//[project updateMappingIntoDB:database];
        
        project.ekId = @"";
        project.tdId = @"";
        [project updateMappingIntoDB:database];
	}		
		
	Settings *settings = [Settings getInstance];
	
	[settings changeDBVersion:@"3.0"];	
}

- (void)upgradeDBv3_1
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:200];
	
	sqlite3_stmt *statement = nil;
	
	const char *sql = "SELECT Task_ID FROM TaskTable WHERE Task_Type = ? AND Task_Status <> ? AND Task_MergedSeqNo > -1 ORDER BY Task_MergedSeqNo ASC";
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK)	
	{
		sqlite3_bind_int(statement, 1, TYPE_TASK);
		sqlite3_bind_int(statement, 2, TASK_STATUS_DELETED);
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
			
			[taskList addObject:task];
			[task release];
		}
	}
		
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
	
	NSInteger c = 0;
	
	for (Task *task in taskList)
	{
		task.sequenceNo = c++;
		task.mergedSeqNo = -1;
		[task updateIntoDB:database];
	}
	
	NSMutableArray *prjKeyList = [NSMutableArray arrayWithCapacity:20];
	
	sql = "SELECT Project_ID FROM ProjectTable WHERE Project_Status <> ? AND Project_Type = ?";

	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, PROJECT_STATUS_DELETED);
		sqlite3_bind_int(statement, 2, TYPE_LIST);
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int primaryKey = sqlite3_column_int(statement, 0);
			
			[prjKeyList addObject:[NSNumber numberWithInt:primaryKey]];
		}
	}

	sqlite3_finalize(statement);	
	
	for (NSNumber *prjKey in prjKeyList)
	{
		NSArray *list = [self getTasksForPlan:[prjKey intValue]]; 
		
		for (Task *task in list)
		{
			task.type = TYPE_SHOPPING_ITEM;
			task.sequenceNo = c++;
			task.mergedSeqNo = -1;
			
			[task updateIntoDB:database];
		}
	}
	
}

- (void)upgradeDBv3_2
{
    ////printf("upgrade DB v3.2\n");
    
    NSInteger newColorIds[21] = {8, 17, 1, 27, 21, 13, 0,
                                22, 20, 11, 16, 5, 29, 9,
                                12, 3, 15, 6, 10, 7, 2};
    
	NSMutableArray *projects = [self getProjects];
	
	for (Project *project in projects)
	{
        project.colorId = newColorIds[project.colorId];
        
        project.ekId = @"";
        
        [project updateIntoDB:database];
    }    
}

- (void)upgradeDBv4_0
{
	sqlite3_exec(database, "ALTER TABLE ProjectTable ADD COLUMN Project_SDWID NUMERIC;", nil, nil, nil);
	sqlite3_exec(database, "ALTER TABLE ProjectTable ADD COLUMN Project_Source NUMERIC;", nil, nil, nil);
    sqlite3_exec(database, "ALTER TABLE ProjectTable ADD COLUMN Project_Transparent NUMERIC;", nil, nil, nil);
	sqlite3_exec(database, "ALTER TABLE TaskTable ADD COLUMN Task_SDWID TEXT;", nil, nil, nil);
    sqlite3_exec(database, "ALTER TABLE TaskTable ADD COLUMN Task_Link TEXT;", nil, nil, nil);
    sqlite3_exec(database, "ALTER TABLE TaskTable ADD COLUMN Task_TimerStatus NUMERIC;", nil, nil, nil);
    
    sqlite3_exec(database, "CREATE TABLE TaskLinkTable (TaskLink_ID INTEGER PRIMARY KEY, \
                                                        SDW_ID TEXT, \
                                                        Source_ID NUMERIC, \
                                                        Dest_ID NUMERIC, \
                                                        Status NUMERIC, \
                                                        CreationTime NUMERIC, \
                                                        UpdateTime NUMERIC)", nil, nil, nil);
    
	NSMutableArray *projects = [self getProjects];
	
	for (Project *project in projects)
    {
        if (project.type == 2) //LIST
        {
            project.type = 1;            
        }
        
        if (project.status == PROJECT_STATUS_TRANSPARENT)
        {
            project.isTransparent = YES;
        }
        
        [project updateIntoDB:database];
    }
}

- (void)upgradeDBv5_0
{
    sqlite3_exec(database, "CREATE TABLE URLTable (URL_ID INTEGER PRIMARY KEY, \
                 URL_Value TEXT, URL_Status NUMERIC, URL_UpdateTime NUMERIC, URL_SDWID TEXT)", nil, nil, nil);

    sqlite3_exec(database, "CREATE TABLE CommentTable (Comment_ID INTEGER PRIMARY KEY, \
                 Comment_Content TEXT, Comment_Status NUMERIC, Comment_CreateTime NUMERIC, Comment_UpdateTime NUMERIC, Comment_SDWID TEXT, Comment_ItemID NUMERIC, Comment_LastName TEXT, Comment_FirstName TEXT, Comment_IsOwner NUMERIC, Comment_Type NUMERIC)", nil, nil, nil);
    
	sqlite3_exec(database, "ALTER TABLE TaskLinkTable ADD COLUMN Dest_AssetType NUMERIC;", nil, nil, nil);
    
	sqlite3_exec(database, "ALTER TABLE TaskTable ADD COLUMN Task_ExtraStatus NUMERIC;", nil, nil, nil);
    sqlite3_exec(database, "ALTER TABLE TaskTable ADD COLUMN Task_TimeZoneID NUMERIC;", nil, nil, nil);
    sqlite3_exec(database, "ALTER TABLE TaskTable ADD COLUMN Task_TimeZoneOffset NUMERIC;", nil, nil, nil);
	sqlite3_exec(database, "ALTER TABLE ProjectTable ADD COLUMN Project_ExtraStatus NUMERIC;", nil, nil, nil);
    sqlite3_exec(database, "ALTER TABLE ProjectTable ADD COLUMN Project_OnwerName TEXT;", nil, nil, nil);
    
    // add 'alert location' field
    sqlite3_exec(database, "ALTER TABLE TaskTable ADD COLUMN Task_LocationAlert NUMERIC;", nil, nil, nil);
    
	NSString *sql = @"UPDATE ProjectTable SET Project_ExtraStatus = ?, Project_OwnerName = ''";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
	{
		sqlite3_bind_int(statement, 1, PROJECT_EXTRA_STATUS_NONE);
		
		int success = sqlite3_step(statement);
		
		if (success != SQLITE_DONE)
		{
			NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
		}
	}
	
	sqlite3_finalize(statement);
    
    sql = @"UPDATE TaskTable SET Task_ExtraStatus = ?, Task_TimeZoneID = 0, Task_TimeZoneOffset = 0";
    
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
	{
		sqlite3_bind_int(statement, 1, TASK_EXTRA_STATUS_NONE);
		//sqlite3_bind_int(statement, 2, tzID);
		int success = sqlite3_step(statement);
		
		if (success != SQLITE_DONE)
		{
			NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
		}
	}
	
	sqlite3_finalize(statement);
    
    sql = @"UPDATE TaskLinkTable SET Dest_AssetType = 0";
    
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
	{
		int success = sqlite3_step(statement);
		
		if (success != SQLITE_DONE)
		{
			NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
		}
	}
	
	sqlite3_finalize(statement);
}

-(void)closeDB
{
	sqlite3_close(database);
}

#pragma mark Public Methods

+(void)startup
{
	DBManager *dbm = [DBManager getInstance];
	
	[dbm createEditableCopyOfDatabaseIfNeeded];
	// Call internal method to initialize database connection
	[dbm initializeDatabase];
	
}

+(id)getInstance
{
	if (_dbManagerSingleton == nil)
	{
		_dbManagerSingleton = [[DBManager alloc] init];
	}
	
	return _dbManagerSingleton;
}

+(void)free
{
	[Task finalizeStatements];
	[Project finalizeStatements];
	[AlertData finalizeStatements];
	
	[TaskProgress finalizeStatements];
	
	sqlite3_finalize(_event_list_statement);
	_event_list_statement = nil;

	sqlite3_finalize(_ade_list_statement);
	_ade_list_statement = nil;

	sqlite3_finalize(_all_task_list_statement);
	_all_task_list_statement = nil;

	sqlite3_finalize(_due_task_list_statement);
	_due_task_list_statement = nil;

	sqlite3_finalize(_start_task_list_statement);
	_start_task_list_statement = nil;

	sqlite3_finalize(_top_task_statement);
	_top_task_statement = nil;
	
	if (_dbManagerSingleton != nil)
	{
		[_dbManagerSingleton closeDB];
		
		[_dbManagerSingleton release];
		_dbManagerSingleton = nil;
	}
}

@end
