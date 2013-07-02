//
//  TaskMovableController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 7/1/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "TaskMovableController.h"

#import "Common.h"
#import "Task.h"

#import "TaskManager.h"

#import "TaskView.h"

#import "CategoryViewController.h"
#import "AbstractSDViewController.h"

extern AbstractSDViewController *_abstractViewCtrler;

@implementation TaskMovableController

@synthesize listTableView;


- (id) init
{
    if (self = [super init])
    {
        self.autoScroll = NO;
    }
    
    return self;
}

-(void) beginMove:(MovableView *)view
{
    self.listTableView.scrollEnabled = NO;
    
    [super beginMove:view];
}

-(void) endMove:(MovableView *)view
{
    self.listTableView.scrollEnabled = YES;
    
    [view retain];
    
    [self unseparate];
    
    self.activeMovableView = view;
    
    self.activeMovableView.hidden = NO;
    
    dummyView.hidden = YES;
    
    if (dummyView != nil && [dummyView superview])
    {
        if (moveInFocus)
        {
            [self doTaskMovementInFocus];
        }
        else if (moveInMM)
        {
            [self doTaskMovementInMM];
        }
        /*else if (moveInDayCalendar)
         {
         [self doMoveTaskInDayCalendar];
         }*/
        else if (rightMovableView != nil)
        {
            Task *task = ((TaskView *) self.activeMovableView).task;
            [[task retain] autorelease];
            
            Task *destTask = ((TaskView *)rightMovableView).task;
            [[destTask retain] autorelease];
            
            [super endMove:view];
            
            if ([task isTask] && [destTask isTask])
            {
                [[TaskManager getInstance] changeOrder:task destTask:destTask];
                
                CategoryViewController *ctrler = [_abstractViewCtrler getCategoryViewController];
                
                if (ctrler.filterType == TYPE_TASK)
                {
                    [ctrler loadAndShowList];
                }
            }
        }
        else
        {
            [super endMove:view];
        }
    }
    
    [view release];
}


- (void) animateRelations
{
    if (moveInFocus || moveInDayCalendar || moveInDayCalendar)
    {
        [self unseparate];
        
        return;
    }
    
    MovableView *rightView = nil;
    MovableView *leftView = nil;
    MovableView *onView = nil;
    
    CGRect frm = [self.activeMovableView.superview convertRect:self.activeMovableView.frame toView:self.listTableView];
    
    NSInteger sections = self.listTableView.numberOfSections;
    
    for (int i=0; i<sections; i++)
    {
        NSInteger rows = [self.listTableView numberOfRowsInSection:i];
        
        for (int j=0; j<rows; j++)
        {
            CGRect rect = [self.listTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            
            if (CGRectIntersectsRect(rect, frm))
            {
                UITableViewCell *cell = [self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
                
                rightView = [cell.contentView viewWithTag:-10000];
                
            }
        }
    }
    
    [self separate:rightView fromLeft:leftView];
}

/*
-(void)scroll:(NSSet *)touches container:(UIView *)container
{
	if (self.autoScroll)
	{
		UIScrollView *scrollView = self.listTableView;
		
		CGPoint location = [[touches anyObject] locationInView:scrollView];
		
		CGPoint p = scrollView.contentOffset;
        
        if (location.x > 320)
        {
            location.x -= 320;
        }
        
        CGRect topArea = [self getScrollAreaInContainer:scrollView side:0];
        CGRect bottomArea = [self getScrollAreaInContainer:scrollView side:1];
        
        //printf("top x = %f, top y= %f, bottom x:%f, bottom y:%f, loc x:%f, loc y:%f\n", topArea.origin.x, topArea.origin.y, bottomArea.origin.x, bottomArea.origin.y, location.x, location.y);
		
		//if (location.y > p.y + scrollView.frame.size.height - SCROLL_CHECK_HEIGHT)
        if (CGRectContainsPoint(bottomArea, location))
		{
			p.y += 10;
		}
		//else if (location.y < p.y + SCROLL_CHECK_HEIGHT)
        else if (CGRectContainsPoint(topArea, location))
		{
			p.y -= 10;
		}
		
		if (p.y < 0)
		{
			p.y = 0;
		}
		else if (p.y > scrollView.contentSize.height)
		{
			p.y = scrollView.contentSize.height;
		}
		
		scrollView.contentOffset = p;
	}
}
*/
@end
