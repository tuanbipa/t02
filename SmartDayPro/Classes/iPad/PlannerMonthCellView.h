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
    BOOL isDot;
    // is expanded
    BOOL isExpand;
}
@property NSInteger skinStyle;

@property NSInteger day;
@property NSInteger month;
@property NSInteger year;

@property BOOL hasDTask;
@property BOOL hasSTask;
@property BOOL isToday;
@property BOOL isDot;

- (void)setDay:(NSInteger) dayValue;
- (void) setDSDots:(BOOL)dTask sTask:(BOOL)sTask;
- (NSDate *)getCellDate;
- (void)expandDayCell: (int) height;
@end
