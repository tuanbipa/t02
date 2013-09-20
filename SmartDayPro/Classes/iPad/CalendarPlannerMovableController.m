//
//  CalendarPlannerMovableController.m
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 4/11/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "CalendarPlannerMovableController.h"
//#import "TaskManager.h"
#import "Common.h"
#import "MovableView.h"
#import "TaskView.h"
//#import "Task.h"
#import "PlannerViewController.h"
#import "PlannerBottomDayCal.h"
#import "PlannerScheduleView.h"
#import "TimeSlotView.h"
#import "PlannerCalendarLayoutController.h"
#import "SmartListViewController.h"

@implementation CalendarPlannerMovableController

- (id)init
{
	if (self = [super init])
	{
	}
	
	return self;
}

-(void)move:(NSSet *)touches withEvent:(UIEvent *)event
{
    moveInSmartList = NO;
    [super move:touches withEvent:event];
    
    if (moveInPlannerDayCalendar) {
        // hilight time slot
        PlannerBottomDayCal *plannerDayCal = [[AbstractActionViewController getInstance] getPlannerDayCalendarView];
        
        [plannerDayCal.plannerScheduleView highlight:self.activeMovableView.frame];
    } else {
        PlannerBottomDayCal *plannerDayCal = [[AbstractActionViewController getInstance] getPlannerDayCalendarView];
        [plannerDayCal.plannerScheduleView unhighlight];
        
        // check move in SmartList
        if (!moveInPlannerMM) {
            CGPoint touchPoint = [self.activeMovableView getTouchPoint];
            SmartListViewController *smartlistViewController = [[AbstractActionViewController getInstance] getSmartListViewController];
            
            touchPoint = [self.activeMovableView.superview convertPoint:touchPoint toView:smartlistViewController.view];
            moveInSmartList = CGRectContainsPoint(smartlistViewController.view.frame, touchPoint);
        }
    }
}

-(void) endMove:(MovableView *)view
{
    [view retain];
    
    [self unseparate];
    
    self.activeMovableView = view;
    
    self.activeMovableView.hidden = NO;
    
    dummyView.hidden = YES;

    if (moveInPlannerDayCalendar) {
        [self doTaskMovementInPlannerDayCal];
    } else if (moveInSmartList) {
        Task *task = [((TaskView *) self.activeMovableView).task retain];
        if ([task isREInstance])
        {
            NSString *mss = [task isManual] ? _convertATaskIntoTaskConfirmation : _convertREIntoTaskConfirmation;
            NSString *headMss = [task isManual] ? _convertATaskIntoTaskHeader : _warningText;
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:headMss  message:mss delegate:self cancelButtonTitle:_cancelText otherButtonTitles:_onlyInstanceText, _allFollowingText, nil];
            
            alertView.tag = -11002;
            
            [alertView show];
            [alertView release];
            
        }
        else
        {
            NSString *mss = [task isManual] ? _convertATaskIntoTaskConfirmation : _convertIntoEventConfirmation;
            NSString *headMss = [task isManual] ? _convertATaskIntoTaskHeader : _warningText;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:headMss  message:mss delegate:self cancelButtonTitle:_cancelText otherButtonTitles:_okText, nil];
            
            alertView.tag = -11000;
            
            [alertView show];
            [alertView release];
        }
        [task release];
    } else {
        [super endMove:view];
    }
    [view release];
}

#pragma mark Actions

- (void)doTaskMovementInPlannerDayCal {
    Task *task = [[((TaskView *) self.activeMovableView).task retain] autorelease];
    
    [self changeEventDateTime:task];
    [super endMove:self.activeMovableView];
}

- (void)changeEventDateTime: (Task *) task {
    
    // calculate date
    CGPoint touchPoint = [self.activeMovableView getTouchPoint];
    
    PlannerBottomDayCal *plannerDayCal = [[AbstractActionViewController getInstance] getPlannerDayCalendarView];
    
    NSDate *startDate = [[plannerDayCal.calendarLayoutController.startDate copy] autorelease];
    
    CGFloat dayWidth = (plannerDayCal.bounds.size.width - TIMELINE_TITLE_WIDTH)/7;
    NSInteger dayNumber = (touchPoint.x-TIMELINE_TITLE_WIDTH)/dayWidth;
    
    TimeSlotView *timeSlot = [plannerDayCal.plannerScheduleView getTimeSlot];
    
    startDate = [Common copyTimeFromDate:[timeSlot getTime] toDate:startDate];
    NSDate *toDate = [Common dateByAddNumDay:dayNumber toDate:startDate];
    
    Task *copyTask = [[task copy] autorelease];
    /*if ([task isTask]) { // for only convert task -> event
        copyTask.original = task;
    }*/
    
    [plannerDayCal.plannerScheduleView unhighlight];
    [[AbstractActionViewController getInstance] changeTime:copyTask time:toDate];
}

#pragma mark Alert
- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertVw.tag == -11002) {
        Task *task = [[((TaskView *) self.activeMovableView).task retain] autorelease];
        [super endMove:self.activeMovableView];
        
        if (buttonIndex != 0)
        {
            [[AbstractActionViewController getInstance] convertRE2Task:buttonIndex task:task];
        }
    } else if (alertVw.tag == -11000) {
        Task *task = [[((TaskView *) self.activeMovableView).task retain] autorelease];
        [super endMove:self.activeMovableView];
        
        if (buttonIndex == 1)
        {
            [[AbstractActionViewController getInstance] convert2Task:task];
        }
    } else {
        [super alertView:alertVw clickedButtonAtIndex:buttonIndex];
    }
}
@end
