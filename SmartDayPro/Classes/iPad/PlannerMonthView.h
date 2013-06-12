//
//  PlannerMonthView.h
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 3/14/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AbstractMonthCalendarView.h"

@class HighlightView;
@class PlannerMonthCellView;

@interface PlannerMonthView : AbstractMonthCalendarView {
    
    NSInteger todayCellIndex;
	
	//NSInteger currentMonth;
	//NSInteger currentYear;
    
    //NSInteger nDays;
	NSInteger nWeeks;
    
    NSInteger skinStyle; //0:white;1:black
    
    NSMutableArray *plannerItemsList;
    
    // the week, which is open
    // if no week is open, the value is -1
    NSInteger openningWeek;
    
    HighlightView *highlightView;
}
@property NSInteger nWeeks;

@property NSInteger skinStyle;
@property (nonatomic, retain) NSMutableArray *plannerItemsList;
@property (nonatomic, readonly) HighlightView *highlightView;

#pragma mark methods
- (void)changeWeekPlanner:(NSInteger)days weeks:(NSInteger)weeks;
// draw calendar
- (void)initCalendar: (NSDate *)date;
- (void)changeMonth: (NSDate *) date;
- (void)expandWeek: (int) week;
- (void)collapseWeek;
- (BOOL)collapseExpand: (int) week;
- (BOOL)collapseExpandByDate: (NSDate *) dt;
- (void)collapseCurrentWeek;
- (void)expandCurrentWeek;
- (NSDate *)getFirstDate;
- (void)selectCell: (PlannerMonthCellView *) cell;
- (void)highlightCellOnDate: (NSDate *) dt;
- (PlannerMonthCellView *) findCellByDate:(NSDate *)date;
- (NSDate *)getSelectedDate;
- (void) refreshCellByDate:(NSDate *)date;
- (void) highlightCellAtPoint:(CGPoint) point;
- (void) unhighlight;
- (void) refreshOpeningWeek: (NSNotification *)notification;
#pragma mark Links
- (void) reconcileLinks:(NSDictionary *)dict;
@end
