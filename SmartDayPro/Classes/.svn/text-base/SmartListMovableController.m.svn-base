//
//  SmartListMovableController.m
//  SmartCal
//
//  Created by Trung Nguyen on 5/20/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "SmartListMovableController.h"

#import "Common.h"

#import "TaskView.h"
#import "MiniMonthView.h"
#import "MonthlyCalendarView.h"

#import "TaskManager.h"
#import "DBManager.h"
#import "Task.h"

#import "SmartListLayoutController.h"

#import "SmartListViewController.h"
//#import "SmartDayPageViewController.h"
//#import "ListViewController.h"

extern SmartListViewController *_smartListViewCtrler;

@implementation SmartListMovableController

- (id)init
{
	if (self = [super init])
	{
	}
	
	return self;
}

-(void) beginMove:(MovableView *)view
{
    if ([[TaskManager getInstance] taskTypeFilter] != TASK_FILTER_DONE)
    {
        [super beginMove:view];
    }
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
