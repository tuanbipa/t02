//
//  AbstractActionViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 4/10/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Project;
@class Task;
@class MovableView;
@class ContentView;
@class TaskView;
@class PlanView;
@class AbstractMonthCalendarView;
@class FocusView;
@class MiniMonthView;
@class PlannerBottomDayCal;

@class PageAbstractViewController;
@class CalendarViewController;
@class SmartListViewController;
@class NoteViewController;
@class CategoryViewController;

@interface AbstractActionViewController : UIViewController
{
    ContentView *contentView;
    
    MovableView *activeView;
    
    UIView *optionView;
    UIImageView *optionImageView;
    
    //Task *actionTask;
    //Task *actionTaskCopy;
}

@property (nonatomic, retain) Task *task2Link;
@property (nonatomic, retain) Task *actionTask;
@property (nonatomic, retain) Task *actionTaskCopy;

@property (nonatomic, retain) MovableView *activeView;
@property (nonatomic, readonly) ContentView *contentView;

@property (nonatomic, retain) UIPopoverController *popoverCtrler;

- (BOOL) checkControllerActive:(NSInteger)index;
- (CalendarViewController *) getCalendarViewController;
- (SmartListViewController *) getSmartListViewController;
- (NoteViewController *) getNoteViewController;
- (CategoryViewController *) getCategoryViewController;
- (AbstractMonthCalendarView *)getMonthCalendarView;
- (AbstractMonthCalendarView *)getPlannerMonthCalendarView;
- (PlannerBottomDayCal *) getPlannerDayCalendarView;
- (FocusView *) getFocusView;
- (MiniMonthView *) getMiniMonth;
- (void) resetMovableContentView;

- (MovableView *) getActiveView4Item:(NSObject *)item;
- (PageAbstractViewController *)getActiveModule;
- (PageAbstractViewController *)getModuleAtIndex:(NSInteger)index;

- (void) updateTask:(Task *)task withTask:(Task *)taskCopy;
- (void) markDoneTask:(Task *)task;
//- (void) changeItem:(Task *)task;
- (void) reconcileItem:(Task *)item reSchedule:(BOOL)reSchedule;

- (void) convertRE2Task:(NSInteger)option task:(Task *)task;
- (void) convert2Task:(Task *)task;
- (void) changeTime:(Task *)task time:(NSDate *)time;
- (void) changeTask:(Task *)task toProject:(NSInteger)prjKey;
- (void) quickAddEvent:(NSString *)name startTime:(NSDate *)startTime;
- (void) quickAddItem:(NSString *)name type:(NSInteger)type defer:(NSInteger)defer;
- (void) quickAddProject:(NSString *)name;
- (void) createTaskFromNote:(Task *)fromNote;

- (void) editItem:(Task *)item;
- (void) editItem:(Task *)task inRect:(CGRect)inRect;
- (void) editItem:(Task *)item inView:(TaskView *)inView;

- (void) editProject:(Project *)project inView:(PlanView *)inView;
- (void) editProject:(Project *)project inRect:(CGRect)inRect;

- (void) hidePopover;
- (void) hideDropDownMenu;
- (void) showOptionMenu;
- (void) deselect;
- (void) setNeedsDisplay;
- (void) resetAllData;
- (void) refreshData;
- (void) applyFilter;
- (void) showModuleByIndex:(NSInteger)index;

- (void) showSeekOrCreate:(NSString *)text;
- (void) createItem:(NSInteger)index title:(NSString *)title;

- (void) markDoneTask;
- (void) deleteTask;
- (Task *) copyTask;
- (void) starTask;
- (void) moveTask2Top;
- (void) defer:(NSInteger)option;
- (Project *) copyCategory;
- (void) deleteCategory;
- (void) deleteNote:(Task *)note;
- (void) share2AirDrop;

- (void) showCategory;
- (void) showUnreadComments;
- (void) showTag;
- (void) showTimer;
- (void) showSettingMenu;
// cancel multi edit
- (void)cancelEdit;

- (void) backup;
- (void) sync;
- (void) autoPush;


@end
