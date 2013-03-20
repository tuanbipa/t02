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
}
@property NSInteger skinStyle;

@property NSInteger day;
@property NSInteger month;
@property NSInteger year;

@property BOOL hasDTask;
@property BOOL hasSTask;
@property BOOL isToday;

- (void)setDay:(NSInteger) dayValue;
- (void) setDSDots:(BOOL)dTask sTask:(BOOL)sTask;
- (NSDate *)getCellDate;
@end
