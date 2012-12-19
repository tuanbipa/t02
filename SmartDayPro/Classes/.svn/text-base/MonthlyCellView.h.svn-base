//
//  MonthlyCellView.h
//  SmartTime
//
//  Created by Left Coast Logic on 12/31/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MonthlyCalendarView;
@class CellBadgeView;
@class CellSquareBadgeView;

@interface MonthlyCellView : UIView {

	NSInteger day;
	NSInteger month;
	NSInteger year;
	
	NSInteger index;
	
	UILabel *dayLabel;
	
	//BOOL selected;
	BOOL gray; //cell in previous or next month
	BOOL isWeekend;
	BOOL isToday;
	BOOL isDot;
	
	BOOL hasDTask;
	BOOL hasSTask;
	
	CGFloat freeRatio;
}

@property NSInteger day;
@property NSInteger month;
@property NSInteger year;

@property NSInteger index;
//@property BOOL selected;
@property BOOL gray;
@property BOOL isWeekend;
@property BOOL isToday;
@property BOOL isDot;

@property BOOL hasDTask;
@property BOOL hasSTask;

@property CGFloat freeRatio;

- (void) changeSkin;
-(void) setDSDots:(BOOL)dTask sTask:(BOOL)sTask;
- (NSDate *)getCellDate;

@end
