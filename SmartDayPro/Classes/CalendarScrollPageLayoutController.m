//
//  CalendarScrollPageLayoutController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 10/30/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//

#import "CalendarScrollPageLayoutController.h"

#import "Common.h"
#import "Settings.h"

#import "Task.h"

#import "TimeSlotView.h"
#import "TaskView.h"
#import "TaskLinkView.h"

#import "DBManager.h"
#import "TaskManager.h"
#import "ProjectManager.h"

#import "CalendarViewController.h"
#import "AbstractSDViewController.h"

extern AbstractSDViewController *_abstractViewCtrler;

@implementation CalendarScrollPageLayoutController

@synthesize overlapDict;

- (void) dealloc
{
    [super dealloc];
    
    self.overlapDict = nil;
    
    [self releaseObjectLists];
}

- (void) scrollPage:(NSInteger)page
{
    if (page != 1)
    {
        //scroll in Calendar view
        
        TaskManager *tm = [TaskManager getInstance];
        
        NSDate *dt = [Common dateByAddNumDay:(page==0?-1:1) toDate:tm.today];
        
        [_abstractViewCtrler scrollToDate:dt];
    }
    
    [super scrollPage:page];
}

- (NSMutableArray *) getObjectList
{
    //for links reconcile
    NSMutableArray *ret = [NSMutableArray arrayWithArray:objectLists[0]];
    
    [ret addObjectsFromArray:objectLists[1]];
    [ret addObjectsFromArray:objectLists[2]];
    
    return ret;
}

- (void) releaseObjectLists
{
    for (int i=0; i<3; i++)
    {
        if (objectLists[i] != nil)
        {
            [objectLists[i] release];
            objectLists[i] = nil;
        }
    }    
}

- (NSMutableArray *) getObjectListForPage:(NSInteger) page
{
    TaskManager *tm = [TaskManager getInstance];
    
    NSDate *dt = tm.today;
    
    if (page == 0)
    {
        dt = [Common dateByAddNumDay:-1 toDate:dt];
    }
    else if (page == 2)
    {
        dt = [Common dateByAddNumDay:1 toDate:dt];
    }
    
    NSDate *start = [Common clearTimeForDate:dt];
    NSDate *end = [Common getEndDate:dt];

    //printf("get object list for page: %d, from: %s - to: %s\n", page, [[start description] UTF8String], [[end description] UTF8String]);
        
    NSMutableArray *list = [tm getEventListFromDate:start toDate:end];
    
	if ([[Settings getInstance] eventCombination] == 0)
	{
        NSArray *taskList = [tm getScheduledTasksFromDate:start toDate:end];
        
		[list addObjectsFromArray:taskList];
        
        [Common sortList:list byKey:@"smartTime" ascending:YES];
        
        //printf("*** Calendar Object List\n");
        
        [tm print:list];
        
        //printf("***\n");
	}

    if (objectLists[page] != nil)
    {
        [objectLists[page] release];
    }
    
    objectLists[page] = [list retain];
    
    return list;
}

/*
- (NSMutableArray *) getObjectList
{
    NSMutableArray *ret = [NSMutableArray arrayWithArray:objectLists[0]];
    
    [ret addObjectsFromArray:objectLists[1]];
    [ret addObjectsFromArray:objectLists[2]];
    
    return ret;
}
*/

- (void) initContentOffset
{
}

- (void) layout
{
    //printf("calendar LAYOUT\n");
    [super layout];
}

- (void) beginLayout
{
	[super beginLayout];
    
    self.overlapDict = [NSMutableDictionary dictionaryWithCapacity:5];
}

- (void) endLayout
{
	[super endLayout];
    
    self.overlapDict = nil;
}

- (void) refreshPage:(NSInteger)page needFree:(BOOL)needFree
{
    [super refreshPage:page needFree:needFree];
    
    [self refreshTransparentEvents:page];
    [self createLinkViews:page];
}

- (BOOL) checkOverlap:(UIView *)view
{
	if (lastView != nil && ((TaskView *)lastView).task.type == ((TaskView *)view).task.type)
	{
		return CGRectIntersectsRect(lastView.frame, CGRectOffset(view.frame, 0, 5));
	}
	
	return NO;
}

- (UIView *) layoutObject:(NSObject *)obj forPage:(NSInteger)page
{
    Task *task = (Task *)obj;
        
    NSDate *startTime = [task isTask]?task.smartTime:task.startTime;
	
	CGSize timePaneSize = [TimeSlotView calculateTimePaneSize];
	CGFloat ymargin = TIME_SLOT_HEIGHT/2;
	CGFloat xmargin = LEFT_MARGIN + timePaneSize.width + TIME_LINE_PAD;
	
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
    
	NSDateComponents *comps = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:startTime];
	NSInteger hour = [comps hour];
	NSInteger minute = [comps minute];
	
	NSInteger slotIdx = 2*hour + minute/30;
	
	CGRect frm;
    
	frm.origin.x = xmargin + (task.type == TYPE_TASK?CALENDAR_BOX_ALIGNMENT:0);
	
    frm.size.width = self.viewContainer.bounds.size.width - xmargin - CALENDAR_BOX_ALIGNMENT - (task.type == TYPE_TASK?20:0);
	
	frm.origin.y = ymargin + slotIdx * TIME_SLOT_HEIGHT + 1;
	
	if (minute >= 30)
	{
		minute -= 30;
	}
	
	frm.origin.y += minute*TIME_SLOT_HEIGHT/30;
	
	NSInteger howLong = [Common timeIntervalNoDST:task.endTime sinceDate:startTime];
    
	if (howLong <= 1800)
	{
		frm.size.height = TIME_SLOT_HEIGHT;
	}
	else
	{
		frm.size.height = 2*TIME_SLOT_HEIGHT*howLong/3600;
	}
	
	TaskView *taskView = (TaskView *)[self getReusableView];
	
	if (taskView == nil)
	{
		taskView = [[[TaskView alloc] initWithFrame:frm] autorelease];
	}
	else
	{
        [taskView changeFrame:frm];
	}
    
    task.listSource = SOURCE_CALENDAR;
    
    if ([task isTask])
    {
        task.isSplitted = NO;
    }
    
    taskView.alpha = 1;
    taskView.transparent = NO;
    taskView.task = task;
    [taskView enableMove:![task checkMustDo] && ![task isShared]];
    taskView.checkEnable = NO;
    
    [taskView refreshCheckImage];
    
	taskView.touchHoldEnable = YES;
	
	if (task.type == TYPE_EVENT)
	{
        NSMutableArray *list = [self.overlapDict objectForKey:[NSNumber numberWithInt:slotIdx]];

        BOOL overlapping = (list != nil && list.count > 0);
        
        if (list == nil)
        {
            list = [NSMutableArray arrayWithCapacity:3];
            
            [self.overlapDict setObject:list forKey:[NSNumber numberWithInt:slotIdx]];
        }

        [list addObject:taskView];
        		
		if (overlapping)
		{
            NSInteger count = list.count;
			NSInteger space = 2;
			
			CGFloat w = (self.viewContainer.bounds.size.width - xmargin - (count-1)*space)/count;
			
			for (int i=0; i<count; i++)
			{
                TaskView *view = [list objectAtIndex:i];
				
				CGRect rect = view.frame;
				rect.size.width = w;
				
				rect.origin.x = frm.origin.x + (w + space)*i;
				
                [view changeFrame:rect];
			}
		}
	}
    
    ////printf("calendar task %s - frame x: %f, width: %f\n", [task.name UTF8String], taskView.frame.origin.x, taskView.frame.size.width);
    
	return taskView;
}

- (void) refreshTransparentEvents:(NSInteger)page
{
    NSMutableArray *prjList = [[ProjectManager getInstance] getTransparentProjectList];
    
    NSDictionary *transparentProjectDict = [ProjectManager getProjectDictById:prjList];
    
	NSMutableArray *pages[3] = {self.previousPage, self.currentPage, self.nextPage};
    
	for (UIView *view in pages[page])
	{
        if ([view isKindOfClass:[TaskView class]])
        {
            TaskView *tskView = (TaskView *)view;
            
            Task *task = tskView.task;
            
            if ([task isEvent] && ![task isMeetingInvited])
            {
                //printf("trans event:%s\n", [task.name UTF8String]);
                Project *transPrj = [transparentProjectDict objectForKey:[NSNumber numberWithInt:task.project]];
                
                tskView.alpha = (transPrj != nil?0.5:1);
                
                BOOL change = (tskView.transparent != (transPrj != nil));
                
                tskView.transparent = (transPrj != nil);
                
                if (transPrj != nil)
                {
                    [tskView.superview bringSubviewToFront:tskView];
                }
                
                if (change)
                {
                    [tskView setNeedsDisplay];
                }
            }
            
        }
	}
}

- (UIView *) linkView:(TaskView *)lastViewParam withView:(TaskView *)view
{
	if (lastViewParam != nil)
	{
		Task *lastTask = lastViewParam.task;
		Task *task = view.task;
		
        if ([task isTask] && task.original != nil && lastTask.original == task.original && [Common daysBetween:lastTask.smartTime sinceDate:task.smartTime] == 0)
		{
            lastTask.isSplitted = YES;
            task.isSplitted = YES;
            
			CGRect frm;
			frm.origin.x = lastViewParam.frame.origin.x + lastViewParam.frame.size.width - 10;
			frm.origin.y = lastViewParam.frame.origin.y + lastViewParam.frame.size.height;
			frm.size.width = 4;
			frm.size.height = view.frame.origin.y - frm.origin.y;
			
			TaskLinkView *linkView = [[TaskLinkView alloc] initWithFrame:frm];
			linkView.colorId = [[ProjectManager getInstance] getProjectColorID:task.project];
			
			return [linkView autorelease];
		}
	}
	
	return nil;
}

- (void) createLinkViews:(NSInteger)page
{
	//link Task Views
	UIView *lView = nil;
	
	NSMutableArray *linkedViews = [NSMutableArray arrayWithCapacity:5];
	
	NSMutableArray *pages[3] = {self.previousPage, self.currentPage, self.nextPage};
    
	for (UIView *view in pages[page])
	{
        if (![view isKindOfClass:[TaskView class]])
        {
            continue;
        }
        
		//Task *task = (Task *)view.tag;
        Task *task = ((TaskView *)view).task;
        
		if (task.type == TYPE_TASK)
		{
			UIView *linkView = [self linkView:lView withView:view];
			
			if (linkView != nil)
			{
				[linkedViews addObject:linkView];
			}
			
			lView = view;
		}
	}
	
	for (UIView *linkView in linkedViews)
    {
        [pages[page] addObject:linkView];
        
        [self.viewContainer addSubview:linkView];
    }
}

- (void) removeLinkViews
{
	for (UIView *view in self.viewContainer.subviews)
	{
        if ([view isKindOfClass:[TaskLinkView class]])
        {
            [view removeFromSuperview];
        }
    }
}

- (void) refreshSyncID4AllItems
{
    DBManager *dbm = [DBManager getInstance];

    for (int i=0; i<3; i++)
    {
        NSArray *list = objectLists[i];
        
        for (Task *task in list)
        {
            [task refreshSyncIDFromDB:[dbm getDatabase]];
        }
    }
}

- (Task *) findEventByKey:(NSInteger) key
{
    for (int i=0; i<3; i++)
    {
        for (Task *task in objectLists[i])
        {
            if (task.primaryKey == key)
            {
                return task;
            }
        }
    }
    
    return nil;
}

@end
