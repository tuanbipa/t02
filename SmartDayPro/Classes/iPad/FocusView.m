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
#import "DBManager.h"
#import "TaskLinkManager.h"

#import "TaskView.h"

#import "AbstractSDViewController.h"
#import "CalendarViewController.h"

AbstractSDViewController *_abstractViewCtrler;

@implementation FocusView

@synthesize adeList;
@synthesize dueList;
@synthesize noteList;

@synthesize doneList;
//@synthesize anchoredList;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Initialization code
  
        self.layer.borderWidth = 1;

        self.layer.borderColor = [[UIColor colorWithRed:192.0/255 green:192.0/255 blue:192.0/255 alpha:1] CGColor];
        //self.backgroundColor = [UIColor colorWithRed:100.0/255 green:108.0/255 blue:127.0/255 alpha:1];
        
        CGRect frm = self.bounds;
        
        //frm.size.height = 40;
        frm.size.height = 24;
        CGRect titleFrame = frm;
        titleFrame.origin.x += PAD_WIDTH;
        
        titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor darkGrayColor];
        //titleLabel.font = [UIFont systemFontOfSize:20];
        titleLabel.font = [UIFont systemFontOfSize:12];
        //titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.text = _focusText;
        
        [self addSubview:titleLabel];
        [titleLabel release];
        
        /*zoomButton = [Common createButton:@""
                                         buttonType:UIButtonTypeCustom
                                              //frame:CGRectMake(0, 0, 50, 50)
                                        frame:frm
                                         titleColor:[UIColor whiteColor]
                                             target:self
                                           selector:@selector(zoom:)
                                   normalStateImage:nil
                                 selectedStateImage:nil];
        zoomButton.selected = NO;
        
        [self addSubview:zoomButton];
        
        UIImageView *zoomImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MM_month.png"]];
        zoomImgView.frame = CGRectMake(5, 3, 30, 30);
        zoomImgView.tag = 10000;
        
        [zoomButton addSubview:zoomImgView];
        [zoomImgView release];*/
        
        frm.origin.y = 30;
        frm.size.height = 0;
        
        contentView = [[UIScrollView alloc] initWithFrame:frm];
        
        [self addSubview:contentView];
        [contentView release];
        
        /*frm.size.height = 1;
        
        UIView *separatorView = [[UIView alloc] initWithFrame:frm];
        separatorView.backgroundColor = [UIColor colorWithRed:192.0/255 green:192.0/255 blue:192.0/255 alpha:1];
        
        [self addSubview:separatorView];
        [separatorView release];*/
    }
    
    return self;
}

- (void) dealloc
{
    self.adeList = nil;
    self.dueList = nil;
    self.noteList = nil;
    
    self.doneList = nil;
    //self.anchoredList = nil;
    
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
    
    //if (zoomButton.selected)
    {
        int y = 5;
        
        /*
        
        // show done tasks
        for (int i=0; i<self.doneList.count; i++)
        {
            Task *task = [self.doneList objectAtIndex:i];
            task.listSource = SOURCE_FOCUS;
            
            ////printf("ade %s - start: %s, end: %s\n", [task.name UTF8String], [[task.startTime description] UTF8String], [[task.endTime description] UTF8String]);
            
            CGRect frm = CGRectMake(10, y, contentView.bounds.size.width-20, 35);
            
            TaskView *taskView = [[TaskView alloc] initWithFrame:frm];
            taskView.task = task;
            taskView.starEnable = NO;
            taskView.listStyle = NO;
            taskView.focusStyle = YES;
            
            [taskView enableMove:NO];
            [taskView refreshStarImage];
            [taskView refreshCheckImage];
            
            [contentView addSubview:taskView];
            [taskView release];
            
            y += frm.size.height;
        }
        
        for (int i=0; i<self.adeList.count; i++)
        {
            Task *task = [self.adeList objectAtIndex:i];
            task.listSource = SOURCE_FOCUS;
            
            ////printf("ade %s - start: %s, end: %s\n", [task.name UTF8String], [[task.startTime description] UTF8String], [[task.endTime description] UTF8String]);
            
            CGRect frm = CGRectMake(10, y, contentView.bounds.size.width-20, 35);
            
            TaskView *taskView = [[TaskView alloc] initWithFrame:frm];
            taskView.task = task;
            taskView.starEnable = NO;
            taskView.listStyle = NO;
            taskView.focusStyle = YES;
            
            [taskView enableMove:NO];
            [taskView refreshStarImage];
            [taskView refreshCheckImage];
            
            [contentView addSubview:taskView];
            [taskView release];
            
            y += frm.size.height;
        }
        
        for (int i=0; i<self.dueList.count; i++)
        {
            Task *task = [self.dueList objectAtIndex:i];
            
            task.listSource = SOURCE_FOCUS;
            
            CGRect frm = CGRectMake(10, y, contentView.bounds.size.width-20, 35);
            
            TaskView *taskView = [[TaskView alloc] initWithFrame:frm];
            taskView.task = task;
            taskView.starEnable = NO;
            taskView.listStyle = NO;
            taskView.focusStyle = YES;
            
            [taskView enableMove:NO];
            [taskView refreshStarImage];
            [taskView refreshCheckImage];
            
            [contentView addSubview:taskView];
            [taskView release];
            
            y += frm.size.height;
            
        }

        for (int i=0; i<self.noteList.count; i++)
        {
            Task *task = [self.noteList objectAtIndex:i];
            
            task.listSource = SOURCE_FOCUS;
            
            CGRect frm = CGRectMake(10, y, contentView.bounds.size.width-20, 35);
            
            TaskView *taskView = [[TaskView alloc] initWithFrame:frm];
            taskView.task = task;
            taskView.starEnable = NO;
            taskView.listStyle = NO;
            taskView.focusStyle = YES;
            
            [taskView enableMove:NO];
            [taskView refreshStarImage];
            [taskView refreshCheckImage];
            
            [contentView addSubview:taskView];
            [taskView release];
            
            y += frm.size.height;
            
        }
        */
        
        NSArray *lists[4] = {self.doneList, self.adeList, self.dueList, self.noteList};
        
        for (int i=0; i<4; i++)
        {
            NSArray *list = lists[i];
            
            for (int j=0; j<list.count; j++)
            {
                Task *task = [list objectAtIndex:j];
                
                task.listSource = SOURCE_FOCUS;
                
                CGRect frm = CGRectMake(10, y, contentView.bounds.size.width-20, 35);
                
                TaskView *taskView = [[TaskView alloc] initWithFrame:frm];
                taskView.task = task;
                taskView.starEnable = NO;
                taskView.listStyle = NO;
                taskView.focusStyle = YES;
                taskView.showDue = YES;
                
                [taskView enableMove:NO];
                [taskView refreshStarImage];
                [taskView refreshCheckImage];
                
                [contentView addSubview:taskView];
                [taskView release];
                
                y += frm.size.height;
                
            }
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
    /*else
    {
        CGRect frm = self.frame;
        
        frm.size.height = 40;
        
        self.frame = frm;
        
        frm = contentView.frame;
        
        frm.size.height = 0;
        
        contentView.frame = frm;
    }*/    
    
    CalendarViewController *ctrler = [_abstractViewCtrler getCalendarViewController];
    [ctrler refreshFrame];
}

- (void) refreshData
{
    TaskManager *tm = [TaskManager getInstance];
    //DBManager *dbm = [DBManager getInstance];
    
    //titleLabel.text = [Common getFullDateString3:tm.today];
    
    if ([self checkExpanded] && tm.today != nil)
    {
        // get done list
        self.doneList = [tm getDoneTasksOnDate:tm.today];
        
        self.adeList = [tm getADEListOnDate:tm.today];
        
        /*if ([Common daysBetween:tm.today sinceDate:[NSDate date]] == 0)
        {
            // REMOVE all overdue Tasks from TODAY's focus pane (PT ID: 54073565)
            //self.dueList = [tm getOverdueTaskList];
            
            //[self.dueList addObjectsFromArray:[tm getDTaskListOnDate:tm.today]];
        }
        else*/
        {
            self.dueList = [tm getDTaskListOnDate:tm.today];
        }
        
        self.noteList = [tm getNoteListOnDate:tm.today];
        
        //self.anchoredList = [tm getATaskListOnDate:tm.today];
    }
    
    [self refreshView];
}

-(void)setNeedsDisplay
{
	for (UIView *view in contentView.subviews)
	{
        if ([view isKindOfClass:[TaskView class]])
        {
            [view refresh];
        }
	}
}

- (void) reloadAlert4Task:(NSInteger)taskId
{
    for (Task *task in self.adeList)
    {
        if (task.original == nil || [task isREException])
        {
            if (task.primaryKey == taskId)
            {
                task.alerts = [[DBManager getInstance] getAlertsForTask:task.primaryKey];
                
                break;
            }
        }
    }
    
    for (Task *task in self.dueList)
    {
        if (task.original == nil || [task isREException])
        {
            if (task.primaryKey == taskId)
            {
                task.alerts = [[DBManager getInstance] getAlertsForTask:task.primaryKey];
                
                break;
            }
        }
    }
}

- (void) reconcileLinks:(NSDictionary *)dict
{
    TaskLinkManager *tlm = [TaskLinkManager getInstance];
    
    int sourceId = [[dict objectForKey:@"LinkSourceID"] intValue];
    int destId = [[dict objectForKey:@"LinkDestID"] intValue];
    
    for (Task *task in self.doneList)
    {
        if (task.original == nil || [task isREException])
        {
            if (task.primaryKey == sourceId)
            {
                task.links = [tlm getLinkIds4Task:sourceId];
            }
            else if (task.primaryKey == destId)
            {
                task.links = [tlm getLinkIds4Task:destId];
            }
        }
    }
    
    for (Task *task in self.adeList)
    {
        if (task.original == nil || [task isREException])
        {
            if (task.primaryKey == sourceId)
            {
                task.links = [tlm getLinkIds4Task:sourceId];
            }
            else if (task.primaryKey == destId)
            {
                task.links = [tlm getLinkIds4Task:destId];
            }
        }
    }
    
    for (Task *task in self.dueList)
    {
        if (task.original == nil || [task isREException])
        {
            if (task.primaryKey == sourceId)
            {
                task.links = [tlm getLinkIds4Task:sourceId];
            }
            else if (task.primaryKey == destId)
            {
                task.links = [tlm getLinkIds4Task:destId];
            }
        }
    }
    
    for (Task *task in self.noteList)
    {
        if (task.original == nil || [task isREException])
        {
            if (task.primaryKey == sourceId)
            {
                task.links = [tlm getLinkIds4Task:sourceId];
            }
            else if (task.primaryKey == destId)
            {
                task.links = [tlm getLinkIds4Task:destId];
            }
        }
    }
}

- (void) refreshTaskView4Key:(NSInteger)taskKey
{
	for (UIView *view in contentView.subviews)
	{
		if ([view isKindOfClass:[TaskView class]])
		{
            TaskView *taskView = (TaskView *) view;
            
            Task *task = taskView.task;
            
            if (task.original != nil && ![task isREException])
            {
                task = task.original;
            }
            
            if (task.primaryKey == taskKey)
            {
                [taskView setNeedsDisplay];
                [taskView refreshStarImage];
                [taskView refreshCheckImage];
                
                break;
            }
		}
	}
}

- (void) reconcileItem:(Task *)item
{
    if ([self checkExpanded])
    {
        [self refreshData];
    }
}

/*- (void) zoom:(id)sender
{
    zoomButton.selected = !zoomButton.selected;
    
    UIImageView *imgView = (UIImageView *)[zoomButton viewWithTag:10000];
    imgView.image = [UIImage imageNamed:zoomButton.selected?@"MM_month.png":@"MM_week.png"];
    
    [self refreshData];
}*/

- (BOOL) checkExpanded
{
    //return zoomButton.selected;
    return YES;
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
