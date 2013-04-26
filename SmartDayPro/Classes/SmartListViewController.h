//
//  SmartListViewController.h
//  SmartCal
//
//  Created by Trung Nguyen on 5/13/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PageAbstractViewController.h"

@class SmartListMovableController;
@class SmartListLayoutController;
@class DayManagerView;
@class ContentView;
@class ContentScrollView;
@class FilterView;
@class GuideWebView;
@class TaskView;
@class ProgressIndicatorView;
@class Task;

@interface SmartListViewController : PageAbstractViewController<UIScrollViewDelegate, UITextFieldDelegate> {
	SmartListLayoutController *smartListLayoutController;
	
	DayManagerView *dayManagerView;
    ContentScrollView *smartListView;
	
    UIView *maskView;
	UIView *barPlaceHolder;
	UIToolbar *taskActionToolBar;
	
	UIBarButtonItem *addButtonItem;	
	UIBarButtonItem *moreButtonItem;
	UIView *quickAddPlaceHolder;
	UITextField *quickAddTextField;
	
	UIView *timePlaceHolder;
	UILabel *suggestedTimeLabel;
	
	UIView *hintView;
	GuideWebView *hintLabel;
	
	UIButton *menuButton;
	UIView *menuView;
	UIImageView *menuImageView;

	UIView *multiSelectionMenuView;
	UIImageView *multiSelectionMenuImageView;
	
	FilterView *filterView;
	
	//BOOL inTaskEditMode;
	
	UIView *tabPane;
	UIButton *selectedTabButton;
	
	UIBarButtonItem *editButtonItem;
	UIBarButtonItem *cancelButtonItem;
	
    UIButton *doneButton;
	UIView *editBarPlaceHolder;
    //UIToolbar *editToolbar;
    UIView *quickAddEditBarView;
    UIBarButtonItem *saveAndMoreItem;
	
	UIActivityIndicatorView *busyIndicatorView;
	
	BOOL firstLoad;
}

@property (nonatomic, readonly) SmartListLayoutController *smartListLayoutController;

-(id) init4Planner;
-(id) initWithTabBar;
- (void) refreshData;
- (void) tabBarChanged:(BOOL)mini;
-(void)deselect;
-(void)changeSkin;
- (void)clearLayout;
-(void)refreshLayout;
- (void) backToSingleSelectMode;
- (void) refreshSmartList:(BOOL) needSchedule;
-(void)setNeedsDisplay;

- (void) starTaskInView:(TaskView *)taskView;
- (void) pinTaskInView:(TaskView *)taskView;
- (void) enableActions:(BOOL)enable onView:(TaskView *)view;
- (void) editTask:(Task *)task;
- (void) copyTask: (id) sender;
-(void) hideBars;
- (void) hideQuickAdd;
-(void) cancelQuickAdd;

- (void) confirmDeleteTask: (id) sender;
-(void)confirmMarkDone: (id) sender;
-(void)refreshView;
-(void) syncComplete;

- (void) multiEdit:(BOOL)enabled;
- (void) multiDelete;
- (BOOL)isInMultiEditMode;

- (void) refreshTaskView4Key:(NSInteger)taskKey;
- (void) filter:(NSInteger)filterType;

- (void) changeFrame:(CGRect)frm;
- (void) resetMovableController:(BOOL)forPlanner;

@end
