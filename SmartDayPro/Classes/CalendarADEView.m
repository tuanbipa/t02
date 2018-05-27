//
//  CalendarADEView.m
//  SmartCal
//
//  Created by Left Coast Logic on 6/25/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import "CalendarADEView.h"

#import "Common.h"
#import "Task.h"

#import "TaskManager.h"
#import "DBManager.h"
#import "TaskLinkManager.h"

#import "TaskView.h"

#import "SmartDayViewController.h"
#import "CalendarViewController.h"

#define WIDTH_ALLDAY_LABEL 60

@implementation CalendarADEView

@synthesize adeList;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UILabel *allDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH_ALLDAY_LABEL, frame.size.height + 10)];// 10:padding top,bottom
        allDayLabel.backgroundColor = [UIColor clearColor];
        allDayLabel.textColor = hexColor(0x8B8B8B);
        allDayLabel.textAlignment = NSTextAlignmentCenter;
        allDayLabel.text = _allDayText;
        allDayLabel.font = [UIFont boldSystemFontOfSize:12];
        
        [self addSubview:allDayLabel];
        [allDayLabel release];
        
        self.adeList = nil;
    }
    
    return self;
}

- (void) dealloc
{
    self.adeList = nil;
    
    [super dealloc];
}

- (void) refreshView
{
    for (UIView *view in self.subviews)
    {
        if ([view isKindOfClass:[TaskView class]])
        {
            [view removeFromSuperview];
        }
    }
    
    //CalendarViewController *ctrler = [_abstractViewCtrler getCalendarViewController];
    
    int y = 5;
    
    for (int i=0; i<self.adeList.count; i++) {
        Task *task = [self.adeList objectAtIndex:i];
        
        ////printf("ade %s - start: %s, end: %s\n", [task.name UTF8String], [[task.startTime description] UTF8String], [[task.endTime description] UTF8String]);
        
        CGRect frm = CGRectMake(WIDTH_ALLDAY_LABEL, y, self.frame.size.width - WIDTH_ALLDAY_LABEL, self.frame.size.height);
        
        TaskView *taskView = [[TaskView alloc] initWithFrame:frm];
        //taskView.tag = task;
        taskView.task = task;
        taskView.starEnable = NO;
        
        [taskView enableMove:NO];
        [taskView refreshStarImage];
        [taskView refreshCheckImage];
        
        [self addSubview:taskView];
        [taskView release]; 
        
        y += frm.size.height;
    }
    
    CGFloat h = 0;
    
    if (self.adeList.count == 1)
    {
        h = 40;
    }
    else if (self.adeList.count == 2)
    {
//        h = 80;
        h = 75;
    }
    else if (self.adeList.count > 2)
    {
        //h = 90;
        h = 110;
    }
    
    CGRect frm = self.frame;
    frm.size.height = h;
    self.frame = frm;
    
//    self.contentSize = CGSizeMake(self.bounds.size.width, y + 5);
    self.contentSize = CGSizeMake(self.bounds.size.width, y);
    self.contentOffset = CGPointMake(0, 0);
}

- (void) refreshData
{
    //printf("Calendar ADE Pane - refresh data\n");
    TaskManager *tm = [TaskManager getInstance];
    
    self.adeList = [tm getADEListOnDate:tm.today];
    
    /*
    for (int i=0; i<self.adeList.count; i++)
    {
        Task *task = [self.adeList objectAtIndex:i];
        
        printf("ade %s - start: %s, end: %s, swd id: %s\n", [task.name UTF8String], [[task.startTime description] UTF8String], [[task.endTime description] UTF8String], [[task.sdwId description] UTF8String]);
    }
    */
    
    [self refreshView];
}

- (void) reconcileLinks:(NSDictionary *)dict
{
    TaskLinkManager *tlm = [TaskLinkManager getInstance];
    
    int sourceId = [[dict objectForKey:@"LinkSourceID"] intValue];
    int destId = [[dict objectForKey:@"LinkDestID"] intValue];
    
    for (Task *ade in self.adeList)
    {
        if (ade.primaryKey == sourceId)
        {
            ade.links = [tlm getLinkIds4Task:sourceId];
        }
        else if (ade.primaryKey == destId)
        {
            ade.links = [tlm getLinkIds4Task:destId];
        }
    }
    
    for (UIView *view in self.subviews)
    {
        if ([view isKindOfClass:[TaskView class]])
        {
            [view setNeedsDisplay];
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
