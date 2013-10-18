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
//@class SmartListLayoutController;
@class TaskLayoutController;
@class DayManagerView;
@class ContentView;
//@class ContentScrollView;
@class ContentTableView;
@class FilterView;
@class GuideWebView;
@class TaskView;
@class ProgressIndicatorView;
@class Task;

@interface SmartListViewController : PageAbstractViewController<UIScrollViewDelegate, UITextFieldDelegate> {
	//SmartListLayoutController *smartListLayoutController;
    TaskLayoutController *layoutController;
	
	DayManagerView *dayManagerView;
    //ContentScrollView *smartListView;
    ContentTableView *smartListView;
	
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

//@property (nonatomic, readonly) SmartListLayoutController *smartListLayoutController;
@property (nonatomic, readonly) TaskLayoutController *layoutController;
//@property (nonatomic, retain) UIView *quickAddPlaceHolder;

//Quick Add
@property NSInteger quickAddOption;
@property (nonatomic, assign) IBOutlet UIToolbar *quickAddOptionToolbar;
- (IBAction) selectQuickAddOption:(id)sender;
- (IBAction)saveAndMore:(id) sender;

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
- (void) enableMultiEdit:(BOOL)enabled;

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
- (void) multiDelete:(id)sender;
- (void) multiDone:(id)sender;
- (void)multiMarkStar: (id)sender;
- (void)multiMoveTop: (id)sender;
- (void)multiDefer: (id)sender;
- (void)createLink: (id)sender;

- (void) filter:(NSInteger)filterType;

- (void) changeFrame:(CGRect)frm;
//- (void) resetMovableController:(BOOL)forPlanner;

- (void) refreshQuickAddColor;

@end
