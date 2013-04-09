//
//  PlannerView.m
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 3/11/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "PlannerView.h"
#import "Common.h"
#import "PlannerHeaderView.h"
#import "PlannerMonthView.h"
#import "PlannerBottomDayCal.h"
#import "TaskManager.h"
#import "PlannerMonthCellView.h"

extern BOOL _isiPad;

@implementation PlannerView

@synthesize headerView;
@synthesize monthView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor grayColor];
        
        headerView = [[PlannerHeaderView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 50)];
		[self addSubview:headerView];
		[headerView release];
        
        // month view
        monthView = [[PlannerMonthView alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height, frame.size.width, 26*6)];
        
		[self addSubview:monthView];
		[monthView release];
        
        // init calendar
        TaskManager *tm = [TaskManager getInstance];
        NSDate *calDate = [Common getFirstMonthDate:tm.today];
        NSInteger weeks = [Common getWeeksInMonth:calDate];
        [monthView changeWeekPlanner:7 weeks:weeks];
        [monthView initCalendar:calDate];
        [self finishInitCalendar];
        
        // open today week
        PlannerMonthCellView *cell = [self.monthView findCellByDate:tm.today];
        [self.monthView collapseExpand: cell.weekNumberInMonth];
        [self.monthView highlightCellOnDate:tm.today];
        // end init calendar
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark Actions

- (void)shiftTime: (int) mode {
    [UIView beginAnimations:@"resize_animation" context:NULL];
    [UIView setAnimationDuration:0.3];
    
    // get first day in month
    NSDate *dt = [self.monthView getFirstDate];
    dt = [Common getFirstMonthDate:[Common dateByAddNumDay:7 toDate:dt]];
    dt = [Common dateByAddNumMonth:(mode == 0?-1:1) toDate:dt];
    NSInteger weeks = [Common getWeeksInMonth:dt];
    [self.monthView changeWeekPlanner:7 weeks:weeks];
    [self.monthView collapseWeek];
    [self finishInitCalendar];
    // change month
    [self.monthView changeMonth:dt];
    // collapse week
    [self.monthView collapseExpand:0];
    // select first date in month
    dt = [Common getFirstMonthDate:[Common dateByAddNumDay:7 toDate:dt]];
    [self.monthView highlightCellOnDate:dt];
    
    [UIView commitAnimations];
}

- (void)finishInitCalendar {
    
    NSInteger weeks = self.monthView.nWeeks;
	    
    CGRect frm = self.monthView.frame;
    frm.size.height = weeks*26;
    self.monthView.frame = frm;
    
    frm = self.frame;
    frm.size.height = self.headerView.frame.size.height + self.monthView.frame.size.height;
    self.frame = frm;
}
@end
