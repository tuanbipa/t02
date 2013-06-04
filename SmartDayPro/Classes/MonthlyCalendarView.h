//
//  MonthlyCalendarView.h
//  SmartTime
//
//  Created by Left Coast Logic on 12/31/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AbstractMonthCalendarView.h"

@class MonthlyADEView;
@class HighlightView;
@class MonthlyCellView;

@interface MonthlyCalendarView : AbstractMonthCalendarView {

	NSInteger todayCellIndex;
	
	NSInteger currentMonth;
	NSInteger currentYear;
	
	MonthlyADEView *adeView;
	HighlightView *highlightView;
	
	NSInteger nDays;
	NSInteger nWeeks;
    
    NSInteger skinStyle; //0:white;1:black
}

@property (nonatomic, readonly) HighlightView *highlightView;
@property NSInteger skinStyle;

@property NSInteger nWeeks;

- (void) changeWeekPlanner:(NSInteger)days weeks:(NSInteger)weeks;
- (void) refreshCellByDate:(NSDate *)date;
- (void) refresh;
- (void) refreshADEView;
- (void) selectCell:(MonthlyCellView *)cell;
- (void) showCalendar:(NSDate *)date;
- (void) showPreviousMonth;
- (void) showNextMonth;
- (void) showDot;
- (void) highlightCellOnDate:(NSDate *)date;
- (void) refreshAllCells;
- (NSDate *)getSelectedDate;
- (void) highlightCellAtPoint:(CGPoint) point;
- (void) unhighlight;
//- (void) scrollDay:(NSDate *)date;
- (void) changeSkin;
- (void) showWeekCalendar:(NSDate *)date;
- (NSDate *) getFirstDate;
- (NSDate *) getLastDate;
- (void) initCalendar:(NSDate *)date;
- (void) refreshCalendar:(NSDate *)date;
- (void) changeFrame:(CGRect)frm;
- (CGRect) getRectOfSelectedCellInView:(UIView *)view;
- (BOOL) checkDateInCalendar:(NSDate *)date;

@end
