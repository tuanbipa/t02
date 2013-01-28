//
//  SmartDayViewController.h
//  SmartCal
//
//  Created by Left Coast Logic on 6/15/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AbstractSDViewController.h"

#define TAB_NUM 4

@class Task;
@class Project;

//@class ContentView;
//@class MiniMonthView;
@class MovableView;
@class PlanView;
@class TaskView;
@class FilterView;
@class DateJumpView;
@class LinkPreviewPane;

/*
@class CalendarViewController;
@class SmartListViewController;
@class NoteViewController;
@class CategoryViewController;
@class PageAbstractViewController;
*/

@interface SmartDayViewController : AbstractSDViewController
{
    //ContentView *contentView;
    ContentView *moduleView;
    
    UIView *navigationView;
    
    UIView *addMenuView;
    UIImageView *addMenuImageView; 
    
    UIView *menuView;
    UIImageView *menuImageView;
    
    //UIView *optionView;
    //UIImageView *optionImageView;
    
    //MiniMonthView *miniMonthView;
    
    FilterView *filterView;
    DateJumpView *dateJumpView;
    UIImageView *filterIndicator;
    
    LinkPreviewPane *previewPane;
    //MovableView *activeView;
    
    UIButton *topButton;
    
    UIButton *selectedTabButton;
    
    //PageAbstractViewController *viewCtrlers[TAB_NUM];
    
    UIButton *tabButtons[TAB_NUM];
    
    BOOL firstTimeLoad;

    //Task *task2Link;
}

@property (nonatomic, retain) UIViewController *activeViewCtrler;
//@property (nonatomic, readonly) MiniMonthView *miniMonthView;
@property (nonatomic, readonly) ContentView *contentView;
@property (nonatomic, readonly) FilterView *filterView;
@property (nonatomic, readonly) LinkPreviewPane *previewPane;

//@property (nonatomic, retain) Task *task2Link;

-(void) switchView:(NSInteger)idx;
- (CalendarViewController *) getCalendarViewController;
- (SmartListViewController *) getSmartListViewController;
- (NoteViewController *) getNoteViewController;
- (CategoryViewController *) getCategoryViewController;

- (void) enableCategoryActions:(BOOL)enable onView:(PlanView *)view;
- (void) copyCategory;
- (void) deleteCategory;
- (void) editCategory:(Project *) project;

- (void) enableActions:(BOOL)enable onView:(TaskView *)view;
- (void) editTask:(Task *)task;
- (void) deleteTask;
- (void) copyTask;
- (void) markDoneTask;
- (void) changeItem:(Task *)task action:(NSInteger)action;
- (void) hideDropDownMenu;
- (void) showBusyIndicator:(BOOL)enable;
- (void) jumpToDate:(NSDate *)date;
- (void) scrollToDate:(NSDate *)date;
-(void) deselect;
- (void) showCalendarView;
- (void) markDoneTaskInView:(TaskView *)view;
- (void) starTaskInView:(TaskView *)taskView;

- (void) copyLink;
- (void) pasteLink;
- (void) applyFilter;
- (void) refreshFilterTag;
- (void) refreshData;
- (void) resetAllData;
- (BOOL) checkFocus;
- (void) hideMiniMonth;
- (void) hidePreview;
- (void) expandPreview;
- (void) setNeedsDisplay;
- (void) refreshView;
- (void) popupHint;

@end
