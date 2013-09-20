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
#import "AbstractSDViewController.h"
#import "Settings.h"

extern BOOL _isiPad;

extern AbstractSDViewController *_abstractViewCtrler;

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
        
    }
    return self;
}

//- (void) changeFrame:(CGRect)frm
//{
//    self.frame = frm;
//    
//    headerView.frame = CGRectMake(0, 0, frm.size.width, 50);
//    monthView.frame = CGRectMake(0, headerView.frame.size.height, frm.size.width, 26*6);
//}

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
    
    /*
    // get first day in month
    NSDate *dt = [self.monthView getFirstDate];
    dt = [Common getFirstMonthDate:[Common dateByAddNumDay:7 toDate:dt]];
    dt = [Common dateByAddNumMonth:(mode == 0?-1:1) toDate:dt];
    */
    
    // get month/week mode
    NSInteger mwMode = [headerView getMWMode];
    
    NSDate *dt = [self.monthView getFirstDate];
    if (mwMode == 0) {
        // month mode
        dt = [Common getFirstMonthDate:[Common dateByAddNumDay:7 toDate:dt]];
        dt = [Common dateByAddNumMonth:(mode == 0?-1:1) toDate:dt];
    } else {
        // week mode
        dt = [Common dateByAddNumDay:(mode == 0?-7:7) toDate:dt];
    }
    [self goToDate:dt];
    
    [UIView commitAnimations];
}

- (void)goToday {
    [UIView beginAnimations:@"resize_animation" context:NULL];
    [UIView setAnimationDuration:0.3];
    
    NSDate *dt = [NSDate date];
    [self goToDate:dt];
    
    [UIView commitAnimations];
}

- (void)goToDate: (NSDate *) dt {
    
    [self updateWeeks:dt];
    [monthView collapseWeek];
    [self finishInitCalendar];
    // change month
    //[monthView changeMonth:firstMonDate];
    NSInteger mode = [headerView getMWMode];
    Settings *settings = [Settings getInstance];
    NSDate *calDate = mode == 1 ? [Common getFirstWeekDate:dt mondayAsWeekStart:settings.isMondayAsWeekStart] : [Common getFirstMonthDate:dt];
    [monthView initCalendar:calDate];
    
    // collapse week
    [monthView collapseExpandByDate:dt];
    // select cell date
    [_abstractViewCtrler jumpToDate:dt];
    [monthView highlightCellOnDate:dt];
    
    [self.headerView setNeedsDisplay];
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

- (void) moveToPoint:(CGPoint) point
{
	CGPoint p = [self convertPoint:point toView:monthView];
    
	if (CGRectContainsPoint(monthView.bounds, p))
	{
		////printf("contain point - %f, frm y: %f, frm h: %f\n", p.y, calView.frame.origin.y, calView.frame.size.height);
		[monthView highlightCellAtPoint:p];
	}
	else
	{
		[monthView unhighlight];
	}
    
}

- (void) switchView:(NSInteger)mode
{
    TaskManager *tm = [TaskManager getInstance];
    
    NSDate *dt = (tm.today==nil?[NSDate date]:tm.today);
    
    NSDate *calDate = (mode == 1?dt:[Common getFirstMonthDate:dt]);
    
    [self updateWeeks:calDate];
    [monthView initCalendar:calDate];
    [monthView collapseWeek];
    [self finishInitCalendar];
    
    [monthView collapseExpandByDate:dt];
    [monthView highlightCellOnDate:dt];
}

- (void) updateWeeks:(NSDate *)date
{
    Settings *settings = [Settings getInstance];
    
    NSInteger mode = [headerView getMWMode];
    
    NSDate *calDate = (mode == 1?date:[Common getFirstMonthDate:date]);
    
    NSDate *lastWeekDate = [Common getLastWeekDate:calDate mondayAsWeekStart:settings.isMondayAsWeekStart];
    
    NSInteger weeks = (mode==1?1:[Common getWeeksInMonth:lastWeekDate mondayAsWeekStart:settings.isMondayAsWeekStart]);
    
    [self.monthView changeWeekPlanner:7 weeks:weeks];
}
@end
