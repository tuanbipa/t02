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
@class TaskOutlineView;
@class TaskView;
@class TimeSlotView;
@class HPGrowingTextView;

@interface PlannerBottomDayCal : UIView <UITextFieldDelegate>{
    ContentScrollView *scrollView;
    PlannerScheduleView *plannerScheduleView;
    PlannerCalendarLayoutController *calendarLayoutController;
    MovableController *movableController;
    
    TaskOutlineView *outlineView;
    
    //UITextField *quickAddTextField;
    HPGrowingTextView *quickAddTextView;
    TaskView *quickAddBackgroundView;
}

@property (nonatomic, readonly) PlannerCalendarLayoutController *calendarLayoutController;
@property (nonatomic, readonly) MovableController *movableController;
@property (nonatomic, readonly) PlannerScheduleView *plannerScheduleView;

- (void)changeWeek: (NSDate*) startDate;
- (void) refreshLayout;
- (void) refreshTaskView4Key:(NSInteger)taskKey;
- (void) setMovableContentView:(UIView *)contentView;

#pragma mark resizing handle
- (void)beginResize:(TaskView *)view;
- (void)finishResize;
- (void) stopResize;

#pragma mark quick add event
-(void)showQuickAdd:(TimeSlotView *)timeSlot sender: (UILongPressGestureRecognizer *)sender;
- (void)stopQuickAdd;

#pragma mark Links
- (void) reconcileLinks:(NSDictionary *)dict;
@end
