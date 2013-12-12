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

#import "PlannerBottomDayCal.h"
#import "PlannerScheduleView.h"
#import "PlannerViewController.h"

extern AbstractSDViewController *_abstractViewCtrler;

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
    
    if ([[AbstractActionViewController getInstance] isKindOfClass:[PlannerViewController class]]) {
        PlannerBottomDayCal *plannerDayCal = (PlannerBottomDayCal*)[[AbstractActionViewController getInstance] getPlannerDayCalendarView];
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
    if ((moveInFocus || moveInDayCalendar || moveInMM || moveInPlannerMM || moveInPlannerDayCalendar) || ![self checkSeparate:self.activeMovableView])
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
@end
