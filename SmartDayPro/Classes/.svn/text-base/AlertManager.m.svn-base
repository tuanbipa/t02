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

#import "Common.h"
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
	
	//////printf("notify %s at time %s\n", [info UTF8String], [[time description] UTF8String]);
	
	UILocalNotification *notif = [[UILocalNotification alloc] init];
	notif.fireDate = time;
	notif.timeZone = [NSTimeZone defaultTimeZone];
	notif.repeatInterval = 0;
	notif.alertBody = info;
	//notif.alertAction = @"Show me";
	notif.soundName = UILocalNotificationDefaultSoundName;
	//notif.applicationIconBadgeNumber = 1;	
	
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
