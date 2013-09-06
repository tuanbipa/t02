//
//  CategoryLayoutController.m
//  SmartCal
//
//  Created by Left Coast Logic on 9/25/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import "CategoryLayoutController.h"

#import "Common.h"
#import "Task.h"
#import "Project.h"

#import "TaskManager.h"

#import "TaskView.h"
#import "PlanView.h"

#import "CategoryViewController.h"
//#import "AbstractSDViewController.h"
#import "iPadViewController.h"

//extern AbstractSDViewController *_abstractViewCtrler;
extern iPadViewController *_iPadViewCtrler;

@implementation CategoryLayoutController

- (id) init
{
    if (self = [super init])
    {
    }
    
    return self;
}

- (BOOL) checkReusableView:(UIView *) view
{
	return NO;
}

- (MovableView *) layoutObject:(NSObject *) obj reusableView:(MovableView *)reusableView
{
    //TaskManager *tm = [TaskManager getInstance];
    
    MovableView *ret = nil;
    
    //CategoryViewController *ctrler = [_abstractViewCtrler getCategoryViewController];
    CategoryViewController *ctrler = [_iPadViewCtrler.activeViewCtrler getCategoryViewController];
    
    BOOL isPlan = [obj isKindOfClass:[Project class]];
    
    CGFloat indent = isPlan?0:PLAN_EXPAND_WIDTH;    
    
	CGRect lastFrame = (lastView == nil? CGRectOffset(CGRectZero, 0, TASK_PAD_HEIGHT):lastView.frame);
	
	CGRect frm = CGRectZero;
	frm.origin.y = lastFrame.origin.y + lastFrame.size.height + TASK_PAD_HEIGHT;
    frm.origin.x = 0 + indent;
    frm.size.width = self.viewContainer.bounds.size.width - indent;
    frm.size.height = TASK_HEIGHT;
    
    if (isPlan)
    {
        //frm.size.height = 40;
        
        PlanView *planView = [[PlanView alloc] initWithFrame:frm];
        //planView.tag = obj;
        planView.project = obj;
        planView.listStyle = YES;
        planView.listType = ctrler.filterType;
        
        [planView refreshExpandImage];
        
        Project *plan = (Project *)obj;
        
        [planView enableMove:!plan.isExpanded];
        
        ret = planView;
    }
    else
    {
        Task *task = (Task *)obj;
        task.listSource = SOURCE_CATEGORY;
        
        TaskView *taskView = [[TaskView alloc] initWithFrame:frm];
        //taskView.tag = obj;
        taskView.task = obj;
        taskView.listStyle = YES;
        taskView.starEnable = ([task isTask] && task.status != TASK_STATUS_DONE && ![task isShared]);
        taskView.checkEnable = !_iPadViewCtrler.inSlidingMode;
        
        [taskView refreshStarImage];
        [taskView refreshCheckImage];
        
        //[taskView enableMove:ctrler.filterType == TYPE_TASK];
        
        ret = taskView;
    }
    
    return [ret autorelease];
}

- (NSMutableArray *) getObjectList
{
    //CategoryViewController *ctrler = [_abstractViewCtrler getCategoryViewController];
    CategoryViewController *ctrler = [_iPadViewCtrler.activeViewCtrler getCategoryViewController];
    
    return ctrler.list;
}

- (BOOL) checkRemovableView:(UIView *) view
{
	if ([view isKindOfClass:[TaskView class]] || [view isKindOfClass:[PlanView class]])
	{
		return YES;
	}
    
    return NO;
}

@end
