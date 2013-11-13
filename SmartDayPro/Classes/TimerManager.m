//
//  TimerManager.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 2/28/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "TimerManager.h"

#import "Common.h"
#import "Task.h"
#import "TaskProgress.h"

#import "ProjectManager.h"
#import "TaskManager.h"
#import "DBManager.h"

#import "AbstractSDViewController.h"

extern AbstractSDViewController *_abstractViewCtrler;

TimerManager *_timerManagerSingleton;

@implementation TimerManager

@synthesize taskToActivate;

@synthesize activeTaskList;
@synthesize inProgressTaskList;

- (id) init
{
    if (self = [super init])
    {
        
    }
    
    return self;
}

- (void) dealloc
{
    self.taskToActivate = nil;
    self.activeTaskList = nil;
    self.inProgressTaskList = nil;
    
    [super dealloc];
}

-(void) refreshTaskLists:(BOOL)needRefreshDuration
{
	DBManager *dbm = [DBManager getInstance];
	
	self.activeTaskList = [dbm getActiveTaskList];
	
	self.inProgressTaskList = [dbm getInProgressTaskList];
    
    //printf("active count: %d, pause count: %d\n", self.activeTaskList.count, self.inProgressTaskList.count);
	
	if (needRefreshDuration)
	{
		[self refreshActualDuration];
	}
}

- (void)refreshActualDuration
{
	[self refreshActualDuration:self.inProgressTaskList];
	[self refreshActualDuration:self.activeTaskList];
}

-(void) refreshActualDurationForTask:(Task *) task
{
	NSArray *progressHistory = [[DBManager getInstance] getProgressHistoryForTask:task.primaryKey];
	
	NSInteger actualDuration = 0;
	
	for (TaskProgress *progress in progressHistory)
	{
		actualDuration += [Common timeIntervalNoDST:progress.endTime sinceDate:progress.startTime];
	}
	
	task.actualDuration = actualDuration;
}

-(void) refreshActualDuration:(NSArray *) taskList
{
	for (Task *task in taskList)
	{
		[self refreshActualDurationForTask:task];
	}
}

-(NSInteger)getTimerDurationForTask:(Task *)task
{
	TaskProgress *lastProgress = task.lastProgress;
	
	NSInteger lastDuration = 0;
	
	if (lastProgress != nil && lastProgress.endTime == nil)
	{
		lastDuration = [Common timeIntervalNoDST:[NSDate date] sinceDate:lastProgress.startTime];
	}
	
	return task.actualDuration + lastDuration;
}

-(BOOL)checkActivated:(Task *)task
{
    BOOL found = NO;
    
    for (Task *tmp in self.activeTaskList)
    {
        if (tmp.primaryKey == task.primaryKey)
        {
            found = YES;
            
            break;
        }
    }
    
    if (!found)
    {
        for (Task *tmp in self.inProgressTaskList)
        {
            if (tmp.primaryKey == task.primaryKey)
            {
                found = YES;
                
                break;
            }
        }        
    }
    
    return found;
}

-(void)activateTask
{
	if (self.taskToActivate != nil)
	{
		if (self.taskToActivate.primaryKey == -1)
		{
			[[TaskManager getInstance] addTask:self.taskToActivate];
            
            [_abstractViewCtrler reconcileItem:self.taskToActivate reSchedule:YES];
		}
		
		TaskProgress *lastProgress = [[[TaskProgress alloc] init] autorelease];
		lastProgress.startTime = [NSDate date];
		
		lastProgress.task = self.taskToActivate;
		
		[lastProgress insertIntoDB:[[DBManager getInstance] getDatabase]];
		
		self.taskToActivate.timerStatus = TASK_TIMER_STATUS_START;
		self.taskToActivate.isActivating = YES;
		self.taskToActivate.lastProgress = lastProgress;
		
		[self.taskToActivate updateTimerStatusIntoDB:[[DBManager getInstance] getDatabase]];
		
		self.taskToActivate.startTime = lastProgress.startTime;
		[self.taskToActivate updateStartTimeIntoDB:[[DBManager getInstance] getDatabase]];
		
		if (self.activeTaskList == nil)
		{
			self.activeTaskList = [NSMutableArray arrayWithCapacity:10];
		}
		
		if (self.activeTaskList.count > 0)
		{
			[self.activeTaskList insertObject:self.taskToActivate atIndex:0];
		}
		else
		{
			[self.activeTaskList addObject:self.taskToActivate];
		}
		
		self.taskToActivate = nil;		
	}
}

- (void) holdAllActiveTasksAndStart
{
	DBManager *dbm = [DBManager getInstance];
	
	for (Task *task in self.activeTaskList)
	{
		if (!task.isActivating)
		{
			TaskProgress *lastProgress = task.lastProgress;
			
			lastProgress.endTime = [NSDate date];
			[lastProgress updateEndTimeIntoDB:[dbm getDatabase]];
			
			task.timerStatus = TASK_TIMER_STATUS_PAUSE;
			[task updateTimerStatusIntoDB:[dbm getDatabase]];
            
            [self refreshActualDurationForTask:task];
						
			if (self.inProgressTaskList == nil)
			{
				self.inProgressTaskList = [NSMutableArray arrayWithCapacity:5];
			}
			
			[self.inProgressTaskList addObject:task];
		}
	}
	
	self.activeTaskList = nil;
	
	[self activateTask];
}

- (void) pauseTask:(NSInteger) taskIndex
{
	Task *task = [self.activeTaskList objectAtIndex:taskIndex];
	
	[task retain];
	[self.activeTaskList removeObject:task];
	
	if (self.inProgressTaskList == nil)
	{
		self.inProgressTaskList = [NSMutableArray arrayWithCapacity:5];
	}
	
	if (self.inProgressTaskList.count > 0)
	{
		[self.inProgressTaskList insertObject:task atIndex:0];
	}
	else
	{
		[self.inProgressTaskList addObject:task];
	}
    
	DBManager *dbm = [DBManager getInstance];
	
	TaskProgress *lastProgress = task.lastProgress;
	
	lastProgress.endTime = [NSDate date];
	[lastProgress updateEndTimeIntoDB:[dbm getDatabase]];
	
	task.timerStatus = TASK_TIMER_STATUS_PAUSE;
	[task updateTimerStatusIntoDB:[dbm getDatabase]];
    
    [self refreshActualDurationForTask:task];
	
//	[[MusicManager getInstance] playSound:SOUND_PAUSE];
}

- (void) startTask:(NSInteger) taskIndex
{
	Task *task = [self.inProgressTaskList objectAtIndex:taskIndex];
	
	[task retain];
	[self.inProgressTaskList removeObject:task];
	
	if (self.activeTaskList == nil)
	{
		self.activeTaskList = [NSMutableArray arrayWithCapacity:5];
	}
	
	if (self.activeTaskList.count > 0)
	{
		[self.activeTaskList insertObject:task atIndex:0];
	}
	else
	{
		[self.activeTaskList addObject:task];
	}
    
	
	DBManager *dbm = [DBManager getInstance];
	
	TaskProgress *lastProgress = [[TaskProgress alloc] init];
	lastProgress.startTime = [NSDate date];
	lastProgress.task = task;
	[lastProgress insertIntoDB:[dbm getDatabase]];
	
	task.lastProgress = lastProgress;
	
	task.timerStatus = TASK_TIMER_STATUS_START;
	[task updateTimerStatusIntoDB:[dbm getDatabase]];
	
	//[[MusicManager getInstance] playSound:SOUND_START];
}

- (void) interrupt
{
	DBManager *dbm = [DBManager getInstance];
	if (self.activeTaskList != nil)
	{
		for (Task *task in self.activeTaskList)
		{
			TaskProgress *lastProgress = task.lastProgress;
			
			lastProgress.endTime = [NSDate date];
			[lastProgress updateEndTimeIntoDB:[dbm getDatabase]];
			
			task.timerStatus = TASK_TIMER_STATUS_INTERRUPT;
			[task updateTimerStatusIntoDB:[dbm getDatabase]];
		}
	}
}

- (void) continueTimer
{
	DBManager *dbm = [DBManager getInstance];
	
	for (Task *task in self.activeTaskList)
	{
		task.lastProgress.endTime = nil;
		
		[task.lastProgress updateEndTimeIntoDB:[dbm getDatabase]];
		
		task.timerStatus = TASK_TIMER_STATUS_START; // to change from TASK_STATUS_INTERRUPT -> TASK_STATUS_ACTIVE
		
		[task updateTimerStatusIntoDB:[dbm getDatabase]];
	}
	
	[self refreshActualDuration];
}

- (void) pauseTimer
{
	DBManager *dbm = [DBManager getInstance];
	
	for (int i=self.activeTaskList.count-1; i>=0; i--)
	{
		Task *task = [self.activeTaskList objectAtIndex:i];
        
		task.timerStatus = TASK_TIMER_STATUS_PAUSE; // to change from TASK_STATUS_INTERRUPT -> TASK_STATUS_INPROGRESS
		
		[task updateTimerStatusIntoDB:[dbm getDatabase]];
        
		if (self.inProgressTaskList == nil)
		{
			self.inProgressTaskList = [NSMutableArray arrayWithCapacity:5];
		}
		
		if (self.inProgressTaskList.count > 0)
		{
			[self.inProgressTaskList insertObject:task atIndex:0];
		}
		else
		{
			[self.inProgressTaskList addObject:task];
		}		
	}
	
	self.activeTaskList = nil;
}

- (void) markDoneTask:(NSInteger) taskIndex inProgress:(BOOL) inProgress
{
	NSMutableArray *sourceList = (inProgress? self.inProgressTaskList: (self.activeTaskList != nil && self.activeTaskList.count > 0?self.activeTaskList:self.inProgressTaskList));
	
	Task *task = [sourceList objectAtIndex:taskIndex];
	
	if (task != nil)
	{
		DBManager *dbm = [DBManager getInstance];
		TaskProgress *lastProgress = task.lastProgress;
		
		//if (task.status == TASK_STATUS_ACTIVE)
        if (task.timerStatus == TASK_TIMER_STATUS_START)
		{
			lastProgress.endTime = [NSDate date];
			
			if ([lastProgress.endTime compare:lastProgress.startTime] == NSOrderedSame)
			{
				lastProgress.endTime = [Common dateByAddNumSecond:1 toDate:lastProgress.startTime];
			}
			
			[lastProgress updateEndTimeIntoDB:[dbm getDatabase]];
		}
		
		task.endTime = lastProgress.endTime;
		
		[task updateEndTimeIntoDB:[[DBManager getInstance] getDatabase]];
		
        [task retain];
        
        [[AbstractActionViewController getInstance] markDoneTask:task];
        
        [task release];
	}
}

- (void) check2CompleteTask:(NSInteger) taskId
{
    Task *foundTask = nil;
    NSMutableArray *sourceList = nil;
    
    for (int i=0; i< self.activeTaskList.count; i++)
    {
        Task *task = [self.activeTaskList objectAtIndex:i];
        
        if (task.primaryKey == taskId)
        {
            foundTask = task;
            
            sourceList = self.activeTaskList;
            
            break;
        }
    }
    
    if (foundTask == nil)
    {
        for (int i=0; i< self.inProgressTaskList.count; i++)
        {
            Task *task = [self.inProgressTaskList objectAtIndex:i];
            
            if (task.primaryKey == taskId)
            {
                foundTask = task;
                
                sourceList = self.inProgressTaskList;
                
                break;
            }
        }        
    }
    
    if (foundTask != nil)
    {
		DBManager *dbm = [DBManager getInstance];
		TaskProgress *lastProgress = foundTask.lastProgress;
		
        if (foundTask.timerStatus == TASK_TIMER_STATUS_START)
		{
			lastProgress.endTime = [NSDate date];
			
			if ([lastProgress.endTime compare:lastProgress.startTime] == NSOrderedSame)
			{
				lastProgress.endTime = [Common dateByAddNumSecond:1 toDate:lastProgress.startTime];
			}
			
			[lastProgress updateEndTimeIntoDB:[dbm getDatabase]];
		}
		
		foundTask.endTime = lastProgress.endTime;
		
		[foundTask updateEndTimeIntoDB:[dbm getDatabase]];
        
        [sourceList removeObject:foundTask];
    }
}

- (void) check2DeleteTask:(NSInteger) taskId
{
    Task *foundTask = nil;
    
    for (int i=0; i< self.activeTaskList.count; i++)
    {
        Task *task = [self.activeTaskList objectAtIndex:i];
        
        if (task.primaryKey == taskId)
        {
            foundTask = task;
            
            break;
        }
    }
    
    if (foundTask != nil)
    {
        [self.activeTaskList removeObject:foundTask];
    }
    else
    {
        for (int i=0; i< self.inProgressTaskList.count; i++)
        {
            Task *task = [self.inProgressTaskList objectAtIndex:i];
            
            if (task.primaryKey == taskId)
            {
                foundTask = task;
                
                break;
            }
        }
        
        if (foundTask != nil)
        {
            [self.inProgressTaskList removeObject:foundTask];
        }
    }
}

- (void) showTimerOptions
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_timerRecoverTitle  message:_timerRecoverText delegate:self cancelButtonTitle:nil otherButtonTitles:_timerResumeText, _timerContinueText, nil];
	
	alertView.tag = -10000;
	[alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertVw.tag == -10000)
	{
		if (buttonIndex == 0) //pause Timer
		{
			[self pauseTimer];
		}
		else //continue Timer
		{
			[self continueTimer];
		}
	}
}


+(id)getInstance
{
	if (_timerManagerSingleton == nil)
	{
		_timerManagerSingleton = [[TimerManager alloc] init];
	}
	
	return _timerManagerSingleton;
}

+(void)startup
{
	TimerManager *timer = [TimerManager getInstance];
	
	[timer refreshTaskLists:YES];
    
	for (Task *task in timer.activeTaskList)
	{
		if (task.timerStatus == TASK_TIMER_STATUS_INTERRUPT)
		{
			[timer showTimerOptions];
            
			break;
		}
	}
	
	//[timer refreshActualDuration];
    
}

+(void)free
{
	if (_timerManagerSingleton != nil)
	{
		[_timerManagerSingleton release];
		
		_timerManagerSingleton = nil;
	}
}

@end
