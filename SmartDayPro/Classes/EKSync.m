//
//  EKSync.m
//  SmartCal
//
//  Created by Trung Nguyen on 7/7/10.
//  Copyright 2010 LCL. All rights reserved.
//
#import <EventKit/EventKit.h>

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "Common.h"
#import "EKSync.h"

#import "SDWSync.h"

#import "Settings.h"
#import "DBManager.h"
#import "ProjectManager.h"
#import "TaskManager.h"
#import "AlertManager.h"
#import "Project.h"
#import "Task.h"
#import "AlertData.h"
#import "RepeatData.h"

#import "BusyController.h"

#import "SmartListViewController.h"
#import "CalendarViewController.h"
#import "SmartCalAppDelegate.h"
#import "AbstractSDViewController.h"

EKSync *_ekSyncSingleton;

//extern SCTabBarController *_tabBarCtrler;
extern SmartCalAppDelegate *_appDelegate;

extern SmartListViewController *_smartListViewCtrler;
extern CalendarViewController *_sc2ViewCtrler;
extern AbstractSDViewController *_abstractViewCtrler;

extern BOOL _syncMatchHintShown;

@implementation EKSync

@synthesize scEKMappingDict;
@synthesize ekSCMappingDict;

//@synthesize sdOriginatedList;
//@synthesize iCalOriginatedList;

@synthesize dupCategoryList;

@synthesize eventStore;

@synthesize syncMode;

@synthesize resultCode;

-(void) reset
{
    if (createList != nil)
    {
        [createList release];
    }
    
    ekSourceiCloud = nil;
    ekSourceLocal =  nil;
    
	self.scEKMappingDict = nil;
	self.ekSCMappingDict = nil;
    
    self.dupCategoryList = nil;
	
	self.eventStore = nil;
    
    //self.resultCode = 0;
}

-(id) init
{
	if (self = [super init])
	{
        createList = nil;
        
		[self reset];
	}
	
	return self;
}

-(void) dealloc 
{
	[self reset];

	[super dealloc];
}

//-(RepeatData *) parseRRule:(EKRecurrenceRule *)rrule endDate:(NSDate *)endDate
-(RepeatData *) parseRRule:(EKRecurrenceRule *)rrule event:(Task *)event
{
	RepeatData *ret = [[RepeatData alloc] init];
	
	ret.type = rrule.frequency;
	ret.interval = rrule.interval;
	
	NSInteger wkOptions[7] = {ON_SUNDAY, ON_MONDAY, ON_TUESDAY, ON_WEDNESDAY, ON_THURSDAY, ON_FRIDAY, ON_SATURDAY};
    
    //printf("daysOfWeek count: %d\n", rrule.daysOfTheWeek.count);

	for (EKRecurrenceDayOfWeek *dow in rrule.daysOfTheWeek)
	{
		ret.weekOption |= wkOptions[dow.dayOfTheWeek-1];
        
        if (ret.type == REPEAT_MONTHLY)
        {
            ret.weekDay = dow.dayOfTheWeek;
            ret.weekOrdinal = dow.weekNumber;
        }
	}
    
    //if (ret.weekOption == 0)
    if (rrule.daysOfTheWeek.count == 0)
    {
        NSInteger day = [Common getWeekday:ret.type==REPEAT_WEEKLY?event.startTime:[NSDate date]];
        
        ret.weekOption = wkOptions[day-1];        
    }
    
    //printf("*** parse RE %s - Week Option: %d\n", [event.name UTF8String], ret.weekOption);
	
	if (rrule.daysOfTheWeek != nil && rrule.daysOfTheWeek.count > 0)
	{
		ret.monthOption = BY_DAY_OF_WEEK;
	}
    
    if (event.deadline == nil)
    {
        ret.repeatFrom = 1;
    }
	
	if (rrule.recurrenceEnd != nil)
	{
		if (rrule.recurrenceEnd.endDate == nil)
		{
			ret.count = rrule.recurrenceEnd.occurrenceCount;
		
			//[ret calculateUntilByCount:endDate];
            [ret calculateUntilByCount:event.endTime];
		}
		else
		{
			ret.until = rrule.recurrenceEnd.endDate;
            //printf("EK re %s - until: %s\n", [event.name UTF8String], [[ret.until description] UTF8String]);
		}
	}
	
	return [ret autorelease];
}

-(EKRecurrenceRule *) buildRRule:(RepeatData *)rrule startDate:(NSDate *)startDate 
{
	EKRecurrenceFrequency freq;
	NSMutableArray *daysOfWeek = [NSMutableArray arrayWithCapacity:7];
	NSMutableArray *daysOfMonth = [NSMutableArray arrayWithCapacity:5];
    
    int wkDay = [Common getWeekday:startDate];
    
	switch (rrule.type)
	{
		case REPEAT_DAILY:
			freq = EKRecurrenceFrequencyDaily;
			break;
		case REPEAT_WEEKLY:
		{
			freq = EKRecurrenceFrequencyWeekly;
			
			NSInteger wkOptions[7] = {ON_SUNDAY, ON_MONDAY, ON_TUESDAY, ON_WEDNESDAY, ON_THURSDAY, ON_FRIDAY, ON_SATURDAY}; 
			
			NSInteger wkOpt = rrule.weekOption;
            
            if (wkOptions[wkDay-1] != wkOpt) // if day is the same as start day -> don't update iCal
			for (int i=0; i<7; i++)
			{
				if (wkOpt & wkOptions[i])
				{
					EKRecurrenceDayOfWeek *dow = [EKRecurrenceDayOfWeek dayOfWeek:i+1];
					[daysOfWeek addObject:dow];
				}
			}
            
            daysOfMonth = nil;
		}
			break;
		case REPEAT_MONTHLY:
		{
			freq = EKRecurrenceFrequencyMonthly;
			
			if (rrule.monthOption == BY_DAY_OF_WEEK)
			{
				EKRecurrenceDayOfWeek *dow = [EKRecurrenceDayOfWeek dayOfWeek:wkDay weekNumber:[Common getWeekdayOrdinal:startDate]];
                
				[daysOfWeek addObject:dow];
			}
			else 
			{
				NSNumber *dom = [NSNumber numberWithInt:[Common getDay:startDate]];
				
				[daysOfMonth addObject:dom];
			}

		}
			break;
		case REPEAT_YEARLY:
			freq = EKRecurrenceFrequencyYearly;
	}
	
	EKRecurrenceEnd *until = nil;
	
	if (rrule.until != nil)
	{
		until = [EKRecurrenceEnd recurrenceEndWithEndDate:rrule.until];
	}

	EKRecurrenceRule *ekRRule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:freq
																			 interval:rrule.interval 
																		daysOfTheWeek:daysOfWeek
																	   daysOfTheMonth:daysOfMonth
																	  monthsOfTheYear:nil
																	   weeksOfTheYear:nil
																		daysOfTheYear:nil
																		 setPositions:nil
																				  end:until];
	
	return [ekRRule autorelease];
}

-(void) updateSCEvent:(Task *)scEvent withEKEvent:(EKEvent *)ekEvent
{
    if (ekEvent.timeZone != nil)
    {
        scEvent.timeZoneId = [Settings findTimeZoneID:ekEvent.timeZone];
        
        printf("timezone id: %d - map for event tz name: %s\n", scEvent.timeZoneId, [ekEvent.timeZone.name UTF8String]);
        
        if (scEvent.timeZoneId == -1)
        {
            scEvent.timeZoneId = [Common createTimeZoneIDByOffset:ekEvent.timeZone.secondsFromGMT];            
        }
    }
    else
    {
        scEvent.timeZoneId = 0;
    }
    
	scEvent.syncId = ekEvent.eventIdentifier;
	scEvent.name = ekEvent.title;
	scEvent.location = ekEvent.location;
	scEvent.note = ekEvent.notes;
	scEvent.startTime = ekEvent.startDate;
	scEvent.endTime = ekEvent.endDate;
	scEvent.updateTime = ekEvent.lastModifiedDate == nil?[NSDate date]:ekEvent.lastModifiedDate;
	scEvent.type = TYPE_EVENT;
	
	if (ekEvent.allDay)
	{
		scEvent.type = TYPE_ADE;
		//scEvent.endTime = [Common getEndDate:ekEvent.endDate]; //EK returns 11:59pm instead of 12:00am
        
        //printf("ADE from iCal: %s - start: %s, end: %s\n", [scEvent.name UTF8String], [[scEvent.startTime description] UTF8String], [[scEvent.endTime description] UTF8String]);
	}
    
    if (ekEvent.recurrenceRules.count > 0)
    {
        //printf("EK recurrence count: %d\n", ekEvent.recurrenceRules.count);

        EKRecurrenceRule *rrule = [ekEvent.recurrenceRules objectAtIndex:0];
        
		scEvent.repeatData = [self parseRRule:rrule event:scEvent];
		
		//printf("RE %s - until: %s\n", [scEvent.name UTF8String], [[scEvent.repeatData.until description] UTF8String]);
        
    }
    else
    {
        scEvent.repeatData = nil;
    }
	
	//[[AlertManager getInstance] removeAllAlertsForTask:scEvent];
	
    /*
	NSMutableArray *alerts = [NSMutableArray arrayWithCapacity:3];
	
	for (EKAlarm *alarm in ekEvent.alarms)
	{
		//printf("EK %s alarm time: %s, offset: %f", [ekEvent.title UTF8String], [[alarm.absoluteDate description] UTF8String], alarm.relativeOffset);
		
		if (alarm.absoluteDate == nil)
		{
			AlertData *dat = [[AlertData alloc] init];
			dat.taskKey = scEvent.primaryKey;
			
			dat.absoluteTime = nil;
			dat.beforeDuration = alarm.relativeOffset;
			
			if (scEvent.primaryKey > -1)
			{
				[dat insertIntoDB:[[DBManager getInstance] getDatabase]];
			}
			
			[alerts addObject:dat];
			[dat release];
		}
	}
	
	scEvent.alerts = alerts;
    */
    
	//if (scEvent.primaryKey > -1)
	{
		[scEvent externalUpdate];
	}
}

-(void) updateEKEvent:(EKEvent *)ekEvent withSCEvent:(Task *)scEvent
{
    //NSInteger secs = scEvent.timeZoneId == 0?[Common getSecondsFromTimeZoneID:0]:0;
    
    ekEvent.allDay = NO;    
	ekEvent.title = scEvent.name;
	ekEvent.location = scEvent.location;
	ekEvent.notes = scEvent.note;
	ekEvent.startDate = scEvent.startTime;//[scEvent.startTime dateByAddingTimeInterval:secs];
	ekEvent.endDate = scEvent.endTime;//[scEvent.endTime dateByAddingTimeInterval:secs];
    
    //ekEvent.timeZone = scEvent.timeZoneId==0?nil:[NSTimeZone timeZoneWithName:[Settings getTimeZoneDisplayNameByID:scEvent.timeZoneId]];
    
    if (scEvent.timeZoneId == 0)
    {
        ekEvent.timeZone = nil;
    }
    else
    {
        /*
        NSString *tzName = [Settings getTimeZoneDisplayNameByID:scEvent.timeZoneId];
        
        if ([tzName isEqualToString:@"Unknown"])
        {
            ekEvent.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[Common getSecondsFromTimeZoneID:scEvent.timeZoneId]];
        }
        else
        {
            ekEvent.timeZone = [NSTimeZone timeZoneWithName:tzName];
        }
        */
        
        ekEvent.timeZone = [Settings getTimeZoneByID:scEvent.timeZoneId];
    }

	if ([scEvent isADE])
	{
		ekEvent.allDay = YES;
	}

	if (scEvent.repeatData != nil && scEvent.groupKey == -1)
	{
		//ekEvent.recurrenceRule = [self buildRRule:scEvent.repeatData startDate:scEvent.startTime];
        
        for (EKRecurrenceRule* rrule in ekEvent.recurrenceRules)
        {
            [ekEvent removeRecurrenceRule:rrule];
            
        }

        [ekEvent addRecurrenceRule:[self buildRRule:scEvent.repeatData startDate:scEvent.startTime]];
	}
	
    /*
	NSMutableArray *alarmList = [NSMutableArray arrayWithCapacity:5];
	
	for (AlertData *dat in scEvent.alerts)
	{
		if (dat.absoluteTime == nil)
		{
			[[AlertManager getInstance] cancelAlert:dat.primaryKey];
			
			EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:dat.beforeDuration];
			[alarmList addObject:alarm];
		}
	}
	
	if (alarmList.count == 0)
	{
		ekEvent.alarms = nil;
	}
	else 
	{
		ekEvent.alarms = alarmList;
	}
    */
}

- (NSMutableDictionary *) getSyncDictionaryForList:(NSMutableArray *)eventList
{
	NSMutableArray *syncKeys = [NSMutableArray arrayWithCapacity:eventList.count];
	
	for (Task *event in eventList)
	{
		[syncKeys addObject:event.syncId];
	}
	return [NSMutableDictionary dictionaryWithObjects:eventList forKeys:syncKeys];
}

-(void)importEvent:(EKEvent *)ekEvent scEventDict:(NSMutableDictionary *)scEventDict
{
	//TaskManager *tm = [TaskManager getInstance];

	Task *scEvent = [[Task alloc] init];
	
	[self updateSCEvent:scEvent withEKEvent:ekEvent];
	
	NSNumber *prjKey = [self.ekSCMappingDict objectForKey:ekEvent.calendar.calendarIdentifier];
	scEvent.project = [prjKey intValue];
	[scEvent enableExternalUpdate];
	
	[scEvent insertIntoDB:[[DBManager getInstance] getDatabase]];
    
    //printf("Create EK->SC: %s - ekStart: %s - ekEnd:%s - ekId:%s - update Time:%s\n", [scEvent.name UTF8String], [[ekEvent.startDate description] UTF8String], [[ekEvent.endDate description] UTF8String], [ekEvent.eventIdentifier UTF8String], [[scEvent.updateTime description] UTF8String]);
    
	
	if (scEvent.repeatData != nil)
	{
		[scEventDict setObject:scEvent forKey:ekEvent.eventIdentifier]; //to search for RE when syncing exceptions later
	}

	[scEvent release];
}

- (void) notifySyncCompletion:(NSNumber *)mode
{
    [[BusyController getInstance] setBusy:NO withCode:BUSY_EK_SYNC];
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          mode, 
                          @"SyncMode",
                          nil];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:@"EKSyncCompleteNotification" object:nil userInfo:dict];
}

- (BOOL) checkOutTimeRange4Event:(Task *)event startTime:(NSDate *)startTime endTime:(NSDate *)endTime
{
    return ([Common compareDate:event.endTime withDate:startTime] != NSOrderedDescending ||
            [Common compareDate:event.startTime withDate:endTime] != NSOrderedAscending);
}

- (void) syncDeletedEvents
{
    DBManager *dbm = [DBManager getInstance];
    
    NSError *err;
    
	NSDate *startTime = [[Settings getInstance] getSyncWindowDate:YES];
	NSDate *endTime = [[Settings getInstance] getSyncWindowDate:NO];
    
    NSMutableArray *delList = [dbm getDeletedEvents];
    
    for (Task *scEvent in delList)
    {
        if ([Common compareDate:scEvent.endTime withDate:startTime] != NSOrderedDescending ||
            [Common compareDate:scEvent.startTime withDate:endTime] != NSOrderedAscending)
        {
            //out of sync window
            continue;
        }		
        
        if ([scEvent.syncId isEqualToString:@""])
        {
            [scEvent cleanFromDatabase:[dbm getDatabase]];
        }
        else
        {
            EKEvent *ekEvent = [eventStore eventWithIdentifier:scEvent.syncId];
            
            if (ekEvent != nil)
            {
                [eventStore removeEvent:ekEvent span:EKSpanFutureEvents commit:YES error:&err];
                
                if (err == nil)
                {
                    [scEvent cleanFromDatabase:[dbm getDatabase]];
                }				
            }
        }         
    }
}

- (void) syncEvents
{
    [self syncDeletedEvents];
    
	Settings *settings = [Settings getInstance];
	
	TaskManager *tm = [TaskManager getInstance];
	DBManager *dbm = [DBManager getInstance];
	
	NSMutableArray *eventList = [dbm getEvents2Sync];
	NSMutableDictionary *scEventDict = [self getSyncDictionaryForList:eventList];
    
    NSMutableDictionary *dupCategoryDict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    if (self.dupCategoryList.count > 0)
    {
        for (NSNumber *prjNum in self.dupCategoryList)
        {
            NSMutableDictionary *taskNameDict = [NSMutableDictionary dictionaryWithCapacity:50];
            
            [dupCategoryDict setObject:taskNameDict forKey:prjNum];
        }
        
        for (Task *task in eventList)
        {
            NSMutableDictionary *taskNameDict = [dupCategoryDict objectForKey:[NSNumber numberWithInt:task.project]];
            
            if (taskNameDict != nil)
            {
                [taskNameDict setObject:task forKey:task.name];
            }
        }
    }
	
	BOOL refreshData = NO;
	
	NSError *err;
	
	NSDate *startTime = [settings getSyncWindowDate:YES];
	NSDate *endTime = [settings getSyncWindowDate:NO];

    NSArray *calList = [[self.scEKMappingDict objectEnumerator] allObjects];
	
	NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:startTime endDate:endTime calendars:calList]; // eventStore is an instance variable.
	
	// Fetch all events that match the predicate.
	NSArray *events = [self.eventStore eventsMatchingPredicate:predicate];
	
	NSMutableDictionary *ekDict = [NSMutableDictionary dictionaryWithCapacity:10];
	
	NSMutableArray *ekREExceptions = [NSMutableArray arrayWithCapacity:10];
	
	for (EKEvent *ekEvent in events)
	{
		NSNumber *prjKey = [self.ekSCMappingDict objectForKey:ekEvent.calendar.calendarIdentifier];
		
		EKEvent *dup = [ekDict objectForKey:ekEvent.eventIdentifier];
		
		if (dup != nil)
		{
			continue; //EK returns every single instance of RE -> ignore them
		}
		
		[ekDict setObject:ekEvent forKey:ekEvent.eventIdentifier];
		
		Task *scEvent = [scEventDict objectForKey:ekEvent.eventIdentifier];
		
		if (scEvent != nil)
		{
			if (ekEvent.status == EKEventStatusCanceled)
			{
				//unable to sync deleted Event from iCal because EK does not return
			}
            else if ([Common compareDate:scEvent.updateTime withDate:ekEvent.lastModifiedDate] == NSOrderedAscending) //change in iCal
			{
                //printf("change from iCal\n");
				RepeatData *recurringData = [scEvent.repeatData retain];
				
				if ([prjKey intValue] != scEvent.project) // project change 
				{
					scEvent.project = [prjKey intValue];
				}
                
				[self updateSCEvent:scEvent withEKEvent:ekEvent];
				
				//printf("Update EK->SC: ");
				[scEvent print];
				
				BOOL recurringSame = [RepeatData isEqual:recurringData toAnother:scEvent.repeatData];
				
				if (scEvent.groupKey == -1 && recurringData != nil && !recurringSame)
				{
                    //printf("recurring data change %s -> delete all exceptions\n", [scEvent.name UTF8String]);
                    
					[dbm deleteTasksInGroup:scEvent.primaryKey];
					scEvent.exceptions = nil;
				}
				
				[recurringData release];
				
				refreshData = YES;
			}			
            else if ([Common compareDate:scEvent.updateTime withDate:ekEvent.lastModifiedDate] == NSOrderedDescending)
			{
				[self updateEKEvent:ekEvent withSCEvent:scEvent];
				
				//printf("Update SC->EK: %s - ekStart: %s - ekEnd:%s - ekId:%s - isDetached:%s\n", [scEvent.name UTF8String], [[ekEvent.startDate description] UTF8String], [[ekEvent.endDate description] UTF8String], [ekEvent.eventIdentifier UTF8String], ekEvent.isDetached?"Yes":"NO");
				[scEvent print];
				
				BOOL deleteFromEK = NO;
				
				if ([prjKey intValue] != scEvent.project) // project change 
				{
					EKCalendar *cal = [self.scEKMappingDict objectForKey:[NSNumber numberWithInt:scEvent.project]];
					
					if (cal != nil)
					{
						ekEvent.calendar = cal;
					}
					else 
					{
						deleteFromEK = YES;
					}
				}	
				
				if (deleteFromEK)
				{
					[eventStore removeEvent:ekEvent span:EKSpanFutureEvents commit:YES error:&err];
					
					scEvent.syncId = @"";
					[scEvent updateSyncIDIntoDB:[[DBManager getInstance] getDatabase]];
				}
				else 
				{
					BOOL ret = [eventStore saveEvent:ekEvent span:(ekEvent.isDetached?EKSpanThisEvent:EKSpanFutureEvents) commit:YES error:&err];
                    
                    if (err == nil && ret && [scEvent.updateTime compare:ekEvent.lastModifiedDate] == NSOrderedAscending)
                    {
                        //bug of iOS: last modified time is not updated when saving -> may keep SD update time
					
                        [scEvent enableExternalUpdate];
                        scEvent.updateTime = ekEvent.lastModifiedDate;
                        [scEvent modifyUpdateTimeIntoDB:[dbm getDatabase]];
                    }
				}
			}
            else
            {
                //printf("Event %s no change - EK modify time: %s - SD update time: %s\n", [scEvent.name UTF8String], [[ekEvent.lastModifiedDate description] UTF8String], [[scEvent.updateTime description] UTF8String]);
                
                if ([scEvent isRE] && [Common daysBetween:scEvent.startTime sinceDate:ekEvent.startDate] != 0)
                {
                    //sync window was changed -> Update EK->SD
                    [self updateSCEvent:scEvent withEKEvent:ekEvent];
                }
            }
			
			[eventList removeObject:scEvent];
		}
        else 
        {
            BOOL eventCreation = YES;
            
            NSDictionary *taskNameDict = [dupCategoryDict objectForKey:prjKey];
            
            if (taskNameDict != nil)
            {
                //sdw Task is in suspected duplicated category
                
                Task *event = [taskNameDict objectForKey:ekEvent.title];
                
                if (event != nil)
                {
                    BOOL duplicated = [Common compareDate:event.startTime withDate:ekEvent.startDate] == NSOrderedSame &&
                        [Common compareDate:event.endTime withDate:ekEvent.endDate] == NSOrderedSame;                            
                    
                    if (duplicated)
                    {
                        //printf("event %s is duplication suspected\n", [event.name UTF8String]);
                        
                        event.syncId = ekEvent.eventIdentifier;
                        [event updateSyncIDIntoDB:[dbm getDatabase]];
                        
                        [eventList removeObject:event];
                        eventCreation = NO;
                    }
                }
                
            }
            
            if (eventCreation)
            {
				if (ekEvent.isDetached) //RE exception
				{
					//printf("detached ek %s - id: %s\n",[ekEvent.title UTF8String], [ekEvent.eventIdentifier UTF8String]);
					
					[ekREExceptions addObject:ekEvent];
				}		
				else 
				{
					//printf("new from EK: %s - id: %s - start time:%s - modify time:%s\n",[ekEvent.title UTF8String], [ekEvent.eventIdentifier UTF8String], [[ekEvent.startDate description] UTF8String], [[ekEvent.lastModifiedDate description] UTF8String]);
                                        
					[self importEvent:ekEvent scEventDict:scEventDict];
					
					refreshData = YES;
				}				
                
            }            
        }
    }    
    
	for (EKEvent *ekEvent in ekREExceptions)
	{
		NSArray *parts = [ekEvent.eventIdentifier componentsSeparatedByString:@"/"];
		NSString *rootId = [parts objectAtIndex:0];
		
		Task *rootRE = [scEventDict objectForKey:rootId];
		
		if (rootRE != nil)
		{
			Task *instance = [rootRE copy];
			instance.name = ekEvent.title;
			instance.startTime = ekEvent.startDate;
			instance.endTime = ekEvent.endDate;
			instance.original = rootRE;
			instance.syncId = ekEvent.eventIdentifier;
			[instance enableExternalUpdate];
			
			[tm createREException:instance originalTime:ekEvent.startDate];
			
			//printf("create RE exception: %s - start: %s - end: %s\n", [instance.name UTF8String], [[instance.startTime description] UTF8String], [[instance.endTime description] UTF8String]);
			
			[instance release];
			
			refreshData = YES;
		}
	}
	
	for (Task *scEvent in eventList) //new Events from SC
	{
        BOOL outsideSyncWindow = NO;
        //if ([self checkOutTimeRange4Event:scEvent startTime:startTime endTime:endTime])
		//{
			//out of sync window
            
            if ([scEvent isRE])
            {
                /*
                Task *task = [tm findRTInstance:scEvent fromDate:startTime];
                
                if ([self checkOutTimeRange4Event:task startTime:startTime endTime:endTime])
                {
                    outsideSyncWindow = YES;
                }*/
                
                NSMutableArray *reInstances = [tm expandRE:scEvent fromDate:startTime toDate:endTime excludeException:NO];
        
                if (reInstances.count == 0)
                {
                    outsideSyncWindow = YES;
                }
            }
            else if ([self checkOutTimeRange4Event:scEvent startTime:startTime endTime:endTime])
            {
                outsideSyncWindow = YES;
            }
		//}
        
        if (outsideSyncWindow)
        {
            continue;
        }
		
		EKCalendar *cal = [self.scEKMappingDict objectForKey:[NSNumber numberWithInt:scEvent.project]];
		
		if (cal != nil && scEvent.type != TYPE_RE_DELETED_EXCEPTION)
		{
			if (![scEvent.syncId isEqualToString:@""]) //Event was deleted from iCal
			{
                EKEvent *ekEvent = [self.eventStore eventWithIdentifier:scEvent.syncId];
                
                if (ekEvent == nil)
                {
                    //printf("Event was deleted from iCal:%s\n", [scEvent.name UTF8String]);
                    
                    scEvent.syncId = @"";
                    [scEvent updateSyncIDIntoDB:[dbm getDatabase]];
                    
                    [scEvent deleteFromDatabase:[dbm getDatabase]];
                    
                    refreshData = YES;
                    
                }
                else
                {
                    //printf("Event %s existing in iCal\n", [ekEvent.title UTF8String]);
                }
			}
			else
			{
				if (scEvent.groupKey == -1)
				{
					//printf("new from SC: %s - start time:%s\n",[scEvent.name UTF8String], [[scEvent.startTime description] UTF8String]);
					
					EKEvent *ekEvent  = [EKEvent eventWithEventStore:eventStore];
					[self updateEKEvent:ekEvent withSCEvent:scEvent];
					
					[ekEvent setCalendar:cal];
					[eventStore saveEvent:ekEvent span:(ekEvent.isDetached?EKSpanThisEvent:EKSpanFutureEvents) commit:YES error:&err];
					
					if (err != nil)
					{
						//printf("error: %s\n", [[err localizedDescription] UTF8String]);
					}
					else 
					{
						scEvent.updateTime = ekEvent.lastModifiedDate;
						scEvent.syncId = ekEvent.eventIdentifier;
						[scEvent enableExternalUpdate];
						
						[scEvent updateSyncIDIntoDB:[dbm getDatabase]];
						
						if (scEvent.repeatData != nil && scEvent.exceptions != nil)
						{
							//unable to sync RE exceptions from SC because EK does not support
						}
						
						//printf("Create SC->EK: [ek update time: %s]", [[ekEvent.lastModifiedDate description] UTF8String]);
						[scEvent print];
					}					
				}
			}
		}
	}
    
}

- (NSString *) checkCalendarNameDuplication
{
    NSMutableDictionary *nameDict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    NSArray *ekCalList = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")?[self.eventStore calendarsForEntityType:EKEntityTypeEvent]:self.eventStore.calendars;
    
	for (EKCalendar *cal in ekCalList)
	{
        EKCalendar *dupCal = [nameDict objectForKey:cal.title];
        
        if (dupCal != nil)
        {
            //printf("duplicated cal title: %s\n", [cal.title UTF8String]);
            
            return cal.title;
        }
        else 
        {
            [nameDict setObject:cal forKey:cal.title];
        }
    }
    
    return nil;
}

- (void) resolveCalendarNameDuplication
{
    NSMutableDictionary *nameDict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    NSArray *ekCalList = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")?[self.eventStore calendarsForEntityType:EKEntityTypeEvent]:self.eventStore.calendars;
    
	for (EKCalendar *cal in ekCalList)
	{
        NSMutableArray *list = [nameDict objectForKey:cal.title];
        
        if (list == nil)
        {
            list = [NSMutableArray arrayWithCapacity:5];
            
            [nameDict setObject:list forKey:cal.title];
        }
        
        [list addObject:cal]; 
    }
    
    //NSMutableDictionary *resolvedNameDict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    NSEnumerator *enumerator = [nameDict keyEnumerator];

    NSError *err = nil;
    NSString *name;
    
    while ((name = [enumerator nextObject])) 
    {
        NSMutableArray *list = [nameDict objectForKey:name];
        
        NSMutableDictionary *bySourceDict = [NSMutableDictionary dictionaryWithCapacity:10]; 
        
        for (EKCalendar *cal in list)
        {
            NSMutableArray *listBySource = [bySourceDict objectForKey:[NSNumber numberWithInt:cal.source.sourceType]];
            
            if (listBySource == nil)
            {
                listBySource = [NSMutableArray arrayWithCapacity:5];
                
                [bySourceDict setObject:listBySource forKey:[NSNumber numberWithInt:cal.source.sourceType]];
            }
            
            [listBySource addObject:cal];
        }
        
        //printf("calendar %s has %d sources\n", [name UTF8String], bySourceDict.allKeys.count);
        
        BOOL needChangeName = (bySourceDict.allKeys.count > 1);
        
        NSEnumerator *keyEnum = bySourceDict.keyEnumerator;
        
        NSNumber *key;
        
        while ((key = [keyEnum nextObject]) != nil)
        {
            BOOL isLocal = [key intValue] == EKSourceTypeLocal;
            
            NSMutableArray *listBySource = [bySourceDict objectForKey:key];
            
            needChangeName = (needChangeName || listBySource.count > 1);
            
            if (!needChangeName)
            {
                continue;
            }
            
            for (int i=0; i<listBySource.count; i++)
            {
                EKCalendar *cal = [listBySource objectAtIndex:i];
                
                //NSString *resolvedName = (isLocal?[NSString stringWithFormat:@"%@ %d", cal.title, i]:[NSString stringWithFormat:@"%@ %@ %d", cal.source.title, cal.title, i]);
                
                NSString *resolvedName = (i==0? (isLocal?[NSString stringWithFormat:@"%@", cal.title]:[NSString stringWithFormat:@"%@ %@", cal.source.title, cal.title]):(isLocal?[NSString stringWithFormat:@"%@ %d", cal.title, i]:[NSString stringWithFormat:@"%@ %@ %d", cal.source.title, cal.title, i]));
                
                //printf("change title for calendar: %s\n", [resolvedName UTF8String]);
                
                cal.title = resolvedName;
                
                [self.eventStore saveCalendar:cal commit:NO error:&err];
                
                if (err != nil)
                {
                    //printf("cannot change title %s - error: %s\n", [resolvedName UTF8String], [err.localizedDescription UTF8String]);
                }
            }
        }
        
    }
    
    err = nil;

    [self.eventStore commit:&err];
    
    if (err != nil)
    {
        //printf("cannot save EK - error: %s\n", [err.localizedDescription UTF8String]);
    }
    
}

- (void) syncDeletedProjects
{
    DBManager *dbm = [DBManager getInstance];
    
	NSMutableArray *delList = [[DBManager getInstance] getDeletedPlans];
    
    NSError *err;
    
    for (Project *prj in delList)
    {
        if (prj.ekId != nil && ![prj.ekId isEqualToString:@""])
        {
            EKCalendar *cal = [self.eventStore calendarWithIdentifier:prj.ekId];    
            
            if (cal != nil)
            {
                [self.eventStore removeCalendar:cal commit:NO error:&err];
            }
        }
        
        if ((prj.tdId != nil && ![prj.tdId isEqualToString:@""]) || 
            (prj.sdwId != nil && ![prj.sdwId isEqualToString:@""]) ||
             (prj.rmdId != nil && ![prj.rmdId isEqualToString:@""]))
        {
            prj.ekId = @"";
            [prj updateEKIDIntoDB:[dbm getDatabase]];
        }
        else 
        {
            //no task was synced -> delete it
            [prj cleanFromDatabase];
        }        
    }
    
    [self.eventStore commit:&err];
}

-(void)deleteProjectBySync:(Project *)prj
{
    DBManager *dbm = [DBManager getInstance];
    ProjectManager *pm = [ProjectManager getInstance];
    
    prj.ekId = @"";
    [prj updateEKIDIntoDB:[dbm getDatabase]];
    
    NSInteger taskCount = [dbm getTaskCountForProject:prj.primaryKey];
    
	NSInteger defaultPrjKey = [[Settings getInstance] taskDefaultProject];
	
	if (taskCount > 0 || prj.primaryKey == defaultPrjKey)
	{
		[dbm cleanAllEventsForProject:prj.primaryKey];
	}
	else
	{
        [pm deleteProject:prj cleanFromDB:YES];
	}
}

- (void) syncProjects
{
	ProjectManager *pm = [ProjectManager getInstance];
	DBManager *dbm = [DBManager getInstance];
	
	self.eventStore = [[[EKEventStore alloc] init] autorelease]; //to query calendars again when syncing back from TD -> EK
    
    [self syncDeletedProjects];
    
    ekSourceLocal = nil;
    ekSourceiCloud = nil;
    
    for (EKSource *ekSource in self.eventStore.sources)
    {
        ////printf("source: %s, %d\n", [ekSource.title UTF8String], ekSource.sourceType);
        if (ekSource.sourceType == EKSourceTypeLocal)
        {
            ////printf("source local found\n");
            ekSourceLocal = ekSource;
        }
        else if (ekSource.sourceType == 2 && [[ekSource.title uppercaseString] isEqualToString:@"ICLOUD"])
        {
            ekSourceiCloud = ekSource;
        }
    }
    
    NSMutableArray *prjList = [NSMutableArray arrayWithArray: pm.projectList];
    
    NSDictionary *prjNameDict = [ProjectManager getProjectDictByName:prjList];
    
    NSDictionary *prjSyncDict = [ProjectManager getProjectDictByEventSyncID:prjList];
	
	NSMutableArray *delList = [dbm getDeletedPlans];
    
    createList = [[NSMutableArray arrayWithCapacity:10] retain];
	
	self.scEKMappingDict = [NSMutableDictionary dictionaryWithCapacity:12];
	self.ekSCMappingDict = [NSMutableDictionary dictionaryWithCapacity:12];

	self.dupCategoryList = [NSMutableArray arrayWithCapacity:12];
    
    NSArray *ekCalList = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")?[self.eventStore calendarsForEntityType:EKEntityTypeEvent]:self.eventStore.calendars;
    
    if (ekCalList.count == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_syncErrorText  message:_ekFatalError delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
        [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        [alertView release];

        [self syncComplete];
        
        return;
    }

	for (EKCalendar *cal in ekCalList)
	{
		//printf("EK title: %s\n", [cal.title UTF8String]);
		
		Project *prj = [prjSyncDict objectForKey:cal.calendarIdentifier];
        
        if (prj.status == PROJECT_STATUS_INVISIBLE)
        {
            continue;
        }
        
        if (prj != nil)
        {
            if (![[prj.name uppercaseString] isEqualToString:[cal.title uppercaseString]])
            {
                //change name in EK
                cal.title = prj.name;
                
                NSError *err;
                [self.eventStore saveCalendar:cal commit:YES error:&err];
                
                if (err != nil)
                {
                    //printf("change calendar name error: %s\n", [[err localizedDescription] UTF8String]); 
                }
            }
            
            [self.scEKMappingDict setObject:cal forKey:[NSNumber numberWithInt:prj.primaryKey]];
            [self.ekSCMappingDict setObject:[NSNumber numberWithInt:prj.primaryKey] forKey:cal.calendarIdentifier];
            
            [prjList removeObject:prj];
        }
        else
        {
            prj = [prjNameDict objectForKey:[cal.title uppercaseString]];
            
            if (prj != nil) //match Project name
            {
                prj.ekId = cal.calendarIdentifier;
                prj.source = CATEGORY_SOURCE_ICAL;
                
                //[prj updateEKIDIntoDB:[dbm getDatabase]];
                [prj updateIntoDB:[dbm getDatabase]];
                
                //[self.dupCategoryList addObject:prj];
                [self.dupCategoryList addObject:[NSNumber numberWithInt:prj.primaryKey]];
                
                [prjList removeObject:prj];
            }
            else 
            {
                //create new Project in SD
                prj = [[Project alloc] init];
                prj.name = cal.title;
                prj.colorId = [pm getSuggestColorId];
                
                prj.ekId = cal.calendarIdentifier;
                prj.source = CATEGORY_SOURCE_ICAL;
                
                [pm addProject:prj];
                
                [prj release];
                
                //printf("create calendar %s in SC\n", [cal.title UTF8String]);                    
            }
            
            [self.scEKMappingDict setObject:cal forKey:[NSNumber numberWithInt:prj.primaryKey]];
            [self.ekSCMappingDict setObject:[NSNumber numberWithInt:prj.primaryKey] forKey:cal.calendarIdentifier]; 
            
        }
    }
    
	delList = [NSMutableArray arrayWithCapacity:5];
    
	for (Project *prj in prjList)
	{
        if (prj.status == PROJECT_STATUS_INVISIBLE || [prj isShared])
        {
            continue;
        }
        
        if (![prj.ekId isEqualToString:@""]) //already synced and calendar is deleted from iCal
        {
            EKCalendar *ekCal = [self.eventStore calendarWithIdentifier:prj.ekId];
            
            if (ekCal == nil)
            {
                [delList addObject:prj];
            }
        }
        else //comment out to don't sync Local project to iCal 
        {
            [createList addObject:prj];
        }
	}
	
	for (Project *prj in delList)
	{
        //printf("EK sync - delete project: %s\n", [prj.name UTF8String]);
        [self deleteProjectBySync:prj];
	}
    
    if (createList.count > 0)
    {
        if (ekSourceiCloud != nil && ekSourceLocal != nil)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_chooseSyncSourceText  message:_multiSourceWarningText delegate:self cancelButtonTitle:_cancelText otherButtonTitles:_sourceLocalText, _sourceiCloudText, nil];
        
            alertView.tag = -11000;
        
            [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
            [alertView release];
        }
        else if (ekSourceiCloud == nil && ekSourceLocal == nil)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_errorText message:_noSourceFoundText delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
            
            [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
            [alertView release];
            
            [self syncComplete];
        }
        else
        {
            [self proceedSync:(ekSourceiCloud !=nil? ekSourceiCloud:ekSourceLocal)];
        }
    }
    else
    {
        [self proceedSync:nil];
    }
}

- (void) syncComplete
{
    [self reset];
    
    [self performSelectorOnMainThread:@selector(notifySyncCompletion:) withObject:[NSNumber numberWithInt:self.syncMode] waitUntilDone:NO];
}

-(void) proceedSync:(EKSource *) ekSource
{
    DBManager *dbm = [DBManager getInstance];
    //Settings *settings = [Settings getInstance];
    //NSError *err;
    
    if (ekSource != nil && createList.count > 0)
    {
        for (Project *prj in createList)
        {
            //create calendar in EK
            EKCalendar *cal = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")?[EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:self.eventStore]:[EKCalendar calendarWithEventStore:self.eventStore];
            
            cal.title = prj.name;
            cal.source = ekSource;
            
            NSError *err = nil;
            [eventStore saveCalendar:cal commit:YES error:&err];
            
            if (err == nil)
            {
                [self.scEKMappingDict setObject:cal forKey:[NSNumber numberWithInt:prj.primaryKey]];
                [self.ekSCMappingDict setObject:[NSNumber numberWithInt:prj.primaryKey] forKey:cal.calendarIdentifier];
                
                prj.ekId = cal.calendarIdentifier;
                [prj updateEKIDIntoDB:[dbm getDatabase]];
            }
        }        
    }
    
    if (self.syncMode != SYNC_MANUAL_2WAY_BACK) //only sync Projects for 2WAY-BACK mode
    {
        if (self.syncMode == SYNC_AUTO_1WAY)
        {
            [self sync1way];
        }
        else
        {
            [self syncEvents];
        }
    }
    
    [self syncComplete];
}

- (void) performSync
{
    /*
    if ([self syncProjects])
    {
        [self proceedSync:nil];
    }
	else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_syncErrorText  message:_ekFatalError delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
        [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        [alertView release];
    }
    */
    
    [self syncProjects];
}

- (void) initSync:(NSInteger)mode
{
	////NSLog(@"begin EK sync");
    // Thuc test commit
	
	@synchronized(self)
	{
		self.syncMode = mode;
        
        self.resultCode = 0;
        
        self.eventStore = [[[EKEventStore alloc] init] autorelease];
        
        NSString *dupName = [self checkCalendarNameDuplication];
        
        if (dupName != nil)
        {
            NSString *msg = [NSString stringWithFormat:@"%@: %@. %@", _calendarNameDuplicationText, dupName, _duplicationResolveSuggestionText];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_warningText message:msg delegate:self cancelButtonTitle:_cancelText otherButtonTitles:_proceedText, nil];
            
            alertView.tag = -10000;
            
            [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
            [alertView release];
            
        }
        else 
        {
            //[self check1stTimeSync];
            [self performSync];
        }
		
	}
	
	////NSLog(@"end EK sync");	
}

- (void) email2HelpDesk
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    
    if (picker != nil)
    {
        picker.mailComposeDelegate = self;
        
        [picker setSubject:@"SmartDay Sync New Calendars - Help"];
        
        // Set up recipients
        NSArray *toRecipients = [NSArray arrayWithObject:@"support@leftcoastlogic.com"];
        //NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
        //NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"];
        
        [picker setToRecipients:toRecipients];
        [picker setCcRecipients:nil];
        [picker setBccRecipients:nil];
        
        if (_abstractViewCtrler != nil)
        {
            [_abstractViewCtrler presentModalViewController:picker animated:YES];
        }
        
        [picker release];
    }
}

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertVw.tag == -10000)
    {
        if (buttonIndex == 1)
        {
            [self resolveCalendarNameDuplication];
            
            //[self check1stTimeSync]; 
            [self performSync];
        }
        else 
        {
            self.resultCode = -1;
            [self performSelectorOnMainThread:@selector(notifySyncCompletion:) withObject:[NSNumber numberWithInt:self.syncMode] waitUntilDone:NO];
        }
    }
	else if (alertVw.tag == -10002 && buttonIndex == 1)
	{
		[[Settings getInstance] enableSyncMatchHint:NO];
	}
    else if (alertVw.tag == -11000)
    {
        switch (buttonIndex)
        {
            case 0:
            {
                self.resultCode = -2;
                [self syncComplete];
            }
                break;
            case 1:
            {
                [self proceedSync:ekSourceLocal];
            }
                break;
            case 2:
            {
                [self proceedSync:ekSourceiCloud];
            }
                break;
            /*case 3:
            {
                [self performSelectorOnMainThread:@selector(email2HelpDesk) withObject:nil waitUntilDone:NO];
            }
                break;
            */
        }
    }
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[controller dismissModalViewControllerAnimated:YES];
    
    [self syncComplete];
}

#pragma mark Auto Sync

-(void)initBackgroundSync
{
	//printf("init sync background\n");
	
	[[BusyController getInstance] setBusy:YES withCode:BUSY_EK_SYNC];
    
    //[self performSelectorInBackground:@selector(syncBackground:) withObject:[NSNumber numberWithInt:SYNC_MANUAL_2WAY]];
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    
    dispatch_async(backgroundQueue, ^{
        [self syncBackground:[NSNumber numberWithInt:SYNC_MANUAL_2WAY]];
    });
    
}

-(void)initBackgroundSyncBack
{
	[[BusyController getInstance] setBusy:YES withCode:BUSY_EK_SYNC];
    
    //[self performSelectorInBackground:@selector(syncBackground:) withObject:[NSNumber numberWithInt:SYNC_MANUAL_2WAY_BACK]];
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    
    dispatch_async(backgroundQueue, ^{
        [self syncBackground:[NSNumber numberWithInt:SYNC_MANUAL_2WAY_BACK]];
    });
}

-(void)initBackgroundAuto1WaySync
{
    [[BusyController getInstance] setBusy:YES withCode:BUSY_EK_SYNC];
    
    //[self performSelectorInBackground:@selector(syncBackground:) withObject:[NSNumber numberWithInt:SYNC_AUTO_1WAY]];
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    
    dispatch_async(backgroundQueue, ^{
        [self syncBackground:[NSNumber numberWithInt:SYNC_AUTO_1WAY]];
    });
}

-(void)initBackgroundAuto2WaySync
{
	//printf("init sync background\n");
	
	[[BusyController getInstance] setBusy:YES withCode:BUSY_EK_SYNC];
    
    //[self performSelectorInBackground:@selector(syncBackground:) withObject:[NSNumber numberWithInt:SYNC_AUTO_2WAY]];
    
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    
    dispatch_async(backgroundQueue, ^{
        [self syncBackground:[NSNumber numberWithInt:SYNC_AUTO_2WAY]];
    });
}

-(void)syncBackground:(NSNumber *) mode
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	[self initSync:[mode intValue]];
	
	[pool release];
}

-(void) sync1way
{
	//Settings *settings = [Settings getInstance];
	//TaskManager *tm = [TaskManager getInstance];
	DBManager *dbm = [DBManager getInstance];
	
	NSDate *startTime = [[Settings getInstance] getSyncWindowDate:YES];
	NSDate *endTime = [[Settings getInstance] getSyncWindowDate:NO];
	
	NSMutableArray *eventList = [dbm getEvents2SyncFromDate:startTime toDate:endTime];	
	
	for (Task *scEvent in eventList) //new Events from SC
	{
        //printf("SC Event for 1-way sync: %s - start: %s - end:%s\n", [scEvent.name UTF8String], [[scEvent.startTime description] UTF8String], [[scEvent.endTime description] UTF8String]);
        
		EKCalendar *cal = [self.scEKMappingDict objectForKey:[NSNumber numberWithInt:scEvent.project]];
		
		if (cal != nil)
		{
			if (![scEvent.syncId isEqualToString:@""]) //Event was synced to iCal
			{
				EKEvent *ekEvent = [eventStore eventWithIdentifier:scEvent.syncId];
				
				if (ekEvent != nil)
				{
					if (scEvent.status == TASK_STATUS_DELETED)
					{
						//printf("Delete SC->EK: %s\n", [scEvent.name UTF8String]);
						
						NSError *err;
						
						[eventStore removeEvent:ekEvent span:EKSpanFutureEvents commit:YES error:&err];
						
						if (err == nil)
						{
							[scEvent cleanFromDatabase:[dbm getDatabase]];
						}						
					}
					//else if ([scEvent.updateTime compare:ekEvent.lastModifiedDate] == NSOrderedDescending)
                    else if ([Common compareDate:scEvent.updateTime withDate:ekEvent.lastModifiedDate] == NSOrderedDescending)
					{
						//printf("Update SC->EK: %s\n", [scEvent.name UTF8String]);
						
						[self updateEKEvent:ekEvent withSCEvent:scEvent];
                        
                        //printf("1 way Update SC->EK: %s - ekStart: %s - ekEnd:%s - ekID: %s\n", [scEvent.name UTF8String], [[ekEvent.startDate description] UTF8String], [[ekEvent.endDate description] UTF8String], [ekEvent.eventIdentifier UTF8String]);
                        
                        [ekEvent setCalendar:cal];
						
						NSError *err;
						
						BOOL ret = [eventStore saveEvent:ekEvent span:(ekEvent.isDetached?EKSpanThisEvent:EKSpanFutureEvents) commit:YES error:&err];
						
						if (err == nil && ret && [scEvent.updateTime compare:ekEvent.lastModifiedDate] == NSOrderedAscending)
						{
                            //bug of iOS: last modified time is not updated when saving -> may keep SD update time
                            
							[scEvent enableExternalUpdate];
							scEvent.updateTime = ekEvent.lastModifiedDate;
							[scEvent modifyUpdateTimeIntoDB:[dbm getDatabase]];	
							
							//printf("1-way EK Sync update SD time: %s for event:%s - now: %s\n", [[scEvent.updateTime description] UTF8String], [scEvent.name UTF8String], [[[NSDate date] description] UTF8String]);
						}
					}
				}				
			}
			else
			{
                TaskManager *tm = [TaskManager getInstance];
                
                BOOL outsideSyncWindow = NO;
                if ([scEvent isRE])
                {
                    NSMutableArray *reInstances = [tm expandRE:scEvent fromDate:startTime toDate:endTime excludeException:NO];
                    
                    if (reInstances.count == 0)
                    {
                        outsideSyncWindow = YES;
                    }
                }
                else if ([self checkOutTimeRange4Event:scEvent startTime:startTime endTime:endTime])
                {
                    outsideSyncWindow = YES;
                }
                
                if (outsideSyncWindow)
                {
                    //printf("1-way sync: Event %s is out of window\n", [scEvent.name UTF8String]);
                    
                    continue;
                }
                
				EKEvent *ekEvent  = [EKEvent eventWithEventStore:eventStore];
				[self updateEKEvent:ekEvent withSCEvent:scEvent];
				
				NSError *err = nil;
				[ekEvent setCalendar:cal];
				BOOL ret = [eventStore saveEvent:ekEvent span:(ekEvent.isDetached?EKSpanThisEvent:EKSpanFutureEvents) commit:YES error:&err];
				
				if (err == nil && ret)
				{
					scEvent.updateTime = ekEvent.lastModifiedDate;
					scEvent.syncId = ekEvent.eventIdentifier;
                    
					[scEvent enableExternalUpdate];
					[scEvent updateSyncIDIntoDB:[dbm getDatabase]];
                    
                    [scEvent enableExternalUpdate];
                    [scEvent modifyUpdateTimeIntoDB:[dbm getDatabase]];
					
					//printf("Create SC->EK: %s - update time: %s\n", [scEvent.name UTF8String], [[scEvent.updateTime description] UTF8String]);
					//[scEvent print];
				}
                else if (err != nil)
                {
                    //printf("Create SC->EK: %s - error: %s\n", [scEvent.name UTF8String], [err.localizedDescription UTF8String]);
                }
			}
		}
	}
		
    /*
	settings.ekLastSyncTime = [NSDate date];
	
	[self reset];
	
	[settings saveEKSync];
    */
}

#pragma mark Public Methods
+ (BOOL) checkEKAccessEnabled
{
    return (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")?[EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent] == EKAuthorizationStatusAuthorized:YES);
}

+(id)getInstance
{
	if (_ekSyncSingleton == nil)
	{
		_ekSyncSingleton = [[EKSync alloc] init];
	}
	
	return _ekSyncSingleton;
}

+(void)free
{
	if (_ekSyncSingleton != nil)
	{
		[_ekSyncSingleton release];
		
		_ekSyncSingleton = nil;
	}
}

@end
