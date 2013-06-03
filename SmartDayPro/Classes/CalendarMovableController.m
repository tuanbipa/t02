//
//  SmartCal2MovableViewController.m
//  SmartCal
//
//  Created by MacBook Pro on 3/21/11.
//  Copyright 2011 LCL. All rights reserved.
//

#import "CalendarMovableController.h"

#import "Common.h"
#import "Settings.h"
#import "TaskManager.h"
#import "DBManager.h"
#import "Task.h"
#import "MovableView.h"

#import "CalendarViewController.h"
#import "MiniMonthView.h"
#import "MonthlyCalendarView.h"

#import "TaskView.h"
#import "ScheduleView.h"

#import "AbstractSDViewController.h"
#import "CategoryViewController.h"

extern AbstractSDViewController *_abstractViewCtrler;

@implementation CalendarMovableController

- (id)init
{
	if (self = [super init])
	{	
	}
	
	return self;
}

#pragma mark Support Methods

- (void) doneMove
{
    [super endMove:self.activeMovableView];
    
    CalendarViewController *ctrler = [_abstractViewCtrler getCalendarViewController];
    
    [ctrler.todayScheduleView unhighlight];
}

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
    Task *task =  [[((TaskView *)self.activeMovableView).task retain] autorelease];

	if (alertVw.tag == -11000)
	{                
        [self doneMove];
        
        if (buttonIndex == 1)
        {
            [_abstractViewCtrler convert2Task:task];
        }
	}
	else if (alertVw.tag == -11001)
	{
        NSDate *time = [[[[_abstractViewCtrler getCalendarViewController].todayScheduleView getTimeSlot] retain] autorelease];
        
        [self doneMove];
        
        if (buttonIndex == 1)
        {
            [_abstractViewCtrler changeTime:task time:time];
        }
	}
	else if (alertVw.tag == -11002)
	{
        [self doneMove];
        
        if (buttonIndex != 0)
        {
            [_abstractViewCtrler convertRE2Task:buttonIndex task:task];
        }
    }
    else
    {
        //to handle MiniMonth actions
        [super alertView:alertVw clickedButtonAtIndex:buttonIndex];
    }
}

#pragma mark MovableController Interface Customization
- (BOOL)canSeparate
{
    return [((TaskView *)self.activeMovableView).task type] == TYPE_TASK;
}

-(void)move:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super move:touches withEvent:event];
    
    CalendarViewController *ctrler = [_abstractViewCtrler getCalendarViewController];
    
    [ctrler.todayScheduleView highlight:self.activeMovableView.frame];
}

-(void) endMove:(MovableView *)view
{
    CalendarViewController *ctrler = [_abstractViewCtrler getCalendarViewController];
    
    self.activeMovableView = view;
    
    [self unseparate];
 
    self.activeMovableView.hidden = NO;
    
    dummyView.hidden = YES;
    
    BOOL refresh = YES;
    
    if (dummyView != nil && [dummyView superview])
    {
        Task *task =  ((TaskView *)self.activeMovableView).task;
        [[task retain] autorelease];
        
        BOOL moveAsEvent = ([task isEvent] || ([task isTask] && [[Settings getInstance] movableAsEvent] == 0));
        
        BOOL convertEventIntoTask = [task isEvent] && self.activeMovableView.frame.origin.x > ctrler.calendarView.bounds.size.width + 60;
        
        if (moveInFocus)
        {
            [self doTaskMovementInFocus];
        }
        else if (moveInMM)
        {
            [self doTaskMovementInMM];
        }
        else if (rightMovableView != nil)
        {
            Task *destTask = ((TaskView *)rightMovableView).task;

            [[destTask retain] autorelease];
            
            [self doneMove];
            
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
        else if (convertEventIntoTask)
        {
            if ([task isREInstance])
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_warningText  message:_convertREIntoTaskConfirmation delegate:self cancelButtonTitle:_cancelText otherButtonTitles:_onlyInstanceText, _allFollowingText, nil];
                
                alertView.tag = -11002;
                
                [alertView show];
                [alertView release];        
                
            }
            else 
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_warningText  message:_convertIntoEventConfirmation delegate:self cancelButtonTitle:_cancelText otherButtonTitles:_okText, nil];
                
                alertView.tag = -11000;
                
                [alertView show];
                [alertView release];                 
            }
            
            return;
        }
        else if (moveAsEvent)
        {
            if ([task isTask])
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_warningText  message:_convertIntoTaskConfirmation delegate:self cancelButtonTitle:_cancelText otherButtonTitles:_okText, nil];
                
                alertView.tag = -11001;
                
                [alertView show];
                [alertView release]; 
                
                return;

            }
            
            NSDate *time = [[[ctrler.todayScheduleView getTimeSlot] retain] autorelease];
            
            [self doneMove];
            
            [_abstractViewCtrler changeTime:task time:time];
            
        }
        else 
        {
            refresh = NO;
            
            [self doneMove];
        }
        /*
        if (!moveInMM && !moveInFocus)
        {
            [super endMove:view];
        }*/
    }
    
    [ctrler.todayScheduleView unhighlight];
        
    if (!moveInMM && !moveInFocus && refresh)
    {
        [ctrler refreshLayout];
    }
    
}

-(void)reset
{
	[super reset];
}

-(void)deselect
{
	[super deselect];
}

- (void)dealloc
{
	[super dealloc];
}

@end
