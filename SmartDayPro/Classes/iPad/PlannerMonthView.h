//
//  PlannerMonthView.h
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 3/14/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlannerMonthView : UIView {
    
    NSInteger todayCellIndex;
	
	NSInteger currentMonth;
	NSInteger currentYear;
    
    NSInteger nDays;
	NSInteger nWeeks;
    
    NSInteger skinStyle; //0:white;1:black
    
    NSMutableArray *plannerItemsList;
    
    // the week, which is open
    // if no week is open, the value is -1
    int openningWeek;
}

@property NSInteger skinStyle;
@property (nonatomic, retain) NSMutableArray *plannerItemsList;

#pragma mark methods
- (void)changeWeekPlanner:(NSInteger)days weeks:(NSInteger)weeks;
// draw calendar
- (void)initCalendar: (NSDate *)date;
- (void)changeMonth: (NSDate *) date;
- (void)expandWeek: (int) week;
- (void)collapseExpand: (int) week;
- (NSDate *)getFirstDate;
@end
