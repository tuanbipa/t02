//
//  SmartListPlannerMovableController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 4/9/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "SmartListPlannerMovableController.h"

#import "Common.h"
#import "Task.h"

#import "TaskManager.h"

#import "MovableView.h"
#import "TaskView.h"

@implementation SmartListPlannerMovableController
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
    
//    if (dummyView != nil && [dummyView superview])
//    { 
//        Task *task = ((TaskView *) self.activeMovableView).task;
//        
//        [[task retain] autorelease];
//        
//        if (moveInMM)
//        {
//            [self doTaskMovementInMM];
//        }
//        else if (rightMovableView != nil)
//        {
//            Task *destTask = ((TaskView *)rightMovableView).task;
//            [[destTask retain] autorelease];
//            
//            [super endMove:view];
//            
//            if ([task isTask] && [destTask isTask])
//            {
//                [[TaskManager getInstance] changeOrder:task destTask:destTask];
//            }
//        }
//        else
//        {
//            [super endMove:view];
//        }
//        
//        /*
//        if (!moveInMM)
//        {
//            [super endMove:view];
//        }*/
//    }
    [super endMove:view];
    [view release];
}

@end
