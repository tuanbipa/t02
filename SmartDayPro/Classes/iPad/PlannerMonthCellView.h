//
//  PlannerMonthCellView.h
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 3/15/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CellBadgeView;
@class CellSquareBadgeView;

#define PLANNER_DAY_CELL_HEIGHT 144
#define PLANNER_DAY_CELL_COLLAPSE_HEIGHT 27

typedef enum
{
	BUTTON_EXPAND_TAG,
    IMAGE_EXPAND_TAG
	
} cellViewTags;

@interface PlannerMonthCellView : UIView {
    
    NSInteger day;
	NSInteger month;
	NSInteger year;
	
	UILabel *dayLabel;
    
    // day has due task
    BOOL hasDTask;
    // day has S task
	BOOL hasSTask;
    // is Today
    BOOL isToday;
    // if has task in current day, view will show dot
    //BOOL isDot;
    // is expanded
    BOOL isExpand;
    // is the first day in week
    BOOL isFirstDayInWeek;
    // this belong to week # in month
    int weekNumberInMonth;
    //cell in previous or next month
    BOOL gray;
}
@property NSInteger skinStyle;

@property NSInteger day;
@property NSInteger month;
@property NSInteger year;

@property BOOL hasDTask;
@property BOOL hasSTask;
@property BOOL isToday;
//@property BOOL isDot;
@property BOOL isFirstDayInWeek;
@property int weekNumberInMonth;
@property BOOL gray;

- (void)setDay:(NSInteger) dayValue;
- (void) setDSDots:(BOOL)dTask sTask:(BOOL)sTask;
- (NSDate *)getCellDate;
- (void)expandDayCell: (int) height;
- (void)collapseDayCell;
- (void)disPlayExpandButton:(BOOL)value;
@end
