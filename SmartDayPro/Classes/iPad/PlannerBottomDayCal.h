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

@interface PlannerBottomDayCal : UIView {
    ContentScrollView *scrollView;
    PlannerScheduleView *plannerScheduleView;
    PlannerCalendarLayoutController *calendarLayoutController;
}

@property (nonatomic, readonly) PlannerCalendarLayoutController *calendarLayoutController;

- (void)changeFrame: (NSDate*) startDate;
@end
