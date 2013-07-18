//
//  SmartListViewController.m
//  SmartCal
//
//  Created by Trung Nguyen on 5/13/10.
//  Copyright 2010 LCL. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "SmartListViewController.h"

#import "Colors.h"
#import "Settings.h"

#import "DBManager.h"
#import "TaskManager.h"
#import "ProjectManager.h"
#import "MusicManager.h"
#import "ImageManager.h"

#import "TaskDetailTableViewController.h"
//#import "SmartListMovableController.h"
//#import "SmartListLayoutController.h"
#import "TaskLayoutController.h"
#import "TaskMovableController.h"
#import "SettingTableViewController.h"

#import "Task.h"
//#import "DayManagerView.h"
#import "TaskView.h"
#import "ContentView.h"
#import "ContentScrollView.h"
#import "ContentTableView.h"
#import "FilterView.h"
#import "GuideWebView.h"
#import "MiniMonthView.h"
#import "MonthlyCalendarView.h"
#import "FocusView.h"

#import "ProgressIndicatorView.h"

#import "TDSync.h"
#import "SDWSync.h"

#import "CalendarSelectionTableViewController.h"

#import "BusyController.h"
#import "CalendarViewController.h"
#import "SmartDayViewController.h"
#import "CategoryViewController.h"

#import "SmartListPlannerMovableController.h"

#import "AbstractSDViewController.h"
#import "PlannerViewController.h"
#import "PlannerMonthView.h"

#import "SmartCalAppDelegate.h"

extern AbstractSDViewController *_abstractViewCtrler;
extern PlannerViewController *_plannerViewCtrler;

extern BOOL _smartListHintShown;
extern BOOL _multiSelectHintShown;
extern BOOL _starTabHintShown;
extern BOOL _gtdoTabHintShown;
extern BOOL _navigationTabChanged;
extern BOOL _scFreeVersion;

extern SmartCalAppDelegate *_appDelegate;

extern BOOL _isiPad;

SmartListViewController *_smartListViewCtrler;


@implementation SmartListViewController

//@synthesize smartListLayoutController;
@synthesize layoutController;
@synthesize quickAddPlaceHolder;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */

-(id) init 
{
	if (self = [super init]) 
	{
        //movableController = [[SmartListMovableController alloc] init];
		
		//smartListLayoutController = [[SmartListLayoutController alloc] init];
        //smartListLayoutController.movableController = movableController;
        
        movableController = [[TaskMovableController alloc] init];
        layoutController = [[TaskLayoutController alloc] init];
        layoutController.movableCtrler = movableController;

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(scheduleFinished:)
													 name:@"ScheduleFinishedNotification" object:nil];
        
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(dayManagerReady:)
													 name:@"DayManagerReadyNotification" object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(appBusy:)
													 name:@"AppBusyNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(appNoBusy:)
													 name:@"AppNoBusyNotification" object:nil];

		firstLoad = YES;
	}
	
	return self;	
}

/*
-(id) init4Planner
{
    if (self = [super init])
    {
        movableController = [[SmartListPlannerMovableController alloc] init];
		
		smartListLayoutController = [[SmartListLayoutController alloc] init];
        smartListLayoutController.movableController = movableController;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(scheduleFinished:)
													 name:@"ScheduleFinishedNotification" object:nil];
        
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(dayManagerReady:)
													 name:@"DayManagerReadyNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(appBusy:)
													 name:@"AppBusyNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(appNoBusy:)
													 name:@"AppNoBusyNotification" object:nil];
        
		firstLoad = YES;        
    }
    
    return self;
}
*/

- (void) resetMovableController:(BOOL)forPlanner
{
    if (movableController != nil)
    {
        [movableController release];
        //smartListLayoutController.movableController = nil;
        layoutController.movableCtrler = nil;
    }
    
    if (forPlanner)
    {
        movableController = [[SmartListPlannerMovableController alloc] init];
        //smartListLayoutController.movableController = movableController;
    }
    else
    {
        //movableController = [[SmartListMovableController alloc] init];
        //smartListLayoutController.movableController = movableController;
        
        movableController = [[TaskMovableController alloc] init];
    }
    
    layoutController.movableCtrler = movableController;
    
	for (UIView *view in smartListView.subviews)
	{
		if ([view isKindOfClass:[TaskView class]])
		{
            ((TaskView *)view).movableController = movableController;
        }
    }
}

-(id) initWithTabBar {
	if ([self init]) {
		self.title = @"Tasks";
		self.tabBarItem.image = [[ImageManager getInstance] getImageWithName:@"tasks.png"];
		
	}
	return self;
	
}

- (BOOL) checkControllerActive
{
    AbstractActionViewController *ctrler = (_plannerViewCtrler != nil?_plannerViewCtrler:_abstractViewCtrler);
    
    return [ctrler checkControllerActive:1];
}

- (void) reconcileItem:(Task *)item
{
    if ([item isTask] && [self checkControllerActive])
    {
        if (item.listSource == SOURCE_SMARTLIST)
        {
            [self refreshTaskView4Key:item.primaryKey];
        }
        else
        {
            [self refreshLayout];
        }
    }
}

- (void) refreshData
{
	[dayManagerView initData];
	
	[[TaskManager getInstance] initSmartListData];			
}


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[addButtonItem release];
	[moreButtonItem release];
	
    [movableController release];
	//[smartListLayoutController release];
    [layoutController release];
	
	[editButtonItem release];
	[cancelButtonItem release];
	
	[hintView release];
    
    self.quickAddPlaceHolder = nil;
	
    [super dealloc];
}

#pragma mark Support
-(void)changeSkin
{
    contentView.backgroundColor = [UIColor colorWithPatternImage:[[ImageManager getInstance] getImageWithName:@"bg_pattern.png"]];
    
    smartListView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];    
    
}

- (void) enableActions:(int)action
{
	switch (action) {
		case 0: //add
		{
			addButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd  target:self action:@selector(quickAdd:)];
			self.navigationItem.rightBarButtonItem = addButtonItem;
			[addButtonItem release];			
		}
			break;
		default: //edit
			break;
	}
}

- (void) editTask:(Task *)task
{
	[self backToSingleSelectMode];
	
	TaskDetailTableViewController *ctrler = [[TaskDetailTableViewController alloc] init];
	
	ctrler.task = task;		

	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];	
	
	//inTaskEditMode = YES;
}

- (void) markDoneTask
{
    TaskView *view = movableController.activeMovableView;
    Task *task = view.tag;
    
    [task retain];
    
    if (![task isRT])
    {
        [view removeFromSuperview];	
    }
    
    [[TaskManager getInstance] markDoneTask:task];
    
    if ([task isRT])
    {
        [view setNeedsDisplay];
    }
    
    [task release];
    
    [self deselect];    
}

-(void)refreshFadedStatus
{
	for (UIView *view in smartListView.subviews)
	{
		if ([view isKindOfClass:[TaskView class]])
		{
			Task * task = (Task *) view.tag;
			
			if (task.isScheduled)
			{
				view.alpha = 1;
			}
			else 
			{
				view.alpha = 0.6;
			}
		}
	}	
}

- (void)clearLayout
{
    //[self.smartListLayoutController wait4LayoutComplete];
    
	for (UIView *view in smartListView.subviews)
	{
		if (view != quickAddPlaceHolder)
		{
            [view removeFromSuperview];
        }
    }
}

-(void)refreshLayout
{
	//////NSLog(@"smart list refresh layout\n");
	//[smartListMovableController unhighlight];
    [movableController unhighlight];
	
	//[smartListMovableController reset];
    [movableController reset];
	
	//NSMutableArray *list = [[TaskManager getInstance] getDisplayList];
    
    NSInteger count = [[TaskManager getInstance] getDisplayListCount];
	
	editButtonItem.enabled = (count > 0);	
	
	if (filterView.userInteractionEnabled == YES)
	{
		[filterView tagInputReset];
	}
    	
    [self.layoutController layout];
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
		
		addButtonItem.enabled = NO;
		
		menuView.hidden = NO;
		[contentView  bringSubviewToFront:menuView];
		
		[Common animateGrowViewFromPoint:CGPointMake(0,0) toPoint:CGPointMake(80, 90) forView:menuView];
	}
	else 
	{
		[Common animateShrinkView:menuView toPosition:CGPointMake(0,0) target:self shrinkEnd:@selector(shrinkEnd)];
	}		
}

- (void) hideDropDownMenu
{
	if (!menuView.hidden)
	{
		[Common animateShrinkView:menuView toPosition:CGPointMake(0,0) target:self shrinkEnd:@selector(shrinkEnd)];
	}
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

-(void) stopQuickAdd
{
	[quickAddTextField resignFirstResponder];
    
    //quickAddEditBarView.hidden = YES;
    maskView.hidden = YES;
}

-(void) cancelQuickAdd
{
    quickAddTextField.text = @"";
    
    [self stopQuickAdd];
}

- (void) enableActions:(BOOL)enable onView:(TaskView *)view
{	
	//if (smartListMovableController.selectionMode == SELECTION_MULTI)
    if (movableController.selectionMode == SELECTION_MULTI)
	{
		return;
	}
	
	[self stopQuickAdd];
    [self hideDropDownMenu];

	//Task *task = (Task *)view.tag;
    Task *task = view.task;
    
	UIMenuController *menuCtrler = [UIMenuController sharedMenuController];
	
	[self hideSuggestedTime];
	
	if (enable)
	{
		CGRect frm = view.frame;
		
		NSString *timeStr = nil;
		
		if (task.isScheduled) //task in SmartList
		{
            NSDate *endTime = [task.smartTime dateByAddingTimeInterval:task.duration];
			
			timeStr = [NSString stringWithFormat:@"[%@ - %@]: %@", [Common getShortTimeString:task.smartTime], [Common getShortTimeString:endTime], task.name];
            
		}

		frm.origin = [view.superview convertPoint:frm.origin toView:contentView];
		
		if (timeStr != nil)
		{
			timePlaceHolder.tag = view;
			suggestedTimeLabel.text = timeStr;
		}
        
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

- (void) refreshViewAfterScrolling
{
	//TaskView *activeView = (TaskView *)smartListMovableController.activeMovableView;	
    TaskView *activeView = (TaskView *)movableController.activeMovableView;	
	
	if (activeView != nil && timePlaceHolder.tag == activeView)
	{
		CGRect frm = timePlaceHolder.frame;
		
		frm.origin.y = activeView.frame.origin.y - smartListView.contentOffset.y + 2;
		
		timePlaceHolder.frame = frm;
		
		[self showSuggestedTime];
	}
}

-(void) hideBars
{
	[[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
	
	[self hideSuggestedTime];
}

- (void) deselect
{
    [self stopQuickAdd];
    
    [self multiEdit:NO];
}

-(void)multiShrinkEnd
{
	multiSelectionMenuView.hidden = YES;
	
	addButtonItem.enabled = YES;
}

-(void)shrinkEnd
{
	menuView.hidden = YES;
	
	addButtonItem.enabled = YES;
}

-(void)setNeedsDisplay
{
	/*for (UIView *view in smartListView.subviews)
	{
        if ([view isKindOfClass:[TaskView class]])
        {
            [view refresh];
        }
	}*/
    
    NSInteger sections = smartListView.numberOfSections;
    
    for (int i=1; i<sections; i++)
    {
        NSInteger rows = [smartListView numberOfRowsInSection:i];
        
        for (int j=0; j<rows; j++)
        {
            UITableViewCell *cell = [smartListView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            
            TaskView *taskView = (TaskView *)[cell.contentView viewWithTag:-10000];
            
            if (taskView != nil)
            {
                [taskView refresh];
            }
        }
    }

}

-(void)refreshView
{
    [self setNeedsDisplay];
}

- (void) refreshTaskView4Key:(NSInteger)taskKey
{
    /*
	for (UIView *view in smartListView.subviews)
	{
		if ([view isKindOfClass:[TaskView class]])
		{
			TaskView *taskView = (TaskView *) view;
			Task *tmp = (Task *) taskView.task;
			
			if (tmp.primaryKey == taskKey)
			{
				[taskView setNeedsDisplay];
				[taskView refreshStarImage];
                [taskView refreshCheckImage];
				break;
			}
		}
	}*/
    
    NSInteger sections = smartListView.numberOfSections;
    
    for (int i=1; i<sections; i++)
    {
        NSInteger rows = [smartListView numberOfRowsInSection:i];
        
        for (int j=0; j<rows; j++)
        {
            UITableViewCell *cell = [smartListView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            
            TaskView *taskView = (TaskView *)[cell.contentView viewWithTag:-10000];
            
            if (taskView != nil)
            {
                Task *tmp = (Task *) taskView.task;
                
                if (tmp.primaryKey == taskKey)
                {
                    [taskView setNeedsDisplay];
                    [taskView refreshStarImage];
                    [taskView refreshCheckImage];
                    
                    break;
                }
            }
        }
    }
}


- (void) starTaskInView:(TaskView *)taskView
{
    TaskManager *tm = [TaskManager getInstance];
    
    //Task *task = (Task *)taskView.tag;
    Task *task = taskView.task;
    
	if (tm.taskTypeFilter == TASK_FILTER_STAR && task.status == TASK_STATUS_NONE)
	{
		[taskView removeFromSuperview];
		
		//[self refreshSmartList:YES];
	}
	else 
	{
		[taskView refreshStarImage];
    }    
}

-(void) refreshTopTaskForPlan:(NSInteger)plan
{
	Task *topTask = [[DBManager getInstance] getTopTaskForPlan:plan excludeFutureTasks:YES];
	
	BOOL found = NO;
	
	for (UIView *view in smartListView.subviews)
	{
		if ([view isKindOfClass:[TaskView class]])
		{
			Task *tmp = (Task *)view.tag;
			
			if (topTask != nil && !found)
			{
				if (tmp.primaryKey == topTask.primaryKey)
				{
					tmp.isTop = YES;
				}
			}
			
			if (tmp.isTop)
			{
				if (found)  
				{
					//clear flag for old top task when un-done a new one and it becomes top
					tmp.isTop = NO;
				}
				else 
				{
					found = YES;
				}

				[view setNeedsDisplay];						
			}
		}
	}		
}

- (void) showCalendarView
{
	self.tabBarController.selectedIndex = 0;	
}

- (void) enableTab:(BOOL)enable
{
	////printf("enable tab: %s\n", (enable?"YES":"NO"));
	tabPane.userInteractionEnabled = enable;
}

- (BOOL) checkMoveEnable
{
	//return !self.layoutController.layoutInProgress && tabPane.userInteractionEnabled && ![[TaskManager getInstance] checkSortInBackground];
    return tabPane.userInteractionEnabled && ![[TaskManager getInstance] checkSortInBackground];
}

- (void) finishLayout
{
	////printf("finish Layout\n");	
}

- (void) multiDelete
{
    NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:10];
    
    NSMutableArray *viewList = [NSMutableArray arrayWithCapacity:10];
    
    for (UIView *view in smartListView.subviews)
    {
        if ([view isKindOfClass:[TaskView class]])
        {
            TaskView *tv = (TaskView *)view;
            
            if ([tv isMultiSelected])
            {
                [taskList addObject:(Task *)view.tag];
                
                [viewList addObject:view];            
            }            
        }
    }
    
    if (viewList.count > 0)
    {
        for (UIView *view in viewList)
        {
            [view removeFromSuperview];
        }
        
        [[TaskManager getInstance] deleteTasks:taskList];        
    }

}

- (void) hideQuickAdd
{
    [smartListView setContentOffset:CGPointMake(0, 40)];
}

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

- (void) syncNewFolders:(NSTimer *)timer
{
	[[TDSync getInstance] syncNewFolders:[timer userInfo]];
}

- (void) initSyncToodledo
{
	[[TDSync getInstance] initSync:SYNC_MANUAL_2WAY];
}

- (void) syncToodledo
{
	if (_scFreeVersion)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_warningText message:_paidUpgradeText delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
		
		[alertView show];
		[alertView release];					
	}
	else //if ([Common checkWiFiAvailable])
	{
		//[_appDelegate showProgress:_toodledoSyncingText];
		
		[self performSelector:@selector(initSyncToodledo) withObject:nil afterDelay:0];			
	}
	/*else 
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_toodledoSyncText message:_noInternetConnectionText delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
		alertView.tag = 0;
		[alertView show];
		[alertView release];
		
	}*/
}

- (void) syncSDW
{
    //[_appDelegate showProgress:_sdwSyncingText];
    
    //[[SDWSync getInstance] initSync];
    [[SDWSync getInstance] performSelector:@selector(initSync) withObject:nil afterDelay:0];	
}

-(void) syncComplete
{
	//[_appDelegate hideProgress];
	
	[self refreshView];
}

#pragma mark Hint 

- (void) showHint
{
/*	
	smartListView.scrollEnabled = NO;
	
	[self.view bringSubviewToFront:hintView];
	hintView.hidden = NO;
	
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	
	[animation setType:kCATransitionMoveIn];
	[animation setSubtype:kCATransitionFromTop];
	
	// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
	[animation setDuration:0.25];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[contentView layer] addAnimation:animation forKey:@"popUpHint"];	
*/
	UIViewController *ctrler = [[UIViewController alloc] init];
	
	ctrler.view = hintView;
	
	//[self presentModalViewController:ctrler animated:YES];
    ctrler.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:ctrler animated:YES completion:NULL];
}

- (void) popupHint:(NSInteger)hint
{
	BOOL showSLHint = [[Settings getInstance] smartListHint];
	BOOL showMSHint = [[Settings getInstance] multiSelectHint];
	
	if (showSLHint && !_smartListHintShown && hint == 0)
	{
		[hintLabel loadHTMLFile:@"SmartListHint" extension:@"htm"];
		
		[self showHint];
		
		_smartListHintShown = YES;
	}
	else if (showMSHint && !_multiSelectHintShown && hint == 1)
	{
		UIAlertView *multiSelectHintAlertView = [[UIAlertView alloc] initWithTitle:_multiSelectText message:_multiSelectHintText delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
		
		multiSelectHintAlertView.tag = -10002;
		
		[multiSelectHintAlertView addButtonWithTitle:_dontShowText];
		[multiSelectHintAlertView show];
		[multiSelectHintAlertView release];
		
		_multiSelectHintShown = YES;
	}
	/*else 
	{
		hintView.hidden = YES;
	}*/

}

- (void) hint: (id) sender
{
	if ([sender tag] == 10001) //Don't Show
	{
		[[Settings getInstance] enableSmartListHint:NO];
	}
	
	/*
	hintView.hidden = YES;
	
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	
	[animation setType:kCATransitionMoveIn];
	[animation setSubtype:kCATransitionFromBottom];
	
	// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
	[animation setDuration:0.25];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[contentView layer] addAnimation:animation forKey:@"popDownHint"];			
	
	smartListView.scrollEnabled = YES;
	*/
	
	//[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark Actions
- (void) editSetting: (id) sender
{
	[self hideDropDownMenu];
	
	SettingTableViewController *ctrler = [[SettingTableViewController alloc] init];
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];	
}

- (void) addTask:(id) sender
{
	TaskDetailTableViewController *ctrler = [[TaskDetailTableViewController alloc] init];
	
	Task *newTask = [[Task alloc] init];

	ctrler.task = newTask;
	
	[newTask release];
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];		
	
	//inTaskEditMode = YES;	
}

- (void) copyTask: (id) sender
{
	//Task *task = [smartListMovableController getActiveTask];
    Task *task = [self getSelectedTask];
    
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
	
	//inTaskEditMode = YES;
}

-(void)confirmMarkDone: (id) sender
{
	if ([[Settings getInstance] doneWarning])
	{
		NSString *title = _taskMarkDoneTitle;
		NSString *msg = _taskMarkDoneText;
		
		//if (smartListMovableController.selectionMode == SELECTION_SINGLE)
        if (movableController.selectionMode == SELECTION_SINGLE)
		{
			//Task *task = [smartListMovableController getActiveTask];
            Task *task = [self getSelectedTask];
			
			if (task.status == TASK_STATUS_DONE)
			{
				title = _taskUnMarkDoneTitle;
				msg = _taskUnMarkDoneText;
			}		
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
	if ([[Settings getInstance] deleteWarning])
	{
		NSString *msg = _itemDeleteText;
		NSInteger tag = -10000;
		
		UIAlertView *taskDeleteAlertView = [[UIAlertView alloc] initWithTitle:_itemDeleteTitle  message:msg delegate:self cancelButtonTitle:_cancelText otherButtonTitles:nil];
		
		taskDeleteAlertView.tag = tag;
		
		[taskDeleteAlertView addButtonWithTitle:_okText];
		[taskDeleteAlertView show];
		[taskDeleteAlertView release];		
	}
	else 
	{
		[self deleteTask];
	}
}

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertVw.tag == -10000 && buttonIndex == 1)
	{
		//[self deleteTask];
        [self doMultiDeleteTask];
	}
	else if (alertVw.tag == -10001 && buttonIndex == 1)
	{
		//[self markDoneTask];
        [self doMultiMarkDoneTask];
	}
	else if (alertVw.tag == -10002 && buttonIndex == 1)
	{
		[[Settings getInstance] enableMultiSelectHint:NO];
	}
	else if (alertVw.tag == -10004 && buttonIndex == 1)
	{
		[[Settings getInstance] enableStarTabHint:NO];
	}	
	else if (alertVw.tag == -10005 && buttonIndex == 1)
	{
		[[Settings getInstance] enableGTDoTabHint:NO];
	}	
	
}

- (void) showTaskType: (id) sender
{
	[self hideDropDownMenu];
	
	TaskManager *tm = [TaskManager getInstance];

	NSInteger taskType = [sender tag]; 
	
	if (taskType != tm.taskTypeFilter)
	{
		UILabel *label = (UILabel *)[menuView viewWithTag:10000 + tm.taskTypeFilter];
		
		if (label != nil)
		{
			label.textColor = [UIColor whiteColor];
		}
		
		[tm filterForTaskType:taskType];
		
		label = (UILabel *)[menuView viewWithTag:10000 + tm.taskTypeFilter];
		
		if (label != nil)
		{
			label.textColor = [UIColor yellowColor];
		}
		
		[self refreshLayout];
	}
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

- (void) multiSelectMode:(id)sender
{
	[self hideDropDownMenu];
	
	//smartListMovableController.selectionMode = SELECTION_MULTI;
    movableController.selectionMode = SELECTION_MULTI;
    
	[self deselect];
	
	[menuButton setBackgroundImage:[[ImageManager getInstance] getImageWithName:@"menu_multi.png"] forState:UIControlStateNormal];
	
	[self popupHint:1];
}

- (void) unPinAll:(id)sender
{
	[self hideDropDownMenu];
	
	for (UIView *view in smartListView.subviews)
	{
		if ([view isKindOfClass:[TaskView class]])
		{
			[self unPinTaskInView:(TaskView*)view];
		}
	}
	
	if ([[TaskManager getInstance] taskTypeFilter] == TASK_FILTER_STAR)
	{
		UIButton *tmp = [[[UIButton alloc] init] autorelease];
		tmp.tag = TASK_FILTER_ALL;
		
		[self showTaskType:tmp];
	}	
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];
}

- (void) quickAddMore:(id) sender
{
	if (![quickAddTextField.text isEqualToString:@""])
	{
		[self quickAddTask:quickAddTextField.text];
		
		quickAddTextField.text = @"";
	}
}

- (void) quickEdit:(id)sender
{
	TaskManager *tm = [TaskManager getInstance];
    Settings *settings = [Settings getInstance];
	
	//TaskDetailTableViewController *ctrler = [[TaskDetailTableViewController alloc] init];
	
	Task *task = [[[Task alloc] init] autorelease];
	task.type = TYPE_TASK;
	task.name = quickAddTextField.text;
	task.duration = tm.lastTaskDuration;
	task.project = tm.lastTaskProjectKey;
	task.startTime = [settings getWorkingStartTimeForDate:tm.today];
	
	switch (tm.taskTypeFilter) 
	{
		case TASK_FILTER_STAR:
		{
			task.status = TASK_STATUS_PINNED;
		}
			break;
		case TASK_FILTER_DUE:
		{
			task.deadline = [settings getWorkingEndTimeForDate:tm.today];
		}
			break;
	}
	
    quickAddTextField.text = @"";
    [quickAddTextField resignFirstResponder];
    
    [_abstractViewCtrler editItem:task inView:nil];
}

- (void) sync:(id) sender
{
	[self hideDropDownMenu];

    [self syncSDW];
}

- (void) tabFilter:(NSNumber *)filterTypeNum
{
    NSInteger filterType = [filterTypeNum intValue];
    
    [[TaskManager getInstance] filterForTaskType:filterType];    
}

- (void) tab:(id) sender
{
    [self hideDropDownMenu];
     
	selectedTabButton.selected = NO;
		
	UIButton *buttons[6];
	//NSInteger taskFilterTypes[6] = {TASK_FILTER_DONE, TASK_FILTER_ACTIVE, TASK_FILTER_DUE, TASK_FILTER_TOP, TASK_FILTER_STAR, TASK_FILTER_ALL}; 
	
	for (UIView *button in tabPane.subviews)
	{
		if ([button isKindOfClass:[UIButton class]])
		{
			[[button retain] autorelease];
            
            int i = 0;
            
            switch (button.tag)
            {
                case TASK_FILTER_ALL:
                    i = 5;
                    break;
                case TASK_FILTER_STAR:
                    i = 4;
                    break;
                case TASK_FILTER_TOP:
                    i = 3;
                    break;
                case TASK_FILTER_DUE:
                    i = 2;
                    break;
                case TASK_FILTER_ACTIVE:
                    i = 1;
                    break;
                case TASK_FILTER_DONE:
                    i = 0;
                    break;
            }
			
			buttons[i] = button;
			
			[button removeFromSuperview];			
		}
	}
	
	for (int i=0; i<6; i++)
	{
		[tabPane addSubview:buttons[i]];
	}
	
	selectedTabButton = sender;
	
	selectedTabButton.selected = YES;
	
	[tabPane bringSubviewToFront:selectedTabButton];
	
	TaskManager *tm = [TaskManager getInstance];
	
	//NSInteger filterType = taskFilterTypes[selectedTabButton.tag];
    
    NSInteger filterType = selectedTabButton.tag;
	
	if (tm.taskTypeFilter != filterType)
	{
		[self deselect];
		
		//[tm filterForTaskType:filterType];
		[self performSelector:@selector(tabFilter:) withObject:[NSNumber numberWithInt:filterType] afterDelay:0];
				
		[[Settings getInstance] changeFilterTab:filterType];
	}
	
	if (filterType == TASK_FILTER_STAR || filterType == TASK_FILTER_TOP)
	{
		BOOL showHint = (filterType == TASK_FILTER_STAR?
						 [[Settings getInstance] starTabHint]:
						 [[Settings getInstance] gtdoTabHint]);
		
		BOOL hintShown = (filterType == TASK_FILTER_STAR?_starTabHintShown:_gtdoTabHintShown);
		
		if (showHint && !hintShown)
		{
			NSString *msg = (filterType == TASK_FILTER_STAR?_starTabHintText:_gtdoTabHintText);
							 
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_hintText message:msg delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
			
			alertView.tag = (filterType == TASK_FILTER_STAR?-10004:-10005);
			
			[alertView addButtonWithTitle:_dontShowText];
			
			[alertView show];
			[alertView release];
			
			if (filterType == TASK_FILTER_STAR)
			{
				_starTabHintShown = YES;
			}
			else 
			{
				_gtdoTabHintShown = YES;
			}

		}
		
	}
}

- (void) filter:(NSInteger)filterType
{
	TaskManager *tm = [TaskManager getInstance];
	
	if (tm.taskTypeFilter != filterType)
	{
		[self deselect];
		
		//[self performSelector:@selector(tabFilter:) withObject:[NSNumber numberWithInt:filterType] afterDelay:0];
        [self tabFilter:[NSNumber numberWithInt:filterType]];
        
		[[Settings getInstance] changeFilterTab:filterType];
        
        [self hideQuickAdd];
	}
	
	if (filterType == TASK_FILTER_STAR || filterType == TASK_FILTER_TOP)
	{
		BOOL showHint = (filterType == TASK_FILTER_STAR?
						 [[Settings getInstance] starTabHint]:
						 [[Settings getInstance] gtdoTabHint]);
		
		BOOL hintShown = (filterType == TASK_FILTER_STAR?_starTabHintShown:_gtdoTabHintShown);
		
		if (showHint && !hintShown)
		{
			NSString *msg = (filterType == TASK_FILTER_STAR?_starTabHintText:_gtdoTabHintText);
            
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_hintText message:msg delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
			
			alertView.tag = (filterType == TASK_FILTER_STAR?-10004:-10005);
			
			[alertView addButtonWithTitle:_dontShowText];
			
			[alertView show];
			[alertView release];
			
			if (filterType == TASK_FILTER_STAR)
			{
				_starTabHintShown = YES;
			}
			else
			{
				_gtdoTabHintShown = YES;
			}
            
		}
	}
}

-(void)editTasks:(id)sender
{
	[self deselect];
	
	quickAddPlaceHolder.userInteractionEnabled = NO;
	menuButton.userInteractionEnabled = NO;
	//dayManagerView.userInteractionEnabled = NO;
	tabPane.userInteractionEnabled = NO;
	
	//smartListMovableController.selectionMode = SELECTION_MULTI;
    movableController.selectionMode = SELECTION_MULTI;
	for (UIView *view in smartListView.subviews)
	{
		if ([view isKindOfClass:[TaskView class]])
		{
			[(TaskView *)view startMultiSelect]; //show multi-select box
		}
	}	
	
	self.navigationItem.rightBarButtonItem = cancelButtonItem;
	
	editBarPlaceHolder.hidden = NO;	
}

/*
-(void)cancelEditTasks:(id)sender
{
	quickAddPlaceHolder.userInteractionEnabled = YES;
	menuButton.userInteractionEnabled = YES;
	dayManagerView.userInteractionEnabled = YES;
	tabPane.userInteractionEnabled = YES;
	
	//[smartListMovableController deselect];
    [movableController deselect];
	
	for (UIView *view in smartListView.subviews)
	{
		if ([view isKindOfClass:[TaskView class]])
		{
			[(TaskView *)view finishMultiSelect]; //hide multi-select box
		}
	}
	
	//smartListMovableController.selectionMode = SELECTION_SINGLE;
    movableController.selectionMode = SELECTION_SINGLE;
		
	self.navigationItem.rightBarButtonItem = editButtonItem;
	
	editBarPlaceHolder.hidden = YES;
}
*/
- (void) backToSingleSelectMode
{
	[self cancelEditTasks:nil];
}

- (void) showHideCategory: (id) sender
{
    [self hideDropDownMenu];
    
	CalendarSelectionTableViewController *ctrler = [[CalendarSelectionTableViewController alloc] init];
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];			
	
}

#pragma mark Multi-Select Actions
/*
- (void) multiUnSelect:(id)sender
{
	[self hideDropDownMenu];
	
	//[smartListMovableController unselectAll:YES];
    [movableController unselectAll:YES];
}
*/

- (void) doMultiDeleteTask
{
    NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:10];
    
    NSMutableArray *viewList = [NSMutableArray arrayWithCapacity:10];
    
    /*
    for (UIView *view in smartListView.subviews)
    {
        if ([view isKindOfClass:[TaskView class]])
        {
            TaskView *tv = (TaskView *)view;
            
            if ([tv isMultiSelected])
            {
                //[taskList addObject:(Task *)view.tag];
                [taskList addObject:tv.task];
                
                [viewList addObject:view];            
            }            
        }
    }*/
    
    NSInteger sections = smartListView.numberOfSections;
    
    for (int i=1; i<sections; i++)
    {
        NSInteger rows = [smartListView numberOfRowsInSection:i];
        
        for (int j=0; j<rows; j++)
        {
            UITableViewCell *cell = [smartListView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            
            TaskView *taskView = (TaskView *)[cell.contentView viewWithTag:-10000];
            
            if ([taskView isMultiSelected])
            {
                [taskList addObject:taskView.task];
                
                [viewList addObject:taskView];
            }
            
        }
    }
    
    [self multiEdit:NO];
    
    if (viewList.count > 0)
    {
        for (UIView *view in viewList)
        {
            [view removeFromSuperview];
        }
        
        //printf("1\n");
        
        [[TaskManager getInstance] deleteTasks:taskList];
        
        /*

        printf("2\n");
        if ([_abstractViewCtrler checkControllerActive:3])
        {
            CategoryViewController *ctrler = [_abstractViewCtrler getCategoryViewController];
            
            if (ctrler.filterType == TYPE_TASK)
            {
                        printf("3\n");
                [ctrler loadAndShowList];
            }
        }
        
        FocusView *focusView = [_abstractViewCtrler getFocusView];
        
        if (focusView != nil && [focusView checkExpanded])
        {
                    printf("4\n");
            [focusView refreshData];
        }
                printf("5\n");
        
<<<<<<< Updated upstream
        if (_plannerViewCtrler) {
            PlannerMonthView *monthView = (PlannerMonthView*)[_plannerViewCtrler getPlannerMonthCalendarView];
            [monthView refresh];
        } else {
            [_abstractViewCtrler.miniMonthView.calView refresh]; //refresh red dots
        }
=======
        [_abstractViewCtrler.miniMonthView.calView refresh]; //refresh red dots
        
                printf("6\n");
        */
        
        //[_abstractViewCtrler performSelector:@selector(refreshData) withObject:nil afterDelay:0.01];
        if (_plannerViewCtrler) {
            [_plannerViewCtrler performSelector:@selector(refreshData) withObject:nil afterDelay:0.01];
        } else {
            [_abstractViewCtrler performSelector:@selector(refreshData) withObject:nil afterDelay:0.01];
        }
    }
    [_abstractViewCtrler refreshEditBarViewWithCheck: NO];
}

- (void) confirmMultiDeleteTask
{
	if ([[Settings getInstance] deleteWarning])
	{
		NSString *msg = _itemDeleteText;
		NSInteger tag = -10000;
		
		UIAlertView *taskDeleteAlertView = [[UIAlertView alloc] initWithTitle:_itemDeleteTitle  message:msg delegate:self cancelButtonTitle:_cancelText otherButtonTitles:nil];
		
		taskDeleteAlertView.tag = tag;
		
		[taskDeleteAlertView addButtonWithTitle:_okText];
		[taskDeleteAlertView show];
		[taskDeleteAlertView release];		
	}
	else 
	{
		[self doMultiDeleteTask];
	}
}

- (void) multiDelete:(id)sender
{
	[self hideDropDownMenu];
    
    BOOL needConfirm = NO;
    
    /*
    for (UIView *view in smartListView.subviews)
    {
        if ([view isKindOfClass:[TaskView class]])
        {
            TaskView *tv = (TaskView *)view;
            
            if ([tv isMultiSelected])
            {
                needConfirm = YES;
                
                break;
            }
        }
    }
	*/
    
    NSInteger sections = smartListView.numberOfSections;
    
    for (int i=1; i<sections; i++)
    {
        NSInteger rows = [smartListView numberOfRowsInSection:i];
        
        for (int j=0; j<rows; j++)
        {
            UITableViewCell *cell = [smartListView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            
            TaskView *taskView = (TaskView *)[cell.contentView viewWithTag:-10000];
            
            if ([taskView isMultiSelected])
            {
                needConfirm = YES;
                
                break;
            }
            
        }
    }
    
    if (needConfirm)
	{
		[self confirmMultiDeleteTask];
	}
}

- (void) doMultiMarkDoneTask
{
    NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:10];
    
    NSMutableArray *viewList = [NSMutableArray arrayWithCapacity:10];
    
    /*
    for (UIView *view in smartListView.subviews)
    {
        if ([view isKindOfClass:[TaskView class]])
        {
            TaskView *tv = (TaskView *)view;
            
            if ([tv isMultiSelected])
            {
                //[taskList addObject:(Task *)view.tag];
                [taskList addObject:tv.task];
                
                [viewList addObject:view];            
            }            
        }
    }*/
    
    NSInteger sections = smartListView.numberOfSections;
    
    for (int i=1; i<sections; i++)
    {
        NSInteger rows = [smartListView numberOfRowsInSection:i];
        
        for (int j=0; j<rows; j++)
        {
            UITableViewCell *cell = [smartListView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            
            TaskView *taskView = (TaskView *)[cell.contentView viewWithTag:-10000];
            
            if ([taskView isMultiSelected])
            {
                [taskList addObject:taskView.task];
                
                [viewList addObject:taskView];
            }
            
        }
    }
    
    [self multiEdit:NO];
        
    if (viewList.count > 0)
    {
        for (UIView *view in viewList)
        {
            [view removeFromSuperview];
        }
        
        [[TaskManager getInstance] markDoneTasks:taskList];     
    }
    
    if ([_abstractViewCtrler checkControllerActive:3])
    {
        CategoryViewController *ctrler = [_abstractViewCtrler getCategoryViewController];
        
        if (ctrler.filterType == TYPE_TASK)
        {
            [ctrler loadAndShowList];
        }
    }
    
    FocusView *focusView = [_abstractViewCtrler getFocusView];
    
    if (focusView != nil && [focusView checkExpanded])
    {
        [focusView refreshData];
    }
    
    PlannerMonthView *monthView = (PlannerMonthView*)[_plannerViewCtrler getPlannerMonthCalendarView];
    [monthView refreshOpeningWeek:nil];
    [monthView refresh];
    
    [[_abstractViewCtrler getMonthCalendarView] refresh];
}

- (void) confirmMultiMarkDone
{
	if ([[Settings getInstance] doneWarning])
	{
		NSString *title = _taskMarkDoneTitle;
		NSString *msg = _taskMarkDoneText;
		
		UIAlertView *taskDoneAlertView = [[UIAlertView alloc] initWithTitle:title  message:msg delegate:self cancelButtonTitle:_cancelText otherButtonTitles:nil];
		taskDoneAlertView.tag = -10001;
		
		[taskDoneAlertView addButtonWithTitle:_okText];
		[taskDoneAlertView show];
		[taskDoneAlertView release];		
	}
	else 
	{
		[self doMultiMarkDoneTask];
	}
}

- (void) multiDone:(id)sender
{
	[self hideDropDownMenu];

    BOOL needConfirm = NO;
    
    /*
    for (UIView *view in smartListView.subviews)
    {
        if ([view isKindOfClass:[TaskView class]])
        {
            TaskView *tv = (TaskView *)view;
     
            if ([tv isMultiSelected])
            {
                needConfirm = YES;
                
                break;
            }
        }
    }
    */
    
    NSInteger sections = smartListView.numberOfSections;
    
    for (int i=1; i<sections; i++)
    {
        NSInteger rows = [smartListView numberOfRowsInSection:i];
        
        for (int j=0; j<rows; j++)
        {
            UITableViewCell *cell = [smartListView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            
            TaskView *taskView = (TaskView *)[cell.contentView viewWithTag:-10000];
            
            if ([taskView isMultiSelected])
            {
                needConfirm = YES;
                
                break;
            }

        }
    }
	
    if (needConfirm)
	{	
		[self confirmMultiMarkDone];
	}
}

/*
- (void) singleSelectMode:(id)sender
{
	[self hideDropDownMenu];
	
	[self backToSingleSelectMode];
}

- (void) menuOutside:(id)sender
{
    ////printf("outside menu\n");
}
*/
- (void) multiEdit:(BOOL)enabled
{
    [self cancelQuickAdd];
    
    /*
    for (UIView *view in smartListView.subviews)
    {
        if ([view isKindOfClass:[MovableView class]])
        {
            [(MovableView *) view multiSelect:enabled];
        }
    }*/
    
    NSInteger sections = smartListView.numberOfSections;
    
    for (int i=1; i<sections; i++)
    {
        NSInteger rows = [smartListView numberOfRowsInSection:i];
        
        for (int j=0; j<rows; j++)
        {
            UITableViewCell *cell = [smartListView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            
            TaskView *taskView = (TaskView *)[cell.contentView viewWithTag:-10000];
            
            [taskView multiSelect:enabled];
        }
    }
    
    /*editBarPlaceHolder.hidden = !enabled;
    
    TaskManager *tm = [TaskManager getInstance];
    
    doneButton.hidden = (tm.taskTypeFilter == TASK_FILTER_DONE);*/
}

- (BOOL)isInMultiEditMode
{
    return !editBarPlaceHolder.hidden;
}

- (void) cancelMultiEdit:(id) sender
{
    [self multiEdit:NO];
}

- (void)multiMoveTop: (id)sender
{
    NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:10];
    
    //NSMutableArray *viewList = [NSMutableArray arrayWithCapacity:10];
    
    
    NSInteger sections = smartListView.numberOfSections;
    for (int i=1; i<sections; i++)
    {
        NSInteger rows = [smartListView numberOfRowsInSection:i];
        
        for (int j=0; j<rows; j++)
        {
            UITableViewCell *cell = [smartListView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            
            TaskView *taskView = (TaskView *)[cell.contentView viewWithTag:-10000];
            
            if ([taskView isMultiSelected])
            {
                [taskList addObject:taskView.task];
                
                //[viewList addObject:taskView];
            }
            
        }
    }
    
    if (taskList.count > 0) {
        TaskManager *tm = [TaskManager getInstance];
        [tm moveTop:taskList];
    }
    
    [_abstractViewCtrler refreshEditBarViewWithCheck: NO];
}

- (void)multiMarkStar: (id)sender
{
    NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:10];
    
    NSMutableArray *viewList = [NSMutableArray arrayWithCapacity:10];

    
    NSInteger sections = smartListView.numberOfSections;
    
    for (int i=1; i<sections; i++)
    {
        NSInteger rows = [smartListView numberOfRowsInSection:i];
        
        for (int j=0; j<rows; j++)
        {
            UITableViewCell *cell = [smartListView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            
            TaskView *taskView = (TaskView *)[cell.contentView viewWithTag:-10000];
            
            if ([taskView isMultiSelected])
            {
                [taskList addObject:taskView.task];
                
                [viewList addObject:taskView];
            }
            
        }
    }
    
    [self multiEdit:NO];
    
    if (viewList.count > 0)
    {
        TaskManager *tm = [TaskManager getInstance];
        if (tm.taskTypeFilter == TASK_FILTER_PINNED) {
            for (UIView *view in viewList)
            {
                [view removeFromSuperview];
            }
        } else {
            for (UIView *view in viewList)
            {
                [view setNeedsDisplay];
            }
        }
        
        [[TaskManager getInstance] starTasks:taskList];
    }
    [_abstractViewCtrler refreshEditBarViewWithCheck: NO];
    
    if ([_abstractViewCtrler checkControllerActive:3])
    {
        CategoryViewController *ctrler = [_abstractViewCtrler getCategoryViewController];
        
        if (ctrler.filterType == TYPE_TASK)
        {
            [ctrler loadAndShowList];
        }
    }
    
    FocusView *focusView = [_abstractViewCtrler getFocusView];
    
    if (focusView != nil && [focusView checkExpanded])
    {
        [focusView refreshData];
    }
    
    PlannerMonthView *monthView = (PlannerMonthView*)[_plannerViewCtrler getPlannerMonthCalendarView];
    [monthView refreshOpeningWeek:nil];
    [monthView refresh];
    
    [[_abstractViewCtrler getMonthCalendarView] refresh];
}

#pragma mark UIScrollView Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView 
{
	[self refreshViewAfterScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if (!decelerate)
	{
		[self refreshViewAfterScrolling];
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (!quickAddTextField.isFirstResponder)
    {
        [_abstractViewCtrler deselect];
    }
}

#pragma mark TextFieldDelegate
- (void) saveAndMore:(id) sender
{
	NSString *text = [quickAddTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
    if (![quickAddTextField isFirstResponder])
    {
        [quickAddTextField becomeFirstResponder];
    }
	else if (![text isEqualToString:@""])
	{
		//[self quickAddTask:text];
        if (_plannerViewCtrler != nil) {
            [_plannerViewCtrler quickAddItem:text type:TYPE_TASK];
        } else {
            [_abstractViewCtrler quickAddItem:text type:TYPE_TASK];
        }
	}
    
    quickAddTextField.text = @"";
    quickAddTextField.tag = -2;
    //saveAndMoreItem.enabled = NO;
}

-(void) quickAddDidChange:(id) sender
{
    //UITextField *textField = (UITextField *) sender;
    
    //NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //saveAndMoreItem.enabled = ![text isEqualToString:@""];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //quickAddEditBarView.hidden = NO;
    maskView.hidden = NO;
    
    if (_plannerViewCtrler != nil)
    {
        [_plannerViewCtrler hideDropDownMenu];
    }
    else
    {
        [_abstractViewCtrler hideDropDownMenu];
    }
    
	return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    quickAddTextField.tag = 1;
    
	[self stopQuickAdd];
	
	return YES;	
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if (quickAddTextField.tag == 1)
    {
        NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if (![text isEqualToString:@""])
        {
            //[self quickAddTask:text];
            if (_plannerViewCtrler != nil) {
                [_plannerViewCtrler quickAddItem:text type:TYPE_TASK];
            } else {
                [_abstractViewCtrler quickAddItem:text type:TYPE_TASK];
            }
        }
        
        quickAddTextField.tag = -1;
    }
    
    quickAddTextField.text = @"";
    
    maskView.hidden = YES;
}

#pragma mark Notification

- (void)scheduleFinished:(NSNotification *)notification
{
    //printf("smart list schedule finished - refresh layout\n");
    
    if (_plannerViewCtrler != nil || [_abstractViewCtrler checkControllerActive:1])
    {
        [self refreshLayout];
    }
}

/*
- (void)taskListReset:(NSNotification *)notification
{
	////NSLog(@"begin smart list reset");
	
	Task *taskDummy = [[TaskManager getInstance] taskDummy];
	
	for (UIView *view in smartListView.subviews)
	{
		view.tag = taskDummy;
	}	
	
	////NSLog(@"end smart list reset");
}
*/

/*
- (void)taskListReady:(NSNotification *)notification
{
    TaskManager *tm = [TaskManager getInstance];

    NSMutableArray *displayList = [tm getDisplayList];
    
    int index = 0;
    
    for (UIView *view in smartListView.subviews)
    {
        if ([view isKindOfClass:[TaskView class]])
        {
            if (index < displayList.count)
            {
                view.tag = [displayList objectAtIndex:index++];
            }
            else
            {
                view.tag = tm.taskDummy;
            }
            
        }
    }			
    
}
*/

- (void)taskListReady_v32:(NSNotification *)notification
{
	////NSLog(@"begin smart list ready");
	//if (_smartListViewCtrler != nil)
	{
		//////printf("task list ready -> renew objects\n");
		
		TaskManager *tm = [TaskManager getInstance];
		
		int max = tm.taskList.count;
		int index = 0;
		// switch tab -> re-assign Task object to reuse views
		for (UIView *view in smartListView.subviews)
		{
			if ([view isKindOfClass:[TaskView class]])
			{
				if (index < max)
				{
					view.tag = [tm.taskList objectAtIndex:index++];
				}
				else 
				{
					[view removeFromSuperview];
				}
				
			}
		}			
		
	}
	////NSLog(@"end smart list ready");	
}

- (void)dayManagerReady:(NSNotification *)notification
{
	[dayManagerView initData];
}

/*
- (void)tdSyncComplete:(NSNotification *)notification
{
	////NSLog(@"Toodle sync complete");
	NSNumber *modeNum = [notification object];
	
	NSInteger mode = [modeNum intValue];
	
	//CalendarViewController *sc2ViewCtrler = [_tabBarCtrler getSC2ViewCtrler];
			
	[_appDelegate hideProgress];		
	
	if (mode != -1)
	{
		TaskManager *tm = [TaskManager getInstance];

		if (mode == SYNC_AUTO_2WAY)
		{
			if ([[Settings getInstance] ekAutoSyncEnabled]) //finish sync both EK and TD
			{
				[tm initData];
				
				//[sc2ViewCtrler.weekPlannerView performSelector:@selector(initCalendar) withObject:nil afterDelay:0];				
			}
			else 
			{
				[tm initSmartListData];
			}
		}
		else if (mode == SYNC_MANUAL_2WAY || mode == SYNC_MANUAL_1WAY_TD2SD)
		{
			[tm initSmartListData];
		}
		else
		{
			[tm refreshSyncID4AllTasks];
		}
	}
	
	[[BusyController getInstance] setBusy:NO withCode:BUSY_TD_SYNC];
}

- (void)sdwSyncComplete:(NSNotification *)notification
{
    TaskManager *tm = [TaskManager getInstance];
    
    [tm initSmartListData];
    
    [self syncComplete];
}
*/

- (void)miniMonthResize:(NSNotification *)notification
{
    CGSize sz = [Common getScreenSize];
    
    MiniMonthView *miniMonthView = notification.object;
    
	CGFloat y = miniMonthView.frame.size.height - 10;
	
	CGRect frm = self.view.frame;
	
	frm.origin.y = y;
	frm.size.height = sz.height - y;
    
	self.view.frame = frm;  
}

- (void)appBusy:(NSNotification *)notification
{
    quickAddPlaceHolder.userInteractionEnabled = NO;
}

- (void)appNoBusy:(NSNotification *)notification
{
    quickAddPlaceHolder.userInteractionEnabled = YES;
}

#pragma mark OS4 Support
-(void) purge
{
	[self.navigationController popToRootViewControllerAnimated:NO];
	
	[self backToSingleSelectMode];
	
	//[smartListMovableController reset];
    [movableController reset];
	suggestedTimeLabel.hidden = YES;
	[menuButton setBackgroundImage:[[ImageManager getInstance] getImageWithName:@"menu_menu.png"] forState:UIControlStateNormal]; //back to single selection mode
}

-(void) recover
{
}

#pragma mark View Creation

-(void) createHintView
{
	hintView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 416-20)];
	hintView.backgroundColor = [UIColor colorWithRed:40.0/255 green:40.0/255 blue:40.0/255 alpha:0.9];
	//hintView.hidden = YES;
	
	hintLabel = [[GuideWebView alloc] initWithFrame:CGRectMake(10, 0, 300, 416-20)];
	
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
	
	//[contentView addSubview:hintView];
	//[hintView release];
	
}

- (NSArray *) getTabFilters
{
    return [NSArray arrayWithObjects:
            [NSNumber numberWithInt:TASK_FILTER_ALL],
            [NSNumber numberWithInt:TASK_FILTER_STAR],
            [NSNumber numberWithInt:TASK_FILTER_TOP],
            [NSNumber numberWithInt:TASK_FILTER_DUE],
            [NSNumber numberWithInt:TASK_FILTER_ACTIVE],
            [NSNumber numberWithInt:TASK_FILTER_DONE],
            nil];
}

-(void) createTabs
{
	tabPane = [[UIView alloc] initWithFrame:CGRectMake(0, quickAddPlaceHolder.frame.size.height, TAB_WIDTH, contentView.frame.size.height)];
	
	[contentView addSubview:tabPane];
	[tabPane release];
	
	busyIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
	[tabPane addSubview:busyIndicatorView];
	busyIndicatorView.hidden = YES;
	[busyIndicatorView release];
    
    NSArray *filters = [self getTabFilters];
    NSString *titles[6] = {_allText, _starText, _gtdoText, _dueText, _startText, _doneText};
    
    for (int i=filters.count-1;i>=0;i--)
    {
        NSNumber *filter = [filters objectAtIndex:i];
        
        UIButton *button = [Common createButton:titles[i] 
                                     buttonType:UIButtonTypeCustom 
                                          frame:CGRectMake(0, i*(TAB_HEIGHT - 10), TAB_WIDTH, TAB_HEIGHT)
                                     titleColor:[UIColor whiteColor]
                                         target:self 
                                       selector:@selector(tab:) 
                               normalStateImage:@"tab_disable_blue.png"
                             selectedStateImage:@"tab_enable_blue.png"];
        [tabPane addSubview:button];	
        
        button.tag = [filter intValue];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        button.selected = NO;
        
        if ([[Settings getInstance] filterTab] == button.tag)
        {
            selectedTabButton = button;
        }
    }
    
    selectedTabButton.selected = YES; 
    
	[tabPane bringSubviewToFront:selectedTabButton];
}

/*
-(void) createFilterTabs
{
	tabPane = [[UIView alloc] initWithFrame:CGRectMake(0, quickAddPlaceHolder.frame.size.height, TAB_WIDTH, contentView.frame.size.height)];
	
	[contentView addSubview:tabPane];
	[tabPane release];
	
	busyIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
	[tabPane addSubview:busyIndicatorView];
	busyIndicatorView.hidden = YES;
	[busyIndicatorView release];
    
	UIButton *doneButton = [Common createButton:_doneText
									   buttonType:UIButtonTypeCustom 
											frame:CGRectMake(0, 5*(TAB_HEIGHT - 10), TAB_WIDTH, TAB_HEIGHT)
									   titleColor:[UIColor blackColor]
										   target:self 
										 selector:@selector(tab:) 
								 normalStateImage:@"tab_disable_blue.png"
							   selectedStateImage:@"tab_enable_blue.png"];
	[tabPane addSubview:doneButton];
	
	doneButton.tag = 0;
	[doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];	
	doneButton.selected = NO;
    
	UIButton *activeButton = [Common createButton:_startText 
									   buttonType:UIButtonTypeCustom 
											frame:CGRectMake(0, 4*(TAB_HEIGHT - 10), TAB_WIDTH, TAB_HEIGHT)
									   titleColor:[UIColor blackColor]
										   target:self 
										 selector:@selector(tab:) 
								 normalStateImage:@"tab_disable_blue.png"
							   selectedStateImage:@"tab_enable_blue.png"];
	[tabPane addSubview:activeButton];
	UIImageView *sortImageView1 = [[UIImageView alloc] initWithFrame:CGRectMake((TAB_WIDTH - 15)/2, 15, 15, 10)];
	sortImageView1.image = [[ImageManager getInstance] getImageWithName:@"sort_indicator.png"];
	[activeButton addSubview:sortImageView1];
	[sortImageView1 release];
	
	activeButton.tag = 1;
	[activeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[activeButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];	
	activeButton.selected = NO;
	
	UIButton *dueButton = [Common createButton:_dueText 
									buttonType:UIButtonTypeCustom 
										 frame:CGRectMake(0, 3*(TAB_HEIGHT-10), TAB_WIDTH, TAB_HEIGHT)
									titleColor:[UIColor blackColor]
										target:self 
									  selector:@selector(tab:) 
							  normalStateImage:@"tab_disable_blue.png"
							selectedStateImage:@"tab_enable_blue.png"];
	[tabPane addSubview:dueButton];
	
	UIImageView *sortImageView2 = [[UIImageView alloc] initWithFrame:CGRectMake((TAB_WIDTH - 15)/2, 15, 15, 10)];
	sortImageView2.image = [[ImageManager getInstance] getImageWithName:@"sort_indicator.png"];
	[dueButton addSubview:sortImageView2];
	[sortImageView2 release];
	
	dueButton.tag = 2;
	[dueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[dueButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];		
	dueButton.selected = NO;
	
	UIButton *topButton = [Common createButton:_gtdoText 
									buttonType:UIButtonTypeCustom 
										 frame:CGRectMake(0, 2*(TAB_HEIGHT - 10), TAB_WIDTH, TAB_HEIGHT)
									titleColor:[UIColor blackColor] 
										target:self 
									  selector:@selector(tab:) 
							  normalStateImage:@"tab_disable_blue.png"
							selectedStateImage:@"tab_enable_blue.png"];
	[tabPane addSubview:topButton];
	
	topButton.tag = 3;
	[topButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[topButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];		
	topButton.selected = NO;	
	
	UIButton *starButton = [Common createButton:_starText 
									 buttonType:UIButtonTypeCustom 
										  frame:CGRectMake(0, TAB_HEIGHT - 10, TAB_WIDTH, TAB_HEIGHT)
									 titleColor:[UIColor blackColor] 
										 target:self 
									   selector:@selector(tab:) 
							   normalStateImage:@"tab_disable_blue.png"
							 selectedStateImage:@"tab_enable_blue.png"];
	[tabPane addSubview:starButton];
	
	starButton.tag = 4;
	[starButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[starButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];		
	starButton.selected = NO;	
	
	UIButton *allButton =[Common createButton:_allText 
								   buttonType:UIButtonTypeCustom 
										frame:CGRectMake(0, 0, TAB_WIDTH, TAB_HEIGHT)
								   titleColor:[UIColor blackColor]
									   target:self 
									 selector:@selector(tab:) 
							 normalStateImage:@"tab_disable_blue.png"
						   selectedStateImage:@"tab_enable_blue.png"];
	
	[tabPane addSubview:allButton];
	
	allButton.tag = 5;
	[allButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[allButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];		
	
	switch ([[Settings getInstance] filterTab]) 
	{
		case TASK_FILTER_ALL:
			selectedTabButton = allButton;
			break;
		case TASK_FILTER_STAR:
			selectedTabButton = starButton;
			break;
		case TASK_FILTER_TOP:
			selectedTabButton = topButton;
			break;
		case TASK_FILTER_DUE:
			selectedTabButton = dueButton;
			break;
		case TASK_FILTER_ACTIVE:
			selectedTabButton = activeButton;
			break;
        case TASK_FILTER_DONE:
            selectedTabButton = doneButton;
            break;
	}
	
	selectedTabButton.selected = YES;
	[tabPane bringSubviewToFront:selectedTabButton];
}
*/

-(void) createEditBar
{
	editBarPlaceHolder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentView.bounds.size.width, 40)];
	editBarPlaceHolder.backgroundColor = [UIColor clearColor];
	editBarPlaceHolder.hidden = YES;
	
	[contentView addSubview:editBarPlaceHolder];
	[editBarPlaceHolder release];
    
	UIToolbar *editToolbar = [[UIToolbar alloc] initWithFrame:editBarPlaceHolder.bounds];
	editToolbar.barStyle = UIBarStyleBlack;
    editToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    editToolbar.tag = 1;
	
	[editBarPlaceHolder addSubview:editToolbar];
	[editToolbar release];

	UIButton *cancelButton = [Common createButton:_cancelText 
									 buttonType:UIButtonTypeCustom 
										  frame:CGRectMake(0, 5, 70, 30)
									 titleColor:[UIColor whiteColor]
										 target:self 
									   selector:@selector(cancelMultiEdit:) 
							   normalStateImage:@"hide_btn.png"
							 selectedStateImage:nil];
	
	UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
	
	doneButton = [Common createButton:_doneText
									 buttonType:UIButtonTypeCustom 
										  frame:CGRectMake(0, 5, 70, 30)
									 titleColor:[UIColor whiteColor]
										 target:self 
									   selector:@selector(multiDone:)
							   normalStateImage:@"done_btn.png"
							 selectedStateImage:nil];
	
	UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
	
	UIButton *deleteButton = [Common createButton:_deleteText 
									   buttonType:UIButtonTypeCustom
											frame:CGRectMake(0, 5, 70, 30)
									   titleColor:[UIColor whiteColor]
										   target:self 
										 selector:@selector(multiDelete:) 
								 normalStateImage:@"delete_btn.png"
							   selectedStateImage:nil];
	
	UIBarButtonItem *deleteButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deleteButton];
	
	UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]
								  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
								  target:nil
								  action:nil];
	
	NSArray *items = [NSArray arrayWithObjects:spaceItem, cancelButtonItem, spaceItem, doneButtonItem, spaceItem, deleteButtonItem, spaceItem, nil];
	
    [cancelButtonItem release];
	[doneButtonItem release];
	[deleteButtonItem release];
	[spaceItem release];
	
	[editToolbar setItems:items animated:NO];
}

/*
-(void) createQuickAddEditBar
{
    CGFloat h = [Common getKeyboardHeight];
    
	quickAddEditBarView = [[UIView alloc] initWithFrame:CGRectMake(0, contentView.bounds.size.height-h-40, contentView.bounds.size.width, 40)];
	quickAddEditBarView.backgroundColor = [UIColor clearColor];
	quickAddEditBarView.hidden = YES;
	
	[contentView addSubview:quickAddEditBarView];
	[quickAddEditBarView release];
	
	editToolbar = [[UIToolbar alloc] initWithFrame:quickAddEditBarView.bounds];
	editToolbar.barStyle = UIBarStyleBlack;
	
	[quickAddEditBarView addSubview:editToolbar];
	[editToolbar release];
    
    //UIBarButtonItem *saveAndMoreItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAndMore:)];
    saveAndMoreItem = [[UIBarButtonItem alloc] initWithTitle:_saveAndMoreText style: UIBarButtonItemStyleBordered target:self action:@selector(saveAndMore:)];
    saveAndMoreItem.tintColor = [UIColor colorWithRed:59.0/255 green:125.0/255 blue:221.0/255 alpha:1];
    saveAndMoreItem.enabled = NO;
    
    //saveAndMoreItem.title = _saveAndMoreText;
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]
								  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
								  target:nil
								  action:nil];
    
    NSArray *items = [NSArray arrayWithObjects:spaceItem, saveAndMoreItem, nil];
    
    [editToolbar setItems:items animated:NO];
    
    [spaceItem release];
    [saveAndMoreItem release];
}
*/
-(void) createMenuView
{
	menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 180)];
	menuView.hidden = YES;
	menuView.backgroundColor = [UIColor clearColor];
	[contentView addSubview:menuView];
	[menuView release];	
	
	menuImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 180)];
	menuImageView.alpha = 0.85;
	[menuView addSubview:menuImageView];
	[menuImageView release];
	
	UIImageView *filterImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 30, 30)];
	filterImageView.image = [[ImageManager getInstance] getImageWithName:@"menu_filter.png"];
	[menuView addSubview:filterImageView];
	[filterImageView release];
	
	UILabel *filterLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 22, 120, 25)];
	filterLabel.text = _filterText;
	filterLabel.textColor = [UIColor whiteColor];
	filterLabel.backgroundColor = [UIColor clearColor];
	filterLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:filterLabel];
	[filterLabel release];
	filterLabel.tag = 10000 + TASK_FILTER_GLOBAL;
	
	UIButton *filterButton=[Common createButton:@""
									 buttonType:UIButtonTypeCustom 
										  frame:CGRectMake(0, 22, 160, 20) 
									 titleColor:nil 
										 target:self 
									   selector:@selector(showFilterView:) 
							   normalStateImage:nil
							 selectedStateImage:nil];
	filterButton.titleLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:filterButton];	
	
	UIImageView *syncImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 55, 30, 30)];
	syncImageView.image = [[ImageManager getInstance] getImageWithName:@"menu_sync.png"];
	[menuView addSubview:syncImageView];
	[syncImageView release];
	
	UILabel *syncLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 57, 120, 25)];
	syncLabel.text = _syncTasksText;
	syncLabel.textColor = [UIColor whiteColor];
	syncLabel.backgroundColor = [UIColor clearColor];
	syncLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:syncLabel];
	[syncLabel release];	
	
	
	UIButton *syncButton=[Common createButton:@"" 
								   buttonType:UIButtonTypeCustom 
										frame:CGRectMake(0, 57, 160, 20) 
								   titleColor:nil
									   target:self 
									 selector:@selector(sync:) 
							 normalStateImage:nil
						   selectedStateImage:nil];
	syncButton.titleLabel.font=[UIFont systemFontOfSize:18];
	
	[menuView addSubview:syncButton];
	
	UIImageView *hideImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 90, 30, 30)];
	hideImageView.image = [[ImageManager getInstance] getImageWithName:@"menu_showhide.png"];
	[menuView addSubview:hideImageView];
	[hideImageView release];
	
	UILabel *hideLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 92, 120, 25)];
	hideLabel.text = _showHideCategoryText;
	hideLabel.textColor = [UIColor whiteColor];
	hideLabel.backgroundColor = [UIColor clearColor];
	hideLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:hideLabel];
	[hideLabel release];	
	
	UIButton *hideButton=[Common createButton:@"" 
                                   buttonType:UIButtonTypeCustom 
                                        frame:CGRectMake(0, 92, 160, 20) 
                                   titleColor:nil
                                       target:self 
                                     selector:@selector(showHideCategory:) 
                             normalStateImage:nil
                           selectedStateImage:nil];
	hideButton.titleLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:hideButton];    
	
	UIImageView *settingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 125, 30, 30)];
	settingImageView.image = [[ImageManager getInstance] getImageWithName:@"menu_setting.png"];
	[menuView addSubview:settingImageView];
	[settingImageView release];
	
	UILabel *settingLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 127, 120, 25)];
	settingLabel.text = _settingTitle;
	settingLabel.textColor = [UIColor whiteColor];
	settingLabel.backgroundColor = [UIColor clearColor];
	settingLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:settingLabel];
	[settingLabel release];	
	
	UIButton *settingButton=[Common createButton:@"" 
									  buttonType:UIButtonTypeCustom 
										   frame:CGRectMake(0, 127, 160, 20)
									  titleColor:nil
										  target:self 
										selector:@selector(editSetting:) 
								normalStateImage:nil
							  selectedStateImage:nil];
	settingButton.titleLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:settingButton];		
}

/*
-(void) createMultiSelectionMenuView
{
	multiSelectionMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 210)];
	multiSelectionMenuView.hidden = YES;
	multiSelectionMenuView.backgroundColor = [UIColor clearColor];
	[contentView addSubview:multiSelectionMenuView];
	[multiSelectionMenuView release];	
	
	multiSelectionMenuImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 210)];
	multiSelectionMenuImageView.alpha = 0.85;
	[multiSelectionMenuView addSubview:multiSelectionMenuImageView];
	[multiSelectionMenuImageView release];
	
	UIImageView *unSelectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 30, 30)];
	unSelectImageView.image = [[ImageManager getInstance] getImageWithName:@"menu_unselect.png"];
	[multiSelectionMenuView addSubview:unSelectImageView];
	[unSelectImageView release];
	
	UILabel *unSelectLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 22, 140, 25)];
	unSelectLabel.text = _unSelectText;
	unSelectLabel.textColor = [UIColor whiteColor];
	unSelectLabel.backgroundColor = [UIColor clearColor];
	unSelectLabel.font=[UIFont systemFontOfSize:18];
	[multiSelectionMenuView addSubview:unSelectLabel];
	[unSelectLabel release];
	
	UIButton *unSelectButton=[Common createButton:@"" 
									   buttonType:UIButtonTypeCustom 
											frame:CGRectMake(0, 22, 200, 20) 
									   titleColor:nil
										   target:self 
										 selector:@selector(multiUnSelect:) 
								 normalStateImage:nil
							   selectedStateImage:nil];
	unSelectButton.titleLabel.font=[UIFont systemFontOfSize:18];
	
	[multiSelectionMenuView addSubview:unSelectButton];
	
	UIImageView *pinImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 55, 30, 30)];
	pinImageView.image = [[ImageManager getInstance] getImageWithName:@"menu_toPin.png"];
	[multiSelectionMenuView addSubview:pinImageView];
	[pinImageView release];
	
	UILabel *pinLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 57, 140, 25)];
	pinLabel.text = _pinText;
	pinLabel.textColor = [UIColor whiteColor];
	pinLabel.backgroundColor = [UIColor clearColor];
	pinLabel.font=[UIFont systemFontOfSize:18];
	[multiSelectionMenuView addSubview:pinLabel];
	[pinLabel release];
	
	UIButton *pinButton=[Common createButton:@""
								  buttonType:UIButtonTypeCustom 
									   frame:CGRectMake(0, 57, 200, 20) 
								  titleColor:nil 
									  target:self 
									selector:@selector(multiPin:) 
							normalStateImage:nil
						  selectedStateImage:nil];
	pinButton.titleLabel.font=[UIFont systemFontOfSize:18];
	
	[multiSelectionMenuView addSubview:pinButton];
	
	
	UIImageView *deleteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 90, 30, 30)];
	deleteImageView.image = [[ImageManager getInstance] getImageWithName:@"menu_toDelete.png"];
	[multiSelectionMenuView addSubview:deleteImageView];
	[deleteImageView release];
	
	UILabel *deleteLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 92, 140, 25)];
	deleteLabel.text = _deleteText;
	deleteLabel.textColor = [UIColor whiteColor];
	deleteLabel.backgroundColor = [UIColor clearColor];
	deleteLabel.font=[UIFont systemFontOfSize:18];
	[multiSelectionMenuView addSubview:deleteLabel];
	[deleteLabel release];
	
	UIButton *deleteButton=[Common createButton:@""
									 buttonType:UIButtonTypeCustom 
										  frame:CGRectMake(0, 92, 200, 20) 
									 titleColor:nil 
										 target:self 
									   selector:@selector(multiDelete:) 
							   normalStateImage:nil
							 selectedStateImage:nil];
	deleteButton.titleLabel.font=[UIFont systemFontOfSize:18];
	
	[multiSelectionMenuView addSubview:deleteButton];
	
	UIImageView *doneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 125, 30, 30)];
	doneImageView.image = [[ImageManager getInstance] getImageWithName:@"menu_toDone.png"];
	[multiSelectionMenuView addSubview:doneImageView];
	[doneImageView release];	
	
	UILabel *doneLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 127, 140, 25)];
	doneLabel.text = _doneText;
	doneLabel.textColor = [UIColor whiteColor];
	doneLabel.backgroundColor = [UIColor clearColor];
	doneLabel.font=[UIFont systemFontOfSize:18];
	[multiSelectionMenuView addSubview:doneLabel];
	[doneLabel release];
	
	UIButton *doneButton=[Common createButton:@""
								   buttonType:UIButtonTypeCustom 
										frame:CGRectMake(0, 127, 200, 20) 
								   titleColor:nil 
									   target:self 
									 selector:@selector(multiDone:) 
							 normalStateImage:nil
						   selectedStateImage:nil];
	doneButton.titleLabel.font=[UIFont systemFontOfSize:18];
	
	[multiSelectionMenuView addSubview:doneButton];
	
	UIImageView *singleSelectionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 160, 30, 30)];
	singleSelectionImageView.image = [[ImageManager getInstance] getImageWithName:@"menu_singleselect.png"];
	[multiSelectionMenuView addSubview:singleSelectionImageView];
	[singleSelectionImageView release];	
	
	UILabel *singleSelectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 162, 140, 25)];
	singleSelectionLabel.text = _singleSelectText;
	singleSelectionLabel.textColor = [UIColor whiteColor];
	singleSelectionLabel.backgroundColor = [UIColor clearColor];
	singleSelectionLabel.font=[UIFont systemFontOfSize:18];
	[multiSelectionMenuView addSubview:singleSelectionLabel];
	[singleSelectionLabel release];
	
	UIButton *singleSelectionButton=[Common createButton:@""
											  buttonType:UIButtonTypeCustom 
												   frame:CGRectMake(0, 162, 200, 20) 
											  titleColor:nil 
												  target:self 
												selector:@selector(singleSelectMode:) 
										normalStateImage:nil
									  selectedStateImage:nil];
	singleSelectionButton.titleLabel.font=[UIFont systemFontOfSize:18];
	
	[multiSelectionMenuView addSubview:singleSelectionButton];	
}
*/

/*
- (void) tabBarChanged:(BOOL)mini
{
	CGFloat barHeight = [_tabBarCtrler getBarHeight];
	
	CGRect frm = smartListView.frame;
	
	frm.size.height = 416 - frm.origin.y - barHeight;
	
	smartListView.frame = frm;
    
    frm = timePlaceHolder.frame;
    frm.origin.y = smartListView.frame.origin.y + smartListView.frame.size.height - frm.size.height;
    
    timePlaceHolder.frame = frm;

}
*/

- (void) showBusyIndicator:(BOOL)enable
{
	////NSLog(@"show busy indicator: %@", (enable?@"YES":@"NO"));
	
	if (enable)
	{
		if (busyIndicatorView.hidden)
		{
			CGRect frm = CGRectOffset(selectedTabButton.frame, 40, 5);
			
			frm.size.width = 20;
			frm.size.height = 20;
			
			//////printf("show busy indicator: %f, %f\n", frm.origin.x, frm.origin.y);
			
			busyIndicatorView.frame = frm;
			
			[busyIndicatorView.superview bringSubviewToFront:busyIndicatorView];
			
			busyIndicatorView.hidden = NO;		
			
			[busyIndicatorView performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:NO];
		}
	}
	else 
	{
		[busyIndicatorView performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
		
		busyIndicatorView.hidden = YES;
	}
	
	[self enableTab:!enable];
}

- (void) changeFrame:(CGRect)frm
{
    contentView.frame = frm;
    
    CGPoint offset = smartListView.contentOffset;
    
    smartListView.frame = contentView.bounds;
    
    CGRect rec = editBarPlaceHolder.frame;
    
    rec.size.width = frm.size.width;
    
    editBarPlaceHolder.frame = rec;
    //editToolbar.frame = editBarPlaceHolder.bounds;
    
    UIToolbar *toolbar = (UIToolbar *) [editBarPlaceHolder viewWithTag:1];
    toolbar.frame = editBarPlaceHolder.bounds;
    
    quickAddPlaceHolder.frame = CGRectMake(0, 0, frm.size.width, 40);
    quickAddTextField.frame = CGRectMake(10, 5, frm.size.width-50, 30);
    
    UIButton *moreButton = (UIButton *) [quickAddPlaceHolder viewWithTag:10000];
    moreButton.frame = CGRectMake(frm.size.width-35, 4, 30, 30);
    
    smartListView.contentOffset = offset;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    frm.size.width = _isiPad?364:320;
    
    contentView = [[ContentView alloc] initWithFrame:frm];
    //contentView.contentSize = CGSizeMake(frm.size.width, frm.size.height+44);
	
	self.view = contentView;
	[contentView release];
	
    //smartListView = [[ContentScrollView alloc] initWithFrame:contentView.bounds];
    smartListView = [[ContentTableView alloc] initWithFrame:contentView.bounds];
    smartListView.contentSize = CGSizeMake(frm.size.width, 1.2*frm.size.height);

	//smartListView.scrollEnabled = YES;
	smartListView.delegate = self;
	smartListView.scrollsToTop = NO;	
	smartListView.showsVerticalScrollIndicator = YES;
	//smartListView.directionalLockEnabled = YES;
	
	[contentView addSubview:smartListView];
	[smartListView release];
    
    maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, frm.size.width, frm.size.height-40)];
    [contentView addSubview:maskView];
    maskView.backgroundColor = [UIColor clearColor];
    maskView.hidden = YES;
    [maskView release];

	//smartListLayoutController.viewContainer = smartListView;
    layoutController.listTableView = smartListView;
	
    self.quickAddPlaceHolder = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, frm.size.width, 40)] autorelease];
	self.quickAddPlaceHolder.backgroundColor = [UIColor clearColor];
    self.quickAddPlaceHolder.tag = -30000;
	//[smartListView addSubview:quickAddPlaceHolder];
	//[quickAddPlaceHolder release];
    
    quickAddTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, frm.size.width-50, 30)];
	quickAddTextField.delegate = self;
    quickAddTextField.tag = -1;
	quickAddTextField.borderStyle = UITextBorderStyleRoundedRect;
	quickAddTextField.keyboardType = UIKeyboardTypeDefault;
	quickAddTextField.returnKeyType = UIReturnKeyDone;
	quickAddTextField.font=[UIFont systemFontOfSize:16];
	quickAddTextField.placeholder = _quickAddNewTask;
    [quickAddTextField addTarget:self action:@selector(quickAddDidChange:) forControlEvents:UIControlEventEditingChanged];
	
	[self.quickAddPlaceHolder addSubview:quickAddTextField];
	[quickAddTextField release];
	
	UIButton *moreButton = [Common createButton:@""
									  buttonType:UIButtonTypeCustom
                                           frame:CGRectMake(frm.size.width-35, 4, 30, 30)
									  titleColor:nil
										  target:self
										selector:@selector(saveAndMore:)
								normalStateImage:@"addmore.png"
							  selectedStateImage:nil];
    moreButton.tag = 10000;
	
	[self.quickAddPlaceHolder addSubview:moreButton];
	
    timePlaceHolder = [[UIView alloc] initWithFrame:CGRectMake(0, frm.size.height-60, frm.size.width, 20)];
	timePlaceHolder.backgroundColor = [UIColor clearColor];
	timePlaceHolder.userInteractionEnabled = NO;
	[contentView addSubview:timePlaceHolder];
	[timePlaceHolder release];	
	
    suggestedTimeLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, frm.size.width, 20)];
	suggestedTimeLabel.backgroundColor=[[Colors darkSlateGray] colorWithAlphaComponent:0.8];
	suggestedTimeLabel.hidden = YES;
	suggestedTimeLabel.font=[UIFont systemFontOfSize:14];
	suggestedTimeLabel.textColor=[UIColor yellowColor];	
	
	[timePlaceHolder addSubview:suggestedTimeLabel];
	[suggestedTimeLabel release];
	
	filterView = [[FilterView alloc] initWithOrientation:0];
	[contentView addSubview:filterView];
	[filterView release];
	
	[self createHintView];
	
	[self createEditBar];
    
    [self changeSkin];

    //[self createQuickAddEditBar];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    //[self refreshLayout];
}

- (void)viewWillDisappear:(BOOL)animated
{
	//quickAddTextField.text = @"";
	//[quickAddTextField resignFirstResponder];
	
	[self deselect];

	//[self cancelEditTasks:nil];	
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	//[self popupHint:0];	
}

- (void)viewWillAppear:(BOOL)animated 
{	
	_smartListViewCtrler = self;
	
	if (firstLoad)
	{
        /*
		if (![[TaskManager getInstance] checkScheduleInProgress])
		{
			[self performSelector:@selector(refreshLayout) withObject:nil afterDelay:0];
		}
        */
		
		firstLoad = NO;
	}
}

- (void)viewDidDisappear:(BOOL)animated
{
	_smartListViewCtrler = nil;
}

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }

 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
	[ImageManager free];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
