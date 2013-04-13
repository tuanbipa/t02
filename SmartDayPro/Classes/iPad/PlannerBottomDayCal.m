//
//  PlannerBottomDayCal.m
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 3/18/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "PlannerBottomDayCal.h"
#import "ContentScrollView.h"
#import "PlannerScheduleView.h"
#import "PlannerCalendarLayoutController.h"
#import "TaskView.h"
#import "Task.h"
#import "CalendarPlannerMovableController.h"
#import "TaskOutlineView.h"
#import "Common.h"
#import "TaskManager.h"

@implementation PlannerBottomDayCal

@synthesize movableController;
@synthesize plannerScheduleView;

@synthesize calendarLayoutController;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        //self.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor colorWithRed:237 green:237 blue:237 alpha:1.0];
        
        // add scroll view
        scrollView = [[ContentScrollView alloc] initWithFrame:self.bounds];
        scrollView.canCancelContentTouches = NO;
        scrollView.backgroundColor = [UIColor clearColor];
        //scrollView.delegate = calendarLayoutController;
        [self addSubview:scrollView];
        [scrollView release];
        
        plannerScheduleView = [[PlannerScheduleView alloc] initWithFrame:scrollView.bounds];
        //plannerScheduleView = [[PlannerScheduleView alloc] initWithFrame:CGRectOffset(scrollView.bounds, scrollView.bounds.size.width, 0)];
        [scrollView addSubview:plannerScheduleView];
        [plannerScheduleView release];
        
        calendarLayoutController = [[PlannerCalendarLayoutController alloc] init];
        // add movable controller
        movableController = [[CalendarPlannerMovableController alloc] init];
        calendarLayoutController.movableController = movableController;
        
        calendarLayoutController.viewContainer = scrollView;
        [calendarLayoutController layout];
        
        scrollView.contentSize = CGSizeMake(plannerScheduleView.frame.size.width, plannerScheduleView.frame.size.height);
        //scrollView.contentOffset = CGPointMake(self.bounds.size.width, 0);
        scrollView.scrollEnabled = YES;
        scrollView.scrollsToTop = NO;
        scrollView.showsHorizontalScrollIndicator = YES;
        scrollView.showsVerticalScrollIndicator = YES;
        scrollView.directionalLockEnabled = YES;
        
        // outline for resizing event
        outlineView = [[TaskOutlineView alloc] initWithFrame:CGRectZero];
        [self addSubview:outlineView];
        [outlineView release];
    }
    return self;
}

- (void)changeWeek: (NSDate*) startDate {
    [UIView beginAnimations:@"resize_animation" context:NULL];
    [UIView setAnimationDuration:0.3];

    [self updateFrame];
    
    // reload week view
    calendarLayoutController.startDate = startDate;
    [calendarLayoutController layout];
    
    [UIView commitAnimations];
}

- (void)updateFrame {
    scrollView.frame = self.bounds;
    scrollView.contentSize = CGSizeMake(plannerScheduleView.frame.size.width, plannerScheduleView.frame.size.height);
}

- (void) refreshLayout
{
    [calendarLayoutController layout];
}

- (void) refreshTaskView4Key:(NSInteger)taskKey
{
	for (UIView *view in scrollView.subviews)
	{
		if ([view isKindOfClass:[TaskView class]])
		{
            TaskView *taskView = (TaskView *) view;
            
            Task *task = taskView.task;
            
            if (task.original != nil)
            {
                task = task.original;
            }
            
            if (task.primaryKey == taskKey)
            {
                [taskView setNeedsDisplay];
                
                break;
            }
		}
	}
}

- (void)dealloc {
    [movableController release];
    [super dealloc];
}

- (void) setMovableContentView:(UIView *)contentView
{
    if ([movableController isKindOfClass:[DummyMovableController class]])
    {
        ((DummyMovableController *) movableController).contentView = contentView;
    }
}

#pragma mark resizing handle

- (void)beginResize:(TaskView *)view
{
	//[self deselect];
	
	//outlineView.tag = view.tag;
    outlineView.tag = view.task;
	
	CGRect frm = view.frame;
	
	frm.origin = [view.superview convertPoint:frm.origin toView:self];
	
	[outlineView changeFrame:frm];
	
	outlineView.hidden = NO;
	
	scrollView.scrollEnabled = NO;
	scrollView.userInteractionEnabled = NO;
}

- (void)finishResize
{
	Task *task = (Task *)outlineView.tag;
	
	int segments = [outlineView getResizedSegments];
	
	if (segments != 0 && outlineView.handleFlag != 0)
	{
		//if ([task isEvent])
		{
			if (outlineView.handleFlag == 1)
			{
				task.startTime = [Common dateByAddNumSecond:-segments*15*60 toDate:task.startTime];
			}
			else if (outlineView.handleFlag == 2)
			{
				task.endTime = [Common dateByAddNumSecond:segments*15*60 toDate:task.endTime];
			}
		}
		/*else if ([task isTask])
		{
			if (task.original != nil)
			{
				task = task.original;
			}
			
			task.duration += segments*15*60;
		}*/
        
		[[TaskManager getInstance] resizeTask:task];
        
        [calendarLayoutController layout];
	}
    
	[self stopResize];
}

- (void) stopResize
{
	outlineView.hidden = YES;
	
	scrollView.scrollEnabled = YES;
	scrollView.userInteractionEnabled = YES;
}
@end
