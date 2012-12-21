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

@interface MiniMonthView : UIView {
	UIView *tinyBarView;
	
	MonthlyCalendarView *calView;
	
	UILongPressGestureRecognizer *lpHandler;
	//UIView *knobAreaView;
	UIImageView *knobImgView;
	MiniMonthHeaderView *headerView;
    UIImageView *separatorImgView;
	
	CGPoint touchedPoint;
	
	//BOOL initCalBGInProgress;
}

@property (nonatomic, readonly) MonthlyCalendarView *calView;
@property (nonatomic, readonly) MiniMonthHeaderView *headerView;

//- (void) scrollDay;
- (void) changeSkin;
- (void) initCalendar;
- (void) initCalendar:(NSDate *)date;
- (void) showCalendar;
//- (void) refreshCalendar;
- (void) refresh;
- (void) moveToPoint:(CGPoint) point;
- (void) jumpToDate:(NSDate *)date;
- (void) finishInitCalendar;
- (void) switchView:(NSInteger)mode;
- (void) shiftTime:(NSInteger)mode;

@end
