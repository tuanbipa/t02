//
//  PlannerMovable.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 4/9/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

//#import "DummyMovableController.h"
#import "PlannerTaskMovableController.h"

//@interface PlannerMovableController : DummyMovableController
@interface PlannerMovableController : PlannerTaskMovableController
{
    //BOOL moveInMM;
    //BOOL moveInPlannerDayCal;
}

- (void) doTaskMovementInMM;

@end
