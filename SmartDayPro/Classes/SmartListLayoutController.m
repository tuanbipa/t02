//
//  SmartListLayoutController.m
//  SmartCal
//
//  Created by Trung Nguyen on 5/21/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "SmartListLayoutController.h"


#import "Common.h"
#import "Settings.h"
#import "Task.h"
#import "TaskView.h"
#import "TodayLine.h"
#import "DayHeaderView.h"

#import "TaskManager.h"

#import "BusyController.h"

#import "AbstractSDViewController.h"
#import "SmartListViewController.h"

//#import "SCTabBarController.h"

//extern SCTabBarController *_tabBarCtrler;

extern AbstractSDViewController *_abstractViewCtrler;

@implementation SmartListLayoutController

@synthesize layoutInProgress;
@synthesize taskList;
//@synthesize layoutInPlanner;

- (id) init
{
    if (self = [super init])
    {
        self.layoutInProgress = NO;
        
        layoutCond = [[NSCondition alloc] init];
    }
    
    return self;
}

- (void) setLayoutInProgress:(BOOL)inProgress
{
	[layoutCond lock];
	
	layoutInProgress = inProgress;
	
	if (!inProgress)
	{
		[layoutCond signal];
	}
	
	[layoutCond unlock];
}

- (void) wait4LayoutComplete
{
	[layoutCond lock];
	
	while (self.layoutInProgress)
	{
        //printf("wait for layout complete\n");
		[layoutCond wait];
	}
    
	[layoutCond unlock];
}

- (void) layout4NewTask:(Task *)task
{
	TaskView *taskView = [self layoutObject:task reusableView:nil];
	
	taskView.movableController = self.movableController;
	
	NSInteger taskPlacement = [[Settings getInstance] newTaskPlacement];
	
	if (taskPlacement == 0) //on top
	{
		if (self.viewContainer.subviews.count == 0)
		{
			[self.viewContainer addSubview:taskView];
		}
		else 
		{
			[self.viewContainer insertSubview:taskView atIndex:0];
		}
		
		CGPoint origin = CGPointMake(0, 5); 
		
		for (TaskView *tmp in self.viewContainer.subviews)
		{
			CGRect frm = tmp.frame;
			
			frm.origin = origin;
			
			tmp.frame = frm;
			
			origin.y += frm.size.height + TASK_PAD_HEIGHT;
			
			lastView = tmp;
		}
	}
	else 
	{
		[self.viewContainer addSubview:taskView];
		
		lastView = taskView;
	}
}

- (BOOL) layoutTodayLines:(NSMutableArray *)todayLines taskView:(TaskView *)taskView forActive:(BOOL)forActive
{
	BOOL ret = NO;
	
	//Task *lastTask = (lastView != nil?(Task *)lastView.tag:nil);
    Task *lastTask = (lastView != nil?((TaskView *)lastView).task:nil);
	
	//Task *task = (Task *)taskView.tag;
    Task *task = taskView.task;
    
	CGRect frm = (lastView == nil?CGRectMake(0, 40, 0, 0):lastView.frame);
	
	NSInteger nextY = frm.origin.y + frm.size.height + TASK_PAD_HEIGHT;
        
    BOOL doneLayout = ([[TaskManager getInstance] taskTypeFilter] == TASK_FILTER_DONE);
    
    //printf("lastTask %s - completed: %s - smart:%s\n", [lastTask.name UTF8String], [[lastTask.completionTime description] UTF8String], [[lastTask.smartTime description] UTF8String]);
    //printf("task %s - completed: %s - smart:%s\n", [task.name UTF8String], [[task.completionTime description] UTF8String], [[task.smartTime description] UTF8String]);

    /*
    if (!doneLayout && (lastTask.smartTime == nil || task.smartTime == nil))
    {
        printf("task %s has smart time nil\n", lastTask.smartTime == nil?[lastTask.name UTF8String]:[task.name UTF8String]);
    }*/
    
    NSComparisonResult res = (lastTask == nil? NSOrderedAscending:(doneLayout?[Common compareDateNoTime:lastTask.completionTime withDate:task.completionTime]:(lastTask.smartTime == nil || task.smartTime == nil? NSOrderedAscending:[Common compareDateNoTime:lastTask.smartTime withDate:task.smartTime])));
    
	if (res != NSOrderedSame)
	{
		frm.origin.y = nextY;
		frm.size.height = 22;
        frm.size.width = taskView.frame.size.width;
		
		////printf("add today line x:%f, y:%f, date:%s\n", frm.origin.x, frm.origin.y, [[task.smartTime description] UTF8String]);			
		
		DayHeaderView *line = [[DayHeaderView alloc] initWithFrame:frm];
		line.date = doneLayout?task.completionTime:task.smartTime;
		
		[todayLines addObject:line];
		
		[line release];
		
		nextY = frm.origin.y + frm.size.height + TASK_PAD_HEIGHT;
		
		ret = YES;
	}

	if (ret)
	{
		frm = taskView.frame;
		
		frm.origin.y = nextY;
		
		//taskView.frame = frm;
        [taskView changeFrame:frm];
	}
	
	return ret;
}

- (BOOL) layout4Tasks:(NSArray *)taskList2Layout fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex forActive:(BOOL)forActive todayLines:(NSMutableArray *)todayLines
{
    //printf("layout the rest [%d-%d]\n", fromIndex, toIndex);
    
	BOOL checkActive = forActive;
	
	//if todayLines is nil -> layout and todayLines directly to veiw container 
	
	NSMutableArray *tdLines = (todayLines == nil?[NSMutableArray arrayWithCapacity:7]:todayLines);

	for (int i=fromIndex; i<toIndex; i++)
	{
		Task *task = [taskList2Layout objectAtIndex:fromIndex++];
		
		TaskView *taskView = [self layoutObject:task reusableView:nil];
		
		taskView.movableController = self.movableController;
		
		BOOL hasTodayLine = [self layoutTodayLines:tdLines taskView:taskView forActive:checkActive];
		
		if (checkActive && hasTodayLine)
		{
			checkActive = NO;
		}
		
        //printf("add view for task: %s\n", [task.name UTF8String]);
		[self.viewContainer addSubview:taskView];
		
		lastView = taskView;
	}
	
	if (todayLines == nil)
	{
		for (UIView *view in tdLines)
		{
			[self.viewContainer addSubview:view];
		}
	}
	
	return checkActive;
}

- (void) layoutBackground:(NSArray *)taskList2Layout
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	TaskManager *tm = [TaskManager getInstance];
    
    //printf("smart list layout background - views: %d - task count:%d\n", self.viewContainer.subviews.count, taskList2Layout.count);

	//NSArray *taskList = [self getObjectList];
	
	NSInteger idx = 0;
	
	lastView = nil;
	
	NSMutableArray *todayLines = [NSMutableArray arrayWithCapacity:7];
	
	BOOL forActive = (tm.taskTypeFilter == TASK_FILTER_ACTIVE);

	for (UIView *view in self.viewContainer.subviews)
	{
		//if ([view isKindOfClass:[TaskView class]] && idx < taskList2Layout.count)
        if ([self checkReusableView:view] && idx < taskList2Layout.count)
		{
			Task *task = [taskList2Layout objectAtIndex:idx++];
			
			TaskView *taskView = [self layoutObject:task reusableView:view];
			
			BOOL hasTodayLine = [self layoutTodayLines:todayLines taskView:taskView forActive:forActive];
			
			if (forActive && hasTodayLine)
			{
				forActive = NO;
			}
			
			lastView = taskView;
		}
		else if ([self checkRemovableView:view])
		{
            //printf("remove\n");
            
			[view removeFromSuperview];
		}
	}
	
	[self layout4Tasks:taskList2Layout fromIndex:idx toIndex:taskList2Layout.count forActive:forActive todayLines:todayLines];
	
	for (UIView *view in todayLines)
	{
        ////printf("add today line x:%f, y:%f, w:%f, h:%f\n", view.frame.origin.x, view.frame.origin.y,view.frame.size.width, view.frame.size.height);
        
		[self.viewContainer addSubview:view];
	}
	
	[self initContentOffset];
	
	self.layoutInProgress = NO;
	
	[[BusyController getInstance] setBusy:NO withCode:BUSY_TASK_LAYOUT];
	
	[pool release];
}

- (void) layoutTasksInBackground:(NSDictionary *)paramDict
{
    //printf("smart list layout tasks in background\n");
    
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSArray *taskList2Layout = [paramDict objectForKey:@"taskList"];
	
	NSNumber *fromIndexNum = [paramDict objectForKey:@"fromIndex"];
	
	NSNumber *toIndexNum = [paramDict objectForKey:@"toIndex"];
	
	NSNumber *forActiveNum = [paramDict objectForKey:@"forActive"];
	
	[self layout4Tasks:taskList2Layout fromIndex:[fromIndexNum intValue] toIndex:[toIndexNum intValue] forActive:[forActiveNum boolValue] todayLines:nil];
	
	[self initContentOffset];
	
	self.layoutInProgress = NO;
	
	[[BusyController getInstance] setBusy:NO withCode:BUSY_TASK_LAYOUT_SUBSET];
	
	[pool release];
}

- (void) layout
{
    //@synchronized(self)
    //{
	if (self.viewContainer == nil)
	{
        //printf("view container is nil -> end\n");
		self.layoutInProgress = NO;
		
		return;
	}
	//printf("smart list begin layout\n");
    
    [self wait4LayoutComplete];
    
    //printf("smartlist begin layout\n");
    
    [super beginLayout];
	
	self.layoutInProgress = YES;
		
	//lastView = nil;
	
	NSMutableArray *taskList2Layout = [self getObjectList];
	
	//////printf("*** Task List to layout:\n");
	//[[TaskManager getInstance] print:taskList];
	
	if (self.viewContainer.subviews.count == 0)
	{
		TaskManager *tm = [TaskManager getInstance];
		
		NSInteger toIndex = (taskList2Layout.count < MAX_LAYOUT_NUM?taskList2Layout.count:MAX_LAYOUT_NUM);

		BOOL forActive = (tm.taskTypeFilter == TASK_FILTER_ACTIVE);
		
		forActive = [self layout4Tasks:taskList2Layout fromIndex:0 toIndex:toIndex forActive:forActive todayLines:nil];
		
		[self initContentOffset];
		
		if (toIndex < taskList2Layout.count)
		{
			NSDictionary *paramDict = [NSDictionary dictionaryWithObjectsAndKeys:
									   taskList2Layout, @"taskList",
									   [NSNumber numberWithInt:toIndex + 1], @"fromIndex",
									   [NSNumber numberWithInt:taskList2Layout.count], @"toIndex",
									   [NSNumber numberWithBool:forActive], @"forActive", nil];
			
            //printf("busy layout subset\n");
            
			[[BusyController getInstance] setBusy:YES withCode:BUSY_TASK_LAYOUT_SUBSET];
			[self performSelectorInBackground:@selector(layoutTasksInBackground:) withObject:paramDict];			
		}
		
		if (toIndex == taskList2Layout.count)
		{
			self.layoutInProgress = NO;
			
			//[[_tabBarCtrler getSmartListViewCtrler]  finishLayout];
		}

	}
	else 
	{
        //printf("busy layout\n");
        
		[[BusyController getInstance] setBusy:YES withCode:BUSY_TASK_LAYOUT];
		[self performSelectorInBackground:@selector(layoutBackground:) withObject:taskList2Layout];		
	}
    //}
	////NSLog(@"smart list end layout");
}

- (BOOL) checkReusableView:(UIView *) view
{
	return [view isKindOfClass:[TaskView class]];
}

- (TaskView *) layoutObject:(Task *) task reusableView:(TaskView *)reusableView
{
    TaskManager *tm = [TaskManager getInstance];
    
	CGRect lastFrame = (lastView == nil? CGRectOffset(CGRectZero, 0, 45):lastView.frame);
	
	CGRect frm = CGRectZero;
	frm.origin.y = lastFrame.origin.y + lastFrame.size.height + TASK_PAD_HEIGHT;
	frm.origin.x = 0;

    frm.size.width = self.viewContainer.bounds.size.width;
	frm.size.height = TASK_HEIGHT;
	
	TaskView *taskView = reusableView;
	
	if (taskView != nil)
	{
		//taskView.frame = frm;
        [taskView changeFrame:frm];
	}
	else
	{
		taskView = [[[TaskView alloc] initWithFrame:frm] autorelease];
        taskView.listStyle = YES;
		//taskView.starEnable = YES;
        
        SmartListViewController *ctrler = [_abstractViewCtrler getSmartListViewController];
        
        if ([ctrler isInMultiEditMode])
        {
            [taskView multiSelect:YES];
        }
	}

    task.listSource = SOURCE_SMARTLIST;
	//taskView.tag = task;
    taskView.task = task;
    
    taskView.starEnable = (task.status != TASK_STATUS_DONE);    
	//[taskView refreshStarImage];
    //[taskView refreshCheckImage];
    [taskView enableMove:![task checkMustDo] && tm.taskTypeFilter != TASK_FILTER_DONE];
    if ([task isManual]) {
        [taskView enableMove:NO];
        taskView.starEnable = NO;
        taskView.checkEnable = YES;
    }
    [taskView refreshStarImage];
    [taskView refreshCheckImage];
    
    [taskView setNeedsDisplay];
	
	return taskView;
}

-(void)reset
{
	//checkActive = NO;
	
	[super reset];
}

- (BOOL) checkRemovableView:(UIView *) view
{
	if ([view isKindOfClass:[TaskView class]] || [view isKindOfClass:[DayHeaderView class]] || [view isKindOfClass:[TodayLine class]])
	{
		return YES;
	}
	
	return NO;
}

- (NSMutableArray *) getObjectList
{
	TaskManager *tm = [TaskManager getInstance];
    
    //[tm garbage:self.taskList];
	
	//NSMutableArray *list = [tm getDisplayList];
    // task list include manual tasks
    NSMutableArray *list = [tm getDisplayListWithManualTasks];
    [Common sortList:list byKey:@"smartTime" ascending:YES];
	
	self.taskList = list;
	
	return self.taskList;
}
/*
- (void) initContentOffset
{
    [self.viewContainer setContentOffset:CGPointMake(0, 40)];
}
*/
- (void)dealloc
{
    [layoutCond release];
    
	self.taskList = nil;
	
    [super dealloc];
}

@end
