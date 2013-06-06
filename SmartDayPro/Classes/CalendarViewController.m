    //
//  CalendarViewController.m
//  SmartCal
//
//  Created by MacBook Pro on 3/21/11.
//  Copyright 2011 LCL. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "CalendarViewController.h"

#define NAVIGATION_HEIGHT 20

#import "Common.h"
#import "Colors.h"
#import "Settings.h"
#import "TaskManager.h"
#import "DBManager.h"
#import "ProjectManager.h"
#import "TaskLinkManager.h"
#import "ImageManager.h"
#import "ScheduleView.h"
#import "Project.h"
#import "Task.h"
#import "TaskView.h"
#import "TaskLinkView.h"
#import "TimeSlotView.h"
#import "DateJumpView.h"
#import "FilterView.h"
#import "ContentView.h"
#import "ContentScrollView.h"
#import "TodayLine.h"
#import "GuideWebView.h"
#import "MiniMonthView.h"
#import "MonthlyCalendarView.h"
#import "HighlightView.h"
#import "TaskOutlineView.h"
#import "CalendarADEView.h"
#import "MiniMonthView.h"
#import "MiniMonthHeaderView.h"
#import "FocusView.h"
#import "HPGrowingTextView.h"

#import "CalendarMovableController.h"
//#import "CalendarLayoutController.h"
#import "CalendarScrollPageLayoutController.h"

#import "TaskDetailTableViewController.h"
#import "SettingTableViewController.h"
#import "CalendarSelectionTableViewController.h"

#import "EKSync.h"
#import "ProgressIndicatorView.h"
#import "TDSync.h"

#import "BusyController.h"

#import "SmartListViewController.h"
#import "NoteDetailTableViewController.h"

#import "SmartCalAppDelegate.h"
#import "iPadSmartDayViewController.h"

NSInteger _recoverCount = 1;

extern BOOL _calendarHintShown;
extern BOOL _featureHintShown;
extern BOOL _syncMatchHintShown;
extern BOOL _firstTimeEventSyncHintShown;

//extern SCTabBarController *_tabBarCtrler;
extern BOOL _appDidStartup;
extern BOOL _navigationTabChanged;
extern BOOL _scFreeVersion;

extern BOOL _isiPad;

extern SmartCalAppDelegate *_appDelegate;
extern iPadSmartDayViewController *_iPadSDViewCtrler;
extern AbstractSDViewController *_abstractViewCtrler;

CalendarViewController *_sc2ViewCtrler;

@implementation CalendarViewController

@synthesize calendarView;
@synthesize calendarLayoutController;
@synthesize todayScheduleView;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

-(id) init 
{
	if (self = [super init]) 
	{
		movableController = [[CalendarMovableController alloc] init];
		//calendarLayoutController = [[CalendarLayoutController alloc] init];
        calendarLayoutController = [[CalendarScrollPageLayoutController alloc] init];
		calendarLayoutController.movableController = movableController;

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(dayManagerReady:)
													 name:@"DayManagerReadyNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(fastScheduleFinished:)
													 name:@"FastScheduleFinishedNotification" object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(calendarDayReady:)
													 name:@"CalendarDayReadyNotification" object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(calendarDayChange:)
													 name:@"CalendarDayChangeNotification" object:nil];
        
/*		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(scheduleFinished:)
													 name:@"ScheduleFinishedNotification" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(calendarDayReset:)
													 name:@"CalendarDayResetNotification" object:nil];
 
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(miniMonthResize:)
													 name:@"MiniMonthResizeNotification" object:nil];
*/        
	}
	
	return self;	
}

-(id) initWithTabBar {
	if ([self init]) {
		//this is the label on the tab button itself
		self.title = _calendarText;

		self.tabBarItem.image = [[ImageManager getInstance] getImageWithName:@"calendar.png"];
		
		// set the long name shown in the navigation bar
		//self.navigationItem.title=@"Calendar";
	}
	return self;
}

- (void)dealloc 
{	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[movableController release];
	[calendarLayoutController release];
	
	[hintView release];
	
    [super dealloc];
}

- (void) reconcileItem:(Task *)item
{
    if (([item isTask] || [item isEvent]) && [_abstractViewCtrler checkControllerActive:0])
    {
        if (item.listSource == SOURCE_CALENDAR)
        {
            [self refreshTaskView4Key:item.primaryKey];
        }
        else
        {
            [self refreshLayout];
        }
    }
}

#pragma mark Support
-(void)showAutoSyncProgress:(BOOL)enabled
{
	if (enabled)
	{
		if (autoSyncIndicatorView.hidden)
		{
			[autoSyncIndicatorView startAnimating];
		}
	}
	else 
	{
		[autoSyncIndicatorView stopAnimating];		
	}
	
	autoSyncIndicatorView.hidden = !enabled;
}

-(void)changeSkin
{    
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    
    [todayScheduleView changeSkin];
}

-(void)refreshLayout
{
	[movableController unhighlight];
	
	[movableController reset];
    
    [calendarLayoutController layout];
}

- (void) refreshADEPane
{
    [adeView refreshData];
    
    [self refreshFrame];
}

- (void) refreshCalendarDay
{
    [todayScheduleView refreshDayManagerView];
    
    todayScheduleView.todayLineHidden = [Common compareDateNoTime:[[TaskManager getInstance] today] withDate:[NSDate date]] != NSOrderedSame;
    
    [todayScheduleView refreshTodayLine];
}

- (void)refreshView
{	
	if (filterView.userInteractionEnabled == YES)
	{
		[filterView tagInputReset];
	}
	 
    [self refreshCalendarDay];
		
	[self refreshLayout];	
}

-(void)setNeedsDisplay
{
	for (UIView *view in calendarView.subviews)
	{
        if ([view isKindOfClass:[TaskView class]])
        {
            [view refresh];
        }
	}
}

- (void) refreshFrame
{
    MiniMonthView *miniMonthView = _abstractViewCtrler.miniMonthView;
    FocusView *focusView = _abstractViewCtrler.focusView;
    
    BOOL adeVisible = adeView.adeList != nil && adeView.adeList.count > 0 && _isiPad?NO:miniMonthView.hidden;
    
    CGFloat mmH = miniMonthView.hidden?0:miniMonthView.frame.origin.y+miniMonthView.frame.size.height;
    CGFloat focusH = _isiPad?(focusView.hidden?0:focusView.bounds.size.height):0;
    CGFloat adeH = adeVisible?adeView.bounds.size.height:0;
    
    CGRect frm = contentView.bounds;
	
	frm.origin.y = mmH + adeH + focusH; //+ (_isiPad?10:0);
    frm.size.height -= mmH + adeH + focusH; //+ (_isiPad?20:0);
    
    calendarView.frame = frm;
    
    frm = adeView.frame;
    frm.origin.y = mmH;
    
    adeView.frame = frm;
    
    frm = adeSeparatorImgView.frame;
    frm.origin.y = adeH-6;
    frm.size.height = 6;
    
    adeSeparatorImgView.frame = frm;
    
    adeView.hidden = !adeVisible;
    adeSeparatorImgView.hidden = !adeVisible;
}

-(void)showSuggestedTime
{
	if (suggestedTimeLabel.hidden == YES)
	{
		suggestedTimeLabel.hidden = NO;
		
		CATransition *animation = [CATransition animation];
		[animation setDelegate:self];
		
		[animation setType:kCATransitionMoveIn];
		[animation setSubtype:kCATransitionFromLeft];
		
		// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
		[animation setDuration:kTransitionDuration];
		[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
		
		[[timePlaceHolder layer] addAnimation:animation forKey:kInfoViewAnimationKey];		
	}
}

-(void)hideSuggestedTime
{
	if (suggestedTimeLabel.hidden == NO)
	{
		suggestedTimeLabel.hidden = YES;
		
		CATransition *animation = [CATransition animation];
		[animation setDelegate:self];
		
		[animation setType:kCATransitionReveal];
		[animation setSubtype:kCATransitionFromLeft];
		
		// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
		[animation setDuration:kTransitionDuration];
		[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
		
		[[timePlaceHolder layer] addAnimation:animation forKey:kInfoViewAnimationKey];		
	}
}

- (void) hideDropDownMenu
{
	if (!menuView.hidden)
	{
		[Common animateShrinkView:menuView toPosition:CGPointMake(0,0) target:self shrinkEnd:@selector(shrinkEnd)];
	}
    
	if (!addMenuView.hidden)
	{
		[Common animateShrinkView:addMenuView toPosition:CGPointMake(320,0) target:self shrinkEnd:@selector(shrinkEnd)];
	}
}

-(void) hideBars
{
	[[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
	[self hideSuggestedTime];
	
	[dateJumpView popDownView];
	[self hideDropDownMenu];
}

- (void) stopResize
{
	outlineView.hidden = YES;
	
	calendarView.scrollEnabled = YES;
	calendarView.userInteractionEnabled = YES;		
}

- (void) stopQuickAdd
{
    quickAddTextView.text = @"";
        
    [quickAddTextView resignFirstResponder];
}

-(void)deselect
{
    [super deselect];
	
    suggestedTimeLabel.hidden = YES;
    
	[self stopResize];
    [self stopQuickAdd];
}

- (void) showAddMenu: (id) sender
{
	[self deselect];
	
	if (addMenuView.hidden)
	{		
		addMenuView.hidden = NO;
		[contentView  bringSubviewToFront:addMenuView];
		
		[Common animateGrowViewFromPoint:CGPointMake(320,0) toPoint:CGPointMake(220, 50) forView:addMenuView];
	}
	else 
	{
		[Common animateShrinkView:addMenuView toPosition:CGPointMake(320,0) target:self shrinkEnd:@selector(shrinkEnd)];
	}
}

- (void) showDropDownMenu: (id) sender
{
	[self deselect];
	
	if (menuView.hidden)
	{
		UILabel *label = (UILabel *)[menuView viewWithTag:10000 + TASK_FILTER_GLOBAL];
		
		if (label != nil)
		{
			label.textColor = ([[TaskManager getInstance] filterData] == nil?[UIColor whiteColor]:[UIColor yellowColor]);
		}
		
		addButton.enabled = NO;
		
		menuView.hidden = NO;
		[contentView  bringSubviewToFront:menuView];
		
		[Common animateGrowViewFromPoint:CGPointMake(0,0) toPoint:CGPointMake(80, 125) forView:menuView];
	}
	else 
	{
		[Common animateShrinkView:menuView toPosition:CGPointMake(0,0) target:self shrinkEnd:@selector(shrinkEnd)];
	}
}

- (void) editTask:(Task *)task
{
	TaskDetailTableViewController *ctrler = [[TaskDetailTableViewController alloc] init];
	
	ctrler.task = task;	
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];		
}

- (void) markDoneTask
{
	TaskView *taskView = movableController.activeMovableView;
	
    Task *task = taskView.task;
	
	if (task.original != nil)
	{
		task = task.original;
	}
	
	[task retain];
	
	[calendarLayoutController removeView:taskView];
	
	[self deselect];
	
	[[TaskManager getInstance] markDoneTask:task];

	[task release];
}

-(void) deleteRE:(NSInteger)deleteOption
{
	TaskView *taskView = movableController.activeMovableView;
	
    Task *task = taskView.task;
	
	[task retain];
	
	[calendarLayoutController removeView:taskView];
	
	[self deselect];
	
	[[TaskManager getInstance] deleteREInstance:task deleteOption:deleteOption];
	    
	[task release];
		
	[self refreshLayout];	
}

-(void)popUpToolbar
{
	barPlaceHolder.userInteractionEnabled = YES;
	taskActionToolBar.hidden = NO;
	
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	
	[animation setType:kCATransitionMoveIn];
	[animation setSubtype:kCATransitionFromTop];
	
	// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
	[animation setDuration:kTransitionDuration];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[barPlaceHolder layer] addAnimation:animation forKey:kInfoViewAnimationKey];	
}

-(void)popDownToolbar
{
	barPlaceHolder.userInteractionEnabled = NO;
	taskActionToolBar.hidden = YES;
	
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	
	[animation setType:kCATransitionReveal];
	[animation setSubtype:kCATransitionFromBottom];
	
	// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
	[animation setDuration:kTransitionDuration];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[barPlaceHolder layer] addAnimation:animation forKey:kInfoViewAnimationKey];	
}

- (void) enableActions:(BOOL)enable onView:(TaskView *)view
{
    Task *task = view.task;
    
	UIMenuController *menuCtrler = [UIMenuController sharedMenuController];	
	
	[self hideSuggestedTime];
	
	if (enable)
	{
		CGRect frm = view.frame;
		
		NSString *timeStr = nil;

        if (task.type == TYPE_EVENT || (task.type == TYPE_TASK && task.original != nil)) //event or task in calendar
		{
			NSDate *smartTime = (task.type == TYPE_TASK?task.smartTime:task.startTime);
			
			timeStr = [NSString stringWithFormat:@"[%@ - %@]: %@", [Common getShortTimeString:smartTime], [Common getShortTimeString:task.endTime], task.name];
		}
		
		frm.origin = [view.superview convertPoint:frm.origin toView:contentView];
		
		if (timeStr != nil)
		{
			timePlaceHolder.tag = view;
			suggestedTimeLabel.text = timeStr;
		}
		
		contentView.actionType = (task.type == TYPE_TASK?0:4);
		[contentView becomeFirstResponder];		
		[menuCtrler setTargetRect:frm inView:contentView];
		[menuCtrler setMenuVisible:YES animated:YES];
		
		
		if (timeStr)
		{
			[self showSuggestedTime];
		}
	}
	else 
	{
		[menuCtrler setMenuVisible:NO animated:YES];
	}
	
}

- (void) enableADEActions:(BOOL)enable
{
	[self hideSuggestedTime];
	
	UIMenuController *menuCtrler = [UIMenuController sharedMenuController];
	
	if (enable)
	{
		contentView.actionType = 6;
		[contentView becomeFirstResponder];		
		[menuCtrler setTargetRect:CGRectMake(0, 0, 320, ADE_VIEW_HEIGHT) inView:contentView];
		[menuCtrler setMenuVisible:YES animated:YES];		
	}
	else 
	{
		[menuCtrler setMenuVisible:NO animated:YES];
	}	
}

- (void) refreshTodayView
{
	[self refreshLayout];
}

- (void) focusNow
{
    CGSize sz = [Common getScreenSize];
    
    CGFloat h = sz.height - calendarView.frame.origin.y - 40;
    
    CGFloat y = [todayScheduleView getTodayLineY] - h/2;
    
    CGPoint contentOffset = calendarView.contentOffset;
    
    contentOffset.x = calendarView.bounds.size.width;//show page 1
    contentOffset.y = (y<0?0:y);
    
    calendarView.contentOffset = contentOffset;
}

- (void) refreshViewAfterScrolling
{
	TaskView *activeView = (TaskView *)movableController.activeMovableView;	
	
	if (activeView != nil && timePlaceHolder.tag == activeView)
	{
		CGRect frm = timePlaceHolder.frame;
		
		frm.origin.y = activeView.frame.origin.y - calendarView.contentOffset.y + 2;
		
		timePlaceHolder.frame = frm;
		
		[self showSuggestedTime];
	}
}

- (void) showDateJumper:(id)sender
{
	[self hideDropDownMenu];
	
	if (dateJumpView.userInteractionEnabled == YES)
	{
		[dateJumpView popDownView];
		
		calendarView.userInteractionEnabled = YES;
	}
	else
	{		
		[dateJumpView popUpView];		
		
		calendarView.userInteractionEnabled = NO;
	}	
}

- (void) refreshTaskView4Key:(NSInteger)taskKey
{
	for (UIView *view in calendarView.subviews)
	{
		if ([view isKindOfClass:[TaskView class]])
		{
            TaskView *taskView = (TaskView *) view;
                        
            Task *task = taskView.task;
            
            if (task.original != nil && ![task isREException])
            {
                task = task.original;
            }
            
            if (task.primaryKey == taskKey)
            {
                [taskView setNeedsDisplay];
                [taskView refreshStarImage];
                [taskView refreshCheckImage];

                break;
            }
		}
	}
}

- (void)beginResize:(TaskView *)view
{
    outlineView.tag = view.task;
	
	CGRect frm = view.frame;
	
	frm.origin = [view.superview convertPoint:frm.origin toView:contentView];
	
	[outlineView changeFrame:frm];
	
	outlineView.hidden = NO;
	
	calendarView.scrollEnabled = NO;
	calendarView.userInteractionEnabled = NO;
}

- (void)finishResize
{
	Task *task = (Task *)outlineView.tag;
    
    [task retain];
	
	int segments = [outlineView getResizedSegments];
	
	if (segments != 0 && outlineView.handleFlag != 0)
	{
		if ([task isEvent])
		{
			if (outlineView.handleFlag == 1)
			{
				task.startTime = [Common dateByAddNumSecond:-segments*15*60 toDate:task.startTime];
			}
			else if (outlineView.handleFlag == 2)
			{
				task.endTime = [Common dateByAddNumSecond:segments*15*60 toDate:task.endTime];
			}			
		}
		else if ([task isTask])
		{
			if (task.original != nil)
			{
				task = task.original;
			}
			
			task.duration += segments*15*60;
		}

		[[TaskManager getInstance] resizeTask:task];
	}
    
    [_abstractViewCtrler reconcileItem:task reSchedule:YES];

	[self stopResize];
    
    [task release];
}

- (void) reloadAlert4Task:(NSInteger)taskId
{
    NSArray *list = [calendarLayoutController getObjectList];
    
    for (Task *task in list)
    {
        if (task.original == nil || [task isREException])
        {
            if (task.primaryKey == taskId)
            {
                task.alerts = [[DBManager getInstance] getAlertsForTask:task.primaryKey];
                
                break;
            }
        }
    }
    
    [adeView reloadAlert4Task:taskId];
}

#pragma mark Quick Add
-(void)showQuickAdd:(NSDate *)timeSlot
{
    MiniMonthView *mm = _abstractViewCtrler.miniMonthView;
    
    if ([mm.headerView getMWMode] == 0 && !_isiPad) //im month mode
    {
        [mm.headerView changeMWMode:1];
    }
    
	calendarView.scrollEnabled = NO;
	calendarView.userInteractionEnabled = NO;
	
	CGFloat ymargin = TIME_SLOT_HEIGHT/2;
	
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSDateComponents *comps = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:timeSlot];
	NSInteger hour = [comps hour];
	NSInteger minute = [comps minute];
	
	NSInteger slotIdx = 2*hour + minute/30;
	
    CGRect frm = quickAddBackgroundView.frame;
	
	frm.origin.y = ymargin + slotIdx * TIME_SLOT_HEIGHT + 1;
	
	if (minute >= 30)
	{
		minute -= 30;
	}
	
	frm.origin.y += minute*TIME_SLOT_HEIGHT/30;
	
	CGPoint p = [calendarView convertPoint:frm.origin toView:contentView];
	p.x = frm.origin.x;
    
    CGFloat kbH = [Common getKeyboardHeight];
    CGSize sz = [Common getScreenSize];
    
    CGFloat visibleH = sz.height - kbH;
	CGPoint offset = calendarView.contentOffset;
	    
    if (p.y + frm.size.height > visibleH)
    {
        CGFloat dy = p.y + frm.size.height - visibleH + (_isiPad?60:40);
        offset.y += dy;
        p.y -= dy;
    }
    
	frm.origin = p;
	
	//quickAddTextField.frame = frm;
    quickAddBackgroundView.frame = frm;
    quickAddBackgroundView.hidden = NO;
    [quickAddBackgroundView setNeedsDisplay];
    
/*
    quickAddTextField.frame = frm;
	
	quickAddTextField.text = @"";
	quickAddTextField.tag = [timeSlot timeIntervalSince1970];
	
	[quickAddTextField becomeFirstResponder];
*/
    //quickAddTextView.frame = frm;
    quickAddTextView.text = @"";
    quickAddTextView.tag = [timeSlot timeIntervalSince1970];
    [quickAddTextView becomeFirstResponder];
	
	addButton.enabled = NO;
    
    calendarView.contentOffset = offset;
}

/*
-(void)quickAdd:(NSString *)name startTime:(NSDate *)startTime
{
	//////printf("quick add - %s, start: %s\n", [name UTF8String], [[startTime description] UTF8String]);
	
	Task *event = [[Task alloc] init];
	
	event.name = name;
	event.startTime = startTime;
	event.endTime = [Common dateByAddNumSecond:3600 toDate:event.startTime];
	
	event.type = TYPE_EVENT;
	
	[[TaskManager getInstance] addTask:event];
	
	[event release];
	
    [_abstractViewCtrler.miniMonthView.calView refreshCellByDate:startTime];
	
	[self refreshLayout];	
}
*/

#pragma mark Hint 
- (void) popupHint
{
	Settings *settings = [Settings getInstance];
	
	BOOL showHint = settings.calendarHint && !_calendarHintShown;
	
	if (showHint)
	{
		_calendarHintShown = YES;
		
		UIViewController *ctrler = [[UIViewController alloc] init];
		ctrler.view = hintView;
		
        ctrler.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:ctrler animated:YES completion:NULL];
        
	}
}

- (void) hint: (id) sender
{
	Settings *settings = [Settings getInstance];
	
	if ([sender tag] == 10001) //Don't Show
	{		
		[settings enableCalendarHint:NO];
		
	}
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark Actions

- (void) addNote:(id) sender
{
    NoteDetailTableViewController *ctrler = [[NoteDetailTableViewController alloc] init];
    
	Task *newNote = [[Task alloc] init];
	newNote.type = TYPE_NOTE;  
    newNote.startTime = [NSDate date];
    
    ctrler.note = newNote;
    [newNote release];
    
    [self.navigationController pushViewController:ctrler animated:YES];
    [ctrler release];
}

- (void) addTask:(id) sender
{
	TaskDetailTableViewController *ctrler = [[TaskDetailTableViewController alloc] init];
	
	Task *newTask = [[Task alloc] init];
	newTask.type = TYPE_EVENT;
	
	newTask.startTime = [Common dateByRoundMinute:15 toDate:[[TaskManager getInstance] today]];
	newTask.endTime = [Common dateByAddNumSecond:3600 toDate:newTask.startTime];
	
	TaskManager *tm = [TaskManager getInstance];
	
	switch (tm.taskTypeFilter) 
	{
		case TASK_FILTER_STAR:
		{
			newTask.status = TASK_STATUS_PINNED;
		}
			break;
		case TASK_FILTER_DUE:
		{
			newTask.deadline = [NSDate date];
		}
			break;
	}	
	
	ctrler.task = newTask;
	
	[newTask release];
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];				
}

- (void) copyTask: (id) sender
{
	Task *task = [movableController getActiveTask];
	
    /*
	if (task == nil)
	{
		task = [adeView getActiveADE];
	}
	*/
    
	if (task.original != nil && ![task isREException])
	{
		task = task.original;
	}
	
	Task *taskCopy = [task copy];
	
	taskCopy.primaryKey = -1;
	taskCopy.name = [NSString stringWithFormat:@"%@ (copy)", taskCopy.name];
	
	TaskDetailTableViewController *ctrler = [[TaskDetailTableViewController alloc] init];
	
	ctrler.task = taskCopy;
	
	[taskCopy release];
	
	[self deselect];
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];			
	
}

-(void)confirmMarkDone: (id) sender
{
	if ([[Settings getInstance] doneWarning])
	{
		NSString *title = _taskMarkDoneTitle;
		NSString *msg = _taskMarkDoneText;
		
		Task *task = [movableController getActiveTask];
		
		if (task.status == TASK_STATUS_DONE)
		{
			title = _taskUnMarkDoneTitle;
			msg = _taskUnMarkDoneText;
		}
		
		UIAlertView *taskDoneAlertView = [[UIAlertView alloc] initWithTitle:title  message:msg delegate:self cancelButtonTitle:_cancelText otherButtonTitles:nil];
		taskDoneAlertView.tag = -10001;
		
		[taskDoneAlertView addButtonWithTitle:_okText];
		[taskDoneAlertView show];
		[taskDoneAlertView release];		
	}
	else 
	{
		[self markDoneTask];
	}
	
}

- (void) confirmDeleteTask: (id) sender
{
	Task *task = [movableController getActiveTask];
	
    /*
	if (task == nil)
	{
		task = [adeView getActiveADE];
	}
	*/
    
	if (task.original != nil && [task.original isRE]) //change RE
	{
		UIAlertView *deleteREAlert= [[UIAlertView alloc] initWithTitle:_deleteRETitleText  message:_deleteREInstanceText delegate:self cancelButtonTitle:_cancelText otherButtonTitles:nil];
		deleteREAlert.tag = -11000;
		[deleteREAlert addButtonWithTitle:_onlyInstanceText];
		[deleteREAlert addButtonWithTitle:_allEventsText];
		[deleteREAlert addButtonWithTitle:_allFollowingText];
		[deleteREAlert show];
		[deleteREAlert release];
	}
	else 
	{
		if ([[Settings getInstance] deleteWarning])
		{
			UIAlertView *taskDeleteAlertView = [[UIAlertView alloc] initWithTitle:_itemDeleteTitle  message:_itemDeleteText delegate:self cancelButtonTitle:_cancelText otherButtonTitles:nil];
			
			taskDeleteAlertView.tag = -10000;
			
			[taskDeleteAlertView addButtonWithTitle:_okText];
			[taskDeleteAlertView show];
			[taskDeleteAlertView release];				
		}
		else 
		{
			[self deleteTask];
		}
	}
}

- (void) showMenu:(id) sender
{
	if (dateJumpView.userInteractionEnabled)
	{
		[dateJumpView popDownView];
		
		calendarView.userInteractionEnabled = YES;
	}
	else if (filterView.userInteractionEnabled)
	{
		[filterView popDownView];
	}
	else 
	{
		CGRect frm = CGRectMake(0, 0, 320, 0);
		UIMenuController *menuCtrler = [UIMenuController sharedMenuController];
		
		contentView.actionType = 1;
		[contentView becomeFirstResponder];		
		[menuCtrler setTargetRect:frm inView:contentView];
		[menuCtrler setMenuVisible:YES animated:YES];
	}	
}

- (void) editSetting: (id) sender
{
	[self hideDropDownMenu];
	
	SettingTableViewController *ctrler = [[SettingTableViewController alloc] init];
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

- (void) showHideCategory: (id) sender
{
    [self hideDropDownMenu];
    
	CalendarSelectionTableViewController *ctrler = [[CalendarSelectionTableViewController alloc] init];
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];			
	
}

-(void)shrinkEnd
{
	menuView.hidden = YES;
    addMenuView.hidden = YES;
	
	addButton.enabled = YES;
}


- (void) showFilterView:(id)sender
{
	[self hideDropDownMenu];
	
	if (filterView.userInteractionEnabled == YES)
	{
		[filterView popDownView];
	}
	else
	{
		[filterView popUpView];	
	}	
}

- (void) tab:(id) sender
{
    //printf("test\n");
}

/*
-(void) swipeDown: (UISwipeGestureRecognizer *) gesture {
    
    if (gesture.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    //do something 
    FocusViewController *ctrler = [[FocusViewController alloc] init];
    
    //[self presentModalViewController:ctrler withPushDirection:kCATransitionFromBottom];
    ctrler.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:ctrler animated:YES completion:NULL];
    
    [ctrler release];    
    
}
*/

#pragma mark Sync

- (void) selectCalendarToSync:(NSMutableArray *)calList forTask:(BOOL)forTask
{
	CalendarSelectionTableViewController *ctrler = [[CalendarSelectionTableViewController alloc] init];
	
	ctrler.keyEdit = (forTask?TASK_MAPPING_EDIT:EVENT_MAPPING_EDIT);
	ctrler.calList = calList;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	
	[ctrler release];		
	
	UIAlertView *noMappingAlertView = [[UIAlertView alloc] initWithTitle:forTask?_toodledoSyncText:_eventSyncText  message:forTask?_noMatchTaskFolderText:_noMatchEventCalendarText delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
	
	[noMappingAlertView show];
	[noMappingAlertView release];	
}

- (void) syncNewCalendars:(NSTimer *)timer
{
	[[EKSync getInstance] syncNewCalendars:[timer userInfo]];
}

- (void) initSyncEK
{
	[[EKSync getInstance] initSync:SYNC_MANUAL_2WAY];
}

- (void) syncEK
{
	//[_appDelegate showProgress:_icalSyncingText];
	
	//[NSTimer scheduledTimerWithTimeInterval:0 target:[EKSync getInstance] selector:@selector(initSync) userInfo:nil repeats:NO];
	[self performSelector:@selector(initSyncEK) withObject:nil afterDelay:0];
}

- (void) sync:(id) sender
{
	[self hideDropDownMenu];
	
	//if ([[Settings getInstance] ekAutoSyncEnabled])
	//{
/*		BOOL showHint = [[Settings getInstance] firstTimeEventSyncHint];
		
		if (showHint && !_firstTimeEventSyncHintShown)
		{
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_hintText message:_1stTimeEventSyncHintText delegate:self cancelButtonTitle:_cancelText otherButtonTitles:nil];
			
			alertView.tag = -12000;
			
			[alertView addButtonWithTitle:_okText];	
			[alertView addButtonWithTitle:_dontShowText];
			
			[alertView show];
			[alertView release];
			
			_firstTimeEventSyncHintShown = YES;
		}
		else 
		{
			[self syncEK];
		}
*/		
	//}
	
	[self syncEK];
}

-(void)syncComplete
{
	[_appDelegate hideProgress];
	
	[self refreshView];
}

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertVw.tag == -10000 && buttonIndex == 1)
	{
		[self deleteTask];
	}
	else if (alertVw.tag == -10001 && buttonIndex == 1)
	{
		[self markDoneTask];
	}
	else if (alertVw.tag == -11000 && buttonIndex != 0) //not Cancel
	{
		[self deleteRE:buttonIndex];		
	}
	else if (alertVw.tag == -12000 && buttonIndex != 0) //not Cancel
	{
		if (buttonIndex == 2) //Don't Show
		{
			[[Settings getInstance] enableFirstTimeEventSyncHint:NO];
		}
		
		[self syncEK];
	}	
	else if (alertVw.tag == -20000)
	{
		if (buttonIndex == 0) //Don't Show
		{
			[[Settings getInstance] enableFeatureHint:NO];
		}
		else if (buttonIndex == 1)
		{
			NSURL *url = [NSURL URLWithString:@"http://www.leftcoastlogic.com/blog/smartapps/smartcal/smartcal-3-1-whats-new/"];
			
			[[UIApplication sharedApplication] openURL:url];
		}
	}
	else if (alertVw.tag == -30000 && buttonIndex != 0)
	{
		UIButton *getNowButton = [[[UIButton alloc] init] autorelease];
		
		getNowButton.tag = 1;
		
		//[_tabBarCtrler linkAppStore:getNowButton];
	}
}

#pragma mark Links
- (void) reconcileLinks:(NSDictionary *)dict
{
    TaskLinkManager *tlm = [TaskLinkManager getInstance];
    
    int sourceId = [[dict objectForKey:@"LinkSourceID"] intValue];
    int destId = [[dict objectForKey:@"LinkDestID"] intValue];
    
    NSArray *list = [calendarLayoutController getObjectList];
    
    for (Task *task in list)
    {
        if (task.original == nil || [task isREException])
        {
            if (task.primaryKey == sourceId)
            {
                task.links = [tlm getLinkIds4Task:sourceId];
            }
            else if (task.primaryKey == destId)
            {
                task.links = [tlm getLinkIds4Task:destId];
            }
        }
    }
    
    [adeView reconcileLinks:dict];
}

#pragma mark GrowingTextView Delegate
- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView
{
    return NO;
}

- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView;
{
    NSString *text = [quickAddTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    quickAddBackgroundView.hidden = YES;
	calendarView.scrollEnabled = YES;
	calendarView.userInteractionEnabled = YES;
	addButton.enabled = YES;
	
	if (![text isEqualToString:@""])
	{
		NSDate *startTime = [NSDate dateWithTimeIntervalSince1970:growingTextView.tag];
		
		TaskManager *tm = [TaskManager getInstance];
		
		//[self quickAdd:text startTime:[Common copyTimeFromDate:startTime toDate:tm.today]];
        [_abstractViewCtrler quickAddEvent:text startTime:[Common copyTimeFromDate:startTime toDate:tm.today]];
	}
}


#pragma mark TextFieldDelegate
/*
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
    
	//textField.hidden = YES;
    quickAddBackgroundView.hidden = YES;
	calendarView.scrollEnabled = YES;
	calendarView.userInteractionEnabled = YES;
	addButton.enabled = YES;	
	
	if (![textField.text isEqualToString:@""])
	{
		NSDate *startTime = [NSDate dateWithTimeIntervalSince1970:textField.tag];
		
		TaskManager *tm = [TaskManager getInstance];
		
		[self quickAdd:textField.text startTime:[Common copyTimeFromDate:startTime toDate:tm.today]];
	}
	
	return YES;	
}
*/

-(void) createHintView
{
	hintView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 416-20)];
	hintView.backgroundColor = [UIColor colorWithRed:40.0/255 green:40.0/255 blue:40.0/255 alpha:0.9];
	
	GuideWebView *hintLabel = [[GuideWebView alloc] initWithFrame:CGRectMake(10, 0, 300, 416-20)];

	[hintLabel loadHTMLFile:@"CalendarHint" extension:@"htm"];
	
	[hintView addSubview:hintLabel];
	
	[hintLabel release];
	
	UIButton *hintOKButton =[Common createButton:_okText
									  buttonType:UIButtonTypeCustom 
										   //frame:CGRectMake(210, 340, 100, 30) 
							 frame:CGRectMake(210, 420, 100, 30) 
									  titleColor:nil 
										  target:self 
										selector:@selector(hint:) 
								normalStateImage:@"blue_button.png"
							  selectedStateImage:nil];
	[hintOKButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	hintOKButton.tag = 10000;
	
	UIButton *hintDontShowButton =[Common createButton:_dontShowText
											buttonType:UIButtonTypeCustom 
												 //frame:CGRectMake(10, 340, 100, 30) 
								   frame:CGRectMake(10, 420, 100, 30) 
											titleColor:nil 
												target:self 
											  selector:@selector(hint:) 
									  normalStateImage:@"blue_button.png"
									selectedStateImage:nil];
	[hintDontShowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	hintDontShowButton.tag = 10001;
	
	[hintView addSubview:hintOKButton];
	
	[hintView addSubview:hintDontShowButton];
}

-(void) createAddMenuView
{
	addMenuView = [[UIView alloc] initWithFrame:CGRectMake(160, 0, 160, 100)];
	addMenuView.hidden = YES;
	addMenuView.backgroundColor = [UIColor clearColor];
	[contentView addSubview:addMenuView];
	[addMenuView release];	
	
	addMenuImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 100)];
	addMenuImageView.alpha = 0.85;
	[addMenuView addSubview:addMenuImageView];
	[addMenuImageView release];
	
	UIImageView *taskImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 30, 30)];
	taskImageView.image = [[ImageManager getInstance] getImageWithName:@"tasks.png"];
	[addMenuView addSubview:taskImageView];
	[taskImageView release];
	
	UILabel *taskLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 22, 120, 25)];
	taskLabel.text = _taskText;
	taskLabel.textColor = [UIColor whiteColor];
	taskLabel.backgroundColor = [UIColor clearColor];
	taskLabel.font=[UIFont systemFontOfSize:18];
	[addMenuView addSubview:taskLabel];
	[taskLabel release];	
	
	UIButton *taskButton=[Common createButton:@"" 
									buttonType:UIButtonTypeCustom 
										 frame:CGRectMake(0, 22, 160, 20) 
									titleColor:nil
										target:self 
									  selector:@selector(addTask:) 
							  normalStateImage:nil
							selectedStateImage:nil];
	taskButton.titleLabel.font=[UIFont systemFontOfSize:18];
	
	[addMenuView addSubview:taskButton];
    
	UIImageView *noteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 55, 30, 30)];
	noteImageView.image = [[ImageManager getInstance] getImageWithName:@"list.png"];
	[addMenuView addSubview:noteImageView];
	[noteImageView release];
	
	UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 57, 120, 25)];
	noteLabel.text = _noteText;
	noteLabel.textColor = [UIColor whiteColor];
	noteLabel.backgroundColor = [UIColor clearColor];
	noteLabel.font=[UIFont systemFontOfSize:18];
	[addMenuView addSubview:noteLabel];
	[noteLabel release];	
	
	UIButton *noteButton=[Common createButton:@""
									   buttonType:UIButtonTypeCustom 
											frame:CGRectMake(0, 57, 160, 20) 
									   titleColor:nil 
										   target:self 
										 selector:@selector(addNote:) 
								 normalStateImage:nil
							   selectedStateImage:nil];
	noteButton.titleLabel.font=[UIFont systemFontOfSize:18];
	[addMenuView addSubview:noteButton];    
}


-(void) createMenuView
{
	menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 250)];
	menuView.hidden = YES;
	menuView.backgroundColor = [UIColor clearColor];
	[contentView addSubview:menuView];
	[menuView release];	
	
	menuImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 250)];
	menuImageView.alpha = 0.85;
	[menuView addSubview:menuImageView];
	[menuImageView release];
	
	UIImageView *todayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 30, 30)];
	todayImageView.image = [[ImageManager getInstance] getImageWithName:@"menu_today.png"];
	[menuView addSubview:todayImageView];
	[todayImageView release];
	
	UILabel *todayLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 22, 120, 25)];
	todayLabel.text = _todayText;
	todayLabel.textColor = [UIColor whiteColor];
	todayLabel.backgroundColor = [UIColor clearColor];
	todayLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:todayLabel];
	[todayLabel release];	
	
	UIButton *todayButton=[Common createButton:@"" 
									buttonType:UIButtonTypeCustom 
										 frame:CGRectMake(0, 22, 160, 20) 
									titleColor:nil
										target:self 
									  selector:@selector(showToday:) 
							  normalStateImage:nil
							selectedStateImage:nil];
	todayButton.titleLabel.font=[UIFont systemFontOfSize:18];
	
	[menuView addSubview:todayButton];
	
	UIImageView *gotoDateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 55, 30, 30)];
	gotoDateImageView.image = [[ImageManager getInstance] getImageWithName:@"menu_gotodate.png"];
	[menuView addSubview:gotoDateImageView];
	[gotoDateImageView release];
	
	UILabel *gotoDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 57, 120, 25)];
	gotoDateLabel.text = _gotoDateText;
	gotoDateLabel.textColor = [UIColor whiteColor];
	gotoDateLabel.backgroundColor = [UIColor clearColor];
	gotoDateLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:gotoDateLabel];
	[gotoDateLabel release];	
	
	UIButton *gotoDateButton=[Common createButton:@""
									   buttonType:UIButtonTypeCustom 
											frame:CGRectMake(0, 57, 160, 20) 
									   titleColor:nil 
										   target:self 
										 selector:@selector(showDateJumper:) 
								 normalStateImage:nil
							   selectedStateImage:nil];
	gotoDateButton.titleLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:gotoDateButton];
	
	UIImageView *filterImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 90, 30, 30)];
	filterImageView.image = [[ImageManager getInstance] getImageWithName:@"menu_filter.png"];
	[menuView addSubview:filterImageView];
	[filterImageView release];
	
	UILabel *filterLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 92, 120, 25)];
	filterLabel.text = _filterText;
	filterLabel.textColor = [UIColor whiteColor];
	filterLabel.backgroundColor = [UIColor clearColor];
	filterLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:filterLabel];
	[filterLabel release];
	filterLabel.tag = 10000 + TASK_FILTER_GLOBAL;
	
	UIButton *filterButton=[Common createButton:@""
									 buttonType:UIButtonTypeCustom 
										  frame:CGRectMake(0, 92, 160, 20) 
									 titleColor:nil 
										 target:self 
									   selector:@selector(showFilterView:) 
							   normalStateImage:nil
							 selectedStateImage:nil];
	filterButton.titleLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:filterButton];	
	
	UIImageView *syncImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 125, 30, 30)];
	syncImageView.image = [[ImageManager getInstance] getImageWithName:@"menu_sync.png"];
	[menuView addSubview:syncImageView];
	[syncImageView release];
	
	UILabel *syncLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 127, 120, 25)];
	syncLabel.text = _syncEventsText;
	syncLabel.textColor = [UIColor whiteColor];
	syncLabel.backgroundColor = [UIColor clearColor];
	syncLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:syncLabel];
	[syncLabel release];	
	
	
	UIButton *syncButton=[Common createButton:@"" 
								   buttonType:UIButtonTypeCustom 
										frame:CGRectMake(0, 127, 160, 20) 
								   titleColor:nil
									   target:self 
									 selector:@selector(sync:) 
							 normalStateImage:nil
						   selectedStateImage:nil];
	syncButton.titleLabel.font=[UIFont systemFontOfSize:18];
	
	[menuView addSubview:syncButton];
	
	UIImageView *hideImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 160, 30, 30)];
	hideImageView.image = [[ImageManager getInstance] getImageWithName:@"menu_showhide.png"];
	[menuView addSubview:hideImageView];
	[hideImageView release];
	
	UILabel *hideLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 162, 120, 25)];
	hideLabel.text = _showHideCategoryText;
	hideLabel.textColor = [UIColor whiteColor];
	hideLabel.backgroundColor = [UIColor clearColor];
	hideLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:hideLabel];
	[hideLabel release];	
	
	UIButton *hideButton=[Common createButton:@"" 
									  buttonType:UIButtonTypeCustom 
										   frame:CGRectMake(0, 162, 160, 20) 
									  titleColor:nil
										  target:self 
										selector:@selector(showHideCategory:) 
								normalStateImage:nil
							  selectedStateImage:nil];
	hideButton.titleLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:hideButton];
    
	UIImageView *settingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 195, 30, 30)];
	settingImageView.image = [[ImageManager getInstance] getImageWithName:@"menu_setting.png"];
	[menuView addSubview:settingImageView];
	[settingImageView release];
	
	UILabel *settingLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 197, 120, 25)];
	settingLabel.text = _settingTitle;
	settingLabel.textColor = [UIColor whiteColor];
	settingLabel.backgroundColor = [UIColor clearColor];
	settingLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:settingLabel];
	[settingLabel release];	
	
	UIButton *settingButton=[Common createButton:@"" 
									  buttonType:UIButtonTypeCustom 
										   frame:CGRectMake(0, 197, 160, 20) 
									  titleColor:nil
										  target:self 
										selector:@selector(editSetting:) 
								normalStateImage:nil
							  selectedStateImage:nil];
	settingButton.titleLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:settingButton];    
}

- (void) tabBarChanged:(BOOL)mini
{	
	//[self resizeView];
}

- (void) changeFrame:(CGRect)frm
{
    contentView.frame = frm;
    calendarView.frame = contentView.bounds;
    
    adeView.frame = CGRectMake(0, 0, frm.size.width, 40);
    adeSeparatorImgView.frame = CGRectMake(0, 0, frm.size.width, 6);
    
    //printf("calendar frame w:%f\n", calendarView.bounds.size.width);
    
    [yesterdayScheduleView changeFrame:contentView.bounds];
    [todayScheduleView changeFrame:CGRectOffset(contentView.bounds, contentView.bounds.size.width, 0)];
    [tomorrowScheduleView changeFrame:CGRectOffset(contentView.bounds, 2*contentView.bounds.size.width, 0)];
    
    CGFloat h = todayScheduleView.frame.size.height;
    
    calendarView.contentSize = CGSizeMake(3*contentView.bounds.size.width, h);
    //calendarView.contentOffset = CGPointMake(contentView.bounds.size.width, 0);
    
    CGPoint offset = calendarView.contentOffset;
    offset.x = contentView.bounds.size.width;
    
    calendarView.contentOffset = offset;
    
	CGSize timePaneSize = [TimeSlotView calculateTimePaneSize];
	CGFloat xmargin = LEFT_MARGIN + timePaneSize.width + TIME_LINE_PAD;
    
    quickAddBackgroundView.frame = CGRectMake(xmargin, 0, frm.size.width-xmargin-CALENDAR_BOX_ALIGNMENT, 2*TIME_SLOT_HEIGHT);
    
    frm = quickAddBackgroundView.bounds;
    frm.origin.x += 15;
    frm.size.width -= 15;
    
    //quickAddTextField.frame = frm;
    quickAddTextView.frame = frm;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    frm.size.width = 320;
    
	contentView = [[ContentView alloc] initWithFrame:frm];
    contentView.backgroundColor = [UIColor clearColor];
    
	self.view = contentView;
	[contentView release];

    adeView = [[CalendarADEView alloc] initWithFrame:CGRectMake(0, 0, frm.size.width, 40)];
    adeView.hidden = YES;
    [contentView addSubview:adeView];
    [adeView release];
    
    adeSeparatorImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ade_separator.png"]];
    adeSeparatorImgView.frame = CGRectMake(0, 0, frm.size.width, 6);
    adeSeparatorImgView.hidden = YES;
    
    [contentView addSubview:adeSeparatorImgView];
    [adeSeparatorImgView release];
    
    calendarView = [[ContentScrollView alloc] initWithFrame:contentView.bounds];
    
    calendarView.canCancelContentTouches = NO;
	calendarView.backgroundColor = [UIColor clearColor];
    calendarView.delegate = calendarLayoutController;
	
	[contentView addSubview:calendarView];
	[calendarView release];	
	
	calendarLayoutController.viewContainer = calendarView;

    yesterdayScheduleView = [[ScheduleView alloc] initWithFrame:calendarView.bounds];
    
	[calendarView addSubview:yesterdayScheduleView];
	[yesterdayScheduleView release];
        
    todayScheduleView = [[ScheduleView alloc] initWithFrame:CGRectOffset(calendarView.bounds, calendarView.bounds.size.width, 0)];
    
	[calendarView addSubview:todayScheduleView];
	[todayScheduleView release];

    tomorrowScheduleView = [[ScheduleView alloc] initWithFrame:CGRectOffset(calendarView.bounds, 2*calendarView.bounds.size.width, 0)];
    
	[calendarView addSubview:tomorrowScheduleView];
	[tomorrowScheduleView release];    
    
    CGFloat h = todayScheduleView.frame.size.height;
    
    //calendarView.contentSize = CGSizeMake(contentView.frame.size.width, h);
    calendarView.contentSize = CGSizeMake(3*contentView.bounds.size.width, h);
    calendarView.contentOffset = CGPointMake(contentView.bounds.size.width, 0);
	calendarView.scrollEnabled = YES;
	calendarView.scrollsToTop = NO;	
	calendarView.showsHorizontalScrollIndicator = YES;
	calendarView.showsVerticalScrollIndicator = YES;
	calendarView.directionalLockEnabled = YES;	
	
	CGSize timePaneSize = [TimeSlotView calculateTimePaneSize];
	CGFloat xmargin = LEFT_MARGIN + timePaneSize.width + TIME_LINE_PAD;
    
    TaskManager *tm = [TaskManager getInstance];
    
    quickAddBackgroundView = [[TaskView alloc] initWithFrame:CGRectMake(xmargin, 0, frm.size.width-xmargin-CALENDAR_BOX_ALIGNMENT, 2*TIME_SLOT_HEIGHT)];
    quickAddBackgroundView.task = tm.eventDummy;
    [contentView addSubview:quickAddBackgroundView];
    [quickAddBackgroundView release];
    quickAddBackgroundView.hidden = YES;
    
    frm = quickAddBackgroundView.bounds;
    frm.origin.x += 15;
    frm.size.width -= 15;
    
    quickAddTextView = [[HPGrowingTextView alloc] initWithFrame:frm];
    quickAddTextView.delegate = self;
    quickAddTextView.backgroundColor = [UIColor clearColor];

	quickAddTextView.minNumberOfLines = 1;
	quickAddTextView.maxNumberOfLines = 2;
    quickAddTextView.contentInset = UIEdgeInsetsZero;
	quickAddTextView.returnKeyType = UIReturnKeyDone; //just as an example
	quickAddTextView.font = [UIFont boldSystemFontOfSize:12];
    quickAddTextView.textColor = [UIColor whiteColor];
    
    [quickAddBackgroundView addSubview:quickAddTextView];
    [quickAddTextView release];

/*
    //quickAddTextField = [[UITextField alloc] initWithFrame:CGRectMake(xmargin, 0, frm.size.width-xmargin-CALENDAR_BOX_ALIGNMENT, 2*TIME_SLOT_HEIGHT)];
    quickAddTextField = [[UITextField alloc] initWithFrame:frm];
    quickAddTextField.backgroundColor = [UIColor clearColor];
    
	quickAddTextField.delegate = self;
	//quickAddTextField.borderStyle = UITextBorderStyleRoundedRect;
    quickAddTextField.borderStyle = UITextBorderStyleNone;
	quickAddTextField.keyboardType = UIKeyboardTypeDefault;
	quickAddTextField.returnKeyType = UIReturnKeyDone;
	quickAddTextField.font = [UIFont boldSystemFontOfSize:12];
    quickAddTextField.textColor = [UIColor whiteColor];
	//quickAddTextField.hidden = YES;
	
	//[contentView addSubview:quickAddTextField];
    [quickAddBackgroundView addSubview:quickAddTextField];
	[quickAddTextField release];
*/
	outlineView = [[TaskOutlineView alloc] initWithFrame:CGRectZero];
	[contentView addSubview:outlineView];
	[outlineView release];
	
	outlineView.hidden = YES;
    
	[self changeSkin];
    
    //[self createHintView];
}

- (void) sendScheduleView2Back
{
    [calendarView sendSubviewToBack:todayScheduleView];
}

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
	[ImageManager free];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    /*
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown:)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [titleView addGestureRecognizer:swipeDown];    
    */
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated 
{	
	_sc2ViewCtrler = self;
	
    [self focusNow];
	
    /*
	if (_navigationTabChanged)
	{
		//////printf("calendar navigation changed\n");
		[self refreshView];
		_navigationTabChanged = NO;
	}
    */
    
    //[self refreshView];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self deselect];	
}

- (void) showFeatureHint
{
	if ([[Settings getInstance] featureHint] && !_scFreeVersion)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_v3_2_welcomeTitle
															message:_v3_2_welcomeText 
														   delegate:self
												  cancelButtonTitle:_dontShowText
												  otherButtonTitles:nil];
		
		alertView.tag = -20000;
		
		[alertView addButtonWithTitle:_seeDetails];
		
		[alertView show];
		[alertView release];		
		
	}
}

- (void) showUpgradeOffer
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_upgradeText
														message:_scPaidOfferText 
													   delegate:self
											  cancelButtonTitle:_laterText
											  otherButtonTitles:nil];
	
	if (alertView.subviews.count > 1)
	{
		UIView *v = [alertView.subviews objectAtIndex:1];
		
		if ([v isKindOfClass:[UILabel class]])
		{
			((UILabel *)v).textAlignment = NSTextAlignmentLeft;
		}		 
	}
	
	alertView.tag = -30000;
	
	[alertView addButtonWithTitle:_getNowText];
	
	[alertView show];
	[alertView release];	
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	//[self showFeatureHint];
	
	//[self popupHint];
	
	//////NSLog(@"SC2 view did appear");
}

- (void)viewDidDisappear:(BOOL)animated
{
	_sc2ViewCtrler = nil;
}

#pragma mark Notification

- (void)dayManagerReady:(NSNotification *)notification
{
    [todayScheduleView refreshDayManagerView];
}

- (void)fastScheduleFinished:(NSNotification *)notification
{
    [self refreshLayout];
}

- (void)calendarDayChange:(NSNotification *)notification
{
    [self refreshLayout];
}

- (void)refreshPanes
{
    [self refreshCalendarDay];
    [self refreshADEPane];    
}

/*
- (void)refreshCalendar
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
    [self refreshPanes];

    [self refreshLayout];
    
    [[BusyController getInstance] setBusy:NO withCode:BUSY_CAL_REFRESH_CALENDAR];

	[pool release];
}
*/

/*
- (void)calendarDayReset:(NSNotification *)notification
{
	////NSLog(@"calendar view: received calendar data init notification -> refresh event layout\n");
    
	//[[BusyController getInstance] setBusy:YES withCode:BUSY_CAL_REFRESH_CALENDAR];
	
	//[self performSelectorInBackground:@selector(refreshCalendar) withObject:nil];
    
    [self refreshPanes];
}
*/

- (void)calendarDayReady:(NSNotification *)notification
{
    [self refreshPanes];
    //[self refreshLayout];
}

/*
- (void)miniMonthResize:(NSNotification *)notification
{
    [UIView beginAnimations:@"mmresize_animation" context:NULL];
    [UIView setAnimationDuration:0.2];
    
    [self refreshFrame];
    
    [UIView commitAnimations];
}
*/

#pragma mark Notification

#pragma mark OS4 Support 
-(void) purge
{
	[self.navigationController popToRootViewControllerAnimated:NO];
	
	[self deselect];
	
	[movableController reset];
}

-(void) recover
{
	//taskBGFinished = NO;
	//eventBGFinished = NO;
	
	//[self.weekPlannerView performSelector:@selector(initCalendar) withObject:nil afterDelay:0.1];
	
	[self showFeatureHint];
	
	if (_scFreeVersion && _recoverCount == 4)
	{
		[self showUpgradeOffer];
		
		_recoverCount = 0;
	}
	
	_recoverCount ++;
}

@end
