//
//  CategoryMovableController.m
//  SmartCal
//
//  Created by Left Coast Logic on 6/27/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import "CategoryMovableController.h"

#import "Common.h"
#import "Task.h"
#import "Project.h"
#import "TaskManager.h"
#import "DBManager.h"
#import "ProjectManager.h"
#import "Settings.h"

#import "MovableView.h"
#import "PlanView.h"
#import "TaskView.h"
#import "ContentScrollView.h"
#import "CategoryViewController.h"

#import "AbstractSDViewController.h"
#import "iPadSmartDayViewController.h"
#import "PlannerViewController.h"
#import "PlannerBottomDayCal.h"
#import "PlannerScheduleView.h"
#import "CalendarViewController.h"
#import "ScheduleView.h"

extern AbstractSDViewController *_abstractViewCtrler;
extern iPadSmartDayViewController *_iPadSDViewCtrler;

@interface CategoryMovableController ()

@end

@implementation CategoryMovableController

-(void) beginMove:(MovableView *)view
{
    [super beginMove:view];
}

- (BOOL) canSeparate
{
    CategoryViewController *ctrler = [_abstractViewCtrler getCategoryViewController];
    
    return ctrler.filterType == TYPE_TASK;
}

- (void) separateFrame:(BOOL) needSeparate
{
	if (rightMovableView != nil)
	{
		rightMovableView.frame = CGRectOffset(rightMovableView.frame, 0, needSeparate?SEPARATE_OFFSET:-SEPARATE_OFFSET);
	}
	
	if (leftMovableView != nil)
	{
		leftMovableView.frame = CGRectOffset(leftMovableView.frame, 0, needSeparate?-SEPARATE_OFFSET:SEPARATE_OFFSET);
	}
}

- (void) animateRelations
{
    if (moveInFocus || moveInDayCalendar || moveInMM || moveInPlannerMM || moveInPlannerDayCalendar)
    {
        [self unseparate];
        
        if (onMovableView != nil)
        {
            [self unzoom:onMovableView];
        }
        
        return;
    }
    
    MovableView *rightView = nil;
    MovableView *leftView = nil;
    MovableView *onView = nil;
    
    UIView *container = [self.activeMovableView superview];
    
    CGRect frm = self.activeMovableView.frame;
    
    for (UIView *checkView in container.subviews)
    {
        if (checkView == self.activeMovableView || ![checkView isKindOfClass:[MovableView class]])
        {
            continue;
        }
        
        CGRect rect = checkView.frame;
        
        if (CGRectIntersectsRect(frm, rect))
        {
            if (([self.activeMovableView isKindOfClass:[TaskView class]] && [checkView isKindOfClass:[TaskView class]] && ![((TaskView *)checkView).task isShared]) ||
                ([self.activeMovableView isKindOfClass:[PlanView class]] && [checkView isKindOfClass:[PlanView class]]))
            {
                leftView = nil;
                rightView = checkView;
                
                onView = nil;
                
            }
            else if ([self.activeMovableView isKindOfClass:[TaskView class]] && [checkView isKindOfClass:[PlanView class]] && (((TaskView *)self.activeMovableView).task).project != ((PlanView *)checkView).project.primaryKey)
            {
                onView = checkView;
                
                leftView = nil;
                rightView = nil;
                
            }
            
            break;
        }
    }
    
    if ([self.activeMovableView isKindOfClass:[TaskView class]])
    {
        Task *item = ((TaskView *) self.activeMovableView).task;
        
        if ([item isNote] || [item isEvent])
        {
            //don't allow to separate Notes and Events
            leftView = nil;
            rightView = nil;
        }
        
        if ([item isShared])
        {
            onView = nil;
            
            if (rightView != nil)
            {
                Task *task = ((TaskView *) rightView).task;
                
                if (task.project != item.project)
                {
                    rightView = nil;
                }
            }
        }
    }
    
    if (onView != nil && [onView isKindOfClass:[PlanView class]])
    {
        Project *prj = ((PlanView *) onView).project;
        
        if ([prj isShared])
        {
            onView = nil;
        }
    }
    
    [self zoom:onView];
    
    [self separate:rightView fromLeft:leftView];
}

-(void)move:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [super move:touches withEvent:event];
    
    //Task *item = ((TaskView *) self.activeMovableView).task;
    UIView *activeView = self.activeMovableView;
    
    if ([activeView isKindOfClass:[TaskView class]]) {
        
        Task *item = ((TaskView *) self.activeMovableView).task;
        
        if ([item isTask]) {
           
            if ([[AbstractActionViewController getInstance] isKindOfClass:[PlannerViewController class]]) {
                PlannerBottomDayCal *plannerDayCal = (PlannerBottomDayCal*)[[AbstractActionViewController getInstance] getPlannerDayCalendarView];
                CGRect rect = [self.activeMovableView.superview convertRect:self.activeMovableView.frame toView:plannerDayCal.plannerScheduleView];
                if (moveInPlannerDayCalendar) {
                    [plannerDayCal.plannerScheduleView highlight:rect];
                } else {
                    [plannerDayCal.plannerScheduleView unhighlight];
                }
                
            } else {
                
                
                CalendarViewController *ctrler = [_abstractViewCtrler getCalendarViewController];
                if (moveInDayCalendar) {
                    
                    CGRect rect = [self.activeMovableView.superview convertRect:self.activeMovableView.frame toView:ctrler.todayScheduleView];
                    [ctrler.todayScheduleView highlight:rect];
                } else {
                    [ctrler.todayScheduleView unhighlight];
                }
            }
        }
    }
}

-(void) endMove:(MovableView *)view
{
    //TaskManager *tm = [TaskManager getInstance];
    DBManager *dbm = [DBManager getInstance];
    ProjectManager *pm = [ProjectManager getInstance];
    
    self.activeMovableView = view;
    
    [self unseparate];
    
    self.activeMovableView.hidden = NO;
    
    dummyView.hidden = YES;
    
    BOOL refresh = NO;
    
    //Task *item = ((TaskView *) self.activeMovableView).task;
    
    if (!moveInMM && !moveInFocus && !moveInPlannerDayCalendar && !moveInPlannerMM && !moveInDayCalendar)
    {
        CGRect frm = dummyView.frame;
        
        frm.size.width = 20;

        if (_iPadSDViewCtrler != nil && [dummyView isKindOfClass:[TaskView class]] && [((TaskView *)dummyView).task isNote] && [_iPadSDViewCtrler checkRect:frm inModule:0])
        {
            [_iPadSDViewCtrler createTaskFromNote:((TaskView *)dummyView).task];
        }
        else
        {
            if ([self.activeMovableView isKindOfClass:[TaskView class]])
            {
                if (onMovableView != nil && [onMovableView isKindOfClass:[PlanView class]])
                {
                    [_iPadSDViewCtrler changeTask:((TaskView *)self.activeMovableView).task toProject:((PlanView *)onMovableView).project.primaryKey];
                    
                    refresh = YES;
                }
                else if (rightMovableView != nil)
                {
                    Task *srcTask = ((TaskView *)self.activeMovableView).task;
                    Task *destTask = ((TaskView *)rightMovableView).task;
                    
                    BOOL catChange = srcTask.project != destTask.project;
                    
                    if (catChange)
                    {
                        srcTask.project = destTask.project;
                        
                        [srcTask updateProjectIntoDB:[dbm getDatabase]];
                    }
                    
                    [[TaskManager getInstance] changeOrder:srcTask destTask:destTask];
                    
                    if (catChange)
                    {
                        if ([srcTask isTask] || [srcTask isNote])
                        {
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];
                        }
                        else if ([srcTask isEvent])
                        {
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"EventChangeNotification" object:nil];
                        }
                    }
                    
                    refresh = YES;
                }
            }
            else if ([self.activeMovableView isKindOfClass:[PlanView class]])
            {
                if (rightMovableView != nil && [rightMovableView isKindOfClass:[PlanView class]])
                {
                    Project *plan1 = ((PlanView *) self.activeMovableView).project;
                    Project *plan2 = ((PlanView *) rightMovableView).project;
                    
                    [pm changeOrder:plan1 destPrj:plan2];
                    
                    refresh = YES;
                }
                else
                {
                    [super endMove:view];
                }
            }
        }
    }
    else
    {
        BOOL convertATask = NO;
        if ([activeMovableView isKindOfClass:[TaskView class]]) {
            Task *item = ((TaskView *) self.activeMovableView).task;
            
            if ([item isTask] && (moveInDayCalendar || moveInPlannerDayCalendar)) {
                [self doMoveTaskInDayCalendar];
                convertATask = YES;
            }
        }
        
        if (!convertATask) {
            [super endMove:view];
        }
    }
    
    if (refresh)
    {
        CategoryViewController *ctrler = [_abstractViewCtrler getCategoryViewController];
        [ctrler loadAndShowList];
    }
}

@end
