//
//  PlannerMovable.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 4/9/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "PlannerMovableController.h"

#import "Common.h"
#import "Settings.h"
#import "TaskManager.h"
#import "DBManager.h"
#import "Task.h"

#import "TaskView.h"
#import "PlanView.h"
#import "ContentView.h"
#import "PlannerView.h"
#import "PlannerMonthView.h"

#import "SmartDayViewController.h"
#import "iPadSmartDayViewController.h"
#import "PlannerViewController.h"

#import "NoteDetailTableViewController.h"
#import "TaskDetailTableViewController.h"

//extern SmartDayViewController *_sdViewCtrler;
//extern AbstractSDViewController *_abstractViewCtrler;
//extern iPadSmartDayViewController *_iPadSDViewCtrler;

extern PlannerViewController *_plannerViewCtrler;

@implementation PlannerMovableController

- (id) init
{
    if (self = [super init])
    {
        self.contentView = _plannerViewCtrler.contentView;
    }
    
    return self;
}

- (BOOL)checkSeparate:(TaskView *)view
{
    //Task *task = (Task *) view.tag;
    Task *task = view.task;
    
    return ![task checkMustDo];
}

-(void) endMove:(MovableView *)view
{
    if (moveInMM)
    {
        [self doTaskMovementInMM];
    }
    else
    {
        [super endMove:self.activeMovableView];
    }
}

-(void)move:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (self.activeMovableView == nil)
	{
		return;
	}
    
    CGRect frm = dummyView.frame;
    
    [super move:touches withEvent:event];
    
    CGRect mmFrm = [self getMovableRect:_plannerViewCtrler.plannerView.monthView];
    
    //printf("mm frame - x:%f, y:%f, w:%f, h:%f\n", mmFrm.origin.x, mmFrm.origin.y, mmFrm.size.width, mmFrm.size.height);
    
    CGPoint touchPoint = [self.activeMovableView getTouchPoint];
    
    CGPoint tp = [self.activeMovableView.superview convertPoint:touchPoint toView:_plannerViewCtrler.contentView];
    
    //printf("touch point - x:%f, y:%f\n", tp.x, tp.y);
    
    moveInMM = CGRectContainsPoint(mmFrm, tp);
    
    if (moveInMM)
    {
        if (frm.size.width > 100)
        {
            if ([self.activeMovableView isKindOfClass:[TaskView class]])
            {
                ((TaskView *)dummyView).starEnable = NO;
            }
            
            [dummyView setNeedsDisplay];
        }
        
        frm.origin.x = tp.x;
        frm.origin.y = tp.y - 40;
        
        frm.size.width = 80;
        frm.size.height = 25;
        
        //highlight cell at point
        
        //[_abstractViewCtrler.miniMonthView moveToPoint:tp];
    }
    else
    {
        if (frm.size.width < 100)
        {
            if ([self.activeMovableView isKindOfClass:[TaskView class]])
            {
                TaskView *tv = (TaskView *) self.activeMovableView;
                
                ((TaskView *) dummyView).starEnable = tv.starEnable;
            }
            
            [dummyView setNeedsDisplay];
        }
        
        frm = [self getMovableRect:self.activeMovableView];
    }
    
    dummyView.frame = frm;
}

- (void) doTaskMovementInMM
{
    
}

@end
