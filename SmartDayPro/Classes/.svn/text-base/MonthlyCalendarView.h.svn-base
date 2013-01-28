//
//  MonthlyCalendarView.h
//  SmartTime
//
//  Created by Left Coast Logic on 12/31/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MonthlyADEView;
@class HighlightView;
@class MonthlyCellView;

@interface MonthlyCalendarView : UIView {

	NSInteger todayCellIndex;
	
	NSInteger currentMonth;
	NSInteger currentYear;
	
	MonthlyADEView *adeView;
	HighlightView *highlightView;
	
	NSInteger nDays;
	NSInteger nWeeks;
}

@property (nonatomic, readonly) HighlightView *highlightView;

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
- (void) initCalendar:(NSDate *)date;
- (void) refreshCalendar:(NSDate *)date;

@end
