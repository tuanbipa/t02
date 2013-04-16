//
//  CalendarViewController.h
//  SmartCal
//
//  Created by MacBook Pro on 3/21/11.
//  Copyright 2011 LCL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PageAbstractViewController.h"

@class CalendarMovableController;
//@class CalendarLayoutController;
@class CalendarScrollPageLayoutController;
@class DTaskLayoutController;
@class ScheduleView;
@class DateJumpView;
@class FilterView;
@class ProgressIndicatorView;
@class CalendarADEView;
@class ContentView;
@class ContentScrollView;
@class CalendarADE;
@class TaskOutlineView;
@class TaskView;
@class Task;
@class HPGrowingTextView;

@interface CalendarViewController : PageAbstractViewController<UITextFieldDelegate> {

	//ContentView *contentView;
	
	UIButton *selectedTabButton;
	
    ContentScrollView *calendarView;
    CalendarADEView *adeView;
    UIImageView *adeSeparatorImgView;
    
    CalendarScrollPageLayoutController *calendarLayoutController;

	ScheduleView *yesterdayScheduleView;
	ScheduleView *todayScheduleView;
    ScheduleView *tomorrowScheduleView;
    
	UIView *barPlaceHolder;
	UIToolbar *taskActionToolBar;	
	
	UIView *timePlaceHolder;
	UILabel *suggestedTimeLabel;
	UIView *hintView;
	
	//UITextField *quickAddTextField;
    HPGrowingTextView *quickAddTextView;
    TaskView *quickAddBackgroundView;
	UIBarButtonItem *addButton;
	DateJumpView *dateJumpView;
	FilterView *filterView;
	UIButton *titleView;
	
	UIImageView *filterModeView;
	UIView *menuView;
	UIImageView *menuImageView;
    
    UIView *addMenuView;
    UIImageView *addMenuImageView;
	
	TaskOutlineView *outlineView;
	
	UIAlertView *wpAlertView;
	
	UIActivityIndicatorView *autoSyncIndicatorView;
	
}

@property (nonatomic, readonly) UIScrollView *calendarView;
@property (nonatomic, readonly) CalendarScrollPageLayoutController *calendarLayoutController;
@property (nonatomic, readonly) ScheduleView *todayScheduleView;

-(id) initWithTabBar;
- (void) refreshFrame;
- (void)refreshView;
-(void)setNeedsDisplay;
- (void) moveWeekPlanner:(CGFloat) dy;
- (void) doWeekPlannerAction:(NSInteger)action;
- (void) syncComplete;
- (void) jumpToDate:(NSDate *)date;
-(void)showQuickAdd:(NSDate *)timeSlot;
- (void) enableActions:(BOOL)enable onView:(TaskView *)view;
- (void) editTask:(Task *)task;
- (void) copyTask: (id) sender;
- (void)beginResize:(TaskView *)view;
- (void) confirmDeleteTask: (id) sender;
-(void)confirmMarkDone: (id) sender;
- (void) showToday:(id)sender;
- (void) showDateJumper:(id)sender;
- (void) showFilterView:(id)sender;
- (void) enableWeekPlannerActionsForView:(TaskView *)taskView;
- (void) doWeekPlannerAction:(NSInteger)action forTask:(Task *)task;
//- (void) resizeView;
-(void)showTaskDrawer;
-(void)hideDTaskView;
-(void) hideBars;
-(void)deselect;
-(void)refreshLayout;
- (void)finishResize;
- (void) refreshTaskView4Key:(NSInteger)taskKey;

//- (void) showADEView:(BOOL)hidden;
- (void) refreshADEPane;
//- (void) garbageADEList;
- (void) focusNow;

- (void)refreshPanes;

@end
