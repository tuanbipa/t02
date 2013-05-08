//
//  EKReminderSync.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 4/3/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//
#import <EventKit/EventKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "EKReminderSync.h"

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

extern SmartCalAppDelegate *_appDelegate;

extern SmartListViewController *_smartListViewCtrler;
extern CalendarViewController *_sc2ViewCtrler;
extern AbstractSDViewController *_abstractViewCtrler;

EKReminderSync *_ekReminderSyncSingleton;

@implementation EKReminderSync

@synthesize scEKMappingDict;
@synthesize ekSCMappingDict;
@synthesize dupCategoryList;

@synthesize eventStore;

@synthesize syncMode;

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
}

-(id) init
{
	if (self = [super init])
	{
        createList = nil;
        
        reminderFetchCond = [[NSCondition alloc] init];
        
		[self reset];
	}
	
	return self;
}

-(void) dealloc
{
    [reminderFetchCond release];
    
	[self reset];
    
	[super dealloc];
}

- (void) setReminderFetchInProgress:(BOOL)inProgress
{
	[reminderFetchCond lock];
	
	reminderFetchInProgress = inProgress;
	
	if (!inProgress)
	{
		[reminderFetchCond signal];
	}
	
	[reminderFetchCond unlock];
}

- (void) wait4ReminderFetchComplete
{
	[reminderFetchCond lock];
	
	while (reminderFetchInProgress)
	{
		[reminderFetchCond wait];
	}
    
	[reminderFetchCond unlock];
}

- (void) notifySyncCompletion:(NSNumber *)mode
{
    [[BusyController getInstance] setBusy:NO withCode:BUSY_REMINDER_SYNC];
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          mode,
                          @"SyncMode",
                          nil];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:@"EKReminderSyncCompleteNotification" object:nil userInfo:dict];
}

- (void) syncComplete
{
    [self reset];
    
    [self performSelectorOnMainThread:@selector(notifySyncCompletion:) withObject:[NSNumber numberWithInt:self.syncMode] waitUntilDone:NO];
}

- (void) syncDeletedProjects
{
    DBManager *dbm = [DBManager getInstance];
    
	NSMutableArray *delList = [[DBManager getInstance] getDeletedPlans];
    
    NSError *err;
    
    for (Project *prj in delList)
    {
        if (prj.rmdId != nil && ![prj.rmdId isEqualToString:@""])
        {
            EKCalendar *cal = [self.eventStore calendarWithIdentifier:prj.rmdId];
            
            if (cal != nil)
            {
                [self.eventStore removeCalendar:cal commit:NO error:&err];
            }
        }
        
        if ((prj.tdId != nil && ![prj.tdId isEqualToString:@""]) ||
            (prj.sdwId != nil && ![prj.sdwId isEqualToString:@""]) ||
            (prj.ekId != nil && ![prj.ekId isEqualToString:@""]))
        {
            prj.rmdId = @"";
            [prj updateReminderIDIntoDB:[dbm getDatabase]];
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
    
    prj.rmdId = @"";
    [prj updateReminderIDIntoDB:[dbm getDatabase]];
    
    NSInteger eventCount = [dbm getEventCountForProject:prj.primaryKey];
    
	NSInteger defaultPrjKey = [[Settings getInstance] taskDefaultProject];
	
	if (eventCount > 0 || prj.primaryKey == defaultPrjKey)
	{
		[dbm cleanAllTasksForProject:prj.primaryKey];
	}
	else
	{
        [pm deleteProject:prj cleanFromDB:YES];
	}
}

-(void) proceedSync:(EKSource *) ekSource
{
    DBManager *dbm = [DBManager getInstance];
    
    if (ekSource != nil && createList.count > 0)
    {
        for (Project *prj in createList)
        {
            //create calendar in EK
            EKCalendar *cal = [EKCalendar calendarForEntityType:EKEntityTypeReminder eventStore:self.eventStore];
            
            cal.title = prj.name;
            cal.source = ekSource;
            
            NSError *err = nil;
            [eventStore saveCalendar:cal commit:YES error:&err];
            
            if (err == nil)
            {
                [self.scEKMappingDict setObject:cal forKey:[NSNumber numberWithInt:prj.primaryKey]];
                [self.ekSCMappingDict setObject:[NSNumber numberWithInt:prj.primaryKey] forKey:cal.calendarIdentifier];
                
                prj.rmdId = cal.calendarIdentifier;
                [prj updateReminderIDIntoDB:[dbm getDatabase]];
            }
        }
    }
    
    if (self.syncMode == SYNC_AUTO_1WAY)
    {
        [self sync1way];
    }
    else
    {
        [self syncTasks];
    }
    
    [self syncComplete];
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
    
    NSDictionary *prjSyncDict = [ProjectManager getProjectDictByReminderSyncID:prjList];
	
	NSMutableArray *delList = [dbm getDeletedPlans];
    
    createList = [[NSMutableArray arrayWithCapacity:10] retain];
	
	self.scEKMappingDict = [NSMutableDictionary dictionaryWithCapacity:12];
	self.ekSCMappingDict = [NSMutableDictionary dictionaryWithCapacity:12];
    
	self.dupCategoryList = [NSMutableArray arrayWithCapacity:12];
    
    NSArray *ekCalList = [self.eventStore calendarsForEntityType:EKEntityTypeReminder];
    
    /*if (ekCalList.count == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_syncErrorText  message:_reminderFatalError delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
        [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        [alertView release];
        
        [self syncComplete];
        
        return;
    }*/
    
	for (EKCalendar *cal in ekCalList)
	{
		printf("EK title: %s\n", [cal.title UTF8String]);
		
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
                prj.rmdId = cal.calendarIdentifier;
                prj.source = CATEGORY_SOURCE_REMINDER;
                
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
                
                prj.rmdId = cal.calendarIdentifier;
                prj.source = CATEGORY_SOURCE_REMINDER;
                
                [pm addProject:prj];
                
                [prj release];
                
                printf("create reminder calendar %s in SC\n", [cal.title UTF8String]);
            }
            
            [self.scEKMappingDict setObject:cal forKey:[NSNumber numberWithInt:prj.primaryKey]];
            [self.ekSCMappingDict setObject:[NSNumber numberWithInt:prj.primaryKey] forKey:cal.calendarIdentifier];
            
        }
        
        //NSNumber *prjNum = [self.ekSCMappingDict objectForKey:cal.calendarIdentifier];
        
        //printf("map calendar: %s - project: %d\n", [cal.calendarIdentifier UTF8String], [prjNum intValue]);
    }
    
	delList = [NSMutableArray arrayWithCapacity:5];
    
	for (Project *prj in prjList)
	{
        if (prj.status == PROJECT_STATUS_INVISIBLE)
        {
            continue;
        }
        
        if (![prj.rmdId isEqualToString:@""]) //already synced and calendar is deleted from Reminder
        {
            EKCalendar *ekCal = [self.eventStore calendarWithIdentifier:prj.rmdId];
            
            if (ekCal == nil)
            {
                [delList addObject:prj];
            }
        }
        else
        {
            [createList addObject:prj];
        }
	}
	
	for (Project *prj in delList)
	{
        [self deleteProjectBySync:prj];
	}
    
    if (createList.count > 0)
    {
        if (ekSourceiCloud != nil && ekSourceLocal != nil)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_chooseSyncSourceText  message:_reminderMultiSourceWarningText delegate:self cancelButtonTitle:_cancelText otherButtonTitles:_sourceLocalText, _sourceiCloudText, nil];
            
            alertView.tag = -11000;
            
            [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
            [alertView release];
        }
        else if (ekSourceiCloud == nil && ekSourceLocal == nil)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_errorText message:_noReminderSourceFoundText delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
            
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

- (void) performSync
{
    [self syncProjects];
}

- (void) initSync:(NSInteger)mode
{
	////NSLog(@"begin EK sync");
    // Thuc test commit
	
	@synchronized(self)
	{
		self.syncMode = mode;
        
        self.eventStore = [[[EKEventStore alloc] init] autorelease];
        
        NSString *dupName = [self checkCalendarNameDuplication];
        
        if (dupName != nil)
        {
            NSString *msg = [NSString stringWithFormat:@"%@: %@. %@", _reminderNameDuplicationText, dupName, _reminderDuplicationResolveSuggestionText];
            
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

- (NSString *) checkCalendarNameDuplication
{
    NSMutableDictionary *nameDict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    NSArray *ekCalList = [self.eventStore calendarsForEntityType:EKEntityTypeReminder];
    
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
    
    NSArray *ekCalList = [self.eventStore calendarsForEntityType:EKEntityTypeReminder];
    
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

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertVw.tag == -10000 && buttonIndex == 1)
    {
        if (buttonIndex == 1)
        {
            [self resolveCalendarNameDuplication];
            
            //[self check1stTimeSync];
            [self performSync];
        }
        else
        {
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
        }
    }
}
#pragma mark Sync Logic
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

- (void) updateEKReminder:(EKReminder *)ekReminder withTask:(Task *)task
{
    ekReminder.title = task.name;
    ekReminder.notes = task.note;
    ekReminder.location = task.location;
    
    ekReminder.startDateComponents = task.startTime == nil?nil:[[NSCalendar autoupdatingCurrentCalendar] components:0xFF fromDate:task.startTime];
    ekReminder.dueDateComponents = task.deadline == nil?nil:[[NSCalendar autoupdatingCurrentCalendar] components:0xFF fromDate:task.deadline];

    ekReminder.completionDate = task.completionTime;
    ekReminder.completed = [task isDone]?YES:NO;
    
	if (task.repeatData != nil && task.groupKey == -1)
	{
        for (EKRecurrenceRule* rrule in ekReminder.recurrenceRules)
        {
            [ekReminder removeRecurrenceRule:rrule];
            
        }
        
        NSDate *deadline = task.deadline;
        
        if (deadline == nil)
        {
            //EK shall generate an error "A repeating reminder must have a due date" when assigning recurring rule without due date -> set today as due date
            deadline = [NSDate date];
            
            ekReminder.dueDateComponents = [[NSCalendar autoupdatingCurrentCalendar] components:0xFF fromDate:deadline];
        }
        
        [ekReminder addRecurrenceRule:[self buildRRule:task.repeatData startDate:deadline]];
	}
}

- (void) updateTask:(Task *)task withReminder:(EKReminder *)ekReminder
{
    task.syncId = ekReminder.calendarItemIdentifier;
    task.name = ekReminder.title;
    task.note = ekReminder.notes;
    task.location = ekReminder.location;
    task.startTime = (ekReminder.startDateComponents == nil?nil:[[NSCalendar autoupdatingCurrentCalendar] dateFromComponents:ekReminder.startDateComponents]);
    task.deadline = (ekReminder.dueDateComponents == nil?nil:[[NSCalendar autoupdatingCurrentCalendar] dateFromComponents:ekReminder.dueDateComponents]);
    
    task.status = (ekReminder.completed?TASK_STATUS_DONE:TASK_STATUS_NONE);
    task.completionTime = ekReminder.completionDate;
    
    task.updateTime = ekReminder.lastModifiedDate == nil?[NSDate date]:ekReminder.lastModifiedDate;
    
    if (ekReminder.recurrenceRules.count > 0)
    {
        //printf("EK recurrence count: %d\n", ekEvent.recurrenceRules.count);
        
        EKRecurrenceRule *rrule = [ekReminder.recurrenceRules objectAtIndex:0];
        
		task.repeatData = [self parseRRule:rrule event:task];
		
		//printf("RE %s - until: %s\n", [scEvent.name UTF8String], [[scEvent.repeatData.until description] UTF8String]);
        
    }
    else
    {
        task.repeatData = nil;
    }
    
	if (task.primaryKey > -1)
	{
		[task externalUpdate];
	}
}

-(void) sync1way
{
	Settings *settings = [Settings getInstance];
	DBManager *dbm = [DBManager getInstance];
    
    NSDate *rmdLastSyncTime = settings.rmdLastSyncTime;
    
    NSMutableArray *taskList = [dbm getModifiedTasks2Sync:rmdLastSyncTime];
   
	for (Task *task in taskList) //new Events from SC
	{
        //printf("SC Event for 1-way sync: %s - start: %s - end:%s\n", [scEvent.name UTF8String], [[scEvent.startTime description] UTF8String], [[scEvent.endTime description] UTF8String]);
        
		EKCalendar *cal = [self.scEKMappingDict objectForKey:[NSNumber numberWithInt:task.project]];
		
		if (cal != nil)
		{
			if (![task.syncId isEqualToString:@""]) //Task was synced to iCal
			{
				EKReminder *ekReminder = (EKReminder *)[self.eventStore calendarItemWithIdentifier:task.syncId];
				
				if (ekReminder != nil)
				{
					if (task.status == TASK_STATUS_DELETED)
					{
						//printf("Delete SC->EK: %s\n", [scEvent.name UTF8String]);
						
						NSError *err;
						
						[self.eventStore removeReminder:ekReminder commit:YES error:&err];
						
						if (err == nil)
						{
							[task cleanFromDatabase:[dbm getDatabase]];
						}
					}
                    else 
					{
						//printf("Update SC->EK: %s\n", [scEvent.name UTF8String]);
						
						[self updateEKReminder:ekReminder withTask:task];
                        
                        //printf("1 way Update SC->EK: %s - ekStart: %s - ekEnd:%s - ekID: %s\n", [scEvent.name UTF8String], [[ekEvent.startDate description] UTF8String], [[ekEvent.endDate description] UTF8String], [ekEvent.eventIdentifier UTF8String]);
                        
                        ekReminder.calendar = cal;
						
						NSError *err;
						
						BOOL ret = [self.eventStore saveReminder:ekReminder commit:YES error:&err];
						
						if (err == nil && ret && [task.updateTime compare:ekReminder.lastModifiedDate] == NSOrderedAscending)
						{
                            //bug of iOS: last modified time is not updated when saving -> may keep SD update time
                            
							[task enableExternalUpdate];
							task.updateTime = ekReminder.lastModifiedDate;
							[task modifyUpdateTimeIntoDB:[dbm getDatabase]];
							
							//printf("1-way EK Sync update SD time: %s for event:%s - now: %s\n", [[scEvent.updateTime description] UTF8String], [scEvent.name UTF8String], [[[NSDate date] description] UTF8String]);
						}
					}
				}
                else
                {
                    [task deleteFromDatabase:[dbm getDatabase]];
                }
			}
			else
			{
				EKReminder *ekReminder  = [EKReminder reminderWithEventStore:self.eventStore];
				[self updateEKReminder:ekReminder withTask:task];
                ekReminder.calendar = cal;
				
				NSError *err = nil;
				BOOL ret = [self.eventStore saveReminder:ekReminder commit:YES error:&err];
				
				if (err == nil && ret)
				{
					task.updateTime = ekReminder.lastModifiedDate;
					task.syncId = ekReminder.calendarItemIdentifier;
                    
					[task enableExternalUpdate];
					[task updateSyncIDIntoDB:[dbm getDatabase]];
                    
                    [task enableExternalUpdate];
                    [task modifyUpdateTimeIntoDB:[dbm getDatabase]];
					
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
}

- (void) syncDeletedTasks
{
    DBManager *dbm = [DBManager getInstance];
    
    NSMutableArray *delList = [dbm getDeletedTasks];
    
    for (Task *task in delList)
    {
        if ([task.syncId isEqualToString:@""])
        {
            [task cleanFromDatabase:[dbm getDatabase]];
        }
        else
        {
            NSError *err = nil;
            
            EKReminder *reminder = (EKReminder *)[self.eventStore calendarItemWithIdentifier:task.syncId];
            
            if (reminder != nil)
            {
                [self.eventStore removeReminder:reminder commit:YES error:&err];
                
                if (err == nil)
                {
                    [task cleanFromDatabase:[dbm getDatabase]];
                }
            }
        }
    }
}

- (void) syncTasks
{
    [self syncDeletedTasks];
    
	DBManager *dbm = [DBManager getInstance];
	
	NSMutableArray *taskList = [dbm getTasks2Sync];
	NSDictionary *taskDict = [TaskManager getTaskDictionaryBySyncId:taskList];
    
    NSMutableDictionary *dupCategoryDict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    if (self.dupCategoryList.count > 0)
    {
        for (NSNumber *prjNum in self.dupCategoryList)
        {
            NSMutableDictionary *taskNameDict = [NSMutableDictionary dictionaryWithCapacity:50];
            
            [dupCategoryDict setObject:taskNameDict forKey:prjNum];
        }
        
        for (Task *task in taskList)
        {
            NSMutableDictionary *taskNameDict = [dupCategoryDict objectForKey:[NSNumber numberWithInt:task.project]];
            
            if (taskNameDict != nil)
            {
                [taskNameDict setObject:task forKey:task.name];
            }
        }
    }
    
    NSArray *calList = [[self.scEKMappingDict objectEnumerator] allObjects];
    
    NSPredicate *predicate = [self.eventStore predicateForRemindersInCalendars:calList];
    
    NSMutableArray *reminderList = [NSMutableArray arrayWithCapacity:100];
    
    [self setReminderFetchInProgress:YES];
    
    [self.eventStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders)
    {
        [reminderList addObjectsFromArray:reminders];
        
        [self setReminderFetchInProgress:NO];
    }];
    
    [self wait4ReminderFetchComplete];
    
    NSError *err = nil;
    
    for (EKReminder *reminder in reminderList)
    {
        NSNumber *prjKey = [self.ekSCMappingDict objectForKey:reminder.calendar.calendarIdentifier];
        
        //printf("reminder cal id: %s - prj: %d\n", [reminder.calendar.calendarIdentifier UTF8String], prjKey == nil?-1:[prjKey intValue]);
        
        if (prjKey == nil)
        {
            continue;
        }
        
        Task *task = [taskDict objectForKey:reminder.calendarItemIdentifier];
        
        if (task != nil) //already sync
        {
            printf("task %s update time - reminder: %s - iSD: %s\n", [task.name UTF8String], [[reminder.lastModifiedDate description] UTF8String], [[task.updateTime description] UTF8String]);
            
            NSComparisonResult compRes = [Common compareDate:task.updateTime withDate:reminder.lastModifiedDate];
            
            if (compRes == NSOrderedAscending) //update Reminder->SD
            {
                if ([prjKey intValue] != task.project) // project change
                {
                    task.project = [prjKey intValue];
                }
                
                [self updateTask:task withReminder:reminder];
            }
            else if (compRes == NSOrderedDescending) //update SD->Reminder
            {
                [self updateEKReminder:reminder withTask:task];
                
                BOOL deleteFromEK = NO;
                
                if ([prjKey intValue] != task.project) // project change
                {
                    EKCalendar *cal = [self.scEKMappingDict objectForKey:[NSNumber numberWithInt:task.project]];
                    
                    if (cal != nil)
                    {
                        reminder.calendar = cal;
                    }
                    else
                    {
                        deleteFromEK = YES;
                    }
                }
                
                if (deleteFromEK)
                {
                    [self.eventStore removeReminder:reminder commit:YES error:&err];
                    
                    task.syncId = @"";
                    [task updateSyncIDIntoDB:[dbm getDatabase]];
                }
                else
                {
                    BOOL ret = [self.eventStore saveReminder:reminder commit:YES error:&err];
                    
                    if (err == nil && ret && [task.updateTime compare:reminder.lastModifiedDate] == NSOrderedAscending)
                    {
                        //bug of iOS: last modified time is not updated when saving -> may keep SD update time
                        
                        [task enableExternalUpdate];
                        task.updateTime = reminder.lastModifiedDate;
                        [task modifyUpdateTimeIntoDB:[dbm getDatabase]];
                    }
                }
            }
            
            [taskList removeObject:task];
        }
        else //new Task from Reminder
        {
            BOOL taskCreation = YES;
            
            NSDictionary *taskNameDict = [dupCategoryDict objectForKey:prjKey];
            
            if (taskNameDict != nil)
            {
                //sdw Task is in suspected duplicated category
                
                task = [taskNameDict objectForKey:reminder.title];
                
                if (task != nil)
                {
                    NSDate *start = reminder.startDateComponents!=nil?[[NSCalendar autoupdatingCurrentCalendar] dateFromComponents:reminder.startDateComponents]:nil;
                    NSDate *end = reminder.dueDateComponents!=nil?[[NSCalendar autoupdatingCurrentCalendar] dateFromComponents:reminder.dueDateComponents]:nil;
                    
                    BOOL duplicated = [Common compareDate:task.startTime withDate:start] == NSOrderedSame &&
                    [Common compareDate:task.deadline withDate:end] == NSOrderedSame;
                    
                    if (duplicated)
                    {
                        printf("task %s is duplication suspected\n", [task.name UTF8String]);
                        
                        task.syncId = reminder.calendarItemIdentifier;
                        [task updateSyncIDIntoDB:[dbm getDatabase]];
                        
                        [taskList removeObject:task];
                        taskCreation = NO;
                    }
                }
                
            }
            
            if (taskCreation)
            {
                task = [[[Task alloc] init] autorelease];
                
                [self updateTask:task withReminder:reminder];
                
                NSNumber *prjKey = [self.ekSCMappingDict objectForKey:reminder.calendar.calendarIdentifier];
                task.project = [prjKey intValue];
                
                [task enableExternalUpdate];
                [task insertIntoDB:[dbm getDatabase]];
            }
        }
    }
    
    for (Task *task in taskList) //new Tasks from SD
    {
        EKCalendar *cal = [self.scEKMappingDict objectForKey:[NSNumber numberWithInt:task.project]];
        
        if (![task.syncId isEqualToString:@""]) //Event was deleted from iCal
        {
            EKReminder *reminder = (EKReminder *)[self.eventStore calendarItemWithIdentifier:task.syncId];
            
            if (reminder == nil)
            {
                //task was deleted in Reminder
                task.syncId = @"";
                [task updateSyncIDIntoDB:[dbm getDatabase]];
                
                [task deleteFromDatabase:[dbm getDatabase]];
            }
        }
        else if (cal != nil)
        {
            EKReminder *reminder  = [EKReminder reminderWithEventStore:self.eventStore];
            reminder.calendar = cal;
            
            [self updateEKReminder:reminder withTask:task];
            
            err = nil;
            
            [eventStore saveReminder:reminder commit:YES error:&err];

            printf("create Reminder: %s\n", [reminder.title UTF8String]);
            
            if (err == nil)
            {
                task.updateTime = reminder.lastModifiedDate;
                task.syncId = reminder.calendarItemIdentifier;
                
                [task enableExternalUpdate];
                
                [task updateSyncIDIntoDB:[dbm getDatabase]];
            }
            else
            {
                printf("error: %s\n", [err.localizedDescription UTF8String]);
            }
            
        }
    }
}

#pragma mark Auto Sync

-(void)initBackgroundSync
{
	//printf("init sync background\n");
	
	[[BusyController getInstance] setBusy:YES withCode:BUSY_REMINDER_SYNC];
    
    [self performSelectorInBackground:@selector(syncBackground:) withObject:[NSNumber numberWithInt:SYNC_MANUAL_2WAY]];
}

-(void)initBackgroundAuto1WaySync
{
    [[BusyController getInstance] setBusy:YES withCode:BUSY_REMINDER_SYNC];
    
    [self performSelectorInBackground:@selector(syncBackground:) withObject:[NSNumber numberWithInt:SYNC_AUTO_1WAY]];
}

-(void)initBackgroundAuto2WaySync
{
	//printf("init sync background\n");
	
	[[BusyController getInstance] setBusy:YES withCode:BUSY_REMINDER_SYNC];
    
    [self performSelectorInBackground:@selector(syncBackground:) withObject:[NSNumber numberWithInt:SYNC_AUTO_2WAY]];
}

-(void)syncBackground:(NSNumber *) mode
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	[self initSync:[mode intValue]];
	
	[pool release];
}

#pragma mark Public Methods

+ (BOOL) checkEKReminderAccessEnabled
{
    return [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder] == EKAuthorizationStatusAuthorized;
}

+(id)getInstance
{
	if (_ekReminderSyncSingleton == nil)
	{
		_ekReminderSyncSingleton = [[EKReminderSync alloc] init];
	}
	
	return _ekReminderSyncSingleton;
}

+(void)free
{
	if (_ekReminderSyncSingleton != nil)
	{
		[_ekReminderSyncSingleton release];
		
		_ekReminderSyncSingleton = nil;
	}
}


@end
