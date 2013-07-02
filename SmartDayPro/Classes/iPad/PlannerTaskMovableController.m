//
//  PlannerTaskMovableController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 7/2/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "PlannerTaskMovableController.h"

#import "TaskView.h"

@implementation PlannerTaskMovableController

@synthesize listTableView;

- (id) init
{
    if (self = [super init])
    {
        self.autoScroll = NO;
        
        moveInMM = NO;
        moveInPlannerDayCal = NO;
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
    
    [self unseparate];
    
    self.activeMovableView = view;
    
    self.activeMovableView.hidden = NO;
    
    dummyView.hidden = YES;
    
    moveInMM = NO;
    moveInPlannerDayCal = NO;
}


- (void) animateRelations
{
    if (moveInMM || moveInPlannerDayCal)
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


@end
