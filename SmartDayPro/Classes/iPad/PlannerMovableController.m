//
//  PlannerMovable.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 4/9/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "PlannerMovableController.h"

#import "Common.h"
#import "Settings.h"
#import "TaskManager.h"
#import "DBManager.h"
#import "Task.h"

#import "TaskView.h"
#import "PlanView.h"
#import "ContentView.h"
#import "PlannerView.h"
#import "PlannerMonthView.h"

#import "SmartDayViewController.h"
#import "iPadSmartDayViewController.h"
#import "PlannerViewController.h"

#import "NoteDetailTableViewController.h"
#import "TaskDetailTableViewController.h"
#import "PlannerBottomDayCal.h"
#import "PlannerScheduleView.h"
#import "PlannerCalendarLayoutController.h"
#import "TimeSlotView.h"

extern AbstractSDViewController *_abstractViewCtrler;

extern PlannerViewController *_plannerViewCtrler;

@implementation PlannerMovableController

- (id) init
{
    if (self = [super init])
    {
        self.contentView = _plannerViewCtrler.contentView;
    }
    
    return self;
}

-(void)move:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (self.activeMovableView == nil)
	{
		return;
	}
    
    CGRect frm = dummyView.frame;
    
    [super move:touches withEvent:event];
    
    CGRect mmFrm = [self getMovableRect:_plannerViewCtrler.plannerView.monthView];
    
    //printf("mm frame - x:%f, y:%f, w:%f, h:%f\n", mmFrm.origin.x, mmFrm.origin.y, mmFrm.size.width, mmFrm.size.height);
    
    CGPoint touchPoint = [self.activeMovableView getTouchPoint];
    
    CGPoint tp = [self.activeMovableView.superview convertPoint:touchPoint toView:_plannerViewCtrler.contentView];
    
    //printf("touch point - x:%f, y:%f\n", tp.x, tp.y);
    
    moveInMM = CGRectContainsPoint(mmFrm, tp);
    
    if (moveInMM)
    {
        if (frm.size.width > 100)
        {
            if ([self.activeMovableView isKindOfClass:[TaskView class]])
            {
                ((TaskView *)dummyView).starEnable = NO;
            }
            
            [dummyView setNeedsDisplay];
        }
        
        frm.origin.x = tp.x;
        frm.origin.y = tp.y - 40;
        
        frm.size.width = 80;
        frm.size.height = 25;
        
        //highlight cell at point
        [_plannerViewCtrler.plannerView moveToPoint:tp];
    }
    else
    {
        // check move in planner day cal
        CGRect dayCalFrm = [self getMovableRect:_plannerViewCtrler.plannerBottomDayCal];
        //tp = [self.activeMovableView.superview convertPoint:touchPoint toView:_plannerViewCtrler.contentView];
        moveInPlannerDayCal = CGRectContainsPoint(dayCalFrm, tp);
        
        if (moveInPlannerDayCal) {
            /*if (frm.size.width > 100)
            {
                if ([self.activeMovableView isKindOfClass:[TaskView class]])
                {
                    ((TaskView *)dummyView).starEnable = NO;
                }
                
                [dummyView setNeedsDisplay];
            }
            
            frm.origin.x = tp.x;
            frm.origin.y = tp.y - 40;
            
            frm.size.width = 80;
            frm.size.height = 25;*/
            
            CGRect rect = [self.activeMovableView.superview convertRect:self.activeMovableView.frame toView:_plannerViewCtrler.plannerBottomDayCal.plannerScheduleView];
            [_plannerViewCtrler.plannerBottomDayCal.plannerScheduleView highlight:rect];
        } else {
        
            if (frm.size.width < 100)
            {
                if ([self.activeMovableView isKindOfClass:[TaskView class]])
                {
                    TaskView *tv = (TaskView *) self.activeMovableView;
                    
                    ((TaskView *) dummyView).starEnable = tv.starEnable;
                }
                
                [dummyView setNeedsDisplay];
            }
            
            //frm = [self getMovableRect:self.activeMovableView];
        }
        frm = [self getMovableRect:self.activeMovableView];
    }
    
    dummyView.frame = frm;
}

-(void) endMove:(MovableView *)view
{
    if (moveInMM)
    {
        [self doTaskMovementInMM];
    } else if (moveInPlannerDayCal) {
        [self doTaskMovementInPlannerDayCal];
    }
    else
    {
        [super endMove:self.activeMovableView];
    }
}

#pragma mark Common methods

- (BOOL)checkSeparate:(TaskView *)view
{
    //Task *task = (Task *) view.tag;
    Task *task = view.task;
    
    return ![task checkMustDo];
}

- (void)resizeFrameDuringMoving: (CGPoint) tp {
    CGRect frm = dummyView.frame;
    if (frm.size.width > 100)
    {
        if ([self.activeMovableView isKindOfClass:[TaskView class]])
        {
            ((TaskView *)dummyView).starEnable = NO;
        }
        
        [dummyView setNeedsDisplay];
    }
    
    frm.origin.x = tp.x;
    frm.origin.y = tp.y - 40;
    
    frm.size.width = 80;
    frm.size.height = 25;
}

- (void) doTaskMovementInMM
{
    NSDate *calDate = [_plannerViewCtrler.plannerView.monthView getSelectedDate];
    
    if (calDate == nil) {
        [super endMove:self.activeMovableView];
        return;
    }
    Task *task = ((TaskView *) self.activeMovableView).task;
    
    if ([task isTask])
    {
        NSString *msg = [NSString stringWithFormat:@"%@: %@", _newDeadlineCreatedText, [Common getCalendarDateString:calDate]];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_warningText message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:_editText, _okText, nil];
        
        alertView.tag = -10000;
        
        [alertView show];
        [alertView release];
        
    } else if ([task isEvent]) {
        
        NSString *msg = [NSString stringWithFormat:@"%@: %@", _newDateIsText, [Common getCalendarDateString:[Common copyTimeFromDate:task.startTime toDate:calDate]]];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_warningText message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:_editText, _okText, nil];
        
        alertView.tag = -10001;
        
        [alertView show];
        [alertView release];
    }
}

- (void)doTaskMovementInPlannerDayCal {
    Task *task = [[((TaskView *) self.activeMovableView).task retain] autorelease];
    
    if ([task isEvent]) { // change evnt datetime
        [self changeEventDateTime:task];
    } else {
        // convert task to STask
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_warningText  message:_convertIntoSTaskConfirmation delegate:self cancelButtonTitle:_cancelText otherButtonTitles:_okText, nil];
        
        alertView.tag = -11001;
        
        [alertView show];
        [alertView release];
    }
    //[_plannerViewCtrler.plannerBottomDayCal.plannerScheduleView unhighlight];
}

- (void) changeTaskDeadline:(Task *)task
{
    DBManager *dbm = [DBManager getInstance];
    
    if (task.original != nil)
    {
        task = task.original;
    }
    
    NSDate *calDate = [_plannerViewCtrler.plannerView.monthView getSelectedDate];
    
    NSDate *dDate = nil;
    NSDate *deadline = task.deadline;
    
    if (deadline != nil)
    {
        dDate = [[deadline copy] autorelease];
        
        deadline = [[Settings getInstance] getWorkingEndTimeForDate:calDate];
    }
    else
    {
        deadline = [[Settings getInstance] getWorkingEndTimeForDate:calDate];
    }
    
    task.deadline = deadline;
    
    [task updateDeadlineIntoDB:[dbm getDatabase]];
    
    [_plannerViewCtrler.plannerView.monthView refreshCellByDate:calDate];
    if (dDate != nil && [Common compareDateNoTime:dDate withDate:calDate] != NSOrderedSame) {
        // refresh old cell
        [_plannerViewCtrler.plannerView.monthView refreshCellByDate:dDate];
    }
    [_plannerViewCtrler.plannerView.monthView collapseExpandByDate:calDate];
    [_plannerViewCtrler.plannerView.monthView highlightCellOnDate:calDate];
    
    [[TaskManager getInstance] initSmartListData]; //refresh Must Do list
    
}

- (void) changeEventDate:(Task *)task
{
    //Task *task = ((TaskView *) self.activeMovableView).task;
    
    NSDate *calDate = [_plannerViewCtrler.plannerView.monthView getSelectedDate];
    
    NSDate *oldDate = [[task.startTime copy] autorelease];
    
    [[TaskManager getInstance] moveTime:[Common copyTimeFromDate:oldDate toDate:calDate] forEvent:task];
    
    //[_plannerViewCtrler.plannerView.monthView refreshCellByDate:calDate];
    BOOL expanded = [_plannerViewCtrler.plannerView.monthView collapseExpandByDate:calDate];
    if (!expanded) {
        [_plannerViewCtrler.plannerBottomDayCal refreshLayout];
    }
}

- (void)changeEventDateTime: (Task *) task {
    // if this is a task, will be convert to STask
    
    // calculate date
    CGPoint touchPoint = [self.activeMovableView getTouchPoint];

    if ([task isTask]) {
        // convert to STask
        //unichar rectangleChar = 0x25A2;
        task.name = [[NSString stringWithFormat:@"%C ", STASK_CHARACTER] stringByAppendingString:task.name];
        [task setManual:YES];
        
        touchPoint = [self.activeMovableView.superview convertPoint:touchPoint toView:_plannerViewCtrler.plannerBottomDayCal.plannerScheduleView];
    }
    
    NSDate *startDate = [[_plannerViewCtrler.plannerBottomDayCal.calendarLayoutController.startDate copy] autorelease];
    
    CGFloat dayWidth = (_plannerViewCtrler.plannerBottomDayCal.bounds.size.width - TIMELINE_TITLE_WIDTH)/7;
    NSInteger dayNumber = (touchPoint.x-TIMELINE_TITLE_WIDTH)/dayWidth;
    
    TimeSlotView *timeSlot = [_plannerViewCtrler.plannerBottomDayCal.plannerScheduleView getTimeSlot];
    
    startDate = [Common copyTimeFromDate:timeSlot.time toDate:startDate];
    NSDate *toDate = [Common dateByAddNumDay:dayNumber toDate:startDate];
    
    Task *copyTask = [[task copy] autorelease];
    copyTask.original = task;
    [_plannerViewCtrler.plannerBottomDayCal.plannerScheduleView unhighlight];
    //[_plannerViewCtrler changeTime:task time:toDate];
    [_plannerViewCtrler changeTime:copyTask time:toDate];
    
    [_plannerViewCtrler.plannerBottomDayCal refreshLayout];
}

#pragma mark Alert delegate
- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
    TaskView *tv = (TaskView *) self.activeMovableView;
    
    Task *task = [[((TaskView *) self.activeMovableView).task retain] autorelease];
    
    //[super endMove:self.activeMovableView];
    
    NSDate *calDate = [_plannerViewCtrler.plannerView.monthView getSelectedDate];
    
    //NSDate *visitDate = nil;
    
    BOOL needEdit = NO;
    
	if (alertVw.tag == -10000)
	{
        switch (buttonIndex)
        {
            case 0: //Edit
            {
                [self changeTaskDeadline:task];
                
                needEdit = YES;
            }
                break;
                
            case 1: //OK
                [self changeTaskDeadline:task];
                break;
        }
        
	} else if (alertVw.tag == -10001)
	{
        switch (buttonIndex)
        {
            case 0: //Edit
            {
                [self changeEventDate:task];
                
                needEdit = YES;
            }
                break;
            case 1: //OK
                [self changeEventDate:task];
                break;
        }
        
    } else if (alertVw.tag == -11001)
	{
        if (buttonIndex == 1)
        {
            [self changeEventDateTime: task];
        }
	}
    
    if (moveInMM)
    {
        if (calDate != nil) {
            [_abstractViewCtrler jumpToDate:calDate];
        }
        
        if (needEdit)
        {
            if (task.original != nil && ![task isREException])
            {
                task = task.original;
            }
            
            Task *taskCopy = [[task copy] autorelease];
            
            taskCopy.listSource = SOURCE_CATEGORY;
            
            [_plannerViewCtrler editItem:task inView:tv];
        }
    }
    
    [super endMove:self.activeMovableView];
}
@end
