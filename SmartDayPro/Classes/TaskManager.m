//
//  TaskManager.m
//  SmartCal
//
//  Created by Trung Nguyen on 5/19/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "TaskManager.h"

#import "Common.h"
#import "Settings.h"
#import "Task.h"
#import "Project.h"
#import "DBManager.h"
#import "AlertManager.h"
#import "ProjectManager.h"
#import "TaskLinkManager.h"
#import "TimerManager.h"
#import "TagDictionary.h"

#import "RepeatData.h"
#import "TaskProgress.h"
#import "FilterData.h"
#import "AlertData.h"
#import "Link.h"

#import "BusyController.h"

#import "SmartListViewController.h"
#import "CalendarViewController.h"
#import "SmartDayViewController.h"

extern SmartListViewController *_smartListViewCtrler;
extern CalendarViewController *_sc2ViewCtrler;

extern BOOL _rtDoneHintShown;

TaskManager *_sctmSingleton = nil;

@implementation TaskManager

@synthesize taskList;
@synthesize mustDoTaskList;
@synthesize scheduledTaskList;

//@synthesize todayEventList;

//@synthesize garbageList;

@synthesize today;

@synthesize REList;
@synthesize RADEList;

@synthesize dayManagerStartTime;
@synthesize dayManagerEndTime;

@synthesize filterData;

@synthesize taskTypeFilter;

@synthesize lastTaskDuration;
@synthesize lastTaskProjectKey;

@synthesize sortQueue;

@synthesize taskDummy;
@synthesize eventDummy;

- (id) init
{
	if (self = [super init])
	{
		[self reset];
		
		self.sortQueue = [NSMutableArray arrayWithCapacity:5];
		
		taskDummy = [[Task alloc] init];
		taskDummy.type = TYPE_TASK;
		
		eventDummy = [[Task alloc] init];
		eventDummy.type = TYPE_EVENT;
		
		sortCond = [[NSCondition alloc] init];
		
		thumbPlannerBGCond = [[NSCondition alloc] init];
        
        scheduleBGCond = [[NSCondition alloc] init];
        
	}
	
	return self;
}

- (void) initMiniMonth:(BOOL)inProgress
{
	////NSLog(@"init ThumbPlanner: %@", (inProgress?@"Yes":@"No"));
	
	[thumbPlannerBGCond lock];
	
	thumbPlannerBGInProgress = inProgress;
	
	if (!inProgress)
	{
		[thumbPlannerBGCond signal];
	}
	
	[thumbPlannerBGCond unlock];
}

- (BOOL) checkScheduleInProgress
{
	return scheduleBGInProgress;
}

- (void) wait4ThumbPlannerInitComplete
{
	[thumbPlannerBGCond lock];
	
	while (thumbPlannerBGInProgress)
	{
		////NSLog(@"Wait for ThumbPlanner ...");
		[thumbPlannerBGCond wait];
	}
	
	////NSLog(@"Wait for ThumbPlanner finished");
	
	[thumbPlannerBGCond unlock];
}

- (void) print:(NSArray *)taskList
{
    /*
	int c = 0;
	for (Task *task in taskList)
	{
		printf("%d.", c++);
		[task print];
	}
	
	printf("\n");
    */
}

- (void) printList
{
	[self print:self.taskList];
}

- (void)dealloc 
{    
	[sortCond release];
	[thumbPlannerBGCond release];
    [scheduleBGCond release];
	
	[taskDummy release];
	[eventDummy release];
	
	[self reset];
	
	[super dealloc];
}


- (void) initData
{
    //printf("TaskManager initData\n");
    
	if (self.today == nil)
	{
		self.today = [NSDate date];
	}
	
	[self initRE];
	
	[self initCalendarData: self.today];

	[self initMiniMonth:YES];
	
	[self initSmartListData];	
}

- (void) initRE
{
	@synchronized(self)
	{
	self.REList = [[DBManager getInstance] getREs];
	
	self.RADEList =  [[DBManager getInstance] getRADEs];
	}
}

- (void) reset
{
	self.taskList = nil;
    self.mustDoTaskList = nil;
	self.scheduledTaskList = nil;
	
	//self.todayEventList = nil;
    
    //self.garbageList = [NSMutableArray arrayWithCapacity:5];
	
	self.today = nil;
	
	self.REList = nil;
	self.RADEList = nil;
	
	self.dayManagerStartTime = nil;
	self.dayManagerEndTime = nil;
	
	self.filterData = nil;
	self.taskTypeFilter = TASK_FILTER_ALL;
	
	self.lastTaskDuration = [[Settings getInstance] taskDuration];
	self.lastTaskProjectKey = [[Settings getInstance] taskDefaultProject];
	
	self.sortQueue = nil;
}

- (NSArray *) getTaskList
{
	return self.taskList;
}

/*
- (void) cleanupGarbage
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
//@synchronized(self)
//{
    if (self.garbageList.count > 2)
    {
        int c = self.garbageList.count - 2;
        
        //printf("clean garbage count: %d - c:%d\n", self.garbageList.count, c);
        
        NSRange range;
     
        range.location = 0;
        range.length = c;
        

        NSMutableArray *keepList = [NSMutableArray arrayWithCapacity:10];
        
        for (int i=c; i<self.garbageList.count; i++)
        {
            [keepList addObject:[self.garbageList objectAtIndex:i]];
        }
        
        self.garbageList = [NSMutableArray arrayWithArray:keepList];
        
        //[self.garbageList removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
    }
//}
    [pool release];
}

- (void) garbage:(NSObject *)obj
{
@synchronized(self)
{
    if (obj != nil)
    {
        BOOL exclude = [obj isKindOfClass:[NSArray class]] && [(NSArray *)obj count] == 0;
        
        if (!exclude)
        {
            [self.garbageList addObject:obj];
        }
        
        ////printf("garbage count:%d\n", self.garbageList.count);
    }
}
}
*/

#pragma mark Week View and Month View Support

- (NSMutableArray *) splitEvent:(Task *)event
{
	NSDate *start = event.startTime;
	
	NSMutableArray *ret = [NSMutableArray arrayWithCapacity:10];
	
	while ([start compare:event.endTime] == NSOrderedAscending) 
	{		
		NSDate *end = [Common getEndDate:start];		 
		
		if ([end compare:event.endTime] == NSOrderedDescending)
		{
			end = event.endTime;
		}
		
		Task *evt = [event copy];
		
		evt.startTime = start;
		evt.endTime = end;
		evt.syncId = event.syncId;
        evt.sdwId = event.sdwId;
		
		evt.isSplitted = YES;
		
		[ret addObject:evt];
		
		[evt release];
		
		start = (start == event.startTime?[Common clearTimeForDate:[Common dateByAddNumDay:1 toDate:start]]:[Common dateByAddNumDay:1 toDate:start]);		
	}
	
	return ret;
}

- (void) splitEvents:(NSMutableArray *) eventList fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
	NSMutableArray *splitList = [NSMutableArray arrayWithCapacity:10];
	
	NSMutableArray *removeList = [NSMutableArray arrayWithCapacity:10];
	
	for (Task *event in eventList)
	{
		if ([event isLong])
		{
			NSMutableArray *subEvents = [self splitEvent:event];
			
			for (Task *subEvent in subEvents)
			{
				if ([TaskManager checkTaskInTimeRange:subEvent startTime:fromDate endTime:toDate])
				{
					[splitList addObject:subEvent];
				}
			}
			
			[removeList addObject:event];
		}
	}
	
	for (Task *event in removeList)
	{
		[eventList removeObject:event];
	}
	
	[eventList addObjectsFromArray:splitList];
}

- (NSMutableArray *) getADEListOnDate:(NSDate *)onDate
{
	NSDate *fromDate = [Common clearTimeForDate:onDate];
	NSDate *toDate = [Common getEndDate:onDate];
	
	NSMutableArray *adeList = [[DBManager getInstance] getADEsOnDate:onDate];
	adeList = [self filterList:adeList];
	
	NSMutableArray *radeList = [self filterList:self.RADEList];
	
	//for (Task *rade in self.RADEList)
	for (Task *rade in radeList)
	{
		NSMutableArray *reInstanceList = [self expandRE:rade fromDate:fromDate toDate:toDate excludeException:YES];
		
		for (Task *reInstance in reInstanceList)
		{
			[adeList addObject:reInstance];
		}
	}	
	
	//if (self.filterData != nil)
	//{
	//	adeList = [self filterList:adeList];
	//}	
	
	//[self splitEvents:adeList fromDate:fromDate toDate:toDate];
	
	[Common sortList:adeList byKey:@"startTime" ascending:YES];
	
	return adeList;
}

- (NSMutableArray *) getEventListOnDate:(NSDate *)onDate
{
	NSDate *fromDate = [Common clearTimeForDate:onDate];
	NSDate *toDate = [Common getEndDate:onDate];
	
	NSMutableArray *eventList = [[DBManager getInstance] getEventsOnDate:onDate];
	
	eventList = [self filterList:eventList];
	
	NSMutableArray *reList = [self filterList:self.REList];
	
	//for (Task *re in self.REList)
	for (Task *re in reList)
	{
		//////printf("expand RE %s\n", [re.name UTF8String]);
		NSMutableArray *reInstanceList = [self expandRE:re fromDate:fromDate toDate:toDate excludeException:YES];
		
		for (Task *reInstance in reInstanceList)
		{
			[eventList addObject:reInstance];
		}
	}	
	
	//if (self.filterData != nil)
	//{
	//	eventList = [self filterList:eventList];
	//}	
	
	[self splitEvents:eventList fromDate:fromDate toDate:toDate];
	
	[Common sortList:eventList byKey:@"startTime" ascending:YES];
	
	//////printf("*** Event List on date: %s\n", [[onDate description] UTF8String]);
	
	//[self print:eventList];
	
	//////printf("\n");
	
	return eventList;
	
}

- (NSMutableArray *) getNoteList
{
    DBManager *dbm = [DBManager getInstance];
    
    NSMutableArray *list = [dbm getAllNotes];
    
    list = [self filterList:list];
    
    [Common sortList:list byKey:@"startTime" ascending:NO];
    
    return list;
}

- (NSMutableArray *) getWeekNoteList
{
    DBManager *dbm = [DBManager getInstance];
    
    NSMutableArray *list = [dbm getNotesByThisWeek];
    
    list = [self filterList:list];
    
    [Common sortList:list byKey:@"startTime" ascending:NO];
    
    return list;
}

- (NSMutableArray *) getNoteListOnDate:(NSDate *)onDate
{
    DBManager *dbm = [DBManager getInstance];
    
    NSMutableArray *list = [dbm getNotesOnDate:onDate];
    
    list = [self filterList:list];
    
    [Common sortList:list byKey:@"startTime" ascending:NO];
    
    return list;
}

- (NSMutableArray *) getNoteListFromDate: (NSDate *) fromDate toDate: (NSDate *) toDate {
    NSDate *start = [Common clearTimeForDate:fromDate];
	NSDate *end =  [Common getEndDate:toDate];
    
    NSMutableArray *list = [[DBManager getInstance] getNotesFromDate:start toDate:end];
	
	list = [self filterList:list];
	
	[Common sortList:list byKey:@"startTime" ascending:NO];
    
    [self print:list];
	
	return list;
}

- (NSMutableArray *) getDoneTasksToday
{
    DBManager *dbm = [DBManager getInstance];
    
    NSMutableArray *list = [dbm getDoneTasksToday];
    
    list = [self filterList:list];
    
    return list;    
}

- (NSMutableArray *) getDoneTasksOnDate: (NSDate*)date
{
    DBManager *dbm = [DBManager getInstance];
    
    NSMutableArray *list = [dbm getDoneTasksOnDate:date];
    
    list = [self filterList:list];
    
    return list;
}

- (NSMutableArray *) getDoneTasksFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate
{
    DBManager *dbm = [DBManager getInstance];
    
    NSMutableArray *list = [dbm getDoneTasksFromDate:fromDate toDate:toDate];
    
    list = [self filterList:list];
    
    return list;
}

- (NSMutableArray *) getEventListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
	NSMutableArray *eventList = [[DBManager getInstance] getEventsFromDate:fromDate toDate:toDate];
	
    @synchronized(self)
    {
	eventList = [self filterList:eventList];
	
	////printf("*** Pure Event List from: %s - to: %s\n", [[fromDate description] UTF8String], [[toDate description] UTF8String]);
	//[self print:eventList];
	
	NSMutableArray *reList = [self filterList:self.REList];
	
	//for (Task *re in self.REList)
	for (Task *re in reList)
	{
        NSTimeInterval reDuration = [re.endTime timeIntervalSinceDate:re.startTime];
        
        NSDate *start = [fromDate dateByAddingTimeInterval:-reDuration];
        
		//NSMutableArray *reInstanceList = [self expandRE:re fromDate:fromDate toDate:toDate excludeException:YES];
		NSMutableArray *reInstanceList = [self expandRE:re fromDate:start toDate:toDate excludeException:YES];
		
		for (Task *reInstance in reInstanceList)
		{
            if ([TaskManager checkTaskInTimeRange:reInstance startTime:fromDate endTime:toDate])
            {
                [eventList addObject:reInstance];
            }
		}
	}
    }
	
	//if (self.filterData != nil)
	//{
	//	eventList = [self filterList:eventList];
	//}
	
	[self splitEvents:eventList fromDate:fromDate toDate:toDate];
	
	[Common sortList:eventList byKey:@"startTime" ascending:YES];
	
	////printf("*** Event List from: %s - to: %s\n", [[fromDate description] UTF8String], [[toDate description] UTF8String]);
	
	//[self print:eventList];
	
	////printf("***\n");
	
	return eventList;
}

- (NSMutableArray *) getADEListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
	NSMutableArray *adeList = [[DBManager getInstance] getADEsFromDate:fromDate toDate:toDate];
	
    @synchronized(self)
    {
	adeList = [self filterList:adeList];
	
	NSMutableArray *radeList = [self filterList:self.RADEList];
	
	//for (Task *rade in self.RADEList)
	for (Task *rade in radeList)
	{
		NSMutableArray *reInstanceList = [self expandRE:rade fromDate:fromDate toDate:toDate excludeException:YES];
		
		for (Task *reInstance in reInstanceList)
		{
			[adeList addObject:reInstance];
		}
	}
    }
	
	//if (self.filterData != nil)
	//{
	//	adeList = [self filterList:adeList];
	//}	
	
	//[Common sortList:adeList byKey:@"startTime" ascending:YES];

	NSSortDescriptor *startTimeSorter = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES];
	NSSortDescriptor *durationSorter = [[NSSortDescriptor alloc] initWithKey:@"duration" ascending:NO];

	NSArray *sortDescriptors = [NSArray arrayWithObjects:startTimeSorter, durationSorter, nil];
	
	[adeList sortUsingDescriptors:sortDescriptors];
	
	[startTimeSorter release];
	[durationSorter release];
	
	
	////////printf("*** ADE List from: %s - to: %s\n", [[fromDate description] UTF8String], [[toDate description] UTF8String]);
	
	//[self print:adeList];
	
	////////printf("\n");
	
	
	return adeList;
}

#pragma mark Week Planner Support
- (NSMutableArray *) getDTaskListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
	NSDate *start = [Common clearTimeForDate:fromDate];
	NSDate *end =  [Common getEndDate:toDate];
	
    /*
	NSMutableArray *list = [NSMutableArray arrayWithCapacity:10];
	
	for (Task *task in self.taskList)
	{
		if (task.deadline != nil && 
			[task.deadline compare:start] != NSOrderedAscending &&
			[task.deadline compare:end] == NSOrderedAscending)
		{
			[list addObject:task];
		}
	}
    */
    
    NSMutableArray *list = [[DBManager getInstance] getDueTasksFromDate:start toDate:end];
	
	list = [self filterList:list];
	
	[Common sortList:list byKey:@"deadline" ascending:YES];
    
    //printf("getDTask from %s - to %s\n", [[fromDate description] UTF8String], [[toDate description] UTF8String]);
    
    [self print:list];
	
	return list;
}

- (NSMutableArray *) getDTaskListOnDate:(NSDate *)onDate
{
	return [self getDTaskListFromDate:onDate toDate:onDate];
}

- (NSMutableArray *) getSTaskListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    
	NSDate *start = [Common clearTimeForDate:fromDate];
	NSDate *end =  [Common getEndDate:toDate];
	
    /*
	NSMutableArray *list = [NSMutableArray arrayWithCapacity:10];
	
	for (Task *task in self.taskList)
	{
		if (task.startTime != nil && 
			[task.startTime compare:start] != NSOrderedAscending &&
			[task.startTime compare:end] == NSOrderedAscending)
		{
			[list addObject:task];
		}
	}
    */
    
    NSMutableArray *list = [[DBManager getInstance] getSTasksFromDate:start toDate:end];
    
	list = [self filterList:list];
	
	[Common sortList:list byKey:@"startTime" ascending:YES];
    
    //printf("getSTask from %s - to %s\n", [[fromDate description] UTF8String], [[toDate description] UTF8String]);
    
    [self print:list];    
	
	return list;
}

- (NSMutableArray *) getSTaskListOnDate:(NSDate *)onDate
{
	return [self getSTaskListFromDate:onDate toDate:onDate];
}

- (NSMutableArray *) getOverdueTaskList
{
    NSMutableArray *list = [[DBManager getInstance] getOverdueTasks];
	
	list = [self filterList:list];
	
	//[Common sortList:list byKey:@"deadline" ascending:YES];
    
    //[self print:list];
	
	return list;
}

- (NSMutableArray *) getATaskListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
	NSDate *start = [Common clearTimeForDate:fromDate];
	NSDate *end =  [Common getEndDate:toDate];

    NSMutableArray *list = [[DBManager getInstance] getAnchoredTasksFromDate:start toDate:end];
	
	list = [self filterList:list];
	
	[Common sortList:list byKey:@"startTime" ascending:YES];
    
    [self print:list];
	
	return list;
}

- (NSMutableArray *) getDAnchoredTaskListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
//	NSDate *start = [Common clearTimeForDate:fromDate];
//	NSDate *end =  [Common getEndDate:toDate];
//    
//    NSMutableArray *list = [[DBManager getInstance] getDAnchoredTasksFromDate:start toDate:end];
//	
//	list = [self filterList:list];
//	
//	[Common sortList:list byKey:@"startTime" ascending:YES];
//    
//    [self print:list];
//	
//	return list;
    
    NSMutableArray *dAnchoredList = [[DBManager getInstance] getDAnchoredTasksFromDate:fromDate toDate:toDate];
	
    @synchronized(self)
    {
        dAnchoredList = [self filterList:dAnchoredList];
        
        ////printf("*** Pure Event List from: %s - to: %s\n", [[fromDate description] UTF8String], [[toDate description] UTF8String]);
        //[self print:eventList];
        
        NSMutableArray *reList = [self filterList:self.REList];
        
        //for (Task *re in self.REList)
        for (Task *re in reList)
        {
            if ([re isManual]) {
                
                NSTimeInterval reDuration = [re.endTime timeIntervalSinceDate:re.startTime];
                
                NSDate *start = [fromDate dateByAddingTimeInterval:-reDuration];
                
                //NSMutableArray *reInstanceList = [self expandRE:re fromDate:fromDate toDate:toDate excludeException:YES];
                NSMutableArray *reInstanceList = [self expandRE:re fromDate:start toDate:toDate excludeException:YES];
                
                for (Task *reInstance in reInstanceList)
                {
                    if ([reInstance.endTime compare:fromDate] != NSOrderedAscending && [reInstance.endTime compare:toDate] != NSOrderedDescending)
                    {
                        [dAnchoredList addObject:reInstance];
                    }
                }
            }
        }
    }
	
	//if (self.filterData != nil)
	//{
	//	eventList = [self filterList:eventList];
	//}
	
	//[self splitEvents:dAnchoredList fromDate:fromDate toDate:toDate];
	
	[Common sortList:dAnchoredList byKey:@"startTime" ascending:YES];
	
	////printf("*** Event List from: %s - to: %s\n", [[fromDate description] UTF8String], [[toDate description] UTF8String]);
	
	//[self print:eventList];
	
	////printf("***\n");
	
	return dAnchoredList;
}

- (NSMutableArray *) getATaskListOnDate:(NSDate *)onDate
{
	return [self getATaskListFromDate:onDate toDate:onDate];
}

#pragma mark Calendar Day View Support

- (void) initCalendarData:(NSDate *) date
{
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"CalendarDayResetNotification" object:nil];

    //[self garbage:self.todayEventList];
    
	@synchronized(self)
	{
        //self.todayEventList = [self getEventListOnDate:date];

        //[[AlertManager getInstance] generateAlerts];
	
        self.today = [Common copyTimeFromDate:[NSDate date] toDate:date];
	}
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CalendarDayReadyNotification" object:nil];

	//[[NSNotificationCenter defaultCenter] postNotificationName:@"CalendarDayResetNotification" object:nil];
}

- (TaskProgress *) getEventSegment:(Task *)task onDate:(NSDate *)onDate
{
	NSDate *smartTime = ([task isTask]?task.smartTime:task.startTime);
	NSDate *start = smartTime;
	
	while ([start compare:task.endTime] != NSOrderedDescending) 
	{		
		NSDate *end = [Common getEndDate:start];		 
		
		if ([end compare:task.endTime] == NSOrderedDescending)
		{
			end = task.endTime;
		}
		
		if ([Common compareDateNoTime:start withDate:onDate] == NSOrderedSame)
		{
			TaskProgress *ret = [[[TaskProgress alloc] init] autorelease];
			
			ret.startTime = start;
			ret.endTime = end;
			
			return ret;
		}
		
		start = (start == smartTime?[Common clearTimeForDate:[Common dateByAddNumDay:1 toDate:start]]:[Common dateByAddNumDay:1 toDate:start]);
		
	}
	
	return nil;
}

- (void) addREInstanceToList:(NSMutableArray *)list original:(Task *)re onDate:(NSDate *)onDate fromDate:(NSDate *)fromDate toDate:(NSDate *) toDate excludeException:(BOOL)excludeException
{
	////printf("Check RE Instance on date: %s\n", [[onDate description] UTF8String]);
	//NSDate *reStart = [Common copyTimeFromDate:re.startTime toDate:onDate];
	//NSInteger duration = [Common timeIntervalNoDST:re.endTime sinceDate:re.startTime];
	
    //NSDate *reStart = onDate;
	//NSDate *reEnd = [Common dateByAddNumSecond:duration toDate:reStart];
    
    //BOOL checkRange = ([reStart compare:fromDate] != NSOrderedAscending && [reStart compare:toDate] == NSOrderedAscending) ||
    //([reStart compare:fromDate] == NSOrderedAscending && [reEnd compare:fromDate] == NSOrderedDescending);

    BOOL checkRange = ([onDate compare:fromDate] != NSOrderedAscending && [onDate compare:toDate] == NSOrderedAscending);

	//if (([re.startTime compare:onDate] != NSOrderedDescending) && checkRange)
	if (checkRange)
    {
		NSDate *dt = [Common clearTimeForDate:onDate];
		NSNumber *dtValue = [NSNumber numberWithDouble:[dt timeIntervalSince1970]];
		Task *exc = nil;
		
		if (re.exceptions != nil && excludeException)
		{
			exc = [re.exceptions objectForKey:dtValue];
		}
		
		if (exc == nil)
		{
			//printf("Add RE Instance %s on date: %s in range [%s - %s]\n", [exc.name UTF8String], [[onDate description] UTF8String], [[fromDate description] UTF8String], [[toDate description] UTF8String]);
			
			Task *task = [re copy];
			
			task.primaryKey = -1;
			task.original = re;
			task.repeatData = nil;
			
			NSInteger duration = [Common timeIntervalNoDST:re.endTime sinceDate:re.startTime];
			task.duration = duration;
			
            task.reInstanceStartTime = onDate;
			task.startTime = onDate;
			task.endTime = [Common dateByAddNumSecond:duration toDate:task.startTime];
			task.smartTime = task.startTime;
			
			[list addObject:task];
			[task release];			
		}
        else
        {
            //printf("has exception on date: %s\n", [[dt description] UTF8String]);
        }
		
	}
}

- (NSMutableArray *) expandRE:(Task *)re fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate excludeException:(BOOL)excludeException
{
	//NSLog(@"[begin] expand RE %@ from: %@ - to: %@\n", re.name, [fromDate description], [toDate description]);
    
	NSMutableArray *ret = [NSMutableArray arrayWithCapacity:10];
	
    NSDate *until = toDate;
    
    if ([re isEvent] && re.repeatData.until != nil && [Common compareDateNoTime:re.repeatData.until withDate:toDate] == NSOrderedAscending)
    {
        until = re.repeatData.until;
    }
    
    if ([fromDate compare:until] == NSOrderedAscending)
    {
        NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
        
        unsigned unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
        
        NSDate *reStartTime = re.startTime;
        
        if (re.repeatData.type == REPEAT_DAILY && re.repeatData.interval == 1)
        {
            if ([fromDate compare:re.startTime] == NSOrderedAscending)
            {
                reStartTime = re.startTime;
            }
            else
            {
                reStartTime = [Common copyTimeFromDate:re.startTime toDate:fromDate];
            }
        }
        
        int wkday = re.repeatData.type == REPEAT_WEEKLY? [Common getWeekday:reStartTime timeZoneID:re.timeZoneId]:[Common getWeekday:reStartTime];
        int wkOrdinal = [Common getWeekdayOrdinal:reStartTime];
        
        NSDateComponents *re_comps = [gregorian components:unitFlags fromDate:reStartTime];
        
        while ([reStartTime compare:until] == NSOrderedAscending)
        {
            NSDateComponents *comps = [gregorian components:unitFlags fromDate:reStartTime];
            
            switch (re.repeatData.type) 
            {
                case REPEAT_DAILY:
                {
                    [self addREInstanceToList:ret original:re onDate:reStartTime fromDate:fromDate toDate:until excludeException:excludeException];
                    
                    reStartTime = [Common dateByAddNumDay:re.repeatData.interval toDate:reStartTime];
                    
                }
                    break;
                case REPEAT_WEEKLY:
                {
                    NSInteger wkOptions[7] = {ON_SUNDAY, ON_MONDAY, ON_TUESDAY, ON_WEDNESDAY, ON_THURSDAY, ON_FRIDAY, ON_SATURDAY}; 
                    
                    NSDateComponents *wkComps = [[comps copy] autorelease];
                    
                    NSInteger wkOpt = re.repeatData.weekOption;
                    
                    if (wkOpt == 0)
                    {
                        wkOpt = wkOptions[wkday-1];
                    }
                    
                    for (int i=0; i<7; i++)
                    {
                        if (wkOpt & wkOptions[i])
                        {
                            if (i < wkday - 1)
                            {
                                [wkComps setDay:[comps day]+i+1-wkday + 7*re.repeatData.interval]; //the week of next interval
                            }
                            else 
                            {
                                [wkComps setDay:[comps day]+i+1-wkday]; //this week
                            }
                            
                            [self addREInstanceToList:ret original:re onDate:[gregorian dateFromComponents:wkComps] fromDate:fromDate toDate:until excludeException:excludeException];
                        }
                    }
                    
                    reStartTime = [Common dateByAddNumDay:7*re.repeatData.interval toDate:reStartTime];
                    
                }
                    break;
                case REPEAT_MONTHLY:
                {
                    NSDateComponents *mthComps = [[[NSDateComponents alloc] init] autorelease];
                    
                    mthComps.year = comps.year;
                    mthComps.month = comps.month;
                    mthComps.hour = comps.hour;
                    mthComps.minute = comps.minute;
                    mthComps.second = comps.second;

                    ////printf("comps year:%d - month:%d - day:%d\n", mthComps.year, mthComps.month, comps.day);
                    
                    if (re.repeatData.monthOption == BY_DAY_OF_WEEK)
                    {
                        //NSDate *lastMonthDate = [Common getEndMonthDate:reStartTime withMonths:re.repeatData.interval];
                        NSDate *lastMonthDate = [Common getEndMonthDate:reStartTime withMonths:1];
                        NSInteger weekOrdinal = [Common getWeekdayOrdinal:lastMonthDate];
                        NSInteger lastWeekday = [Common getWeekday:lastMonthDate];

                        if (re.repeatData.weekDay != 0 && re.repeatData.weekOrdinal != 0) //to support sync TD RT
                        {
                            ////////printf("Expand - task:%s, weekday:%d, weekordinal:%d, last week ordinal:%d\n", [re.name UTF8String], re.repeatData.weekDay, re.repeatData.weekOrdinal, weekOrdinal);
                            
                            if (re.repeatData.weekOrdinal > weekOrdinal)
                            {
                                if (lastWeekday < re.repeatData.weekDay)
                                {
                                    weekOrdinal -= 1;
                                }
                            }
                            else
                            {
                                weekOrdinal = re.repeatData.weekOrdinal;
                            }
                            
                            [mthComps setWeekday:re.repeatData.weekDay];
                            [mthComps setWeekdayOrdinal:weekOrdinal];								
                        }
                        else
                        {
                            if (wkOrdinal > weekOrdinal)
                            {
                                if (lastWeekday < wkday)
                                {
                                    weekOrdinal -= 1;
                                }
                            }
                            else
                            {
                                weekOrdinal = wkOrdinal;
                            }
                            
                            [mthComps setWeekday:wkday];
                            [mthComps setWeekdayOrdinal:weekOrdinal];
                            
                            ////printf("set month weekday: %d - week ordinal: %d\n", wkday, weekOrdinal);
                        }
                    }
                    else 
                    {
                        [mthComps setDay:re_comps.day];
                    }
                    
                    NSDate *mthDate = [gregorian dateFromComponents:mthComps];
                    
                    mthComps = [gregorian components:unitFlags fromDate:mthDate];
                    
                    if (mthComps.month != comps.month)
                    {
                        mthComps.day -= 7;
                        
                        mthDate = [gregorian dateFromComponents:mthComps];
                    }

                    ////printf("month date: %s\n", [[mthDate description] UTF8String]);
                                        
                    if (re.repeatData.monthOption == BY_DAY_OF_MONTH && [Common getDay:mthDate] != re_comps.day)
                    {
                        mthDate = nil; //there is no such day, 31 for example, in the checking month
                    }
                    
                    if (mthDate != nil)
                    {
                        [self addREInstanceToList:ret original:re onDate:mthDate fromDate:fromDate toDate:until excludeException:excludeException];
                    }
                    
                    mthComps.day = (re.repeatData.monthOption == BY_DAY_OF_WEEK?1:comps.day);
                    mthComps.month = comps.month;
                    mthComps.year = comps.year;
                    
                    reStartTime = [Common dateByAddNumMonth:re.repeatData.interval toDate:[gregorian dateFromComponents:mthComps]];
                }
                    break;
                case REPEAT_YEARLY:
                {
                    int newDay = [Common getDay:reStartTime];
                    
                    ////printf("RE check date: %s - day: %d - original day: %d\n", [[reStartTime description] UTF8String], newDay, re_comps.day);
                    
                    if (newDay == re_comps.day)
                    {
                        [self addREInstanceToList:ret original:re onDate:reStartTime fromDate:fromDate toDate:until excludeException:excludeException];
                    }
                    
                    //reStartTime = [Common dateByAddNumYear:re.repeatData.interval toDate:reStartTime];
                    
                    NSDateComponents *yrComps = [[comps copy] autorelease];
                    yrComps.year += re.repeatData.interval;
                    yrComps.day = re_comps.day;
                    yrComps.month = re_comps.month;
                    
                    reStartTime = [gregorian dateFromComponents:yrComps];
                    
                }
                    break;
                default:
                    break;
            }
            
            ////////printf("Expand - task:%s, next start time:%s\n", [re.name UTF8String], [[reStartTime description] UTF8String]);
            ////printf("expand RE - Check Next Start Time: %s\n", [[reStartTime description] UTF8String]);
            
            
        }
    }
    
    //NSLog(@"[sort] expand RE %@", re.name);
	
	[Common sortList:ret byKey:@"startTime" ascending:YES];
    
    //NSLog(@"[end] expand RE %@\n\n", re.name);
	
	return ret;	
}

#pragma mark Fast Scheduling Support
-(void) findFreeTimeSlotsFromDate:(NSDate *)fromDate inDays:(NSInteger)inDays segments:(NSMutableArray *)segments
{
	NSDate *toDate = [Common dateByAddNumDay:inDays toDate:fromDate];
	
	//printf("* find time slot from:%s to:%s\n", [[fromDate description] UTF8String], [[toDate description] UTF8String]);
	
	NSMutableArray *eventList = [self getEventListFromDate:[Common clearTimeForDate:fromDate] toDate:[Common getEndDate:toDate]];
    
    //printf("* end find time slot\n");
	
	NSDate *dmStartTime = [self getWorkingStartTime:fromDate];
	NSDate *dmEndTime = [self getWorkingEndTime:fromDate];
	
	NSDate *start = dmStartTime;
	NSDate *dateSchedule = nil;
    
    NSMutableArray *transProjectList = [[ProjectManager getInstance] getTransparentProjectList];
    
    NSDictionary *transProjectDict = [ProjectManager getProjectDictById:transProjectList];
	
	for (Task *event in eventList)
	{
		Project *transPrj = [transProjectDict objectForKey:[NSNumber numberWithInt:event.project]];
        
		if (event.type != TYPE_EVENT || (transPrj != nil && ![event isMeetingInvited]))
		{
			continue;
		}
		
		if (dateSchedule == nil || [Common compareDateNoTime:dateSchedule withDate:event.startTime] != NSOrderedSame)
		{
			if (dateSchedule != nil)
			{
				if ([start compare:dmEndTime] == NSOrderedAscending) //fill the final segment of the previous day
				{
					TaskProgress *segment = [[TaskProgress alloc] init];
					segment.startTime = start;
					segment.endTime = dmEndTime;
					[segments addObject:segment];
					
					[segment release];
					/*
					////printf("slot1: [start time:%s dateSchedule:%s] -> [from:%s to:%s]\n",
						   [[event.startTime description] UTF8String], [[dateSchedule description] UTF8String],
						   [[segment.startTime description] UTF8String], [[segment.endTime description] UTF8String]);
					*/
				}
				
				dateSchedule = [Common dateByAddNumDay:1 toDate:dateSchedule];
				
			}
			else 
			{
				dateSchedule = fromDate;
			}
			
			
			while ([Common compareDateNoTime:dateSchedule withDate:event.startTime] == NSOrderedAscending)
			{
				//fill whole day hours as free time slot for days there is no Event in between
				
				TaskProgress *segment = [[TaskProgress alloc] init];
				segment.startTime = [self getWorkingStartTime:dateSchedule];
				segment.endTime = [self getWorkingEndTime:dateSchedule];
				[segments addObject:segment];
				
				[segment release];
				
				/*
				////printf("slot2: [start time:%s dateSchedule:%s] -> [from:%s to:%s]\n",
					   [[event.startTime description] UTF8String], [[dateSchedule description] UTF8String],
					   [[segment.startTime description] UTF8String], [[segment.endTime description] UTF8String]);				
				*/
				dateSchedule = [Common dateByAddNumDay:1 toDate:dateSchedule];
			}	
			
			//new date
			dateSchedule = event.startTime;
			
			dmStartTime = [self getWorkingStartTime:dateSchedule];
			dmEndTime = [self getWorkingEndTime:dateSchedule];
			
			//////printf("date schedule: %s - start %s, end %s\n", [[dateSchedule description] UTF8String], [[dmStartTime description] UTF8String], [[dmEndTime description] UTF8String]);
			
			start = dmStartTime;				
		}
		
		if ([start compare:event.startTime] == NSOrderedAscending)
		{
			if ([start compare:dmEndTime] == NSOrderedAscending)
			{
				TaskProgress *segment = [[TaskProgress alloc] init];
				segment.startTime = start;
				[segments addObject:segment];
				[segment release];
				
				if ([dmEndTime compare:event.startTime] != NSOrderedDescending)
				{
					segment.endTime = dmEndTime;
					/*
					////printf("slot3.1: [start time:%s start:%s dmEnd:%s] -> [from:%s to:%s]\n",
						   [[event.startTime description] UTF8String], [[start description] UTF8String], [[dmEndTime description] UTF8String],
						   [[segment.startTime description] UTF8String], [[segment.endTime description] UTF8String]);				
					*/
					
					start = dmEndTime;
				}
				else 
				{
					segment.endTime = event.startTime;
					
					/*
					////printf("slot3.2: [start time:%s start:%s dmEnd:%s] -> [from:%s to:%s]\n",
						   [[event.startTime description] UTF8String], [[start description] UTF8String], [[dmEndTime description] UTF8String],
						   [[segment.startTime description] UTF8String], [[segment.endTime description] UTF8String]);				
					*/
					start = event.endTime;
					
				}	
			}
		}
		else if ([start compare:event.endTime] == NSOrderedAscending) 
		{
			start = event.endTime;
		}
	}		
	
	if ([start compare:dmEndTime] == NSOrderedAscending)
	{
		TaskProgress *segment = [[TaskProgress alloc] init];
		segment.startTime = start;
		segment.endTime = dmEndTime;
		[segments addObject:segment];
		
		[segment release];		
		/*
		////printf("slot4: [start:%s dmEnd:%s] -> [from:%s to:%s]\n",
			   [[start description] UTF8String], [[dmEndTime description] UTF8String],
			   [[segment.startTime description] UTF8String], [[segment.endTime description] UTF8String]);				
		*/
	}
	
	if (dateSchedule == nil) //no event found in a week
	{
		dateSchedule = fromDate;
	}
	
	dateSchedule = [Common dateByAddNumDay:1 toDate:dateSchedule];
	
	while ([Common compareDateNoTime:dateSchedule withDate:toDate] != NSOrderedDescending)
	{
		//fill segment with whole day hours for the rest of days which have no Event
		
		TaskProgress *segment = [[TaskProgress alloc] init];
		segment.startTime = [self getWorkingStartTime:dateSchedule];
		segment.endTime = [self getWorkingEndTime:dateSchedule];
		[segments addObject:segment];
		
		[segment release];
		/*
		////printf("slot5: [dateSchedule:%s toDate:%s] -> [from:%s to:%s]\n",
			   [[dateSchedule description] UTF8String], [[toDate description] UTF8String],
			   [[segment.startTime description] UTF8String], [[segment.endTime description] UTF8String]);				
		*/
		
		dateSchedule = [Common dateByAddNumDay:1 toDate:dateSchedule];
	}			
}

- (void) notifyScheduleCompletion
{
    //[self cleanupGarbage];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ScheduleFinishedNotification" object:nil];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"CalendarDayReadyNotification" object:nil];
}

- (void) notifyFastScheduleCompletion
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FastScheduleFinishedNotification" object:nil];
    
    if (filterChanged)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FilterChangeNotification" object:nil];
    }
    
    filterChanged = NO;
}

- (void) wait4SortComplete
{
	[sortCond lock];
	
	while (sortBGInProgress)
	{
		[sortCond wait];
	}
	
	[sortCond unlock];	
}

- (void) wait4ScheduleGBComplete
{
	[scheduleBGCond lock];
	
	while (scheduleBGInProgress)
	{
		[scheduleBGCond wait];
	}
	
	[scheduleBGCond unlock];	
}

//-(void) scheduleBackground:(NSNumber *)scheduledIndexNum segments:(NSMutableArray *)segments
-(NSInteger) scheduleBackground:(NSInteger)scheduledIndex segments:(NSMutableArray *)segments
{
	//NSLog(@"begin schedule with index:%d", scheduledIndex);
    
    NSMutableArray *list = [self getDisplayList];  

    NSDate *lastScheduleDate = (scheduledIndex-1>=0?[[list objectAtIndex:scheduledIndex-1] smartTime]:nil);
    
    NSInteger index = scheduledIndex;
	
	@synchronized(self)
	{
        for (int i=scheduledIndex;i<list.count;i++)
        {
            Task *task = [list objectAtIndex:i];
            
            task.smartTime = nil;
            
            if (segments.count == 0)
            {
                task.smartTime = (lastScheduleDate == nil? [NSDate date]:[Common dateByAddNumDay:1 toDate:lastScheduleDate]);
                
            }
            else if (task.duration == 0)
            {
                task.smartTime = (lastScheduleDate == nil? [NSDate date]:lastScheduleDate);
                
            }        
            else 
            {
                [self assignTimeForTask:task durationLeft:task.duration segments:segments list:self.scheduledTaskList];
                
                if (task.smartTime == nil)
                {
                    task.smartTime = lastScheduleDate;
                }
                
                lastScheduleDate = task.smartTime;
            }
            
            task.isScheduled = YES;
            
            index ++;
            
            if (index == MAX_FAST_SCHEDULE_TASKS)
            {
                break;
            }
            
            //if (task.smartTime == nil)
            //{
                //printf("**** BG Smart Time NIL: %s\n", [task.name UTF8String]);
            //}
        }
	}

    if (index == MAX_FAST_SCHEDULE_TASKS || list.count < MAX_FAST_SCHEDULE_TASKS)
    {
        //NSLog(@"notify fast schedule finished");
        
        if (refreshGTD)
        {
            [self refreshTopTasks];
        }
        
        //[self notifyFastScheduleCompletion];
        [self performSelectorOnMainThread:@selector(notifyFastScheduleCompletion) withObject:nil waitUntilDone:NO];
    }
    else if (index == list.count)
    {
        if (refreshGTD)
        {
            [self refreshTopTasks];
        }
        
        [self performSelectorOnMainThread:@selector(notifyScheduleCompletion) withObject:nil waitUntilDone:NO];
            
    }
    
    if (scheduledIndex > 0)
    {
        //in background mode
        
        [scheduleBGCond lock];
        
        scheduleBGInProgress = NO;
        
        [scheduleBGCond signal];
        [scheduleBGCond unlock];
        
        [[BusyController getInstance] setBusy:NO withCode:BUSY_TASK_SCHEDULE];
    }
    

    //NSLog(@"end schedule");
    
    return index;
	//[pool release];
}

-(void) fastSchedule
{
	if ((self.mustDoTaskList.count == 0 && self.taskList.count == 0) || self.taskTypeFilter == TASK_FILTER_DONE)
	{
		self.scheduledTaskList = [NSMutableArray arrayWithCapacity:0];
        [self notifyFastScheduleCompletion];
        
		return;
	}
    
	////NSLog(@"begin fast schedule\n");
	
	NSInteger scheduledIndex = 0;
    
    NSMutableArray *list = [self getDisplayList];
    
    self.scheduledTaskList = [NSMutableArray arrayWithCapacity:list.count];
    
    NSMutableArray *segments = [NSMutableArray arrayWithCapacity:20];
    
    [self findFreeTimeSlotsFromDate:[NSDate date] inDays:6 segments:segments];

    scheduledIndex = [self scheduleBackground:0 segments:segments];
    
    if (scheduledIndex < list.count)
    {
		scheduleBGInProgress = YES;
		
		[[BusyController getInstance] setBusy:YES withCode:BUSY_TASK_SCHEDULE];
     
        dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        
        dispatch_async(backgroundQueue, ^{
            NSLog(@"schedule background");
            [self scheduleBackground:scheduledIndex segments:segments];
        });
        
    }
}

- (void) refreshTopTasks
{
    //printf("refresh GTD\n");
    //NSLog(@"begin refresh top tasks");
    
    NSMutableArray *tasks = [NSMutableArray arrayWithArray:self.taskList];
    
    [tasks addObjectsFromArray:self.mustDoTaskList];
    
	for (Task *task in tasks)
	{
		task.isTop = NO;		
	}    
    
	NSDictionary *taskDict = [TaskManager getTaskDictionary:tasks];
	
	NSArray *prjList = [[ProjectManager getInstance] projectList];
	DBManager *dbm = [DBManager getInstance];
	
	//@synchronized(self)
	//{
	for (Project *prj in prjList)
	{
		Task *topTask = [dbm getTopTaskForPlan:prj.primaryKey excludeFutureTasks:YES];
		
		if (topTask != nil)
		{
			Task *tmp = [taskDict objectForKey:[NSNumber numberWithInt:topTask.primaryKey]];
			
			if (tmp != nil)
			{
                //printf("Top Task FOUND: %s - key: %d\n", [topTask.name UTF8String], topTask.primaryKey);
                
				tmp.isTop = YES;
			}
		}
	}
	//}
    
    //NSLog(@"end refresh top tasks");
}

#pragma mark Multi-day Scheduling Support

-(NSInteger) getTotalTaskDuration
{
	NSInteger total = 0;
	
	for (Task *task in self.taskList)
	{
		total += task.duration;
	}
	
	return total;
}

- (NSDate *) getWorkingStartTime:(NSDate *)date
{
    NSDate *now = [NSDate date];
    
    NSDate *dt = [[Settings getInstance] getWorkingStartTimeForDate:date];
    
	if ([Common compareDateNoTime:dt withDate:now] == NSOrderedSame)
	{
        if ([Common compareDate:dt withDate:now] == NSOrderedAscending)
        {
            dt = now;
        }
	}
	
	//return [[dt retain] autorelease];
    return dt;
}

- (NSDate *) getWorkingEndTime:(NSDate *)date
{
	return [[Settings getInstance] getWorkingEndTimeForDate:date];
}

/* -- v3.2
- (NSDate *) getWorkingStartTime:(NSDate *)date
{
	if ([Common compareDateNoTime:date withDate:[NSDate date]] == NSOrderedSame)
	{
		return self.dayManagerStartTime;
	}
	
	return [[Settings getInstance] getWorkingStartTimeForDate:date];
}

- (NSDate *) getWorkingEndTime:(NSDate *)date
{
	if ([Common compareDateNoTime:date withDate:[NSDate date]] == NSOrderedSame)
	{
		return self.dayManagerEndTime;
	}
	
	return [[Settings getInstance] getWorkingEndTimeForDate:date];
}
*/

-(void) findFreeTimeSlotsFromDate:(NSDate *)fromDate segments:(NSMutableArray *)segments
{
	//NSDate *startDate = [Common clearTimeForDate:fromDate];
	NSDate *toDate = [Common getEndDate:[Common dateByAddNumDay:7 toDate:fromDate]];
	
	NSMutableArray *eventList = [self getEventListFromDate:[Common clearTimeForDate:fromDate] toDate:toDate];
	
	NSDate *dmStartTime = [self getWorkingStartTime:fromDate];
	NSDate *dmEndTime = [self getWorkingEndTime:fromDate];
	
	NSDate *start = dmStartTime;
	NSDate *dateSchedule = nil;
	
	for (Task *event in eventList)
	{		
		if (event.type != TYPE_EVENT)
		{
			continue;
		}
		
		if ([Common compareDateNoTime:dateSchedule withDate:event.startTime] != NSOrderedSame)
		{
			if (dateSchedule != nil)
			{
				if ([start compare:dmEndTime] == NSOrderedAscending) //fill the final segment of the previous day
				{
					TaskProgress *segment = [[TaskProgress alloc] init];
					segment.startTime = start;
					segment.endTime = dmEndTime;
					[segments addObject:segment];
					
					[segment release];
					
				}
				
				dateSchedule = [Common dateByAddNumDay:1 toDate:dateSchedule];
				
			}
			else 
			{
				dateSchedule = fromDate;
			}
			
			
			while ([Common compareDateNoTime:dateSchedule withDate:event.startTime] == NSOrderedAscending)
			{
				//fill whole day hours as free time slot for days there is no Event in between
				
				TaskProgress *segment = [[TaskProgress alloc] init];
				segment.startTime = [self getWorkingStartTime:dateSchedule];
				segment.endTime = [self getWorkingEndTime:dateSchedule];
				[segments addObject:segment];
				
				[segment release];
				
				dateSchedule = [Common dateByAddNumDay:1 toDate:dateSchedule];
			}	
			
			//new date
			dateSchedule = event.startTime;
			
			dmStartTime = [self getWorkingStartTime:dateSchedule];
			dmEndTime = [self getWorkingEndTime:dateSchedule];
			
			//////printf("date schedule: %s - start %s, end %s\n", [[dateSchedule description] UTF8String], [[dmStartTime description] UTF8String], [[dmEndTime description] UTF8String]);
			
			start = dmStartTime;				
		}
		
		if ([start compare:event.startTime] == NSOrderedAscending)
		{
			TaskProgress *segment = [[TaskProgress alloc] init];
			segment.startTime = start;
			[segments addObject:segment];
			[segment release];
			
			if ([dmEndTime compare:event.startTime] != NSOrderedDescending)
			{
				segment.endTime = dmEndTime;
				start = dmEndTime;
				//break;
			}
			else 
			{
				segment.endTime = event.startTime;
				start = event.endTime;
			}			
		}
		else if ([start compare:event.endTime] == NSOrderedAscending) 
		{
			start = event.endTime;
		}
	}		
	
	if ([start compare:dmEndTime] == NSOrderedAscending)
	{
		TaskProgress *segment = [[TaskProgress alloc] init];
		segment.startTime = start;
		segment.endTime = dmEndTime;
		[segments addObject:segment];
		
		[segment release];		
	}
	
	if (dateSchedule == nil) //no event found in a week
	{
		dateSchedule = fromDate;
	}
	
	dateSchedule = [Common dateByAddNumDay:1 toDate:dateSchedule];
	
	while ([Common compareDateNoTime:dateSchedule withDate:toDate] != NSOrderedDescending)
	{
		//fill segment with whole day hours for the rest of days which have no Event
		
		TaskProgress *segment = [[TaskProgress alloc] init];
		segment.startTime = [self getWorkingStartTime:dateSchedule];
		segment.endTime = [self getWorkingEndTime:dateSchedule];
		[segments addObject:segment];
		
		[segment release];
		
		dateSchedule = [Common dateByAddNumDay:1 toDate:dateSchedule];
	}			
}


-(void) findFreeTimeSlotsForDuration:(NSInteger)duration fromDate:(NSDate *)fromDate segments:(NSMutableArray *)segments
{
	NSDate *startDate = [Common clearTimeForDate:fromDate];
	//NSDate *toDate = [Common getEndDate:[Common dateByAddNumDay:14 toDate:fromDate]];
	NSDate *toDate = [Common getEndDate:[Common dateByAddNumDay:7 toDate:fromDate]];

	NSMutableArray *eventList = [self getEventListFromDate:startDate toDate:toDate];
	
	NSDate *dmStartTime = [self getWorkingStartTime:startDate];
	NSDate *dmEndTime = [self getWorkingEndTime:startDate];
	
	NSDate *start = dmStartTime;
	NSDate *dateSchedule = nil;
	
	for (Task *event in eventList)
	{		
		if (event.type != TYPE_EVENT)
		{
			continue;
		}
		
		if ([Common compareDateNoTime:dateSchedule withDate:event.startTime] != NSOrderedSame)
		{
			if (dateSchedule != nil)
			{
				if ([start compare:dmEndTime] == NSOrderedAscending) //fill the final segment of the previous day
				{
					TaskProgress *segment = [[TaskProgress alloc] init];
					segment.startTime = start;
					segment.endTime = dmEndTime;
					[segments addObject:segment];
					
					[segment release];
					
					NSInteger diff = (NSInteger) [segment.endTime timeIntervalSinceDate:segment.startTime];
					
					duration -= diff;
					
					if (duration <= 0)
						break;
				}
				
				dateSchedule = [Common dateByAddNumDay:1 toDate:dateSchedule];
				
			}
			else 
			{
				dateSchedule = startDate;
			}

			
			while ([Common compareDateNoTime:dateSchedule withDate:event.startTime] == NSOrderedAscending)
			{
				//fill whole day hours as free time slot for days there is no Event in between
				
				TaskProgress *segment = [[TaskProgress alloc] init];
				segment.startTime = [self getWorkingStartTime:dateSchedule];
				segment.endTime = [self getWorkingEndTime:dateSchedule];
				[segments addObject:segment];
				
				[segment release];
				
				NSInteger diff = (NSInteger) [segment.endTime timeIntervalSinceDate:segment.startTime];
				
				duration -= diff;
				
				if (duration <= 0)
					break;
				
				dateSchedule = [Common dateByAddNumDay:1 toDate:dateSchedule];
			}	
						
			//new date
			dateSchedule = event.startTime;
			
			//dmStartTime = [Common copyTimeFromDate:self.dayManagerStartTime toDate:dateSchedule];
			//dmEndTime = [Common copyTimeFromDate:self.dayManagerEndTime toDate:dateSchedule];
			
			dmStartTime = [self getWorkingStartTime:dateSchedule];
			dmEndTime = [self getWorkingEndTime:dateSchedule];
			
			//////printf("date schedule: %s - start %s, end %s\n", [[dateSchedule description] UTF8String], [[dmStartTime description] UTF8String], [[dmEndTime description] UTF8String]);
			
			start = dmStartTime;				
		}
		
		if ([start compare:event.startTime] == NSOrderedAscending)
		{
			TaskProgress *segment = [[TaskProgress alloc] init];
			segment.startTime = start;
			[segments addObject:segment];
			[segment release];
			
			if ([dmEndTime compare:event.startTime] != NSOrderedDescending)
			{
				segment.endTime = dmEndTime;
				start = dmEndTime;
				//break;
			}
			else 
			{
				segment.endTime = event.startTime;
				start = event.endTime;
			}
			
			NSInteger diff = (NSInteger) [segment.endTime timeIntervalSinceDate:segment.startTime];
			
			duration -= diff;
			
			if (duration <= 0)
				break;
			
		}
		else if ([start compare:event.endTime] == NSOrderedAscending) 
		{
			start = event.endTime;
		}
	}		
	
	if ([start compare:dmEndTime] == NSOrderedAscending)
	{
		TaskProgress *segment = [[TaskProgress alloc] init];
		segment.startTime = start;
		segment.endTime = dmEndTime;
		[segments addObject:segment];
		
		[segment release];
		
		NSInteger diff = (NSInteger) [segment.endTime timeIntervalSinceDate:segment.startTime];
		
		duration -= diff;
	}
	
	if (dateSchedule == nil) //no event found in a week
	{
		dateSchedule = startDate;
	}

	dateSchedule = [Common dateByAddNumDay:1 toDate:dateSchedule];
	
	while ([Common compareDateNoTime:dateSchedule withDate:toDate] != NSOrderedDescending)
	{
		//fill segment with whole day hours for the rest of days which have no Event
		
		TaskProgress *segment = [[TaskProgress alloc] init];
		segment.startTime = [self getWorkingStartTime:dateSchedule];
		segment.endTime = [self getWorkingEndTime:dateSchedule];
		[segments addObject:segment];
		
		[segment release];
		
		NSInteger diff = (NSInteger) [segment.endTime timeIntervalSinceDate:segment.startTime];
		
		duration -= diff;
		
		if (duration <= 0)
			break;
		
		dateSchedule = [Common dateByAddNumDay:1 toDate:dateSchedule];
	}			
	
	/*
	if (duration > 0)
	{
		toDate = [Common dateByAddNumDay:1 toDate:toDate];
		
		[self findFreeTimeSlotsForDuration:duration fromDate:toDate segments:segments];
	}
	*/
}

- (void) schedule
{
	//NSInteger totalDuration = [self getTotalTaskDuration] + 8*3600; //add extra 8 hours to supplement some small non-allocated 15' slots	
	
	NSMutableArray *segments = [NSMutableArray arrayWithCapacity:20];
	
	//[self findFreeTimeSlotsForDuration:totalDuration fromDate:[NSDate date] segments:segments];
	[self findFreeTimeSlotsFromDate:[NSDate date] segments:segments];
	
	self.scheduledTaskList = [NSMutableArray arrayWithCapacity:self.taskList.count];

	//////printf("*** Free Time Slots\n");
	/*for (TaskProgress *progress in segments)
	{
		////printf("segment:[%s - %s]\n", [[progress.startTime descriptionWithLocale:[NSLocale currentLocale]] UTF8String], [[progress.endTime descriptionWithLocale:[NSLocale currentLocale]] UTF8String]);
	}
	*/
	NSDate *lastScheduleDate = [NSDate date];

	//NSInteger scheduleDuration = 0;
	NSDate *futureDate = nil;
	
	for (Task *task in self.taskList)
	{
		task.smartTime = nil;
		
		if (segments.count == 0)
		{
			if (futureDate == nil)
			{
				//futureDate = [Common dateByAddNumSecond:(totalDuration-scheduleDuration) toDate:lastScheduleDate];
                futureDate = [Common dateByAddNumDay:8 toDate:lastScheduleDate];
			}
			
			task.smartTime = futureDate;
		}
		else 
		{
			[self assignTimeForTask:task durationLeft:task.duration segments:segments list:self.scheduledTaskList];
			
			lastScheduleDate = task.startTime;
			//scheduleDuration += task.duration;			
		}		
	}
	
	//////printf("*** Scheduled Task List:\n");
	//[self print:self.scheduledTaskList];		
	
}

#pragma mark SmartList Support
- (void) initDayManager
{
	Settings *settings = [Settings getInstance];
	
	NSDate *dmStartTime = [settings getDayManagerStartTime];
	NSDate *dmEndTime = [settings getDayManagerEndTime];
	
	NSDate *todayStartTime = [settings getTodayWorkingStartTime];
	NSDate *todayEndTime = [settings getTodayWorkingEndTime];
	
	NSDate *now = [NSDate date];
		
	if (settings.dayManagerUpdateTime == nil || [Common compareDateNoTime:now withDate:settings.dayManagerUpdateTime] != NSOrderedSame)
	{
		dmStartTime = todayStartTime;
		dmEndTime = todayEndTime;
	}
	
	if ([dmStartTime compare:todayStartTime] == NSOrderedAscending)
	{
		self.dayManagerStartTime = todayStartTime;
	}
	else 
	{
		self.dayManagerStartTime = dmStartTime;
	}
	
	if ([self.dayManagerStartTime compare:now] == NSOrderedAscending)
	{
		self.dayManagerStartTime = now;
	}
	
	if ([dmEndTime compare:self.dayManagerStartTime] == NSOrderedAscending)
	{
		self.dayManagerEndTime = self.dayManagerStartTime;
	}
	else 
	{
		self.dayManagerEndTime = dmEndTime;
	}
	
	self.dayManagerStartTime = [Common dateByRoundMinute:5 toDate: self.dayManagerStartTime];
	self.dayManagerEndTime = [Common dateByRoundMinute:5 toDate: self.dayManagerEndTime];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DayManagerReadyNotification" object:nil];
	
/*
	if ([dmEndTime compare:todayEndTime] == NSOrderedDescending)
	{
		self.dayManagerEndTime = todayEndTime;
	}
	else 
	{
		self.dayManagerEndTime = dmEndTime;
	}
	
	if ([self.dayManagerEndTime compare:self.dayManagerStartTime] == NSOrderedAscending)
	{
		self.dayManagerEndTime = self.dayManagerStartTime;
	}
*/
}

- (Task *) findRTInstance:(Task *)rt fromDate:(NSDate *) fromDate
{
    if (rt.repeatData.until != nil && [Common compareDateNoTime:rt.repeatData.until withDate:fromDate] == NSOrderedAscending)
    {
        return nil;
    }
    
	NSDate *toDate = fromDate;
	
	switch (rt.repeatData.type) 
	{
		case REPEAT_DAILY:
		{
			toDate = [Common dateByAddNumDay:rt.repeatData.interval toDate:fromDate];
		}
			break;
			
		case REPEAT_WEEKLY:
		{
			toDate = [Common dateByAddNumDay:7*rt.repeatData.interval toDate:fromDate];
		}
			break;
			
		case REPEAT_MONTHLY:
		{
			toDate = [Common getEndMonthDate:fromDate withMonths:rt.repeatData.interval+1];
		}
			break;
		case REPEAT_YEARLY:
		{
			toDate = [Common dateByAddNumYear:rt.repeatData.interval toDate:fromDate];
		}
			break;
	}

	NSMutableArray *rtInstances = [self expandRE:rt fromDate:[Common clearTimeForDate:fromDate] toDate:[Common getEndDate:toDate] excludeException:YES];

	//////printf("RE instances from date:%s to date:%s\n", [[[Common clearTimeForDate:fromDate] description] UTF8String], [[[Common getEndDate:toDate] description] UTF8String]);
	//[self print:rtInstances];
	
    /*
	if (rtInstances.count > 0)
	{
		return [rtInstances objectAtIndex:0];
	}
    */
    
    if (rtInstances.count == 0)
    {
        fromDate = [Common dateByAddNumDay:1 toDate:toDate];
        
        return [self findRTInstance:rt fromDate:fromDate];
    }
	
	return [rtInstances objectAtIndex:0];
}

- (void) updateSortOrderBackground:(NSMutableArray *)list
{
	//NSLog(@"begin updateSortOrderBackground");
	
	//NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	//[self wait4ThumbPlannerInitComplete];
		
	//NSLog(@"start to updateSortOrderBackground");
	
	DBManager *dbm = [DBManager getInstance];
	
	for (Task *task in list)
	{
        //NSLog(@"task: %@", task.name);
        
		[task updateSeqNoIntoDB:[dbm getDatabase]];
	}
	
	//NSLog(@"end updateSortOrderBackground");
	
	[sortCond lock];
	
	sortBGInProgress = NO;
	
	[sortCond signal];
	[sortCond unlock];	

	[[BusyController getInstance] setBusy:NO withCode:BUSY_TASK_SORT_ORDER];
	
	//[pool release];
}

- (void) sortDue
{
	////NSLog(@"begin sort due");
	
	DBManager *dbm = [DBManager getInstance];
	
	self.taskList = [dbm getDueTasks];
	
	NSMutableArray *seqNoList = [NSMutableArray arrayWithCapacity:self.taskList.count];
	
	for (Task *task in self.taskList)
	{
		[seqNoList addObject:[NSNumber numberWithInt:task.sequenceNo]];
	}
	
	////NSLog(@"sort due 1");
	
	[Common sortList:self.taskList byKey:@"deadline" ascending:YES];
	
	////NSLog(@"sort due 2");
	
    /*
	sortBGInProgress = (self.taskList.count > 30);
	
	for (int i=0; i<self.taskList.count; i++)
	{
		Task *task = [self.taskList objectAtIndex:i];
		
		task.sequenceNo = [[seqNoList objectAtIndex:i] intValue];
		
		if (!sortBGInProgress)
		{
            //printf("update seq no: %d for task:%s\n", task.sequenceNo, [task.name UTF8String]);
			[task updateSeqNoIntoDB:[dbm getDatabase]];
		}
	}
	
	////NSLog(@"sort due 3");
	
	if (sortBGInProgress)
	{
		[[BusyController getInstance] setBusy:YES withCode:BUSY_TASK_SORT_ORDER];
        
		//[self performSelectorInBackground:@selector(updateSortOrderBackground:) withObject:self.taskList];
        
        dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        
        dispatch_async(backgroundQueue, ^{
            [self updateSortOrderBackground:[[self.taskList retain] autorelease]];
        });
	}
	*/
	////NSLog(@"end sort due");
	
}

- (void) sortStart
{
	////NSLog(@"begin sort start");
	
	DBManager *dbm = [DBManager getInstance];
	
	self.taskList = [dbm getStartTasks];
	
	NSMutableArray *seqNoList = [NSMutableArray arrayWithCapacity:self.taskList.count];
	
	for (Task *task in self.taskList)
	{
		[seqNoList addObject:[NSNumber numberWithInt:task.sequenceNo]];
	}
	
	////NSLog(@"sort start 1");
	
	[Common sortList:self.taskList byKey:@"startTime" ascending:YES];
	
	////NSLog(@"sort start 2");
	
    /*
	sortBGInProgress = (self.taskList.count > 30);
	
	for (int i=0; i<self.taskList.count; i++)
	{
		Task *task = [self.taskList objectAtIndex:i];
		
		task.sequenceNo = [[seqNoList objectAtIndex:i] intValue];
		
		if (!sortBGInProgress)
		{
			[task updateSeqNoIntoDB:[dbm getDatabase]];
		}
	}
	
	////NSLog(@"sort start 3");
	
	if (sortBGInProgress)
	{
		[[BusyController getInstance] setBusy:YES withCode:BUSY_TASK_SORT_ORDER];
        
		//[self performSelectorInBackground:@selector(updateSortOrderBackground:) withObject:self.taskList];
        
        dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        
        dispatch_async(backgroundQueue, ^{
            [self updateSortOrderBackground:[[self.taskList retain] autorelease]];
        });
        
	}
	*/
	////NSLog(@"end sort start");
	
}

- (void) sortStar
{
	////NSLog(@"begin sort start");
	
	DBManager *dbm = [DBManager getInstance];
	
	self.taskList = [dbm getStartTasks];
	
	NSMutableArray *seqNoList = [NSMutableArray arrayWithCapacity:self.taskList.count];
	
	for (Task *task in self.taskList)
	{
		[seqNoList addObject:[NSNumber numberWithInt:task.sequenceNo]];
	}
	
	////NSLog(@"sort start 1");
	
	[Common sortList:self.taskList byKey:@"status" ascending:NO];
	
	////NSLog(@"sort start 2");
	/*
	sortBGInProgress = (self.taskList.count > 30);
	
	for (int i=0; i<self.taskList.count; i++)
	{
		Task *task = [self.taskList objectAtIndex:i];
		
		task.sequenceNo = [[seqNoList objectAtIndex:i] intValue];
		
		if (!sortBGInProgress)
		{
			[task updateSeqNoIntoDB:[dbm getDatabase]];
		}
	}
	
	////NSLog(@"sort start 3");
	
	if (sortBGInProgress)
	{
		[[BusyController getInstance] setBusy:YES withCode:BUSY_TASK_SORT_ORDER];
        
		//[self performSelectorInBackground:@selector(updateSortOrderBackground:) withObject:self.taskList];
        
        dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        
        dispatch_async(backgroundQueue, ^{
            [self updateSortOrderBackground:[[self.taskList retain] autorelease]];
        });
        
	}
	*/
	////NSLog(@"end sort start");
	
}

- (void) sortDurationWithAsc: (BOOL) asc
{
	////NSLog(@"begin sort start");
	
	DBManager *dbm = [DBManager getInstance];
	
	self.taskList = [dbm getStartTasks];
	
	/*NSMutableArray *seqNoList = [NSMutableArray arrayWithCapacity:self.taskList.count];
	
	for (Task *task in self.taskList)
	{
		[seqNoList addObject:[NSNumber numberWithInt:task.sequenceNo]];
	}
     */
	
	////NSLog(@"sort start 1");
	
	[Common sortList:self.taskList byKey:@"duration" ascending:asc];
	
	////NSLog(@"sort start 2");
	
	/*sortBGInProgress = (self.taskList.count > 30);
	
	for (int i=0; i<self.taskList.count; i++)
	{
		Task *task = [self.taskList objectAtIndex:i];
		
		task.sequenceNo = [[seqNoList objectAtIndex:i] intValue];
		
		if (!sortBGInProgress)
		{
			[task updateSeqNoIntoDB:[dbm getDatabase]];
		}
	}
	
	////NSLog(@"sort start 3");
	
	if (sortBGInProgress)
	{
		[[BusyController getInstance] setBusy:YES withCode:BUSY_TASK_SORT_ORDER];
		
        //[self performSelectorInBackground:@selector(updateSortOrderBackground:) withObject:self.taskList];
        dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        
        dispatch_async(backgroundQueue, ^{
            [self updateSortOrderBackground:[[self.taskList retain] autorelease]];
        });
        
	}
	
	////NSLog(@"end sort start");
     */
	
}

- (void) resort
{
    switch (self.taskTypeFilter)
    {
        case TASK_FILTER_DUE:
            [Common sortList:self.taskList byKey:@"deadline" ascending:YES];
            break;
        case TASK_FILTER_ACTIVE:
            [Common sortList:self.taskList byKey:@"startTime" ascending:YES];
            break;
        case TASK_FILTER_DONE:
            [Common sortList:self.taskList byKey:@"completionTime" ascending:YES];
            break;
        case TASK_FILTER_LONG:
            [Common sortList:self.taskList byKey:@"duration" ascending:NO];
            break;
        case TASK_FILTER_SHORT:
            [Common sortList:self.taskList byKey:@"duration" ascending:YES];
            break;
    }
}

- (void) resetTabAllWithList:(NSMutableArray *)allList
{
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskListResetNotification" object:nil];
    //[self garbage:self.taskList];
	
	self.taskList = [self filterList: allList];
	
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskListReadyNotification" object:nil];
	
	[self scheduleTasks];
}

- (void) filterTaskList
{
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskListResetNotification" object:nil];
    //[self garbage:self.taskList];
	
	refreshGTD = YES;
    
    DBManager *dbm = [DBManager getInstance];
	
	@synchronized(self)
	{
	
	switch (self.taskTypeFilter) 
	{
		case TASK_FILTER_ALL:
			self.taskList = [dbm getVisibleTasks];
			break;
		case TASK_FILTER_DUE:
			[self sortDue];
			break;
		case TASK_FILTER_ACTIVE:
			[self sortStart];
			break;
		case TASK_FILTER_STAR:
			self.taskList = [dbm getPinnedTasks];
            //[self sortStar];
			break;
		case TASK_FILTER_TOP:
			self.taskList = [self getTopTasks];
			break;
        case TASK_FILTER_DONE:
            self.taskList = [dbm getDoneTasks];
            break;
        case TASK_FILTER_LONG:
            [self sortDurationWithAsc:NO];
            break;
        case TASK_FILTER_SHORT:
            [self sortDurationWithAsc:YES];
            break;
	}
        /*
        printf("before exclude MustDo\n");
        [self print:self.taskList];
        */
         
        NSMutableArray *list = [self excludeMustDo: self.taskList];
        
        /*
        printf("after exclude MustDo\n");
        [self print:list];
        */
        
        self.taskList = [self filterList: list];
        
        /*
        printf("after filter\n");
        [self print:self.taskList];
         */
	}
    
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskListReadyNotification" object:nil];
	
	////printf("Task Sequence when filter Smart List:\n");
	//[self print:self.taskList];
}

- (void) initSmartListData
{
	//////printf("init smart list data\n");
	//NSDate *now = [NSDate date];
	
	sortBGInProgress = NO;
	scheduleBGInProgress = NO;
    
    //[self garbage:self.mustDoTaskList];
    
    self.mustDoTaskList = [self filterList: [[DBManager getInstance] getMustDoTasks]];
	
	[self initDayManager];
	
	[self filterTaskList];
	
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskListReadyNotification" object:nil];
	
	[self scheduleTasks];
	
	//[self performSelector:@selector(scheduleTasks) withObject:nil afterDelay:0];
	
	//////printf("task list init time: %f\n", [now timeIntervalSinceNow]);	
}

/*
- (void) sortAndReschedule
{
	[Common sortList:self.taskList byKey:@"sequenceNo" ascending:YES];
	
	[self refreshTopTasks];
	
	//////printf("Task Sequence after moving:\n");
	//[self print:self.taskList];
		
	[self scheduleTasks];
}
*/

- (void) populateEvent:(Task *)task
{
    /*
	NSDate *start = [Common clearTimeForDate:self.today];
	
	NSDate *end = [Common dateByAddNumDay:1 toDate:start];
	
	if ([TaskManager checkTaskInTimeRange:task startTime:start endTime:end])
	{
		if (task.type == TYPE_EVENT)
		{
			if (self.todayEventList == nil)
			{
				self.todayEventList = [NSMutableArray arrayWithCapacity:10];
			}
			
			[self.todayEventList addObject:task];			
		}
	}
    */
}

- (void) populateRE:(Task *)re fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
	NSMutableArray *reInstanceList = [self expandRE:re fromDate:fromDate toDate:toDate excludeException:YES];

	for (Task *reInstance in reInstanceList)
	{
		[self populateEvent:reInstance];
	}	
}

- (void) assignTimeForTask:(Task *)original durationLeft:(NSInteger)durationLeft segments:(NSMutableArray *)segments list:(NSMutableArray *)list
{
	if (durationLeft <= 0 || segments.count == 0)
	{
		return;
	}
	
	//NSTimeInterval minDuration = 15*60;
	NSTimeInterval minDuration = [[Settings getInstance] minimumSplitSize];
	
	TaskProgress *segment = [segments objectAtIndex:0];
	
	//NSInteger slotDuration = [Common timeIntervalNoDST:segment.endTime sinceDate:segment.startTime];
    NSInteger slotDuration = [segment.endTime timeIntervalSinceDate:segment.startTime];
	
	if (durationLeft <= slotDuration)
	{
		Task *tmpTask = [original copy];
		tmpTask.primaryKey = -1;
		tmpTask.original = original;
        //tmpTask.mustDo = original.mustDo;
		//original.isScheduled = YES;
		
		tmpTask.smartTime = segment.startTime;
		tmpTask.endTime = [Common dateByAddNumSecond:durationLeft toDate:tmpTask.smartTime];
		
		if (original.smartTime == nil)
		{
			original.smartTime = tmpTask.smartTime;
		}
		
		//[tmpTask print];
		
		[list addObject:tmpTask];
		[tmpTask release];
		
		if (durationLeft == slotDuration)
		{
			[segments removeObjectAtIndex:0];
		}
		else 
		{
			segment.startTime = [Common dateByAddNumSecond:durationLeft toDate:segment.startTime];
		}
	}
	else 
	{
		if (slotDuration >= minDuration)
		{
			Task *tmpTask = [original copy];
			tmpTask.primaryKey = -1;
			tmpTask.original = original;
            //tmpTask.mustDo = original.mustDo;
			//original.isScheduled = YES;
			
			tmpTask.smartTime = segment.startTime;
			tmpTask.endTime  = segment.endTime;
			
			if (original.smartTime == nil)
			{
				original.smartTime = tmpTask.smartTime;
			}
			
			//[tmpTask print];
			
			[list addObject:tmpTask];
			[tmpTask release];

			durationLeft -= slotDuration;
		}
		
		[segments removeObjectAtIndex:0];
		
		[self assignTimeForTask:original durationLeft:durationLeft segments:segments list:list];
	}
}

- (void) clearScheduledFlag
{
	for (Task *task in self.taskList)
	{
		task.isScheduled = NO;
	}
}

- (void) scheduleTasks
{
	[self clearScheduledFlag];
	
	//[self schedule];
	[self fastSchedule];
}

- (NSMutableArray *)findScheduledTasks:(Task *)original
{
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:5];
    
	for (Task *task in self.scheduledTaskList)
	{
		if (task.original == original)
		{
			[ret addObject:task];
		}
	}
	
	return ret;
}

- (NSMutableArray *)getScheduledTasksOnDate:(NSDate *)date
{
	NSDate *startTime = [Common clearTimeForDate:date];
	NSDate *endTime = [Common getEndDate:date];
	
	NSMutableArray *ret = [NSMutableArray arrayWithCapacity:10]; 
	
	@synchronized(self)
	{
	for (Task *task in self.scheduledTaskList)
	{
		if ([task.smartTime compare:startTime] != NSOrderedAscending && [task.smartTime compare:endTime] == NSOrderedAscending)
		{
			[ret addObject:task];
		}
	}		
	}
	
	ret = [self filterList:ret];
	
	return ret;
}

- (NSMutableArray *)getUnSplittedScheduledTasksOnDate:(NSDate *)date
{
	NSDate *startTime = [Common clearTimeForDate:date];
	NSDate *endTime = [Common getEndDate:date];
	
	NSMutableArray *ret = [NSMutableArray arrayWithCapacity:10];
    
    NSMutableDictionary *taskDict = [NSMutableDictionary dictionaryWithCapacity:10];
	
	@synchronized(self)
	{
        for (Task *task in self.scheduledTaskList)
        {
            Task *tmp = [taskDict objectForKey:[NSNumber numberWithInt:task.original.primaryKey]];
            
            if (tmp != nil)
            {
                //splitted task
                continue;
            }
            
            if ([task.smartTime compare:startTime] != NSOrderedAscending && [task.smartTime compare:endTime] == NSOrderedAscending)
            {
                [ret addObject:task];
            }
            
            [taskDict setObject:task forKey:[NSNumber numberWithInt:task.original.primaryKey]];
        }
	}
	
	ret = [self filterList:ret];
	
	return ret;
}

- (NSMutableArray *)getScheduledTasksFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
	NSMutableArray *ret = [NSMutableArray arrayWithCapacity:10];
	
	@synchronized(self)
	{
        for (Task *task in self.scheduledTaskList)
        {
            if ([task.smartTime compare:fromDate] != NSOrderedAscending && [task.smartTime compare:toDate] == NSOrderedAscending)
            {
                [ret addObject:task];
            }
        }		
	}
	
	ret = [self filterList:ret];
	
	return ret;
}

- (NSMutableArray *) getTopTasks
{
	NSMutableArray *ret = [NSMutableArray arrayWithCapacity:10];
	
	NSMutableArray *prjList = [[ProjectManager getInstance] projectList];
	
	DBManager *dbm = [DBManager getInstance];
	
	for (Project *prj in prjList)
	{
		if (prj.type != TYPE_LIST && prj.status != PROJECT_STATUS_INVISIBLE)
		{
			Task *task = [dbm getTopTaskForPlan:prj.primaryKey excludeFutureTasks:YES];
			
			if (task != nil)
			{
				task.isTop = YES;
				[ret addObject:task];
			}			
		}
	}
	
	//[Common sortList:ret byKey:@"mergedSeqNo" ascending:YES];
    [Common sortList:ret byKey:@"sequenceNo" ascending:YES];
	
	//refreshGTD = NO; //due to Must Do feature, it still needs to refresh GTD for Must Do ones
	
	return ret;
}

/*- (NSMutableArray *)getManualTaskList {
    
	DBManager *dbm = [DBManager getInstance];
	NSMutableArray *ret = [dbm getManualTasks];
    ret = [self filterList:ret];
	
    return ret;
}

- (NSMutableArray *)getManualTaskListFromDate: (NSDate *) fromDate toDate: (NSDate *) toDate {
    
    // get list from DB
	DBManager *dbm = [DBManager getInstance];
	NSMutableArray *ret = [dbm getManualTasksFromDate:fromDate toDate:toDate];
    
    // filter and split
    ret = [self filterList:ret];
    //[self splitEvents:ret fromDate:fromDate toDate:toDate];
    
    return ret;
}*/

- (BOOL) checkSortInBackground
{
	return sortBGInProgress;
}

#pragma mark Project Integration Support
- (void)reconcileSeqNo:(NSArray *)checkList
{
	NSDictionary *taskDict = [TaskManager getTaskDictionary:self.taskList];
	
	for (Task *item in checkList)
	{
		Task *task = [taskDict objectForKey:[NSNumber numberWithInt:item.primaryKey]];
					  
		if (task != nil)
		{
			task.sequenceNo = item.sequenceNo;
			//task.mergedSeqNo = item.mergedSeqNo;
		}
	}
}

- (NSInteger) getDisplayListCount
{
    NSInteger ret = self.taskList.count;
    
    if (self.taskTypeFilter != TASK_FILTER_DONE)
    {
        ret += self.mustDoTaskList.count;
    }
    
    return ret;
}

- (NSMutableArray *) getDisplayList
{
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:self.mustDoTaskList.count + self.taskList.count];
    
    if (self.taskTypeFilter != TASK_FILTER_DONE)
    {
        //printf("* GET DISPLAY LIST - MustDo count:%d\n", self.mustDoTaskList.count);

        if (self.mustDoTaskList.count > 0)
        {
            [list addObjectsFromArray:self.mustDoTaskList];
        }
    }
    
    if (self.taskList.count > 0)
    {
        [list addObjectsFromArray:self.taskList];
    }
    
    return list;
}

//- (void)mergeNormalTask: (NSMutableArray *) normalTask withManualTasks: (NSMutableArray *) manualTasks {
//    if (normalTask.count > 0 && manualTasks.count > 0) {
//        // merge
//        int i = 0;
//        int j = 0;
//        while (i < normalTask.count && j < manualTasks.count) {
//            Task *norTask = [normalTask objectAtIndex:i];
//            Task *manTask = [manualTasks objectAtIndex:j];
//            if ([Common compareDateNoTime:norTask.smartTime withDate:manTask.smartTime] != NSOrderedAscending) {
//                [normalTask insertObject:manTask atIndex:i];
//                j++;
//                i++;
//            } else {
//                i++;
//            }
//        }
//        
//        if (i == normalTask.count &&  j < manualTasks.count) {
//            for (; j < manualTasks.count; j++) {
//                Task *manTask = [manualTasks objectAtIndex:j];
//                [normalTask addObject:manTask];
//            }
//        }
//    } else {
//        if (normalTask.count == 0) {
//            [normalTask addObjectsFromArray:manualTasks];
//        }
//    }
//}
//
//- (NSMutableArray *) getDisplayListWithManualTasks {
//    NSMutableArray *list = [self getDisplayList];
//    if (self.taskTypeFilter != TASK_FILTER_DONE && self.taskTypeFilter == TASK_FILTER_ALL) {
//        
//        // get follow seven days logic
//        NSDate *fromDate = [Common clearTimeForDate:[NSDate date]];
//        NSDate *toDate = [Common getEndDate: [Common dateByAddNumDay:7 toDate:fromDate]];
//        NSMutableArray *manualTaskList = [self getManualTaskListFromDate:fromDate toDate:toDate];
//        /*if (manualTaskList.count > 0) {
//            [list addObjectsFromArray:scheduleTaskList];
//        }*/
//        
//        [self mergeNormalTask:list withManualTasks:manualTaskList];
//    } else if (self.taskTypeFilter == TASK_FILTER_PINNED) {
//        NSMutableArray *manualTaskList = [self getManualTaskList];
//        if (manualTaskList.count > 0) {
//            [list addObjectsFromArray:manualTaskList];
//        }
//    }
//    
//    return list;
//}

#pragma mark Task Operation Support
-(void) unDone:(Task *)task
{
    /*
    if (task.original != nil && task.primaryKey == -1)
    {
        task = task.original;
    }
    */
    
    Task *slTask = [self getTask2Update:task];
    
    if (self.taskTypeFilter == TASK_FILTER_DONE)
    {
        [self removeTask:slTask status:TASK_STATUS_NONE];
    }
    else 
    {
        slTask.status = TASK_STATUS_NONE;
        
        [slTask updateStatusIntoDB:[[DBManager getInstance] getDatabase]];        
    }
    	
	[self populateTask:slTask];
		
	[self scheduleTasks];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];    
}

- (void) populateRE:(Task *)re isNew:(BOOL)isNew
{
	if (isNew)
	{
		if (re.type == TYPE_EVENT)
		{
			[self.REList addObject:re];
		}
		else if (re.type == TYPE_ADE)
		{
			[self.RADEList addObject:re];
		}
		
	}
	
	//NSDate *yesterday = [Common clearTimeForDate:[Common dateByAddNumDay:-1 toDate:self.today]];
	
	//NSDate *tomorrow = [Common getEndDate:[Common dateByAddNumDay:1 toDate:self.today]];
	
    NSDate *start = [Common clearTimeForDate:self.today];
    NSDate *end = [Common getEndDate:self.today];
    
	[self populateRE:re fromDate:start toDate:end];	
}

/*
-(void) changeTask:(Task *)task toProject:(NSInteger)prjKey
{
	Task *original = [self findTaskByKey:task.primaryKey];
	
	if (original != nil)
	{
        [self removeTask:original status:-1];
    }
    
    task.project = prjKey;
    
    BOOL needSchedule = NO;
    
    if ([task isTask])
    {
        needSchedule = [self populateTask:task];
        
        if (needSchedule)
        {
            [self scheduleTasks];
        }
    }

        
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];
}
*/

-(void) sortTasks:(NSMutableArray *)tasks //to support sync multi tasks 
{
	DBManager *dbm = [DBManager getInstance];
    ProjectManager *pm = [ProjectManager getInstance];
	
	NSMutableDictionary *prjDict = [ProjectManager getProjectDictById:pm.projectList];
	
	NSInteger taskPlacement = [[Settings getInstance] newTaskPlacement];
	
	NSMutableDictionary *planDict = [NSMutableDictionary dictionaryWithCapacity:10];
	
	NSMutableArray *list = [dbm getVisibleTasks];
	
	//update seq no inside Plan
	for (Task * task in tasks)
	{
		BOOL isOfCheckList = [ProjectManager checkListStyle:task.project projectDict:prjDict];
		
		task.mergedSeqNo = -1;
		if (task.primaryKey == -1)
		{
			if (isOfCheckList)
			{
				task.duration = 0;
			}
			
			[task insertIntoDB:[dbm getDatabase]];
		}
			
		NSMutableArray *planTaskList = [planDict objectForKey:[NSNumber numberWithInt:task.project]];
		
		if (planTaskList == nil)
		{
			planTaskList = [dbm getTasksForPlan:task.project];
			[planDict setObject:planTaskList forKey:[NSNumber numberWithInt:task.project]];
		}
		
		if (taskPlacement == 0) //on top
		{
			if (planTaskList.count > 0)
			{
				[planTaskList insertObject:task atIndex:0];
			}
			else 
			{
				[planTaskList addObject:task];
			}		
		}
		else 
		{
			[planTaskList addObject:task];
		}
		
		//BOOL isOfCheckList = [[ProjectManager getInstance] checkListStyle:task.project];
				
		if (!isOfCheckList)
		{
			if (taskPlacement == 0) //on top
			{
				if (list.count > 0)
				{
					[list insertObject:task atIndex:0];
				}
				else 
				{
					[list addObject:task];
				}				
			}
			else 
			{
				[list addObject:task];
			}
		}
	}	
	
	NSEnumerator *enumerator = [planDict objectEnumerator];
	NSMutableArray *planTaskList;
	
	//for (NSMutableArray *planTaskList in [planDict allObjects])
	while (planTaskList = [enumerator nextObject])
	{
		if (taskPlacement == 0)
		{
			for (int i=planTaskList.count-1; i>=0; i--)
			{
				Task *tmp = [planTaskList objectAtIndex:i];
				
				tmp.sequenceNo = i;
				
				[tmp updateSeqNoIntoDB:[dbm getDatabase]];
			}			
		}
		else 
		{
			for (int i=0; i<planTaskList.count; i++)
			{
				Task *tmp = [planTaskList objectAtIndex:i];
				
				tmp.sequenceNo = i;
				
				[tmp updateSeqNoIntoDB:[dbm getDatabase]];
			}			
		}
	}
	
	if (taskPlacement == 0)
	{
		for (int i=list.count-1; i>=0; i--)
		{
			Task *tmp = [list objectAtIndex:i];
			
			tmp.mergedSeqNo = i;
			
			[tmp updateMergedSeqNoIntoDB:[dbm getDatabase]];			
		}
	}
	else 
	{
		for (int i=0; i<list.count; i++)
		{
			Task *tmp = [list objectAtIndex:i];
			
			tmp.mergedSeqNo = i;
			
			[tmp updateMergedSeqNoIntoDB:[dbm getDatabase]];
		}		
	}

}

-(NSMutableArray *) sortTask:(Task *)task
{
	//////NSLog(@"begin sort tasks");
	DBManager *dbm = [DBManager getInstance];
	
	BOOL isOfCheckList = [[ProjectManager getInstance] checkListStyle:task.project];
	NSInteger taskPlacement = [[Settings getInstance] newTaskPlacement];
	
	NSMutableArray *list = [dbm getVisibleTasks];
	NSMutableArray *planTaskList = isOfCheckList?[dbm getTasksForPlan:task.project]:[NSMutableArray arrayWithCapacity:10];
	
	task.mergedSeqNo = -1;
	
	BOOL taskNew = NO;
	
	if (task.primaryKey == -1)
	{
		[task insertIntoDB:[dbm getDatabase]];
		
		taskNew = YES;
	}
	
	Task *taskFound = nil;
	
	if (isOfCheckList)
	{
		if (taskPlacement == 0) //on top
		{
			if (planTaskList.count > 0)
			{
				[planTaskList insertObject:task atIndex:0];
			}
			else 
			{
				[planTaskList addObject:task];
			}
		}
		else 
		{
			[planTaskList addObject:task];
		}		
	}
	else
	{
		if (taskPlacement == 0) //on top
		{
			if (list.count > 0)
			{
				[list insertObject:task atIndex:0];
			}
			else 
			{
				[list addObject:task];
			}
		}
		else 
		{
			[list addObject:task];
		}
		
		for (int i=0; i<list.count; i++)
		{
			Task *tmp = [list objectAtIndex:i];
			
			if (tmp.project == task.project)
			{
				[planTaskList addObject:tmp];
			}
			
			if (!taskNew && tmp.primaryKey == task.primaryKey && 
				((taskPlacement == 0 && tmp != task) || (taskPlacement == 1 && tmp == task)))
			{
				//in case Task update (not insert) there is an existing Task id in the list -> bypass
				taskFound = tmp;
				continue;
			}	
			
			tmp.mergedSeqNo = (taskFound == nil?i:i-1);
			
			//////printf("sort merge task %s: - task Found: %s - seqNo: %d\n", [tmp.name UTF8String], [taskFound?@"YES":@"NO" UTF8String], tmp.mergedSeqNo);			
			
			[tmp updateMergedSeqNoIntoDB:[dbm getDatabase]];			
		}
		
		if (taskFound != nil)
		{
			//remove the same task from list in case of update (not insert)
			[list removeObject:taskFound];
			[planTaskList removeObject:taskFound];
		}		
	}
	
	taskFound = nil;
	
	for (int i=0; i<planTaskList.count; i++)
	{
		Task *tmp = [planTaskList objectAtIndex:i];
		
		if (!taskNew && tmp.primaryKey == task.primaryKey && 
			((taskPlacement == 0 && tmp != task) || (taskPlacement == 1 && tmp == task)))
		{
			taskFound = tmp;
			continue;
		}
		
		tmp.sequenceNo = (taskFound == nil?i:i-1);
		//////printf("sort task %s: - task Found: %s - seqNo: %d\n", [tmp.name UTF8String], [taskFound?@"YES":@"NO" UTF8String], tmp.sequenceNo);
		
		[tmp updateSeqNoIntoDB:[dbm getDatabase]];					
	}
	
	//////NSLog(@"end sort tasks");
	
	return list;
}

- (BOOL) populateTask:(Task *)task
{
    /*
	if (![task isTask])
	{
		return NO;
	}
    */
    
	BOOL reSchedule = NO;
	
	DBManager *dbm = [DBManager getInstance];
	TaskManager *tm = [TaskManager getInstance];
    Settings *settings = [Settings getInstance];
	
	NSInteger taskPlacement = [[Settings getInstance] newTaskPlacement];
    
	//BOOL isOfCheckList = [[ProjectManager getInstance] checkListStyle:task.project];
	
	if (taskPlacement == 0) //on top
	{
		task.sequenceNo = [dbm getTaskMinSortSeqNo] - 1;
	}
	else 
	{
		task.sequenceNo = [dbm getTaskMaxSortSeqNo] + 1;
	}
	
	if (task.primaryKey == -1)
	{
		[task insertIntoDB:[dbm getDatabase]];
		
		self.lastTaskDuration = (task.duration > 0? task.duration: self.lastTaskDuration);		
		self.lastTaskProjectKey = task.project;
		
	}
	else 
	{
		[task updateIntoDB:[dbm getDatabase]];
	}
    
    if (settings.hideFutureTasks && task.startTime != nil && [Common daysBetween:task.startTime sinceDate:[NSDate date]] >= 1)
    {
        //future tasks
        return reSchedule;
    }
    
    if ([task checkMustDo] && ![task isDone])
    {
        reSchedule = YES;
        
        //task.mustDo = YES;
    
        [self.mustDoTaskList addObject:task];
        
        [Common sortList:self.mustDoTaskList byKey:@"deadline" ascending:YES];
        
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskListReadyNotification" object:nil];
        
        reSchedule = YES;
    }
	else if (tm.taskTypeFilter == TASK_FILTER_TOP || tm.taskTypeFilter == TASK_FILTER_DUE || tm.taskTypeFilter == TASK_FILTER_ACTIVE || tm.taskTypeFilter == TASK_FILTER_LONG || tm.taskTypeFilter == TASK_FILTER_SHORT)
	{
        [tm filterTaskList];
		
		reSchedule = YES;
	}
	else 
	{
		BOOL filterIn = [self checkFilterIn:task] && [self checkGlobalFilterIn:task];
		
		//if (filterIn && !isOfCheckList)
        if (filterIn)
		{
			if (taskPlacement == 0) //on top
			{
				if (self.taskList.count > 0)
				{
					[self.taskList insertObject:task atIndex:0];
				}
				else 
				{
					[self.taskList addObject:task];
				}
			}
			else 
			{
				[self.taskList addObject:task];
			}
			
			//[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskListReadyNotification" object:nil];
			reSchedule = YES;
		}
		
	}
    
	return reSchedule;
}

- (BOOL) addTask:(Task *)task
{
	BOOL reSchedule = NO;
	
	BOOL filterIn = NO;
    
    if ([task isRE])
    {
        //take the start time of the first instance
        
        Task *firstInstance = [self findRTInstance:task fromDate:task.startTime];
        
        if (firstInstance != nil)
        {
            task.startTime = firstInstance.startTime;
            task.endTime = firstInstance.endTime;
        }
        
    }
	
	if ([task isTask])
	{
		reSchedule = [self populateTask:task];
		
		filterIn = reSchedule;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskCreatedNotification" object:task];
	}
	else 
	{
		[task insertIntoDB:[[DBManager getInstance] getDatabase]];
		 
		filterIn = [self checkFilterIn:task] && [self checkGlobalFilterIn:task];
		
		if (filterIn)
		{
			if ([task isRE])
			{
				[self populateRE:task isNew:YES];
				
				//reSchedule = (task.type == TYPE_EVENT);
			}
			else if ([task isNREvent])
			{
				[self populateEvent:task];
			}
            
            reSchedule = [task isNormalEvent];
		}
        
        if ([task isEvent])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"EventChangeNotification" object:nil];
        }
        else if ([task isNote])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NoteChangeNotification" object:nil];
        }
	}

	if (reSchedule)
	{
		[self scheduleTasks];
	}
    
	return filterIn;
}

- (Task *) getTask2Update:(Task *)taskEdit
{
	if (taskEdit.original != nil && ![taskEdit isREException])
	{
		taskEdit = taskEdit.original;
	}
    
    Task *slTask = taskEdit;
    
    if (taskEdit.listSource != SOURCE_SMARTLIST || taskEdit.listSource != SOURCE_CALENDAR)
    {
        slTask = [self findSmartTask:taskEdit];
        
        if (slTask == nil)
        {
            slTask = taskEdit;
        }
    }
    
    return slTask;
}

-(BOOL) updateTask:(Task *)taskEdit withTask:(Task *)task
{
    BOOL isSplitted = taskEdit.isSplitted && [taskEdit isTask];
    
    Task *slTask = [self getTask2Update:taskEdit];

    [slTask retain];
        
    BOOL reSchedule = NO;
    
    if (slTask != nil)
    {
        DBManager *dbm = [DBManager getInstance];
        ProjectManager *pm = [ProjectManager getInstance];
        TaskLinkManager *tlm = [TaskLinkManager getInstance];
        Settings *settings = [Settings getInstance];
        
        Project *originalProject = [pm getProjectByKey:slTask.project];
        Project *newProject = [pm getProjectByKey:task.project];

        BOOL timeChange = [slTask.startTime compare:task.startTime] != NSOrderedSame || [slTask.endTime compare:task.endTime] != NSOrderedSame;
        
        BOOL reChange = ([slTask isRE] && [task isNREvent]) ||
        ([slTask isNREvent] && [task isRE]);
        
        BOOL reRuleChange = ![RepeatData isEqual:slTask.repeatData toAnother:task.repeatData];
        
        BOOL taskChange = ([slTask isEvent] && [task isTask]) || ([slTask isTask] && [task isEvent]);
        
        BOOL typeChange = (slTask.type != task.type); // ADE->Event or Event->ADE, this includes taskChange
        
        BOOL exceptionChange = [slTask isREException] && taskChange;
        
        BOOL alertDataChange = ![[slTask alertsToString] isEqualToString:[task alertsToString]];
        
        BOOL alertTimeChange = ([slTask isTask] && [slTask.deadline compare:task.deadline] != NSOrderedSame) || ([slTask isEvent] && [slTask.startTime compare:task.startTime] != NSOrderedSame);
        
        BOOL durationChange = (slTask.duration != task.duration);
        
        BOOL projectChange = (slTask.project != task.project);
        
        //BOOL projectStatusChange = (originalProject.status != newProject.status); //transparent change
        BOOL transChange = (originalProject.isTransparent != newProject.isTransparent);
        
        BOOL dueLost = (slTask.deadline != nil && task.deadline == nil && self.taskTypeFilter == TASK_FILTER_DUE) ||
		(slTask.startTime != nil && task.startTime == nil && self.taskTypeFilter == TASK_FILTER_ACTIVE);
        
        BOOL starLost = (slTask.status == TASK_STATUS_PINNED && task.status != TASK_STATUS_PINNED && self.taskTypeFilter == TASK_FILTER_STAR);
        
        BOOL becomeDue = (slTask.deadline == nil && task.deadline != nil && self.taskTypeFilter == TASK_FILTER_DUE) ||
        (slTask.startTime == nil && task.startTime != nil && self.taskTypeFilter == TASK_FILTER_ACTIVE);	

        BOOL needSort = (slTask.deadline != nil && task.deadline != nil && [slTask.deadline compare:task.deadline] != NSOrderedSame && self.taskTypeFilter == TASK_FILTER_DUE) ||
        (slTask.startTime != nil && task.startTime != nil && [slTask.startTime compare:task.startTime] != NSOrderedSame && self.taskTypeFilter == TASK_FILTER_ACTIVE)
            || (slTask.duration != task.duration && (self.taskTypeFilter == TASK_FILTER_SHORT || self.taskTypeFilter == TASK_FILTER_LONG));
        
        BOOL mustDoLost = ([slTask checkMustDo] && ![task checkMustDo]);
        //BOOL becomeMustDo = (![slTask checkMustDo] && [task checkMustDo]);
        BOOL becomeMustDo = [task checkMustDo]; // to fix bug: move a non due task to MM then choose Edit -> assign a Due date but it is still non-due list -> must remove from the list
        BOOL mustDoChange = ([slTask checkMustDo] && [task checkMustDo] && [Common compareDateNoTime:slTask.deadline withDate:task.deadline] != NSOrderedSame);
        
        BOOL futureLost = settings.hideFutureTasks && ([Common daysBetween:slTask.startTime sinceDate:[NSDate date]] >= 1 && task.startTime != nil && [Common daysBetween:task.startTime sinceDate:[NSDate date]] <= 0);
        
        BOOL becomeFuture = settings.hideFutureTasks && ([Common daysBetween:slTask.startTime sinceDate:[NSDate date]] <= 0 && task.startTime != nil && [Common daysBetween:task.startTime sinceDate:[NSDate date]] >= 1);
        
        reSchedule = reChange || reRuleChange || typeChange || durationChange || dueLost || becomeDue || needSort || mustDoLost || becomeMustDo || mustDoChange || transChange || futureLost || becomeFuture || starLost;
        
        if ([slTask isRE] && [task isNREvent])
        {
            [[DBManager getInstance] deleteTasksInGroup:slTask.primaryKey]; //delete all exceptions
            slTask.exceptions = nil;
        }
        
        BOOL taskReset = NO;
        NSMutableArray *links = nil;
        
        if (taskChange) 
        {
            if ([task isEvent])
            {
                [[TimerManager getInstance] check2CompleteTask:slTask.primaryKey];
            }
            
            if ((![slTask.syncId isEqualToString:@""] || ![slTask.sdwId isEqualToString:@""])) //already synced
            {
                links = [tlm getLinks4Task:taskEdit.primaryKey];
                
                //[slTask deleteFromDatabase:[dbm getDatabase]];
                [self deleteTask:slTask];
                
                taskReset = YES;                
            }
        }
        
        if ([slTask isTask] && (taskChange || projectChange || dueLost || mustDoLost || becomeMustDo || becomeFuture || starLost))
        {
            //[self garbage:slTask];
            
            [self removeTask:slTask status:-1];
        }
        else if ([slTask isRE])
        {
            [self removeEvent:slTask];
            
            if (typeChange || reChange)
            {
                [self removeRE:slTask];
            }		
        }
        else if (exceptionChange)
        {
            [self removeEvent:slTask];
        }
        else if ([slTask isNREvent] && (typeChange || reChange || timeChange))
        {
            [self removeEvent:slTask];
        }
        
        if ([task isTask] && task.alerts.count > 0 && task.deadline == nil)
        {
            //task has no dealine -> clear alerts
            task.alerts = [NSMutableArray arrayWithCapacity:0];
        }
        
        if (alertDataChange || alertTimeChange || taskChange)
        {
            //[[AlertManager getInstance] removeAllAlertsForTask:slTask];
            [[AlertManager getInstance] cancelAllAlertsForTask:slTask];
        }
        
        if (projectChange)
        {
            slTask.tag = [TagDictionary updateTag:slTask.tag removeList:originalProject.tag addList:newProject.tag];
        }
        
        [slTask updateByTask:task];
        
        if ([slTask isTask] && slTask.deadline == nil && slTask.alerts.count > 0)
        {
            for (AlertData *alert in slTask.alerts)
            {
                if (alert.primaryKey > -1)
                {
                    [alert deleteFromDatabase:[[DBManager getInstance] getDatabase]];
                }
            }
            
            slTask.alerts = [NSMutableArray arrayWithCapacity:0];
        }
        
        if (exceptionChange)
        {
            slTask.repeatData = nil;
            slTask.original = nil;
            slTask.groupKey = -1;
        }
        
        if (taskReset) //already synced
        {
            slTask.primaryKey = -1;
            slTask.syncId = @"";
            slTask.sdwId = @"";
            slTask.status = TASK_STATUS_NONE;		
        }	
        
        if (slTask.primaryKey != -1)
        {
            [slTask updateIntoDB:[dbm getDatabase]];
        }
        else if ([slTask isEvent])
        {
            [slTask insertIntoDB:[dbm getDatabase]];
        }
        
        if (alertDataChange || alertTimeChange || taskChange)
        {
            [[AlertManager getInstance] generateAlertsForTask:slTask];
        }
        
        reSchedule = reSchedule || isSplitted || ([slTask isEvent] && timeChange) || ([slTask isTask] && (projectChange || typeChange || taskChange));
        
        if ([slTask isTask])
        {
            if (taskChange || projectChange || becomeDue || becomeMustDo || mustDoLost || futureLost)
            {
                [self populateTask:slTask];
            }
            else if (mustDoChange)
            {
                [Common sortList:self.mustDoTaskList byKey:@"deadline" ascending:YES];
                
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskListReadyNotification" object:nil];
            }
            
            if (needSort)
            {
                [self resort];
            }
        }
        else if (taskChange && self.taskTypeFilter == TASK_FILTER_TOP)
        {
            //refresh Top tasks
            
            [self filterTaskList];
        }
        
        if ([slTask isRE])
        {
            [self populateRE:slTask isNew:(typeChange || reChange)];
        }
        else if ([slTask isNREvent] && (typeChange || reChange || timeChange))
        {
            [self populateEvent:slTask];
        }
        
        if (taskReset && links != nil)
        {
            //recover links for converted item with new primary key
            
            for (Link *link in links)
            {
                if (link.srcId == task.primaryKey)
                {
                    link.srcId = slTask.primaryKey;
                }
                else if (link.destId == task.primaryKey)
                {
                    link.destId = slTask.primaryKey;
                }
                
                [tlm createLink:link.srcId destId:link.destId destType:ASSET_ITEM];
            }
            
        }
        
        BOOL filterIn = [self checkGlobalFilterIn:slTask];
        
        if (!filterIn)
        {
            if ([slTask isEvent])
            {
                [self removeEvent:slTask];
                
                if ([slTask isRE])
                {
                    [self removeRE:slTask];
                }            
            }
            else if ([slTask isTask])
            {
                [self removeTask:slTask status:-1];
            }
            
            reSchedule = YES;
        }        
        
        if (reSchedule)
        {
            [self scheduleTasks];
        }
        else //if (dummyUpdate)
        {
            /*Task *tmp = [self findScheduledTask:slTask];
            
            if (tmp != nil)
            {
                NSDate *startTime = [[tmp.startTime retain] autorelease];
                NSDate *endTime = [[tmp.endTime retain] autorelease];
                [tmp updateByTask:slTask];
                tmp.startTime = startTime;
                tmp.endTime = endTime;						
            }	
            */
            
            NSMutableArray *list = [self findScheduledTasks:slTask];

            for (Task *tmp in list)
            {
                NSDate *startTime = [[tmp.startTime retain] autorelease];
                NSDate *endTime = [[tmp.endTime retain] autorelease];
                [tmp updateByTask:slTask];
                tmp.startTime = startTime;
                tmp.endTime = endTime;
            }
        }
        
        if (taskChange || typeChange)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"EventChangeNotification" object:nil];
        }
        else if ([slTask isTask])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];
        }
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"EventChangeNotification" object:nil];
        }        
    }    
    
    [slTask release];
    
    return reSchedule;
}

-(void)createREException:(Task *)instance originalTime:(NSDate *)originalTime
{
    DBManager *dbm = [DBManager getInstance];
    
    Task *rootRE = instance.original;
    
    BOOL only1Instance = NO;
    
    //printf("create RE exception - instance date:%s - root start: %s\n", [[instance.startTime description] UTF8String], [[rootRE.startTime description] UTF8String]);
    
    if ([self checkFirstInstance:instance rootRE:rootRE])
    {
        NSInteger days = [Common daysBetween:rootRE.endTime sinceDate:rootRE.startTime];
        
        Task *nextInstance = [self findRTInstance:rootRE fromDate:[Common dateByAddNumDay:days+1 toDate:instance.startTime]];
        
        if (nextInstance == nil)
        {
            only1Instance = YES;
        }
        /*else 
        {
            //exception is the first instance -> update RE start time to next instance
            
            rootRE.startTime = nextInstance.startTime;
            rootRE.endTime = nextInstance.endTime;
            
            [rootRE updateIntoDB:[dbm getDatabase]];
        }*/
    }
    
    if (only1Instance)
    {
        [rootRE retain];
        
        [self removeEvent:rootRE];
        [self removeRE:rootRE];
        
        rootRE.repeatData = nil;
        rootRE.type = TYPE_EVENT;
        rootRE.startTime = instance.startTime;
        rootRE.endTime = instance.endTime;
        
        [rootRE updateIntoDB:[dbm getDatabase]];
        
        instance.primaryKey = rootRE.primaryKey;
        instance.groupKey = -1;
        
        //[self populateEvent:rootRE];
        
        [rootRE release];
    }
    else 
    {
        [self deleteREInstance:instance];
        
        NSDate *dt = [Common clearTimeForDate:originalTime];
        NSNumber *dtValue = [NSNumber numberWithDouble:[dt timeIntervalSince1970]];	
        
        RepeatData *repDat = [[RepeatData alloc] init];
        instance.repeatData = repDat;
        [repDat release];
        
        instance.groupKey = instance.original.primaryKey;
        instance.repeatData.originalStartTime = dt;
        instance.links = [NSMutableArray arrayWithCapacity:0];
        
        [instance insertIntoDB:[dbm getDatabase]];
        
        /*
        if (instance.original.exceptions == nil)
        {
            instance.original.exceptions = [NSMutableDictionary dictionaryWithCapacity:5];
        }
        
        [instance.original.exceptions setObject:instance forKey:dtValue];
        */
        //printf("add exception on date: %d, exception count = %d\n", [dtValue intValue], instance.original.exceptions.count);
    }
}

-(BOOL) changeRE:(Task *)re withUntil:(NSDate *)until
{
    //until = [Common dateByAddNumSecond:-1 toDate:[Common getEndDate:until]];
    until = [Common getEndDate:until];
    
    if ([Common compareDate:until withDate:re.startTime] == NSOrderedAscending)
    {
        [self deleteRE:re];
        
        return YES;
    }
    
	re.repeatData.until = until;
	
	Task *delExc = nil;
	
	NSMutableArray *removeDelDates = [NSMutableArray arrayWithCapacity:5];
	
	if (re.exceptions != nil)
	{
		for (NSNumber *key in [re.exceptions allKeys])
		{
			NSDate *excDate = [NSDate dateWithTimeIntervalSince1970:[key doubleValue]];
			
			if ([Common compareDateNoTime:until withDate:excDate] == NSOrderedAscending)
			{
				Task *exc = [re.exceptions objectForKey:key];
				
				if (exc.type == TYPE_RE_DELETED_EXCEPTION)
				{
					if (delExc == nil)
					{
						delExc = [[exc retain] autorelease];
					}
					else 
					{
						for (NSDate *date in delExc.repeatData.deletedExceptionDates)
						{
							if ([Common compareDateNoTime:date withDate:excDate] == NSOrderedSame)
							{
								[removeDelDates addObject:date];
								
								break;
							}
						}
					}
					
				}
				else 
				{
					[exc deleteFromDatabase:[[DBManager getInstance] getDatabase]];
				}
				
				[re.exceptions removeObjectForKey:key];				
			}
		}
	}
	
	if (delExc != nil)
	{
		for (NSDate *date in removeDelDates)
		{
			[delExc.repeatData.deletedExceptionDates removeObject:date];
		}
		
		[delExc updateIntoDB:[[DBManager getInstance] getDatabase]];
	}
    
    return NO;
}

-(void)updateREInstance:(Task *)instance withRE:(Task *)re updateOption:(NSInteger) updateOption
{
    DBManager *dbm = [DBManager getInstance];
    
	NSDate *oldTime = [instance.startTime copy];
    
    Task *rootRE = instance.original;
    
	[self removeEvent:rootRE];
    
    BOOL typeChange = (rootRE.type != re.type);
    
    BOOL recurringChange = (rootRE.repeatData != nil && re.repeatData == nil);
	
	switch (updateOption) 
	{
		case 1: //only this instance
		{
			RepeatData *rpt = [[instance.repeatData retain] autorelease];
			
            if (typeChange)
            {
                //delete the exception
                [self deleteREInstance:instance deleteOption:1];
                
                [instance updateByTask:re];
                
                instance.repeatData = nil;
                instance.groupKey = -1;
                instance.original = nil;
                
                [instance insertIntoDB:[dbm getDatabase]];
                
                [self populateEvent:instance];
            }
            else 
            {
                if (rpt == nil)
                {
                    [self createREException:instance originalTime:oldTime];
                    
                    rpt = [[instance.repeatData retain] autorelease];
                    int pk = instance.primaryKey;
                    int groupKey = instance.groupKey;
                    
                    [instance updateByTask:re];
                    
                    instance.primaryKey = pk;
                    instance.groupKey = groupKey;
                    instance.repeatData = rpt;
                    
                    
                    [instance updateIntoDB:[dbm getDatabase]];
                    
                    [self populateEvent:instance];
                }
                else //is an Exception already 
                {
                    [instance updateByTask:re];
                                        
                    instance.repeatData = rpt;
                    
                    [instance updateIntoDB:[dbm getDatabase]];
                }
                
                if (instance.groupKey != -1)
                {
                    //if instance groupKey is -1, that means root RE has only 1 instance and it was converted into normal event when creating exception
                    [self populateRE:rootRE isNew:NO];
                }
            }
		}
			break;
		case 2: //all in series
		{
            [rootRE retain];
            
            if (typeChange || recurringChange)
            {
                [self removeRE:rootRE];
            }
            
            if ([rootRE.repeatData.until compare:re.startTime] == NSOrderedAscending)
            {
                //start exceeds until -> delete
                
                [self deleteRE:rootRE];
            }
            else
            {
                //NSDate *rootStart = [Common copyTimeFromDate:re.startTime toDate:rootRE.startTime];
                //NSTimeInterval duration = [re.endTime timeIntervalSinceDate:re.startTime];
                
                [rootRE updateByTask:re];
                
                //rootRE.startTime = rootStart;
                //rootRE.endTime = [rootStart dateByAddingTimeInterval:duration];
                
                [rootRE updateIntoDB:[dbm getDatabase]];
                
                if ([rootRE isRE])
                {
                    [self populateRE:rootRE isNew:typeChange];
                }
                else if ([rootRE isEvent])
                {
                    [self populateEvent:rootRE];
                }                
            }
                        
            [rootRE release];
		}
			break;
		case 3: //all following
		{
			Task *newRE = [rootRE copy];
            newRE.primaryKey = -1;
            newRE.syncId = @"";
            newRE.sdwId = @"";
            newRE.links = [NSMutableArray arrayWithCapacity:0];
			
			BOOL reDeletion = [self changeRE:rootRE withUntil:[Common dateByAddNumDay:-1 toDate:oldTime]];
            
            if (!reDeletion)
            {
                [rootRE updateIntoDB:[dbm getDatabase]];
                
                [self populateRE:rootRE isNew:NO];
			}
            
            [newRE updateByTask:re];
            			
			if (newRE.repeatData.until != nil &&[Common compareDateNoTime:newRE.repeatData.until withDate:newRE.startTime] == NSOrderedAscending)
			{
				newRE.repeatData.until = nil;
			}
			
			[newRE insertIntoDB:[dbm getDatabase]];
						
            if ([newRE isRE])
            {
                [self populateRE:newRE isNew:YES];
            }
            else if ([newRE isEvent])
            {
                [self populateEvent:newRE];
            }
			
			[newRE release];
		}
			break;
	}
	
	[oldTime release];
	
	[self scheduleTasks];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:@"EventChangeNotification" object:nil];
}

- (void)deleteRE:(Task *)rootRE
{
    DBManager *dbm = [DBManager getInstance];
    //TaskLinkManager *tlm = [TaskLinkManager getInstance];
    
    [rootRE retain];
    
    [self removeRE:rootRE];
    
    //[tlm deleteAllLinks4Task:rootRE];
    
    [dbm deleteTasksInGroup:rootRE.primaryKey];
    
    [rootRE deleteFromDatabase:[dbm getDatabase]];
    [rootRE release];    
}

-(BOOL)checkFirstInstance:(Task *)instance rootRE:(Task *)rootRE
{
    Task *firstInstance = [self findRTInstance:rootRE fromDate:rootRE.startTime];
    
    //printf("first instance date: %s - instance date: %s\n", [[firstInstance.startTime description] UTF8String], [[instance.startTime description] UTF8String]);

    BOOL checkFirstInstance = ([Common compareDateNoTime:firstInstance.startTime withDate:instance.startTime] == NSOrderedSame);
    
    return checkFirstInstance;
}

- (void) deleteREInstance:(Task *)instance
{
    DBManager *dbm = [DBManager getInstance];
    
    Task *delExc = [[DBManager getInstance] getDeletedExceptionForRE:instance.original.primaryKey];
    
    if (delExc == nil)
    {
        delExc = [[instance copy] autorelease];
        
        delExc.primaryKey = -1;
        delExc.type = TYPE_RE_DELETED_EXCEPTION;
        delExc.groupKey = instance.original.primaryKey;
        delExc.alerts = nil;
        
        RepeatData *repDat = [[RepeatData alloc] init];
        delExc.repeatData = repDat;
        [repDat release];
        
        delExc.repeatData.deletedExceptionDates = [NSMutableArray arrayWithCapacity:1];
        
        [delExc insertIntoDB:[dbm getDatabase]];
    }
    
    [delExc.repeatData.deletedExceptionDates addObject:instance.startTime];
    
    [delExc updateRepeatDataIntoDB:[dbm getDatabase]];
    
    if (instance.original.exceptions == nil)
    {
        instance.original.exceptions = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    /*
    for (NSDate *date in delExc.repeatData.deletedExceptionDates)
    {
        NSDate *dt = [Common clearTimeForDate:date];
        
        [instance.original.exceptions setObject:delExc forKey:[NSNumber numberWithDouble:[dt timeIntervalSince1970]]];
    }  
    */
    
    NSDate *dt = [Common clearTimeForDate:instance.startTime];
    [instance.original.exceptions setObject:delExc forKey:[NSNumber numberWithDouble:[dt timeIntervalSince1970]]];
    
    [instance.original modifyUpdateTimeIntoDB:[dbm getDatabase]];
}

-(void)deleteREInstance:(Task *)instance deleteOption:(NSInteger) deleteOption
{	
    DBManager *dbm = [DBManager getInstance];
    
    Task *rootRE = instance.original;
    
    [rootRE retain];
    
	[self removeEvent:rootRE];
	
	switch (deleteOption) 
	{
		case 1: //only this instance
		{
            [[AlertManager getInstance] cancelAllAlertsForTask:rootRE];
                        
            if ([self checkFirstInstance:instance rootRE:rootRE])
            {
                //delete first instance -> shift start date of root RE
                NSInteger days = [Common daysBetween:rootRE.endTime sinceDate:rootRE.startTime];
                
                Task *nextInstance = [self findRTInstance:rootRE fromDate:[Common dateByAddNumDay:days+1 toDate: instance.startTime]];
                
                if (nextInstance != nil)
                {
                    //next instance found
                    NSTimeInterval duration = [rootRE.endTime timeIntervalSinceDate:rootRE.startTime];
                    
                    rootRE.startTime = [Common copyTimeFromDate:rootRE.startTime toDate:nextInstance.startTime];
                    rootRE.endTime = [rootRE.startTime dateByAddingTimeInterval:duration];
                    
                    //printf("move root RE time - start:%s - end:%s\n", [[rootRE.startTime description] UTF8String], [[rootRE.endTime description] UTF8String]);
                    
                    [rootRE updateIntoDB:[dbm getDatabase]];
                                        
                    //[self populateRE:rootRE isNew:NO];
                }
                else 
                {
                    //next instance not found -> delete root RE
                
                    [self deleteRE:rootRE];
                }
                
                break;
            }
            
            [self deleteREInstance:instance];
			
			[self populateRE:rootRE isNew:NO];
            
            [[AlertManager getInstance] generateAlertsForTask:rootRE];            
			
		}
			break;
		case 2: //all in series
		{
            [self removeExceptions4RE:rootRE];
            
            [[AlertManager getInstance] cancelAllAlertsForTask:rootRE];
            
            [self deleteRE:rootRE];
		}
			break;
		case 3: //all following
		{
            [[AlertManager getInstance] cancelAllAlertsForTask:rootRE];
            
            if ([self checkFirstInstance:instance rootRE:rootRE])
            {
                //change all exceptions into normal first before deleting the root
                //[self removeEvent:rootRE];
                [self removeExceptions4RE:rootRE];
                
                NSMutableArray *excList = [dbm getExceptionsForRE:rootRE.primaryKey];
                
                for (Task *exc in excList)
                {
                    if ([Common compareDate:exc.startTime withDate:instance.startTime] == NSOrderedAscending)
                    {
                        exc.repeatData = nil;
                        exc.groupKey = -1;
                        [exc updateIntoDB:[dbm getDatabase]];
                        
                        [self populateEvent:exc];
                    }
                }                
                
                //delete first instance -> delete root RE
                [self deleteRE:rootRE];
            }
            else 
            {
                [self changeRE:rootRE withUntil:[Common dateByAddNumDay:-1 toDate:instance.startTime]];
                
                [rootRE updateIntoDB:[dbm getDatabase]];
                
                [self populateRE:rootRE isNew:NO];
                
                [[AlertManager getInstance] generateAlertsForTask:rootRE];
            }
		}
			break;
	}
    
    [rootRE release];
	
	[self scheduleTasks];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"EventChangeNotification" object:nil];
}

-(Task *)convertRE2Task:(Task *)instance option:(NSInteger) option
{	
    Task *ret = nil;
    
    DBManager *dbm = [DBManager getInstance];
    
    Task *rootRE = instance.original;
    
	[self removeEvent:rootRE];
	
	switch (option) 
	{
		case 1: //only this instance
		{
            if ([self checkFirstInstance:instance rootRE:rootRE])
            {
                //convert first instance -> shift start date of root RE
                NSInteger days = [Common daysBetween:rootRE.endTime sinceDate:rootRE.startTime];

                Task *nextInstance = [self findRTInstance:rootRE fromDate:[Common dateByAddNumDay:days+1 toDate:instance.startTime]];
                
                if (nextInstance != nil)
                {
                    //next instance found
                    NSTimeInterval duration = [rootRE.endTime timeIntervalSinceDate:rootRE.startTime];
                    
                    rootRE.startTime = [Common copyTimeFromDate:rootRE.startTime toDate:nextInstance.startTime];
                    rootRE.endTime = [rootRE.startTime dateByAddingTimeInterval:duration];
                    
                    [rootRE updateIntoDB:[dbm getDatabase]];
                    
                    [self populateRE:rootRE isNew:NO];
                }
                else 
                {
                    //next instance not found -> delete root RE
                    
                    [self deleteRE:rootRE];
                }
            }
            else 
            {
                Task *delExc = [[DBManager getInstance] getDeletedExceptionForRE:rootRE.primaryKey];
                
                if (delExc == nil)
                {
                    delExc = [[instance copy] autorelease];
                    
                    delExc.primaryKey = -1;
                    delExc.type = TYPE_RE_DELETED_EXCEPTION;
                    delExc.groupKey = rootRE.primaryKey;
                    
                    RepeatData *repDat = [[RepeatData alloc] init];
                    delExc.repeatData = repDat;
                    [repDat release];
                    
                    delExc.repeatData.deletedExceptionDates = [NSMutableArray arrayWithCapacity:1];
                    
                    [delExc insertIntoDB:[dbm getDatabase]];
                }
                
                [delExc.repeatData.deletedExceptionDates addObject:instance.startTime];
                
                [delExc updateRepeatDataIntoDB:[dbm getDatabase]];
                
                if (rootRE.exceptions == nil)
                {
                    rootRE.exceptions = [NSMutableDictionary dictionaryWithCapacity:1];
                }
                
                for (NSDate *date in delExc.repeatData.deletedExceptionDates)
                {
                    NSDate *dt = [Common clearTimeForDate:date];
                    
                    [rootRE.exceptions setObject:delExc forKey:[NSNumber numberWithDouble:[dt timeIntervalSince1970]]];
                }
                
                [rootRE modifyUpdateTimeIntoDB:[dbm getDatabase]];
                
                [self populateRE:instance.original isNew:NO];                
            }
            
			instance.type = TYPE_TASK;
            instance.repeatData = nil;
            instance.original = nil;
            instance.primaryKey = -1;
            
            ret = instance;
            
            [self populateTask:instance];
            
            //[instance insertIntoDB:[dbm getDatabase]];
		}
			break;
		case 2: //all following
		{            
            if ([self checkFirstInstance:instance rootRE:rootRE])
            {
                [rootRE retain];
                
                [self removeRE:rootRE];
                
                if (![rootRE.syncId isEqualToString:@""] || ![rootRE.sdwId isEqualToString:@""]) //already synced
                {
                    [rootRE deleteFromDatabase:[dbm getDatabase]];
                    
                    rootRE.syncId = @"";
                    rootRE.sdwId = @"";
                    rootRE.primaryKey = -1;
                    rootRE.status = TASK_STATUS_NONE;
                }
                
                // first instance -> convert root RE
                rootRE.type = TYPE_TASK;
                rootRE.repeatData.until = nil;
                rootRE.updateTime = [NSDate date];
                //[rootRE modifyUpdateTimeIntoDB:[dbm getDatabase]];
                
                ret = rootRE;
                
                [self populateTask:rootRE];
                
                [rootRE release];
            }
            else 
            {
                [self changeRE:rootRE withUntil:[Common dateByAddNumDay:-1 toDate:instance.startTime]];
                
                [rootRE updateIntoDB:[dbm getDatabase]];
                
                [self populateRE:rootRE isNew:NO];
                
                instance.type = TYPE_TASK;
                instance.primaryKey = -1;
                instance.sdwId = @"";
                instance.syncId = @"";
                instance.original = nil;
                instance.repeatData = rootRE.repeatData;
                instance.repeatData.until = nil;
                
                ret = instance;
                
                [self populateTask:instance];
            }
		}
			break;
	}
	
	[self scheduleTasks];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"EventChangeNotification" object:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];
    
    if (ret != nil)
    {
        return [[ret retain] autorelease];
    }
    
    return nil;
}


- (void)removeTaskByKey:(NSInteger)taskKey
{
	Task *taskFound = nil;
	
	for (Task *task in self.taskList)
	{
		if (task.primaryKey == taskKey)
		{
			taskFound = task;
			break;
		}
	}
	
	if (taskFound)
	{
		//[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskListResetNotification" object:nil];
		//[self garbage:taskFound];
        
        if ([taskFound checkMustDo])
        {
            [self.mustDoTaskList removeObject:taskFound];
        }
        else 
        {
            [self.taskList removeObject:taskFound];
        }
		
		
		//[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskListReadyNotification" object:nil];
		
		[self scheduleTasks];
	}
}

- (void)removeTasksByKey:(NSMutableArray *)tasks 
{
	NSDictionary *taskDict = [TaskManager getTaskDictionary:self.taskList];
	
	NSMutableArray *removeList = [NSMutableArray arrayWithCapacity:10];
	
	for (Task *task in tasks)
	{
		Task *found = [taskDict objectForKey:[NSNumber numberWithInt:task.primaryKey]];
		
		if (found)
		{
			[removeList addObject:found];
		}
	}
	
    /*
	if (removeList.count > 0)
	{
		//[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskListResetNotification" object:nil];
		[self garbage:removeList];
	}*/
	
	for (Task *task in removeList)
	{
        if ([task checkMustDo])
        {
            [self.mustDoTaskList removeObject:task];
        }
        else 
        {
            [self.taskList removeObject:task];
        }
	}
		
	if (removeList.count > 0)
	{
		//[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskListReadyNotification" object:nil];
		
		[self scheduleTasks];
	}
}

//-(void)removeTask:(Task *)task deleteFromDB:(BOOL)deleteFromDB
-(void)removeTask:(Task *)task status:(NSInteger)status
{
	[[AlertManager getInstance] cancelAllAlertsForTask:task];
	
	//if (task.type == TYPE_TASK)
	{
		Task *tmp = task;
		
		if ([task isPartial]) //delete split Task in Calendar View
		{
			tmp = task.original;
		}
		
        //[self garbage:tmp];
        
        if (self.taskTypeFilter == TASK_FILTER_DONE)
        {
            [self.taskList removeObject:tmp];
        }
        else 
        {
            [self.mustDoTaskList removeObject:tmp];
            
            [self.taskList removeObject:tmp];            
        }
		        
        if (status == TASK_STATUS_DELETED)
        {
            [tmp deleteFromDatabase:[[DBManager getInstance] getDatabase]];
        }
        else if (status != -1)
        {
            tmp.status = status;
            [tmp updateStatusIntoDB:[[DBManager getInstance] getDatabase]];
        }
        
		//[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskListReadyNotification" object:nil];
		
	}
}

- (Task *) doneRT:(Task *)rt
{
    DBManager *dbm = [DBManager getInstance];
    
	[[AlertManager getInstance] cancelAllAlertsForTask:rt];
    
    [[TimerManager getInstance] check2CompleteTask:rt.primaryKey];
	
	Task *instance = [[rt copy] autorelease];
	
	instance.status = TASK_STATUS_DONE;
	instance.repeatData = nil;
	instance.sequenceNo = [[DBManager getInstance] getTaskMaxSeqNoForPlan:instance.project] + 1;
	instance.mergedSeqNo = -1;
	instance.completionTime = [NSDate date];
	
	[instance insertIntoDB:[dbm getDatabase]];
    
    NSMutableArray *progressList = [dbm getAllProgressHistoryForTask:rt.primaryKey];
    
    for (TaskProgress *progress in progressList)
    {
        progress.task = instance;
        
        [progress updateIntoDB:[dbm getDatabase]];
    }
	
	Task *nextInstance = nil;
	
	if (rt.repeatData.repeatFrom == REPEAT_FROM_COMPLETION)
	{
        //NSInteger days = [Common daysBetween:rt.deadline sinceDate:rt.startTime];

		//nextInstance = [self findRTInstance:rt fromDate:[Common dateByAddNumDay:days+1 toDate:[NSDate date]]];
        nextInstance = [self findRTInstance:rt fromDate:[Common dateByAddNumDay:1 toDate:[NSDate date]]];
	}
	else // repeat from Due 
	{
        //NSInteger days = [Common daysBetween:rt.deadline sinceDate:rt.startTime];
        
		if (rt.deadline == nil)
		{
			//nextInstance = [self findRTInstance:rt fromDate:[Common dateByAddNumDay:days+1 toDate:(rt.startTime!=nil?rt.startTime:[NSDate date])]];
			nextInstance = [self findRTInstance:rt fromDate:[Common dateByAddNumDay:1 toDate:(rt.startTime!=nil?rt.startTime:[NSDate date])]];
            
		}
		else
		{
			//nextInstance = [self findRTInstance:rt fromDate:[Common dateByAddNumDay:days+1 toDate:rt.deadline]];
            nextInstance = [self findRTInstance:rt fromDate:[Common dateByAddNumDay:1 toDate:rt.deadline]];
		}
	}
    
	if (nextInstance != nil)
	{
        [self removeTask:rt status:-1];
            
		NSInteger duration = (rt.deadline == nil? 0:[Common timeIntervalNoDST:rt.deadline sinceDate:rt.startTime]);

		rt.deadline = [Common copyTimeFromDate:rt.deadline toDate:nextInstance.startTime];
        
		if (rt.startTime != nil)
		{
			rt.startTime = [Common dateByAddNumSecond:-duration toDate:rt.deadline];
		}
		
		[rt updateTimeIntoDB:[[DBManager getInstance] getDatabase]];
        
        [self populateTask:rt];
        
        [self scheduleTasks];
	}
	
	[[AlertManager getInstance] generateAlertsForTask:rt];
	
	BOOL showHint = [[Settings getInstance] rtDoneHint];
	
	if (showHint && !_rtDoneHintShown)
	{
		UIAlertView *rtDoneHintAlertView = [[UIAlertView alloc] initWithTitle:_hintText message:_rtDoneHintText delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
		
		rtDoneHintAlertView.tag = -10002;
		
		[rtDoneHintAlertView addButtonWithTitle:_dontShowText];
		[rtDoneHintAlertView show];
		[rtDoneHintAlertView release];
		
		_rtDoneHintShown = YES;
	}	
	
	return instance;
}

//- (void)doneRepeatManualTask: (Task *) rt instance: (Task *) instance {
//    
//    if (![instance isREInstance]) {
//        instance.primaryKey = -1;
//        instance.original = rt;
//    }
//    // delete instance
//    [self deleteREInstance:instance deleteOption:1];
//    
//    // insert done task into DB
//    instance.type = TYPE_TASK;
//    [instance setManual:NO];
//    instance.status = TASK_STATUS_DONE;
//    instance.completionTime = [NSDate date];
//    instance.repeatData = nil;
//    
//    [instance insertIntoDB:[[DBManager getInstance] getDatabase]];
//}

-(void) starTask:(Task *)task
{
    Task *slTask = [self getTask2Update:task];
    
	if (task.status == TASK_STATUS_PINNED)
	{
		task.status = TASK_STATUS_NONE;
	}
	else 
	{
		task.status = TASK_STATUS_PINNED;
	}
    
    slTask.status = task.status;
	
	[slTask updateStatusIntoDB:[[DBManager getInstance] getDatabase]];
    
/*	if (self.taskTypeFilter == TASK_FILTER_STAR && slTask.status == TASK_STATUS_NONE)
    {
        if (![task checkMustDo])
        {
            [self.taskList removeObject:slTask];
            
            [self scheduleTasks];
        }
    }
*/
	if (self.taskTypeFilter == TASK_FILTER_STAR && ![task checkMustDo])
    {
        BOOL reSchedule = NO;
        
        if (slTask.status == TASK_STATUS_NONE)
        {
            [self.taskList removeObject:slTask];
            
            reSchedule = YES;
        }
        else if (task.listSource == SOURCE_CATEGORY && slTask == task)
        {
            [self filterTaskList];
            
            reSchedule = YES;
        }
        
        if (reSchedule)
        {
            [self scheduleTasks];
        }
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];
}

-(void) starTasks:(NSMutableArray *)tasks
{
    sqlite3 *db = [[DBManager getInstance] getDatabase];
    
    /*
    NSInteger pin = TASK_STATUS_PINNED;
    if (self.taskTypeFilter == TASK_FILTER_STAR) {
        pin = TASK_STATUS_NONE;
    }*/

    for (Task *task in tasks) {
        Task *slTask = [self getTask2Update:task];
        
        NSInteger status = (self.taskTypeFilter == TASK_FILTER_STAR?TASK_STATUS_NONE:(slTask.status == TASK_STATUS_PINNED?TASK_STATUS_NONE:TASK_STATUS_PINNED));
        
        //task.status = pin;
        task.status = status;
                            
        slTask.status = task.status;
        [slTask updateStatusIntoDB:db];
        
        /*if (self.taskTypeFilter == TASK_FILTER_STAR) {
            [self.taskList removeObject:slTask];
        }*/
    }
    
	if (self.taskTypeFilter == TASK_FILTER_STAR)
    {
        [self scheduleTasks];
        [self.taskList removeObjectsInArray:tasks];
    }
    
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];
}

-(void) markDoneTask:(Task *)task
{
    Task *slTask = [self getTask2Update:task];
    
	if ([slTask isRT])
	{
		[self doneRT:slTask];	
    }
	else if ([slTask isTask])
	{
        //[self removeTask:slTask status:TASK_STATUS_DONE];
        
        [[TimerManager getInstance] check2CompleteTask:slTask.primaryKey];
        
        if (self.taskTypeFilter == TASK_FILTER_DONE)
        {
            slTask.status = TASK_STATUS_DONE;
            slTask.completionTime = [NSDate date];

            [self populateTask:slTask];
            
            [self resort];
        }
        else
        {
            [self removeTask:slTask status:TASK_STATUS_DONE];
        }
		
		if (self.taskTypeFilter == TASK_FILTER_TOP)
		{
			[self initSmartListData]; //to refresh next GTDo
		}
		else
		{
			[self scheduleTasks];
		}
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];
}

-(void) markDoneTasks:(NSMutableArray *)tasks
{
	BOOL refresh = NO;
	
	for (Task *task in tasks)
	{
        /*
		if ([task isRT])
		{
			[self doneRT:task];
		}
		else if ([task isTask])
		{
            [self removeTask:task status:TASK_STATUS_DONE];
			
			refresh = YES;
		}*/
        
        Task *slTask = [self getTask2Update:task];
        
        if ([slTask isRT])
        {
            [self doneRT:slTask];
        }
        else if ([slTask isTask])
        {
            [[TimerManager getInstance] check2CompleteTask:slTask.primaryKey];
            
            [self removeTask:task status:TASK_STATUS_DONE];
			
			refresh = YES;
        }
	}
	
	if (refresh)
	{
		if (self.taskTypeFilter == TASK_FILTER_TOP)
		{
			[self initSmartListData]; //to refresh next GTDo
		}
		else
		{
			[self scheduleTasks];
		}
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];
}

-(void) markUnDoneTasks:(NSMutableArray *)tasks
{
    DBManager *dbm = [DBManager getInstance];
    
	for (Task *task in tasks)
	{
        task.status = TASK_STATUS_NONE;
        
        [task updateStatusIntoDB:[dbm getDatabase]];
	}
    
    [self initSmartListData];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];
}


-(void) deleteTask:(Task *)task
{
    DBManager *dbm = [DBManager getInstance];
    
    BOOL reschedule = NO;
    
    Task *slTask = [self getTask2Update:task];
    
    [slTask retain];
    
    ////printf("task to delete %s has link count: %d\n", [slTask.name UTF8String], slTask.links.count);

    if (slTask != nil)
    {
        if ([slTask isNote])
        {
            [slTask deleteFromDatabase:[dbm getDatabase]];
        }
        else if ([slTask isTask])
        {
            [self removeTask:slTask status:TASK_STATUS_DELETED];
            
            [[TimerManager getInstance] check2DeleteTask:slTask.primaryKey];
        }
        else if ([slTask isEvent])
        {
            [self removeEvent:slTask];
            
            [slTask deleteFromDatabase:[dbm getDatabase]];
        }
        
        reschedule = YES;
    }
    /*else
    {
        [task deleteFromDatabase:[dbm getDatabase]];
    }*/
    
    if (reschedule)
    {
        if (self.taskTypeFilter == TASK_FILTER_TOP)
        {
            //GTDo filter -> need to reload task list
            [self initSmartListData];
        }
        else
        {
            [self scheduleTasks];
        }
    }
    
	if ([task isTask] || [task isNote])
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];
	}
	else if ([task isEvent])
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"EventChangeNotification" object:nil];		
	}
    
    [slTask release];
}

-(void) deleteTasks:(NSMutableArray *)tasks
{
    TaskLinkManager *tlm = [TaskLinkManager getInstance];
    
	for (Task *task in tasks)
	{
        /*
        [tlm deleteAllLinks4Task:task];
        
        [self removeTask:task status:TASK_STATUS_DELETED];*/
        
        Task *slTask = [self getTask2Update:task];

        if ([slTask isRE])
        {
            [self deleteRE:slTask];
        }
        else
        {
            [tlm deleteAllLinks4Task:slTask];
            [self removeTask:slTask status:TASK_STATUS_DELETED];
        }
	}

	if (self.taskTypeFilter == TASK_FILTER_TOP)
	{
		[self initSmartListData]; //to refresh next GTDo
	}
	else
	{
		[self scheduleTasks];	
	}	
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];
}

- (void) removeEventFromList:(NSMutableArray *)list forKey:(NSInteger)key 
{
	if (key == -1)
	{
		return;
	}
	
	NSMutableArray *removeList = [NSMutableArray arrayWithCapacity:3];
	
	for (Task *evt in list)
	{
		//if (evt.primaryKey == key || (evt.original != nil && evt.original.primaryKey == key)) // the second to remove RE exception
        if (evt.primaryKey == key || ([evt isREInstance] && evt.original.primaryKey == key))
		{
			[removeList addObject:evt];
		}
	}
	
	for (Task *evt in removeList)
	{
        [list removeObject:evt];
    }
	
}

- (void) removeExceptions4RE:(Task *)re
{
    /*
    NSMutableArray *removeList = [NSMutableArray arrayWithCapacity:5];
    
	for (Task *evt in self.todayEventList)
	{
		if (evt.original != nil && evt.original.primaryKey == re.primaryKey)
		{
			[removeList addObject:evt];
		}
	}
	
	for (Task *evt in removeList)
	{
        [self.todayEventList removeObject:evt];
    }
    */
}

- (void) removeEvent:(Task *)event
{
    /*
    if (event.type == TYPE_EVENT)
	{
		[self removeEventFromList:self.todayEventList forKey:event.primaryKey];
	}
    */
}

- (void) removeRE:(Task *)re
{
    if (re.type == TYPE_ADE)
    {
        [self.RADEList removeObject:re];				
    }
    else 
    {
        [self.REList removeObject:re];				
    }
}

- (void)moveTime:(NSDate *)date forEvent:(Task *)event
{
	NSDate *oldTime = [event.startTime copy];
    
    NSDate *dt = date;
    
    /*if (event.timeZoneId == 0 && [event isEvent])
    {
        //convert to GMT+0
        NSInteger secs = [[NSTimeZone defaultTimeZone] secondsFromGMT];
        
        dt = [date dateByAddingTimeInterval:secs];
    }*/
	
	Task *longEvent = nil;
	
	if (event.isSplitted)
	{
		longEvent = [[Task alloc] initWithPrimaryKey:event.primaryKey database:[[DBManager getInstance] getDatabase]];
	}
	
	NSInteger duration = ([event isTask]? event.duration:
						  (longEvent? [longEvent.endTime timeIntervalSinceDate:longEvent.startTime]:
                           [event.endTime timeIntervalSinceDate:event.startTime]));
    
	[longEvent release];
	
	BOOL isLong = [event isLong];
	
	isLong = isLong || [event isLong]; 
	
	if ([event isTask]) //convert Task into Event
	{
        [[AlertManager getInstance] removeAllAlertsForTask:event];
        
		if (event.original != nil)
		{
			event.primaryKey = event.original.primaryKey;
			event.syncId = event.original.syncId;
            event.links = event.original.links;
            
            [self removeTask:event.original status:-1];
			
			//[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskListReadyNotification" object:nil];
			
			event.original = nil;
		}

		event.type = TYPE_EVENT;
        event.startTime = dt;
        event.endTime = [Common dateByAddNumSecond:duration toDate:event.startTime];
        event.timeZoneId = [Settings findTimeZoneID:[NSTimeZone defaultTimeZone]];

		if (![event.syncId isEqualToString:@""]) //already synced
		{
            NSMutableArray *linkedPartnerIds = [NSMutableArray arrayWithCapacity:event.links.count];
            
            for (NSNumber *linkIdNum in event.links)
            {
                NSInteger linkedId = [[TaskLinkManager getInstance] getLinkedId4Task:event.primaryKey linkId:[linkIdNum intValue]];
                
                [linkedPartnerIds addObject:[NSNumber numberWithInt:linkedId]];
            }
            
			[event deleteFromDatabase:[[DBManager getInstance] getDatabase]];
			
			event.primaryKey = -1;
			event.syncId = @"";
			event.status = TASK_STATUS_NONE;
			
			[event insertIntoDB:[[DBManager getInstance] getDatabase]];
            
            NSMutableArray *linkList = [NSMutableArray arrayWithCapacity:linkedPartnerIds.count];
            
            for (NSNumber *idNum in linkedPartnerIds)
            {
                NSInteger linkId = [[TaskLinkManager getInstance] createLink:event.primaryKey destId:[idNum intValue] destType:ASSET_ITEM];
                
                if (linkId != -1)
                {
                    [linkList addObject:[NSNumber numberWithInt:linkId]];
                }
            }
            
            event.links = linkList;
		}
		else 
		{
			event.status = TASK_STATUS_NONE;
			[event updateIntoDB:[[DBManager getInstance] getDatabase]];
		}
				
		if ([event isRE])
		{
			[self populateRE:event isNew:YES];
		}
		else 
		{
			[self populateEvent:event];		
		}
        
        if (self.taskTypeFilter == TASK_FILTER_TOP)
        {
            //refresh Top tasks
            [self filterTaskList];
        }
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];
 	}
	else if ([event isREInstance]) //RE instances
	{
		if (event.repeatData == nil) //going to become an exception
		{
			[self createREException:event originalTime:oldTime];
		}
        
        event.startTime = dt;
        event.endTime = [Common dateByAddNumSecond:duration toDate:event.startTime];

        [event updateTimeIntoDB:[[DBManager getInstance] getDatabase]];
			
        [self removeEvent:event];
				
        [self populateEvent:event];
	}
	else 
	{
        event.startTime = dt;
        event.endTime = [Common dateByAddNumSecond:duration toDate:event.startTime];
        
		[event updateTimeIntoDB:[[DBManager getInstance] getDatabase]];				
		
        [self removeEvent:event];
        
        [self populateEvent:event];
	}
    
	event.smartTime = event.startTime;    
	
	[oldTime release];

	[self scheduleTasks];
	
	[[AlertManager getInstance] generateAlertsForTask:event];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"EventChangeNotification" object:nil];	
}

- (void)resizeTask:(Task *)task
{
    DBManager *dbm = [DBManager getInstance];
    
    if ([task isREInstance])
    {
        [self removeEvent:task];
        
        NSDate *startTime = [task.startTime retain];
        NSDate *endTime = [task.endTime retain];
        
        [self createREException:task originalTime:startTime];

        task.startTime = startTime;
        task.endTime = endTime;
        
        [task updateTimeIntoDB:[dbm getDatabase]];
    }
	else if ([task isEvent])
	{
		[task updateTimeIntoDB:[dbm getDatabase]];

		[[AlertManager getInstance] generateAlertsForTask:task];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"EventChangeNotification" object:nil];
	}
	else if ([task isTask])
	{
		[task updateDurationIntoDB:[dbm getDatabase]];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];
        
        if (self.taskTypeFilter == TASK_FILTER_LONG || self.taskTypeFilter == TASK_FILTER_SHORT)
        {
            [self filterTaskList];
        }
	}
	
	[self scheduleTasks];
}

- (void) changeOrder:(Task *)srcTask destTask:(Task *)destTask
{
    //printf("change order src = %s - dest: %s\n", [srcTask.name UTF8String], [destTask.name UTF8String]);
	DBManager *dbm = [DBManager getInstance];
	
	if (srcTask.original != nil && srcTask.primaryKey == -1)
	{
		srcTask = srcTask.original;
	}
	
	if (destTask.original != nil && destTask.primaryKey == -1)
	{
		destTask = destTask.original;
	}
	
	if (srcTask == destTask)
	{
		return;
	}
    
    //NSLog(@"begin 1\n");
    
    NSDictionary *taskDict = [TaskManager getTaskDictionary:self.taskList];
    
    srcTask.sequenceNo = destTask.sequenceNo;
    
    int seqNo = destTask.sequenceNo + 1;
    
	NSMutableArray *list = [dbm getVisibleTasks];
 
	sortBGInProgress = (list.count > 30);
    
    BOOL seqNoIncrease = NO;

    for (Task *task in list)
    {
        if (seqNoIncrease && task.primaryKey != srcTask.primaryKey)
        {
            task.sequenceNo = seqNo ++;
            
            if (!sortBGInProgress)
            {
                [task updateSeqNoIntoDB:[dbm getDatabase]];
            }
            
            Task *tmp = [taskDict objectForKey:[NSNumber numberWithInt:task.primaryKey]];
            
            if (tmp != nil)
            {
                tmp.sequenceNo = task.sequenceNo;
            }
        }
        else if (task.primaryKey == destTask.primaryKey)
        {
            seqNoIncrease = YES;
            
            task.sequenceNo = seqNo ++;
            
            if (!sortBGInProgress)
            {
                [task updateSeqNoIntoDB:[dbm getDatabase]];
            }
            
            Task *tmp = [taskDict objectForKey:[NSNumber numberWithInt:task.primaryKey]];
            
            if (tmp != nil)
            {
                tmp.sequenceNo = task.sequenceNo;
            }           
        }
    }
    
    if (!sortBGInProgress)
    {
        [srcTask updateSeqNoIntoDB:[dbm getDatabase]];
    }
    
    Task *tmp = [taskDict objectForKey:[NSNumber numberWithInt:srcTask.primaryKey]];
    
    if (tmp != nil)
    {
        tmp.sequenceNo = srcTask.sequenceNo;
    }
    
    //NSLog(@"begin 2\n");
    
	if (sortBGInProgress)
	{
		[[BusyController getInstance] setBusy:YES withCode:BUSY_TASK_SORT_ORDER];
		
        //[self performSelectorInBackground:@selector(updateSortOrderBackground:) withObject:list];
        
        dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        
        dispatch_async(backgroundQueue, ^{
            [self updateSortOrderBackground:list];
        });
        
        
        sortBGInProgress = NO; //does not need to wait sort complete when scheduling
	}
    
    //[self initSmartListData];
    [Common sortList:self.taskList byKey:@"sequenceNo" ascending:YES];
    
    [self scheduleTasks];
}

- (void) reconcilePinTask:(Task *)task
{
	if (self.taskTypeFilter == TASK_FILTER_STAR)
	{
		[self initSmartListData];
	}
	else 
	{
		Task *tmp = [self findTaskByKey:task.primaryKey];
		
		if (tmp != nil)
		{
			tmp.status = task.status;
			
			//[[_tabBarCtrler getSmartListViewCtrler] refreshView4Task:tmp];
		}
	}
}

- (void) reloadAlert4Task:(NSInteger)taskId
{
    Task *task = [self findItemByKey:taskId];
    
    if (task != nil)
    {
        task.alerts = [[DBManager getInstance] getAlertsForTask:task.primaryKey];
    }
}

- (void)moveTop: (NSArray*) tasks
{
    DBManager *dbm = [DBManager getInstance];
    
    // get current order numbers
    NSMutableArray *seqNoList = [NSMutableArray arrayWithCapacity:self.taskList.count];
	for (Task *task in self.taskList)
	{
		[seqNoList addObject:[NSNumber numberWithInt:task.sequenceNo]];
	}
    
    sortBGInProgress = (self.taskList.count > 30);
    
    for (int i=0; i < tasks.count; i++) {
        Task *willBeTop = [tasks objectAtIndex:i];
        NSInteger index = [self.taskList indexOfObject:willBeTop];
        
        [self.taskList removeObjectAtIndex:index];
        [self.taskList insertObject:willBeTop atIndex:i];
    }
    
    for (int i=0; i<self.taskList.count; i++)
	{
		Task *task = [self.taskList objectAtIndex:i];
		
		task.sequenceNo = [[seqNoList objectAtIndex:i] intValue];
		
		if (!sortBGInProgress)
		{
			[task updateSeqNoIntoDB:[dbm getDatabase]];
		}
	}
	
	////NSLog(@"sort start 3");
	
	if (sortBGInProgress)
	{
		[[BusyController getInstance] setBusy:YES withCode:BUSY_TASK_SORT_ORDER];
		
        //[self performSelectorInBackground:@selector(updateSortOrderBackground:) withObject:self.taskList];
        dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        
        dispatch_async(backgroundQueue, ^{
            [self updateSortOrderBackground:[[self.taskList retain] autorelease]];
        });
        
	}
    
    [self scheduleTasks];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskListReadyNotification" object:nil];
}

- (void) moveTask2Top:(Task *)task
{
    if (task.primaryKey != -1)
    {
        DBManager *dbm = [DBManager getInstance];
        
        NSInteger seqNo = [dbm getTaskMinSortSeqNo] - 1;
        
        Task *slTask = [self getTask2Update:task];
        
        slTask.sequenceNo = seqNo;
        
        [slTask updateSeqNoIntoDB:[dbm getDatabase]];

        if (slTask.listSource == SOURCE_SMARTLIST)
        {
            [Common sortList:self.taskList byKey:@"sequenceNo" ascending:YES];
            
            [self scheduleTasks];
        }
    }
}

- (void) defer:(Task *)task deferOption:(NSInteger)deferOption
{
    //option: 1 - next week, 2 - next month

    if (task.primaryKey != -1)
    {
        Settings *settings = [Settings getInstance];
        
        Task *slTask = [self getTask2Update:task];
        
        switch (deferOption)
        {
            case 1:
            {
                /*
                NSDate *dt = [Common getEndWeekDate:[NSDate date] withWeeks:1 mondayAsWeekStart:(settings.weekStart == 1)];
                
                dt = [Common getFirstWeekDate:dt mondayAsWeekStart:YES];
                
                slTask.startTime = [Common copyTimeFromDate:[settings getWorkingStartTimeForDate:dt] toDate:dt];
                
                dt = [Common dateByAddNumDay:4 toDate:dt];
                
                slTask.deadline = [Common copyTimeFromDate:[settings getWorkingEndTimeForDate:dt] toDate:dt];*/
                
                NSDate *dt = [Common dateByAddNumDay:7 toDate:[Common dateByWeekday:2]];
                
                slTask.startTime = [Common copyTimeFromDate:[settings getWorkingStartTimeForDate:dt] toDate:dt];
                
                dt = [Common dateByAddNumDay:4 toDate:dt];
                
                slTask.deadline = [Common copyTimeFromDate:[settings getWorkingEndTimeForDate:dt] toDate:dt];

            }
                break;
                
            case 2:
            {
                NSDate *dt = [Common getEndMonthDate:[NSDate date] withMonths:2];
                
                slTask.deadline = [Common copyTimeFromDate:[settings getWorkingEndTimeForDate:dt] toDate:dt];
                
                dt = [Common getFirstMonthDate:dt];
                
                slTask.startTime = [Common copyTimeFromDate:[settings getWorkingStartTimeForDate:dt] toDate:dt];
                
            }
                break;
        }
        
        [slTask updateIntoDB:[[DBManager getInstance] getDatabase]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];
        
        [self initSmartListData];
    }
}

- (void)deferTasks: (NSMutableArray*)tasks withOption: (NSInteger)option
{
    sqlite3 *db = [[DBManager getInstance] getDatabase];
    Settings *settings = [Settings getInstance];
    switch (option)
    {
        case 1:
        {
            //BOOL mondayAsWeekStart = (settings.weekStart == 1);
            for (Task *task in tasks)
            {
                Task *slTask = [self getTask2Update:task];
                
                /*
                NSDate *dt = [Common getEndWeekDate:[NSDate date] withWeeks:1 mondayAsWeekStart:mondayAsWeekStart];
                
                slTask.deadline = [Common copyTimeFromDate:[settings getWorkingEndTimeForDate:dt] toDate:dt];
                
                dt = [Common getFirstWeekDate:dt mondayAsWeekStart:(settings.weekStart == 1)];
                
                slTask.startTime = [Common copyTimeFromDate:[settings getWorkingStartTimeForDate:dt] toDate:dt];*/
                
                NSDate *dt = [Common dateByAddNumDay:7 toDate:[Common dateByWeekday:2]];
                
                slTask.startTime = [Common copyTimeFromDate:[settings getWorkingStartTimeForDate:dt] toDate:dt];
                
                dt = [Common dateByAddNumDay:4 toDate:dt];
                
                slTask.deadline = [Common copyTimeFromDate:[settings getWorkingEndTimeForDate:dt] toDate:dt];
                
                [slTask updateIntoDB:db];
            }
        }
            break;
         case 2:
        {
            for (Task *task in tasks) {
                Task *slTask = [self getTask2Update:task];
                NSDate *dt = [Common getEndMonthDate:[NSDate date] withMonths:1];
                
                slTask.deadline = [Common copyTimeFromDate:[settings getWorkingEndTimeForDate:dt] toDate:dt];
                
                dt = [Common getFirstMonthDate:dt];
                
                slTask.startTime = [Common copyTimeFromDate:[settings getWorkingStartTimeForDate:dt] toDate:dt];
                
                [slTask updateIntoDB:db];
            }
        }
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];
    
    [self initSmartListData];
}

#pragma mark Filter

- (BOOL) checkFilterIn:(Task *) task
{
	if ([task isEvent])
	{
		return YES;
	}
	
	BOOL ret = NO;
	
	switch (self.taskTypeFilter) 
	{
		case TASK_FILTER_ALL:
		case TASK_FILTER_TOP:
			ret = YES;
			break;
		case TASK_FILTER_RECURRING:
			ret = [task isRT];
			break;
		case TASK_FILTER_DUE:
			ret = (task.deadline != nil);
			break;
		case TASK_FILTER_ACTIVE:
            ret = (task.startTime != nil);
			break;
		case TASK_FILTER_INACTIVE:
			ret = (task.startTime != nil && [Common compareDateNoTime:[NSDate date] withDate:task.startTime] == NSOrderedAscending);
			break;
		case TASK_FILTER_STAR:
			ret = (task.status == TASK_STATUS_PINNED);
			break;
        case TASK_FILTER_DONE:
            ret = (task.status == TASK_STATUS_DONE);
            break;
	}
	
	return ret;
}

- (BOOL) checkGlobalFilterIn:(Task *)task
{
    NSDictionary *tagDict = [self getFilterTagDict];
    
    NSDictionary *categoryDict = [self getFilterCategoryDict];

    return [self checkGlobalFilterIn:task tagDict:tagDict catDict:categoryDict];
}

- (BOOL) checkGlobalFilterIn:(Task *)task tagDict:(NSDictionary *)tagDict  catDict:(NSDictionary *)catDict
{
    Project *prj = [catDict objectForKey:[NSNumber numberWithInt:task.project]];
    
    if (prj == nil)
    {
        return NO;
    }

	if (self.filterData == nil)
	{
		return YES;
	}
    
	BOOL ret = NO;
	
	NSRange nameRange;
	
	nameRange.location = 0;
	
	BOOL tagFound = NO;
    
    NSString *taskTag = [task getCombinedTag];
	
	if (![self.filterData.taskName isEqualToString:@""])
	{
		nameRange = [task.name rangeOfString:self.filterData.taskName options:NSCaseInsensitiveSearch];
	}
	
	if (tagDict == nil)
	{
		tagFound = YES;
	}
	else if (![taskTag isEqualToString:@""]) 
	{
		NSArray *parts = [taskTag componentsSeparatedByString:@","];
		
		for (NSString *tag in parts)
		{
			if ([tagDict objectForKey:tag] != nil)
			{
				tagFound = YES;
				
				break;
			}
		}
	}

	NSInteger _taskFilterValues[3] = {0x01, 0x02, 0x04};
	
	BOOL typeCheck = (self.filterData.typeMask==0?YES:NO);
	
	for (int i=0; i<3; i++)
	{
		if (self.filterData.typeMask & _taskFilterValues[0])
		{
			typeCheck = typeCheck || (task.type == TYPE_EVENT) || (task.type == TYPE_ADE);
		}				

		if (self.filterData.typeMask & _taskFilterValues[1])
		{
			typeCheck = typeCheck || (task.type == TYPE_TASK);
		}

		if (self.filterData.typeMask & _taskFilterValues[2])
		{
			typeCheck = typeCheck || (task.type == TYPE_NOTE);
		}		
	}

	if (nameRange.location != NSNotFound && tagFound && typeCheck)
	{
		ret = YES;
	}

	return ret;
}

- (NSMutableArray *)excludeMustDo:(NSMutableArray *)list
{
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:list.count];
    
    NSDictionary *mustDoDict = [TaskManager getTaskDictionary:self.mustDoTaskList];
   
    for (Task *task in list)
    {
        Task *mustDoTask = [mustDoDict objectForKey:[NSNumber numberWithInt:task.primaryKey]];
        
        if (mustDoTask == nil)
        {
            [ret addObject:task];
        }            
    }
    
    return ret;
}

- (NSMutableArray *) filterList:(NSMutableArray *)list
{
    ProjectManager *pm = [ProjectManager getInstance];
    
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:list.count];
    
    NSDictionary *categoryDict = [self getFilterCategoryDict];
    
    BOOL checkInvisible = (categoryDict.count != pm.projectList.count);
	
    if (self.filterData != nil || checkInvisible)
	{
		NSDictionary *tagDict = [self getFilterTagDict];
        
        //NSDictionary *categoryDict = [self getFilterCategoryDict];

		for (Task *task in list)
		{
			BOOL filterIn = [self checkGlobalFilterIn:task tagDict:tagDict catDict:categoryDict];
            
            if (filterIn)
            {
                [ret addObject:task];
            }
		}
	}
    else 
    {
        ret = list;
    }
	
	return ret;
}

- (void) filterForTaskType:(NSInteger) type
{
    filterChanged = (self.taskTypeFilter != type);
    
	self.taskTypeFilter = type;
	
	//[self initSmartListData];
	[self filterTaskList];
	
	[self scheduleTasks];		
}

-(NSDictionary *) getFilterTagDict
{
	if (self.filterData != nil && ![self.filterData.tag isEqualToString:@""])
	{
		NSArray *parts = [self.filterData.tag componentsSeparatedByString:@","];
		
		return [NSDictionary dictionaryWithObjects:parts forKeys:parts];
	}
	
	return nil; 
}

-(NSDictionary *) getFilterCategoryDict
{
	/*if (self.filterData != nil && ![self.filterData.categories isEqualToString:@""])
	{
		NSArray *parts = [self.filterData.categories componentsSeparatedByString:@","];
		
		return [NSDictionary dictionaryWithObjects:parts forKeys:parts];
	}*/
    
    return [[ProjectManager getInstance] getVisibleProjectDict];
}

- (NSString *) getFilterTitle:(NSInteger)filterType
{
    NSString *title = @"";
    
    switch (filterType)
    {
        case TASK_FILTER_ALL:
            title = _allText;
            break;
        case TASK_FILTER_STAR:
            title = _starText;
            break;
        case TASK_FILTER_TOP:
            title = _gtdoText;
            break;
        case TASK_FILTER_DUE:
            title = _dueText;
            break;
        case TASK_FILTER_ACTIVE:
            title = _startText;
            break;
        case TASK_FILTER_DONE:
            title = _doneText;
            break;
        case TASK_FILTER_LONG:
            title = _longText;
            break;
        case TASK_FILTER_SHORT:
            title = _shortText;
            break;
    }
    
    return title;
}

- (NSString *) getFilterTitle
{
    return [self getFilterTitle:self.taskTypeFilter];
}

#pragma mark Sync Support
- (Task *) findREByKey:(NSInteger)key
{
	for (Task *re in self.REList)
	{
		if (re.primaryKey == key)
		{
			return re;
		}
	}
	
	for (Task *rade in self.RADEList)
	{
		if (rade.primaryKey == key)
		{
			return rade;
		}
	}
	
	return nil;
}

- (void) resetRESyncIdForProject:(NSInteger) prjKey
{
	DBManager *dbm = [DBManager getInstance];
	
	for (Task *re in self.REList)
	{
		if (re.project == prjKey)
		{
			re.syncId = @"";
			
			[re updateSyncIDIntoDB:[dbm getDatabase]];
		}
 	}

	for (Task *rade in self.RADEList)
	{
		if (rade.project == prjKey)
		{
			rade.syncId = @"";
			
			[rade updateSyncIDIntoDB:[dbm getDatabase]];
		}
 	}
}

- (void) refreshSyncID4AllItems
{
	DBManager *dbm = [DBManager getInstance];

	for (Task *task in self.mustDoTaskList)
	{
		[task refreshSyncIDFromDB:[dbm getDatabase]];
	}
	
	for (Task *task in self.taskList)
	{
		[task refreshSyncIDFromDB:[dbm getDatabase]];
	}
    
	for (Task *re in self.REList)
	{
        [re refreshSyncIDFromDB:[dbm getDatabase]];
    }    
    
	for (Task *rade in self.RADEList)
	{
        [rade refreshSyncIDFromDB:[dbm getDatabase]];
    }  
    
    /*
    for (Task *event in self.todayEventList)
    {
        [event refreshSyncIDFromDB:[dbm getDatabase]];
    }*/
}

#pragma mark Links

- (void) reconcileLinks:(NSDictionary *)dict
{
    TaskLinkManager *tlm = [TaskLinkManager getInstance];
    
    int sourceId = [[dict objectForKey:@"LinkSourceID"] intValue];
    int destId = [[dict objectForKey:@"LinkDestID"] intValue];
    
    Task *src = [self findItemByKey:sourceId];
    
    if (src != nil)
    {
        src.links = [tlm getLinkIds4Task:sourceId];
    }
    
    Task *dest = [self findItemByKey:destId];
    
    if (dest != nil)
    {
        dest.links = [tlm getLinkIds4Task:destId];
    }
}

#pragma mark Actions

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertVw.tag == -10002 && buttonIndex == 1)
	{
		[[Settings getInstance] enableRTDoneHint:NO];
	}	
}

#pragma mark OS4 Support 
-(void) purge
{

}

-(void) recover
{
	self.today = nil;
	[self initData];
	
	//[self performSelector:@selector(scheduleTasks) withObject:nil afterDelay:0];
}

- (Task *) findTaskByKey:(NSInteger)key
{
	for (Task *task in self.mustDoTaskList)
	{
		if (task.primaryKey == key)
		{
			return task;
		}
	}    
    
	for (Task *task in self.taskList)
	{
		if (task.primaryKey == key)
		{
			return task;
		}
	}
	
	return nil;
}

- (Task *) findEventByKey:(NSInteger)key
{
    /*
	for (Task *task in self.todayEventList)
	{
		if (task.primaryKey == key)
		{
			return task;
		}
	}
	*/
	return nil;
}

- (Task *) findSmartTask:(Task *)task
{
    if ([task isTask])
    {
        return [self findTaskByKey:task.primaryKey];
    }
    else if ([task isRE])
    {
        return [self findREByKey:task.primaryKey];
    }
    else if ([task isEvent])
    {
        return [self findEventByKey:task.primaryKey];
    }
    
    return nil;
}

- (Task *) findItemByKey:(NSInteger)key
{
    Task *ret = [self findEventByKey:key];

    if (ret != nil)
    {
        return ret;
    }

    ret = [self findREByKey:key];
    
    if (ret != nil)
    {
        return ret;
    }
        
    return [self findTaskByKey:key];
}


#pragma mark Public Methods

+(id)getInstance
{
	if (_sctmSingleton == nil)
	{
		_sctmSingleton = [[TaskManager alloc] init];
	}
	
	return _sctmSingleton;
}

+(void)startup
{
	TaskManager *tm = [TaskManager getInstance];
	
	tm.taskTypeFilter = [[Settings getInstance] filterTab];
}

+(void)free
{
	if (_sctmSingleton != nil)
	{
		[_sctmSingleton release];
		
		_sctmSingleton = nil;
	}
}

+ (NSDictionary *) getTaskDictionary:(NSArray *)taskList
{
	NSMutableArray *keys = [NSMutableArray arrayWithCapacity:taskList.count];
	
	for (Task *task in taskList)
	{
		[keys addObject:[NSNumber numberWithInt:task.primaryKey]];
	}
	
	return [NSDictionary dictionaryWithObjects:taskList forKeys:keys];	
}

+ (NSDictionary *) getTaskDictionaryBySyncId:(NSArray *)taskList
{
	NSMutableArray *keys = [NSMutableArray arrayWithCapacity:taskList.count];
	
	for (Task *task in taskList)
	{
		[keys addObject:task.syncId];
	}
	
	return [NSDictionary dictionaryWithObjects:taskList forKeys:keys];
}

+ (NSDictionary *) getTaskDictionaryByName:(NSArray *)taskList
{
	NSMutableArray *keys = [NSMutableArray arrayWithCapacity:taskList.count];
	
	for (Task *task in taskList)
	{
		[keys addObject:[NSNumber numberWithInt:task.name]];
	}
	
	return [NSDictionary dictionaryWithObjects:taskList forKeys:keys];	
}

+ (NSDictionary *) getTaskDictBySDWID:(NSArray *)taskList
{
	NSMutableArray *mappingList = [NSMutableArray arrayWithCapacity:taskList.count];
	
	for (Task *task in taskList)
	{
		[mappingList addObject:task.sdwId];
	}
	
	return [NSDictionary dictionaryWithObjects:taskList forKeys:mappingList];
}

+(BOOL)checkTaskInTimeRange:(Task *)task startTime:(NSDate *)startTime endTime:(NSDate *)endTime
{
	return ([task.startTime compare:startTime] != NSOrderedAscending && [task.startTime compare:endTime] == NSOrderedAscending) ||
	([task.startTime compare:startTime] == NSOrderedAscending && [task.endTime compare:startTime] == NSOrderedDescending);
}



@end
