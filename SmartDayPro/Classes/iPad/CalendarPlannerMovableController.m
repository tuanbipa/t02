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

extern PlannerViewController *_plannerViewCtrler;

@implementation CalendarPlannerMovableController

- (id)init
{
	if (self = [super init])
	{
	}
	
	return self;
}

//-(void)move:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super move:touches withEvent:event];
//    [_plannerViewCtrler.plannerBottomDayCal.plannerScheduleView highlight:self.activeMovableView.frame];
//}

-(void) endMove:(MovableView *)view
{
    [view retain];
    
    [self unseparate];
    
    self.activeMovableView = view;
    
    self.activeMovableView.hidden = NO;
    
    dummyView.hidden = YES;

    [super endMove:view];
    [view release];
}


@end
