//
//  FocusView.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 12/12/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FocusView.h"

#import "Common.h"
#import "Task.h"

#import "TaskManager.h"

#import "TaskView.h"

#import "AbstractSDViewController.h"
#import "CalendarViewController.h"

AbstractSDViewController *_abstractViewCtrler;

@implementation FocusView

@synthesize adeList;
@synthesize dueList;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Initialization code
        
        self.layer.borderWidth = 1;
        self.layer.borderColor = [[UIColor grayColor] CGColor];
        
        CGRect frm = self.bounds;
        
        frm.size.height = 40;
        
        titleLabel = [[UILabel alloc] initWithFrame:frm];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor grayColor];
        titleLabel.font = [UIFont systemFontOfSize:20];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:titleLabel];
        [titleLabel release];
        
        zoomButton = [Common createButton:@""
                                         buttonType:UIButtonTypeCustom
                                              frame:CGRectMake(0, 0, 50, 50)
                                         titleColor:[UIColor whiteColor]
                                             target:self
                                           selector:@selector(zoom:)
                                   normalStateImage:nil
                                 selectedStateImage:nil];
        
        [self addSubview:zoomButton];
        
        UIImageView *zoomImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MM_week.png"]];
        zoomImgView.frame = CGRectMake(5, 3, 30, 30);
        zoomImgView.tag = 10000;
        
        [zoomButton addSubview:zoomImgView];
        [zoomImgView release];
        
        frm.origin.y = 40;
        frm.size.height = 0;
        
        contentView = [[UIScrollView alloc] initWithFrame:frm];
        
        [self addSubview:contentView];
        [contentView release];
        
        frm.size.height = 1;
        
        UIView *separatorView = [[UIView alloc] initWithFrame:frm];
        separatorView.backgroundColor = [UIColor grayColor];
        
        [self addSubview:separatorView];
        [separatorView release];
    }
    
    return self;
}

- (void) dealloc
{
    self.adeList = nil;
    self.dueList = nil;
    
    [super dealloc];
}

- (void) refreshView
{
    for (UIView *view in contentView.subviews)
    {
        if ([view isKindOfClass:[TaskView class]])
        {
            [view removeFromSuperview];
        }
    }
    
    if (zoomButton.selected)
    {
        int y = 5;
        
        for (int i=0; i<self.adeList.count; i++)
        {
            Task *task = [self.adeList objectAtIndex:i];
            task.listSource = SOURCE_FOCUS;
            
            ////printf("ade %s - start: %s, end: %s\n", [task.name UTF8String], [[task.startTime description] UTF8String], [[task.endTime description] UTF8String]);
            
            CGRect frm = CGRectMake(10, y, contentView.bounds.size.width-20, 30);
            
            TaskView *taskView = [[TaskView alloc] initWithFrame:frm];
            taskView.task = task;
            taskView.starEnable = NO;
            
            [taskView enableMove:NO];
            [taskView refreshStarImage];
            [taskView refreshCheckImage];
            
            [contentView addSubview:taskView];
            [taskView release];
            
            y += frm.size.height + 5;
        }
        
        for (int i=0; i<self.dueList.count; i++)
        {
            Task *task = [self.dueList objectAtIndex:i];
            
            task.listSource = SOURCE_FOCUS;
            
            CGRect frm = CGRectMake(10, y, contentView.bounds.size.width-20, 30);
            
            TaskView *taskView = [[TaskView alloc] initWithFrame:frm];
            taskView.task = task;
            taskView.starEnable = NO;
            
            [taskView enableMove:NO];
            [taskView refreshStarImage];
            [taskView refreshCheckImage];
            
            [contentView addSubview:taskView];
            [taskView release];
            
            y += frm.size.height + 5;
            
        }
        
        CGRect frm = contentView.frame;
        frm.size.height = y > 150?150:(y==5?0:y);
        contentView.frame = frm;
        
        contentView.contentSize = CGSizeMake(self.bounds.size.width, y);
        contentView.contentOffset = CGPointMake(0, 0);
        
        frm = self.frame;
        
        frm.size.height = 40 + contentView.bounds.size.height;
        
        self.frame = frm;
    }
    else
    {
        CGRect frm = self.frame;
        
        frm.size.height = 40;
        
        self.frame = frm;
        
        frm = contentView.frame;
        
        frm.size.height = 0;
        
        contentView.frame = frm;
    }
}

- (void) refreshData
{
    TaskManager *tm = [TaskManager getInstance];
    
    titleLabel.text = [Common getFullDateString3:tm.today];
    
    if (zoomButton.selected)
    {
        self.adeList = [tm getADEListOnDate:tm.today];
        
        if ([Common daysBetween:tm.today andDate:[NSDate date]] == 0)
        {
            self.dueList = [tm getOverdueTaskList];
            
            [self.dueList addObjectsFromArray:[tm getDTaskListOnDate:tm.today]];
        }
        else
        {
            self.dueList = [tm getDTaskListOnDate:tm.today];
        }        
    }
    
    [self refreshView];
}

- (void) zoom:(id)sender
{
    zoomButton.selected = !zoomButton.selected;
    
    UIImageView *zoomImgView = (UIImageView *)[zoomButton viewWithTag:10000];
    
    zoomImgView.image = [UIImage imageNamed:zoomButton.selected?@"MM_month.png":@"MM_week.png"];
    
    [self refreshData];
    
    CalendarViewController *ctrler = [_abstractViewCtrler getCalendarViewController];
    [ctrler refreshFrame];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
