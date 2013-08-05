//
//  AbstractSDViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 12/4/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AbstractActionViewController.h"

@class Task;

@class ContentView;
@class MiniMonthView;
@class FocusView;
@class MovableView;
@class TaskView;
@class NoteView;
@class PlanView;

@class PageAbstractViewController;

@interface AbstractSDViewController : AbstractActionViewController
{
    UISegmentedControl *filterSegmentedControl;
    
    MiniMonthView *miniMonthView;
    FocusView *focusView;
    
    PageAbstractViewController *viewCtrlers[4];
}

@property (nonatomic, readonly) MiniMonthView *miniMonthView;
@property (nonatomic, readonly) FocusView *focusView;

- (void) refreshView;
- (void) setNeedsDisplay;
- (void) resetAllData;
- (void) refreshData;
- (void) hideDropDownMenu;
- (void) hidePopover;
- (void) hidePreview;
- (void) deselect;
- (void) scrollToDate:(NSDate *)date;
- (void) jumpToDate:(NSDate *)date;
- (void) applyFilter;

- (void) enableActions:(BOOL)enable onView:(MovableView *)view;
- (void) enableCategoryActions:(BOOL)enable onView:(PlanView *)view;

- (void) starTaskInView:(TaskView *)taskView;
- (void) markDoneTaskInView:(TaskView *)view;

- (NSString *) showTaskWithOption:(id)sender;
- (NSString *) showNoteWithOption:(id)sender;
- (NSString *) showProjectWithOption:(id)sender;

- (void) autoPush;
- (void) backup;
- (void) sync;

@end
