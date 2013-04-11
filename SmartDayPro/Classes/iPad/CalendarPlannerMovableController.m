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

@implementation CalendarPlannerMovableController

- (id)init
{
	if (self = [super init])
	{
	}
	
	return self;
}

-(void) endMove:(MovableView *)view
{
    [view retain];
    
    [self unseparate];
    
    self.activeMovableView = view;
    
    self.activeMovableView.hidden = NO;
    
    dummyView.hidden = YES;
    
    if (dummyView != nil && [dummyView superview])
    {
        //Task *task = (Task *) self.activeMovableView.tag;
        Task *task = ((TaskView *) self.activeMovableView).task;
        
        if (moveInMM)
        {
            [self doTaskMovementInMM];
        }
        else if (rightMovableView != nil)
        {
            //Task *destTask = (Task *)rightMovableView.tag;
            Task *destTask = ((TaskView *)rightMovableView).task;
            
            if ([task isTask] && [destTask isTask])
            {
                [[TaskManager getInstance] changeOrder:task destTask:destTask];
            }
            
        }
        
        if (!moveInMM)
        {
            [super endMove:view];
        }
    }
    
    [view release];
}
@end
