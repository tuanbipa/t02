//
//  Task.m
//  iVo_DatabaseAccess
//
//  Created by Nang Le on 4/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SPadTask.h"
#import "Setting.h"
#import "MigrationData.h"
#import "Calendar.h"
#import "Utilities.h"

extern MigrationData *coreData;
extern BOOL isAddingToDB;
extern BOOL isUpdatingDB;
extern BOOL	isSyncing;
extern BOOL     isLockingDB;

static sqlite3_stmt *insert_statement = nil;
static sqlite3_stmt *init_statement = nil;
static sqlite3_stmt *delete_statement = nil;
//static sqlite3_stmt *hydrate_statement = nil;
static sqlite3_stmt *update_statement = nil;

static sqlite3_stmt *insert_dummy_statement = nil;
static sqlite3_stmt *init_dummy_statement = nil;
static sqlite3_stmt *delete_dummy_statement = nil;
//static sqlite3_stmt *hydrate_statement = nil;
static sqlite3_stmt *update_dummy_statement = nil;

extern sqlite3 *database;
extern double gmtSeconds;

extern NSTimeZone	*App_defaultTimeZone;
extern BOOL				isDayLigtSavingTime;
extern NSTimeInterval	dstOffset;
 

@implementation SPadTask

@synthesize isDeletedFromGCal;
@synthesize originalPKey;
@synthesize overlapIndex;
@synthesize totalOverlap;
@synthesize showInDayOfWeek;
@synthesize originalHyperNoteString;
@synthesize isTopGTDTask;
@synthesize isFromSyncing;
@synthesize isDisplaying;
@synthesize toodledoHasStart;
@synthesize reInstances;
@synthesize hasUsed;
@synthesize isMyselfException;
@synthesize migrateID;

-(id)init{
	self=[super init];
	
	self.primaryKey=-1;
    
    
	//general
	self.taskType=0;
	self.isADE=0;
	self.taskName=@"";
	self.taskLocation=@"";
    self.notes=@"";
	self.isFromSyncing=NO;
	
	//logic
	self.createdDate=[NSDate date];
	self.startTime=[NSDate date];
	self.endTime=[self.startTime dateByAddingTimeInterval:3600];
	self.dueStart=[NSDate date];
	self.dueEnd = [[NSDate date] dateByAddingTimeInterval:7*86400];
	self.dateUpdate=[NSDate date];
	self.startWindow=self.dueStart;
	self.endWindow=[[NSDate date] addTimeInterval:93312000];
	self.completedDate=nil;
	self.hasDue=0;
	self.taskOrder=0;
	
	//repeat
	self.repeatType=0;
	self.repeatStartDate=[NSDate date];
	self.repeatEndDate=[NSDate date];
	self.repeatOptions=@"1//0";
	self.repeatExceptions=@"";
	self.isRepeatForever=1;
	
	//Detail
	self.status=0;
	self.whatId=-1;
	self.whoId=-1;
	self.contextId=1;
	self.originalContextId=-1;
	self.hasDuration=1;
	self.parentId=-1;
	self.updateType=0;
	self.isInitialTask=0;
	self.isPinned=NO;
	self.doingStatus=0;
	self.doingLogs=@"";
	self.currentStartTime=[NSDate date];
	self.originalExceptionDate=nil;
	self.alertValues=@"";
	
	//hyperNote use
	self.hyperNoteId=0;
	
	//toodledo syncing
	self.toodledoID=0;
	
	//Gcal sync
	self.gcalSynKey=0;
	self.gcalEventId=@"";
	
	self.totalOverlap=1;
	self.overlapIndex=0;
	self.taskRepeatStyle=0;
    
	self.hiddenFromTaskView=0;
	self.hasUsed=NO;
    
    self.toodledoHasStart=NO;
	//local use
	//self.loadedDummiesFromDate=[NSDate date];
	//self.loadedDummiesToDate=[NSDate date];
	
    self.isMyselfException=NO;
    
	return self;
}

-(id)initWithLessInfo{
    self=[super init];
    if (self) {
        self.startTime=[NSDate date];
        self.endTime=[self.startTime dateByAddingTimeInterval:3600];
        self.createdDate=[NSDate date];
        self.dueStart=[NSDate date];
        self.isRepeatForever=1;
        self.dueEnd = [[NSDate date] dateByAddingTimeInterval:7*86400];
        self.startWindow=self.dueStart;
        self.endWindow=[[NSDate date] addTimeInterval:93312000];
        self.toodledoHasStart=NO;
    }
    
    return self;
}

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements {
    
	if (insert_statement) sqlite3_finalize(insert_statement);
    if (init_statement) sqlite3_finalize(init_statement);
    if (delete_statement) sqlite3_finalize(delete_statement);
    if (update_statement) sqlite3_finalize(update_statement);
	
	if (insert_dummy_statement) sqlite3_finalize(insert_dummy_statement);
    if (init_dummy_statement) sqlite3_finalize(init_dummy_statement);
    if (delete_dummy_statement) sqlite3_finalize(delete_dummy_statement);
    if (update_dummy_statement) sqlite3_finalize(update_dummy_statement);
	
}

// Creates the task object with primary key and name, description is brought into memory.
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db{
	if (self = [super init]) {
        while (isLockingDB) {
            usleep(110);
        }
        isLockingDB=YES;

        self.primaryKey = pk;
        // Compile the query for retrieving book data.
        if (init_statement == nil) {
            // Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
            // This is a great way to optimize because frequently used queries can be compiled once, then with each
            // use new variable values can be bound to placeholders.
            const char *sql = "SELECT \
			taskType,\
			isADE,\
			taskName,\
			taskLocation,\
			notes,\
			createdDate,\
			startTime,\
			endTime,\
			dueStart,\
			dueEnd,\
			dateUpdate,\
			startWindow,\
			endWindow,\
			completedDate,\
			hasDue,\
			taskOrder,\
			repeatType,\
			repeatStartDate,\
			repeatEndDate,\
			repeatOptions,\
			repeatExceptions,\
			isRepeatForever,\
			status,\
			whatId,\
			whoId,\
			contextId,\
			originalContextId,\
			duration,\
			calendarId,\
			parentId,\
			updateType,\
			isInitialTask,\
			specifiedAlertTime,\
			alertValues,\
			PNSKey,\
			hyperNoteId,\
			toodledoID,\
			hasDuration,\
			contactName,\
			isPinned,\
			doingStatus,\
			doingLogs,\
			currentStartTime,\
			gcalSynKey,\
			gcalEventId,\
			originalExceptionDate,\
			iCalIdentifier,\
			iCalCalendarName,\
			builtIn,\
			hiddenFromTaskView,\
			isHidden,\
			isList,\
			gtdOrder,\
            taskRepeatStyle,\
            SDWIdentifer \
			FROM Tasks WHERE primaryKey=?";
			
            if (sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // For this query, we bind the primary key to the first (and only) placeholder in the statement.
        // Note that the parameters are numbered from 1, not from 0.
        sqlite3_bind_int(init_statement, 1, self.primaryKey);
        if (sqlite3_step(init_statement) == SQLITE_ROW) {
			//for debugging
			////printf("\n catname: %s, catDescr: %s",sqlite3_column_text(init_statement, 0),sqlite3_column_text(init_statement, 1));
            //------------
			//NSDate *date=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 17)-gmtSeconds];
			//NSTimeInterval adjustTimeVal=-gmtSeconds -[App_defaultTimeZone daylightSavingTimeOffsetForDate:date]+[App_defaultTimeZone daylightSavingTimeOffset];
			//NSTimeInterval adjustTimeVal=-gmtSeconds;
			
			NSDate *date=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 6)-gmtSeconds];
			NSTimeInterval adjustTimeVal=-gmtSeconds -[App_defaultTimeZone daylightSavingTimeOffsetForDate:date]+[App_defaultTimeZone daylightSavingTimeOffset];
            
			self.taskType=sqlite3_column_int(init_statement, 0);
			self.isADE=sqlite3_column_int(init_statement, 1);
			
			char *taskNme=(char *)sqlite3_column_text(init_statement, 2);
			self.taskName =(taskNme)? [NSString stringWithUTF8String:taskNme] : @"";
            
			char *taskLoc=(char *)sqlite3_column_text(init_statement, 3);
			self.taskLocation = (taskLoc)? [NSString stringWithUTF8String:taskLoc] : @"";
            
			char *taskDesr=(char *)sqlite3_column_text(init_statement, 4);
			self.notes=(taskDesr)? [NSString stringWithUTF8String:taskDesr] :  @"" ;
			
			//For logic
			self.createdDate=[NSDate dateWithTimeIntervalSince1970:(sqlite3_column_double(init_statement, 5) + adjustTimeVal)]; 
			self.startTime=[NSDate dateWithTimeIntervalSince1970:(sqlite3_column_double(init_statement, 6)+ adjustTimeVal)]; 
			self.endTime=[NSDate dateWithTimeIntervalSince1970:(sqlite3_column_double(init_statement, 7)+ adjustTimeVal)]; 
			self.dueStart=[NSDate dateWithTimeIntervalSince1970:(sqlite3_column_double(init_statement, 8)+ adjustTimeVal)]; 
			self.dueEnd=[NSDate dateWithTimeIntervalSince1970:(sqlite3_column_double(init_statement, 9)+ adjustTimeVal)]; 
			self.dateUpdate=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 10)]; //[[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 17)] addTimeInterval:+ adjustTimeVal];
            
			self.startWindow=[NSDate dateWithTimeIntervalSince1970:(sqlite3_column_double(init_statement, 11)+ adjustTimeVal)]; 
			self.endWindow=[NSDate dateWithTimeIntervalSince1970:(sqlite3_column_double(init_statement, 12)+ adjustTimeVal)]; 
            
			self.completedDate=[NSDate dateWithTimeIntervalSince1970:(sqlite3_column_double(init_statement, 13)+ adjustTimeVal)]; 
			self.hasDue=sqlite3_column_int(init_statement, 14);
			self.taskOrder=sqlite3_column_int(init_statement, 15);
			
			//repeat information
			self.repeatType=sqlite3_column_int(init_statement, 16);
			self.repeatStartDate=[NSDate dateWithTimeIntervalSince1970:(sqlite3_column_double(init_statement, 17)+ adjustTimeVal)]; 
			self.repeatEndDate=[NSDate dateWithTimeIntervalSince1970:(sqlite3_column_double(init_statement, 18)+ adjustTimeVal)]; 
			
			char *repeatOpt=(char *)sqlite3_column_text(init_statement, 19);
			self.repeatOptions =(repeatOpt)? [NSString stringWithUTF8String:repeatOpt] : @"";
            
			char *repeatExp=(char *)sqlite3_column_text(init_statement, 20);
			self.repeatExceptions =(repeatExp)? [NSString stringWithUTF8String:repeatExp] : @"";
            
			self.isRepeatForever=sqlite3_column_int(init_statement, 21);
			
			//detail
			self.status=sqlite3_column_int(init_statement, 22);
			self.whatId=sqlite3_column_int(init_statement, 23);
			self.whoId=sqlite3_column_int(init_statement, 24);
			self.contextId=sqlite3_column_int(init_statement, 25);
			self.originalContextId=sqlite3_column_int(init_statement, 26);
			self.duration=sqlite3_column_int(init_statement, 27);
			self.calendarId=sqlite3_column_int(init_statement, 28);
			self.parentId=sqlite3_column_int(init_statement, 29);
			self.updateType=sqlite3_column_int(init_statement, 30);
			self.isInitialTask=sqlite3_column_int(init_statement, 31);
			
			//for alerts
			self.specifiedAlertTime=[NSDate dateWithTimeIntervalSince1970:(sqlite3_column_double(init_statement, 32)+ adjustTimeVal)]; 
			
			char *alertValue=(char *)sqlite3_column_text(init_statement, 33);
			self.alertValues =(alertValue)? [NSString stringWithUTF8String:alertValue] : @"";
            
			char *pnsKey=(char *)sqlite3_column_text(init_statement, 34);
			self.PNSKey =(pnsKey)? [NSString stringWithUTF8String:pnsKey] : @"";
			
			//HyperNotes 
			self.hyperNoteId=sqlite3_column_int(init_statement, 35);
			
			//toodledoID
			self.toodledoID=sqlite3_column_int(init_statement, 36);
			self.hasDuration=sqlite3_column_int(init_statement, 37);
			
			//contactName
			char *whoname=(char *)sqlite3_column_text(init_statement, 38);
			self.contactName =(whoname)? [NSString stringWithUTF8String:whoname] : @"";
            
			self.isPinned=sqlite3_column_int(init_statement, 39);
			
			self.doingStatus=sqlite3_column_int(init_statement, 40);
			
			char *log=(char *)sqlite3_column_text(init_statement, 41);
			self.doingLogs=(log)? [NSString stringWithUTF8String:log] : @"";
			self.currentStartTime=[NSDate dateWithTimeIntervalSince1970:(sqlite3_column_double(init_statement, 42)+ adjustTimeVal)];
			self.gcalSynKey=sqlite3_column_double(init_statement, 43);
			
			//gcalEventId
			char *gcalid=(char *)sqlite3_column_text(init_statement, 44);
			self.gcalEventId=(gcalid)? [NSString stringWithUTF8String:gcalid] : @"";
            
			self.originalExceptionDate=[NSDate dateWithTimeIntervalSince1970:(sqlite3_column_double(init_statement, 45)+ adjustTimeVal)];
			
			//iCalIdentifier
			char *icalid=(char *)sqlite3_column_text(init_statement, 46);
			self.iCalIdentifier=(icalid)? [NSString stringWithUTF8String:icalid] : @"";
            
			//iCalCalendarName
			char *icalname=(char *)sqlite3_column_text(init_statement, 47);
			self.iCalCalendarName=(icalname)? [NSString stringWithUTF8String:icalname] : @"";
			
			self.builtIn=sqlite3_column_int(init_statement, 48);
			self.hiddenFromTaskView=sqlite3_column_int(init_statement, 49);
			self.isHidden=sqlite3_column_int(init_statement, 50);
			
			self.isList=sqlite3_column_int(init_statement, 51);
			self.gtdOrder=sqlite3_column_int(init_statement, 52);
            self.taskRepeatStyle=sqlite3_column_int(init_statement, 53);
            
            //SDWIdentifer
            self.SDWIdentifer=sqlite3_column_int(init_statement, 54);
		}
        
		// Reset the statement for future reuse.
        sqlite3_reset(init_statement);
        dirty = NO;
        		
        isLockingDB=NO;

		//for debugging
		////printf("\n catname: %s, catDescr: %s, date: %s",[self.taskName UTF8String],[self.notes UTF8String],[[self.startTime description] UTF8String]);
		//------------
	}
    
	return self;
}

- (void)dealloc {
	//general info
    [taskName release];
	[taskLocation release];
    [notes release];
    
	//logic
	[createdDate release];
    [startTime release];
	[endTime release];
	[dueStart release];
	[dueEnd release];
	[dateUpdate release];
	[startWindow release];
	[endWindow release];
	[completedDate release];
	[contactName release];
	[doingLogs release];
	[currentStartTime release];
	
	//repeat information
	[repeatStartDate release];
	[repeatEndDate release];
	[repeatOptions release];
	[repeatExceptions release];
	
	[gcalEventId release];
	[originalExceptionDate release];
	
	//alerts
	[alertValues release];
	[specifiedAlertTime release];
	[PNSKey release];
	
	[iCalIdentifier release];
	[iCalCalendarName release];
	
    if (reInstances) {
        [reInstances release];
    }
    
	[super dealloc];
}


int busyHandler(void *pArg1, int iPriorCalls)
{
    // sleep if handler has been called less than threshold value
    if (iPriorCalls < 20)
    {
        // adding a random value here greatly reduces locking
        if (pArg1 < 0)
            usleep((rand() % 500000) + 400000);
        else usleep(500000);
        return 1;
    }
    
    // have sqlite3_exec immediately return SQLITE_BUSY
    return 0;
}


-(void)copyContentOfTask:(SPadTask *)task{
		
	//general 6
	self.primaryKey=task.primaryKey;
	self.taskType=task.taskType;
	self.isADE=task.isADE;
	self.taskName=task.taskName;
	self.taskLocation=task.taskLocation;
	self.notes=task.notes;
	
	//logic 10
	self.createdDate=task.createdDate;
	self.startTime=task.startTime;
	self.endTime=task.endTime;
	self.dueStart=task.dueStart;
	self.dueEnd=task.dueEnd;
	self.dateUpdate=task.dateUpdate;
	self.startWindow=task.startWindow;
	self.completedDate=task.completedDate;
	self.hasDue=task.hasDue;
	self.taskOrder=task.taskOrder;
	
	//repeat 6
	self.repeatType=task.repeatType;
	self.repeatStartDate=task.repeatStartDate;
	self.repeatEndDate=task.repeatEndDate;
	self.repeatOptions=task.repeatOptions;
	self.repeatExceptions=task.repeatExceptions;
	self.isRepeatForever=task.isRepeatForever;
	
	//detail 13
	self.status=task.status;
	self.whatId=task.whatId;
	self.whoId=task.whoId;
	self.contextId=task.contextId;
	self.originalContextId=task.originalContextId;
	self.duration=task.duration;
	self.hasDuration=task.hasDuration;
	self.calendarId=task.calendarId;
	self.parentId=task.parentId;
	self.updateType=task.updateType;
	self.isInitialTask=task.isInitialTask;
	self.contactName=task.contactName;
	self.isPinned=task.isPinned;
	
	//alerts 3
	self.specifiedAlertTime=task.specifiedAlertTime;
	self.alertValues=task.alertValues;
	self.PNSKey=task.PNSKey;
	
	//hyperNotes 1
	self.hyperNoteId=task.hyperNoteId;
	
	//local 1
	self.isDeletedFromGCal=task.isDeletedFromGCal;
	
	//toodledoID 1
	self.toodledoID=task.toodledoID;
	
	//Gcal uses  17
	self.gcalSynKey=task.gcalSynKey;
	self.gcalEventId=task.gcalEventId;
	self.originalExceptionDate=task.originalExceptionDate;
	self.hasDuration=task.hasDuration;
	self.doingStatus=task.doingStatus;
    //	self.isUsedExternalUpdateTime=task.isUsedExternalUpdateTime;
	self.originalPKey=task.originalPKey;
	self.overlapIndex=task.overlapIndex;
	self.totalOverlap=task.totalOverlap;
	self.showInDayOfWeek=task.showInDayOfWeek;
	
	self.doingLogs=task.doingLogs;
	self.currentStartTime=task.currentStartTime;
	self.isDeletedFromGCal=task.isDeletedFromGCal;
	self.originalHyperNoteString=task.originalHyperNoteString;
	
	self.iCalIdentifier=task.iCalIdentifier;
	self.iCalCalendarName=task.iCalCalendarName;
	self.builtIn=task.builtIn;
	self.hiddenFromTaskView=task.hiddenFromTaskView;
	self.isHidden=task.isHidden;
	self.isList=task.isList;
	self.gtdOrder=task.gtdOrder;
	self.taskRepeatStyle=task.taskRepeatStyle;
    self.SDWIdentifer=task.SDWIdentifer;
    
	//self.loadedDummiesFromDate=task.loadedDummiesFromDate;
	//self.loadedDummiesToDate=task.loadedDummiesToDate;
	//self.loadedDummiesDates=[NSMutableArray arrayWithArray:task.loadedDummiesDates];
	
}

#pragma mark Properties
// Accessors implemented below. All the "get" accessors simply return the value directly, with no additional
// logic or steps for synchronization. The "set" accessors attempt to verify that the new value is definitely
// different from the old value, to minimize the amount of work done. Any "set" which actually results in changing
// data will mark the object as "dirty" - i.e., possessing data that has not been written to the database.
// All the "set" accessors copy data, rather than retain it. This is common for value objects - strings, numbers, 
// dates, data buffers, etc. This ensures that subsequent changes to either the original or the copy don't violate 
// the encapsulation of the owning object.

//primarykey property
- (NSInteger)primaryKey {
    return primaryKey;
}

-(void)setPrimaryKey:(NSInteger)num{
	//if (primaryKey==num) return;
	dirty=YES;
	primaryKey=num;
}

//taskType property
-(NSInteger)taskType{
	return taskType;	
}

-(void)setTaskType:(NSInteger)TID{
	if(taskType==TID) return;
	dirty=YES;
	taskType=TID;
	
	if (self.primaryKey==-1) {
		if (TID==0) {
			//self.duration=coreData.currentSetting.durationDefTaskVal;
		}else {
			//self.duration=coreData.currentSetting.durationDefEventVal;
			self.endTime=[[Utilities newDateFromDate:self.startTime offset:self.duration*60] autorelease];
		}
	}
}

//isADE
-(NSInteger)isADE{
	return isADE;	
}

-(void)setIsADE:(NSInteger)anum{
	if(isADE==anum) return;
	dirty=YES;
	isADE=anum;
}

//taskName property
- (NSString *)taskName {
    return taskName;
}

- (void)setTaskName:(NSString *)aString {
    if ((!taskName && !aString) || (taskName && aString && [taskName isEqualToString:aString])) return;
    dirty = YES;
    [taskName release];
    taskName = [aString copy];
}

//taskLocation property
- (NSString *)taskLocation {
    return taskLocation;
}

- (void)setTaskLocation:(NSString *)aString {
    if ((!taskLocation && !aString) || (taskLocation && aString && [taskLocation isEqualToString:aString])) return;
    dirty = YES;
    [taskLocation release];
    taskLocation = [[aString stringByReplacingOccurrencesOfString:@"\n" withString:@", "] copy];
}

//notes property
- (NSString *)notes {
    return notes;
}

- (void)setNotes:(NSString *)aString {
    if ((!notes && !aString) || (notes && aString && [notes isEqualToString:aString])) return;
    dirty = YES;
    [notes release];
    notes = [aString copy];
}

//createdDate
- (NSDate *)createdDate{
	return createdDate;
}

- (void)setCreatedDate:(NSDate *)aDate{
	if ([createdDate isEqualToDate:aDate]) return;
	dirty=YES;
	
	[createdDate release];
	createdDate=[aDate copy];
}

//startTime property
- (NSDate *)startTime{
	return startTime;
}

- (void)setStartTime:(NSDate *)aDate{
	if ([startTime isEqualToDate:aDate]) return;
	dirty=YES;
	
	[startTime release];
	
	NSInteger dateSecond=[Utilities getSecond:aDate];
	startTime=[[[Utilities newDateFromDate:aDate  offset:-dateSecond] autorelease] copy];	
    
	if(self.repeatStartDate ==nil || [Utilities getYear:startTime]==1970){
		self.repeatStartDate=startTime;
	}
	
	if(taskType==1){
		NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
		unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;//|NSWeekdayCalendarUnit|NSWeekdayOrdinalCalendarUnit;
		NSDateComponents *comps = [gregorian components:unitFlags fromDate:aDate];
		[comps setHour:[Utilities getHour:aDate]];//task does not use due start, just for event use
		[comps setMinute:[Utilities getMinute:aDate]];
		[comps setSecond:[Utilities getSecond:aDate]];
		
		self.repeatStartDate=[gregorian dateFromComponents:comps];
	}
	
}

//endTime property
- (NSDate *)endTime{
	return endTime;
}

- (void)setEndTime:(NSDate *)aDate{
	if ([endTime isEqualToDate:aDate]) return;
	dirty=YES;
	
	[endTime release];
	NSInteger dateSecond=[Utilities getSecond:aDate];
	
	//for compatible with previous version
	if (self.isADE && [Utilities getHour:aDate]==0){
		endTime=[[[Utilities newDateFromDate:aDate offset:-1] autorelease] copy];
	}else {
		endTime=[[[Utilities newDateFromDate:aDate  offset:-dateSecond] autorelease] copy];
	}
	
	if (self.taskType==1) {
		NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
		unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;//|NSWeekdayCalendarUnit|NSWeekdayOrdinalCalendarUnit;
		NSDateComponents *comps = [gregorian components:unitFlags fromDate:self.repeatEndDate];
		[comps setHour:[Utilities getHour:aDate]];
		[comps setMinute:[Utilities getMinute:aDate]];
		[comps setSecond:[Utilities getSecond:aDate]];
		
		self.repeatEndDate=[gregorian dateFromComponents:comps];
	}
}

//dueStart property
- (NSDate *)dueStart{
	return dueStart;
}

- (void)setDueStart:(NSDate *)aDate{
	if ([dueStart isEqualToDate:aDate]) return;
	dirty=YES;
    
	[dueStart release];
	dueStart=[aDate copy];
	
	if (self.taskType==0 ) {
		NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
		unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;//|NSWeekdayCalendarUnit|NSWeekdayOrdinalCalendarUnit;
		NSDateComponents *comps = [gregorian components:unitFlags fromDate:self.repeatEndDate];
		[comps setHour:[Utilities getHour:aDate]];
		[comps setMinute:[Utilities getMinute:aDate]];
		[comps setSecond:[Utilities getSecond:aDate]];
		
		self.repeatStartDate=[gregorian dateFromComponents:comps];
	}
	
}

//dueEnd property
- (NSDate *)dueEnd{
	return dueEnd;
}

- (void)setDueEnd:(NSDate *)aDate{
	if ([dueEnd isEqualToDate:aDate]) return;
	dirty=YES;
    
	[dueEnd release];
	dueEnd=[aDate copy];
    
	if(taskType==0){
		NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
		unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;//|NSWeekdayCalendarUnit|NSWeekdayOrdinalCalendarUnit;
		NSDateComponents *comps = [gregorian components:unitFlags fromDate:self.repeatStartDate];
		[comps setHour:[Utilities getHour:aDate]];
		[comps setMinute:[Utilities getMinute:aDate]];
		[comps setSecond:[Utilities getSecond:aDate]];
		
		self.repeatStartDate=[gregorian dateFromComponents:comps];
	}
	
}

//dateUpdate property
- (NSDate *)dateUpdate{
	return dateUpdate;
}

- (void)setDateUpdate:(NSDate *)aDate{
	if ([dateUpdate isEqualToDate:aDate]) return;
	dirty=YES;
	
	[dateUpdate release];
	dateUpdate=[aDate copy];
}

//startWindow property
- (NSDate *)startWindow{
	return startWindow;
}

- (void)setStartWindow:(NSDate *)aDate{
	if ([startWindow isEqualToDate:aDate]) return;
	dirty=YES;
	
	[startWindow release];
	startWindow=[aDate copy];
}

//endWindow property
- (NSDate *)endWindow{
	return endWindow;
}

- (void)setEndWindow:(NSDate *)aDate{
	if ([endWindow isEqualToDate:aDate]) return;
	dirty=YES;
	
	[endWindow release];
	endWindow=[aDate copy];
}

//completedDate property
- (NSDate *)completedDate{
	return completedDate;
}

- (void)setCompletedDate:(NSDate *)aDate{
	if ([completedDate isEqualToDate:aDate]) return;
	dirty=YES;
	
	[completedDate release];
	completedDate=[aDate copy];
}

//hasDue property
-(NSInteger)hasDue{
	return hasDue;
}

-(void)setHasDue: (NSInteger)pinned {
	if (hasDue==pinned) return;
	dirty=YES;
	hasDue=pinned;
}

//hasDue property
-(NSInteger)taskOrder{
	return taskOrder;
}

-(void)setTaskOrder: (NSInteger)anum {
	if (taskOrder==anum) return;
	dirty=YES;
	taskOrder=anum;
}

//repeatType property
-(NSInteger)repeatType{
	return repeatType;
}

-(void)setRepeatType: (NSInteger)anum {
	if (repeatType==anum) return;
	dirty=YES;
	repeatType=anum;
    
    if (repeatType==0) {
        if (reInstances) {
            [reInstances release];
            reInstances=nil;
        }
    }else{
        if (!reInstances) {
            reInstances=[[NSMutableArray alloc] init];
        }
    }
}

//repeatStartDate property
-(NSDate *)repeatStartDate{
	return repeatStartDate;	
}

- (void)setRepeatStartDate:(NSDate *)aDate{
	if([repeatStartDate isEqualToDate:aDate]) return;
	dirty=YES;
	[repeatStartDate release];
	//NSInteger dateSecond=[Utilities getSecond:aDate];
	//repeatStartDate=[[aDate addTimeInterval:-dateSecond] copy];
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;//|NSWeekdayCalendarUnit|NSWeekdayOrdinalCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:aDate];
	[comps setHour:[Utilities getHour:taskType==0?self.dueEnd:self.startTime]];//task does not use due start, just for event use
	[comps setMinute:[Utilities getMinute:taskType==0?self.dueEnd:self.startTime]];
	[comps setSecond:[Utilities getSecond:taskType==0?self.dueEnd:self.startTime]];
	
	repeatStartDate=[[gregorian dateFromComponents:comps] copy];
}

//repeatEndDate property
-(NSDate *)repeatEndDate{
	return repeatEndDate;	
}

- (void)setRepeatEndDate:(NSDate *)aDate{
	if([repeatEndDate isEqualToDate:aDate]) return;
	dirty=YES;
	[repeatEndDate release];
    //	NSInteger dateSecond=[Utilities getSecond:aDate];
    //	repeatEndDate=[[aDate addTimeInterval:-dateSecond] copy];
	
    /*
	NSCalendar *gregorian = [NSCalendar autoUpdating];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;//|NSWeekdayCalendarUnit|NSWeekdayOrdinalCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:aDate];
	[comps setHour:[Utilities getHour:self.taskType==0? self.dueEnd:self.endTime]];
	[comps setMinute:[Utilities getMinute:self.taskType==0? self.dueEnd:self.endTime]];
	[comps setSecond:[Utilities getSecond:self.taskType==0? self.dueEnd:self.endTime]];
	
	repeatEndDate=[[gregorian dateFromComponents:comps] copy];
     */
    repeatEndDate=[aDate copy];
	
}

//repeatOptions property
- (NSString *)repeatOptions {
    return repeatOptions;
}

- (void)setRepeatOptions:(NSString *)aString {
    if ((!repeatOptions && !aString) || (repeatOptions && aString && [repeatOptions isEqualToString:aString])) return;
    dirty = YES;
    [repeatOptions release];
    repeatOptions = [aString copy];
}

//repeatOptions property
- (NSString *)repeatExceptions{
    return repeatExceptions;
}

- (void)setRepeatExceptions:(NSString *)aString {
    if ((!repeatExceptions && !aString) || (repeatExceptions && aString && [repeatExceptions isEqualToString:aString])) return;
    dirty = YES;
    [repeatExceptions release];
    repeatExceptions = [aString copy];
}

//isRepeatForever property
-(NSInteger)isRepeatForever{
	return isRepeatForever;	
}

- (void)setIsRepeatForever:(NSInteger)anum{
	if (isRepeatForever==anum) return;
	dirty=YES;
	isRepeatForever=anum;
}

//status property
-(NSInteger)status{
	return status;	
}

- (void)setStatus:(NSInteger)anum{
	if (status==anum) return;
	dirty=YES;
	status=anum;
}

//whatId property
- (NSInteger)whatId{
	return whatId;	
}

- (void)setWhatId:(NSInteger)anum{
	if (whatId==anum) return;
	dirty=YES;
	whatId=anum;
}

//whoId property
- (NSInteger)whoId{
	return whoId;	
}

- (void)setWhoId:(NSInteger)anum{
	if (whoId==anum) return;
	dirty=YES;
	whoId=anum;
}

//contextId property
- (NSInteger)contextId{
	return contextId;	
}

- (void)setContextId:(NSInteger)anum{
	if (contextId==anum) return;
	dirty=YES;
	contextId=anum;
}

//originalContextId property
- (NSInteger)originalContextId{
	return originalContextId;	
}

- (void)setOriginalContextId:(NSInteger)anum{
	if (originalContextId==anum) return;
	dirty=YES;
	originalContextId=anum;
}

//duration property
- (NSInteger)duration{
	return duration;	
}

- (void)setDuration:(NSInteger)anum{
	if (duration==anum) return;
	dirty=YES;
	duration=anum;
}

//calendarId property
- (NSInteger)calendarId{
	return calendarId;	
}

- (void)setCalendarId:(NSInteger)anum{
	if (calendarId==anum) return;
	dirty=YES;
	calendarId=anum;
	
	Calendar *cal=[coreData calendarWithPrimaryKey:anum];
	if (cal.projectType==1) {
		self.isList=1;
	}else {
		self.isList=0;
	}
}

//parentId property
- (NSInteger)parentId{
	return parentId;	
}

- (void)setParentId:(NSInteger)anum{
	if (parentId==anum) return;
	dirty=YES;
	parentId=anum;
}

//updateType property
- (NSInteger)updateType{
	return updateType;	
}

- (void)setUpdateType:(NSInteger)anum{
	if (updateType==anum) return;
	dirty=YES;
	updateType=anum;
}

//isInitialTask property
- (NSInteger)isInitialTask{
	return isInitialTask;	
}

- (void)setIsInitialTask:(NSInteger)anum{
	if (isInitialTask==anum) return;
	dirty=YES;
	isInitialTask=anum;
}

//specifiedAlertTime property
- (NSDate *)specifiedAlertTime{
	return specifiedAlertTime;
}

- (void)setSpecifiedAlertTime:(NSDate *)aDate{
	if ([specifiedAlertTime isEqualToDate:aDate]) return;
	dirty=YES;
	
	[specifiedAlertTime release];
	specifiedAlertTime=[aDate copy];
}

//alertValues
- (NSString *)alertValues {
    return alertValues;
}

- (void)setAlertValues:(NSString *)aString {
    if ((!alertValues && !aString) || (alertValues && aString && [alertValues isEqualToString:aString])) return;
    dirty = YES;
    [alertValues release];
    alertValues = [aString copy];
}

//alertValues
- (NSString *)PNSKey {
    return PNSKey;
}

- (void)setPNSKey:(NSString *)aString {
    if ((!PNSKey && !aString) || (PNSKey && aString && [PNSKey isEqualToString:aString])) return;
    dirty = YES;
    [PNSKey release];
    PNSKey = [aString copy];
}

//hyperNoteId
- (NSInteger)hyperNoteId{
	return hyperNoteId;	
}

- (void)setHyperNoteId:(NSInteger)anum{
	if (hyperNoteId==anum) return;
	dirty=YES;
	hyperNoteId=anum;
}

//toodledoID
- (NSInteger)toodledoID{
	return toodledoID;	
}

- (void)setToodledoID:(NSInteger)anum{
	if (toodledoID==anum) return;
	dirty=YES;
	toodledoID=anum;
}

//hasDuration
- (NSInteger)hasDuration{
	return hasDuration;	
}

- (void)setHasDuration:(NSInteger)anum{
	if (hasDuration==anum) return;
	dirty=YES;
	hasDuration=anum;
}

//contactName
- (NSString *)contactName {
    return contactName;
}

- (void)setContactName:(NSString *)aString {
    if ((!contactName && !aString) || (contactName && aString && [contactName isEqualToString:aString])) return;
    dirty = YES;
    [contactName release];
    contactName = [aString copy];
}


//isPinned
- (NSInteger)isPinned{
	return isPinned;	
}

- (void)setIsPinned:(NSInteger)anum{
	if (isPinned==anum) return;
	dirty=YES;
	isPinned=anum;
}


//doingStatus
- (NSInteger)doingStatus{
	return doingStatus;	
}

- (void)setDoingStatus:(NSInteger)anum{
	if (doingStatus==anum) return;
	dirty=YES;
	doingStatus=anum;
}

//doingLogs
- (NSString *)doingLogs {
    return doingLogs;
}

- (void)setDoingLogs:(NSString *)aString {
    if ((!doingLogs && !aString) || (doingLogs && aString && [doingLogs isEqualToString:aString])) return;
    dirty = YES;
    [doingLogs release];
    doingLogs = [aString copy];
}

//currentStartTime
- (NSDate *)currentStartTime{
	return currentStartTime;
}

- (void)setCurrentStartTime:(NSDate *)aDate{
	if ([currentStartTime isEqualToDate:aDate]) return;
	dirty=YES;
	
	[currentStartTime release];
	currentStartTime=[aDate copy];
}

-(double)gcalSynKey{
	return gcalSynKey;
}

-(void)setGcalSynKey:(double)anum{
	if (gcalSynKey==anum) return;
	
	dirty=YES;
	
	gcalSynKey=anum;
}

//gcalEventId
- (NSString *)gcalEventId {
    return gcalEventId;
}

- (void)setGcalEventId:(NSString *)aString {
    if ((!gcalEventId && !aString) || (gcalEventId && aString && [gcalEventId isEqualToString:aString])) return;
    dirty = YES;
    [gcalEventId release];
    gcalEventId = [aString copy];
}


//originalExceptionDate
- (NSDate *)originalExceptionDate{
	return originalExceptionDate;
}

- (void)setOriginalExceptionDate:(NSDate *)aDate{
	if ([originalExceptionDate isEqualToDate:aDate]) return;
	dirty=YES;
	
	[originalExceptionDate release];
	originalExceptionDate=[aDate copy];
}

//iCalIdentifier
- (NSString *)iCalIdentifier {
    return iCalIdentifier;
}

- (void)setICalIdentifier:(NSString *)aString {
    if ((!iCalIdentifier && !aString) || (iCalIdentifier && aString && [iCalIdentifier isEqualToString:aString])) return;
    dirty = YES;
    [iCalIdentifier release];
    iCalIdentifier = [aString copy];
}

//iCalCalendarName
- (NSString *)iCalCalendarName {
    return iCalCalendarName;
}

- (void)setICalCalendarName:(NSString *)aString {
    if ((!iCalCalendarName && !aString) || (iCalCalendarName && aString && [iCalCalendarName isEqualToString:aString])) return;
    dirty = YES;
    [iCalCalendarName release];
    iCalCalendarName = [aString copy];
}

//builtIn
- (NSInteger)builtIn{
	return builtIn;	
}

- (void)setBuiltIn:(NSInteger)anum{
	if (builtIn==anum) return;
	dirty=YES;
	builtIn=anum;
}

//hiddenFromTaskView
- (NSInteger)hiddenFromTaskView{
	return hiddenFromTaskView;	
}

- (void)setHiddenFromTaskView:(NSInteger)anum{
	if (hiddenFromTaskView==anum) return;
	dirty=YES;
	hiddenFromTaskView=anum;
}

//isHidden
- (NSInteger)isHidden{
	return isHidden;	
}

- (void)setIsHidden:(NSInteger)anum{
	if (isHidden==anum) return;
	dirty=YES;
	isHidden=anum;
}

//isList
- (NSInteger)isList{
	return isList;	
}

- (void)setIsList:(NSInteger)anum{
	if (isList==anum) return;
	dirty=YES;
	isList=anum;
}

//gtdOrder
- (NSInteger)gtdOrder{
	return gtdOrder;	
}

- (void)setGtdOrder:(NSInteger)anum{
	if (gtdOrder==anum) return;
	dirty=YES;
	gtdOrder=anum;
}

//taskRepeatStyle
- (NSInteger)taskRepeatStyle{
	return taskRepeatStyle;	
}

- (void)setTaskRepeatStyle:(NSInteger)anum{
	if (taskRepeatStyle==anum) return;
	dirty=YES;
	taskRepeatStyle=anum;
}

//SDWIdentifer
- (NSInteger)SDWIdentifer{
	return SDWIdentifer;	
}

- (void)setSDWIdentifer:(NSInteger)anum{
	if (SDWIdentifer==anum) return;
	dirty=YES;
	SDWIdentifer=anum;
}

@end
