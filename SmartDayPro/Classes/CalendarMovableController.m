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

#import "SmartDayViewController.h"

//extern SmartDayViewController *_sdViewCtrler;

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
- (void) convertRE2Task:(NSInteger)option task:(Task *)task
{
    //Task *task =  ((TaskView *)self.activeMovableView).task;
    
    TaskManager *tm = [TaskManager getInstance];
    
    [tm convertRE2Task:task option:option];
    
    //[_sdViewCtrler.miniMonthView refresh];
    [_abstractViewCtrler.miniMonthView refresh];
}

- (void) convert2Task:(Task *)task
{
    //Task *task =  ((TaskView *)self.activeMovableView).task;
    
    NSDate *sDate = [[task.startTime copy] autorelease];
    
    Task *taskCopy = [[task copy] autorelease];
    
    taskCopy.type = TYPE_TASK;
    
    if (task.original != nil && ![task isREException])
    {
        task = task.original;
    }
    
    BOOL isRE = [task isRE];
        
    TaskManager *tm = [TaskManager getInstance];
    
    [tm updateTask:task withTask:taskCopy];
    
    if (isRE)
    {
        //[_sdViewCtrler.miniMonthView refresh];
        [_abstractViewCtrler.miniMonthView refresh];
    } 
    else 
    {
        //[_sdViewCtrler.miniMonthView.calView refreshCellByDate:sDate];
        [_abstractViewCtrler.miniMonthView.calView refreshCellByDate:sDate];
        
        if (task.deadline != nil)
        {
            //[_sdViewCtrler.miniMonthView.calView refreshCellByDate:task.deadline];
            [_abstractViewCtrler.miniMonthView.calView refreshCellByDate:task.deadline];
        }
    }
}

- (void) doneMove
{
    [super endMove:self.activeMovableView];
    
    //CalendarViewController *ctrler = [_sdViewCtrler getCalendarViewController];
    CalendarViewController *ctrler = [_abstractViewCtrler getCalendarViewController];
    
    [ctrler.todayScheduleView unhighlight];
    
    //[self enableScroll:YES container:ctrler.calendarView];
}

- (void) changeTime:(Task *)task time:(NSDate *)time
{
    //Task *task =  ((TaskView *)self.activeMovableView).task;
    
    //CalendarViewController *ctrler = [_sdViewCtrler getCalendarViewController];
    CalendarViewController *ctrler = [_abstractViewCtrler getCalendarViewController];
    
    //NSDate *timeslot = [ctrler.todayScheduleView getTimeSlot];
    
    TaskManager *tm = [TaskManager getInstance];
    
    NSDate *sDate = [task.startTime copy];
    NSDate *dDate = [task.deadline copy];
    
    [tm moveTime:[Common copyTimeFromDate:time toDate:tm.today] forEvent:task];
    
    if ([task isRE])
    {
        //[_sdViewCtrler.miniMonthView refresh];
        [_abstractViewCtrler.miniMonthView refresh];
    }
    else
    {
        if (sDate != nil)
        {
            //[_sdViewCtrler.miniMonthView.calView refreshCellByDate:sDate];
            [_abstractViewCtrler.miniMonthView.calView refreshCellByDate:sDate];
            [sDate release];
        }
        
        if (dDate != nil)
        {
            //[_sdViewCtrler.miniMonthView.calView refreshCellByDate:dDate];
            [_abstractViewCtrler.miniMonthView.calView refreshCellByDate:dDate];
            [dDate release];
        }
        
        //[_sdViewCtrler.miniMonthView.calView refreshCellByDate:task.startTime];
        [_abstractViewCtrler.miniMonthView.calView refreshCellByDate:task.startTime];
    }
    
}

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
    Task *task =  [[((TaskView *)self.activeMovableView).task retain] autorelease];
    NSDate *time = [[_abstractViewCtrler getCalendarViewController].todayScheduleView getTimeSlot];
    
	if (alertVw.tag == -11000)
	{                
        [self doneMove];
        
        if (buttonIndex == 1)
        {
            [self convert2Task:task];
        }
	}
	else if (alertVw.tag == -11001)
	{
        [self doneMove];
        
        if (buttonIndex == 1)
        {
            [self changeTime:task time:time];
        }
	}
	else if (alertVw.tag == -11002)
	{
        [self doneMove];
        
        if (buttonIndex != 0)
        {
            [self convertRE2Task:buttonIndex task:task];
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
	//return [(Task *)self.activeMovableView.tag type] == TYPE_TASK;
    return [((TaskView *)self.activeMovableView).task type] == TYPE_TASK;
}

-(void)move:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super move:touches withEvent:event];
    
    //CalendarViewController *ctrler = [_sdViewCtrler getCalendarViewController];
    CalendarViewController *ctrler = [_abstractViewCtrler getCalendarViewController];
    
    [ctrler.todayScheduleView highlight:self.activeMovableView.frame];
}

-(void) endMove:(MovableView *)view
{
    //CalendarViewController *ctrler = [_sdViewCtrler getCalendarViewController];
    CalendarViewController *ctrler = [_abstractViewCtrler getCalendarViewController];
    
    self.activeMovableView = view;
    
    [self unseparate];
 
    self.activeMovableView.hidden = NO;
    
    dummyView.hidden = YES;
    
    BOOL refresh = YES;
    
    if (dummyView != nil && [dummyView superview])
    {
        Task *task =  ((TaskView *)self.activeMovableView).task;
        
        BOOL moveAsEvent = ([task isEvent] || ([task isTask] && [[Settings getInstance] movableAsEvent] == 0));
        
        BOOL convertEventIntoTask = [task isEvent] && self.activeMovableView.frame.origin.x > ctrler.calendarView.bounds.size.width + 60;
        
        if (moveInMM)
        {
            [self doTaskMovementInMM];
        }
        else if (rightMovableView != nil)
        {
            Task *destTask = ((TaskView *)rightMovableView).task;
            
            if ([task isTask] && [destTask isTask])
            {
                [[TaskManager getInstance] changeOrder:task destTask:destTask];
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
            
            NSDate *time = [ctrler.todayScheduleView getTimeSlot];

            [self changeTime:task time:time];
            
        }
        else 
        {
            refresh = NO;
        }
        
        if (!moveInMM)
        {
            [super endMove:view];
        }
    }
    
    [ctrler.todayScheduleView unhighlight];
        
    if (!moveInMM && refresh)
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
