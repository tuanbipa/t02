//
//  SmartListMovableController.m
//  SmartCal
//
//  Created by Trung Nguyen on 5/20/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "SmartListMovableController.h"

#import "Common.h"

#import "TaskView.h"
#import "MiniMonthView.h"
#import "MonthlyCalendarView.h"

#import "TaskManager.h"
#import "DBManager.h"
#import "Task.h"

#import "SmartListLayoutController.h"

#import "SmartListViewController.h"
#import "CategoryViewController.h"
//#import "SmartDayPageViewController.h"
//#import "ListViewController.h"

#import "AbstractSDViewController.h"
#import "CalendarViewController.h"
#import "ScheduleView.h"

extern SmartListViewController *_smartListViewCtrler;

extern AbstractSDViewController *_abstractViewCtrler;

@implementation SmartListMovableController

- (id)init
{
	if (self = [super init])
	{
	}
	
	return self;
}

- (BOOL)checkSeparate:(TaskView *)view
{
    Task *task = view.task;
    
    return ![task checkMustDo] && ![task isManual];
}

-(void) beginMove:(MovableView *)view
{
    if ([[TaskManager getInstance] taskTypeFilter] != TASK_FILTER_DONE)
    {
        [super beginMove:view];
    }
}

-(void)move:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super move:touches withEvent:event];
    
    CalendarViewController *ctrler = [_abstractViewCtrler getCalendarViewController];
    if (moveInDayCalendar) {
        
        //CalendarViewController *ctrler = [_abstractViewCtrler getCalendarViewController];
        CGRect rect = [self.activeMovableView.superview convertRect:self.activeMovableView.frame toView:ctrler.todayScheduleView];
        [ctrler.todayScheduleView highlight:rect];
    } else {
        [ctrler.todayScheduleView unhighlight];
    }
}

-(void) endMove:(MovableView *)view
{
    [view retain];
    
    [self unseparate];
    
    self.activeMovableView = view;
    
    self.activeMovableView.hidden = NO;
    
    dummyView.hidden = YES;    
    
    if (dummyView != nil && [dummyView superview])
    {
        Task *task = ((TaskView *) self.activeMovableView).task;
        [[task retain] autorelease];
        
        if (moveInFocus)
        {
            [self doTaskMovementInFocus];
        }
        else if (moveInMM)
        {
            [self doTaskMovementInMM];
        }
        else if (moveInDayCalendar)
        {
            [self doMoveTaskInDayCalendar];
        }
        else if (rightMovableView != nil)
        {
            Task *destTask = ((TaskView *)rightMovableView).task;
            [[destTask retain] autorelease];
            
            [super endMove:view];
            
            if ([task isTask] && [destTask isTask])
            {
                [[TaskManager getInstance] changeOrder:task destTask:destTask];
                
                CategoryViewController *ctrler = [_abstractViewCtrler getCategoryViewController];
                
                if (ctrler.filterType == TYPE_TASK)
                {
                    [ctrler loadAndShowList];
                }
            }
        }
        else
        {
            [super endMove:view];
        }
    }
        
    [view release];
}

#pragma mark After end move

- (void)doMoveTaskInDayCalendar {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_warningText  message:_convertIntoSTaskConfirmation delegate:self cancelButtonTitle:_cancelText otherButtonTitles:_okText, nil];
    
    alertView.tag = -11001;
    
    [alertView show];
    [alertView release];
}
@end
