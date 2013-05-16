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
    
//    if (dummyView != nil && [dummyView superview])
//    {
//        //Task *task = (Task *) self.activeMovableView.tag;
//        Task *task = ((TaskView *) self.activeMovableView).task;
//        
//        if (moveInMM)
//        {
//            [self doTaskMovementInMM];
//        } else {
//            // calculate date
//            CGPoint touchPoint = [self.activeMovableView getTouchPoint];
//            
//            NSDate *startDate = [[_plannerViewCtrler.plannerBottomDayCal.calendarLayoutController.startDate copy] autorelease];
//            
//            CGFloat dayWidth = (_plannerViewCtrler.plannerBottomDayCal.bounds.size.width - TIMELINE_TITLE_WIDTH)/7;
//            CGFloat dayNumber = (touchPoint.x-TIMELINE_TITLE_WIDTH)/dayWidth;
//            
//            // if not move out calendar
//            if (dayNumber > 0 && dayNumber < 7) {
//                TimeSlotView *timeSlot = [_plannerViewCtrler.plannerBottomDayCal.plannerScheduleView getTimeSlot];
//                
//                startDate = [Common copyTimeFromDate:timeSlot.time toDate:startDate];
//                NSInteger num = dayNumber;
//                NSDate *toDate = [Common dateByAddNumDay:num toDate:startDate];
//                [self changeTime:task time:toDate];
//                
//                [_plannerViewCtrler.plannerBottomDayCal refreshLayout];
//            }            
//            
//        }
//        
//        
//        if (!moveInMM)
//        {
//            [super endMove:view];
//        }
//    }
//    
//    [_plannerViewCtrler.plannerBottomDayCal.plannerScheduleView unhighlight];
    [super endMove:view];
    [view release];
}
@end
