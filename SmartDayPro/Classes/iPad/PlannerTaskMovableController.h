//
//  PlannerTaskMovableController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 7/2/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "DummyMovableController.h"

@interface PlannerTaskMovableController : DummyMovableController
{
    BOOL moveInMM;
    BOOL moveInPlannerDayCal;
}

@property (nonatomic, assign) UITableView *listTableView;

@end
