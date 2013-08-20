//
//  TDSync.m
//  SmartCal
//
//  Created by MacBook Pro on 10/5/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "TDSync.h"

#import "TDSyncSection.h"
#import "TDAccount.h"
#import "TDClient.h"
#import "TDFolder.h"
#import "TDTask.h"
#import "TDFetchParam.h"

#import "TDFolderParser.h"
#import "TDTaskParser.h"
#import "TDAccountParser.h"
#import "TDKeyParser.h"

#import "DBManager.h"
#import "TaskManager.h"
#import "ProjectManager.h"
#import "AlertManager.h"
#import "Settings.h"
#import "Project.h"
#import "Task.h"
#import "RepeatData.h"
#import "EKSync.h"

#import "TagDictionary.h"

#import "SmartListViewController.h"

#import "BusyController.h"

#import "SmartCalAppDelegate.h"

//#import "SCTabBarController.h"

extern SmartCalAppDelegate *_appDelegate;
//extern SCTabBarController *_tabBarCtrler;

extern SmartListViewController *_smartListViewCtrler;

extern BOOL _syncMatchHintShown;

TDSync *_tdSyncSingleton;

@implementation TDSync

@synthesize tdTaskDict;
@synthesize tdDeletedTaskList;

@synthesize tdSCMappingDict;
@synthesize scTDMappingDict;
@synthesize dupCategoryList;
@synthesize tdArchivedDict;

@synthesize account;
//@synthesize key;

@synthesize syncMode;

@synthesize lastError;

@synthesize syncSection;

- (id)init
{
	if (self = [super init])
	{
		self.syncSection = nil;
		self.lastError = nil;
		
		self.syncMode = -1;
	}
	
	return self;
}

- (void)dealloc 
{
	self.tdTaskDict = nil;
	self.tdDeletedTaskList = nil;
	
	self.tdSCMappingDict = nil;
	self.scTDMappingDict = nil;
    self.dupCategoryList = nil;
    self.tdArchivedDict = nil;
    
	self.account = nil;
	//self.key = nil;
	
	self.syncSection = nil;
	self.lastError = nil;
	
	[super dealloc];
}

- (void)resetSyncSection
{
	self.syncSection = nil;
	self.account = nil;
}

- (void)reset
{
	//self.tdTaskDict = [NSMutableDictionary dictionaryWithCapacity:50];
	//self.tdDeletedTaskList = [NSMutableArray arrayWithCapacity:10];
	//self.tdSCMappingDict = [NSMutableDictionary dictionaryWithCapacity:10];
	//self.scTDMappingDict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    self.tdTaskDict = nil;
    self.tdDeletedTaskList = nil;
    self.tdSCMappingDict = nil;
    self.scTDMappingDict = nil;
    
    self.dupCategoryList = nil;
    self.tdArchivedDict = nil;
    
	self.account = nil;
	self.lastError = nil;
 	
	nFetch = 0;
	nPlanFetch = 0;
	
	noMapping = YES;
    
    sync2WayPending = NO;
    sync1WayPending = NO;
}

- (void) updateSCTask:(Task *) scTask withTDTask:(TDTask *)tdTask
{
	BOOL tagChange = ![scTask.tag isEqualToString:tdTask.tag];
		
	scTask.syncId = tdTask.id;
	scTask.name = tdTask.title;
	scTask.tag = tdTask.tag;
	scTask.note = tdTask.note;
	//scTask.startTime = (tdTask.startTime != nil?[Common fromDBDate:tdTask.startTime]:nil);
	scTask.startTime = tdTask.startTime;
	//scTask.deadline = (tdTask.dueTime != nil?[Common fromDBDate:tdTask.dueTime]:nil);
	scTask.deadline = tdTask.dueTime;
	scTask.updateTime = tdTask.modifiedTime;
	
	NSInteger prjId = [[self.tdSCMappingDict objectForKey:tdTask.folderId] intValue];
	
	scTask.project = prjId;
	
	if (tdTask.star == 1)
	{
		scTask.status = TASK_STATUS_PINNED;
	}
	else 
	{
		scTask.status = TASK_STATUS_NONE;
	}

/*	
	if (scTask.hasNoDuration)
	{
		scTask.duration = 0;
		scTask.mergedSeqNo = -1;
	}
	else if (tdTask.length > 0)
	{
		scTask.duration = tdTask.length*60;
	}
*/
	
	DBManager *dbm = [DBManager getInstance];
	NSInteger taskPlacement = [[Settings getInstance] newTaskPlacement];
	BOOL isOfCheckList = [[ProjectManager getInstance] checkListStyle:scTask.project];
	
	if (scTask.primaryKey == -1)
	{
		if (taskPlacement == 0) //on top
		{
			scTask.sequenceNo = [dbm getTaskMinSortSeqNo] - 1;
		}
		else 
		{
			scTask.sequenceNo = [dbm getTaskMaxSortSeqNo] + 1;
		}		
	}
	
	if (isOfCheckList)
	{
		scTask.type = TYPE_SHOPPING_ITEM;
		scTask.duration = 0;
	}
	else 
	{
		scTask.type = TYPE_TASK;
		scTask.duration = tdTask.length*60;
	}
	
	if (tdTask.completedTime != nil)
	{
		scTask.status = TASK_STATUS_DONE;
		
		scTask.completionTime = tdTask.completedTime;
		
		//printf("Done Task TD->SC: %s, td completed time: %s, completed time: %s\n", [scTask.name UTF8String], [[tdTask.completedTime description] UTF8String], [[scTask.completionTime description] UTF8String]);		
	}

	scTask.repeatData = [tdTask getRepeatData];
	
	if (scTask.primaryKey > -1)
	{
		[scTask externalUpdate];		
	}

	if (tagChange)
	{
		[[TagDictionary getInstance] addTagFromList:scTask.tag];
	}	
}

- (NSString *)repeatData2String:(RepeatData *)repeatData
{
	switch (repeatData.type) 
	{
		case REPEAT_DAILY:
		{
			//if (repeatData.interval > 1)
			//{
				return [NSString stringWithFormat:@"Every %d days", repeatData.interval];
			//}
		}
			break;
		case REPEAT_WEEKLY:
		{
			/*if (repeatData.interval > 1)
			{
				return [NSString stringWithFormat:@"Every %d weeks", repeatData.interval];
			}
			else */
			if (repeatData.weekOption > 0)
			{
				NSInteger wkOptions[7] = {ON_SUNDAY, ON_MONDAY, ON_TUESDAY, ON_WEDNESDAY, ON_THURSDAY, ON_FRIDAY, ON_SATURDAY}; 
				NSString *wkStrings[7] = {@"Sun", @"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat"}; 
				
				NSString *str = @"";
				
				for (int i=0; i<7; i++)
				{
					if (repeatData.weekOption & wkOptions[i])
					{
						if ([str isEqualToString:@""])
						{
							str = wkStrings[i];
						}
						else 
						{
							str = [str stringByAppendingFormat:@", %@", wkStrings[i]];
						}

					}
				}
				
				return [@"Every " stringByAppendingString:str];
			}
			
			return [NSString stringWithFormat:@"Every %d weeks", repeatData.interval];
		}
			break;
		case REPEAT_MONTHLY:
		{
			/*if (repeatData.interval > 1)
			{
				return [NSString stringWithFormat:@"Every %d months", repeatData.interval];
			}
			else*/ 
			if (repeatData.monthOption == BY_DAY_OF_WEEK)
			{ 
				NSString *ordinalStrings[5] = {@"1st", @"2nd", @"3rd", @"4th", @"5th"}; 
				
				NSString *wkStrings[7] = {@"Sun", @"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat"}; 
				
				return [NSString stringWithFormat:@"The %@ %@ of the month", ordinalStrings[repeatData.weekOrdinal], wkStrings[repeatData.weekDay]];
			}
			
			return [NSString stringWithFormat:@"Every %d months", repeatData.interval];
		}
			break;
		case REPEAT_YEARLY:
		{
			//if (repeatData.interval > 1)
			//{
				return [NSString stringWithFormat:@"Every %d years", repeatData.interval];
			//}			
		}
			break;			
	}
	
	return nil;
}

- (NSString *)task2String:(Task *)scTask idIncluded:(BOOL) idIncluded
{
	NSString *id = (idIncluded?scTask.syncId:@"");
	
	NSString *folderId = [self.scTDMappingDict objectForKey:[NSNumber numberWithInt:scTask.project]];
	
	NSString *folder = (folderId == nil? @"0":folderId);	
	
	NSString *startDate = @"0";
	NSString *startTime = @"0";
	
	if (scTask.startTime != nil)
	{
		//startDate = [NSString stringWithFormat:@"%.0f", [[Common toDBDate:scTask.startTime] timeIntervalSince1970]];
        startDate = [NSString stringWithFormat:@"%.0f", [scTask.startTime timeIntervalSince1970]];
		startTime = startDate;
	}

	NSString *dueDate = @"0";
	NSString *dueTime = @"0";
	
	if (scTask.deadline != nil)
	{
		//dueDate = [NSString stringWithFormat:@"%.0f", [[Common toDBDate:scTask.deadline] timeIntervalSince1970]];
        dueDate = [NSString stringWithFormat:@"%.0f", [scTask.deadline timeIntervalSince1970]];
		dueTime = dueDate;		
	}
	
	NSString *completedDate = @"0";
	
	if (scTask.status == TASK_STATUS_DONE)
	{
		//completedDate = [NSString stringWithFormat:@"%.0f", [[Common toDBDate:scTask.completionTime] timeIntervalSince1970]];
        completedDate = [NSString stringWithFormat:@"%.0f", [scTask.completionTime timeIntervalSince1970]];
	}
	
	NSString *repeat = @",\"repeat\":\"\"";
	
	if (scTask.repeatData != nil)
	{
		RepeatData *rptDat = [scTask.repeatData copy];
		
		if (rptDat.type == REPEAT_MONTHLY && rptDat.monthOption == BY_DAY_OF_WEEK && rptDat.weekDay == 0 && rptDat.weekOrdinal == 0)
		{
			NSDate *dt = scTask.updateTime;
			
			if (rptDat.repeatFrom == REPEAT_FROM_DUE)
			{
				if (scTask.deadline == nil)
				{
					dt = (scTask.startTime!=nil?scTask.startTime:scTask.updateTime);
				}
				else
				{
					dt = scTask.deadline;
				}
			}
			
			rptDat.weekDay = [Common getWeekday:dt];
			rptDat.weekOrdinal = [Common getWeekdayOrdinal:dt];
		}		
		
		NSString *advRepeatStr = [self repeatData2String:rptDat];
		
		if (advRepeatStr != nil)
		{
			repeat = [NSString stringWithFormat:@",\"repeatfrom\":\"%d\",\"repeat\":\"%@\"", (scTask.repeatData.repeatFrom == REPEAT_FROM_COMPLETION?1:0) , advRepeatStr];
		}
		
		[rptDat release];
	}
	
	NSString *meta = (idIncluded?@"":[NSString stringWithFormat:@",\"meta\":\"%d\"", scTask.primaryKey]);

	NSString *ret = [NSString stringWithFormat:@"{\"id\":\"%@\",\"folder\":\"%@\",\"title\":\"%@\",\"tag\":\"%@\",\"note\":\"%@\",\"star\":\"%d\",\"length\":\"%@\",\"startdate\":\"%@\",\"starttime\":\"%@\",\"duedate\":\"%@\",\"duetime\":\"%@\",\"completed\":\"%@\"%@%@}",
					 id,
					 folder,
					 [TDSync convertString: scTask.name],
					 [TDSync convertString:scTask.tag],
					 [TDSync convertString:scTask.note],
					 (scTask.status == TASK_STATUS_PINNED?1:0),
					 [NSString stringWithFormat:@"%d", scTask.duration/60],
					 startDate,
					 startTime,
					 dueDate,
					 dueTime,
					 completedDate,
					 repeat,
					 meta
					 ];

	return ret;
}

- (void) updateTask2TD:(Task *)scTask
{
	//NSString *paramStr = [NSString stringWithFormat:@"key=%@;tasks=[%@]", self.syncSection.key, [TDSync encodeString:[self task2String:scTask idIncluded:YES]]];
	NSString *paramStr = [NSString stringWithFormat:@"tasks=[%@]", [TDSync encodeString:[self task2String:scTask idIncluded:YES]]];
	
	TDFetchParam *param = [TDFetchParam fetchParamWithCommand:FETCH_EDIT_TASK param:paramStr];	
	
	nFetch ++;
	[[TDClient getInstance] fetchData:param delegate:self didFinishSelector:@selector(fetchEditTaskSuccess:userInfo:) didFailSelector:@selector(fetchEditTaskError:) userInfo:scTask];			
}

- (void) addTask2TD:(Task *)scTask
{
	//NSString *paramStr = [NSString stringWithFormat:@"key=%@;tasks=[%@]", self.syncSection.key, [TDSync encodeString:[self task2String:scTask idIncluded:NO]]];
	NSString *paramStr = [NSString stringWithFormat:@"tasks=[%@]", [TDSync encodeString:[self task2String:scTask idIncluded:NO]]];
	
	TDFetchParam *param = [TDFetchParam fetchParamWithCommand:FETCH_ADD_TASK param:paramStr];	
	
	nFetch ++;
	[[TDClient getInstance] fetchData:param delegate:self didFinishSelector:@selector(fetchAddTaskSuccess:userInfo:) didFailSelector:@selector(fetchError:) userInfo:scTask];	
	
	//printf("Add Task SC->TD: ");
	[scTask print];
}

- (void) deleteTask2TD:(Task *)scTask
{
	//NSString *paramStr = [NSString stringWithFormat:@"key=%@;tasks=[\"%@\"]", self.syncSection.key, scTask.syncId];
	NSString *paramStr = [NSString stringWithFormat:@"tasks=[\"%@\"]", scTask.syncId];
	
	nFetch ++;
	[[TDClient getInstance] fetchData:[TDFetchParam fetchParamWithCommand:FETCH_DELETE_TASK param:paramStr] delegate:self didFinishSelector:@selector(fetchDeleteTaskSuccess:userInfo:) didFailSelector:@selector(fetchError:) userInfo:scTask];
}

/*
- (void) addTask2SC:(TDTask *) tdTask
{
	Task *task = [[Task alloc] init];
	
	[self updateSCTask:task withTDTask:tdTask];
	
	NSNumber *prjKey = [self.tdSCMappingDict objectForKey:tdTask.folderId];
	
	if (prjKey != nil)
	{
		task.project = [prjKey intValue];
		
		[[TaskManager getInstance] sortTask:task];
		
		//printf("Add Task TD->SC: ");
		[task print];		
	}
	
	[task release];
}
*/
- (void) addTask2ImportList:(NSMutableArray *)importList tdTask:(TDTask *)tdTask
{
	Task *task = [[Task alloc] init];
	
	[self updateSCTask:task withTDTask:tdTask];
	
	NSNumber *prjKey = [self.tdSCMappingDict objectForKey:tdTask.folderId];
	
	if (prjKey != nil)
	{
		task.project = [prjKey intValue];		
		//printf("Add Task TD->SC: ");
		[task print];		
	}
	
	[importList addObject:task];
	
	[task release];
}

- (void) addPlan2TD:(Project *)plan 
{
	//NSString *paramStr = [NSString stringWithFormat:@"key=%@;name=%@", self.syncSection.key, [TDSync encodeString:plan.name]];
	NSString *paramStr = [NSString stringWithFormat:@"name=%@", [TDSync encodeString:plan.name]];
	
	TDFetchParam *param = [TDFetchParam fetchParamWithCommand:FETCH_ADD_FOLDER param:paramStr];	
	
	nPlanFetch ++;
	
	[[TDClient getInstance] fetchData:param delegate:self didFinishSelector:@selector(fetchAddFolderSuccess:userInfo:) didFailSelector:@selector(fetchAddFolderError:) userInfo:plan];	
	
	//printf("Add Folder SP->TD: %s - nPlanFetch:%d\n", [plan.name UTF8String], nPlanFetch);
}

- (void) deletePlan2TD:(Project *)plan
{
	//NSString *paramStr = [NSString stringWithFormat:@"key=%@;id=%@", self.syncSection.key, plan.tdId];
	NSString *paramStr = [NSString stringWithFormat:@"id=%@", plan.tdId];
	
	nFetch ++;
	[[TDClient getInstance] fetchData:[TDFetchParam fetchParamWithCommand:FETCH_DELETE_FOLDER param:paramStr] delegate:self didFinishSelector:@selector(fetchDeleteFolderSuccess:userInfo:) didFailSelector:@selector(fetchDeleteFolderError:) userInfo:plan];
}

- (void) updatePlan2TD:(Project *)plan
{
	//NSString *paramStr = [NSString stringWithFormat:@"key=%@;id=%@;name=%@", self.syncSection.key, plan.tdId, [TDSync encodeString:plan.name]];
	NSString *paramStr = [NSString stringWithFormat:@"id=%@;name=%@", plan.tdId, [TDSync encodeString:plan.name]];
	
	nPlanFetch ++;
	[[TDClient getInstance] fetchData:[TDFetchParam fetchParamWithCommand:FETCH_EDIT_FOLDER param:paramStr] delegate:self didFinishSelector:@selector(fetchEditFolderSuccess:userInfo:) didFailSelector:@selector(fetchEditFolderError:) userInfo:plan];
}

/*
- (NSDictionary *) getProjectDict
{
	NSMutableArray *projectList = [[ProjectManager getInstance] projectList];
	
	NSMutableArray *mappingList = [NSMutableArray arrayWithCapacity:projectList.count];
	
	for (Project *project in projectList)
	{
		[mappingList addObject:project.name];
	}
	
	return [NSDictionary dictionaryWithObjects:projectList forKeys:mappingList];
}
*/

- (NSDictionary *) getProjectMappingDict
{
	NSMutableArray *projectList = [[ProjectManager getInstance] projectList];

	NSMutableArray *mappingList = [NSMutableArray arrayWithCapacity:projectList.count];
	
	for (Project *project in projectList)
	{
		[mappingList addObject:project.tdId];
	}
	
	return [NSDictionary dictionaryWithObjects:projectList forKeys:mappingList];
}

- (NSDictionary *) getSyncDictionaryForList:(NSMutableArray *)taskList
{
	NSMutableArray *mappingList = [NSMutableArray arrayWithCapacity:taskList.count];
	
	for (Task *task in taskList)
	{
		[mappingList addObject:task.syncId];
	}
	
	return [NSDictionary dictionaryWithObjects:taskList forKeys:mappingList];
}
	
- (void) syncError:(NSString *)error
{
	//printf("syncError: %s\n", [error UTF8String]);
	self.lastError = error;
	
	if (nFetch == 0 || nPlanFetch == 0)
	{
		nFetch = -1;
		nPlanFetch = -1;
		
		[self performSelectorOnMainThread:@selector(syncComplete) withObject:nil waitUntilDone:NO];		
	}	
}

- (void) notifySyncCompletion:(NSNumber *)mode
{
	//printf("notify sync complete with mode: %d\n", [mode intValue]);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		
    [[BusyController getInstance] setBusy:NO withCode:BUSY_TD_SYNC];
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          mode, 
                          @"SyncMode",
                          nil];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TDSyncCompleteNotification" object:nil userInfo:dict];
}

- (void) syncComplete
{
	NSString *taskMappingList = [[ProjectManager getInstance] getMappingList:YES];
	
	Settings *settings = [Settings getInstance];
	
	settings.tdSyncReset = NO;
	
	[self performSelectorOnMainThread:@selector(notifySyncCompletion:) withObject:[NSNumber numberWithInt:self.syncMode] waitUntilDone:NO];
	
	self.syncMode = -1;
	
	if (sync2WayPending)
	{
		sync2WayPending = NO;
		
		//printf("continue to sync 2 way\n");
		
		[self initBackgroundSync];
	}
	else if (sync1WayPending)
	{
		sync1WayPending = NO;
		
		//printf("continue to sync 1 way\n");
		
		[self initBackground1WaySync];
	}
	
	if (self.lastError != nil)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_syncErrorText message:self.lastError delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
		
		[alertView show];
		[alertView release];
		
		self.lastError = nil;
	}
    else
    {
        settings.tdLastAddEditTime = account.lastAddEditTime;
        settings.tdLastDeleteTime = account.lastDeleteTime;
        settings.tdLastSyncTime = [NSDate date];
        
        /*//printf("sync complete - last edit: %s, last delete: %s, last sync: %s\n",
         [[settings.tdLastAddEditTime description] UTF8String],
         [[settings.tdLastDeleteTime description] UTF8String],
         [[settings.tdLastSyncTime description] UTF8String]		   
         );
         */
    }
    
    [settings changeToodledoSync];
	
	if (!noMapping && [[Settings getInstance] syncMatchHint])
	{
		NSString *msg = [NSString stringWithFormat:@"%@: %@.\n %@", _matchTaskCalendarText, taskMappingList, _toMatchTaskCalendarText];
		
		UIAlertView *syncMatchHintAlertView = [[UIAlertView alloc] initWithTitle:_toodledoSyncText message:msg delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
		
		syncMatchHintAlertView.tag = -10002;
		
		[syncMatchHintAlertView addButtonWithTitle:_dontShowText];
		[syncMatchHintAlertView show];
		[syncMatchHintAlertView release];
		
		_syncMatchHintShown = YES;		
	}
	
	//printf("sync complete\n");
}

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertVw.tag == -10002 && buttonIndex == 1)
	{
		[[Settings getInstance] enableSyncMatchHint:NO];
	}
	else if (_smartListViewCtrler != nil)
	{
		[_smartListViewCtrler syncComplete];
	}	
}

#pragma mark Batch Operations
- (void) batchAddTask2TD:(NSMutableArray *)list
{
	NSString *tasks = nil;
	
	for (Task *scTask in list)
	{
		if (tasks == nil)
		{
			tasks = [self task2String:scTask idIncluded:NO];
		}
		else 
		{
			tasks = [NSString stringWithFormat:@"%@,%@", tasks, [self task2String:scTask idIncluded:NO]];
		}
	}
	
	//NSString *paramStr = [NSString stringWithFormat:@"key=%@;tasks=[%@]", self.syncSection.key, tasks==nil?@"":[TDSync encodeString:tasks]];
	NSString *paramStr = [NSString stringWithFormat:@"tasks=[%@]", tasks==nil?@"":[TDSync encodeString:tasks]];
	
	TDFetchParam *param = [TDFetchParam fetchParamWithCommand:FETCH_ADD_TASK param:paramStr];	
	
	nFetch ++;
	[[TDClient getInstance] fetchData:param delegate:self didFinishSelector:@selector(batchFetchAddTaskSuccess:userInfo:) didFailSelector:@selector(fetchError:) userInfo:list];	
}

- (void)batchFetchAddTaskSuccess:(NSData *)xmlData userInfo:(NSObject *)userInfo
{
	//NSString *dat = [[[NSString alloc] initWithData:xmlData encoding:NSASCIIStringEncoding] autorelease];
	
	////printf("Batch Add Tasks XML: %s\n", [dat UTF8String]);
	@synchronized(self)
	{
		nFetch--;
		
		NSMutableArray *scTasks = (NSMutableArray *) userInfo;
		
		TDTaskParser *parser = [[TDTaskParser alloc] init];
		
		[parser parseXML:xmlData];	
		
		if (parser.error != nil)
		{		
			[self syncError:parser.error];
		}
		else 
		{
			NSMutableArray *fetchTasks = parser.tasks;
			
			NSDictionary *scTaskDict = [TaskManager getTaskDictionary:scTasks];
			
			for (TDTask *tdTask in fetchTasks)
			{
				Task *scTask = [scTaskDict objectForKey:[NSNumber numberWithInt:[tdTask.meta intValue]] ];
				
				if (scTask != nil)
				{
					scTask.syncId = tdTask.id;
					scTask.updateTime = tdTask.modifiedTime;
					
					//printf("batch add - task: %s, modified time: %s\n", [scTask.name UTF8String], [[scTask.updateTime description] UTF8String]);
					
					[scTask enableExternalUpdate];
					[scTask updateSyncIDIntoDB:[[DBManager getInstance] getDatabase]];
				}
			}		
		}
		
		[parser release];
		
		[self checkSyncComplete];		
	}	
}


- (void) batchUpdateTask2TD:(NSMutableArray *)list
{
	NSString *tasks = nil;
	
	for (Task *scTask in list)
	{
		if (tasks == nil)
		{
			tasks = [self task2String:scTask idIncluded:YES];
		}
		else 
		{
			tasks = [NSString stringWithFormat:@"%@,%@", tasks, [self task2String:scTask idIncluded:YES]];
		}
	}
	
	//NSString *paramStr = [NSString stringWithFormat:@"key=%@;tasks=[%@]", self.syncSection.key, tasks==nil?@"":[TDSync encodeString:tasks]];
	NSString *paramStr = [NSString stringWithFormat:@"tasks=[%@]", tasks==nil?@"":[TDSync encodeString:tasks]];
	
	TDFetchParam *param = [TDFetchParam fetchParamWithCommand:FETCH_EDIT_TASK param:paramStr];	
	
	nFetch ++;
	[[TDClient getInstance] fetchData:param delegate:self didFinishSelector:@selector(batchFetchUpdateTaskSuccess:userInfo:) didFailSelector:@selector(fetchError:) userInfo:list];	
}

- (void)batchFetchUpdateTaskSuccess:(NSData *)xmlData userInfo:(NSObject *)userInfo
{
	//NSString *dat = [[[NSString alloc] initWithData:xmlData encoding:NSASCIIStringEncoding] autorelease];
	
	////printf("Batch Fetch Update Task XML: %s\n", [dat UTF8String]);
	
	@synchronized(self)
	{
		nFetch--;
		
		NSMutableArray *scTasks = (NSMutableArray *) userInfo;
		
		TDTaskParser *parser = [[TDTaskParser alloc] init];
		
		[parser parseXML:xmlData];	
		
		if (parser.error != nil)
		{
			if (parser.errorCode > 0 && parser.errorCode != 7) //not 'invalid Task id' error
			{
				[self syncError:parser.error];
			}
		}
		else 
		{
			NSMutableArray *fetchTasks = parser.tasks;
			
			NSDictionary *scTaskDict = [self getSyncDictionaryForList:scTasks];
			
			for (TDTask *tdTask in fetchTasks)
			{
				Task *scTask = [scTaskDict objectForKey:tdTask.id];
				
				if (scTask != nil)
				{
					scTask.updateTime = tdTask.modifiedTime;
					
					//printf("batch update - task: %s, modified time: %s\n", [scTask.name UTF8String], [[scTask.updateTime description] UTF8String]);
					
					[scTask enableExternalUpdate];
					[scTask modifyUpdateTimeIntoDB:[[DBManager getInstance] getDatabase]];
					
					[scTasks removeObject:scTask];
				}
				else 
				{
					scTask.syncId = @"";
					
					[scTask updateSyncIDIntoDB:[[DBManager getInstance] getDatabase]];
				}
				
			}		
		}
		
		[parser release];
		
		[self checkSyncComplete];		
	}	
}

- (void) batchDeleteTask2TD:(NSMutableArray *)list clean2SC:(BOOL)clean2SC
{
	NSString *tasks = nil;
	
	for (Task *scTask in list)
	{
		NSString *delStr = [NSString stringWithFormat:@"\"%@\"", scTask.syncId];
		if (tasks == nil)
		{
			tasks = delStr;
		}
		else 
		{
			tasks = [NSString stringWithFormat:@"%@,%@", tasks, delStr];
		}
	}
	
	//NSString *paramStr = [NSString stringWithFormat:@"key=%@;tasks=[%@]", self.syncSection.key, tasks==nil?@"":[TDSync encodeString:tasks]];
	NSString *paramStr = [NSString stringWithFormat:@"tasks=[%@]", tasks==nil?@"":[TDSync encodeString:tasks]];
	
	TDFetchParam *param = [TDFetchParam fetchParamWithCommand:FETCH_DELETE_TASK param:paramStr];	
	
	nFetch ++;
	[[TDClient getInstance] fetchData:param delegate:self didFinishSelector:(clean2SC?@selector(batchFetchCleanTaskSuccess:userInfo:):@selector(batchFetchDeleteTaskSuccess:userInfo:)) didFailSelector:@selector(fetchError:) userInfo:list];	
}

- (void)batchFetchDeleteTaskSuccess:(NSData *)xmlData userInfo:(NSObject *)userInfo
{
	//NSString *dat = [[[NSString alloc] initWithData:xmlData encoding:NSASCIIStringEncoding] autorelease];
	
	////printf("Batch Fetch Delete Task XML: %s\n", [dat UTF8String]);
	
	@synchronized(self)
	{
		nFetch--;
		
		NSMutableArray *scTasks = (NSMutableArray *) userInfo;	
		
		TDTaskParser *parser = [[TDTaskParser alloc] init];
		parser.forDeletion = YES;
		
		[parser parseXML:xmlData];	
		
		if (parser.error != nil)
		{
			if (parser.errorCode > 0 && parser.errorCode != 7) //not 'invalid Task id' error
			{
				[self syncError:parser.error];
			}
		}
		else 
		{
			DBManager *dbm = [DBManager getInstance];
			
			NSDictionary *scTaskDict = [self getSyncDictionaryForList:scTasks];
			
			NSMutableArray *fetchTasks = parser.tasks;
			
			for (TDTask *tdTask in fetchTasks)
			{
				Task *scTask = [scTaskDict objectForKey:tdTask.id];
				
				if (scTask != nil)
				{
					scTask.syncId = @"";
					[scTask updateSyncIDIntoDB:[dbm getDatabase]];
				}
			}
		}		
		
		[parser release];
		
		[self checkSyncComplete];		
	}	
}

- (void)batchFetchCleanTaskSuccess:(NSData *)xmlData userInfo:(NSObject *)userInfo
{
	//NSString *dat = [[[NSString alloc] initWithData:xmlData encoding:NSASCIIStringEncoding] autorelease];
	
	////printf("Batch Fetch Delete Task XML: %s\n", [dat UTF8String]);
	
	@synchronized(self)
	{
		nFetch--;
		
		TDTaskParser *parser = [[TDTaskParser alloc] init];
		parser.forDeletion = YES;
		
		[parser parseXML:xmlData];	
		
		if (parser.error != nil)
		{
			if (parser.errorCode > 0 && parser.errorCode != 7) //not 'invalid Task id' error
			{
				[self syncError:parser.error];
			}
		}
		else 
		{
			DBManager *dbm = [DBManager getInstance];
			
			NSMutableArray *fetchTasks = parser.tasks;
			
			for (TDTask *tdTask in fetchTasks)
			{
				[dbm cleanTaskByToodledoId:tdTask.id];
			}
		}		
		
		[parser release];
		
		[self checkSyncComplete];		
	}	
}

- (BOOL) batchExecute:(NSMutableArray *)list task:(Task *)task command:(TDSyncCommand)command
{
	[list addObject:task];
	
	if (list.count == 50)
	{
		switch (command) 
		{
			case SYNC_COMMAND_ADD:
				[self batchAddTask2TD:list];				
				break;
			case SYNC_COMMAND_UPDATE:
				[self batchUpdateTask2TD:list];				
				break;
			case SYNC_COMMAND_DELETE:
				[self batchDeleteTask2TD:list clean2SC:NO];				
				break;
			case SYNC_COMMAND_CLEAN:
				[self batchDeleteTask2TD:list clean2SC:YES];				
				break;
			default:
				break;
		}
		
		return YES;
	}
	
	return NO;
}

#pragma mark Mapping

- (void) mapFolder_1waySync:(NSMutableArray *) folders
{
    ProjectManager *pm = [ProjectManager getInstance];
    DBManager *dbm = [DBManager getInstance];
    
    NSMutableArray *prjList = pm.projectList;
    
    NSDictionary *projectDict = [ProjectManager getProjectDictByName:prjList]; 
    NSDictionary *projectSyncDict = [ProjectManager getProjectDictByTaskSyncID:prjList];
    
    self.tdSCMappingDict = [NSMutableDictionary dictionaryWithCapacity:10];
    self.scTDMappingDict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    for (TDFolder *folder in folders)
    {
        if (folder.archived)
        {
            [self.tdArchivedDict setObject:folder.id forKey:folder.id];
            
            continue;
        }
        
        Project *project = [projectSyncDict objectForKey:folder.id];
        
        if (project.status == PROJECT_STATUS_INVISIBLE)
        {
            continue;
        }
        
        if (project != nil) //already synced
        {
            if (![[project.name uppercaseString] isEqualToString:[folder.name uppercaseString]])
            {
                project.name = folder.name;
                
                [project updateNameIntoDB:[dbm getDatabase]];
                
                [self.scTDMappingDict setObject:folder.id forKey:[NSNumber numberWithInt:project.primaryKey]];
                [self.tdSCMappingDict setObject:[NSNumber numberWithInt:project.primaryKey] forKey:folder.id];
                
            }
        }
        else 
        {
            project = [projectDict objectForKey:[folder.name uppercaseString]]; 
            
            if (project != nil) //match project name
            {
                //printf("match folder name: %s\n", [folder.name UTF8String]);
                
                project.tdId = folder.id;
                [project updateToodledoIDIntoDB:[dbm getDatabase]];
                
                [self.scTDMappingDict setObject:folder.id forKey:[NSNumber numberWithInt:project.primaryKey]];
                [self.tdSCMappingDict setObject:[NSNumber numberWithInt:project.primaryKey] forKey:folder.id];
            }
            else //new folder -> create plan in SP  
            {
                //printf("create new folder in SP: %s - id: %s\n", [folder.name UTF8String], [folder.id UTF8String]);
                
                Project *newProject = [[Project alloc] init];
                newProject.name = folder.name;
                newProject.colorId = [pm getSuggestColorId];
                
                [pm addProject:newProject];
                
                newProject.tdId = folder.id;
                [newProject updateToodledoIDIntoDB:[dbm getDatabase]];
                
                [newProject release];
                
                [self.scTDMappingDict setObject:folder.id forKey:[NSNumber numberWithInt:newProject.primaryKey]];
                [self.tdSCMappingDict setObject:[NSNumber numberWithInt:newProject.primaryKey] forKey:folder.id];
                
            }
        }
    }
    
    [self fetchDeletedTasks];
}

-(void)deleteProjectBySync:(Project *)prj
{
    DBManager *dbm = [DBManager getInstance];
    ProjectManager *pm = [ProjectManager getInstance];
    
    prj.tdId = @"";
    [prj updateToodledoIDIntoDB:[dbm getDatabase]];
    
    NSInteger eventCount = [dbm getEventCountForProject:prj.primaryKey];
    
	NSInteger defaultPrjKey = [[Settings getInstance] taskDefaultProject];
	
	if (eventCount > 0 || prj.primaryKey == defaultPrjKey)
	{
		[dbm cleanAllTasksForProject:prj.primaryKey];
	}
	else 
	{
        /*
		[pm.cascadeDictionary removeObjectForKey:[NSNumber numberWithInt:prj.primaryKey]];
        
		[prj deleteFromDatabase];
		
		[pm.projectList removeObject:prj];	
        */
        [pm deleteProject:prj cleanFromDB:YES];
	}
}

- (void) mapFolder:(NSMutableArray *) folders
{
    Settings *settings = [Settings getInstance];
    ProjectManager *pm = [ProjectManager getInstance];
    DBManager *dbm = [DBManager getInstance];
    
    NSMutableArray *prjList = [NSMutableArray arrayWithArray: pm.projectList];
    
    NSDictionary *projectDict = [ProjectManager getProjectDictByName:prjList]; 
    NSDictionary *projectSyncDict = [ProjectManager getProjectDictByTaskSyncID:prjList];
    
    self.tdSCMappingDict = [NSMutableDictionary dictionaryWithCapacity:10];
    self.scTDMappingDict = [NSMutableDictionary dictionaryWithCapacity:10];
    self.dupCategoryList = [NSMutableArray arrayWithCapacity:10];
    self.tdArchivedDict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    BOOL syncReset = NO;
    
    BOOL needUpdateEK = NO;
    
    for (TDFolder *folder in folders)
    {
        //printf("folder: %s - id: %s - archived: %s\n", [folder.name UTF8String], [folder.id UTF8String], folder.archived?"YES":"NO");
        
        if (folder.archived)
        {
            [self.tdArchivedDict setObject:folder.id forKey:folder.id];
            
            continue;
        }
        
        Project *project = [projectSyncDict objectForKey:folder.id];
        
        if (project.status == PROJECT_STATUS_INVISIBLE)
        {
            continue;
        }
        
        if (project != nil) //already synced
        {
            if (![[project.name uppercaseString] isEqualToString:[folder.name uppercaseString]])
            {
                //change name in TD
                [self updatePlan2TD:project];
            }
            
            //printf("folder was synced: %s, TD id:%s\n", [folder.name UTF8String], [project.tdId UTF8String]);
            
            [self.scTDMappingDict setObject:folder.id forKey:[NSNumber numberWithInt:project.primaryKey]];
            [self.tdSCMappingDict setObject:[NSNumber numberWithInt:project.primaryKey] forKey:folder.id];
            
            [prjList removeObject:project]; 
        }
        else 
        {
            project = [projectDict objectForKey:[folder.name uppercaseString]]; 
            
            if (project != nil) //match project name
            {
                //printf("match folder name: %s\n", [folder.name UTF8String]);
                
                syncReset = YES;						
                
                project.tdId = folder.id;
                [project updateToodledoIDIntoDB:[dbm getDatabase]];
                
                [self.dupCategoryList addObject:[NSNumber numberWithInt:project.primaryKey]];
                
                [prjList removeObject:project];
            }
            else //new folder -> create plan in SP  
            {
                //printf("create new folder in SP: %s - id: %s\n", [folder.name UTF8String], [folder.id UTF8String]);
                
                project = [[[Project alloc] init] autorelease];
                project.name = folder.name;
                project.colorId = [pm getSuggestColorId];
                
                [pm addProject:project];
                
                project.tdId = folder.id;
                [project updateToodledoIDIntoDB:[dbm getDatabase]];
                
                syncReset = YES;
                
                needUpdateEK = YES;
            }
            
            [self.scTDMappingDict setObject:folder.id forKey:[NSNumber numberWithInt:project.primaryKey]];
            [self.tdSCMappingDict setObject:[NSNumber numberWithInt:project.primaryKey] forKey:folder.id];
        }
    }
    
    if (syncReset)
    {
        [settings resetToodledoSync];
    }
    
    BOOL resetCalendar = NO;
    BOOL folderCreation = NO;
    
    NSMutableArray *delList = [NSMutableArray arrayWithCapacity:5];
    NSMutableArray *hiddenList = [NSMutableArray arrayWithCapacity:5];
    
    for (Project *prj in prjList)
    {
        if (prj.status == PROJECT_STATUS_INVISIBLE)
        {
            [hiddenList addObject:prj];
            
            continue;
        }
        
        if (prj.tdId != nil && ![prj.tdId isEqualToString:@""]) //project was deleted in SDW
        {
            [delList addObject:prj];
        }
    }  
    
    if (delList.count > 0)
    {
        resetCalendar = YES;
        
        needUpdateEK = YES;        
    }
    
    for (Project *prj in delList)
    {
        /*
        NSInteger eventCount = [dbm getEventCountForProject:prj.primaryKey];
        
        if (eventCount > 0)
        {
            //printf("delete tasks in project: %s\n", [prj.name UTF8String]);

            [dbm cleanAllTasksForProject:prj.primaryKey];
        }
        else 
        {
            //printf("delete project: %s\n", [prj.name UTF8String]);
            
            [pm deleteProjectBySync:prj];	
            
            resetCalendar = YES;
            
            needUpdateEK = YES;
        }
        */
        
        [self deleteProjectBySync:prj];
        
        [prjList removeObject:prj];        
    }
    
    for (Project *prj in hiddenList)
    {
        [prjList removeObject:prj];
    }    
    
    for (Project *prj in prjList)
    {
        folderCreation = YES;
        
        [self addPlan2TD:prj];
    }
    
    if (needUpdateEK && [[Settings getInstance] ekSyncEnabled])
    {
        EKSync *ekSync = [EKSync getInstance];
        
        [ekSync syncProjects];
    }
    
    if (!folderCreation)
    {
        //printf("fetchFolderSuccess\n");
        
        if (self.syncMode == SYNC_AUTO_1WAY)
        {
            [self sync1way];
        }
        else
        {
            [self fetchDeletedTasks];
        }
    }	
    else 
    {
        settings.tdLastSyncTime = nil;
    }
    
}


#pragma mark Toodledo Fetch 

- (void)fetchAccount
{
	//NSString *paramStr = [NSString stringWithFormat:@"key=%@",self.syncSection.key];
	NSString *paramStr = @"";

	[[TDClient getInstance] fetchData:[TDFetchParam fetchParamWithCommand:FETCH_ACCOUNT param:paramStr] delegate:self didFinishSelector:@selector(fetchAccountSuccess:userInfo:) didFailSelector:@selector(fetchError:) userInfo:nil];		
}

- (void)fetchAccountSuccess:(NSData *)xmlData userInfo:(NSObject *)userInfo
{
	//NSString *dat = [[[NSString alloc] initWithData:xmlData encoding:NSASCIIStringEncoding] autorelease];
	
	////printf("Account XML: %s\n", [dat UTF8String]);
	
	TDAccountParser *parser = [[TDAccountParser alloc] init];
	
	[parser parseXML:xmlData];
	
	if (parser.error != nil)
	{
		[self syncError:parser.error];
	}
	else 
	{
		self.account = parser.account;
		
		//printf("Account - lastaddedit: %s - lastdelete: %s\n", [[self.account.lastAddEditTime description] UTF8String], [[self.account.lastDeleteTime description] UTF8String]);
		
		//[self syncComplete];
		
		[self performSelectorOnMainThread:@selector(syncComplete) withObject:nil waitUntilDone:NO];

	}
	
	[parser release];
}

- (void)fetchTask
{
	NSDate *modAfter = [[Settings getInstance] tdLastAddEditTime];
	
	NSString *paramStr = [NSString stringWithFormat:@"%@", (modAfter != nil?[NSString stringWithFormat:@"modafter=%.0f",[modAfter timeIntervalSince1970]]:@"")];
	
	TDFetchParam *param = [TDFetchParam fetchParamWithCommand:FETCH_TASK param:paramStr];
	
	nFetch ++;
	
	[[TDClient getInstance] fetchData:param delegate:self didFinishSelector:@selector(fetchTaskSuccess:userInfo:) didFailSelector:@selector(fetchError:) userInfo:nil];					
}

- (void)fetchTaskSuccess:(NSData *)xmlData userInfo:(NSObject *)userInfo
{
	//NSString *dat = [[[NSString alloc] initWithData:xmlData encoding:NSASCIIStringEncoding] autorelease];
	
	////printf("Fetch Task XML: %s\n", [dat UTF8String]);
	
	@synchronized(self)
	{
		nFetch --;
		
		TDTaskParser *parser = [[TDTaskParser alloc] init];
		
		[parser parseXML:xmlData];
		
		if (parser.error != nil)
		{
			[self syncError:parser.error];
		}
		else 
		{
            self.tdTaskDict = [NSMutableDictionary dictionaryWithCapacity:100];
            
			NSMutableArray *tasks = parser.tasks;
			
			for (TDTask *task in tasks)
			{
				[task print];
				
				if (task.folderId != nil && ![task.folderId isEqualToString:@"0"])
				{
					NSMutableArray *taskList = [self.tdTaskDict objectForKey:task.folderId];
					
					if (taskList == nil)
					{
						taskList = [NSMutableArray arrayWithCapacity:10];
						
						[self.tdTaskDict setObject:taskList forKey:task.folderId];
					}
					
					[taskList addObject:task];				
				}
			}		
			
			if (nFetch == 0)
			{
                if (self.syncMode == SYNC_MANUAL_1WAY_TD2SD)
                {
                    [self sync1way_TD2SD];
                }
                else 
                {
                    [self sync];                    
                }
			}		
		}
		
		[parser release];		
	}
	
}

- (void)fetchDeletedTasks
{
	NSDate *delAfter = [[Settings getInstance] tdLastDeleteTime];
	
	//NSString *paramStr = [NSString stringWithFormat:@"key=%@%@",self.syncSection.key,(delAfter != nil?[NSString stringWithFormat:@";after=%.0f",[delAfter timeIntervalSince1970]]:@"")];	
	NSString *paramStr = [NSString stringWithFormat:@"%@",(delAfter != nil?[NSString stringWithFormat:@"after=%.0f",[delAfter timeIntervalSince1970]]:@"")];	
	
	nFetch ++;
	
	[[TDClient getInstance] fetchData:[TDFetchParam fetchParamWithCommand:FETCH_ALL_DELETED_TASK param:paramStr] delegate:self didFinishSelector:@selector(fetchDeletedTasksSuccess:userInfo:) didFailSelector:@selector(fetchError:) userInfo:nil];	
}

- (void)fetchDeletedTasksSuccess:(NSData *)xmlData userInfo:(NSObject *)userInfo
{
	//NSString *dat = [[[NSString alloc] initWithData:xmlData encoding:NSASCIIStringEncoding] autorelease];
	
	////printf("Deleted Tasks XML: %s\n", [dat UTF8String]);
	
	@synchronized(self)
	{
		nFetch --;
		
		TDTaskParser *parser = [[TDTaskParser alloc] init];
		
		[parser parseXML:xmlData];
		
		if (parser.error != nil)
		{
			[self syncError:parser.error];
		}
		else 
		{
			self.tdDeletedTaskList = parser.tasks;
			
			[self fetchTask];
		}
		
		[parser release];		
	}	
}

- (void)fetchFolder
{
	//NSString *paramStr = [NSString stringWithFormat:@"key=%@",self.syncSection.key];
	NSString *paramStr = @"";
	nFetch ++;
	
	[[TDClient getInstance] fetchData:[TDFetchParam fetchParamWithCommand:FETCH_ALL_FOLDER param:paramStr] delegate:self didFinishSelector:@selector(fetchFolderSuccess:userInfo:) didFailSelector:@selector(fetchError:) userInfo:nil];		
}

- (void)fetchFolderSuccess:(NSData *)xmlData userInfo:(NSObject *)userInfo
{
	@synchronized(self)
	{
		nFetch --;
		
		TDFolderParser *parser = [[TDFolderParser alloc] init];
		
		[parser parseXML:xmlData];
		
		if (parser.error != nil)
		{
			[self syncError:parser.error];
		}
		else 
		{
			if (self.syncMode == SYNC_MANUAL_1WAY_TD2SD)
            {
                [self mapFolder_1waySync:parser.folders];
            }
            else 
            {
                [self mapFolder:parser.folders];
            }
		}
		
		[parser release];		
	}		
}

- (void)fetchAddFolderSuccess:(NSData *)xmlData userInfo:(NSObject *)userInfo
{
	@synchronized(self)
	{
		nPlanFetch--;
		
		Project *plan = (Project *) userInfo;
		
		//printf("fetchAddFolderSuccess: %s - nPlanFetch = %d\n", [plan.name UTF8String], nPlanFetch);
		
		TDFolderParser *parser = [[TDFolderParser alloc] init];
		
		[parser parseXML:xmlData];
		
		if (parser.error != nil)
		{
			[self syncError:parser.error];
		}
		else 
		{
			NSMutableArray *folders = parser.folders;
			
			if (folders.count == 1)
			{
				TDFolder *folder = [folders objectAtIndex:0];
				
				//printf("successfully added folder %s to TD  - nPlanFetch = %d\n", [folder.name UTF8String], nPlanFetch);
				
				plan.tdId = folder.id;
				[plan updateToodledoIDIntoDB:[[DBManager getInstance] getDatabase]];
				
				[self.scTDMappingDict setObject:folder.id forKey:[NSNumber numberWithInt:plan.primaryKey]];
				[self.tdSCMappingDict setObject:[NSNumber numberWithInt:plan.primaryKey] forKey:folder.id];			
			}
		}
		
		[parser release];
		
		if (nPlanFetch == 0)
		{
			nPlanFetch = -1;
            
			if (self.syncMode == SYNC_AUTO_1WAY)
			{
				[self sync1way];
			}
			else 
			{
				[self fetchDeletedTasks];
			}
            
		}		
	}
}

- (void)fetchAddFolderError:(NSError *)error
{
	//printf("sync error: %s\n", [[error localizedDescription] UTF8String]);
	
	@synchronized(self)
	{
		nPlanFetch --;
		
		[self syncError:[error localizedDescription]];
		
		[self checkSyncComplete];		
	}	
}

- (void)fetchEditFolderSuccess:(NSData *)xmlData userInfo:(NSObject *)userInfo
{
	@synchronized(self)
	{
		nPlanFetch--;
	}
}

- (void)fetchEditFolderError:(NSError *)error
{
	@synchronized(self)
	{	
		nPlanFetch --;
	
		[self syncError:[error localizedDescription]];
		
		[self checkSyncComplete];		
	}
}

- (void)fetchDeleteFolderSuccess:(NSData *)xmlData userInfo:(NSObject *)userInfo
{
	@synchronized(self)
	{
		nFetch--;

		Project *plan = (Project *)userInfo;
	
		if ((plan.ekId != nil && ![plan.ekId isEqualToString:@""]) ||
            (plan.sdwId != nil && ![plan.sdwId isEqualToString:@""]) ||
            (plan.rmdId != nil && ![plan.rmdId isEqualToString:@""]))
		{
			plan.tdId = @"";
			[plan updateToodledoIDIntoDB:[[DBManager getInstance] getDatabase]];
		}
		else 
		{
			[plan cleanFromDatabase];	
		}
		
		//[self checkCleanFolderComplete];
		[self fetchFolder];
	}
}

- (void)fetchDeleteFolderError:(NSError *)error
{
	//printf("sync error: %s\n", [[error localizedDescription] UTF8String]);
	@synchronized(self)
	{
		nFetch --;
		
		[self syncError:[error localizedDescription]];
        
        [self checkSyncComplete];
		
		//[self checkCleanFolderComplete];		
	}	
}

- (void)fetchAddTaskSuccess:(NSData *)xmlData userInfo:(NSObject *)userInfo
{
	//NSString *dat = [[[NSString alloc] initWithData:xmlData encoding:NSASCIIStringEncoding] autorelease];
	
	////printf("Fetch Add Task XML: %s\n", [dat UTF8String]);
	
	@synchronized(self)
	{
		nFetch--;
		
		Task *scTask = (Task *) userInfo;
		
		//TDKeyParser *parser = [[[TDKeyParser alloc] init] autorelease];
		TDKeyParser *parser = [[TDKeyParser alloc] init];
		
		[parser parseXML:xmlData];	
		
		if (parser.error != nil)
		{
			[self syncError:parser.error];
		}
		else 
		{
			scTask.syncId = parser.key;
			
			[scTask enableExternalUpdate];
			[scTask updateSyncIDIntoDB:[[DBManager getInstance] getDatabase]];
			
			//printf("add Task %s success with sync id:%s\n", [scTask.name UTF8String], [scTask.syncId UTF8String]);
			
			if (scTask.status == TASK_STATUS_DONE) //done Task
			{
				[self updateTask2TD:scTask];
			}
		}
		
		[parser release];
		
		[self checkSyncComplete];		
	}
}

- (void)fetchEditTaskSuccess:(NSData *)xmlData userInfo:(NSObject *)userInfo
{
	//NSString *dat = [[[NSString alloc] initWithData:xmlData encoding:NSASCIIStringEncoding] autorelease];
	
	////printf("Fetch Edit Task XML: %s\n", [dat UTF8String]);
	
	@synchronized(self)
	{
		nFetch--;
		
		TDKeyParser *parser = [[TDKeyParser alloc] init];
		
		[parser parseXML:xmlData];	
		
		if (parser.error != nil)
		{
			[self syncError:parser.error];
		}
		
		[parser release];
		
		[self checkSyncComplete]; 		
	}
}

- (void)fetchDeleteTaskSuccess:(NSData *)xmlData userInfo:(NSObject *)userInfo
{
	//NSString *dat = [[[NSString alloc] initWithData:xmlData encoding:NSASCIIStringEncoding] autorelease];
	
	////printf("Fetch Delete Task XML: %s\n", [dat UTF8String]);
	
	@synchronized(self)
	{
		nFetch--;
		
		[self checkSyncComplete];		
	}
}	

- (void)fetchError:(NSError *)error
{
	//printf("sync error: %s\n", [[error localizedDescription] UTF8String]);
	
	@synchronized(self)
	{
		nFetch --;
		
		[self syncError:[error localizedDescription]];
		
		[self checkSyncComplete];		
	}	
}

- (void)fetchEditTaskError:(NSError *)error
{
	@synchronized(self)
	{
		nFetch --;
		
		//printf("[Edit Task] sync error: %s\n", [[error localizedDescription] UTF8String]);
		
		[self checkSyncComplete];		
	}	
}

- (void) fetchToken
{
	NSString *sig = [TDSyncSection md5:[NSString stringWithFormat:@"%@%@", self.syncSection.userId, ToodledoAppToken]];
	NSString *paramStr = [NSString stringWithFormat:@"userid=%@;appid=%@;sig=%@", self.syncSection.userId, ToodledoAppID, sig];
	
	nFetch ++;
	
	TDFetchParam *param = [TDFetchParam fetchParamWithCommand:FETCH_TOKEN param:paramStr];
	
	[[TDClient getInstance] fetchData:param delegate:self didFinishSelector:@selector(fetchTokenSuccess:userInfo:) didFailSelector:@selector(fetchError:) userInfo:nil];				
}

- (void)fetchTokenSuccess:(NSData *)xmlData userInfo:(NSObject *)userInfo
{
	@synchronized(self)
	{
		nFetch --;
		
		TDKeyParser *parser = [[TDKeyParser alloc] init];
		[parser parseXML:xmlData];
		
		if (parser.error != nil)
		{
			[self syncError:parser.error];
		}
		else 
		{
			self.syncSection.token = parser.key;
			self.syncSection.lastTokenAcquireTime = [NSDate date];
			
			[self.syncSection refreshKey];
			
			//[self fetchFolder];
            if (![self cleanFolders])
            {
                [self fetchFolder];
            }
		}
		
		[parser release];		
	}	
}

- (void)fetchUserId
{
	TDSyncSection *syncingSection = [[TDSyncSection alloc] init];
	
	NSString *email = [[Settings getInstance] tdEmail];
	NSString *pwd = [[Settings getInstance] tdPassword];
	
	NSString *sig = [TDSyncSection md5:[NSString stringWithFormat:@"%@%@", email, ToodledoAppToken]];
	NSString *param = [NSString stringWithFormat:@"appid=%@;sig=%@;email=%@;pass=%@", ToodledoAppID, sig, email, pwd];
	
	nFetch ++;
	
	[[TDClient getInstance] fetchData:[TDFetchParam fetchParamWithCommand:FETCH_USER_ID param:param] delegate:self didFinishSelector:@selector(fetchUserIdSuccess:userInfo:) didFailSelector:@selector(fetchError:) userInfo:syncingSection];
	
	[syncingSection release];
}

- (void)fetchUserIdSuccess:(NSData *)xmlData userInfo:(NSObject *)userInfo
{
	@synchronized(self)
	{
		nFetch --;
		
		TDKeyParser *parser = [[TDKeyParser alloc] init];
		[parser parseXML:xmlData];
		
		if (parser.error != nil)
		{
			[self syncError:parser.error];
		}
		else 
		{
			TDSyncSection *syncingSection = (TDSyncSection *) userInfo;
			
			syncingSection.userId = parser.key;
			
			if ([syncingSection.userId isEqualToString:@"0"] || [syncingSection.userId isEqualToString:@"1"])
			{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_syncErrorText message:_accountInvalidText delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
				[alert show];
				[alert release];		
			}
			else 
			{
				self.syncSection = syncingSection;
				
				[self fetchToken];
			}
		}
		
		[parser release];		
	}
}

#pragma mark Sync 
- (BOOL) checkTaskCompletedInRange:(TDTask *)task
{
    NSDate *endDate = [Common getEndDate:[NSDate date]];
    
    NSDate *startDate = [Common clearTimeForDate:[Common dateByAddNumDay:-14 toDate:endDate]];
    
    return [task.completedTime compare:startDate] != NSOrderedAscending && [task.completedTime compare:endDate] != NSOrderedDescending;
}

- (BOOL) cleanTasks
{
	BOOL ret = NO;
	
	NSMutableArray *scDelTaskList = [[DBManager getInstance] getDeletedTasks];
	
	NSMutableArray *tdCleanList = [NSMutableArray arrayWithCapacity:50];
	
	NSDate *lastSyncTime = [[Settings getInstance] tdLastSyncTime];
	
	for (Task *task in scDelTaskList)
	{
		//printf("Checking Task to delete SC->TD: %s\n", [task.name UTF8String]);
		[task print];													
		
		//if (lastSyncTime == nil || (lastSyncTime != nil && [task.updateTime compare:lastSyncTime] == NSOrderedDescending))
        if (lastSyncTime == nil || (lastSyncTime != nil && [Common compareDate:task.updateTime withDate:lastSyncTime] == NSOrderedDescending))
		{
			if (![task.syncId isEqualToString:@""])
			{
				//printf("Delete Task SC->TD: ");
				[task print];													
				
				if ([self batchExecute:tdCleanList task:task command:SYNC_COMMAND_CLEAN])
				{
					ret = YES;
					tdCleanList = [NSMutableArray arrayWithCapacity:50];
				}				
			}
		}
	}
	
	if (tdCleanList.count > 0)
	{
		ret = YES;
		[self batchDeleteTask2TD:tdCleanList clean2SC:YES];
	}
	
	//printf("cleanTasks: %s\n",ret?"YES":"NO");
	
	return ret;
}

- (BOOL) cleanFolders
{
	BOOL ret = NO;
	
	NSMutableArray *scDelPlanList = [[DBManager getInstance] getDeletedPlans];
	
	for (Project *plan in scDelPlanList)
	{
		//printf("delete plan SC->TD: %s\n", [plan.name UTF8String]);
		
		//if (plan.syncId != nil && ![plan.syncId isEqualToString:@""])
		if (plan.tdId != nil && ![plan.tdId isEqualToString:@""])
		{
			[self deletePlan2TD:plan];
			
			ret = YES;
		}
		else if (!((plan.ekId != nil && [plan.ekId isEqualToString:@""]) 
                  || (plan.sdwId != nil && [plan.sdwId isEqualToString:@""])))
		{
			[plan cleanFromDatabase];
		}
			
	}
	
	//printf("cleanFolders: %s\n",ret?"YES":"NO");
	
	return ret;
}
/*

- (void) checkCleanTaskComplete
{
	//printf("checkSyncComplete - nFetch:%d\n", nFetch);
	
	if (nFetch <= 0)
	{
        nFetch = -1;
        
        [self fetchAccount];
	}
}
*/

/*
- (void) checkCleanFolderComplete
{
	//printf("checkSyncComplete - nFetch:%d\n", nFetch);
	
	if (nFetch <= 0)
	{
		nFetch = -1;
		
		[self fetchAccount];
	}		
}
*/

- (void) checkSyncComplete
{
	if (nFetch <= 0 && nPlanFetch <= 0)
	{
        /*
		if (![self cleanTasks])
		{
            nFetch = -1;
            
            [self fetchAccount];
		}
        */
        
        [self fetchAccount];
	}
	
}

- (void)initSync:(NSInteger)mode
{
	//printf("init sync with mode: %d\n", mode);
    NSLog(@"begin Toodledo sync - mode:%s",(mode == SYNC_AUTO_1WAY?"auto 1 way":(mode == SYNC_MANUAL_2WAY?"2 way manual":"2 way auto")));
    
	self.syncMode = mode;
	
	[self reset];
	
	Settings *settings = [Settings getInstance];
	
	if ([[settings tdEmail] isEqualToString:@""])
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_syncErrorText message:_accountInvalidText delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
		//[alert show];
        [alertView performSelector:@selector(show) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
        
		[alertView release];
		
        //[self notifySyncCompletion:[NSNumber numberWithInt:self.syncMode]];
        [self performSelectorOnMainThread:@selector(notifySyncCompletion:) withObject:[NSNumber numberWithInt:self.syncMode] waitUntilDone:NO];    
        
	}
	else
	{
		if (self.syncSection == nil)
		{
			[self fetchUserId];
		}
		else if ([self.syncSection checkTokenExpired])
		{
			[self fetchToken];
		}
		else 
		{
			//[self fetchFolder];
            if (![self cleanFolders])
            {
                [self fetchFolder];
            }
		}
		
	}
}

- (void) sync1way_TD2SD
{
	DBManager *dbm = [DBManager getInstance];
  
    NSMutableArray *scTaskList = [NSMutableArray arrayWithArray:[dbm getTasks2Sync]];	
	NSDictionary *scTaskDict = [self getSyncDictionaryForList:scTaskList];
    
	for (NSString *folderId in [self.tdTaskDict allKeys])
	{
        NSString *archivedId = [self.tdArchivedDict objectForKey:folderId];
        
        if (archivedId != nil)
        {
            continue;
        }
        
		NSMutableArray *tdTasks = [self.tdTaskDict objectForKey:folderId];
		
		if (tdTasks != nil && tdTasks.count > 0)
		{
			for (TDTask *tdTask in tdTasks)
			{                
				NSNumber *prjKeyNum = [self.tdSCMappingDict objectForKey:tdTask.folderId];
                
				Task *task = [scTaskDict objectForKey:tdTask.id];
                
				if (task != nil) //Task already synced in SC
				{
                    if (prjKeyNum == nil) //folder is changed in TD, not match SC calendar -> delete in SC
                    {
                        [scTaskList removeObject:task];
                        
                        //[task cleanFromDatabase:[dbm getDatabase]];
                        task.syncId = @"";
                        [task updateSyncIDIntoDB:[dbm getDatabase]];
                        
                        [task deleteFromDatabase:[dbm getDatabase]];
                    }
                    else 
                    {
                        [self updateSCTask:task withTDTask:tdTask];
                        
                        //printf("Update Task TD->SC: ");
                        [task print];
                        
                        [task updateIntoDB:[dbm getDatabase]];
                    }
                    
                } 
				else if (prjKeyNum != nil)
				{
                    task = [[Task alloc] init];
                    [self updateSCTask:task withTDTask:tdTask];
                    
                    [task insertIntoDB:[dbm getDatabase]];
                    [task release];
				}
                
            }
        }
    }
    
    [self checkSyncComplete];
}

- (void) sync
{
	DBManager *dbm = [DBManager getInstance];
    ProjectManager *pm = [ProjectManager getInstance];
	
	NSDate *lastSyncTime = [[Settings getInstance] tdLastSyncTime];
	
	//NSMutableArray *scTaskList = [NSMutableArray arrayWithArray:[dbm getAllTasks]];
    NSMutableArray *scTaskList = [NSMutableArray arrayWithArray:[dbm getTasks2Sync]];
	
	NSDictionary *scTaskDict = [self getSyncDictionaryForList:scTaskList];
    
    NSMutableDictionary *dupCategoryDict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    if (self.dupCategoryList.count > 0)
    {
        for (NSNumber *prjNum in self.dupCategoryList)
        {
            NSMutableDictionary *taskNameDict = [NSMutableDictionary dictionaryWithCapacity:50];
            
            [dupCategoryDict setObject:taskNameDict forKey:prjNum];
        }
        
        for (Task *task in scTaskList)
        {
            NSMutableDictionary *taskNameDict = [dupCategoryDict objectForKey:[NSNumber numberWithInt:task.project]];
            
            if (taskNameDict != nil)
            {
                [taskNameDict setObject:task forKey:task.name];
            }
        }
    }    
	
	//sync deleted Tasks
	for (TDTask *delTask in self.tdDeletedTaskList)
	{
		Task *task = [scTaskDict objectForKey:delTask.id];
		
		if (task != nil)
		{
			//printf("Delete Task TD->SC: ");
			[task print];
			
			[scTaskList removeObject:task];
            
            task.syncId = @"";
            [task updateSyncIDIntoDB:[dbm getDatabase]];
			
			//[task cleanFromDatabase:[dbm getDatabase]];
            [task deleteFromDatabase:[dbm getDatabase]];
		}
	}
	
	NSMutableArray *scDelTaskList = [NSMutableArray arrayWithArray:[dbm getDeletedTasks]];
	NSDictionary *scDelTaskDict = [self getSyncDictionaryForList:scDelTaskList];
	
	NSDictionary *scProjectDict = [ProjectManager getProjectDictById:pm.projectList];
	
	NSMutableArray *tdCleanList = [NSMutableArray arrayWithCapacity:50];
	NSMutableArray *tdDelList = [NSMutableArray arrayWithCapacity:50];
	NSMutableArray *tdAddList = [NSMutableArray arrayWithCapacity:50];
	NSMutableArray *tdUpdateList = [NSMutableArray arrayWithCapacity:50];
	
	//NSMutableArray *scImportList = [NSMutableArray arrayWithCapacity:50];
	
	for (NSString *folderId in [self.tdTaskDict allKeys])
	{
        NSString *archivedId = [self.tdArchivedDict objectForKey:folderId];
        
        if (archivedId != nil)
        {
            continue;
        }
        
		NSMutableArray *tdTasks = [self.tdTaskDict objectForKey:folderId];
		
		if (tdTasks != nil && tdTasks.count > 0)
		{
			for (TDTask *tdTask in tdTasks)
			{                
				NSNumber *prjKeyNum = [self.tdSCMappingDict objectForKey:tdTask.folderId];
                
				Task *task = [scTaskDict objectForKey:tdTask.id];
				
				if ([ProjectManager checkListStyle:task.project projectDict:scProjectDict])
				{
					task.hasNoDuration = YES;
				}
				
				if (task != nil) //Task already synced in SC
				{
					//if ([task.updateTime compare:tdTask.modifiedTime] == NSOrderedAscending) //update TD->SC
                    if ([Common compareDate:task.updateTime withDate:tdTask.modifiedTime] == NSOrderedAscending)
					{
						if (prjKeyNum == nil) //folder is changed in TD, not match SC calendar -> delete in SC
						{
							[scTaskList removeObject:task];
							
							//[task cleanFromDatabase:[dbm getDatabase]];
                            task.syncId = @"";
                            [task updateSyncIDIntoDB:[dbm getDatabase]];
                            
                            [task deleteFromDatabase:[dbm getDatabase]];
						}
						else 
						{
							//BOOL prjChange = (task.project != [prjKeyNum intValue]);
							
							[self updateSCTask:task withTDTask:tdTask];
							
							//printf("Update Task TD->SC: ");
							[task print];
                            
                            if (task.deadline == nil && task.alerts != nil && task.alerts.count > 0)
                            {
                                //remove alerts for non deadline tasks
                                [[AlertManager getInstance] removeAllAlertsForTask:task];
                            }
							
							[task updateIntoDB:[dbm getDatabase]];
						}
					}
					//else if ([task.updateTime compare:tdTask.modifiedTime] == NSOrderedDescending) //update SC->TD
                    if ([Common compareDate:task.updateTime withDate:tdTask.modifiedTime] == NSOrderedDescending)
					{
						if (prjKeyNum == nil) //calendar is changed in SC, not match TD folder -> delete in TD
						{
							//printf("Delete[1] Task SC->TD [Project change in SC]: ");
							[task print];
							
							if ([self batchExecute:tdDelList task:task command:SYNC_COMMAND_DELETE])
							{
								tdDelList = [NSMutableArray arrayWithCapacity:50];
							}
							
						}
						else 
						{
							//[self updateTask2TD:task];
							
							//printf("Update[1] Task SC->TD: ");
							[task print];
							if ([self batchExecute:tdUpdateList task:task command:SYNC_COMMAND_UPDATE])
							{
								tdUpdateList = [NSMutableArray arrayWithCapacity:50];
							}
							
						}
					}
					
					[scTaskList removeObject:task];
				}
				else if (prjKeyNum != nil)
				{
					Task *task = [scDelTaskDict objectForKey:tdTask.id];
					
					if (task == nil) // not in deleted list
					{
                        if (![self checkTaskCompletedInRange:tdTask])
                        {
                            continue;//don't sync completed Tasks outside 2 weeks
                        }
                        
                        BOOL taskCreation = YES;
                        
                        NSDictionary *taskNameDict = [dupCategoryDict objectForKey:prjKeyNum];
                        
                        if (taskNameDict != nil)
                        {
                            //sdw Task is in suspected duplicated category
                            
                            Task *task = [taskNameDict objectForKey:tdTask.title];
                            
                            if (task != nil)
                            {
                                BOOL duplicated = [Common compareDate:task.startTime withDate:tdTask.startTime] == NSOrderedSame &&
                                [Common compareDate:task.deadline withDate:tdTask.dueTime] == NSOrderedSame &&
                                task.duration == tdTask.length*60;
                                
                                if (duplicated)
                                {
                                    printf("Toodledo task %s is duplication suspected\n", [task.name UTF8String]);
                                    
                                    task.syncId = tdTask.id;
                                    [task updateSyncIDIntoDB:[dbm getDatabase]];
                                    
                                    [scTaskList removeObject:task];
                                    taskCreation = NO;
                                }
                            }
                            
                        }
                        
                        if (taskCreation)
                        {
                            task = [[Task alloc] init];
                            [self updateSCTask:task withTDTask:tdTask];
                            
                            [task insertIntoDB:[dbm getDatabase]];
                            [task release];                            
                        }
					}
				}
			}
		}
	}
	
	for (Task *task in scTaskList)
	{	
		NSString *folderId = [self.scTDMappingDict objectForKey:[NSNumber numberWithInt: task.project]];
		
		if (task.syncId == nil || [task.syncId isEqualToString:@""]) //new from SC
		{
			if (folderId != nil)
			{
				//printf("Add Task SC->TD: ");
				[task print];
				
				if ([self batchExecute:tdAddList task:task command:SYNC_COMMAND_ADD])
				{
					tdAddList = [NSMutableArray arrayWithCapacity:50];
				}
				
			}
		}
        else if (lastSyncTime == nil || (lastSyncTime != nil && [Common compareDate:task.updateTime withDate:lastSyncTime] == NSOrderedDescending))
		{
			if (folderId == nil) //calendar is changed in SC, not match TD folder -> delete in TD
			{
				//printf("Delete[2] Task SC->TD [Project change in SC]: ");
				[task print];	
				if ([self batchExecute:tdDelList task:task command:SYNC_COMMAND_DELETE])
				{
					tdDelList = [NSMutableArray arrayWithCapacity:50];
				}
			}
			else 
			{
				//printf("Update[2] Task SC->TD (last sync time: %s): ", [[lastSyncTime description] UTF8String]);
				[task print];	
				
				if ([self batchExecute:tdUpdateList task:task command:SYNC_COMMAND_UPDATE])
				{
					tdUpdateList = [NSMutableArray arrayWithCapacity:50];
				}
				
			}
		}		
	}
	
	for (Task *task in scDelTaskList)
	{
        if (lastSyncTime == nil || (lastSyncTime != nil && [Common compareDate:task.updateTime withDate:lastSyncTime] == NSOrderedDescending))
		{
			if (![task.syncId isEqualToString:@""])
			{
				//printf("Delete Task SC->TD: ");
				[task print];													
				
				if ([self batchExecute:tdCleanList task:task command:SYNC_COMMAND_CLEAN])
				{
					tdCleanList = [NSMutableArray arrayWithCapacity:50];
				}				
			}
		}
	}	
	
	if (tdAddList.count > 0)
	{
		[self batchAddTask2TD:tdAddList];
	}
	
	if (tdUpdateList.count > 0)
	{
		[self batchUpdateTask2TD:tdUpdateList];
	}
	
	if (tdDelList.count > 0)
	{
		[self batchDeleteTask2TD:tdDelList clean2SC:NO];
	}
	
	if (tdCleanList.count > 0)
	{
		[self batchDeleteTask2TD:tdCleanList clean2SC:YES];
	}
	
	[self checkSyncComplete];
}

#pragma mark Auto Sync
-(void)initBackgroundSync
{
	//printf("init sync background\n");
	
	@synchronized(self)
	{
		//if ([Common checkWiFiAvailable])
		{
			if (self.syncMode != -1)
			{
				//printf("other sync is in progress, wait for 2 way sync\n");
				sync2WayPending = YES;
			}
			else 
			{
				//printf("start 2 way syncing\n");
				
				sync2WayPending = NO;
				
				[[BusyController getInstance] setBusy:YES withCode:BUSY_TD_SYNC];
                
				//[self performSelectorInBackground:@selector(syncBackground:) withObject:[NSNumber numberWithInt:SYNC_MANUAL_2WAY]];
                
                dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
                
                dispatch_async(backgroundQueue, ^{
                    [self syncBackground:[NSNumber numberWithInt:SYNC_MANUAL_2WAY]];
                });
                
			}			
		}
	}
}

-(void)initBackground1WaySync
{
	//printf("init sync 1 way background\n");
	@synchronized(self)
	{
		//if ([Common checkWiFiAvailable])
		{
			if (self.syncMode != -1)
			{
				//printf("other sync is in progress, wait for 1 way sync\n");
				sync1WayPending = sync2WayPending?NO:YES;
			}
			else 
			{
				//printf("start 1 way syncing\n");
				
				sync1WayPending = NO;
				
				[[BusyController getInstance] setBusy:YES withCode:BUSY_TD_SYNC];
				
                //[self performSelectorInBackground:@selector(syncBackground:) withObject:[NSNumber numberWithInt:SYNC_AUTO_1WAY]];
                dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
                
                dispatch_async(backgroundQueue, ^{
                    [self syncBackground:[NSNumber numberWithInt:SYNC_AUTO_1WAY]];
                });
                
			}			
		}		
	}
}

-(void)initBackgroundAuto2WaySync
{
	@synchronized(self)
	{
		//if ([Common checkWiFiAvailable])
		{
			if (self.syncMode != -1)
			{
				//printf("other sync is in progress, wait for 2 way sync\n");
				sync2WayPending = YES;
			}
			else 
			{
				//printf("start 2 way syncing\n");
				
				sync2WayPending = NO;
				
				[[BusyController getInstance] setBusy:YES withCode:BUSY_TD_SYNC];
				
                //[self performSelectorInBackground:@selector(syncBackground:) withObject:[NSNumber numberWithInt:SYNC_AUTO_2WAY]];
                
                dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
                
                dispatch_async(backgroundQueue, ^{
                    [self syncBackground:[NSNumber numberWithInt:SYNC_AUTO_2WAY]];
                });
			}			
		}
	}	
}

- (void) initBackground1WayTD2SDSync
{
    Settings *settings = [Settings getInstance];
    
    [settings resetToodledoSync];
    
    [[BusyController getInstance] setBusy:YES withCode:BUSY_TD_SYNC];
    
    //[self performSelectorInBackground:@selector(syncBackground:) withObject:[NSNumber numberWithInt:SYNC_MANUAL_1WAY_TD2SD]];
    
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    
    dispatch_async(backgroundQueue, ^{
        [self syncBackground:[NSNumber numberWithInt:SYNC_MANUAL_1WAY_TD2SD]];
    });
    
}

-(void)syncBackground:(NSNumber *)mode
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	[self initSync:[mode intValue]];

	[pool release];
}

- (void) sync1way
{
	@synchronized(self)
	{
		Settings *settings = [Settings getInstance];
		DBManager *dbm = [DBManager getInstance];
		
		NSDate *tdLastSyncTime = settings.tdLastSyncTime;
		
		NSMutableArray *taskList = [dbm getModifiedTasks2Sync:tdLastSyncTime];
		
		NSMutableArray *tdCleanList = [NSMutableArray arrayWithCapacity:50];
		NSMutableArray *tdDelList = [NSMutableArray arrayWithCapacity:50];
		NSMutableArray *tdAddList = [NSMutableArray arrayWithCapacity:50];
		NSMutableArray *tdUpdateList = [NSMutableArray arrayWithCapacity:50];
		
		for (Task *task in taskList)
		{
			NSString *folderId = [self.scTDMappingDict objectForKey:[NSNumber numberWithInt: task.project]];
			
			if (task.syncId == nil || [task.syncId isEqualToString:@""]) //new from SC
			{
				if (folderId != nil)
				{
					//printf("Add Task SC->TD: ");
					[task print];
					
					if ([self batchExecute:tdAddList task:task command:SYNC_COMMAND_ADD])
					{
						tdAddList = [NSMutableArray arrayWithCapacity:50];
					}
				}
			}
			else 
			{
				if (task.status == TASK_STATUS_DELETED)
				{
					if ([self batchExecute:tdCleanList task:task command:SYNC_COMMAND_CLEAN])
					{
						tdCleanList = [NSMutableArray arrayWithCapacity:50];
					}				
				}
				else 
				{
					if (folderId == nil) //calendar is changed in SC, not match TD folder -> delete in TD
					{
						//printf("Delete Task SC->TD [Project change in SC]: ");
						[task print];	
						if ([self batchExecute:tdDelList task:task command:SYNC_COMMAND_DELETE])
						{
							tdDelList = [NSMutableArray arrayWithCapacity:50];
						}
					}
					else 
					{
						//printf("Update[2] Task SC->TD (last sync time: %s): ", [[tdLastSyncTime description] UTF8String]);
						[task print];	
						
						if ([self batchExecute:tdUpdateList task:task command:SYNC_COMMAND_UPDATE])
						{
							tdUpdateList = [NSMutableArray arrayWithCapacity:50];
						}
						
					}				
				}
			}
		}
		
		if (tdAddList.count > 0)
		{
			[self batchAddTask2TD:tdAddList];
		}
		
		if (tdUpdateList.count > 0)
		{
			[self batchUpdateTask2TD:tdUpdateList];
		}
		
		if (tdDelList.count > 0)
		{
			[self batchDeleteTask2TD:tdDelList clean2SC:NO];
		}
		
		if (tdCleanList.count > 0)
		{
			[self batchDeleteTask2TD:tdCleanList clean2SC:YES];
		}
		
		[self checkSyncComplete];		
	}
}

#pragma mark Public methods
+ (NSString *) convertString:(NSString *)str
{
	NSString *ret = [str stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
	ret = [ret stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    ret = [ret stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    ret = [ret stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
	ret = [ret stringByReplacingOccurrencesOfString:@"\t" withString:@"\\t"];
	
	return ret;
}

+ (NSString *) encodeString:(NSString *)str
{
	/*
	 str = [str stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
	 str = [str stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
	 str = [str stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
	 str = [str stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
	 str = [str stringByReplacingOccurrencesOfString:@";" withString:@"%3B"];
	 str = [str stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
	 str = [str stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
	 str = [str stringByReplacingOccurrencesOfString:@"@" withString:@"%40"];
	 str = [str stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
	 str = [str stringByReplacingOccurrencesOfString:@"\t" withString:@"%09"];
	 str = [str stringByReplacingOccurrencesOfString:@"#" withString:@"%23"];
	 str = [str stringByReplacingOccurrencesOfString:@"<" withString:@"%3C"];
	 str = [str stringByReplacingOccurrencesOfString:@">" withString:@"%3E"];
	 str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@"%22"];
	 str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@"%0A"];
	 */
	
	str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	str = [str stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];

	return str;
}

+(id)getInstance
{
	if (_tdSyncSingleton == nil)
	{
		_tdSyncSingleton = [[TDSync alloc] init];
	}
	
	return _tdSyncSingleton;
}

+(void)free
{
	if (_tdSyncSingleton != nil)
	{
		[_tdSyncSingleton release];
		
		_tdSyncSingleton = nil;
	}	
}

@end
