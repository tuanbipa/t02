//
//  DummyMovableController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 3/18/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "DummyMovableController.h"

#import "Common.h"
#import "Task.h"

#import "ContentView.h"
#import "TaskView.h"
#import "PlanView.h"

//#import "AbstractSDViewController.h"

//extern AbstractSDViewController *_abstractViewCtrler;

#import "iPadViewController.h"

extern iPadViewController *_iPadViewCtrler;

@implementation DummyMovableController

@synthesize contentView;

- (CGRect) getMovableRect:(UIView *)view
{
    return [view.superview convertRect:view.frame toView:self.contentView];
}

- (void) beginMove:(MovableView *)view
{
    /*if (_abstractViewCtrler != nil)
    {
        [_abstractViewCtrler deselect];
    }*/
    
    [_iPadViewCtrler.activeViewCtrler deselect];
    
    [super beginMove:view];
    
    CGRect frm = [self getMovableRect:view];
    
    if ([view isKindOfClass:[TaskView class]])
    {
        TaskView *dummyTaskView = [[TaskView alloc] initWithFrame:frm];
        
        TaskView *tv = (TaskView *) view;
        
        dummyTaskView.starEnable = tv.starEnable;
        dummyTaskView.listStyle = tv.listStyle;
        dummyTaskView.showListBorder = YES;
        
        dummyView = dummyTaskView;
        
        dummyTaskView.task = tv.task;
    }
    else if ([view isKindOfClass:[PlanView class]])
    {
        PlanView *dummyPlanView = [[PlanView alloc] initWithFrame:frm];
        dummyPlanView.listStyle = YES;
        dummyPlanView.listType = ((PlanView *)view).listType;
        
        dummyView = dummyPlanView;
        
        dummyPlanView.project = ((PlanView *)view).project;
    }
    
    [self.contentView addSubview:dummyView];
    [dummyView release];
    
    dummyView.alpha = 0.7;
    
    self.activeMovableView.hidden = YES;
    
}

-(void)move:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (self.activeMovableView == nil)
	{
		return;
	}
    
    [super move:touches withEvent:event];
    
    dummyView.frame = [self getMovableRect:self.activeMovableView];
}

-(void) endMove:(MovableView *)view
{
    [self unseparate];
    
    dummyView.hidden = YES;
    
    if (dummyView != nil && [dummyView superview])
    {
        [dummyView removeFromSuperview];
        
        dummyView = nil;
    }
    
     if (self.activeMovableView != nil)
     {
         self.activeMovableView.hidden = NO;
         
         [self enableScroll:YES container:self.activeMovableView.superview];
         
         [super endMove:self.activeMovableView];
     }
}

@end
