//
//  CalendarPlannerMovableController.m
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 4/11/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "CalendarPlannerMovableController.h"
#import "TaskManager.h"
#import "Common.h"
#import "MovableView.h"
#import "TaskView.h"
#import "Task.h"
#import "PlannerViewController.h"
#import "PlannerBottomDayCal.h"
#import "PlannerScheduleView.h"
#import "TimeSlotView.h"
#import "PlannerCalendarLayoutController.h"
#import "SmartListViewController.h"

extern PlannerViewController *_plannerViewCtrler;

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
    
    if (!moveInSmartList && !moveInPlannerDayCal) {
        CGPoint touchPoint = [self.activeMovableView getTouchPoint];
        SmartListViewController *smartlistViewController = [_plannerViewCtrler getSmartListViewController];
        moveInSmartList = CGRectContainsPoint(smartlistViewController.view.frame, touchPoint);
    }
}

-(void) endMove:(MovableView *)view
{
    [view retain];
    
    [self unseparate];
    
    self.activeMovableView = view;
    
    self.activeMovableView.hidden = NO;
    
    dummyView.hidden = YES;

    if (moveInSmartList) {
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

#pragma mark Alert
- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertVw.tag == -11002) {
        Task *task = [[((TaskView *) self.activeMovableView).task retain] autorelease];
        [super endMove:self.activeMovableView];
        
        if (buttonIndex != 0)
        {
            [_plannerViewCtrler convertRE2Task:buttonIndex task:task];
        }
    } else if (alertVw.tag == -11000) {
        Task *task = [[((TaskView *) self.activeMovableView).task retain] autorelease];
        [super endMove:self.activeMovableView];
        
        if (buttonIndex == 1)
        {
            [_plannerViewCtrler convert2Task:task];
        }
    } else {
        [super alertView:alertVw clickedButtonAtIndex:buttonIndex];
    }
}
@end
