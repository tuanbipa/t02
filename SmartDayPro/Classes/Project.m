//
//  Project.m
//  SmartPlan
//
//  Created by Huy Le on 11/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <sqlite3.h>

#import "Project.h"

#import "Task.h"
#import "Common.h"
#import "Settings.h"
#import "Link.h"

#import "DBManager.h"
#import "TaskLinkManager.h"

//extern NSInteger _gmtSeconds;

static sqlite3_stmt *prj_init_statement = nil;
static sqlite3_stmt *prj_insert_statement = nil;
static sqlite3_stmt *prj_update_statement = nil;
static sqlite3_stmt *prj_seq_update_statement = nil;
static sqlite3_stmt *prj_delete_statement = nil;

@implementation Project

@synthesize primaryKey;
@synthesize sequenceNo;
@synthesize colorId;
@synthesize isTransparent;
@synthesize name;
@synthesize ownerName;
@synthesize tag;
//@synthesize syncId;
@synthesize sdwId;

@synthesize actualStartTime;
@synthesize startTime;
@synthesize endTime;
@synthesize workBalance;
@synthesize estimatedHours;

@synthesize isPinnedDeadline;

@synthesize creationTime;
@synthesize updateTime;

@synthesize type;
@synthesize goal;

@synthesize ekId;
@synthesize tdId;
@synthesize rmdId;

@synthesize suggestedEventMappingName;

@synthesize yMargin;

@synthesize tbdTask;

@synthesize planDuration;
@synthesize latestEstimatedDuration;
@synthesize doneDuration;
@synthesize delayedDuration;
@synthesize revisedWorkBalance;
@synthesize revisedDeadline;

@synthesize isInitial;
@synthesize isExpanded;

@synthesize status;
@synthesize extraStatus;
@synthesize source;

- (id)init
{
	if (self = [super init])
	{
		self.isInitial = NO;
		self.isExpanded = NO;
		
		self.type = 0;
		self.colorId = 0;
		self.primaryKey = -1;
		self.sequenceNo = -1;
        self.isTransparent = NO;
		self.name = @"";
        self.ownerName = @"";
		self.goal = 0;
		self.tag = @"";
		//self.syncId = @"";
        self.sdwId = @"";
		
		self.actualStartTime = nil;				
		self.creationTime = [NSDate date];
		self.startTime = [NSDate date];	
		self.updateTime = nil;
		
		self.ekId = @"";
		self.tdId = @"";
        self.rmdId = @"";
		
		self.suggestedEventMappingName = @"";
		
		self.yMargin = -1;
		
		
		self.isPinnedDeadline = NO;	
		
		self.status = PROJECT_STATUS_NONE;
        self.extraStatus = PROJECT_EXTRA_STATUS_NONE;
        self.source = CATEGORY_SOURCE_LOCAL;
		
		isExternalUpdate = NO;
		
		[self resetPlan];
	}
	
	return self;
}

- (void)dealloc {
	
	self.name = nil;
    self.ownerName = nil;
	self.tag = nil;
	//self.syncId = nil;
    self.sdwId = nil;
	
	self.actualStartTime = nil;
	self.startTime = nil;
	self.endTime = nil;
	
	self.creationTime = nil;
	self.updateTime = nil;
	
	self.tbdTask = nil;
	
	self.revisedDeadline = nil;
	
	self.ekId = nil;
	self.tdId = nil;
    self.rmdId = nil;
	self.suggestedEventMappingName = nil;
	
    [super dealloc];
}


- (void) initialUpdate
{
	self.type = (10000 + self.type)*(-1);
		
	NSMutableArray *taskList = [[DBManager getInstance] getAllItemsForPlan:self.primaryKey];
	
	for (Task *task in taskList)
	{
		[task initialUpdate];
	}
}	

- (id) copyWithZone:(NSZone*) zone{
	Project *copy = [[Project alloc] init];
	copy.type = type;
	copy.status = status;
    copy.extraStatus = extraStatus;
	copy.primaryKey = primaryKey;
	copy.sequenceNo = sequenceNo;
	copy.colorId = colorId;
    copy.isTransparent = isTransparent;
	copy.name = name;
    copy.ownerName = ownerName;
	copy.tag = tag;
	copy.actualStartTime = actualStartTime;
	copy.startTime = startTime;
	copy.endTime = endTime;
	copy.workBalance = workBalance;
	copy.estimatedHours = estimatedHours;
	
	copy.isPinnedDeadline = isPinnedDeadline;	
	
	copy.goal = goal;
	
	copy.ekId = ekId;
	copy.tdId = tdId;
	
	copy.yMargin = yMargin;
	
	//copy.creationTime = creationTime;
	copy.creationTime = [NSDate date];
	
	copy.tbdTask = [self.tbdTask copy];
	
	copy.planDuration = planDuration;
	copy.latestEstimatedDuration = latestEstimatedDuration;
	copy.doneDuration = doneDuration;
	copy.delayedDuration = delayedDuration;
	copy.revisedWorkBalance = revisedWorkBalance;
	copy.revisedDeadline = revisedDeadline;
	
	return copy;
}

- (void) resetDefault
{	
	self.startTime = (self.actualStartTime != nil? self.actualStartTime: [NSDate date]);
	
	//self.workBalance = [[Settings getInstance] planWorkBalance];
	//self.estimatedHours =  [[Settings getInstance] planEstimatedHours];
	self.isPinnedDeadline = NO;
	
	self.tbdTask = nil;
	
	[self refreshPlan];
	
	if (self.latestEstimatedDuration > 0)
	{
		self.estimatedHours = self.latestEstimatedDuration/3600;
	}
}

- (void) resetPlan
{	
	self.tbdTask = nil;
	
	self.planDuration = 0;
	self.latestEstimatedDuration = self.estimatedHours*3600;
	self.doneDuration = 0;
	self.delayedDuration = 0;
	self.revisedWorkBalance = self.workBalance;
	self.revisedDeadline = self.endTime;
	
	self.actualStartTime = nil;
}

- (void) updateEstimatedHours:(CGFloat) hours
{
	if (self.tbdTask != nil)
	{
		if (hours > self.estimatedHours)
		{
			self.tbdTask.duration += (hours - self.estimatedHours)*3600;
			self.tbdTask.status = TASK_STATUS_TBD_DURATION_CHANGED;
		}
		else if (hours*3600 < self.planDuration)
		{
			self.tbdTask = nil;
		}
		else if (hours != self.estimatedHours)
		{
			self.tbdTask.duration -= (self.estimatedHours - hours)*3600;
			self.tbdTask.status = TASK_STATUS_TBD_DURATION_CHANGED;
		}
	}
	
	self.estimatedHours = hours;
}

-(void)updateByProject:(Project *)prj
{
	self.type = prj.type;
	self.status = prj.status;
    self.extraStatus = prj.extraStatus;
	self.name = prj.name;
    self.ownerName = prj.ownerName;
	self.colorId = prj.colorId;
    self.isTransparent = prj.isTransparent;
	self.startTime = prj.startTime;
	self.endTime = prj.endTime;
	self.workBalance = prj.workBalance;
	self.estimatedHours = prj.estimatedHours;
	self.goal = prj.goal;
	self.tag = prj.tag;
	
	self.ekId = prj.ekId;
	self.tdId = prj.tdId;
	
	self.isPinnedDeadline = prj.isPinnedDeadline;
	
	self.revisedWorkBalance = prj.revisedWorkBalance;
	self.revisedDeadline = prj.revisedDeadline;
	
	if (!self.isPinnedDeadline)
	{
		self.workBalance = self.revisedWorkBalance;
	}
	else
	{
		self.endTime = self.revisedDeadline;
	}
}

- (void) refreshPlan
{
	self.planDuration = 0;
	self.latestEstimatedDuration = 0;
	self.doneDuration = 0;
	self.delayedDuration = 0;
	
	NSArray *taskList = [[DBManager getInstance] getTasksWithDurationForProject:self.primaryKey estimatedOnly:NO];
	
	for (Task *task in taskList)
	{
		self.planDuration += task.duration;
		self.latestEstimatedDuration += (task.status == TASK_STATUS_DONE? task.actualDuration : task.duration);
		self.doneDuration += (task.status == TASK_STATUS_DONE? task.actualDuration:0);
		self.delayedDuration += (task.status == TASK_STATUS_DONE && task.actualDuration > task.duration?task.actualDuration - task.duration:0);
	}
	
	/*
	 if (self.tbdTask != nil)
	 {
	 self.latestEstimatedDuration += self.tbdTask.duration;
	 }
	 */
	
	if (self.isPinnedDeadline)
	{
		[self calculateWorkBalance];
	}
	else
	{
		[self calculateDeadline];
	}
	
	if (self.actualStartTime == nil) //not yet start
	{
		self.endTime = self.revisedDeadline;		
	}
}

- (CGFloat) getTotalDuration
{
	if (self.actualStartTime == nil && self.tbdTask != nil)
	{
		return self.estimatedHours*3600;
	}
	
	CGFloat duration = self.latestEstimatedDuration;
	
	if (self.tbdTask != nil)
	{
		duration += self.tbdTask.duration;
	}
	
	return duration;
}

- (NSDate *)getPlanStartTime
{
	if (self.actualStartTime != nil)
	{
		return self.actualStartTime;
	}
	
	return self.startTime;
}

- (NSDate *) calculateDefaultEndTime
{
	NSInteger days = round([self calculateDefaultWeeks]*7);
	
	return [Common dateByAddNumDay:days toDate:self.startTime];
}

- (CGFloat) calculateDefaultWeeks
{
	if (self.workBalance == 0)
	{
		return 0;
	}
	
	return self.estimatedHours/self.workBalance;
}

- (CGFloat) calculateWeeks
{
	CGFloat totalDuration = [self getTotalDuration];
	
	if (self.revisedWorkBalance == 0)
	{
		return 0;
	}
	
	return totalDuration/3600/self.revisedWorkBalance;
}

- (void) calculateDeadline
{
	//CGFloat hours = [self getTotalDuration]/3600;
	
	//NSInteger days = round(hours*7/self.revisedWorkBalance);
	
	NSInteger days = round([self calculateWeeks]*7);
	
	self.revisedDeadline = [Common dateByAddNumDay:days toDate:[self getPlanStartTime]];
}

- (void) calculateWorkBalance
{	
	CGFloat hours = [self getTotalDuration]/3600;
	
	NSInteger days = [Common timeIntervalNoDST:self.revisedDeadline sinceDate:[self getPlanStartTime]]/(24*3600);
	
	if (days == 0)
	{
		self.revisedWorkBalance = 0;
	}
	else 
	{
		self.revisedWorkBalance = hours*7/days;
	}
}

- (PlanInfo) getInfo //SmartCal support
{
	PlanInfo ret;
	
	ret.progress = 0;
	ret.doneTotal = 0;
	ret.total = 0;
	ret.totalDuration = 0;

	NSMutableArray *taskList = [[DBManager getInstance] getTasksForPlan:self.primaryKey];
	
	NSInteger doneDurationTotal = 0;
	
	for (Task *task in taskList)
	{
		ret.total ++;
		
		ret.totalDuration += task.duration;
		
		if (task.status == TASK_STATUS_DONE)
		{
			ret.doneTotal ++;
			
			doneDurationTotal += task.duration;			
		}
	}
	
	ret.progress = (ret.totalDuration == 0? 0:doneDurationTotal*1.0/ret.totalDuration);
	
	return ret;
}

- (BOOL) checkTransparent
{
    return self.isTransparent;//(self.status == PROJECT_STATUS_TRANSPARENT );  
}

- (BOOL) checkDefault
{
    NSInteger pk = [[Settings getInstance] taskDefaultProject];
    
    return pk == self.primaryKey;
}

- (BOOL) isShared
{
    return self.extraStatus == PROJECT_EXTRA_STATUS_SHARED;
}

-(void) saveSnapshot
{
	self.workBalance = self.revisedWorkBalance;
	self.endTime = self.revisedDeadline;
	
	[self updateEndTimeWBIntoDB:[[DBManager getInstance] getDatabase]];
}

// Creates the object with primary key and title is brought into memory.
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)database 
{
    if (self = [super init]) {
		//@synchronized([DBManager getInstance])
		{
		
        // Compile the query for retrieving book data. See insertNewBookIntoDatabase: for more detail.
        //sqlite3_stmt *statement = nil;
			
		sqlite3_stmt *statement = prj_init_statement;
			
        if (statement == nil) {
            // Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
            // This is a great way to optimize because frequently used queries can be compiled once, then with each
            // use new variable values can be bound to placeholders.
            const char *sql = "SELECT Project_ID, Project_Type, Project_ColorID, Project_SeqNo, Project_GoalID, \
			Project_Name, Project_CreationTime, Project_ActualStartTime, Project_StartTime, Project_EndTime, \
			Project_Hours, Project_WorkBalance, Project_YMargin, Project_PinnedDeadline, Project_EventMappingName, Project_TaskMappingName, \
			Project_Tag, Project_SyncID, Project_Status, Project_UpdateTime, Project_SDWID, Project_Source, Project_Transparent, Project_ExtraStatus, Project_OwnerName  FROM ProjectTable WHERE Project_ID = ?";
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
			self.type = sqlite3_column_int(statement, 1);
			self.colorId = sqlite3_column_int(statement, 2);
			self.sequenceNo = sqlite3_column_int(statement, 3);
			self.goal = sqlite3_column_int(statement, 4);			

            //self.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(prj_init_statement, 5)];
			char *str = (char *)sqlite3_column_text(statement, 5);
			self.name = (str == NULL? @"":[NSString stringWithUTF8String:str]);			
			
			NSTimeInterval creationTimeValue = sqlite3_column_double(statement, 6);
			NSTimeInterval actualStartTimeValue = sqlite3_column_double(statement, 7);
			NSTimeInterval startTimeValue = sqlite3_column_double(statement, 8);
			NSTimeInterval endTimeValue = sqlite3_column_double(statement, 9);			
			
			self.creationTime = (creationTimeValue == -1? nil:[Common fromDBDate:[NSDate dateWithTimeIntervalSince1970:creationTimeValue]]);
			self.actualStartTime = (actualStartTimeValue == -1? nil:[Common fromDBDate:[NSDate dateWithTimeIntervalSince1970:actualStartTimeValue]]);			
			self.startTime = (startTimeValue == -1? nil:[Common fromDBDate:[NSDate dateWithTimeIntervalSince1970:startTimeValue]]);
			self.endTime = (endTimeValue == -1? nil:[Common fromDBDate:[NSDate dateWithTimeIntervalSince1970:endTimeValue]]);
			
			self.estimatedHours = sqlite3_column_double(statement, 10);
			self.workBalance = sqlite3_column_double(statement, 11);
			
			self.yMargin = sqlite3_column_double(statement, 12);
			self.isPinnedDeadline = sqlite3_column_int(statement, 13);
			
			str = (char *)sqlite3_column_text(statement, 14);
			self.ekId = (str == NULL? @"":[NSString stringWithUTF8String:str]);			

			str = (char *)sqlite3_column_text(statement, 15);
			self.tdId = (str == NULL? @"":[NSString stringWithUTF8String:str]);			

			str = (char *)sqlite3_column_text(statement, 16);
			self.tag = (str == NULL? @"":[NSString stringWithUTF8String:str]);
			
			str = (char *)sqlite3_column_text(statement, 17);
			//self.syncId = (str == NULL? @"":[NSString stringWithUTF8String:str]);
            self.rmdId = (str == NULL? @"":[NSString stringWithUTF8String:str]);
			
			self.status = sqlite3_column_int(statement, 18);
			
			NSTimeInterval updateTimeValue = sqlite3_column_double(statement, 19);			
			
			self.updateTime = (updateTimeValue == -1? nil:[NSDate dateWithTimeIntervalSince1970:updateTimeValue]);
            
			str = (char *)sqlite3_column_text(statement, 20);
			self.sdwId = (str == NULL? @"":[NSString stringWithUTF8String:str]);
            
            self.source = sqlite3_column_int(statement, 21);
            
            self.isTransparent = (sqlite3_column_int(statement, 22) == 1);
            
            self.extraStatus = sqlite3_column_int(statement, 23);
            
			str = (char *)sqlite3_column_text(statement, 24);
			self.ownerName = (str == NULL? @"":[NSString stringWithUTF8String:str]);
            
        } 
		
        // Reset the statement for future reuse.
        //sqlite3_finalize(statement);
		sqlite3_reset(statement);
			
		}
		
		self.revisedWorkBalance = self.workBalance;
		self.revisedDeadline = self.endTime;
		
		if (self.type <= -10000)
		{
			[self initialUpdate];
			
			[self updateTypeIntoDB:database];
		}
    }
	
    return self;
}

- (void) insertIntoDB:(sqlite3 *)database
{
	//@synchronized([DBManager getInstance])
	{
	
    //sqlite3_stmt *statement = nil; 
	sqlite3_stmt *statement = prj_insert_statement;
    if (statement == nil) 
	{
        static char *sql = "INSERT INTO ProjectTable (Project_Type,Project_ColorID,Project_SeqNo,Project_GoalID, \
		Project_Name,Project_CreationTime,Project_ActualStartTime,Project_StartTime,Project_EndTime, \
		Project_Hours,Project_WorkBalance,Project_YMargin,Project_PinnedDeadline,Project_EventMappingName,Project_TaskMappingName, \
		Project_Tag,Project_SyncID,Project_Status,Project_UpdateTime,Project_SDWID,Project_Source,Project_Transparent, Project_ExtraStatus, Project_OwnerName) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
		
    }
	
	if (!isExternalUpdate)
	{
		self.updateTime = [NSDate date];		
	}
	
	isExternalUpdate = NO;		
	
	sqlite3_bind_int(statement, 1, self.type);
	sqlite3_bind_int(statement, 2, self.colorId);
	sqlite3_bind_int(statement, 3, self.sequenceNo);
	sqlite3_bind_int(statement, 4, self.goal);	
	sqlite3_bind_text(statement, 5, [self.name UTF8String], -1, SQLITE_TRANSIENT);
	
	//NSTimeInterval creationTimeValue = (self.creationTime == nil? -1: [[Common toDBDate:self.creationTime] timeIntervalSince1970]);	

	NSTimeInterval creationTimeValue = (self.creationTime == nil? -1: [self.creationTime timeIntervalSince1970]);
	
	NSTimeInterval actualStartTimeValue = (self.actualStartTime == nil? -1: [[Common toDBDate:self.actualStartTime] timeIntervalSince1970]);
	NSTimeInterval startTimeValue = (self.startTime == nil? -1: [[Common toDBDate:self.startTime] timeIntervalSince1970]);
	NSTimeInterval endTimeValue = (self.endTime == nil? -1: [[Common toDBDate:self.endTime] timeIntervalSince1970]);
	
	sqlite3_bind_double(statement, 6, creationTimeValue);
	sqlite3_bind_double(statement, 7, actualStartTimeValue);
	sqlite3_bind_double(statement, 8, startTimeValue);
	sqlite3_bind_double(statement, 9, endTimeValue);
	
	sqlite3_bind_double(statement, 10, self.estimatedHours);
	sqlite3_bind_double(statement, 11, self.workBalance);
	
	sqlite3_bind_double(statement, 12, self.yMargin);
	sqlite3_bind_int(statement, 13, self.isPinnedDeadline);
	
	sqlite3_bind_text(statement, 14, [self.ekId UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statement, 15, [self.tdId UTF8String], -1, SQLITE_TRANSIENT);
	
	sqlite3_bind_text(statement, 16, [self.tag UTF8String], -1, SQLITE_TRANSIENT);
	
	//sqlite3_bind_text(statement, 17, [self.syncId UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 17, [self.rmdId UTF8String], -1, SQLITE_TRANSIENT);
	
	sqlite3_bind_int(statement, 18, self.status);
	
	NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);
	
	sqlite3_bind_double(statement, 19, updateTimeValue);	
        
    sqlite3_bind_text(statement, 20, [self.sdwId UTF8String], -1, SQLITE_TRANSIENT);        
	
	sqlite3_bind_int(statement, 21, self.source);
        
    sqlite3_bind_int(statement, 22, self.isTransparent?1:0);
        
    sqlite3_bind_int(statement, 23, self.extraStatus);
        
    sqlite3_bind_text(statement, 24, [self.ownerName UTF8String], -1, SQLITE_TRANSIENT);
        
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
}

- (void) updateIntoDB:(sqlite3 *)database
{
	if (self.tbdTask != nil)
	{
		[self.tbdTask updateDurationIntoDB:[[DBManager getInstance] getDatabase]];
	}
	
	//@synchronized([DBManager getInstance])
	{
	
    //sqlite3_stmt *statement = nil; 
	sqlite3_stmt *statement = prj_update_statement;
    if (statement == nil) {
		static char *sql = "UPDATE ProjectTable SET Project_Type=?, Project_ColorID=?, Project_SeqNo=?, \
		Project_GoalID=?, Project_Name=?, Project_CreationTime=?, Project_ActualStartTime=?, Project_StartTime=?, Project_EndTime=?, \
		Project_Hours=?, Project_WorkBalance=?, Project_PinnedDeadline=?,Project_EventMappingName=?,Project_TaskMappingName=?, \
		Project_Tag=?, Project_SyncID=?, Project_Status=?, Project_UpdateTime=?, Project_SDWID=?, Project_Source=?, Project_Transparent=?, Project_ExtraStatus=?, Project_OwnerName=? WHERE Project_ID = ?";
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	if (!isExternalUpdate)
	{
		self.updateTime = [NSDate date];		
	}
	
	isExternalUpdate = NO;		
	
	sqlite3_bind_int(statement, 1, self.type);
	sqlite3_bind_int(statement, 2, self.colorId);
	sqlite3_bind_int(statement, 3, self.sequenceNo);
	sqlite3_bind_int(statement, 4, self.goal);	
	sqlite3_bind_text(statement, 5, [self.name UTF8String], -1, SQLITE_TRANSIENT);

	NSTimeInterval creationTimeValue = (self.creationTime == nil? -1: [[Common toDBDate:self.creationTime] timeIntervalSince1970]);	
	NSTimeInterval actualStartTimeValue = (self.actualStartTime == nil? -1: [[Common toDBDate:self.actualStartTime] timeIntervalSince1970]);
	NSTimeInterval startTimeValue = (self.startTime == nil? -1: [[Common toDBDate:self.startTime] timeIntervalSince1970]);
	NSTimeInterval endTimeValue = (self.endTime == nil? -1: [[Common toDBDate:self.endTime] timeIntervalSince1970]);	
	
	sqlite3_bind_double(statement, 6, creationTimeValue);
	sqlite3_bind_double(statement, 7, actualStartTimeValue);
	sqlite3_bind_double(statement, 8, startTimeValue);
	sqlite3_bind_double(statement, 9, endTimeValue);
	
	sqlite3_bind_double(statement, 10, self.estimatedHours);
	sqlite3_bind_double(statement, 11, self.workBalance);
	sqlite3_bind_int(statement, 12, self.isPinnedDeadline);
	
	sqlite3_bind_text(statement, 13, [self.ekId UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statement, 14, [self.tdId UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statement, 15, [self.tag UTF8String], -1, SQLITE_TRANSIENT);
	
	//sqlite3_bind_text(statement, 16, [self.syncId UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 16, [self.rmdId UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(statement, 17, self.status);
	
	NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);
	
	sqlite3_bind_double(statement, 18, updateTimeValue);
        
    sqlite3_bind_text(statement, 19, [self.sdwId UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(statement, 20, self.source);
    sqlite3_bind_int(statement, 21, self.isTransparent?1:0);
    sqlite3_bind_int(statement, 22, self.extraStatus);
        
    sqlite3_bind_text(statement, 23, [self.ownerName UTF8String], -1, SQLITE_TRANSIENT);
	
	sqlite3_bind_int(statement, 24, self.primaryKey);
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    //sqlite3_finalize(statement);
	sqlite3_reset(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
	}
}

- (void) updateSeqNoIntoDB:(sqlite3 *)database
{
	//@synchronized([DBManager getInstance])
	{
	
    //sqlite3_stmt *statement = nil;
	sqlite3_stmt *statement = prj_seq_update_statement;
    if (statement == nil) {
        static char *sql = "UPDATE ProjectTable SET Project_SeqNo = ? WHERE Project_ID = ?";
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	sqlite3_bind_int(statement, 1, self.sequenceNo);
	sqlite3_bind_int(statement, 2, self.primaryKey);	
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    //sqlite3_finalize(statement);
	sqlite3_reset(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
		
	}
}

- (void) updateTypeIntoDB:(sqlite3 *)database
{
    //@synchronized([DBManager getInstance])
	{
	
	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE ProjectTable SET Project_Type=? WHERE Project_ID=?";
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	sqlite3_bind_int(statement, 1, self.type);
	sqlite3_bind_int(statement, 2, self.primaryKey);	
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
	}
}

- (void) updateYMarginIntoDB:(sqlite3 *)database
{
	//@synchronized([DBManager getInstance])
	{

	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE ProjectTable SET Project_YMargin=? WHERE Project_ID=?";
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	sqlite3_bind_int(statement, 1, self.yMargin);
	sqlite3_bind_int(statement, 2, self.primaryKey);	
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
	}
}

- (void) updateMappingIntoDB:(sqlite3 *)database
{
	//@synchronized([DBManager getInstance])
	{

	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE ProjectTable SET Project_EventMappingName=?,Project_TaskMappingName=? WHERE Project_ID=?";
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	sqlite3_bind_text(statement, 1, [self.ekId UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statement, 2, [self.tdId UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 3, self.primaryKey);
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
	}
}

- (void) updateEKIDIntoDB:(sqlite3 *)database
{
	//@synchronized([DBManager getInstance])
	{

	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE ProjectTable SET Project_EventMappingName=? WHERE Project_ID=?";
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	sqlite3_bind_text(statement, 1, [self.ekId UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(statement, 2, self.primaryKey);	
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
	}
}

- (void) updateToodledoIDIntoDB:(sqlite3 *)database
{
	//@synchronized([DBManager getInstance])
	{

	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE ProjectTable SET Project_TaskMappingName=? WHERE Project_ID=?";
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	sqlite3_bind_text(statement, 1, [self.tdId UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(statement, 2, self.primaryKey);	
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
	}
}

- (void) updateActualStartTimeIntoDB:(sqlite3 *)database
{
	//@synchronized([DBManager getInstance])
	{

	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE ProjectTable SET Project_ActualStartTime = ? WHERE Project_ID = ?";		
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	//NSTimeInterval actualStartTimeValue = (self.actualStartTime == nil? -1: [[Common dateByAddNumSecond:_gmtSeconds toDate:self.actualStartTime] timeIntervalSince1970]);		
	NSTimeInterval actualStartTimeValue = (self.actualStartTime == nil? -1: [[Common toDBDate:self.actualStartTime] timeIntervalSince1970]);		
	
	sqlite3_bind_double(statement, 1, actualStartTimeValue);
	sqlite3_bind_int(statement, 2, self.primaryKey);
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
	}
}

- (void) updateEndTimeIntoDB:(sqlite3 *)database
{
	//@synchronized([DBManager getInstance])
	{

	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE ProjectTable SET Project_EndTime = ? WHERE Project_ID = ?";		
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	//NSTimeInterval endTimeValue = (self.endTime == nil? -1: [[Common dateByAddNumSecond:_gmtSeconds toDate:self.endTime] timeIntervalSince1970]);		
	NSTimeInterval endTimeValue = (self.endTime == nil? -1: [[Common toDBDate:self.endTime] timeIntervalSince1970]);		
	
	sqlite3_bind_double(statement, 1, endTimeValue);
	sqlite3_bind_int(statement, 2, self.primaryKey);
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
		
	}
}

- (void) updateEndTimeWBIntoDB:(sqlite3 *)database
{
	//@synchronized([DBManager getInstance])
	{

	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE ProjectTable SET Project_EndTime = ?, Project_WorkBalance = ? WHERE Project_ID = ?";		
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	//NSTimeInterval endTimeValue = (self.endTime == nil? -1: [[Common dateByAddNumSecond:_gmtSeconds toDate:self.endTime] timeIntervalSince1970]);		
	NSTimeInterval endTimeValue = (self.endTime == nil? -1: [[Common toDBDate:self.endTime] timeIntervalSince1970]);		
	
	sqlite3_bind_double(statement, 1, endTimeValue);
	sqlite3_bind_double(statement, 2, self.workBalance);
	
	sqlite3_bind_int(statement, 3, self.primaryKey);
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
	}
}

- (void) updateHoursIntoDB:(sqlite3 *)database
{
    //@synchronized([DBManager getInstance])
	{

	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE ProjectTable SET Project_Hours = ? WHERE Project_ID = ?";		
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	sqlite3_bind_double(statement, 1, self.estimatedHours);
	sqlite3_bind_int(statement, 2, self.primaryKey);
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
	}
}

- (void) updateNameIntoDB:(sqlite3 *)database
{
	//@synchronized([DBManager getInstance])
	{

	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE ProjectTable SET Project_Name = ? WHERE Project_ID = ?";		
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	if (!isExternalUpdate)
	{
		self.updateTime = [NSDate date];
	}
	
	isExternalUpdate = NO;		
	
	sqlite3_bind_text(statement, 1, [self.name UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(statement, 2, self.primaryKey);
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
	}
}

//- (void) updateSyncIDIntoDB:(sqlite3 *)database
- (void) updateReminderIDIntoDB:(sqlite3 *)database
{
	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE ProjectTable SET Project_SyncID=?, Project_UpdateTime=? WHERE Project_ID=?";
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    
	NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);	    
	
	//sqlite3_bind_text(statement, 1, [self.syncId UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 1, [self.rmdId UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_double(statement, 2, updateTimeValue);
	sqlite3_bind_int(statement, 3, self.primaryKey);	
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) 
    {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
}

- (void) updateSDWIDIntoDB:(sqlite3 *)database
{
	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE ProjectTable SET Project_SDWID=?, Project_UpdateTime=? WHERE Project_ID=?";
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    
	NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);	    
	
	sqlite3_bind_text(statement, 1, [self.sdwId UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_double(statement, 2, updateTimeValue);
	sqlite3_bind_int(statement, 3, self.primaryKey);	
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) 
    {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
}


- (void) updateColorIDIntoDB:(sqlite3 *)database
{
	//@synchronized([DBManager getInstance])
	{

	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE ProjectTable SET Project_ColorID=? WHERE Project_ID=?";
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	sqlite3_bind_int(statement, 1, self.colorId);
	sqlite3_bind_int(statement, 2, self.primaryKey);	
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
	}
}

- (void) updateStatusIntoDB:(sqlite3 *)database
{
	//@synchronized([DBManager getInstance])
	{

	sqlite3_stmt *statement = nil;
	
    if (statement == nil) 
	{
		static char *sql = "UPDATE ProjectTable SET Project_Status=?, Project_UpdateTime=? WHERE Project_ID=?";
		
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
	
	sqlite3_bind_int(statement, 1, self.status);
	sqlite3_bind_double(statement, 2, updateTimeValue);
	sqlite3_bind_int(statement, 3, self.primaryKey);
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
	}
}

- (void) updateTagIntoDB:(sqlite3 *)database
{
	//////printf("Update Tag - task %s\n", [self.name UTF8String]);
	
    //@synchronized([DBManager getInstance])
	{
	
	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE ProjectTable SET Project_Tag = ?, Project_UpdateTime = ? WHERE Project_ID=?";
		
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
	
	sqlite3_bind_text(statement, 1, [self.tag UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_double(statement, 2, updateTimeValue);
	sqlite3_bind_int(statement, 3, self.primaryKey);
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
	}
}

- (void) modifyUpdateTimeIntoDB:(sqlite3 *)database
{
	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE ProjectTable SET Project_UpdateTime = ? WHERE Project_ID = ?";
		
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

- (void)deleteFromDatabase
{
	if ((self.ekId == nil || [self.ekId isEqualToString:@""]) &&
        (self.tdId == nil || [self.tdId isEqualToString:@""]) &&
        (self.sdwId == nil || [self.sdwId isEqualToString:@""]))
	{
		[self cleanFromDatabase];
		
		return;
	}
	
	DBManager *dbm = [DBManager getInstance];
    TaskLinkManager *tlm = [TaskLinkManager getInstance];
	
	//[dbm deleteAllTasksForProject:self.primaryKey];
    NSMutableArray *itemList = [dbm getAllItemsForPlan:self.primaryKey];
	
	for (Task *item in itemList)
	{
        if ([item isTask])
        {
            [dbm deleteAllProgressForTask:item.primaryKey];
        }
        
        NSMutableArray *links = [tlm getLinks4Task:item.primaryKey];
        
        for (Link *link in links)
        {
            [link deleteFromDatabase:[dbm getDatabase]];
        }
        
        [item deleteFromDatabase:[dbm getDatabase]];
	}
    
    //[dbm deleteAllItemsForProject:self.primaryKey];
	
	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
		static char *sql = "UPDATE ProjectTable SET Project_Status=?,Project_UpdateTime=? WHERE Project_ID=?";
		
        if (sqlite3_prepare_v2([dbm getDatabase], sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([dbm getDatabase]));
        }
    }
	
	self.status = PROJECT_STATUS_DELETED;
	
	if (!isExternalUpdate)
	{
		self.updateTime = [NSDate date];
	}
	
	isExternalUpdate = NO;	
	
	NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);
	
	sqlite3_bind_int(statement, 1, self.status);
	sqlite3_bind_double(statement, 2, updateTimeValue);
	sqlite3_bind_int(statement, 3, self.primaryKey);
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg([dbm getDatabase]));
	}
}

- (void)cleanFromDatabase 
{
	DBManager *dbm = [DBManager getInstance];
    TaskLinkManager *tlm = [TaskLinkManager getInstance];
	
    NSMutableArray *itemList = [dbm getAllItemsForPlan:self.primaryKey];
	
	for (Task *item in itemList)
	{
        if ([item isTask])
        {
            [dbm deleteAllProgressForTask:item.primaryKey];
        }
        
        NSMutableArray *links = [tlm getLinks4Task:item.primaryKey];
        
        for (Link *link in links)
        {
            //[link deleteFromDatabase:[dbm getDatabase]];
            [link cleanFromDatabase:[dbm getDatabase]];
        }
        
        //[item deleteFromDatabase:[dbm getDatabase]];
        [item cleanFromDatabase:[dbm getDatabase]];
	}   
    
    // Compile the delete statement if needed.
	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        const char *sql = "DELETE FROM ProjectTable WHERE Project_ID = ?";
		
        if (sqlite3_prepare_v2([dbm getDatabase], sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([dbm getDatabase]));
        }
    }
	
    // Bind the primary key variable.
    sqlite3_bind_int(statement, 1, self.primaryKey);
    // Execute the query.
    int success = sqlite3_step(statement);
    // Reset the statement for future use.
    sqlite3_finalize(statement);
	
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg([dbm getDatabase]));
    }
}

- (void) externalUpdate
{
	isExternalUpdate = YES;
	
	[self updateIntoDB:[[DBManager getInstance] getDatabase]];
}

- (void) enableExternalUpdate
{
	isExternalUpdate = YES;
}


// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements {
    if (prj_init_statement) sqlite3_finalize(prj_init_statement);
    if (prj_insert_statement) sqlite3_finalize(prj_insert_statement);
    if (prj_update_statement) sqlite3_finalize(prj_update_statement);
	if (prj_seq_update_statement) sqlite3_finalize(prj_seq_update_statement);
	if (prj_delete_statement) sqlite3_finalize(prj_delete_statement);
	
	prj_init_statement = nil;
	prj_insert_statement = nil;
	prj_update_statement = nil;
	prj_seq_update_statement = nil;
	prj_delete_statement = nil;
}

@end
