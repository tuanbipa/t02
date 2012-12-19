//
//  ProjectManager.m
//  SmartPlan
//
//  Created by Huy Le on 11/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ProjectManager.h"
#import "Common.h"
#import "Project.h"
#import "Task.h"
#import "Settings.h"

#import "DBManager.h"
#import "TaskManager.h"
#import "TagDictionary.h"

#import "ProjectIconView.h"

ProjectManager *_projectManagerSingleton = nil;

@implementation ProjectManager

@synthesize projectList;

@synthesize eventIconList;
@synthesize adeIconList;
@synthesize taskIconList;
@synthesize noteIconList;

/*
@synthesize squareIconList;
@synthesize roundedSquareIconList;
@synthesize circleIconList;
@synthesize rectangleIconList;
@synthesize listIconList;
@synthesize taskIconList;
*/

@synthesize cascadeDictionary;

- (id) init
{
	if (self = [super init])
	{
		self.cascadeDictionary = [NSMutableDictionary dictionaryWithCapacity:5];
	}
	
	return self;
}

-(void)makeIcon:(Project *)prj
{
	ProjectIconView *iconView = [[ProjectIconView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
	iconView.colorId = prj.colorId;
	iconView.type = ICON_EVENT;
	
	UIImage *icon = [Common takeSnapshot:iconView size:CGSizeMake(16, 16)];
	
	[self.eventIconList setObject:icon forKey:[NSNumber numberWithInt:prj.primaryKey]];

	iconView.type = ICON_SQUARE;
	[iconView setNeedsDisplay];
	
	icon = [Common takeSnapshot:iconView size:CGSizeMake(14, 14)];
	
	[self.adeIconList setObject:icon forKey:[NSNumber numberWithInt:prj.primaryKey]];
	
	iconView.type = ICON_NOTE;
	[iconView setNeedsDisplay];
	
	icon = [Common takeSnapshot:iconView size:CGSizeMake(16, 16)];
	
	[self.noteIconList setObject:icon forKey:[NSNumber numberWithInt:prj.primaryKey]];

	iconView.type = ICON_TASK;
    iconView.frame = CGRectMake(0, 0, 20, 20);
	[iconView setNeedsDisplay];
	
	icon = [Common takeSnapshot:iconView size:CGSizeMake(20, 20)];
	
	[self.taskIconList setObject:icon forKey:[NSNumber numberWithInt:prj.primaryKey]];
	
	[iconView release];	
}

- (UIImage *) getEventIcon:(NSInteger)key
{
	return [self.eventIconList objectForKey:[NSNumber numberWithInt:key]];
}

- (UIImage *) getADEIcon:(NSInteger)key
{
	return [self.adeIconList objectForKey:[NSNumber numberWithInt:key]];
}

- (UIImage *) getNoteIcon:(NSInteger)key
{
	return [self.noteIconList objectForKey:[NSNumber numberWithInt:key]];
}

- (UIImage *) getTaskIcon:(NSInteger)key
{
	return [self.taskIconList objectForKey:[NSNumber numberWithInt:key]];
}

#pragma mark Sync
- (void) resetToodledoIds
{
    for (Project *prj in self.projectList)
    {
        prj.tdId = @"";
    }
}

- (void) resetSDWIds
{
    for (Project *prj in self.projectList)
    {
        prj.sdwId = @"";
    }
}

#pragma mark Cascade Management
- (NSMutableArray *) getCascadeList
{	
	NSMutableArray *ret = [NSMutableArray arrayWithCapacity:self.projectList.count + 10]; 
	
	for (Project *prj in self.projectList)
	{
		if (prj.status != PROJECT_STATUS_INVISIBLE) //visible project
		{
			[ret addObject:prj];
			
			if (prj.isExpanded)
			{
				NSMutableArray *activeTasks = [[DBManager getInstance] getActiveTasksForPlan:prj.primaryKey];
				
				[Common sortList:activeTasks byKey:@"mergedSeqNo" ascending:YES];
				
				[self.cascadeDictionary setObject:activeTasks forKey:[NSNumber numberWithInt:prj.primaryKey]];
				
				[ret addObjectsFromArray:activeTasks];
			}			
		}
	}
	
	return ret;
}

- (NSMutableArray *) sortAndGetCascadeList
{	
	[self sortProjectList];
	
	NSMutableArray *ret = [NSMutableArray arrayWithCapacity:self.projectList.count + 10]; 
	
	for (Project *prj in self.projectList)
	{
		[ret addObject:prj];
		
		if (prj.isExpanded)
		{
			NSMutableArray *activeTasks = [self.cascadeDictionary objectForKey:[NSNumber numberWithInt:prj.primaryKey]];

			[ret addObjectsFromArray:activeTasks];
		}
	}
	
	return ret;
}

- (void) sortCascadeTasksForProject:(NSInteger)prjKey
{
	NSMutableArray *activeTasks = [self.cascadeDictionary objectForKey:[NSNumber numberWithInt:prjKey]];

	if (activeTasks != nil && activeTasks.count > 0)
	{
		[Common sortList:activeTasks byKey:@"sequenceNo" ascending:YES];
	}
}

#pragma mark Calendar Management
- (void) initProjectList:(NSMutableArray *)list
{
	self.projectList = list;
	
    /*
	NSSortDescriptor *seqNo_descriptor = [[NSSortDescriptor alloc] initWithKey:@"sequenceNo"  ascending: YES];
	
	NSArray *sortDescriptors = [NSArray arrayWithObject:seqNo_descriptor];
	
	[self.projectList sortUsingDescriptors:sortDescriptors];
	
	[seqNo_descriptor release];	
    */
	
	self.eventIconList = [NSMutableDictionary dictionaryWithCapacity:list.count];
	self.adeIconList = [NSMutableDictionary dictionaryWithCapacity:list.count];
	self.taskIconList = [NSMutableDictionary dictionaryWithCapacity:list.count];
	self.noteIconList = [NSMutableDictionary dictionaryWithCapacity:list.count];
	
	for (Project *prj in self.projectList)
	{
		[self makeIcon:prj];
	}
}

-(void) addProject:(Project *)project
{
	//project.sequenceNo = self.projectList.count;
	project.sequenceNo = [[DBManager getInstance] getPlanMaxSeqNo] + 1;
	
    //change in SD: don't create tag with the same name as category

	//project.tag = [TagDictionary addTagToList:project.tag tag:project.name];	
	//[[TagDictionary getInstance] makePreset:project.name preset:YES];
	
	[project insertIntoDB:[[DBManager getInstance] getDatabase]];
	
	[self.projectList addObject:project];
	
	[self makeIcon:project];
}

-(void) copyProject:(Project *)project
{
	DBManager *dbm = [DBManager getInstance];
	Project *copyProject = [project copy];
	
	copyProject.name = [NSString stringWithFormat:@"%@ (copy)", project.name];
	
	copyProject.sequenceNo = [dbm getPlanMaxSeqNo] + 1;
	copyProject.colorId = (self.projectList.count < PROJECT_COLOR_NUM?self.projectList.count:0);
	copyProject.tdId = @"";
    copyProject.ekId = @"";
	
	[copyProject insertIntoDB:[dbm getDatabase]];
	
	[self.projectList addObject:copyProject];
	
	[self makeIcon:copyProject];
	
	NSMutableArray *taskList = [dbm getTasksForPlan:project.primaryKey];
	
	NSInteger taskPlacement = [[Settings getInstance] newTaskPlacement];
	
	for (int i=0; i<taskList.count; i++)
	{
		Task *task = [taskList objectAtIndex:i];
		
		task.primaryKey = -1;
		task.project = copyProject.primaryKey;		
		
		//task.sequenceNo = i;
		
		if (taskPlacement == 0) //on top
		{
			task.sequenceNo = [dbm getTaskMinSortSeqNo] - 1;
		}
		else 
		{
			task.sequenceNo = [dbm getTaskMaxSortSeqNo] + 1;
		}		
		
		task.mergedSeqNo = -1;
		task.syncId = @"";

		[task insertIntoDB:[dbm getDatabase]];
	}
	
	TaskManager *tm = [TaskManager getInstance];
	
	//[tm sortTasks:taskList];
	
	[tm initSmartListData];
}

-(void)deleteProject:(Project *)prj cleanFromDB:(BOOL)cleanFromDB
{
	[self.cascadeDictionary removeObjectForKey:[NSNumber numberWithInt:prj.primaryKey]];
	
	if (cleanFromDB)
	{
		[prj cleanFromDatabase];		
	}
	else 
	{
		[prj deleteFromDatabase];		
	}
	
	[self.projectList removeObject:prj];
}

- (void) changeOrder:(Project *)srcPrj destPrj:(Project *)destPrj
{
	DBManager *dbm = [DBManager getInstance];
    
    NSDictionary *prjDict = [ProjectManager getProjectDictById:self.projectList];
	
    srcPrj.sequenceNo = destPrj.sequenceNo;
    
    int seqNo = destPrj.sequenceNo + 1;
    
	NSMutableArray *list = [dbm getProjects];
    
    BOOL seqNoIncrease = NO;
    
    for (Project *prj in list)
    {
        if (prj.primaryKey == srcPrj.primaryKey)
        {
            continue;
        }
        
        if (prj.primaryKey == destPrj.primaryKey)
        {
            seqNoIncrease = YES;
        }
        
        if (seqNoIncrease)
        {
            prj.sequenceNo = seqNo ++;
            [prj updateSeqNoIntoDB:[dbm getDatabase]];
            
            Project *prjUpdate = [prjDict objectForKey:[NSNumber numberWithInt:prj.primaryKey]];
            
            if (prjUpdate != nil)
            {
                prjUpdate.sequenceNo = prj.sequenceNo;
            }
        }
        
    }
    
    [srcPrj updateSeqNoIntoDB:[dbm getDatabase]];
    
    Project *prjUpdate = [prjDict objectForKey:[NSNumber numberWithInt:srcPrj.primaryKey]];
    
    if (prjUpdate != nil)
    {
        prjUpdate.sequenceNo = srcPrj.sequenceNo;
    }
    
    [self sortProjectList];
}

-(void)changeProjectType:(Project *)prj type:(NSInteger)type
{
	if (prj.type != type)
	{
		DBManager *dbm = [DBManager getInstance];
		Settings *settings = [Settings getInstance];
		
		prj.type = type;
		[prj updateTypeIntoDB:[dbm getDatabase]];

		NSMutableArray *tasks = [dbm getTasksForPlan:prj.primaryKey];
		
		NSInteger placement = [[Settings getInstance] newTaskPlacement];
		NSInteger seqNo = (placement == 0?[dbm getTaskMinSortSeqNo]:[dbm getTaskMaxSortSeqNo]);
		
		for (Task *task in tasks)
		{
			if (type == TYPE_LIST)
			{
				task.duration = 0;
				task.type = TYPE_SHOPPING_ITEM;
			}
			else 
			{
				task.duration = settings.taskDuration;
				task.type = TYPE_TASK;
				task.sequenceNo = (placement == 0?--seqNo:++seqNo);
			}

			[task updateIntoDB:[dbm getDatabase]];
		}		
		
		/*
		if (type == TYPE_LIST)
		{
			for (Task *task in tasks)
			{
				task.mergedSeqNo = -1;
				task.duration = 0;
				
				[task updateIntoDB:[dbm getDatabase]];
			}
		}
		else 
		{
			for (Task *task in tasks)
			{
				task.duration = [[Settings getInstance] taskDuration];
				[task updateDurationIntoDB:[dbm getDatabase]];
			}
			
			[tm sortTasks:tasks];			
		}
		*/
		[[TaskManager getInstance] initSmartListData];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];
	}
}

- (void) resolveTagChange:(Project *)prj tag:(NSString *)tag
{
	NSDictionary *dict = [TagDictionary getTagDict:prj.tag];
	
	NSMutableArray *newTags = [NSMutableArray arrayWithCapacity:3];
	NSMutableArray *delTags = [NSMutableArray arrayWithCapacity:3];
	
	if (![tag isEqualToString:@""])
	{
		NSArray *parts = [tag componentsSeparatedByString:@","];
		
		for (NSString *part in parts)
		{
			NSString *tag = [dict objectForKey:part];
			
			if (tag == nil) // new Tag
			{
				[newTags addObject:part];
			}
		}
		
		if (![prj.tag isEqualToString:@""])
		{
			dict = [TagDictionary getTagDict:tag];
			
			parts = [prj.tag componentsSeparatedByString:@","];
			
			for (NSString *part in parts)
			{
				NSString *tag = [dict objectForKey:part];
				
				if (tag == nil) // removed Tag
				{
					[delTags addObject:part];
				}
			}
		}		
	}
	else if (![prj.tag isEqualToString:@""])
	{
		delTags = [NSMutableArray arrayWithArray:[prj.tag componentsSeparatedByString:@","]];
	}
	
	DBManager *dbm = [DBManager getInstance];

	NSMutableArray *tasks = [dbm getTasksForPlan:prj.primaryKey];
	
	for (Task *task in tasks)
	{
		NSMutableDictionary *tagDict = [NSMutableDictionary dictionaryWithDictionary:[TagDictionary getTagDict:task.tag]];
		
		for (NSString *tag in newTags)
		{
			[tagDict setObject:tag forKey:tag];
		}
		
		for (NSString *tag in delTags)
		{
			[tagDict removeObjectForKey:tag];
		}
		
		task.tag = [TagDictionary createTagByDict:tagDict];
		
		[task updateTagIntoDB:[dbm getDatabase]];
	}	
}

-(void)changeProjectName:(Project *)prj name:(NSString *)name
{
	DBManager *dbm = [DBManager getInstance];
	
	NSMutableDictionary *tagDict = [NSMutableDictionary dictionaryWithDictionary:[TagDictionary getTagDict:prj.tag]];
	
	[tagDict removeObjectForKey:prj.name];
	
	[tagDict setObject:name forKey:name];
	
	prj.tag = [TagDictionary createTagByDict:tagDict];
	
	[prj updateTagIntoDB:[dbm getDatabase]];
	
	NSMutableArray *tasks = [dbm getTasksForPlan:prj.primaryKey];
	
	for (Task *task in tasks)
	{
		tagDict = [NSMutableDictionary dictionaryWithDictionary:[TagDictionary getTagDict:task.tag]];
		
		[tagDict removeObjectForKey:prj.name];
		
		[tagDict setObject:name forKey:name];
		
		task.tag = [TagDictionary createTagByDict:tagDict];
		
		[task updateTagIntoDB:[dbm getDatabase]];
	}
	
	TagDictionary *tagMgr = [TagDictionary getInstance];
	
	[tagMgr deleteTag:prj.name];
	[tagMgr addTag:name];
	[tagMgr makePreset:name preset:YES];
	
	prj.name = name;
	
	[prj updateNameIntoDB:[dbm getDatabase]];
	
}

- (BOOL) checkListStyle:(NSInteger)prjKey
{
	for (Project *prj in self.projectList)
	{
		if (prj.primaryKey == prjKey && prj.type == TYPE_LIST)
		{
			return YES;
		}
	}
	
	return NO;	
}

- (BOOL) checkTransparent:(NSInteger)prjKey
{
	for (Project *prj in self.projectList)
	{
		//if (prj.primaryKey == prjKey && prj.status == PROJECT_STATUS_TRANSPARENT)
        if (prj.primaryKey == prjKey && prj.isTransparent)
		{
			return YES;
		}
	}
	
	return NO;	
}

- (NSMutableArray *) getTransparentProjectList
{
	NSMutableArray *ret = [NSMutableArray arrayWithCapacity:10];
	
	for (Project *project in self.projectList)
	{
		//if (project.status == PROJECT_STATUS_TRANSPARENT)
        if (project.isTransparent)
		{
			[ret addObject:project];
		}
	}
	
	return ret;
}

- (NSMutableArray *) getVisibleProjectList
{
	NSMutableArray *ret = [NSMutableArray arrayWithCapacity:10];
	
	for (Project *project in self.projectList)
	{
		if (project.status != PROJECT_STATUS_INVISIBLE)
		{
			[ret addObject:project];
		}
	}
	
	return ret;
}

- (NSMutableDictionary *) getInvisibleProjectDict
{
	NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity:5];
	
	for (Project *project in self.projectList)
	{
		if (project.status == PROJECT_STATUS_INVISIBLE)
		{
			[ret setObject:project forKey:[NSNumber numberWithInt:project.primaryKey]];
		}
	}
	
	return ret;
}

- (NSMutableDictionary *) getVisibleProjectDict
{
	NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity:5];
	
	for (Project *project in self.projectList)
	{
		if (project.status != PROJECT_STATUS_INVISIBLE)
		{
			[ret setObject:project forKey:[NSNumber numberWithInt:project.primaryKey]];
		}
	}
	
	return ret;
}

- (NSString *) stringOfInvisibleProjectList
{
    NSString *ret = nil;
    
	for (Project *project in self.projectList)
	{
		if (project.status == PROJECT_STATUS_INVISIBLE)
		{
            //ret = (ret == nil? project.name:[ret stringByAppendingFormat:@",%@", project.name]);
            ret = (ret == nil? [NSString stringWithFormat:@"%d", project.primaryKey]:[ret stringByAppendingFormat:@",%d", project.primaryKey]);
		}
	}
        
    return ret;
}

- (NSArray *) getProjectList
{
	return self.projectList;
}

- (Project *) getProjectAtIndex:(NSInteger)index
{
	return [self.projectList objectAtIndex:index];
}

- (Project *) getProjectByKey:(NSInteger)key
{
	for (Project *prj in self.projectList)
	{
		if (prj.primaryKey == key)
		{
			return prj;
		}
	}
	
	return nil;
}

- (NSString *) getProjectNameByKey:(NSInteger)key
{
	for (Project *prj in self.projectList)
	{
		if (prj.primaryKey == key)
		{
			return prj.name;
		}
	}
	
	return nil;
}

- (NSString *) getProjectTagByKey:(NSInteger)key
{
	for (Project *prj in self.projectList)
	{
		if (prj.primaryKey == key)
		{
			return prj.tag;
		}
	}
	
	return nil;
}

- (NSInteger) getProjectColorID:(NSInteger) key
{
	for (Project *prj in self.projectList)
	{
		if (prj.primaryKey == key)
		{
			return prj.colorId;
		}
	}
	
	return 0;
}

- (UIColor *) getProjectColor0:(NSInteger) key
{
	for (Project *prj in self.projectList)
	{
		if (prj.primaryKey == key)
		{
			return [Common getColorByID:prj.colorId colorIndex:0];
		}
	}
	
	return [Common getColorByID:10 colorIndex:0];
}

- (UIColor *) getProjectColor1:(NSInteger) key
{
	for (Project *prj in self.projectList)
	{
		if (prj.primaryKey == key)
		{
			return [Common getColorByID:prj.colorId colorIndex:1];
		}
	}
	
	return [Common getColorByID:10 colorIndex:1];
}

- (UIColor *) getProjectColor2:(NSInteger) key
{
	for (Project *prj in self.projectList)
	{
		if (prj.primaryKey == key)
		{
			return [Common getColorByID:prj.colorId colorIndex:2];
		}
	}
	
	return [Common getColorByID:10 colorIndex:2];
}
- (void) sortProjectList
{
	[Common sortList:self.projectList byKey:@"sequenceNo" ascending:YES];	
}

- (NSString *) getMappingList: (BOOL)forTask
{
	NSString *ret = @"";
	
	for (Project *prj in self.projectList)
	{
		NSString *name = nil;
		if (![prj.tdId isEqualToString:@""] && forTask)
		{
			name = prj.tdId;
		}
		
		if (![prj.ekId isEqualToString:@""] && !forTask)
		{
			name = prj.ekId;
		}

		if (name != nil)
		{
			if ([ret isEqualToString:@""])
			{
				ret = name;
			}
			else 
			{
				ret = [NSString stringWithFormat:@"%@, %@", ret, name];
			}
		}
	}	
	
	return ret;
}

- (NSInteger) getSuggestColorId
{
	int cnt = self.projectList.count;
		
	return cnt%21;
}

- (BOOL) checkExistingProjectName:(NSString *)name excludeProject:(NSInteger)excludeProject;
{
	for (Project *prj in self.projectList)
	{
		if (prj.primaryKey != excludeProject && [[prj.name uppercaseString] isEqualToString:[name uppercaseString]])
		{
			return YES;
		}
	}
	
	return NO;
}

- (void) print:(NSArray *)prjList
{
	//int c = 0;
	//for (Project *prj in prjList)
	//{
		//////printf("%d. Project '%s' - seqNo:%d, start:%s, end:%s\n", c++, [prj.name UTF8String], prj.sequenceNo, [[prj.startTime description] UTF8String], [[prj.endTime description] UTF8String]);
	//}
	
	//////printf("\n");
}

- (void)dealloc 
{
	self.projectList = nil;
	self.eventIconList = nil;
	self.adeIconList = nil;
	self.taskIconList = nil;
    self.noteIconList = nil;
	
	self.cascadeDictionary = nil;
	
	[super dealloc];
}

+(id)getInstance
{
	if (_projectManagerSingleton == nil)
	{
		_projectManagerSingleton = [[ProjectManager alloc] init];
	}
	
	return _projectManagerSingleton;
}

+(void)startup
{
	ProjectManager *pm = [ProjectManager getInstance];
	
	[pm initProjectList:[[DBManager getInstance] getProjects]]; 
	
}

+ (BOOL) checkListStyle:(NSInteger) prjKey projectDict:(NSMutableDictionary *)projectDict
{
	Project *prj = [projectDict objectForKey:[NSNumber numberWithInt:prjKey]];
	
	if (prj != nil)
	{
		return prj.type == TYPE_LIST;
	}
	
	return NO;
}

+ (NSDictionary *) getProjectDictById:(NSArray *)projectList
{
	//NSMutableArray *prjList = [[ProjectManager getInstance] projectList];
	
	NSMutableArray *mappingList = [NSMutableArray arrayWithCapacity:projectList.count];
	
	for (Project *project in projectList)
	{
		[mappingList addObject:[NSNumber numberWithInt:project.primaryKey]];
	}
	
	return [NSDictionary dictionaryWithObjects:projectList forKeys:mappingList];
}


+ (NSDictionary *) getProjectDictionaryByName
{
	NSMutableArray *prjList = [[ProjectManager getInstance] projectList];
	
	NSMutableArray *keys = [NSMutableArray arrayWithCapacity:prjList.count];
	
	for (Project *prj in prjList)
	{
		[keys addObject:prj.name];
	}
	
	return [NSDictionary dictionaryWithObjects:prjList forKeys:keys];	
}

+ (NSDictionary *) getProjectDictByName:(NSArray *)projectList
{
	NSMutableArray *mappingList = [NSMutableArray arrayWithCapacity:projectList.count];
	
	for (Project *project in projectList)
	{
		NSString *name = project.name;
		
        /*
		if ([name length] > 32)
		{
			name = [name substringToIndex:32];
		}
		*/
        
		[mappingList addObject:[name uppercaseString]];
	}
	
	return [NSDictionary dictionaryWithObjects:projectList forKeys:mappingList];
}

+ (NSDictionary *) getProjectDictBySDWID:(NSArray *)projectList
{
	NSMutableArray *mappingList = [NSMutableArray arrayWithCapacity:projectList.count];
	
	for (Project *project in projectList)
	{
		[mappingList addObject:project.sdwId];
	}
	
	return [NSDictionary dictionaryWithObjects:projectList forKeys:mappingList];
}

+ (NSDictionary *) getProjectDictByTaskSyncID:(NSArray *)projectList
{
	NSMutableArray *mappingList = [NSMutableArray arrayWithCapacity:projectList.count];
	
	for (Project *project in projectList)
	{
		//[mappingList addObject:project.syncId];
		[mappingList addObject:project.tdId];
	}
	
	return [NSDictionary dictionaryWithObjects:projectList forKeys:mappingList];
}

+ (NSDictionary *) getProjectDictByEventSyncID:(NSArray *)projectList
{
	NSMutableArray *mappingList = [NSMutableArray arrayWithCapacity:projectList.count];
	
	for (Project *project in projectList)
	{
		[mappingList addObject:project.ekId];
	}
	
	return [NSDictionary dictionaryWithObjects:projectList forKeys:mappingList];
}


+(void)free
{
	if (_projectManagerSingleton != nil)
	{
		[_projectManagerSingleton release];
	}
}


@end
