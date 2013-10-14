//
//  MiniMonthMovableController.h
//  SmartCal
//
//  Created by Left Coast Logic on 5/2/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

//#import "MovableController.h"
#import "DummyMovableController.h"

#import "MovableView.h"

@class Task;

@interface MiniMonthMovableController : DummyMovableController
{
    //MovableView *dummyView;
    
    BOOL moveInMM;
    
    BOOL moveInFocus;
    
    BOOL moveInDayCalendar;
    
    BOOL moveInPlannerMM;
    
    BOOL moveInPlannerDayCalendar;
}

- (void) doTaskMovementInMM;
- (void) doTaskMovementInFocus;
- (void)convertTaskToSTask: (Task *) task time: (NSDate *) time;

@end
