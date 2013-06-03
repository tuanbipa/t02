//
//  PlannerCalendarLayoutController.m
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 4/3/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "PlannerCalendarLayoutController.h"
#import "Task.h"
#import "TaskView.h"
#import "Common.h"
#import "TaskManager.h"
#import "TimeSlotView.h"
#import "Settings.h"
#import "ProjectManager.h"
#import "TaskLinkView.h"

@implementation PlannerCalendarLayoutController

@synthesize objList;
@synthesize startDate;

- (id)init
{
	if (self = [super init])
	{
	}
	
	return self;
}

- (void) dealloc
{
    self.objList = nil;
    self.startDate = nil;
    
    [super dealloc];
}

- (BOOL) checkOverlap:(TaskView *)view
{
	if (lastView != nil)
	{
        Task *task = view.task;
        Task *lastTask = ((TaskView *) lastView).task;
        
        if (task.type == lastTask.type &&
            CGRectIntersectsRect(lastView.frame, CGRectOffset(view.frame, 0, 5)))
        {
            return YES;
        }
        
    }
    
    return NO;
}

- (TaskView *) layoutObject:(Task *) task reusableView:(TaskView *)reusableView
{
        
    // drawing events
    NSDate *startTime = task.startTime;
	
	CGSize timePaneSize = [TimeSlotView calculateTimePaneSize];
	CGFloat ymargin = TIME_SLOT_HEIGHT/2;
	CGFloat xmargin = LEFT_MARGIN + timePaneSize.width + TIME_LINE_PAD;
	
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
    
	NSDateComponents *comps = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:startTime];
	NSInteger hour = [comps hour];
	NSInteger minute = [comps minute];
	
	NSInteger slotIdx = 2*hour + minute/30;
	
	CGRect frm;
    
    //NSInteger days = [Common daysBetween:startTime sinceDate:date];
    NSInteger days = [Common daysBetween:startTime sinceDate:startDate];
    
    CGFloat dayWidth = (self.viewContainer.bounds.size.width - xmargin)/7;
    //NSInteger dayWidth = (self.viewContainer.bounds.size.width - xmargin)/7;
    
    CGFloat pageOffset = days*dayWidth;
    
    //printf("task:%s - start:%s - offset:%f\n", [task.name UTF8String], [[task.startTime description] UTF8String], pageOffset);
	
	//frm.origin.x = xmargin + (task.type == TYPE_TASK?CALENDAR_BOX_ALIGNMENT:0) + pageOffset;
    frm.origin.x = xmargin + pageOffset;
	
	//frm.size.width = 320 - xmargin - CALENDAR_BOX_ALIGNMENT;
    //frm.size.width = self.viewContainer.bounds.size.width - xmargin - CALENDAR_BOX_ALIGNMENT - (task.type == TYPE_TASK?20:0);
    frm.size.width = dayWidth-1;
	
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
	
	TaskView *taskView = reusableView;
	
	if (taskView == nil)
	{
		taskView = [[[TaskView alloc] initWithFrame:frm] autorelease];
	}
	else
	{
        [taskView changeFrame:frm];
	}
    
    task.listSource = SOURCE_PLANNER_CALENDAR;
    
    if ([task isTask])
    {
        task.isSplitted = NO;
    }
    
    taskView.alpha = 1;
	//taskView.tag = task;
    taskView.task = task;
    [taskView enableMove:YES];
    taskView.checkEnable = NO;
    
    taskView.checkEnable = NO;
    [taskView refreshCheckImage];
    
	taskView.touchHoldEnable = YES;
	
    // check overlap
    int index = days;
    
    BOOL overlapping = (slotObjects[index][slotIdx].count > 0);
    
    [slotObjects[index][slotIdx] addObject:taskView];
    
    if (overlapping)
    {
        NSInteger count = slotObjects[index][slotIdx].count;
        NSInteger space = 2;
        
        //CGFloat w = (self.viewContainer.bounds.size.width - xmargin - (count-1)*space)/count;
        CGFloat w = (dayWidth - (count-1)*space)/count;
        
        for (int i=0; i<count; i++)
        {
            TaskView *view = [slotObjects[index][slotIdx] objectAtIndex:i];
            
            CGRect rect = view.frame;
            rect.size.width = w;
            
            rect.origin.x = frm.origin.x + (w + space)*i;
            
            [view changeFrame:rect];
        }
    }
    // end check overlap
    
    //printf("calendar task %s - frame x: %f, width: %f\n", [task.name UTF8String], taskView.frame.origin.x, taskView.frame.size.width);
    
 	return taskView;
}

- (BOOL) checkReusableView:(UIView *) view
{
	return [view isKindOfClass:[TaskView class]];
}

- (BOOL) checkRemovableView:(UIView *) view
{
	return [view isKindOfClass:[TaskView class]];
}

- (void) beginLayout
{
	[super beginLayout];
    
    for (int i=0; i<7; i++)
    {
        for (int j=0; j<48; j++)
        {
            slotObjects[i][j] = [[NSMutableArray alloc] initWithCapacity:3];
        }
    }
    
    [self removeLinkViews];
}

- (void) endLayout
{
	[super endLayout];
    
    for (int i=0; i<7; i++)
    {
        for (int j=0; j<48; j++)
        {
            [slotObjects[i][j] release];
        }
    }
    
    [self createLinkViews];
    
    [self refreshTransparentEvents];
}

- (NSArray *) getObjectList
{
    TaskManager *tm = [TaskManager getInstance];
    
    if (startDate == nil) {
        NSDate *dt = tm.today;
        Settings *settings = [Settings getInstance];
        self.startDate = [Common getFirstWeekDate:dt mondayAsWeekStart:(settings.weekStart==1)];
    }
    NSDate *start = [Common clearTimeForDate:startDate];
    NSDate *end = [Common getEndDate:[Common dateByAddNumDay:6 toDate:startDate]];
    
    // only get events
    self.objList = [tm getEventListFromDate:start toDate:end];
    
	return self.objList;
}

- (void) setContentOffsetForTime:(NSDate *)time
{
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	unsigned unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit |  NSSecondCalendarUnit;
	
	CGFloat hours = [[gregorian components:unitFlags fromDate:time] hour];
	
	[(UIScrollView *) self.viewContainer setContentOffset:CGPointMake(0, (hours<4?0:hours-3)*2*TIME_SLOT_HEIGHT)];
}

- (void) initContentOffset
{
}

- (void) refreshTransparentEvents
{
    NSMutableArray *prjList = [[ProjectManager getInstance] getTransparentProjectList];
    
    NSDictionary *transparentProjectDict = [ProjectManager getProjectDictById:prjList];
    
	for (UIView *view in self.viewContainer.subviews)
	{
        if ([view isKindOfClass:[TaskView class]])
        {
            TaskView *tskView = (TaskView *)view;
            
            //Task *task = (Task *)tskView.tag;
            Task *task = tskView.task;
            
            if ([task isEvent])
            {
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
		//Task *lastTask = (Task *)lastViewParam.tag;
		//Task *task = (Task *)view.tag;
		
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

- (void) createLinkViews
{
	//link Task Views
	UIView *lView = nil;
	
	NSMutableArray *linkedViews = [NSMutableArray arrayWithCapacity:5];
	
	for (UIView *view in self.viewContainer.subviews)
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
@end
