//
//  MiniMonthView.h
//  SmartCal
//
//  Created by MacBook Pro on 3/21/11.
//  Copyright 2011 LCL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MonthlyCalendarView;
@class MiniMonthHeaderView;
@class MiniMonthWeekHeaderView;

@interface MiniMonthView : UIView {
	UIView *tinyBarView;
	
	MonthlyCalendarView *calView;
	
	UILongPressGestureRecognizer *lpHandler;
	UIImageView *knobImgView;
    
	MiniMonthHeaderView *headerView;
    MiniMonthWeekHeaderView *weekHeaderView;
    UIImageView *separatorImgView;
	
	CGPoint touchedPoint;
}

@property (nonatomic, readonly) MonthlyCalendarView *calView;
@property (nonatomic, readonly) MiniMonthHeaderView *headerView;
@property (nonatomic, readonly) MiniMonthWeekHeaderView *weekHeaderView;

//- (void) scrollDay;
- (void) changeSkin;
- (void) initCalendar;
- (void) showCalendar;
//- (void) refreshCalendar;
- (void) refresh;
- (void) moveToPoint:(CGPoint) point;
- (void) jumpToDate:(NSDate *)date;
- (void) finishInitCalendar;
- (void) switchView:(NSInteger)mode;
- (void) shiftTime:(NSInteger)mode;
- (void) initCalendar:(NSDate *)date;
- (void) highlight:(NSDate *)date;
- (void) updateWeeks:(NSDate *)date;

@end
