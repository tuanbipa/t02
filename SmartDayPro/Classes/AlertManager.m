//
//  AlertManager.m
//  SmartCal
//
//  Created by MacBook Pro on 8/17/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "AlertManager.h"
#import "TaskManager.h"
#import "DBManager.h"
#import "MusicManager.h"

#import "Common.h"
#import "Settings.h"
#import "Task.h"
#import "AlertData.h"

AlertManager *_alarmSingleton = nil;

@implementation AlertManager

@synthesize alertDict;

- (id) init
{
	if (self = [super init])
	{
		self.alertDict = [NSMutableDictionary dictionaryWithCapacity:10];
	}
	
	return self;
}

- (void) dealloc 
{
	self.alertDict = nil;
	
	[super dealloc];
}

- (void) cancelAlert:(NSInteger) alertKey
{
	UILocalNotification *notif = [self.alertDict objectForKey:[NSNumber numberWithInt:alertKey]];
	
	if (notif != nil)
	{
		//if ([notif.fireDate compare:[NSDate date]] == NSOrderedDescending)
		//{
			[[UIApplication sharedApplication] cancelLocalNotification:notif];
			
			[self.alertDict removeObjectForKey:[NSNumber numberWithInt:alertKey]];
		//}
		//else
		//{
		//	[self.alertDict removeObjectForKey:[NSNumber numberWithInt:alertKey]];
		//}
	}
}

- (void) alertOnTime:(NSDate *)time forKey:(NSInteger)alertKey info:(NSString *)info
{
	[self cancelAlert:alertKey];
	
	printf("notify %s at time %s\n", [info UTF8String], [[time description] UTF8String]);
	
	UILocalNotification *notif = [[UILocalNotification alloc] init];
	notif.fireDate = time;
	notif.timeZone = [NSTimeZone defaultTimeZone];
	//notif.repeatInterval = 0;
	notif.alertBody = info;
	//notif.alertAction = @"Show me";
	notif.soundName = UILocalNotificationDefaultSoundName;
	//notif.applicationIconBadgeNumber = 1;
    notif.userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:alertKey] forKey:@"alertKey"];
	
    [[UIApplication sharedApplication] scheduleLocalNotification:notif];
	
	[self.alertDict setObject:notif forKey:[NSNumber numberWithInt:alertKey]];
	
	[notif release];
}

- (void) generateAlert:(AlertData *)alert forTask:(Task *)task
{
	if (alert.absoluteTime == nil)
	{
		NSDate *time = (task.type == TYPE_TASK? task.deadline: task.startTime);
		
		if (alert.beforeDuration != 0)
		{
			time = [Common dateByAddNumSecond:alert.beforeDuration toDate:time];
		}
		
		if ([time compare:[NSDate date]] != NSOrderedAscending)
		{
			NSString *alertStr = [NSString stringWithFormat:@"[%@]:%@", task.type == TYPE_TASK?_taskText:_eventText, task.name];
			[self alertOnTime:time forKey:alert.primaryKey info:alertStr];
		}
	}	
}

- (void) generateAlertsForTask:(Task *)task
{
	if (task.alerts != nil && (task.syncId == nil || [task.syncId isEqualToString:@""]))
	{
		if ([task isRE])
		{
			NSDate *fromDate = [Common clearTimeForDate:[NSDate date]];
            
            /*
			NSDate *toDate = [Common getEndDate:fromDate];

			NSMutableArray *reInstances = [[TaskManager getInstance] expandRE:task fromDate:fromDate toDate:toDate excludeException:YES];

			if (reInstances.count == 1)
			{
				task = [reInstances objectAtIndex:0]; 
			}
            */
            
            task = [[TaskManager getInstance] findRTInstance:task fromDate:fromDate];
            
            //printf("find instance %s from today: %s\n", [task.name UTF8String], [[task.startTime description] UTF8String]);
		}
		
		if (task != nil)
		{
			for (AlertData *alert in task.alerts)
			{
				[self generateAlert:alert forTask:task];
			}			
		}
	}	
}

- (void) removeAllAlertsForTask:(Task *)task
{
	if (task.alerts != nil)
	{
        DBManager *dbm = [DBManager getInstance];
        
		for (AlertData *dat in task.alerts)
		{
			[self cancelAlert:dat.primaryKey];
			
			[dat deleteFromDatabase:[dbm getDatabase]];
		}
		
		task.alerts = [NSMutableArray arrayWithCapacity:5];
	}
}

- (void) cancelAllAlertsForTask:(Task *)task
{
	if (task.alerts != nil)
	{
		for (AlertData *dat in task.alerts)
		{
			[self cancelAlert:dat.primaryKey];			
		}
	}
}

- (void) generateAlerts
{
	TaskManager *tm = [TaskManager getInstance];
	
	for (Task *task in tm.taskList)
	{
		[self generateAlertsForTask:task];
	}
	
    /*
	for (Task *event in tm.todayEventList)
	{
		[self generateAlertsForTask:event];
	}
    */
}

- (void) stopAlert:(UILocalNotification *)notif
{
    NSNumber *alertKey = [notif.userInfo objectForKey:@"alertKey"];
    
    if (alertKey != nil)
    {
        [self cancelAlert:[alertKey intValue]];
    }
}

- (void) snoozeAlert:(UILocalNotification *)notif
{
    NSNumber *alertKey = [notif.userInfo objectForKey:@"alertKey"];
    
    if (alertKey != nil)
    {
        printf("snooze alert: %s\n", [notif.alertBody UTF8String]);
        
        Settings *settings = [Settings getInstance];
        
        [self alertOnTime:[NSDate dateWithTimeInterval:settings.snoozeDuration*60 sinceDate:[NSDate date]] forKey:[alertKey intValue] info:notif.alertBody];
    }
}

- (void) postponeAlert:(UILocalNotification *)notif postponeType:(NSInteger)postponeType
{
    NSNumber *alertKey = [notif.userInfo objectForKey:@"alertKey"];
    
    if (alertKey != nil)
    {
        [self cancelAlert:[alertKey intValue]];
        
        DBManager *dbm = [DBManager getInstance];
        
        AlertData *dat = [[AlertData alloc] initWithPrimaryKey:[alertKey intValue] database:[dbm getDatabase]];
        
        Task *task = [[Task alloc] initWithPrimaryKey:dat.taskKey database:[dbm getDatabase]];
        
        /*
        NSDate *alertTime = [dat getAlertTime:task];
        
        switch (postponeType)
        {
            case 0:
            {
                alertTime = [Common dateByAddNumDay:1 toDate:alertTime];
            }
                break;
            case 1:
            {
                alertTime = [Common dateByAddNumDay:7 toDate:alertTime];
            }
                break;
            case 2:
            {
                alertTime = [Common dateByAddNumMonth:1 toDate:alertTime];
            }
                break;
        }
        
        dat.absoluteTime = alertTime;
        
        [dat updateIntoDB:[dbm getDatabase]];
        */
        
        //change task deadline and start
        Settings *settings = [Settings getInstance];
                
        if (task.startTime == nil)
        {
            task.startTime = [settings getWorkingStartTimeForDate:[Common dateByAddNumDay:-7 toDate:task.deadline]];
        }
        
        NSInteger diff = [task.deadline timeIntervalSinceDate:task.startTime];
        
        task.deadline = postponeType == 2?[Common dateByAddNumMonth:1 toDate:task.deadline]:[Common dateByAddNumDay:(postponeType == 1?7:1) toDate:task.deadline];
        
        task.startTime = [settings getWorkingStartTimeForDate:[task.deadline dateByAddingTimeInterval:-diff]];
        
        [task updateTimeIntoDB:[dbm getDatabase]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AlertPostponeChangeNotification" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:task.primaryKey] forKey:@"TaskId"]];
        
        [task release];
        [dat release];
    }
}

#pragma mark Public Methods

+(id)getInstance
{
	if (_alarmSingleton == nil)
	{
		_alarmSingleton = [[AlertManager alloc] init];
	}
	
	return _alarmSingleton;
}

+(void)free
{
	if (_alarmSingleton != nil)
	{
		[_alarmSingleton release];
		
		_alarmSingleton = nil;
	}
}

@end
