//
//  MiniMonthMovableController.m
//  SmartCal
//
//  Created by Left Coast Logic on 5/2/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import "MiniMonthMovableController.h"

//#import "ListMovableController.h"

#import "Common.h"
#import "Settings.h"
#import "TaskManager.h"
#import "DBManager.h"
#import "Task.h"

#import "TaskView.h"
#import "PlanView.h"
#import "ContentView.h"
#import "MiniMonthView.h"
#import "MonthlyCalendarView.h"
#import "FocusView.h"

#import "NoteViewController.h"

#import "SmartDayViewController.h"
//#import "iPadSmartDayViewController.h"

#import "NoteDetailTableViewController.h"
#import "TaskDetailTableViewController.h"

#import "ScheduleView.h"
#import "CalendarViewController.h"

#import "iPadViewController.h"
#import "PlannerViewController.h"
#import "PlannerMonthView.h"
#import "PlannerBottomDayCal.h"

extern SmartDayViewController *_sdViewCtrler;
//extern AbstractSDViewController *_abstractViewCtrler;
//extern iPadSmartDayViewController *_iPadSDViewCtrler;

iPadViewController *_iPadViewCtrler;

@implementation MiniMonthMovableController

/*
- (CGRect) getMovableRect:(UIView *)view
{
    return [view.superview convertRect:view.frame toView:_abstractViewCtrler.contentView];
}
*/
- (BOOL)checkSeparate:(TaskView *)view
{
    //Task *task = (Task *) view.tag;
    Task *task = view.task;
    
    return ![task checkMustDo];
}

- (NSDate*)getDateInMonthAtDrop
{
    /*
    if ([[AbstractActionViewController getInstance] isKindOfClass:[PlannerViewController class]]) {
        PlannerMonthView *plannerMonthView = (PlannerMonthView*)[[AbstractActionViewController getInstance] getPlannerMonthCalendarView];
        return [plannerMonthView getSelectedDate];
    } else {
        return [_abstractViewCtrler.miniMonthView.calView getSelectedDate];
    }*/
    
    if (_sdViewCtrler != nil)
    {
        MiniMonthView *mmView = [_sdViewCtrler getMiniMonth];
        
        return [mmView.calView getSelectedDate];
    }
    else if (_iPadViewCtrler != nil)
    {
        PlannerMonthView *plannerMonthView = (PlannerMonthView*)[[AbstractActionViewController getInstance] getPlannerMonthCalendarView];
        
        if (plannerMonthView != nil)
        {
            return [plannerMonthView getSelectedDate];
        }
        
        MiniMonthView *mmView = [[AbstractActionViewController getInstance] getMiniMonth];
        
        return [mmView.calView getSelectedDate];
    }
    
    return nil;
}

-(void)beginMove:(MovableView *)view
{
    [super beginMove:view];
    
    moveInFocus = NO;
    moveInMM = NO;
    moveInDayCalendar = NO;
    moveInPlannerMM = NO;
    moveInPlannerDayCalendar = NO;
    
    [_iPadViewCtrler closeDetail];
}

-(void) endMove:(MovableView *)view
{
    if (moveInMM || moveInPlannerMM)
    {
        [self doTaskMovementInMM];
    }
    else if (moveInFocus)
    {
        [self doTaskMovementInFocus];
    }
    else
    {
        [super endMove:view];
    }
}

-(void)move:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (self.activeMovableView == nil)
	{
		return;
	}
    
    CGRect frm = dummyView.frame;
    
    [super move:touches withEvent:event];

    CGPoint touchPoint = [self.activeMovableView getTouchPoint];
    
    //CGPoint p = [self.activeMovableView.superview convertPoint:touchPoint toView:_abstractViewCtrler.contentView];
    CGPoint p = [self.activeMovableView.superview convertPoint:touchPoint toView:self.contentView];

    if ([self.activeMovableView isKindOfClass:[TaskView class]] && ![((TaskView *)self.activeMovableView).task isShared])
    {
        if ([[AbstractActionViewController getInstance] isKindOfClass:[PlannerViewController class]])
        {
            PlannerMonthView *plannerMonthView = (PlannerMonthView*)[[AbstractActionViewController getInstance] getPlannerMonthCalendarView];
            CGRect mmFrm = [self getMovableRect:plannerMonthView];
            
            //CGPoint touchPoint = [self.activeMovableView getTouchPoint];
            touchPoint = [self.activeMovableView getTouchPoint];
            
            //p = [self.activeMovableView.superview convertPoint:touchPoint toView:[AbstractActionViewController getInstance].contentView];
            p = [self.activeMovableView.superview convertPoint:touchPoint toView:self.contentView];
            
            moveInPlannerMM = CGRectContainsPoint(mmFrm, p);
            
            // check moving in planner day calendar
            PlannerBottomDayCal *plannerDayCal = [[AbstractActionViewController getInstance] getPlannerDayCalendarView];
            CGRect plannerDayCalFrm = [self getMovableRect:plannerDayCal];
            moveInPlannerDayCalendar = CGRectContainsPoint(plannerDayCalFrm, p);
        }
        else
        {
            MiniMonthView *mmView = [[AbstractActionViewController getInstance] getMiniMonth];
            FocusView *focusView = [[AbstractActionViewController getInstance] getFocusView];
            
            //CGRect mmFrm = [self getMovableRect:_abstractViewCtrler.miniMonthView.calView];
            
            CGRect mmFrm = [self getMovableRect:mmView.calView];
            
            //moveInMM = CGRectContainsPoint(mmFrm, p) && !_abstractViewCtrler.miniMonthView.hidden;
            
            moveInMM = CGRectContainsPoint(mmFrm, p) && !mmView.hidden;
            
            moveInFocus = NO;
            
            //if (_abstractViewCtrler.focusView != nil)
            if (focusView != nil)
            {
                //CGRect focusFrm = [self getMovableRect:_abstractViewCtrler.focusView];
                CGRect focusFrm = [self getMovableRect:focusView];
                
                //p = [self.activeMovableView.superview convertPoint:touchPoint toView:_abstractViewCtrler.contentView];
                
                p = [self.activeMovableView.superview convertPoint:touchPoint toView:self.contentView];

                moveInFocus = CGRectContainsPoint(focusFrm, p);
            }
            
            // check move in Day Calendar
            //CalendarViewController *calendarViewCtrl =  [_abstractViewCtrler getCalendarViewController];
            CalendarViewController *calViewCtrler =  [[AbstractActionViewController getInstance] getCalendarViewController];
            
            CGRect smartListFrm = [self getMovableRect:calViewCtrler.view];
            moveInDayCalendar = CGRectContainsPoint(smartListFrm, p);
        }
        
    }
    
    if (moveInMM || moveInFocus || moveInPlannerMM)
    {
        if (frm.size.width > 100)
        {
            if ([self.activeMovableView isKindOfClass:[TaskView class]])
            {
                TaskView *tv = (TaskView *)dummyView;
                tv.starEnable = NO;
                [tv hideCheckImage];
            }
                        
            [dummyView setNeedsDisplay];
        }
        
        frm.origin.x = p.x;
        frm.origin.y = p.y - (moveInMM?40:25);
        
        frm.size.width = (moveInMM?80:160);
        frm.size.height = 25;
        
        if (moveInMM)
        {
            MiniMonthView *mmView = [[AbstractActionViewController getInstance] getMiniMonth];
            
            //p = [self.activeMovableView.superview convertPoint:touchPoint toView:_abstractViewCtrler.miniMonthView];
            p = [self.activeMovableView.superview convertPoint:touchPoint toView:mmView];
            
            //[_abstractViewCtrler.miniMonthView moveToPoint:p];
            [mmView moveToPoint:p];
        }
        
        if (moveInPlannerMM)
        {
            PlannerMonthView *plannerMonthView = (PlannerMonthView*)[[AbstractActionViewController getInstance] getPlannerMonthCalendarView];
            
            p = [self.activeMovableView.superview convertPoint:touchPoint toView:plannerMonthView];
            
            [plannerMonthView highlightCellAtPoint:p];
        }
    }
    else
    {        
        if (frm.size.width <= 160)
        {
            if ([self.activeMovableView isKindOfClass:[TaskView class]])
            {
                TaskView *tv = (TaskView *) self.activeMovableView;
                
                ((TaskView *) dummyView).starEnable = tv.starEnable;
            }
            
            [dummyView setNeedsDisplay];
        }
        
        frm = [self getMovableRect:self.activeMovableView];
    }
    
    dummyView.frame = frm;    
}

- (void) changeTaskDeadline:(Task *)task
{
    DBManager *dbm = [DBManager getInstance];
    
    //Task *task = ((TaskView *) self.activeMovableView).task;
    
    if (task.original != nil && ![task isREException])
    {
        task = task.original;
    }    
    
    //NSDate *calDate = [_abstractViewCtrler.miniMonthView.calView getSelectedDate];
    NSDate *calDate = [self getDateInMonthAtDrop];
    
    //NSDate *dDate = nil;
    NSDate *deadline = task.deadline;
    
    Settings *settings = [Settings getInstance];
    
    if (deadline != nil)
    {
        //dDate = [[deadline copy] autorelease];
        deadline = [settings getWorkingEndTimeForDate:calDate];
        
        if (task.startTime != nil)
        {
            NSTimeInterval diff = [task.deadline timeIntervalSinceDate:task.startTime];
            
            task.startTime = [settings getWorkingStartTimeForDate:[deadline dateByAddingTimeInterval:-diff]];
        }
    }
    else 
    {
        deadline = [settings getWorkingEndTimeForDate:calDate];
        
        if (task.startTime != nil && [deadline compare:task.startTime] == NSOrderedAscending)
        {
            task.startTime = [settings getWorkingStartTimeForDate:deadline];
        }
    }
    
    task.deadline = deadline;
    
    [task updateTimeIntoDB:[dbm getDatabase]];
    
    /*
    if (dDate != nil)
    {
        [_abstractViewCtrler.miniMonthView.calView refreshCellByDate:dDate];
    }
    
    [_abstractViewCtrler.miniMonthView.calView refreshCellByDate:calDate];*/
    
    [[TaskManager getInstance] initSmartListData]; //refresh Must Do list
    
    //[_abstractViewCtrler reconcileItem:task reSchedule:YES]; //refresh Category module
    [[AbstractActionViewController getInstance] reconcileItem:task reSchedule:YES];
}

- (void) changeEventDate:(Task *)task
{
    //Task *task = ((TaskView *) self.activeMovableView).task;
    
    //NSDate *calDate = [_abstractViewCtrler.miniMonthView.calView getSelectedDate];
    NSDate *calDate = [self getDateInMonthAtDrop];
    
    [super endMove:self.activeMovableView];
    
    NSDate *oldDate = [[task.startTime copy] autorelease];
    
    [[TaskManager getInstance] moveTime:[Common copyTimeFromDate:oldDate toDate:calDate] forEvent:task];
    
    /*
    if ([task isADE])
    {
        [_abstractViewCtrler.miniMonthView refresh]; 
    }
    else 
    {
        [_abstractViewCtrler.miniMonthView.calView refreshCellByDate:oldDate];
        [_abstractViewCtrler.miniMonthView.calView refreshCellByDate:calDate];
    }*/
    
    //[_abstractViewCtrler reconcileItem:task reSchedule:NO]; //refresh Category module
    [[AbstractActionViewController getInstance] reconcileItem:task reSchedule:YES];
}

- (void) changeNoteDate:(Task *)task
{
    //NSDate *calDate = [_abstractViewCtrler.miniMonthView.calView getSelectedDate];
    NSDate *calDate = [self getDateInMonthAtDrop];
    
    [super endMove:self.activeMovableView];
  
    task.startTime = [Common copyTimeFromDate:task.startTime toDate:calDate];
    
    [task updateStartTimeIntoDB:[[DBManager getInstance] getDatabase]];

    //[[_abstractViewCtrler getNoteViewController] loadAndShowList];
    
    //[_abstractViewCtrler reconcileItem:task reSchedule:NO]; //refresh Category module
    [[AbstractActionViewController getInstance] reconcileItem:task reSchedule:NO];
}

- (void) doTaskMovementInFocus
{
    Task *task = ((TaskView *) self.activeMovableView).task;
    
    [[task retain] autorelease];
    
    [super endMove:self.activeMovableView];
    
    if ([task isTask])
    {
        [self changeTaskDeadline:task];
    }
    else if ([task isEvent])
    {
        [self changeEventDate:task];
    }
    else if ([task isNote])
    {
        task.startTime = [Common copyTimeFromDate:task.startTime toDate:[[TaskManager getInstance] today]];
        
        [task updateStartTimeIntoDB:[[DBManager getInstance] getDatabase]];
    }
    
    if ([task isEvent])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EventChangeNotification" object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];
        
        FocusView *focusView = [[AbstractActionViewController getInstance] getFocusView];
        
        //if ([_abstractViewCtrler.focusView checkExpanded])
        if ([focusView checkExpanded])
        {
            //[_abstractViewCtrler.focusView refreshData];
            [focusView refreshData];

            //resize calendar views
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MiniMonthResizeNotification" object:nil];
        }
    }
}

- (void) doTaskMovementInMM
{
    Settings *settings = [Settings getInstance];
    
    //NSDate *calDate = [_abstractViewCtrler.miniMonthView.calView getSelectedDate];
    NSDate *calDate = [self getDateInMonthAtDrop];
    
    Task *task = ((TaskView *) self.activeMovableView).task;
    
    if (settings.move2MMConfirmation)
    {
        if ([task isTask])
        {
            NSString *msg = [Common getCalendarDateString:calDate];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_newDeadlineText message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:_dontShowText, _okText, nil];
            
            alertView.tag = -10000;
            
            [alertView show];
            [alertView release];
            
        }
        else if ([task isEvent])
        {
            NSString *msg = [Common getCalendarDateString:calDate];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_newDateText message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:_dontShowText, _okText, nil];
            
            alertView.tag = -10001;
            
            [alertView show];
            [alertView release];
        }
        else if ([task isNote])
        {
            NSString *msg = [Common getCalendarDateString:calDate];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_newDateText message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:_dontShowText, _okText, nil];
            
            alertView.tag = -10002;
            
            [alertView show];
            [alertView release];
            
        }
    }
    else
    {
        [[task retain] autorelease];
        
        [super endMove:self.activeMovableView];

        if ([task isTask])
        {
            [self changeTaskDeadline:task];
        }
        else if ([task isEvent])
        {
            [self changeEventDate:task];
        }
        else if ([task isNote])
        {
            [self changeNoteDate:task];
        }
        
        if ([[AbstractActionViewController getInstance] isKindOfClass:[PlannerViewController class]]) {
            [[AbstractActionViewController getInstance] jumpToDate:calDate];
        } else {
            MiniMonthView *mmView = [[AbstractActionViewController getInstance] getMiniMonth];
            
            [mmView jumpToDate:calDate];
        }
    }

}

- (void)convertTaskToSTask: (Task *) task time: (NSDate *) time {
    
    // convert to STask
    [task setManual:YES];
    
    Task *copyTask = [[task copy] autorelease];
    copyTask.original = task;
    
    //[_abstractViewCtrler changeTime:copyTask time:time];
    [[AbstractActionViewController getInstance] changeTime:copyTask time:time];
}

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
    Settings *settings = [Settings getInstance];
    
    //TaskView *tv = (TaskView *) self.activeMovableView;
    
    Task *task = [[((TaskView *) self.activeMovableView).task retain] autorelease];
    
    [super endMove:self.activeMovableView];
    
    MiniMonthView *mmView = [[AbstractActionViewController getInstance] getMiniMonth];
    
    //NSDate *calDate = [_abstractViewCtrler.miniMonthView.calView getSelectedDate];
    //NSDate *calDate = [mmView.calView getSelectedDate];
    
    //NSDate *visitDate = nil;
    
    //BOOL needEdit = NO;

	if (alertVw.tag == -10000)
	{
        switch (buttonIndex) 
        {
            /*
            case 0: //Edit
            {
                [self changeTaskDeadline:task];
                
                needEdit = YES;
            }
                break;*/
            case 0: //Don't Show
            {
                settings.move2MMConfirmation = NO;
                [settings saveHintDict];
            }
                //break;
                
            case 1: //OK
                [self changeTaskDeadline:task];
                break;
        }
        
	}
	else if (alertVw.tag == -10001)
	{
        switch (buttonIndex) 
        {
                /*
            case 0: //Edit
            {
                [self changeEventDate:task];
                
                needEdit = YES;
            }
                break;*/
            case 0: //Don't Show
            {
                settings.move2MMConfirmation = NO;
                [settings saveHintDict];
            }
                //break;
            case 1: //OK
                [self changeEventDate:task];
                break;
        }
        
    }
	else if (alertVw.tag == -10002)
	{
        switch (buttonIndex) 
        {
                /*
            case 0: //Edit
            {
                [self changeNoteDate:task];
                
                needEdit = YES;
            }
                break;*/
            case 0: //Don't Show
            {
                settings.move2MMConfirmation = NO;
                [settings saveHintDict];
            }
                //break;
                
            case 1: //OK
            {
                [self changeNoteDate:task];
            }
                break;
        }
    }
    else if (alertVw.tag == -11001)
    {
        //CalendarViewController *ctrler = [_abstractViewCtrler getCalendarViewController];
        CalendarViewController *ctrler = [[AbstractActionViewController getInstance] getCalendarViewController];
        
        if (buttonIndex == 1)
        {
            NSDate *time = [[[ctrler.todayScheduleView getTimeSlot] retain] autorelease];
            
            [self convertTaskToSTask:task time:time];
        }
        [ctrler.todayScheduleView unhighlight];
    }
    
    if (moveInMM)
    {
        //MiniMonthView *mmView = [[AbstractActionViewController getInstance] getMiniMonth];
        
        //[_abstractViewCtrler.miniMonthView jumpToDate:(visitDate != nil?visitDate:calDate)];
        //[mmView jumpToDate:(visitDate != nil?visitDate:calDate)];
        
        NSDate *calDate = [self getDateInMonthAtDrop];
        
        [mmView jumpToDate:calDate];

        /*
        if (visitDate != nil)
        {
            [_sdViewCtrler showCalendarView];    
        }
        */
        /*
        if (needEdit)
        {
            if (task.original != nil && ![task isREException])
            {
                task = task.original;
            }
        
            Task *taskCopy = [[task copy] autorelease];
            
            taskCopy.listSource = SOURCE_CATEGORY;//free task -> refresh in all views
            
            CGRect frm = [_abstractViewCtrler.miniMonthView.calView getRectOfSelectedCellInView:_abstractViewCtrler.contentView];
            
            [_abstractViewCtrler editItem:taskCopy inRect:frm];
        }
        else*/
        {
            if ([task isEvent])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"EventChangeNotification" object:nil];
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];
            }
        }
    }
}

@end
