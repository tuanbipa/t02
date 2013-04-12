//
//  PlannerBottomDayCal.h
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 3/18/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContentScrollView;
@class PlannerScheduleView;
@class PlannerCalendarLayoutController;
@class MovableController;

@interface PlannerBottomDayCal : UIView {
    ContentScrollView *scrollView;
    PlannerScheduleView *plannerScheduleView;
    PlannerCalendarLayoutController *calendarLayoutController;
    MovableController *movableController;
}

@property (nonatomic, readonly) PlannerCalendarLayoutController *calendarLayoutController;
@property (nonatomic, readonly) MovableController *movableController;
@property (nonatomic, readonly) PlannerScheduleView *plannerScheduleView;

- (void)changeWeek: (NSDate*) startDate;
- (void) refreshLayout;
- (void) refreshTaskView4Key:(NSInteger)taskKey;
- (void) setMovableContentView:(UIView *)contentView;
@end
