//
//  TaskMovableController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 7/1/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "TaskMovableController.h"

#import "Common.h"
#import "Task.h"

#import "TaskManager.h"

#import "TaskView.h"
#import "ScheduleView.h"

#import "CalendarViewController.h"
#import "CategoryViewController.h"
#import "AbstractSDViewController.h"

#import "iPadViewController.h"
#import "PlannerBottomDayCal.h"
#import "PlannerScheduleView.h"
#import "PlannerViewController.h"
#import "PlannerCalendarLayoutController.h"
#import "TimeSlotView.h"

extern AbstractSDViewController *_abstractViewCtrler;
iPadViewController *_iPadViewCtrler;

@implementation TaskMovableController

@synthesize listTableView;


- (id) init
{
    if (self = [super init])
    {
        self.autoScroll = NO;
    }
    
    return self;
}

-(void) beginMove:(MovableView *)view
{
    movedDirection = 0;
    self.listTableView.scrollEnabled = NO;
    
    [super beginMove:view];
}

-(void)move:(NSSet *)touches withEvent:(UIEvent *)event
{
    movedDirection = self.activeMovableView.movedDirection;
    
    [super move:touches withEvent:event];
    
    if ([_iPadViewCtrler.activeViewCtrler isKindOfClass:[PlannerViewController class]]) {
        PlannerBottomDayCal *plannerDayCal = (PlannerBottomDayCal*)[_iPadViewCtrler.activeViewCtrler getPlannerDayCalendarView];
        CGRect rect = [self.activeMovableView.superview convertRect:self.activeMovableView.frame toView:plannerDayCal.plannerScheduleView];
        if (moveInPlannerDayCalendar) {
            [plannerDayCal.plannerScheduleView highlight:rect];
        } else {
            [plannerDayCal.plannerScheduleView unhighlight];
        }
        
    } else {
    
    
        CalendarViewController *ctrler = [_abstractViewCtrler getCalendarViewController];
        if (moveInDayCalendar) {

            CGRect rect = [self.activeMovableView.superview convertRect:self.activeMovableView.frame toView:ctrler.todayScheduleView];
            [ctrler.todayScheduleView highlight:rect];
        } else {
            [ctrler.todayScheduleView unhighlight];
        }
    }
}

-(void) endMove:(MovableView *)view
{
    self.listTableView.scrollEnabled = YES;
    
    [view retain];
    
    [self unseparate];
    
    self.activeMovableView = view;
    
    self.activeMovableView.hidden = NO;
    
    dummyView.hidden = YES;
    
    if (dummyView != nil && [dummyView superview])
    {
        if (moveInFocus)
        {
            [self doTaskMovementInFocus];
        }
        else if (moveInMM || moveInPlannerMM)
        {
            [self doTaskMovementInMM];
        }
        else if (moveInDayCalendar || moveInPlannerDayCalendar)
        {
            [self doMoveTaskInDayCalendar];
        }
        else if (rightMovableView != nil)
        {
            Task *task = ((TaskView *) self.activeMovableView).task;
            [[task retain] autorelease];
            
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_convertATaskHeader  message:_convertIntoPinnedTaskConfirmation delegate:self cancelButtonTitle:_cancelText otherButtonTitles:_okText, nil];
    
    //alertView.tag = -11001;
    alertView.tag = moveInPlannerDayCalendar ? -11002: -11001;
    
    [alertView show];
    [alertView release];
}

- (NSDate*)getDateTimeInPlannerDayCalAtDrop
{
    // calculate date
    CGPoint touchPoint = [self.activeMovableView getTouchPoint];
    
    PlannerBottomDayCal *plannerDayCal = (PlannerBottomDayCal*)[_iPadViewCtrler.activeViewCtrler getPlannerDayCalendarView];
    touchPoint = [self.activeMovableView.superview convertPoint:touchPoint toView:plannerDayCal.plannerScheduleView];
    
    NSDate *startDate = [[plannerDayCal.calendarLayoutController.startDate copy] autorelease];
    
    CGFloat dayWidth = (plannerDayCal.bounds.size.width - TIMELINE_TITLE_WIDTH)/7;
    NSInteger dayNumber = (touchPoint.x-TIMELINE_TITLE_WIDTH)/dayWidth;
    
    TimeSlotView *timeSlot = [plannerDayCal.plannerScheduleView getTimeSlot];
    
    startDate = [Common copyTimeFromDate:[timeSlot getTime] toDate:startDate];
    NSDate *toDate = [Common dateByAddNumDay:dayNumber toDate:startDate];
    
    return toDate;
}

- (void) separateFrame:(BOOL) needSeparate
{
	if (rightMovableView != nil)
	{
		rightMovableView.frame = CGRectOffset(rightMovableView.frame, 0, needSeparate?SEPARATE_OFFSET:-SEPARATE_OFFSET);
	}
	
	if (leftMovableView != nil)
	{
		leftMovableView.frame = CGRectOffset(leftMovableView.frame, 0, needSeparate?-SEPARATE_OFFSET:SEPARATE_OFFSET);
	}
}

- (void) animateRelations
{
    if (moveInFocus || moveInDayCalendar || moveInMM || moveInPlannerMM || moveInPlannerDayCalendar)
    {
        [self unseparate];
        
        return;
    }
    
    MovableView *rightView = nil;
    MovableView *leftView = nil;
    
    CGRect frm = [self.activeMovableView.superview convertRect:self.activeMovableView.frame toView:self.listTableView];
    
    NSInteger sections = self.listTableView.numberOfSections;
    
    for (int i=0; i<sections; i++)
    {
        NSInteger rows = [self.listTableView numberOfRowsInSection:i];
        
        for (int j=0; j<rows; j++)
        {
            CGRect rect = [self.listTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            
            if (CGRectIntersectsRect(rect, frm))
            {
                UITableViewCell *cell = [self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
                
                rightView = [cell.contentView viewWithTag:-10000];
                
            }
        }
    }
    
    [self separate:rightView fromLeft:leftView];
}

#pragma mark Alert delegate

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
    Task *task = [[((TaskView *) self.activeMovableView).task retain] autorelease];
    if (alertVw.tag == -11002)
	{
        if (buttonIndex == 1)
        {
            NSDate *time = [self getDateTimeInPlannerDayCalAtDrop];
            
            [self convertTaskToSTask:task time:time];
        }
        CalendarViewController *ctrler = [_abstractViewCtrler getCalendarViewController];
        [ctrler.todayScheduleView unhighlight];
    }
    else
    {
        [super alertView:alertVw clickedButtonAtIndex:buttonIndex];
    }
}
@end
