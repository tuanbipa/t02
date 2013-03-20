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

extern AbstractSDViewController *_abstractViewCtrler;

@interface CategoryMovableController ()

@end

@implementation CategoryMovableController

-(void) beginMove:(MovableView *)view
{
    [super beginMove:view];
}

- (void) animateRelations
{
    MovableView *rightView = nil;
    MovableView *leftView = nil;
    MovableView *onView = nil;
    
    UIView *container = [self.activeMovableView superview];
    
    CGRect frm = [self.activeMovableView.superview convertRect:self.activeMovableView.frame toView:container];
    
    for (UIView *checkView in container.subviews)
    {
        if (CGRectIntersectsRect(checkView.frame, frm))
        {
            if (([self.activeMovableView isKindOfClass:[TaskView class]] && [checkView isKindOfClass:[TaskView class]]) ||
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
        
        if (([self.activeMovableView isKindOfClass:[TaskView class]] && [checkView isKindOfClass:[TaskView class]]) ||
            ([self.activeMovableView isKindOfClass:[PlanView class]] && [checkView isKindOfClass:[PlanView class]]))
        {
            leftView = checkView;
        }
        
    }
    
    [self zoom:onView];
    
    if ([self canSeparate])
    {
        [self separate:rightView fromLeft:leftView];
    }
}

-(void) endMove:(MovableView *)view
{
    TaskManager *tm = [TaskManager getInstance];
    DBManager *dbm = [DBManager getInstance];
    ProjectManager *pm = [ProjectManager getInstance];
    
    self.activeMovableView = view;
    
    [self unseparate];
    
    self.activeMovableView.hidden = NO;
    
    dummyView.hidden = YES;
    
    BOOL refresh = NO;
    
    if (!moveInMM)
    {
        if ([self.activeMovableView isKindOfClass:[TaskView class]])
        {
            if (onMovableView != nil && [onMovableView isKindOfClass:[PlanView class]])
            {
                [tm changeTask:((TaskView *)self.activeMovableView).task toProject:((PlanView *)onMovableView).project.primaryKey];
                
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
        }
    }

    [super endMove:view];
    
    if (refresh)
    {
        CategoryViewController *ctrler = [_abstractViewCtrler getCategoryViewController];
        [ctrler loadAndShowList];
    }
}

@end
