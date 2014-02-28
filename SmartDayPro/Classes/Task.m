//
//  Task.m
//  SmartPlan
//
//  Created by Huy Le on 11/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <sqlite3.h>

#import "Common.h"
#import "Task.h"
#import "Settings.h"

#import "TaskManager.h"
#import "DBManager.h"
#import "TaskProgress.h"
#import "RepeatData.h"
#import "AlertData.h"
#import "AlertManager.h"
#import "ProjectManager.h"
#import "TaskLinkManager.h"

#import "TagDictionary.h"

static sqlite3_stmt *task_init_statement = nil;
static sqlite3_stmt *task_insert_statement = nil;
static sqlite3_stmt *task_update_statement = nil;
static sqlite3_stmt *task_order_update_statement = nil;
static sqlite3_stmt *task_seq_update_statement = nil;
static sqlite3_stmt *task_merge_seq_update_statement = nil;
static sqlite3_stmt *task_delete_statement = nil;

@implementation Task

@synthesize primaryKey;
@synthesize groupKey;
@synthesize sequenceNo;
@synthesize mergedSeqNo;
@synthesize project;
@synthesize goal;
@synthesize type;

@synthesize status;
@synthesize timerStatus;
@synthesize extraStatus;
@synthesize duration;
@synthesize timeZoneId;

@synthesize name;
@synthesize contactName;
@synthesize location;
@synthesize contactEmail;
@synthesize contactPhone;
@synthesize note;
@synthesize tag;
@synthesize syncId;
@synthesize sdwId;

//@synthesize toodledoId;

@synthesize creationTime;
@synthesize startTime;
@synthesize endTime;
@synthesize deadline;
@synthesize updateTime;
@synthesize completionTime;

@synthesize smartTime;
@synthesize reInstanceStartTime;

@synthesize repeatData;
@synthesize alerts;

@synthesize isActivating;
@synthesize actualDuration;

@synthesize subTasks;
@synthesize lastProgress;

@synthesize original;

@synthesize isScheduled;

@synthesize exceptions;
@synthesize links;

@synthesize isTop;
@synthesize isSplitted;
@synthesize hasNoDuration;
@synthesize isMultiEdit;

@synthesize listSource;

@synthesize plannerDuration;
@synthesize plannerStartTime;
@synthesize locationAlert;
@synthesize locationAlertID;
@synthesize locationID;
// smart share
@synthesize assigneeEmail;
@synthesize assignDate;

- (id)init
{
	if (self = [super init])
	{
        Settings *settings = [Settings getInstance];
        
		self.primaryKey = -1;
		self.groupKey = -1;
		self.sequenceNo = 0;
		self.mergedSeqNo = -1;

		self.project = settings.taskDefaultProject;
		self.goal = 0;
		self.type = TYPE_TASK;		
		
		self.status = TASK_STATUS_NONE;
        self.timerStatus = TASK_TIMER_STATUS_NONE;
        self.extraStatus = TASK_EXTRA_STATUS_NONE;
		self.duration = [[Settings getInstance] taskDuration];
        self.timeZoneId = [Settings findTimeZoneID:[NSTimeZone defaultTimeZone]];
		
		self.name = @"";
		self.contactName = @"";
		self.location = @"";
		self.contactEmail = @"";
		self.contactPhone = @"";
		self.note = @"";
        
        //change in SD: don't copy tags from Category but inherits instead
		//self.tag = [[ProjectManager getInstance] getProjectTagByKey:self.project];
		
        self.tag = @"";
		self.syncId = @"";
        self.sdwId = @"";
		
		self.creationTime = [NSDate date];

		self.startTime = [settings getWorkingStartTimeForDate:[NSDate date]];
		self.endTime = nil;
		self.deadline = nil;
		self.updateTime = nil;
		self.completionTime = nil;
		
		self.repeatData = nil;
		self.alerts = [NSMutableArray arrayWithCapacity:0];
		
		self.isActivating = NO;
		self.actualDuration = 0;
		
		self.subTasks = nil;
		self.lastProgress = nil;
		
		self.original = nil;
		
		self.isScheduled = NO;

		self.exceptions = nil;
        
        self.links = [NSMutableArray arrayWithCapacity:10];
		
		isExternalUpdate = NO;
		
		self.isTop = NO;
		
		self.isSplitted = NO;
		
		self.hasNoDuration = NO;
        
        self.isMultiEdit = NO;
        
        self.listSource = SOURCE_SMARTLIST;
        
        // for planner
        self.plannerDuration = 0;
        self.plannerStartTime = nil;
        
        // location alert
        self.locationAlert = 0;
        self.locationAlertID = 0;
        self.locationID = 0;
        
        // smart share
        self.assigneeEmail = @"";
        self.assignDate = nil;
	}
	
	return self;
}

- (void)dealloc {
	
	self.name = nil;
	
	self.contactName = nil;
	self.location = nil;
	self.contactEmail = nil;
	self.contactPhone = nil;
	self.note = nil;
	self.tag = nil;
	self.syncId = nil;
	
	self.creationTime = nil;
	self.startTime = nil;
	self.endTime = nil;
	self.deadline = nil;
	self.updateTime = nil;
	self.completionTime = nil;
	
	self.smartTime = nil;
    self.reInstanceStartTime = nil;
	
	self.repeatData = nil;
	self.alerts = nil;
	
    self.original = nil;
	self.subTasks = nil;
	self.lastProgress = nil;
	
	self.exceptions = nil;
    self.links = nil;
	
    // for planner
    self.plannerStartTime = nil;
    
    self.assigneeEmail = nil;
    self.assignDate = nil;
    [super dealloc];
}

- (BOOL) checkChange:(Task *)task
{
    Task *taskOriginal = self;
    
    NSDate *taskStartTime = self.startTime;
    NSDate *taskEndTime = self.endTime;
    
	if (self.original != nil && ![self isREException]) //Calendar Task or REException
	{
        taskOriginal = self.original;
        
        NSTimeInterval reDuration = [self.original.endTime timeIntervalSinceDate:self.original.startTime];
        
        taskStartTime = self.reInstanceStartTime;
        taskEndTime = [self.reInstanceStartTime dateByAddingTimeInterval:reDuration];
    }
    
    return
    task.primaryKey == -1 ||
        taskOriginal.project != task.project ||
        taskOriginal.type != task.type ||
        taskOriginal.status != task.status ||
        taskOriginal.extraStatus != task.extraStatus ||
        taskOriginal.duration != task.duration ||
        taskOriginal.timeZoneId != task.timeZoneId ||
        ![taskOriginal.name isEqualToString:task.name] ||
        ![taskOriginal.contactName isEqualToString:task.contactName] ||
        ![taskOriginal.location isEqualToString:task.location] ||
        ![taskOriginal.contactEmail isEqualToString:task.contactEmail] ||
        ![taskOriginal.contactPhone isEqualToString:task.contactPhone] ||
        ![taskOriginal.note isEqualToString:task.note] ||
        ![taskOriginal.tag isEqualToString:task.tag] ||
        [Common compareDate:taskStartTime withDate:task.startTime] != NSOrderedSame ||
        [Common compareDate:taskEndTime withDate:task.endTime] != NSOrderedSame ||
        [Common compareDate:taskOriginal.deadline withDate:task.deadline] != NSOrderedSame ||        ![[taskOriginal getRepeatString] isEqualToString:[task getRepeatString]] ||
    ![[taskOriginal alertsToString] isEqualToString:[task alertsToString]] ||
    taskOriginal.locationAlert != task.locationAlert ||
    taskOriginal.locationAlertID != task.locationAlertID ||
    taskOriginal.locationID != task.locationID;
    
}

- (void) updateByTask:(Task*) task 
{
	self.primaryKey = task.primaryKey;
	self.groupKey = task.groupKey;
	self.project = task.project;
	self.goal = task.goal;
	self.type = task.type;	
	
	self.status = task.status;
    self.extraStatus = task.extraStatus;
	self.duration = task.duration;
    self.timeZoneId = task.timeZoneId;
	
	self.name = task.name;
	self.contactName = task.contactName;
	self.location = task.location;
	self.contactEmail = task.contactEmail;
	self.contactPhone = task.contactPhone;	
	self.note = task.note;
	self.tag = task.tag;
	
	self.startTime = task.startTime;
	self.endTime = task.endTime;
	self.deadline = task.deadline;
	self.updateTime = [NSDate date];
	self.completionTime = task.completionTime;
	
	self.repeatData = task.repeatData;
	
	//self.alerts = nil;
	
	if (task.alerts != nil)
	{
		self.alerts = [[NSMutableArray alloc] initWithArray:task.alerts copyItems:YES];
		[self.alerts release];
	}
    else
    {
        self.alerts = [NSMutableArray arrayWithCapacity:0];
    }
	
	self.actualDuration = task.actualDuration;
	
	if (self.type != TYPE_TASK)
	{
		self.smartTime = self.startTime;
	}
	
    /*
	if (self.duration == 0 && self.type == TYPE_TASK)
	{
		self.duration = [[Settings getInstance] taskDuration];
	}
    
    if (task.links != nil)
    {
		self.links = [[NSMutableArray alloc] initWithArray:task.links copyItems:YES];
		[self.links release]; 
    }
	*/
    
    // location alert
    self.locationAlert = task.locationAlert;
    self.locationAlertID = task.locationAlertID;
    self.locationID = task.locationID;
    
    self.assigneeEmail = task.assigneeEmail;
    self.assignDate = task.assignDate;
}

- (void) updateByRE:(Task*) reOriginal 
{
	self.project = reOriginal.project;
	self.goal = reOriginal.goal;
	
	if (self.primaryKey < 0) // not RE exception
	{
		self.duration = reOriginal.duration;	
		
		self.name = reOriginal.name;
		self.contactName = reOriginal.contactName;
		self.location = reOriginal.location;
		self.contactEmail = reOriginal.contactEmail;
		self.contactPhone = reOriginal.contactPhone;	
		self.note = reOriginal.note;
		self.tag = reOriginal.tag;		
	}
}

- (id) copyWithZone:(NSZone*) zone{
	Task *copy = [[Task alloc] init];
	
	copy.primaryKey = primaryKey;
	copy.groupKey = groupKey;
	copy.sequenceNo = sequenceNo;
	copy.mergedSeqNo = mergedSeqNo;
	copy.project = project;
	copy.goal = goal;
	copy.type = type;	
	
	copy.status = status;
    copy.extraStatus = extraStatus;
	copy.duration = duration;
    copy.timeZoneId = timeZoneId;
	
	copy.name = name;
	copy.contactName = contactName;
	copy.location = location;
	copy.contactEmail = contactEmail;
	copy.contactPhone = contactPhone;
	copy.note = note;
	copy.tag = tag;
	
	copy.creationTime = [NSDate date];
	copy.startTime = startTime;
	copy.endTime = endTime;
	copy.deadline = deadline;
	copy.updateTime = updateTime;
	copy.completionTime = completionTime;
	copy.smartTime = (smartTime != nil?[Common dateByAddNumSecond:1 toDate:smartTime]:smartTime);
    copy.reInstanceStartTime = reInstanceStartTime;
	
	copy.repeatData = repeatData;
	copy.alerts = [[NSMutableArray alloc] initWithArray:alerts copyItems:YES];
	[copy.alerts release];
	
	copy.actualDuration = actualDuration;
	copy.original = original;
	
	//copy.isScheduled = YES;
    
    copy.links = [[NSMutableArray alloc] initWithArray:links copyItems:YES];
    [copy.links release];
    
    copy.listSource = listSource;
    
    // location alert
    copy.locationAlert = locationAlert;
    copy.locationAlertID = locationAlertID;
    copy.locationID = locationID;
    
    copy.assigneeEmail = assigneeEmail;
    copy.assignDate = assignDate;
    
    ////printf("Task %s copy - link count: %d\n", [copy.name UTF8String], copy.links.count);
	
	return copy;
}

- (NSDictionary *) tojson
{
    NSInteger extra = self.extraStatus & TASK_EXTRA_STATUS_ANCHORED;
    
    NSString *repeatStr = [self getRepeatString];
    
    //printf("repeate str to json: %s\n", [repeatStr UTF8String]);
    
    NSDictionary *taskDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              self.name, @"name",
                              self.note, @"description",
                              self.location, @"location",
                              self.tag, @"tag",
                              self.contactName, @"contact_name",
                              self.contactEmail, @"contact_email",
                              self.contactPhone, @"contact_phone",
                              [NSNumber numberWithInt:type], @"type",
                              [NSNumber numberWithInt: self.duration], @"duration",
                              [NSNumber numberWithInt: self.timeZoneId], @"timezone",
                              [NSNumber numberWithInt:self.status], @"status",
                              [NSNumber numberWithInt:extra], @"extra_status",
                              [NSNumber numberWithDouble:(self.startTime == nil?-1:[self.startTime timeIntervalSince1970])], @"start_time",
                              [NSNumber numberWithDouble:(self.endTime == nil?-1:[self.endTime timeIntervalSince1970])], @"end_time",
                              [NSNumber numberWithDouble:(self.deadline == nil?-1:[self.deadline timeIntervalSince1970])], @"deadline",
                              [NSNumber numberWithDouble:(self.completionTime == nil?-1:[self.completionTime timeIntervalSince1970])], @"completion_time",
                              repeatStr, @"repeat",
                              [self alertsToString], @"alert",
                              nil
                              ];

    return taskDict;
}

- (void) fromjson:(NSDictionary *)jsonDict
{
    self.name = [jsonDict objectForKey:@"name"];
    self.note = [jsonDict objectForKey:@"description"];
    self.location = [jsonDict objectForKey:@"location"];
    self.tag = [jsonDict objectForKey:@"tag"];
    self.contactName = [jsonDict objectForKey:@"contactName"];
    self.contactEmail = [jsonDict objectForKey:@"contactEmail"];
    self.contactPhone = [jsonDict objectForKey:@"contactPhone"];
    self.type = [[jsonDict objectForKey:@"type"] intValue];
    self.duration = [[jsonDict objectForKey:@"duration"] intValue];
    self.timeZoneId = [[jsonDict objectForKey:@"timeZoneId"] intValue];
    self.status = [[jsonDict objectForKey:@"status"] intValue];
    self.extraStatus = [[jsonDict objectForKey:@"extraStatus"] intValue];
    
    NSInteger startTimeValue = [[jsonDict objectForKey:@"start_time"] intValue];
    self.startTime = (startTimeValue == -1?nil:[NSDate dateWithTimeIntervalSince1970:startTimeValue]);

    NSInteger endTimeValue = [[jsonDict objectForKey:@"end_time"] intValue];
    self.endTime = (endTimeValue == -1?nil:[NSDate dateWithTimeIntervalSince1970:endTimeValue]);

    NSInteger deadlineValue = [[jsonDict objectForKey:@"deadline"] intValue];
    self.deadline = (deadlineValue == -1?nil:[NSDate dateWithTimeIntervalSince1970:deadlineValue]);

    NSInteger completionValue = [[jsonDict objectForKey:@"completion_time"] intValue];
    self.completionTime = (completionValue == -1?nil:[NSDate dateWithTimeIntervalSince1970:completionValue]);
    
    NSString *repeatStr = [jsonDict objectForKey:@"repeat"];
    
    //printf("repeat str: %s\n", [repeatStr UTF8String]);
    
    self.repeatData = [RepeatData parseRepeatData:repeatStr];

    NSString *alerts = [jsonDict objectForKey:@"alert"];
    
    if (![alerts isEqualToString:@""])
    {
        NSArray *parts = [alerts componentsSeparatedByString:@","];
        
        for (NSString *alertStr in parts)
        {
            AlertData *alertDat = [AlertData parseRepeatData:alertStr];
            
            [self.alerts addObject:alertDat];
        }
    }
}

- (void) resetTask
{
	self.primaryKey = -1;
	self.groupKey = -1;
	self.sequenceNo = 0;
	self.mergedSeqNo = -1;
	self.type = TYPE_TASK;
	
	self.status = TASK_STATUS_NONE;
    self.timerStatus = TASK_TIMER_STATUS_NONE;
    self.extraStatus = TASK_EXTRA_STATUS_NONE;
	self.subTasks = nil;
	
	self.creationTime = [NSDate date];
	self.startTime = nil;
	self.endTime = nil;	
	self.deadline = nil;
	self.updateTime = nil;
	self.completionTime = nil;
	
	self.repeatData = nil;
	self.alerts = [NSMutableArray arrayWithCapacity:0];
	
	self.isActivating = NO;
	self.actualDuration = 0;
	
	self.isScheduled = NO;
	
	self.exceptions = nil;
	
	self.isSplitted = NO;
}

-(void)resetStrings
{
	if (self.contactName == nil)
	{
		self.contactName = @"";
	}
	
	if (self.contactEmail == nil)
	{
		self.contactEmail = @"";
	}
	
	if (self.contactPhone == nil)
	{
		self.contactPhone = @"";
	}
	
	if (self.location == nil)
	{
		self.location = @"";
	}
	
	if (self.note == nil)
	{
		self.note = @"";
	}
	
	if (self.tag == nil)
	{
		self.tag = @"";
	}
	
	if (self.syncId == nil)
	{
		self.syncId = @"";
	}
	
	/*
	if (self.toodledoId == nil)
	{
		self.toodledoId = @"";
	}
	*/
}

- (void) initialUpdate
{
	NSDate *today = [self isEvent]?[Common dateByRoundMinute:5 toDate:[NSDate date]]:[Common copyTimeFromDate:self.creationTime toDate:[NSDate date]];
	
	NSInteger startDiff = (self.startTime == nil?0:[self.startTime timeIntervalSinceDate:self.creationTime]);
	NSInteger dueDiff = (self.deadline == nil?0:[self.deadline timeIntervalSinceDate:self.creationTime]);
	NSInteger endDiff = [self.endTime timeIntervalSinceDate:self.startTime];
	
	if (self.startTime != nil)
	{
		self.startTime = [self isADE]?[Common clearTimeForDate:today]:
        [self isEvent]?[Common dateByAddNumSecond:-30*60 toDate:today]:
        [self isNote]?[Common copyTimeFromDate:self.startTime toDate:[Common dateByAddNumDay:-1 toDate:today]]:[Common dateByAddNumSecond:startDiff toDate:today];
		
		if (self.endTime != nil)
		{
			self.endTime = [Common dateByAddNumSecond:endDiff toDate:self.startTime];
            
            if ([self isADE]) {
                self.endTime = [Common getEndDate:self.endTime];
            }
		}
	}
	
	if (self.deadline != nil)
	{
		self.deadline = [Common dateByAddNumSecond:dueDiff toDate:today];
	}
    
    DBManager *dbm = [DBManager getInstance];

	[self updateTimeIntoDB:[dbm getDatabase]];
    
}

// Creates the object with primary key and title is brought into memory.
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)database 
{
    if (self = [super init]) 
	{
        //sqlite3_stmt *statement = nil;
		sqlite3_stmt *statement = task_init_statement;

        // Compile the query for retrieving book data. See insertNewBookIntoDatabase: for more detail.
        if (statement == nil) {
            // Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
            // This is a great way to optimize because frequently used queries can be compiled once, then with each
            // use new variable values can be bound to placeholders.
			
            const char *sql = "SELECT Task_ID, Task_GroupID, Task_ProjectID, Task_SeqNo, Task_GoalID, Task_Type, \
			Task_Status, Task_Name, Task_ContactName, Task_ContactEmail, Task_ContactPhone, Task_Location, \
			Task_Note, Task_Duration, Task_CreationTime, Task_StartTime, Task_EndTime, Task_Deadline, Task_UpdateTime, \
			Task_RepeatData, Task_Tag, Task_SyncID, Task_MergedSeqNo, Task_CompletionTime,Task_SDWID,Task_TimerStatus,Task_ExtraStatus,Task_TimeZoneID,Task_LocationAlert, Task_LocationID, Task_LocationAlertID, Task_AssigneeEmail, Task_AssignDate\
            FROM TaskTable WHERE Task_ID = ?";
			
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
			self.groupKey = sqlite3_column_int(statement, 1);
			self.project = sqlite3_column_int(statement, 2);
			self.sequenceNo = sqlite3_column_int(statement, 3);
			self.goal = sqlite3_column_int(statement, 4);
			self.type = sqlite3_column_int(statement, 5);			
			self.status = sqlite3_column_int(statement, 6);

			char *str = (char *)sqlite3_column_text(statement, 7);
			self.name = (str == NULL? @"":[NSString stringWithUTF8String:str]);
			
			str = (char *)sqlite3_column_text(statement, 8);
			self.contactName = (str == NULL? @"":[NSString stringWithUTF8String:str]);
			
			str = (char *)sqlite3_column_text(statement, 9);
			self.contactEmail = (str == NULL? @"":[NSString stringWithUTF8String:str]);			
			
			str = (char *)sqlite3_column_text(statement, 10);
			self.contactPhone = (str == NULL? @"":[NSString stringWithUTF8String:str]);			
			
			str = (char *)sqlite3_column_text(statement, 11);
			self.location = (str == NULL? @"":[NSString stringWithUTF8String:str]);			
			
			str = (char *)sqlite3_column_text(statement, 12);
			self.note = (str == NULL? @"":[NSString stringWithUTF8String:str]);			
			
			self.duration = sqlite3_column_double(statement, 13);	
			
			NSTimeInterval creationTimeValue = sqlite3_column_double(statement, 14);
			NSTimeInterval startTimeValue = sqlite3_column_double(statement, 15);
			NSTimeInterval endTimeValue = sqlite3_column_double(statement, 16);
			NSTimeInterval deadlineValue = sqlite3_column_double(statement, 17);
			NSTimeInterval updateTimeValue = sqlite3_column_double(statement, 18);
			
			str = (char *)sqlite3_column_text(statement, 19);
			NSString *repeatStr = (str == NULL? @"":[NSString stringWithUTF8String:str]);
			
			if (self.type == TYPE_RE_DELETED_EXCEPTION)
			{
				self.repeatData = [RepeatData parseRepeatDataForDeletedException:repeatStr];
			}
			else if (self.groupKey > -1)
			{
				self.repeatData = [RepeatData parseRepeatDataForException:repeatStr];
                
                self.original = [[TaskManager getInstance] findREByKey:self.groupKey];
			}
			else
			{
				self.repeatData = [RepeatData parseRepeatData:repeatStr];
			}
			
			str = (char *)sqlite3_column_text(statement, 20);
			self.tag = (str == NULL? @"":[NSString stringWithUTF8String:str]);			
			
			str = (char *)sqlite3_column_text(statement, 21);
			self.syncId = (str == NULL? @"":[NSString stringWithUTF8String:str]);			

			self.mergedSeqNo = sqlite3_column_int(statement, 22);	
			
			NSTimeInterval completionTimeValue = sqlite3_column_double(statement, 23);
			
 			str = (char *)sqlite3_column_text(statement, 24);
			self.sdwId = (str == NULL? @"":[NSString stringWithUTF8String:str]);
			            
            self.timerStatus = sqlite3_column_int(statement, 25);

            self.extraStatus = sqlite3_column_int(statement, 26);

            self.timeZoneId = sqlite3_column_int(statement, 27);
            
            // location alert
            self.locationAlert = sqlite3_column_int(statement, 28);
            self.locationID = sqlite3_column_int(statement, 29);
            self.locationAlertID = sqlite3_column_int(statement, 30);
            
            str = (char *)sqlite3_column_text(statement, 31);
			self.assigneeEmail = (str == NULL? @"":[NSString stringWithUTF8String:str]);
            NSTimeInterval assignDateValue = sqlite3_column_double(statement, 32);
            self.assignDate = (assignDateValue == -1? nil:[NSDate dateWithTimeIntervalSince1970:assignDateValue]);
            
//            if ([self isNormalEvent])
//            {
//                NSInteger secs = [[NSTimeZone defaultTimeZone] secondsFromGMT] - [Common getSecondsFromTimeZoneID:self.timeZoneId];
//                
//                startTimeValue += secs;
//                endTimeValue += secs;
//            }
            
			self.creationTime = (creationTimeValue == -1? nil:[Common fromDBDate:[NSDate dateWithTimeIntervalSince1970:creationTimeValue]]);
            
			self.startTime = (startTimeValue == -1? nil:[Common fromDBDate:[NSDate dateWithTimeIntervalSince1970:startTimeValue]]);
			
			self.endTime = (endTimeValue == -1? nil:[Common fromDBDate:[NSDate dateWithTimeIntervalSince1970:endTimeValue]]);
            
            if ([self isNormalEvent]) {
                
                self.startTime = [Common convertDate:self.startTime fromTimeZone:[Settings getTimeZoneByID:self.timeZoneId] toTimeZone:[NSTimeZone defaultTimeZone]];
                
                self.endTime = [Common convertDate:self.endTime fromTimeZone:[Settings getTimeZoneByID:self.timeZoneId] toTimeZone:[NSTimeZone defaultTimeZone]];
            }
            
			self.deadline = (deadlineValue == -1? nil:[Common fromDBDate:[NSDate dateWithTimeIntervalSince1970:deadlineValue]]);
			
			self.updateTime = (updateTimeValue == -1? nil:[NSDate dateWithTimeIntervalSince1970:updateTimeValue]);
			
			self.completionTime = (completionTimeValue == -1? nil:[NSDate dateWithTimeIntervalSince1970:completionTimeValue]);
            
			self.smartTime = self.startTime;
			
			if ([self isEvent] || [self isADE])
			{
				self.duration = [Common timeIntervalNoDST:self.endTime sinceDate:self.startTime];
			}
        }
		
        // Reset the statement for future reuse.
        //sqlite3_finalize(statement);
		sqlite3_reset(statement);
			
		}
		
		if (self.repeatData != nil && self.groupKey == -1) 
		{
			//load RE exceptions
			NSMutableArray *exceptionList = [[DBManager getInstance] getTasksInGroup:self.primaryKey];
			
			if (exceptionList.count > 0)
			{
				self.exceptions = [NSMutableDictionary dictionaryWithCapacity:exceptionList.count];
				
				for (Task *exception in exceptionList)
				{
					if (exception.type == TYPE_RE_DELETED_EXCEPTION)
					{
						for (NSDate *date in exception.repeatData.deletedExceptionDates)
						{
							NSDate *dt = [Common clearTimeForDate:date];
							
							[self.exceptions setObject:exception forKey:[NSNumber numberWithDouble:[dt timeIntervalSince1970]]];
						}					
					}
					else if (exception.repeatData != nil) //mySmartDay does not maintain original start time -> exclude the exception instance by DELETED EXCEPTION
					{
						NSDate *dt = [Common clearTimeForDate:exception.repeatData.originalStartTime];
                        
						NSNumber *dtValue = [NSNumber numberWithDouble:[dt timeIntervalSince1970]];
						exception.original = self;
						
						//////printf("RE %s exception on %s - start:%s end:%s\n", [exception.name UTF8String], [[dt description] UTF8String], [[exception.startTime description] UTF8String], [[exception.endTime description] UTF8String]);
						
						[self.exceptions setObject:exception forKey:dtValue];					
						
					}
					
				}
			}
			
		}
		
		self.alerts = [[DBManager getInstance] getAlertsForTask:pk];
    
        self.links = [[TaskLinkManager getInstance] getLinkIds4Task:self.primaryKey];
		
		//self.isScheduled = YES;
		
	////////printf("init Task - ");
	//[self print];
	
    return self;
}

- (void) insertIntoDB:(sqlite3 *)database
{
	[self resetStrings];
	
	sqlite3_stmt *statement = task_insert_statement;
    
    if (statement == nil) 
	{
        static char *sql = "INSERT INTO TaskTable (Task_GroupID, Task_ProjectID, Task_SeqNo, Task_GoalID, Task_Type, \
		Task_Status, Task_Name, Task_ContactName, Task_ContactEmail, Task_ContactPhone, Task_Location, Task_Note, \
		Task_Duration, Task_CreationTime, Task_StartTime, Task_EndTime, Task_Deadline, Task_UpdateTime, Task_RepeatData, \
		Task_Tag, Task_SyncID, Task_MergedSeqNo, Task_CompletionTime, Task_SDWID, Task_Link, Task_TimerStatus, Task_ExtraStatus,Task_TimeZoneID,Task_TimeZoneOffset,Task_LocationAlert, Task_LocationID, Task_LocationAlertID, Task_AssigneeEmail, Task_AssignDate) \
		VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
		
    }
	
	if (!isExternalUpdate)
	{
		self.updateTime = [NSDate date];		
	}
	
	isExternalUpdate = NO;	
	
	sqlite3_bind_int(statement, 1, self.groupKey);
	sqlite3_bind_int(statement, 2, self.project);
	sqlite3_bind_int(statement, 3, self.sequenceNo);
	sqlite3_bind_int(statement, 4, self.goal);	
	sqlite3_bind_int(statement, 5, self.type);
	sqlite3_bind_int(statement, 6, self.status);	
	sqlite3_bind_text(statement, 7, [self.name UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statement, 8, [self.contactName UTF8String], -1, SQLITE_TRANSIENT);	
	sqlite3_bind_text(statement, 9, [self.contactEmail UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statement, 10, [self.contactPhone UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statement, 11, [self.location UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statement, 12, [self.note UTF8String], -1, SQLITE_TRANSIENT);	
	sqlite3_bind_double(statement, 13, self.duration);
    
    if ([self isNormalEvent]) {
        self.startTime = [Common convertDate:self.startTime fromTimeZone:[NSTimeZone defaultTimeZone] toTimeZone:[Settings getTimeZoneByID:self.timeZoneId]];
        self.endTime = [Common convertDate:self.endTime fromTimeZone:[NSTimeZone defaultTimeZone] toTimeZone:[Settings getTimeZoneByID:self.timeZoneId]];
    }

	NSTimeInterval creationTimeValue = (self.creationTime == nil? -1: [[Common toDBDate:self.creationTime] timeIntervalSince1970]);
	NSTimeInterval startTimeValue = (self.startTime == nil? -1: [[Common toDBDate:self.startTime] timeIntervalSince1970]);
	NSTimeInterval endTimeValue = (self.endTime == nil? -1: [[Common toDBDate:self.endTime] timeIntervalSince1970]);
	NSTimeInterval deadlineValue = (self.deadline == nil? -1: [[Common toDBDate:self.deadline] timeIntervalSince1970]);
	NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);
    
//    if ([self isNormalEvent])
//    {
//        NSInteger secs = [Common getSecondsFromTimeZoneID:self.timeZoneId]-[[NSTimeZone defaultTimeZone] secondsFromGMT];
//        
//        startTimeValue += secs;
//        endTimeValue += secs;
//    }
	
	sqlite3_bind_double(statement, 14, creationTimeValue);
	sqlite3_bind_double(statement, 15, startTimeValue);
	sqlite3_bind_double(statement, 16, endTimeValue);
	sqlite3_bind_double(statement, 17, deadlineValue);
	sqlite3_bind_double(statement, 18, updateTimeValue);
	
    NSString *repeatStr = [self getRepeatString];
    
	sqlite3_bind_text(statement, 19, [repeatStr UTF8String], -1, SQLITE_TRANSIENT);	
	
	sqlite3_bind_text(statement, 20, [self.tag UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statement, 21, [self.syncId UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(statement, 22, self.mergedSeqNo);
	
	NSTimeInterval completionTimeValue = (self.completionTime == nil? -1: [self.completionTime timeIntervalSince1970]);
	
	sqlite3_bind_double(statement, 23, completionTimeValue);
    sqlite3_bind_text(statement, 24, [self.sdwId UTF8String], -1, SQLITE_TRANSIENT);
    
    NSString *linkStr = nil;
    
    if (self.links.count > 0)
    {
        for (NSNumber *idNum in self.links)
        {
            linkStr = (linkStr == nil? [NSString stringWithFormat:@"%d", [idNum intValue]] : [linkStr stringByAppendingFormat:@"|%d", [idNum intValue]]);
        }
    }
    else 
    {
        linkStr = @"";
    }
    
    sqlite3_bind_text(statement, 25, [linkStr UTF8String], -1, SQLITE_TRANSIENT);
    
    sqlite3_bind_int(statement, 26, self.timerStatus);
    
    sqlite3_bind_int(statement, 27, self.extraStatus);

    sqlite3_bind_int(statement, 28, self.timeZoneId);
    
    sqlite3_bind_int(statement, 29, [self isEvent]?[Common getSecondsFromTimeZoneID:self.timeZoneId]:0);
    
    // location alert
    sqlite3_bind_int(statement, 30, self.locationAlert);
    sqlite3_bind_int(statement, 31, self.locationID);
    sqlite3_bind_int(statement, 32, self.locationAlertID);
    
    sqlite3_bind_text(statement, 33, [self.assigneeEmail UTF8String], -1, SQLITE_TRANSIENT);
    NSTimeInterval assignDateValue = (self.assignDate == nil? -1: [self.assignDate timeIntervalSince1970]);
    sqlite3_bind_double(statement, 34, assignDateValue);
	
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
		
		[self updateAlerts];
		
    }
	else
	{
		NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
		//return -1;
	}
}

- (void) updateIntoDB:(sqlite3 *)database
{
	[self resetStrings];
	
	sqlite3_stmt *statement = task_update_statement;

    if (statement == nil) {
        static char *sql = "UPDATE TaskTable SET Task_GroupID = ?, Task_ProjectID = ?, Task_SeqNo = ?, Task_GoalID = ?, Task_Type = ?, \
		Task_Status = ?, Task_Name = ?, Task_ContactName = ?, Task_ContactEmail = ?, Task_ContactPhone = ?, Task_Location = ?, \
		Task_Note = ?, Task_Duration = ?, Task_CreationTime = ?, Task_StartTime = ?, Task_EndTime = ?, Task_Deadline = ?, Task_UpdateTime = ?, \
		Task_RepeatData = ?, Task_Tag = ?, Task_MergedSeqNo = ?, Task_CompletionTime = ?, Task_Link = ?, Task_TimerStatus = ?, Task_ExtraStatus = ?, Task_TimeZoneID = ?, Task_TimeZoneOffset = ?, Task_LocationAlert = ?, Task_LocationID = ?, Task_LocationAlertID = ?, Task_AssigneeEmail = ?, Task_AssignDate = ? WHERE Task_ID = ?";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	sqlite3_bind_int(statement, 1, self.groupKey);
	sqlite3_bind_int(statement, 2, self.project);
	sqlite3_bind_int(statement, 3, self.sequenceNo);
	sqlite3_bind_int(statement, 4, self.goal);	
	sqlite3_bind_int(statement, 5, self.type);		
	sqlite3_bind_int(statement, 6, self.status);		
	sqlite3_bind_text(statement, 7, [self.name UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statement, 8, [self.contactName UTF8String], -1, SQLITE_TRANSIENT);	
	sqlite3_bind_text(statement, 9, [self.contactEmail UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statement, 10, [self.contactPhone UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statement, 11, [self.location UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statement, 12, [self.note UTF8String], -1, SQLITE_TRANSIENT);	
	sqlite3_bind_double(statement, 13, self.duration);
	
	if (!isExternalUpdate)
	{
		self.updateTime = [NSDate date];
	}
	
	isExternalUpdate = NO;
    if ([self isNormalEvent]) {
        self.startTime = [Common convertDate:self.startTime fromTimeZone:[NSTimeZone defaultTimeZone] toTimeZone:[Settings getTimeZoneByID:self.timeZoneId]];
        self.endTime = [Common convertDate:self.endTime fromTimeZone:[NSTimeZone defaultTimeZone] toTimeZone:[Settings getTimeZoneByID:self.timeZoneId]];
    }
	
	NSTimeInterval creationTimeValue = (self.creationTime == nil? -1: [[Common toDBDate:self.creationTime] timeIntervalSince1970]);
	NSTimeInterval startTimeValue = (self.startTime == nil? -1: [[Common toDBDate:self.startTime] timeIntervalSince1970]);
	NSTimeInterval endTimeValue = (self.endTime == nil? -1: [[Common toDBDate:self.endTime] timeIntervalSince1970]);
	NSTimeInterval deadlineValue = (self.deadline == nil? -1: [[Common toDBDate:self.deadline] timeIntervalSince1970]);
	NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);
    
//    if ([self isNormalEvent])
//    {
//        NSInteger secs = [Common getSecondsFromTimeZoneID:self.timeZoneId]- [[NSTimeZone defaultTimeZone] secondsFromGMT];
//        
//        startTimeValue += secs;
//        endTimeValue += secs;
//    }
	
	sqlite3_bind_double(statement, 14, creationTimeValue);
	sqlite3_bind_double(statement, 15, startTimeValue);
	sqlite3_bind_double(statement, 16, endTimeValue);
	sqlite3_bind_double(statement, 17, deadlineValue);
	sqlite3_bind_double(statement, 18, updateTimeValue);

    NSString *repeatStr = [self getRepeatString];
	
	sqlite3_bind_text(statement, 19, [repeatStr UTF8String], -1, SQLITE_TRANSIENT);
	
	sqlite3_bind_text(statement, 20, [self.tag UTF8String], -1, SQLITE_TRANSIENT);

	sqlite3_bind_int(statement, 21, self.mergedSeqNo);
	
	NSTimeInterval completionTimeValue = (self.completionTime == nil? -1: [self.completionTime timeIntervalSince1970]);
	
	sqlite3_bind_double(statement, 22, completionTimeValue);
    
    NSString *linkStr = nil;
    
    if (self.links.count > 0)
    {
        for (NSNumber *idNum in self.links)
        {
            linkStr = (linkStr == nil? [NSString stringWithFormat:@"%d", [idNum intValue]] : [linkStr stringByAppendingFormat:@"|%d", [idNum intValue]]);
        }
    }
    else 
    {
        linkStr = @"";
    }
    
    sqlite3_bind_text(statement, 23, [linkStr UTF8String], -1, SQLITE_TRANSIENT);
    
    sqlite3_bind_int(statement, 24, self.timerStatus);
    
    sqlite3_bind_int(statement, 25, self.extraStatus);
    
    sqlite3_bind_int(statement, 26, self.timeZoneId);
    
    sqlite3_bind_int(statement, 27, [self isNormalEvent]?[Common getSecondsFromTimeZoneID:self.timeZoneId]:0);
    
    sqlite3_bind_int(statement, 28, self.locationAlert);
    sqlite3_bind_int(statement, 29, self.locationID);
    sqlite3_bind_int(statement, 30, self.locationAlertID);
    
    sqlite3_bind_text(statement, 31, [self.assigneeEmail UTF8String], -1, SQLITE_TRANSIENT);
    NSTimeInterval assignDateValue = (self.assignDate == nil? -1: [self.assignDate timeIntervalSince1970]);
    sqlite3_bind_double(statement, 32, assignDateValue);
	
	sqlite3_bind_int(statement, 33, self.primaryKey);
	
	////////printf("Update DB - task %s, key: %d, project: %d, group: %d, seq: %d\n", [self.name UTF8String], self.primaryKey, self.project, self.groupKey, self.sequenceNo);
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    //sqlite3_finalize(statement);
	sqlite3_reset(statement);
		
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
	else 
	{
		[self updateAlerts];
	}
}

- (void) updateTimeZoneIDIntoDB:(sqlite3 *)database
{
	//////printf("Update Type - task %s\n", [self.name UTF8String]);
    //@synchronized([DBManager getInstance])
	{
        
        sqlite3_stmt *statement = nil;
        
        if (statement == nil) {
            static char *sql = "UPDATE TaskTable SET Task_TimeZoneID = ?, Task_TimeZoneOffset = ?,  Task_UpdateTime = ? WHERE Task_ID=?";
            
            if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        
        if (!isExternalUpdate)
        {
            self.updateTime = [NSDate date];
        }
        
        isExternalUpdate = NO;
        
        //NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [[Common toDBDate:self.updateTime] timeIntervalSince1970]);
        NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);
        
        sqlite3_bind_int(statement, 1, self.timeZoneId);
        sqlite3_bind_int(statement, 2, [self isNormalEvent]?[Common getSecondsFromTimeZoneID:self.timeZoneId]:0);
        sqlite3_bind_double(statement, 3, updateTimeValue);
        sqlite3_bind_int(statement, 4, self.primaryKey);
        
        int success = sqlite3_step(statement);
        // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
        sqlite3_finalize(statement);
        if (success != SQLITE_DONE) {
            NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
        }
	}
}

- (void) updateSeqNoIntoDB:(sqlite3 *)database
{
	sqlite3_stmt *statement = task_seq_update_statement;
	
    if (statement == nil) {
        static char *sql = "UPDATE TaskTable SET Task_GroupID = ?, Task_SeqNo = ?, Task_UpdateTime = ? WHERE Task_ID = ?";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }

    if (!isExternalUpdate)
	{
		self.updateTime = [NSDate date];
	}
	
	isExternalUpdate = NO;
	
	sqlite3_bind_int(statement, 1, self.groupKey);
	sqlite3_bind_int(statement, 2, self.sequenceNo);

    NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);
	
	sqlite3_bind_double(statement, 3, updateTimeValue);    
    
	sqlite3_bind_int(statement, 4, self.primaryKey);
	
	//////printf("Update Seq No - task %s, key: %d, project: %d, group: %d, seq: %d, merged seq: %d\n", [self.name UTF8String], self.primaryKey, self.project, self.groupKey, self.sequenceNo, self.mergedSeqNo);
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    
	sqlite3_reset(statement);
    
    if (success != SQLITE_DONE)
    {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
}

- (void) updateMergedSeqNoIntoDB:(sqlite3 *)database
{
	sqlite3_stmt *statement = task_merge_seq_update_statement;
	
    if (statement == nil) {
        static char *sql = "UPDATE TaskTable SET Task_GroupID = ?, Task_MergedSeqNo = ? WHERE Task_ID = ?";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	sqlite3_bind_int(statement, 1, self.groupKey);
	sqlite3_bind_int(statement, 2, self.mergedSeqNo);
	sqlite3_bind_int(statement, 3, self.primaryKey);
	
	//////printf("Update Merged Seq No - task %s, key: %d, project: %d, group: %d, seq: %d, merged seq: %d\n", [self.name UTF8String], self.primaryKey, self.project, self.groupKey, self.sequenceNo, self.mergedSeqNo);
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    //sqlite3_finalize(statement);
	sqlite3_reset(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
}

- (void) updateSortOrderIntoDB:(sqlite3 *)database
{
    sqlite3_stmt *statement = task_order_update_statement;
    
    if (statement == nil) {
        static char *sql = "UPDATE TaskTable SET Task_SeqNo = ?, Task_MergedSeqNo = ? WHERE Task_ID = ?";
        
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    
    sqlite3_bind_int(statement, 1, self.sequenceNo);
    sqlite3_bind_int(statement, 2, self.mergedSeqNo);
    sqlite3_bind_int(statement, 3, self.primaryKey);
    
    //////printf("Update Seq No - task %s, key: %d, project: %d, group: %d, seq: %d, merged seq: %d\n", [self.name UTF8String], self.primaryKey, self.project, self.groupKey, self.sequenceNo, self.mergedSeqNo);
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    //sqlite3_finalize(statement);
    sqlite3_reset(statement);
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
    }    
}

- (void) updateDurationIntoDB:(sqlite3 *)database
{
	//////printf("Update Duration - task %s\n", [self.name UTF8String]);
	//@synchronized([DBManager getInstance])
	{
	
	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE TaskTable SET Task_Duration = ?, Task_UpdateTime = ? WHERE Task_ID = ?";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	if (!isExternalUpdate)
	{
		self.updateTime = [NSDate date];
	}
	
	isExternalUpdate = NO;
	
	//NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [[Common toDBDate:self.updateTime] timeIntervalSince1970]);	
	NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);	
	
	sqlite3_bind_double(statement, 1, self.duration);
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

- (void) updateNameIntoDB:(sqlite3 *)database
{
	//////printf("Update Name - task %s\n", [self.name UTF8String]);
    //@synchronized([DBManager getInstance])
	{
	
	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE TaskTable SET Task_Name=?,Task_UpdateTime=? WHERE Task_ID=?";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	if (!isExternalUpdate)
	{
		self.updateTime = [NSDate date];
	}
	
	isExternalUpdate = NO;	
	
	//NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [[Common toDBDate:self.updateTime] timeIntervalSince1970]);	
	NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);	
	
	sqlite3_bind_text(statement, 1, [self.name UTF8String], -1, SQLITE_TRANSIENT);
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

- (void) updateStatusIntoDB:(sqlite3 *)database
{
	//////printf("Update Status - task %s\n", [self.name UTF8String]);
    //@synchronized([DBManager getInstance])
	{
	
	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE TaskTable SET Task_Status=?, Task_CompletionTime=?, Task_UpdateTime=?, Task_MergedSeqNo=? WHERE Task_ID=?";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	if (!isExternalUpdate)
	{
		self.updateTime = [NSDate date];
	}
	
	if (self.status == TASK_STATUS_DONE)
	{
		self.completionTime = [NSDate date];
	}
	else 
	{
		self.completionTime = nil;
	}
	
	isExternalUpdate = NO;	
	
	//NSTimeInterval completionTimeValue = (self.completionTime == nil? -1: [[Common toDBDate:self.completionTime] timeIntervalSince1970]);	
	NSTimeInterval completionTimeValue = (self.completionTime == nil? -1: [self.completionTime timeIntervalSince1970]);	
	
	//NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [[Common toDBDate:self.updateTime] timeIntervalSince1970]);	
	NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);	
	
	sqlite3_bind_int(statement, 1, self.status);
	sqlite3_bind_double(statement, 2, completionTimeValue);
	sqlite3_bind_double(statement, 3, updateTimeValue);
	sqlite3_bind_int(statement, 4, (self.status == TASK_STATUS_DONE || self.status == TASK_STATUS_DELETED)?-1:self.mergedSeqNo);
	sqlite3_bind_int(statement, 5, self.primaryKey);
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
	}
}

- (void) updateTimerStatusIntoDB:(sqlite3 *)database
{
	//////printf("Update Type - task %s\n", [self.name UTF8String]);
    //@synchronized([DBManager getInstance])
	{
        
        sqlite3_stmt *statement = nil;
        
        if (statement == nil) {
            static char *sql = "UPDATE TaskTable SET Task_TimerStatus = ?, Task_UpdateTime = ? WHERE Task_ID=?";
            
            if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        
        if (!isExternalUpdate)
        {
            self.updateTime = [NSDate date];
        }
        
        isExternalUpdate = NO;	
        
        //NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [[Common toDBDate:self.updateTime] timeIntervalSince1970]);	
        NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);		
        
        sqlite3_bind_int(statement, 1, self.timerStatus);
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

- (void) updateTypeIntoDB:(sqlite3 *)database
{
	//////printf("Update Type - task %s\n", [self.name UTF8String]);
    //@synchronized([DBManager getInstance])
	{
	
	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE TaskTable SET Task_Type = ?, Task_UpdateTime = ? WHERE Task_ID=?";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	if (!isExternalUpdate)
	{
		self.updateTime = [NSDate date];
	}
	
	isExternalUpdate = NO;	
	
	//NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [[Common toDBDate:self.updateTime] timeIntervalSince1970]);	
	NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);		
	
	sqlite3_bind_int(statement, 1, self.type);
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

- (void) updateProjectIntoDB:(sqlite3 *)database
{
	//////printf("Update Type - task %s\n", [self.name UTF8String]);
    //@synchronized([DBManager getInstance])
	{
        
        sqlite3_stmt *statement = nil;
        
        if (statement == nil) {
            static char *sql = "UPDATE TaskTable SET Task_ProjectID = ?, Task_UpdateTime = ? WHERE Task_ID=?";
            
            if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        
        if (!isExternalUpdate)
        {
            self.updateTime = [NSDate date];
        }
        
        isExternalUpdate = NO;	
        
        //NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [[Common toDBDate:self.updateTime] timeIntervalSince1970]);	
        NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);		
        
        sqlite3_bind_int(statement, 1, self.project);
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

- (void) updateStartTimeIntoDB:(sqlite3 *)database
{
	//////printf("Update StartTime - task %s\n", [self.name UTF8String]);
    //@synchronized([DBManager getInstance])
	{
	
	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE TaskTable SET Task_StartTime = ?, Task_UpdateTime = ? WHERE Task_ID = ?";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	if (!isExternalUpdate)
	{
		self.updateTime = [NSDate date];
	}
	
	isExternalUpdate = NO;
        
    if ([self isEvent]) {
        self.startTime = [Common convertDate:self.startTime fromTimeZone:[NSTimeZone defaultTimeZone] toTimeZone:[Settings getTimeZoneByID:self.timeZoneId]];
    }
	
	//NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [[Common toDBDate:self.updateTime] timeIntervalSince1970]);			
	NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);
	
	NSTimeInterval startTimeValue = (self.startTime == nil? -1: [[Common toDBDate:self.startTime] timeIntervalSince1970]);
        
//    if ([self isEvent])
//    {
//        NSInteger secs = [Common getSecondsFromTimeZoneID:self.timeZoneId]- [[NSTimeZone defaultTimeZone] secondsFromGMT];
//            
//        startTimeValue += secs;
//    }
	
	sqlite3_bind_double(statement, 1, startTimeValue);
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

- (void) updateEndTimeIntoDB:(sqlite3 *)database
{
	//////printf("Update EndTime - task %s\n", [self.name UTF8String]);
    //@synchronized([DBManager getInstance])
	{
	
	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE TaskTable SET Task_EndTime = ?, Task_UpdateTime = ? WHERE Task_ID = ?";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	if (!isExternalUpdate)
	{
		self.updateTime = [NSDate date];
	}
	
	isExternalUpdate = NO;
        
    if ([self isEvent]) {
        self.endTime = [Common convertDate:self.endTime fromTimeZone:[NSTimeZone defaultTimeZone] toTimeZone:[Settings getTimeZoneByID:self.timeZoneId]];
    }
	
	NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);			
	NSTimeInterval endTimeValue = (self.endTime == nil? -1: [[Common toDBDate:self.endTime] timeIntervalSince1970]);
        
//    if ([self isEvent])
//    {
//        NSInteger secs = [Common getSecondsFromTimeZoneID:self.timeZoneId]- [[NSTimeZone defaultTimeZone] secondsFromGMT];
//            
//        endTimeValue += secs;
//    }
	
	sqlite3_bind_double(statement, 1, endTimeValue);
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

- (void) updateDeadlineIntoDB:(sqlite3 *)database
{
	//////printf("Update Deadline - task %s\n", [self.name UTF8String]);
    //@synchronized([DBManager getInstance])
	{
	
	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE TaskTable SET Task_Deadline = ?, Task_UpdateTime = ? WHERE Task_ID = ?";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	if (!isExternalUpdate)
	{
		self.updateTime = [NSDate date];
	}
	
	isExternalUpdate = NO;	
	
	//NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [[Common toDBDate:self.updateTime] timeIntervalSince1970]);			
	NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);			
	
	NSTimeInterval deadlineValue = (self.deadline == nil? -1: [[Common toDBDate:self.deadline] timeIntervalSince1970]);
	
	sqlite3_bind_double(statement, 1, deadlineValue);
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

- (void) updateTimeIntoDB:(sqlite3 *)database
{
	//////printf("Update Time - task %s\n", [self.name UTF8String]);
//@synchronized([DBManager getInstance])
{
	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE TaskTable SET Task_StartTime = ?, Task_EndTime = ?, Task_Deadline = ?, Task_UpdateTime = ? WHERE Task_ID = ?";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	if (!isExternalUpdate)
	{
		self.updateTime = [NSDate date];
	}
	
	isExternalUpdate = NO;
    
    if ([self isEvent]) {
        self.startTime = [Common convertDate:self.startTime fromTimeZone:[NSTimeZone defaultTimeZone] toTimeZone:[Settings getTimeZoneByID:self.timeZoneId]];
        self.endTime = [Common convertDate:self.endTime fromTimeZone:[NSTimeZone defaultTimeZone] toTimeZone:[Settings getTimeZoneByID:self.timeZoneId]];
    }

	NSTimeInterval startTimeValue = (self.startTime == nil? -1: [[Common toDBDate:self.startTime] timeIntervalSince1970]);
	NSTimeInterval endTimeValue = (self.endTime == nil? -1: [[Common toDBDate:self.endTime] timeIntervalSince1970]);
	NSTimeInterval deadlineValue = (self.deadline == nil? -1: [[Common toDBDate:self.deadline] timeIntervalSince1970]);
	NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);
    
//    if ([self isEvent])
//    {
//        NSInteger secs = [Common getSecondsFromTimeZoneID:self.timeZoneId]- [[NSTimeZone defaultTimeZone] secondsFromGMT];
//        
//        startTimeValue += secs;
//        endTimeValue += secs;
//    }
	
	sqlite3_bind_double(statement, 1, startTimeValue);
	sqlite3_bind_double(statement, 2, endTimeValue);
	sqlite3_bind_double(statement, 3, deadlineValue);
	sqlite3_bind_double(statement, 4, updateTimeValue);
	sqlite3_bind_int(statement, 5, self.primaryKey);
	
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
        static char *sql = "UPDATE TaskTable SET Task_UpdateTime = ? WHERE Task_ID = ?";
		
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
    
    ////printf("update time SQLLite error: %s\n", sqlite3_errmsg(database));
    
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
}

- (void) updateCompletionTimeIntoDB:(sqlite3 *)database
{
	//@synchronized([DBManager getInstance])
	{

	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE TaskTable SET Task_CompletionTime = ?, Task_UpdateTime = ? WHERE Task_ID = ?";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	if (!isExternalUpdate)
	{
		self.updateTime = [NSDate date];
	}
	
	isExternalUpdate = NO;	

	//NSTimeInterval completionTimeValue = (self.completionTime == nil? -1: [[Common toDBDate:self.completionTime] timeIntervalSince1970]);	
	NSTimeInterval completionTimeValue = (self.completionTime == nil? -1: [self.completionTime timeIntervalSince1970]);	
	
	//NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [[Common toDBDate:self.updateTime] timeIntervalSince1970]);
	NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);
	
	sqlite3_bind_double(statement, 1, completionTimeValue);
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


- (void) updateRepeatDataIntoDB:(sqlite3 *)database
{
	//////printf("Update RepeatData - task %s\n", [self.name UTF8String]);
    //@synchronized([DBManager getInstance])
	{
	
	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE TaskTable SET Task_RepeatData = ?, Task_UpdateTime = ? WHERE Task_ID = ?";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	NSString *repeatStr = @"";
	
	if (self.type == TYPE_RE_DELETED_EXCEPTION)
	{
		repeatStr = [RepeatData stringOfRepeatDataForDeletedException:self.repeatData];
	}
	else if (self.groupKey > -1)
	{
		repeatStr = [RepeatData stringOfRepeatDataForException:self.repeatData];
	}
	else
	{
		repeatStr = [RepeatData stringOfRepeatData:self.repeatData];
	}
	
	if (!isExternalUpdate)
	{
		self.updateTime = [NSDate date];
	}
	
	isExternalUpdate = NO;	
	
	//NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [[Common toDBDate:self.updateTime] timeIntervalSince1970]);
	NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);
	
	sqlite3_bind_text(statement, 1, [repeatStr UTF8String], -1, SQLITE_TRANSIENT);	
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
        static char *sql = "UPDATE TaskTable SET Task_Tag = ?, Task_UpdateTime = ? WHERE Task_ID=?";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	if (!isExternalUpdate)
	{
		self.updateTime = [NSDate date];
	}
	
	isExternalUpdate = NO;	
	
	//NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [[Common toDBDate:self.updateTime] timeIntervalSince1970]);
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

- (void) updateSyncIDIntoDB:(sqlite3 *)database
{
	////////printf("Update SyncID - task %s\n", [self.name UTF8String]);
	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        //static char *sql = "UPDATE TaskTable SET Task_SyncID = ?, Task_UpdateTime = ? WHERE Task_ID=?";
		static char *sql = "UPDATE TaskTable SET Task_SyncID = ?,Task_UpdateTime = ? WHERE Task_ID=?";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	if (self.syncId == nil)
	{
		self.syncId = @"";
	}
    
    NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);	
	
	sqlite3_bind_text(statement, 1, [self.syncId UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_double(statement, 2, updateTimeValue);
	sqlite3_bind_int(statement, 3, self.primaryKey);
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
}

- (void) updateSDWIDIntoDB:(sqlite3 *)database
{
	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
		static char *sql = "UPDATE TaskTable SET Task_SDWID = ?,Task_UpdateTime = ? WHERE Task_ID=?";
		
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

- (void) updateLinkIntoDB:(sqlite3 *)database
{
    sqlite3_stmt *statement = nil;
    
    if (statement == nil) {
        static char *sql = "UPDATE TaskTable SET Task_Link = ?, Task_UpdateTime = ? WHERE Task_ID=?";
        
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
    
    
    NSString *linkStr = nil;
    
    if (self.links.count > 0)
    {
        for (NSNumber *idNum in self.links)
        {
            linkStr = (linkStr == nil? [NSString stringWithFormat:@"%d", [idNum intValue]] : [linkStr stringByAppendingFormat:@"|%d", [idNum intValue]]);
        }
    }
    else 
    {
        linkStr = @"";
    }
    
    sqlite3_bind_text(statement, 1, [linkStr UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_double(statement, 2, updateTimeValue);
    sqlite3_bind_int(statement, 3, self.primaryKey);
    
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
    }
}

- (void) updateLocationAlertIntoDB:(sqlite3 *)database
{
	////////printf("Update SyncID - task %s\n", [self.name UTF8String]);
	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        //static char *sql = "UPDATE TaskTable SET Task_SyncID = ?, Task_UpdateTime = ? WHERE Task_ID=?";
		static char *sql = "UPDATE TaskTable SET Task_LocationAlert = ?,Task_UpdateTime = ? WHERE Task_ID=?";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	if (self.syncId == nil)
	{
		self.syncId = @"";
	}
    
    NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);
	
	sqlite3_bind_int(statement, 1, self.locationAlert);
    sqlite3_bind_double(statement, 2, updateTimeValue);
	sqlite3_bind_int(statement, 3, self.primaryKey);
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
}

- (void) refreshSyncIDFromDB:(sqlite3 *)database
{
	//@synchronized([DBManager getInstance])
	{
		sqlite3_stmt *statement = nil;
		
		if (statement == nil) {
			static char *sql = "SELECT Task_SyncID, Task_SDWID FROM TaskTable WHERE Task_ID=?";
			
			if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
				NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			}
		}
		
		sqlite3_bind_int(statement, 1, self.primaryKey);
		
		if (sqlite3_step(statement) == SQLITE_ROW)
		{
			char *str = (char *)sqlite3_column_text(statement, 0);
			self.syncId = (str == NULL? @"":[NSString stringWithUTF8String:str]);						

			str = (char *)sqlite3_column_text(statement, 1);
			self.sdwId = (str == NULL? @"":[NSString stringWithUTF8String:str]);						            
		}
		
		// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
		sqlite3_finalize(statement);
	}
}

- (void)deleteFromDatabase:(sqlite3 *)database 
{
    [[AlertManager getInstance] removeAllAlertsForTask:self];
    [[TaskLinkManager getInstance] deleteAllLinks4Task:self];
    [[DBManager getInstance] deleteAllProgressForTask:self.primaryKey];
    
/*	if ((self.syncId == nil || [self.syncId isEqualToString:@""]) &&
        (self.sdwId == nil || [self.sdwId isEqualToString:@""]))*/
    if ([self checkCleanable])
	{
		[self cleanFromDatabase:database];
		
		return;
	}

	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE TaskTable SET Task_Status=?,Task_UpdateTime=?,Task_MergedSeqNo=-1 WHERE Task_ID=? OR Task_GroupID=?";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	self.status = TASK_STATUS_DELETED;
	
	if (!isExternalUpdate)
	{
		self.updateTime = [NSDate date];
	}
	
	isExternalUpdate = NO;	
	
	NSTimeInterval updateTimeValue = (self.updateTime == nil? -1: [self.updateTime timeIntervalSince1970]);
	
	sqlite3_bind_int(statement, 1, self.status);
	sqlite3_bind_double(statement, 2, updateTimeValue);	
	sqlite3_bind_int(statement, 3, self.primaryKey);
	sqlite3_bind_int(statement, 4, self.primaryKey);
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
}

- (BOOL) checkCleanable
{
    return (self.sdwId == nil || [self.sdwId isEqualToString:@""]) &&
            (self.syncId == nil || [self.syncId isEqualToString:@""]);
}

- (void)cleanFromDatabase:(sqlite3 *)database 
{
	//if (self.primaryKey == -1 || ![self checkCleanable])
    if (self.primaryKey == -1)
	{
		return;
	}
    
    [[DBManager getInstance] deleteAllComments:self.primaryKey];
	
    // Compile the delete statement if needed.
	sqlite3_stmt *statement = nil;
	
//@synchronized([DBManager getInstance])
{
    if (statement == nil) {
        const char *sql = "DELETE FROM TaskTable WHERE Task_ID=? OR Task_GroupID=?";
		//NSString *sql =[NSString stringWithFormat:@"DELETE FROM iVo_Tasks WHERE Task_ID=?",tableName];
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
    // Bind the primary key variable.
    sqlite3_bind_int(statement, 1, self.primaryKey);
	sqlite3_bind_int(statement, 2, self.primaryKey);
    // Execute the query.
    int success = sqlite3_step(statement);

    sqlite3_finalize(statement);
	
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }
}
}

- (void) updateAlerts
{
    DBManager *dbm = [DBManager getInstance];
    
	//BOOL updated = NO;
    
    if (self.primaryKey != -1)
    {
        if (self.alerts != nil && self.alerts.count > 0)
        {
            for (AlertData *alert in self.alerts)
            {
                if (alert.taskKey != self.primaryKey)
                {
                    alert.taskKey = self.primaryKey;
                    [alert insertIntoDB:[dbm getDatabase]];
                    
                    //updated = YES;
                }
                else
                {
                    [alert updateIntoDB:[dbm getDatabase]];
                }
            }
        }
        else
        {
            [dbm deleteAlertsForTask:self.primaryKey];        
        }
    }
    
    if ((self.syncId == nil || [self.syncId isEqualToString:@""]))
	{
		[[AlertManager getInstance] generateAlertsForTask:self];
	}    
}

- (NSString *) alertsToString
{
	NSString *ret = @"";
	
	for (AlertData *alert in self.alerts)
	{
		ret = [ret isEqualToString:@""]? [AlertData stringOfAlertData:alert]:[NSString stringWithFormat:@"%@,%@", ret, [AlertData stringOfAlertData:alert]];
	}
	
	return ret;
}

- (NSString *) getRepeatString
{
	NSString *repeatStr = @"";
	
	if (self.type == TYPE_RE_DELETED_EXCEPTION)
	{
		repeatStr = [RepeatData stringOfRepeatDataForDeletedException:self.repeatData];
	}
	else if (self.groupKey > -1)
	{
		repeatStr = [RepeatData stringOfRepeatDataForException:self.repeatData];
	}
	else
	{
		repeatStr = [RepeatData stringOfRepeatData:self.repeatData];
	}
    
    return repeatStr;
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

-(void) changeProject:(int)key
{
	if (self.project != key)
	{
		self.project = key;

	}
}

- (NSString *) getCombinedTag
{
    NSString *parentTag = [[ProjectManager getInstance] getProjectTagByKey:self.project];
    
    NSString *combinedTag = self.tag;
    
    if (![parentTag isEqualToString:@""])
    {
        combinedTag = [NSString stringWithFormat:@"%@%@", parentTag, [combinedTag isEqualToString:@""]?@"":[NSString stringWithFormat:@",%@",combinedTag]];
    }
    
    return combinedTag;
}

- (NSString *) getDisplayStartTime
{
    NSDate *dt = self.startTime;
    
    if ([self isNormalEvent] && self.timeZoneId != 0 && [[Settings getInstance] timeZoneSupport])
    {
        //NSInteger secs = [Common getSecondsFromTimeZoneID:self.timeZoneId] - [[NSTimeZone defaultTimeZone] secondsFromGMT];
        // sub DST offset
//        NSInteger secs = [[Settings getTimeZoneByID:self.timeZoneId] secondsFromGMT] - [[NSTimeZone defaultTimeZone] secondsFromGMT];
//        
//        dt = [dt dateByAddingTimeInterval:secs];
        dt = [Common convertDate:dt fromTimeZone:[NSTimeZone defaultTimeZone] toTimeZone:[Settings getTimeZoneByID:self.timeZoneId]];
    }
    
    return [self isADE]?[Common getFullDateString3:dt]:[Common getFullDateTimeString:dt];
}

- (NSString *) getDisplayEndTime
{
    NSDate *dt = self.endTime;
    
    if ([self isNormalEvent] && self.timeZoneId != 0 && [[Settings getInstance] timeZoneSupport])
    {
        //NSInteger secs = [Common getSecondsFromTimeZoneID:self.timeZoneId] - [[NSTimeZone defaultTimeZone] secondsFromGMT];
        // sub DST offset
//        NSInteger secs = [[Settings getTimeZoneByID:self.timeZoneId] secondsFromGMT] - [[NSTimeZone defaultTimeZone] secondsFromGMT];
//        
//        dt = [dt dateByAddingTimeInterval:secs];
        dt = [Common convertDate:dt fromTimeZone:[NSTimeZone defaultTimeZone] toTimeZone:[Settings getTimeZoneByID:self.timeZoneId]];
    }
    
    return [self isADE]?[Common getFullDateString3:dt]:[Common getFullDateTimeString:dt];    
}

- (void) print
{
    /*
	NSString *typeStr = @"Task";
	
	if (self.type == TYPE_EVENT)
	{
		typeStr = @"Event";
	}
	else if (self.type == TYPE_ADE)
	{
		typeStr = @"ADE";
	}

	printf("[%s] '%s' - seqNo:%d, merged seqNo:%d, key:%d, project:%d, start: %s - end:%s, deadline:%s, smart:%s, syncId:%s, modified:%s\n", 
		   [typeStr UTF8String], [self.name UTF8String], self.sequenceNo, self.mergedSeqNo, self.primaryKey, 
		   self.project, [[self.startTime description] UTF8String], [[self.endTime description] UTF8String], 
		   [[self.deadline description] UTF8String], [[self.smartTime description] UTF8String], [self.syncId UTF8String], [[self.updateTime description] UTF8String]);
     */
}

#pragma mark Type Check

-(BOOL)isRT
{
	return ([self isTask] && self.repeatData != nil && self.groupKey == -1);	
}

-(BOOL)isRE
{
	return ([self isEvent] && self.repeatData != nil && self.groupKey == -1);	
}

-(BOOL)isRecurring
{
	return (self.repeatData != nil && self.groupKey == -1);	
}

-(BOOL)isNREvent //non-recurring
{
	return (self.type == TYPE_EVENT || self.type == TYPE_ADE) && self.repeatData == nil;
}

-(BOOL)isDTask
{
	return (self.type == TYPE_TASK && self.deadline != nil);
}

-(BOOL)isSTask
{
	return (self.type == TYPE_TASK && self.startTime != nil);
}

-(BOOL)isEvent
{
	return (self.type == TYPE_EVENT || self.type == TYPE_ADE);
}

-(BOOL)isNormalEvent
{
    return (self.type == TYPE_EVENT);
}

-(BOOL)isADE
{
	return self.type == TYPE_ADE;
}

-(BOOL)isTask
{
	//return (self.type == TYPE_TASK);
	return (self.type == TYPE_TASK || self.type == TYPE_SHOPPING_ITEM);
}

-(BOOL)isNote
{
    return self.type == TYPE_NOTE;
}

-(BOOL)isREInstance
{
	return ([self isEvent] && self.primaryKey == -1 && self.original != nil && self.original.repeatData != nil);
}

-(BOOL)isREException
{
    return [self isEvent] && self.primaryKey != -1 && self.original != nil && self.repeatData != nil;
}

-(BOOL)isLong //long event
{
	//return [self isEvent] && ([Common getDay:self.startTime] != [Common getDay:self.endTime]);
    return [self isEvent] && [Common daysBetween:self.endTime sinceDate:self.startTime] > 0;
}

-(BOOL)isPartial //partial task
{
	return ([self isTask] && self.primaryKey == -1 && self.original != nil);
}

-(BOOL)isDone
{
    return self.status == TASK_STATUS_DONE;
}

- (BOOL)isStar
{
    return self.status == TASK_STATUS_PINNED;
}

-(BOOL) isMeetingInvited
{
    return (self.extraStatus & TASK_EXTRA_STATUS_MEETING_INVITED) != 0;
}

-(BOOL) isShared
{
    return (self.extraStatus & (TASK_EXTRA_STATUS_SHARED |
                                TASK_EXTRA_STATUS_ASSIGN_TO_ME | TASK_EXTRA_STATUS_ACCEPTED_BY_ME |
                                TASK_EXTRA_STATUS_ASSIGN_TO_OTHER | TASK_EXTRA_STATUS_ACCEPTED_BY_OTHER
                                | TASK_EXTRA_STATUS_MEETING_INVITED)) != 0;
}

-(BOOL) isAssignedToAssignee
{
    return (self.extraStatus & TASK_EXTRA_STATUS_ASSIGNED_TO_ASSIGNEE) != 0;
}

-(BOOL) isAcceptByAssignee
{
    return (self.extraStatus & (TASK_EXTRA_STATUS_ACCEPTED_BY_ASSIGNEE | TASK_EXTRA_STATUS_ACCEPTED_BY_OTHER)) != 0;
}

- (BOOL) isAssignPending
{
    return (self.extraStatus & (TASK_EXTRA_STATUS_ASSIGN_TO_ME | TASK_EXTRA_STATUS_ASSIGN_TO_OTHER | TASK_EXTRA_STATUS_ASSIGNED_TO_ASSIGNEE)) != 0;
}

- (BOOL)isPendingByMe
{
    return (self.extraStatus & TASK_EXTRA_STATUS_ASSIGN_TO_ME) != 0;
}

-(BOOL) isAcceptedByMe
{
    return (self.extraStatus & TASK_EXTRA_STATUS_ACCEPTED_BY_ME) != 0;
}

-(BOOL) isManual
{
    return (self.extraStatus & TASK_EXTRA_STATUS_ANCHORED) != 0;
}

- (void) setExtraManual:(NSInteger)intValue {
    if (intValue != 0) {
        self.extraStatus |= TASK_EXTRA_STATUS_ANCHORED;
    } else {
        self.extraStatus &= ~TASK_EXTRA_STATUS_ANCHORED;
    }
}

- (void) setManual:(BOOL)enabled
{
    
    if (enabled)
    {
        self.extraStatus |= TASK_EXTRA_STATUS_ANCHORED;
        
        // reset alert based location
        self.locationAlert = LOCATION_NONE;
        self.locationAlertID = 0;
        self.locationID = 0;
    }
    else
    {
        self.extraStatus &= ~TASK_EXTRA_STATUS_ANCHORED;
    }
}

//- (void) setMeetingInvited:(BOOL)enabled
//{
//    if (enabled)
//    {
//        self.extraStatus |= TASK_EXTRA_STATUS_MEETING_INVITED;
//        self.extraStatus &= ~TASK_EXTRA_STATUS_SHARED;
//    }
//    else
//    {
//        self.extraStatus &= ~TASK_EXTRA_STATUS_MEETING_INVITED;
//    }
//}
//
//- (void) setShared:(BOOL)enabled
//{
//    if (enabled)
//    {
//        self.extraStatus |= TASK_EXTRA_STATUS_SHARED;
//    }
//    else
//    {
//        self.extraStatus &= ~TASK_EXTRA_STATUS_SHARED;
//    }
//}
//    
//- (void) setAssignedToAssingnee:(NSInteger)assignStatus
//{
//    /*if (enabled)
//    {
//        self.extraStatus |= TASK_EXTRA_STATUS_ASSIGNED_TO_ASSIGNEE;
//    }
//    else
//    {
//        self.extraStatus &= ~TASK_EXTRA_STATUS_ASSIGNED_TO_ASSIGNEE;
//    }*/
//    if (assignStatus == 0) {
//        self.extraStatus |= TASK_EXTRA_STATUS_ASSIGNED_TO_ASSIGNEE;
//    } else if (assignStatus == 1){
//        self.extraStatus |= TASK_EXTRA_STATUS_ACCEPTED_BY_ASSIGNEE;
//    } else {
//        self.extraStatus &= ~(TASK_EXTRA_STATUS_ASSIGNED_TO_ASSIGNEE | TASK_EXTRA_STATUS_ACCEPTED_BY_ASSIGNEE);
//    }
//}
//
//- (void) setAcceptedByMe:(BOOL)enabled
//{
//    // assignee (this is delegated to me) is accepted
//    if (enabled)
//    {
//        self.extraStatus |= TASK_EXTRA_STATUS_ACCEPTED_BY_ME;
//        //self.extraStatus &= ~TASK_EXTRA_STATUS_SHARED;
//    }
//    else
//    {
//        self.extraStatus &= ~TASK_EXTRA_STATUS_ACCEPTED_BY_ME;
//    }
//}
//
//- (void)setDelegateStatus: (NSInteger) assignStatus andMe:(BOOL) assignToMe
//{
//    if (assignToMe) {
//        self.extraStatus &= ~TASK_EXTRA_STATUS_SHARED;
//        if (assignStatus == 0) {
//            // pending
//            self.extraStatus |= TASK_EXTRA_STATUS_ASSIGN_TO_ME;
//        } else if (assignStatus == 1) {
//            // accepted
//            self.extraStatus |= TASK_EXTRA_STATUS_ACCEPTED_BY_ME;
//        }
//    } else {
//        //self.extraStatus &= ~TASK_EXTRA_STATUS_SHARED;
//        if (assignStatus == 0) {
//            // pending
//            self.extraStatus |= TASK_EXTRA_STATUS_ASSIGN_TO_OTHER;
//        } else if (assignStatus == 1) {
//            // accepted
//            self.extraStatus |= TASK_EXTRA_STATUS_ACCEPTED_BY_OTHER;
//        }
//    }
//}

- (void)setSmartShareStatus:(BOOL)shared meetingInvited:(BOOL)meetingInviteFlag delegateStatus:(NSInteger)delegate
{
    // this method should invoke after this item is set type and assigneeEmail
    
    // reset share status
    self.extraStatus &= ~(TASK_EXTRA_STATUS_SHARED
                          | TASK_EXTRA_STATUS_ASSIGNED_TO_ASSIGNEE
                          | TASK_EXTRA_STATUS_ACCEPTED_BY_ASSIGNEE
                          | TASK_EXTRA_STATUS_ASSIGN_TO_ME
                          | TASK_EXTRA_STATUS_ACCEPTED_BY_ME
                          | TASK_EXTRA_STATUS_ASSIGN_TO_OTHER
                          | TASK_EXTRA_STATUS_ACCEPTED_BY_OTHER);
    
    if (shared) {
        if (meetingInviteFlag && [self isEvent]) {
            //[self setMeetingInvited:meetingInviteFlag];
            self.extraStatus |= TASK_EXTRA_STATUS_MEETING_INVITED;
            
        } else if (![self.assigneeEmail isEqualToString:@""] && [self isTask]) {
            
            Settings *settings = [Settings getInstance];
            NSString *myEmail = [settings.sdwEmail lowercaseString];
            
            if ([myEmail isEqualToString:[self.assigneeEmail lowercaseString]]) {
                if (delegate == 0) {
                    // pending
                    self.extraStatus |= TASK_EXTRA_STATUS_ASSIGN_TO_ME;
                } else {
                    self.extraStatus |= TASK_EXTRA_STATUS_ACCEPTED_BY_ME;
                }
            } else {
                if (delegate == 0) {
                    // pending
                    self.extraStatus |= TASK_EXTRA_STATUS_ASSIGN_TO_OTHER;
                } else {
                    self.extraStatus |= TASK_EXTRA_STATUS_ACCEPTED_BY_OTHER;
                }
            }
        } else {
            self.extraStatus |= TASK_EXTRA_STATUS_SHARED;
        }
    } else {
        if (![self.assigneeEmail isEqualToString:@""]) {
            if (delegate == 0) {
                self.extraStatus |= TASK_EXTRA_STATUS_ASSIGNED_TO_ASSIGNEE;
            } else if (delegate == 1){
                self.extraStatus |= TASK_EXTRA_STATUS_ACCEPTED_BY_ASSIGNEE;
            }
        }
    }
}

-(BOOL)checkMustDo
{
    if ([self isEvent] || self.deadline == nil)
    {
        return NO;
    }

    int mustDoDays = [[Settings getInstance] mustDoDays];
    
    if (mustDoDays <= 0)
    {
        return NO;
    }
    
    NSDate *due = [Common getEndDate:[Common dateByAddNumDay:mustDoDays-1 toDate:[NSDate date]]];
    
    return [Common compareDate:self.deadline withDate:due] != NSOrderedDescending;
}

#pragma mark Repeat String
- (NSString *) getRepeatTypeString
{
	if (self.repeatData != nil && ![self isREException])
	{
		NSString *repeatTypes[4] = {_dailyText, _weeklyText, _monthlyText, _yearlyText};
		
		return repeatTypes[self.repeatData.type - REPEAT_DAILY];
	}
	
	return _noneText;
}

- (NSString *) getRepeatUntilString
{
	if (self.repeatData != nil)
	{
		if ([self isRT]) //RT instance -> not allow to edit Repeat info
		{
			return _foreverText;
		}
		else if (![self isREException])
        {
            if (self.repeatData.until == nil)
            {
                return _foreverText;
            }
            else 
            {
                return [Common getFullDateString3:self.repeatData.until];
            }
        
        }
	}
	
	return _noneText;
}

- (NSString *) getRepeatDisplayString
{
	if (self.repeatData != nil)
	{
        return [NSString stringWithFormat:@"%@ | %@", [self getRepeatTypeString], [self getRepeatUntilString]];
	}
	
	return _noneText;
}
#pragma mark Due String

- (NSString *)getDueString
{
    NSString *dueString = @"";
    if ([self isDTask]) {
        NSDate *today = [NSDate date];
        
        //NSComparisonResult result = [today compare:self.task.deadline];
        NSComparisonResult result = [Common compareDateNoTime:self.deadline withDate:today];
        
        //NSString *dueString = @"";
        if (result == NSOrderedAscending) {
            dueString = _overDueText;
        } else if (result == NSOrderedSame) {
            
            dueString = [_dueText stringByAppendingFormat:@" %@", _todayText];
        } else {
            NSTimeInterval diff = [self.deadline timeIntervalSinceDate:[Common clearTimeForDate:today]];
            NSInteger dueDays = floor(diff/24/3600);
            
            dueString = [NSString stringWithFormat:_dueInDaysTex, dueDays];
        }
    }
    return dueString;
}

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements {
    if (task_init_statement) sqlite3_finalize(task_init_statement);
    if (task_insert_statement) sqlite3_finalize(task_insert_statement);
    if (task_update_statement) sqlite3_finalize(task_update_statement);
	if (task_order_update_statement) sqlite3_finalize(task_order_update_statement);
    if (task_seq_update_statement) sqlite3_finalize(task_seq_update_statement);
	if (task_merge_seq_update_statement) sqlite3_finalize(task_merge_seq_update_statement);
	if (task_delete_statement) sqlite3_finalize(task_delete_statement);
	
	task_init_statement = nil;
	task_insert_statement = nil;
	task_update_statement = nil;
	task_order_update_statement = nil;
	task_seq_update_statement = nil;
	task_delete_statement = nil;
	
}

#pragma mark Properties

- (void)setType:(NSInteger)_type {
    if ([self isEvent] && [self isManual] && _type != TYPE_EVENT) {
        self.extraStatus &= ~TASK_EXTRA_STATUS_ANCHORED;
    }
    type = _type;
}
@end
