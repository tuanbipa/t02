//
//  CalendarDayLayoutController.m
//  SmartCal
//
//  Created by Trung Nguyen on 6/14/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "CalendarDayLayoutController.h"

#import "Common.h"
#import "TaskView.h"
#import "TaskManager.h"
#import "ProjectManager.h"
#import "TimeSlotView.h"
#import "Task.h"
#import "TaskProgress.h"

@implementation CalendarDayLayoutController

@synthesize calendarDate;
@synthesize objectList;

- (id)init
{
	if (self = [super init])
	{
		self.calendarDate = [NSDate date];
		self.movableController = nil;
		self.objectList = nil;
	}
	
	return self;
}

- (void) beginLayout
{
	[super beginLayout];
	
	for (int i=0; i<48; i++)
	{
		slotObjects[i] = [[NSMutableArray alloc] initWithCapacity:3];
	}
}

- (void) endLayout
{
	[super endLayout];
	
	for (int i=0; i<48; i++)
	{
		[slotObjects[i] release];
	}
    
    [self refreshTransparentEvents];
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
                Project *transPrj = [transparentProjectDict objectForKey:[NSNumber numberWithInteger:task.project]];
                
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

- (void) setContentOffsetForTime:(NSDate *)time
{
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	unsigned unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit |  NSSecondCalendarUnit;	
	
	CGFloat hours = [[gregorian components:unitFlags fromDate:time] hour];	
	
	UIScrollView *parent = [self.viewContainer superview];
	[parent setContentOffset:CGPointMake(0, (hours < 3?0:hours-2)*2*TIME_SLOT_HEIGHT)];
}

- (void) initContentOffset
{
	[self setContentOffsetForTime:[NSDate date]];
}

- (BOOL) checkReusableView:(UIView *) view
{
	return [view isKindOfClass:[TaskView class]];
}

- (TaskView *) layoutObject:(Task *) task reusableView:(TaskView *)reusableView
{
	TaskManager *tm = [TaskManager getInstance];
	
	NSDate *date = self.calendarDate;
	
	TaskProgress *segment = [tm getEventSegment:task onDate:date];
	
	CGSize timePaneSize = [TimeSlotView calculateTimePaneSize];
	CGFloat ymargin = TIME_SLOT_HEIGHT/2;	
	CGFloat xmargin = LEFT_MARGIN + timePaneSize.width + TIME_LINE_PAD;
	
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSDateComponents *comps = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:segment.startTime];
	NSInteger hour = [comps hour];
	NSInteger minute = [comps minute];
	
	NSInteger slotIdx = 2*hour + minute/30;
	
	CGRect frm;
	
	frm.origin.x = xmargin;
	
	//frm.size.width = 3*WEEKVIEW_CELL_WIDTH - xmargin;
	
	CGFloat containerWidth = self.viewContainer.frame.size.width;
	
	frm.size.width = containerWidth - xmargin;
	
	frm.origin.y = ymargin + slotIdx * TIME_SLOT_HEIGHT + 1;
	
	if (minute >= 30)
	{
		minute -= 30;
	}
	
	frm.origin.y += minute*TIME_SLOT_HEIGHT/30;
	
	//NSTimeInterval howLong = [segment.endTime timeIntervalSinceDate:segment.startTime];
	NSInteger howLong = [Common timeIntervalNoDST:segment.endTime sinceDate:segment.startTime];
	
	CGFloat hours = howLong/3600;
	
	if (hours < 0.5)
	{
		frm.size.height = TIME_SLOT_HEIGHT;
	}
	else
	{
		frm.size.height = 2*TIME_SLOT_HEIGHT*hours;
	}
	
	//[taskView initWithFrame:frm];
	TaskView *taskView = reusableView;
	
	if (taskView != nil)
	{
		//////printf("reuse\n");
		taskView.frame = frm;
		taskView.alpha = 1;
	}
	else
	{
		//////printf("not reuse\n");
		taskView = [[[TaskView alloc] initWithFrame:frm] autorelease];
	}
	
	//taskView.tag = task;
    taskView.task = task;
	
	if (task.type == TYPE_EVENT)
	{
		BOOL overlapping = (slotObjects[slotIdx].count > 0);
		
		[slotObjects[slotIdx] addObject:taskView];
		
		if (overlapping)
		{
			NSInteger count = slotObjects[slotIdx].count;
			NSInteger space = 2;
			
			CGFloat w = (320 - xmargin - (count-1)*space)/count;
			
			for (int i=0; i<count; i++)
			{
				TaskView *view = [slotObjects[slotIdx] objectAtIndex:i];
				
				CGRect rect = view.frame;
				rect.size.width = w;
				
				rect.origin.x = frm.origin.x + (w + space)*i;
				
				view.frame = rect;
			}
		}		
	}
	
	return taskView;
}

- (void) handleOverlap:(TaskView *)view
{
	if ([self checkOverlap:view])
	{
		view.alpha = 0.7;
		
		CGRect frm = view.frame;
		
		//Task *task = (Task *) view.tag;
		//Task *lastTask = (Task *) lastView.tag;

		Task *task = view.task;
		Task *lastTask = ((TaskView *)lastView).task;
		
		CGFloat offset = (task.type == TYPE_TASK?-5:5);
		
		if (task.type == lastTask.type)
		{
			if (lastView.frame.size.width > 110) //full size box
			{
				frm.origin.x = lastView.frame.origin.x + offset;
			}
			else 
			{
				frm.origin.x += offset;
			}			
		}
		
		view.frame = frm;
		
	}		
}

- (BOOL) checkRemovableView:(UIView *) view
{
	if ([view isKindOfClass:[TaskView class]])
	{
		return YES;
	}
	
	return NO;
}

- (NSMutableArray *) getObjectList
{
	self.objectList = [[TaskManager getInstance] getEventListOnDate:self.calendarDate];
	
	return self.objectList;
}

- (void)dealloc {
	self.calendarDate = nil;
	self.objectList = nil;
	
	[super dealloc];
}

@end
