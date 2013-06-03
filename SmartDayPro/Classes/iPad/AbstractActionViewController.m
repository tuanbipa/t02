//
//  AbstractActionViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 4/10/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "AbstractActionViewController.h"

#import "Common.h"
#import "Settings.h"
#import "Task.h"
#import "Project.h"

#import "SDWSync.h"
#import "TDSync.h"
#import "EKSync.h"
#import "EKReminderSync.h"

#import "TaskManager.h"
#import "TaskLinkManager.h"
#import "ProjectManager.h"
#import "DBManager.h"
#import "BusyController.h"

#import "TaskView.h"
#import "PlanView.h"
#import "ContentView.h"
#import "FocusView.h"
#import "MiniMonthView.h"
#import "PlannerBottomDayCal.h"

#import "CalendarViewController.h"
#import "SmartListViewController.h"
#import "CategoryViewController.h"
#import "NoteViewController.h"
#import "AbstractMonthCalendarView.h"

#import "TaskDetailTableViewController.h"
#import "NoteDetailTableViewController.h"
#import "ProjectEditViewController.h"

#import "SDNavigationController.h"

#import "SmartCalAppDelegate.h"
#import "PlannerViewController.h"
#import "PlannerMonthView.h"

extern BOOL _isiPad;

BOOL _autoPushPending = NO;

@interface AbstractActionViewController ()

@end

@implementation AbstractActionViewController
@synthesize contentView;

@synthesize popoverCtrler;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    if (self = [super init])
    {
        activeView = nil;
        
        self.task2Link = nil;
        
        self.popoverCtrler = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(miniMonthResize:)
                                                     name:@"MiniMonthResizeNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(calendarDayReady:)
                                                     name:@"CalendarDayReadyNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reconcileLinks:)
                                                     name:@"LinkChangeNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(taskChanged:)
                                                     name:@"TaskCreatedNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(taskChanged:)
                                                     name:@"TaskChangeNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(eventChanged:)
                                                     name:@"EventChangeNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(noteChanged:)
                                                     name:@"NoteChangeNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(ekSyncComplete:)
                                                     name:@"EKSyncCompleteNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(ekReminderSyncComplete:)
                                                     name:@"EKReminderSyncCompleteNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tdSyncComplete:)
                                                     name:@"TDSyncCompleteNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sdwSyncComplete:)
                                                     name:@"SDWSyncCompleteNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadAlerts:)
                                                     name:@"AlertPostponeChangeNotification" object:nil];
        
    }
    
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.task2Link = nil;
    
    self.popoverCtrler = nil;    
    
    [super dealloc];
}


- (CalendarViewController *) getCalendarViewController
{
    return nil;
}

- (SmartListViewController *) getSmartListViewController
{
    return nil;
}

- (NoteViewController *) getNoteViewController
{
    return nil;
}

- (CategoryViewController *) getCategoryViewController
{
    return nil;
}

- (AbstractMonthCalendarView *)getMonthCalendarView
{
    return nil;
}

- (AbstractMonthCalendarView *)getPlannerMonthCalendarView
{
    return nil;
}

- (FocusView *) getFocusView
{
    return nil;
}

- (PlannerBottomDayCal *) getPlannerDayCalendarView
{
    return nil;
}

- (void) hidePopover
{
	if (self.popoverCtrler != nil && [self.popoverCtrler isPopoverVisible])
	{
		[self.popoverCtrler dismissPopoverAnimated:NO];
	}
	
}
-(void) deselect
{
    if (activeView != nil)
    {
        [CATransaction begin];
        [activeView doSelect:NO];
        [CATransaction commit];
    }

    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
    
    [self hidePopover];
    
    activeView = nil;
}

- (Task *) getActiveTask
{
    if (activeView != nil && [activeView isKindOfClass:[TaskView class]])
    {
        return ((TaskView *) activeView).task;
    }
    
    return nil;
}

- (Project *) getActiveProject
{
    if (activeView != nil && [activeView isKindOfClass:[PlanView class]])
    {
        return ((PlanView *) activeView).project;
    }
    
    return nil;
}

- (BOOL) checkControllerActive:(NSInteger)index
{
    //0:Calendar, 1:Tasks, 2:Notes, 3:Projects
    return NO;
}

#pragma mark Refresh
- (void) setNeedsDisplay
{
    PageAbstractViewController *ctrlers[4] = {
        [self getCalendarViewController],
        [self getSmartListViewController],
        [self getNoteViewController],
        [self getCategoryViewController]
    };
    
    for (int i=0; i<4; i++)
    {
        PageAbstractViewController *ctrler = ctrlers[i];
        
        [ctrler setNeedsDisplay];
        
        if ([ctrler isKindOfClass:[CalendarViewController class]])
        {
            CalendarViewController *calCtrler = [self getCalendarViewController];
            [calCtrler refreshADEPane];
        }
        
    }
    
    FocusView *focusView = [self getFocusView];
    
    if (focusView != nil)
    {
        [focusView setNeedsDisplay];
    }
}

- (void) refreshView
{
    PageAbstractViewController *ctrlers[4] = {
        [self getCalendarViewController],
        [self getSmartListViewController],
        [self getNoteViewController],
        [self getCategoryViewController]
    };
    
    for (int i=0; i<4; i++)
    {
        PageAbstractViewController *ctrler = ctrlers[i];
        
        if ([ctrler respondsToSelector:@selector(refreshView)])
        {
            [ctrler refreshView];
        }
    }
    
    FocusView *focusView = [self getFocusView];
    
    if (focusView != nil)
    {
        [focusView refreshView];
    }
}

- (void) refreshData
{
    if ([self checkControllerActive:2])
    {
        NoteViewController *noteCtrler = [self getNoteViewController];
    
        [noteCtrler loadAndShowList];
    }
    
    if ([self checkControllerActive:3])
    {
        CategoryViewController *catCtrler = [self getCategoryViewController];
        
        [catCtrler loadAndShowList];
    }
    
    FocusView *focusView = [self getFocusView];
    
    if (focusView != nil && [focusView checkExpanded])
    {
        [focusView refreshData];
    }
    
    AbstractMonthCalendarView *calView = [self getMonthCalendarView];
    
    [calView refresh];
    
    AbstractMonthCalendarView *plannerCalView = [self getPlannerMonthCalendarView];
    
    [plannerCalView refresh];
    
    PlannerBottomDayCal *planerDayCal = [self getPlannerDayCalendarView];
    [planerDayCal refreshLayout];
}

- (void) resetAllData
{
    TaskManager *tm = [TaskManager getInstance];
    ProjectManager *pm = [ProjectManager getInstance];
    DBManager *dbm = [DBManager getInstance];
    Settings *settings = [Settings getInstance];
    
    [settings refreshTimeZone];
    
    [pm initProjectList:[dbm getProjects]];
    
    [tm initData];
    
    [self refreshData];
    
    self.task2Link = nil;
}

- (void) refreshADE
{
    AbstractMonthCalendarView *calView = [self getMonthCalendarView];
    AbstractMonthCalendarView *plannerCalView = [self getPlannerMonthCalendarView];
    
    [calView refreshADEView];
    [plannerCalView refreshADEView];
    
    [[self getCalendarViewController] refreshADEPane];
}

#pragma mark Action Menu
- (void)showActionMenu:(TaskView *)view
{
    Task *task = view.task;
    
    if ([task isShared])
    {
        return;
    }
    
    NSInteger pk = (task.original != nil && ![task isREException]?task.original.primaryKey:task.primaryKey);
    
    BOOL calendarTask = ([task isTask] && task.original != nil) || [task isManual];
    
    contentView.actionType = calendarTask?ACTION_TASK_EDIT:([task isNote]?ACTION_NOTE_EDIT:ACTION_ITEM_EDIT);
    contentView.tag = pk;
    
    CGRect frm = view.frame;
    frm.origin = [view.superview convertPoint:frm.origin toView:contentView];
    
    UIMenuController *menuCtrler = [UIMenuController sharedMenuController];
    
    [contentView becomeFirstResponder];
    [menuCtrler setTargetRect:frm inView:contentView];
    [menuCtrler setMenuVisible:YES animated:YES];
}

- (void) enableActions:(BOOL)enable onView:(MovableView *)view
{
	if ([[BusyController getInstance] checkSyncBusy])
    {
        return;
    }
    
    BOOL showAction = activeView != view;
    
    [self deselect];
    
    if (showAction)
    {
        UIMenuController *menuCtrler = [UIMenuController sharedMenuController];
        
        if (enable)
        {
            [self performSelector:@selector(showActionMenu:) withObject:view afterDelay:0];
        }
        else
        {
            [menuCtrler setMenuVisible:NO animated:YES];
        }
        
        activeView = enable?view:nil;
        
        if (activeView != nil)
        {
            [activeView doSelect:YES];
        }
    }
    else
    {
        activeView = nil;
    }
}

- (void)showProjectActionMenu:(PlanView *)view
{
    if ([view.project isShared])
    {
        return;
    }
    
    contentView.actionType = ACTION_CATEGORY_EDIT;
    
    CGRect frm = view.frame;
    frm.origin = [view.superview convertPoint:frm.origin toView:contentView];
    
    UIMenuController *menuCtrler = [UIMenuController sharedMenuController];
    
    [contentView becomeFirstResponder];
    [menuCtrler setTargetRect:frm inView:contentView];
    [menuCtrler setMenuVisible:YES animated:YES];
}

- (void) enableCategoryActions:(BOOL)enable onView:(PlanView *)view
{
	if ([[BusyController getInstance] checkSyncBusy])
    {
        return;
    }
    
    if (activeView != nil)
    {
        [activeView doSelect:NO];
    }
    
    if (activeView != view)
    {
        UIMenuController *menuCtrler = [UIMenuController sharedMenuController];
        
        if (enable)
        {
            [self performSelector:@selector(showProjectActionMenu:) withObject:view afterDelay:0];
        }
        else
        {
            [menuCtrler setMenuVisible:NO animated:YES];
        }
        
        activeView = enable?view:nil;
        
        if (activeView != nil)
        {
            [activeView doSelect:YES];
        }
    }
    else
    {
        activeView = nil;
    }
}


#pragma mark Views

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Edit
/*
- (void) editItem:(Task *)item
{
    if ([item isNote])
    {
        NoteDetailTableViewController *ctrler = [[NoteDetailTableViewController alloc] init];
        ctrler.note = item;
        
        [self.navigationController pushViewController:ctrler animated:YES];
        [ctrler release];
    }
    else
    {
        TaskDetailTableViewController *ctrler = [[TaskDetailTableViewController alloc] init];
        
        ctrler.task = item;
        
        [self.navigationController pushViewController:ctrler animated:YES];
        [ctrler release];
    }
}
*/
- (void) editItem:(Task *)item
{
    if (self.popoverCtrler != nil && [self.popoverCtrler.contentViewController isKindOfClass:[SDNavigationController class]])
    {
        if ([item isNote])
        {
            NoteDetailTableViewController *ctrler = [[NoteDetailTableViewController alloc] init];
            ctrler.note = item;
            
            [self.popoverCtrler.contentViewController pushViewController:ctrler animated:YES];
            [ctrler release];
        }
        else
        {
            TaskDetailTableViewController *ctrler = [[TaskDetailTableViewController alloc] init];
            
            ctrler.task = item;
            
            [self.popoverCtrler.contentViewController pushViewController:ctrler animated:YES];
            [ctrler release];
        }
    }
    else
    {
        if ([item isNote])
        {
            NoteDetailTableViewController *ctrler = [[NoteDetailTableViewController alloc] init];
            ctrler.note = item;
            
            [self.navigationController pushViewController:ctrler animated:YES];
            [ctrler release];
        }
        else
        {
            TaskDetailTableViewController *ctrler = [[TaskDetailTableViewController alloc] init];
            
            ctrler.task = item;
            
            [self.navigationController pushViewController:ctrler animated:YES];
            [ctrler release];
        }

    }
}

/*
- (void) editItem:(Task *)item inRect:(CGRect)inRect
{
    [self editItem:item];
}
*/

- (void) editItem:(Task *)task inRect:(CGRect)inRect
{
    if (!_isiPad)
    {
        [self editItem:task];
        
        return;
    }
    
    [self.popoverCtrler dismissPopoverAnimated:NO];
    
    UIViewController *ctrler = nil;
    
    if ([task isNote])
    {
        NoteDetailTableViewController *noteCtrler = [[NoteDetailTableViewController alloc] init];
        noteCtrler.note = task;
        
        ctrler = noteCtrler;
    }
    else
    {
        TaskDetailTableViewController *taskCtrler = [[TaskDetailTableViewController alloc] init];
        taskCtrler.task = task;
        
        ctrler = taskCtrler;
    }
    
	SDNavigationController *navController = [[SDNavigationController alloc] initWithRootViewController:ctrler];
	[ctrler release];
	
	self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
	
	[navController release];
    
    [self.popoverCtrler presentPopoverFromRect:inRect inView:contentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    /*
    [self.popoverCtrler presentPopoverFromRect:inRect inView:contentView permittedArrowDirections:task.listSource == SOURCE_PLANNER_CALENDAR?UIPopoverArrowDirectionAny:(task.listSource == SOURCE_CALENDAR || task.listSource == SOURCE_FOCUS?UIPopoverArrowDirectionLeft:UIPopoverArrowDirectionRight) animated:YES]; */   
}

/*
- (void) editItem:(Task *)item inView:(TaskView *)inView
{
    [self editItem:item];
}
*/

- (void) editItem:(Task *)item inView:(TaskView *)inView
{
    if (!_isiPad)
    {
        [self editItem:item];
        
        return;
    }
    
    UIViewController *editCtrler = nil;
    
    if ([item isNote])
    {
        NoteDetailTableViewController *ctrler = [[NoteDetailTableViewController alloc] init];
        
        ctrler.note = item;
        
        editCtrler = ctrler;
    }
    else
    {
        TaskDetailTableViewController *ctrler = [[TaskDetailTableViewController alloc] init];
        
        ctrler.task = item;
        
        editCtrler = ctrler;
    }
	
    if (editCtrler != nil)
    {
        [self hidePopover];
        
        SDNavigationController *navController = [[SDNavigationController alloc] initWithRootViewController:editCtrler];
        [editCtrler release];
        
        self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
        
        [navController release];
        
        CGRect frm = [inView.superview convertRect:inView.frame toView:contentView];
        /*
        [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:item.listSource == SOURCE_CALENDAR || item.listSource == SOURCE_FOCUS?UIPopoverArrowDirectionLeft:UIPopoverArrowDirectionRight animated:YES];*/
        
        //[self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:item.listSource == SOURCE_PLANNER_CALENDAR?UIPopoverArrowDirectionAny:(item.listSource == SOURCE_CALENDAR || item.listSource == SOURCE_FOCUS?UIPopoverArrowDirectionLeft:UIPopoverArrowDirectionRight) animated:YES];
        if (item.listSource == SOURCE_PLANNER_CALENDAR) {
            if (frm.origin.x <= editCtrler.view.frame.size.width) {
                [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
            } else {
                [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
            }
        } else {
            [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:item.listSource == SOURCE_CALENDAR || item.listSource == SOURCE_FOCUS?UIPopoverArrowDirectionLeft:UIPopoverArrowDirectionRight animated:YES];
        }
    }
}

- (void) editCategory:(Project *) project
{
	ProjectEditViewController *ctrler = [[ProjectEditViewController alloc] init];
	
	ctrler.project = project;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

/*
- (void) editProject:(Project *)project inView:(PlanView *)inView
{
    [self editCategory:project];
}
*/
- (void) editProject:(Project *)project inView:(PlanView *)inView
{
    if (!_isiPad)
    {
        [self editCategory:project];
        
        return;
    }
    
    ProjectEditViewController *editCtrler = [[ProjectEditViewController alloc] init];
    editCtrler.project = project;
    
    SDNavigationController *navController = [[SDNavigationController alloc] initWithRootViewController:editCtrler];
    [editCtrler release];
    
    self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
    
    [navController release];
    
    CGRect frm = [inView.superview convertRect:inView.frame toView:contentView];
    
    [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    
}

- (void) editProject:(Project *)project inRect:(CGRect)inRect
{
    if (!_isiPad)
    {
        [self editCategory:project];
        
        return;
    }
    
    ProjectEditViewController *editCtrler = [[ProjectEditViewController alloc] init];
    editCtrler.project = project;
    
    SDNavigationController *navController = [[SDNavigationController alloc] initWithRootViewController:editCtrler];
    [editCtrler release];
    
    self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
    
    [navController release];
    
    [self.popoverCtrler presentPopoverFromRect:inRect inView:contentView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    
}

#pragma mark Calendar Actions
- (void) scrollToDate:(NSDate *)date
{
    [self deselect];
    
    TaskManager *tm = [TaskManager getInstance];
    
    tm.today = date;
    
    MiniMonthView *mmView = [self getMiniMonth];
    
    if (mmView != nil)
    {
        [mmView highlight:date];
    }
    
    CalendarViewController *ctrler = [self getCalendarViewController];
    
    [ctrler refreshPanes];
}

- (void) jumpToDate:(NSDate *)date
{
    [self deselect];
    
    MiniMonthView *mmView = [self getMiniMonth];
    
    /*if (mmView != nil)
    {
        [mmView updateWeeks:date];
    }*/
    
    [[TaskManager getInstance] initCalendarData:date];

    if (mmView != nil)
    {
        [mmView highlight:date];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CalendarDayChangeNotification" object:nil]; //to refresh Calendar layout
}

#pragma mark Task Actions

- (void) reconcileItem:(Task *)item reSchedule:(BOOL)reSchedule
{
    CalendarViewController *calCtrler = [self getCalendarViewController];
    
    if (!reSchedule)
    {
        //don't need to refresh Calendar View and Task List when re-scheduling because they are refreshed when schedule is finished
        
        [calCtrler reconcileItem:item];
        
        SmartListViewController *taskCtrler = [self getSmartListViewController];
        
        [taskCtrler reconcileItem:item];
    }
    
    NoteViewController *noteCtrler = [self getNoteViewController];
    
    [noteCtrler reconcileItem:item];
    
    CategoryViewController *catCtrler = [self getCategoryViewController];
    
    [catCtrler reconcileItem:item];
    
    FocusView *focusView = [self getFocusView];
    
    if (focusView != nil)
    {
        [focusView reconcileItem:item];
    }
    
    /*
    //if ([item isADE]) -> need to update when convert from ADE -> Event also
    {
        AbstractMonthCalendarView *calView = [self getMonthCalendarView];
        
        [calView refreshADEView];
        [[self getCalendarViewController] refreshADEPane];
        
        AbstractMonthCalendarView *plannerCalView = [self getPlannerMonthCalendarView];
        
        [plannerCalView refreshADEView];
    }*/
    
    AbstractMonthCalendarView *calView = [self getMonthCalendarView];
    AbstractMonthCalendarView *plannerCalView = [self getPlannerMonthCalendarView];

    [calView refresh];
    [plannerCalView refresh];
    [calCtrler refreshADEPane];
}

- (void) updateTask:(Task *)task withTask:(Task *)taskCopy
{
    TaskManager *tm = [TaskManager getInstance];
    
    // check Manual task on title
    [taskCopy checkHasPinnedCharacterInTitle];
    BOOL isManual = [task isManual];
    
    actionTask = task;
    actionTaskCopy = taskCopy;
    
    NSDate *dDate = [[(task.original != nil?task.original.deadline:task.deadline) copy] autorelease];
    NSDate *sDate = [[(task.original != nil?task.original.startTime:task.startTime) copy] autorelease];
    
    //BOOL isADE = ([task isADE] || [task.original isADE] || [taskCopy isADE]);
    
    BOOL reChange = [task isRE] || [task.original isRE] || [taskCopy isRE];
    
    BOOL reSchedule = NO;
    
    if (taskCopy.primaryKey == -1)
    {
        [task updateByTask:taskCopy];
        
        [tm addTask:task];
        
        reSchedule = YES;
    }
    else
    {
        BOOL reEdit = [task isREInstance];
        
        BOOL convertRE2Task = reEdit && [taskCopy isTask];
        
        if (convertRE2Task)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_warningText  message:_convertREIntoTaskConfirmation delegate:self cancelButtonTitle:_cancelText otherButtonTitles:_onlyInstanceText, _allFollowingText, nil];
            
            alertView.tag = -13001;
            
            [alertView show];
            [alertView release];
            
            return;
        }
        else if (reEdit) //change RE
        {
            UIAlertView *changeREAlert= [[UIAlertView alloc] initWithTitle:_changeRETitleText  message:_changeREInstanceText delegate:self cancelButtonTitle:_cancelText otherButtonTitles:nil];
            changeREAlert.tag = -13000;
            [changeREAlert addButtonWithTitle:_onlyInstanceText];
            [changeREAlert addButtonWithTitle:_allEventsText];
            [changeREAlert addButtonWithTitle:_allFollowingText];
            [changeREAlert show];
            [changeREAlert release];
            
            return;
        }
        else
        {
            reSchedule = [tm updateTask:task withTask:taskCopy];
        }
    }
    // refresh smartlist
    if (isManual) {
        SmartListViewController *smartlistController = [self getSmartListViewController];
        [smartlistController refreshData];
    }
    
    [self reconcileItem:task reSchedule:reSchedule];
    
    /*
    AbstractMonthCalendarView *calView = [self getMonthCalendarView];
    
    AbstractMonthCalendarView *plannerCalView = [self getPlannerMonthCalendarView];
    
    //if (calView != nil)
    {
        if (sDate != nil)
        {
            //refresh Calendar cell when convert Task -> Event
            [calView refreshCellByDate:sDate];
            [plannerCalView refreshCellByDate:sDate];
        }
        
        if (dDate != nil)
        {
            [calView refreshCellByDate:dDate];
            [plannerCalView refreshCellByDate:dDate];
        }
        
        if (reChange)
        {
            [calView refresh];
            [plannerCalView refresh];
        }
        else if ([taskCopy isTask])
        {
            if (taskCopy.deadline != nil)
            {
                [calView refreshCellByDate:taskCopy.deadline];
                [plannerCalView refreshCellByDate:taskCopy.deadline];
            }
        }
        else
        {
            [calView refreshCellByDate:taskCopy.startTime];
            [plannerCalView refreshCellByDate:taskCopy.startTime];
        }
    }
    */
    
    [self deselect];
}

- (void) convertRE2Task:(NSInteger)option
{
    TaskManager *tm = [TaskManager getInstance];
    
    BOOL isADE = [actionTask isADE];
    
    Task *rt = [tm convertRE2Task:actionTask option:option];
    
    actionTaskCopy.primaryKey = rt.primaryKey;
    
    [tm updateTask:actionTask withTask:actionTaskCopy];
    
    MiniMonthView *mmView = [self getMiniMonth];
    
    if (mmView != nil)
    {
        [mmView refresh];
    }
    
    if (isADE)
    {
        [[self getCalendarViewController] refreshADEPane];
    }
}

- (void) deleteRE
{
    TaskManager *tm = [TaskManager getInstance];
    
    Task *task = [self getActiveTask];
    
    //AbstractMonthCalendarView *calView = [self getMonthCalendarView];
    
    //AbstractMonthCalendarView *plannerCalView = [self getPlannerMonthCalendarView];
    
    [task retain];
    
    [self deselect];
    
    NSInteger pk = task.primaryKey;
    
    if (task.original != nil && ![task isREException])
    {
        pk = task.original.primaryKey;
    }
    
    if (pk == self.task2Link.primaryKey)
    {
        self.task2Link = nil;
    }
    
    Task *rootRE = [tm findREByKey:task.primaryKey];
    
    if (rootRE != nil)
    {
        Task *instance = [[rootRE copy] autorelease];
        instance.original = rootRE;
        
        [tm deleteREInstance:instance deleteOption:2];
        
        /*
        [calView refresh];
        
        [plannerCalView refresh];*/

        [self reconcileItem:task reSchedule:YES];
    }
    
    [task release];
}

-(void) deleteRE:(NSInteger)deleteOption
{
    Task *task = [self getActiveTask];
    
    //AbstractMonthCalendarView *calView = [self getMonthCalendarView];
    
    //AbstractMonthCalendarView *plannerCalView = [self getPlannerMonthCalendarView];
    
    NSInteger pk = task.primaryKey;
    
    if (task.original != nil && ![task isREException])
    {
        pk = task.original.primaryKey;
    }
    
    if (pk == self.task2Link.primaryKey)
    {
        self.task2Link = nil;
    }
    
    [task retain];
    
    [self deselect];
	
	[[TaskManager getInstance] deleteREInstance:task deleteOption:deleteOption];
    
    /*
    [calView refresh];
    
    [plannerCalView refresh];*/
    
    CalendarViewController *calCtrler = [self getCalendarViewController];
    
    [calCtrler refreshView];
    
    [self reconcileItem:task reSchedule:YES];
    
    [task release];
}

- (void) doDeleteTask
{
    TaskManager *tm = [TaskManager getInstance];
    
    Task *task = [self getActiveTask];
    //AbstractMonthCalendarView *calView = [self getMonthCalendarView];
    //AbstractMonthCalendarView *plannerCalView = [self getPlannerMonthCalendarView];
    
    NSInteger pk = task.primaryKey;
    
    if (task.original != nil && ![task isREException])
    {
        pk = task.original.primaryKey;
    }
    
    if (pk == self.task2Link.primaryKey)
    {
        self.task2Link = nil;
    }
    
    /*
    if ([task isNote])
    {
        [tm deleteTask:task];
    }
    else
    {
        //note: task original could be removed from task list so need to store neccessary information instead of directly call methods on the task after done
        
        BOOL isRE = [task isRE];
        NSInteger type = task.type;
        NSDate *start = [[task.startTime copy] autorelease];
        NSDate *deadline = [[task.deadline copy] autorelease];
        
        [tm deleteTask:task];
        
        
        if (isRE)
        {
            [calView refresh];
        }

        if (type == TYPE_TASK)
        {
            if (start != nil)
            {
                [calView refreshCellByDate:start];
                [plannerCalView refreshCellByDate:start];
            }
            
            if (deadline != nil)
            {
                [calView refreshCellByDate:deadline];
                [plannerCalView refreshCellByDate:deadline];
                
                if ([Common daysBetween:deadline sinceDate:tm.today] <= 0)
                {
                    [[self getFocusView] refreshData];
                }
            }
        }
        else if (type == TYPE_EVENT)
        {
            [calView refreshCellByDate:start];
            [plannerCalView refreshCellByDate:start];
        }
        else if (type == TYPE_ADE)
        {
            if ([TaskManager checkTaskInTimeRange:task startTime:[Common clearTimeForDate:tm.today] endTime:[Common getEndDate:tm.today]])
            {
                [[self getFocusView] refreshData];
            }
        }

    }
    */
    [tm deleteTask:task];
    
    [self reconcileItem:task reSchedule:YES];
    
    [self deselect];
}

- (void) deleteTask
{
    Task *task = [self getActiveTask];
    
    if (task != nil)
    {
        if (task.primaryKey == -1 && task.original != nil && [task.original isRE]) //change RE
        {
            UIAlertView *deleteREAlert= [[UIAlertView alloc] initWithTitle:_deleteRETitleText  message:_deleteREInstanceText delegate:self cancelButtonTitle:_cancelText otherButtonTitles:nil];
            deleteREAlert.tag = -11000;
            [deleteREAlert addButtonWithTitle:_onlyInstanceText];
            [deleteREAlert addButtonWithTitle:_allEventsText];
            [deleteREAlert addButtonWithTitle:_allFollowingText];
            [deleteREAlert show];
            [deleteREAlert release];
        }
        else if ([[Settings getInstance] deleteWarning])
        {
            if ([task isRE])
            {
                UIAlertView *deleteREAlert= [[UIAlertView alloc] initWithTitle:_deleteRETitleText  message:_deleteAllInSeriesText delegate:self cancelButtonTitle:_cancelText otherButtonTitles:_okText, nil];
                deleteREAlert.tag = -12000;
                [deleteREAlert show];
                [deleteREAlert release];
            }
            else
            {
                NSString *msg = _itemDeleteText;
                NSInteger tag = -10000;
                
                UIAlertView *taskDeleteAlertView = [[UIAlertView alloc] initWithTitle:_itemDeleteTitle  message:msg delegate:self cancelButtonTitle:_cancelText otherButtonTitles:nil];
                
                taskDeleteAlertView.tag = tag;
                
                [taskDeleteAlertView addButtonWithTitle:_okText];
                [taskDeleteAlertView show];
                [taskDeleteAlertView release];
                
            }
        }
        else
        {
            [self doDeleteTask];
        }
    }
}

- (void) copyTask
{
    Task *task = [self getActiveTask];
    
    if (task != nil)
    {
        [task retain];
        
        CGRect frm = [activeView.superview convertRect:activeView.frame toView:contentView];
        
        [self deselect];
        
        Task *tmp = task;
        
        if (task.original != nil && ![task isREException])
        {
            tmp = task.original;
        }
        
        Task *taskCopy = [[tmp copy] autorelease];
        
        taskCopy.primaryKey = -1;
        taskCopy.name = ([tmp isNote]?taskCopy.name:[NSString stringWithFormat:@"%@ (copy)", taskCopy.name]);
        taskCopy.links = nil;
        taskCopy.listSource = tmp.listSource;
        
        if ([task isREException])
        {
            taskCopy.groupKey = -1;
            taskCopy.repeatData = nil;
            taskCopy.original = nil;
        }
        
        //[self editItem:taskCopy inView:activeView];
        [self editItem:taskCopy inRect:frm];
        
        [task release];
    }
    
    //[self deselect];
}

- (void) markDoneTask:(Task *)task
{
    AbstractMonthCalendarView *calView = [self getMonthCalendarView];
    AbstractMonthCalendarView *plannerCalView = [self getPlannerMonthCalendarView];
    
    TaskManager *tm = [TaskManager getInstance];
    
    NSDate *oldDeadline = [[task.deadline copy] autorelease];
    BOOL isRT = [task isRT];
    
    //[tm markDoneTask:task];
    NSDate *startTime = nil;
    if ([task isManual]) {
        startTime = [[task.startTime copy] autorelease];
    }
    
    if ([task isDone])
    {
        [tm unDone:task];
    }
    else
    {
        [tm markDoneTask:task];
    }
    
    if (startTime != nil) {
        [calView refreshCellByDate:startTime];
        // refresh planner day cal
        PlannerBottomDayCal *plannerDayCal = [self getPlannerDayCalendarView];
        [plannerDayCal refreshLayout];
    }
    
    if (oldDeadline != nil)
    {
        [calView refreshCellByDate:oldDeadline];
        [plannerCalView refreshCellByDate:oldDeadline];
        
        if ([Common daysBetween:oldDeadline sinceDate:tm.today] <= 0)
        {
            [[self getFocusView] refreshData];
        }
    }
    
    if ([self checkControllerActive:3])
    {
        CategoryViewController *ctrler = [self getCategoryViewController];
        
        if (ctrler.filterType == TYPE_TASK)
        {
            [ctrler loadAndShowList];
        }
    }
    
    if (isRT)
    {
        [calView refreshCellByDate:task.deadline];
        [plannerCalView refreshCellByDate:task.deadline];
    }
    
}

- (void) markDoneTask
{
    Task *task = [self getActiveTask];
    
    if (task != nil)
    {
        [task retain];
        
        [self deselect];
                
        [self markDoneTask:task];
        
        [task release];
    }
}

-(void) createTaskFromNote:(Task *)fromNote
{
    TaskManager *tm = [TaskManager getInstance];
    TaskLinkManager *tlm = [TaskLinkManager getInstance];
    
    Task *note = fromNote != nil?fromNote:[self getActiveTask];
    
    if (note != nil)
    {
        [note retain];
        
        [self deselect];
        
        Task *task = [[Task alloc] init];
        
        switch (tm.taskTypeFilter)
        {
            case TASK_FILTER_STAR:
            {
                task.status = TASK_STATUS_PINNED;
            }
                break;
            case TASK_FILTER_DUE:
            {
                task.deadline = [NSDate date];
            }
                break;
        }
        
        task.project = note.project;
        task.name = note.name;
        
        [tm addTask:task];
        
        NSInteger linkId = [tlm createLink:task.primaryKey destId:note.primaryKey];
        
        if (linkId != -1)
        {
            //edit in Category view
            task.links = [tlm getLinkIds4Task:task.primaryKey];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil]; //trigger sync for Link
        }
        
        [note release];
        
        [self reconcileItem:task reSchedule:YES];
    }
}

- (void) markDoneTaskInView:(TaskView *)view
{
    Task *task = view.task;
    
    AbstractMonthCalendarView *calView = [self getMonthCalendarView];
    
    AbstractMonthCalendarView *plannerCalView = [self getPlannerMonthCalendarView];
    
    [task retain];
    
    [self deselect];
    
    NSDate *oldDue = [[task.deadline copy] autorelease];
    BOOL isRT = [task isRT]; //note: task original could be removed from task list so need to store this information instead of directly call the method after done
    
    BOOL isManual = [task isManual]; // for refesh minimonth
    
    TaskManager *tm = [TaskManager getInstance];
    
    if ([task isDone])
    {
        [tm unDone:task];
    }
    else
    {
        [tm markDoneTask:task];
    }
    
    if (oldDue != nil)
    {
        [calView refreshCellByDate:oldDue];
        [plannerCalView refreshCellByDate:oldDue];
        
        if ([Common daysBetween:oldDue sinceDate:tm.today] <= 0)
        {
            [[self getFocusView] refreshData];
        }
    }
    if ([self checkControllerActive:3])
    {
        CategoryViewController *ctrler = [self getCategoryViewController];
        
        if (ctrler.filterType == TYPE_TASK)
        {
            [ctrler loadAndShowList];
        }
    }
    
    if (isRT)
    {
        [calView refreshCellByDate:task.deadline];
        [plannerCalView refreshCellByDate:task.deadline];
        
        [view setNeedsDisplay];
    }
    
    if (isManual) {
        [calView refresh];
    }
    
    [task release];
}

- (void) starTaskInView:(TaskView *)taskView
{
	TaskManager *tm = [TaskManager getInstance];
	
	Task *task = taskView.task;
    
    [tm starTask:task];
    
    SmartListViewController *slViewCtrler = [self getSmartListViewController];
    
    [slViewCtrler setNeedsDisplay];
    
    /*
    CategoryViewController *catViewCtrler = [self getCategoryViewController];
    
    [catViewCtrler setNeedsDisplay];
    */
    CategoryViewController *ctrler = [self getCategoryViewController];

    if (task.listSource == SOURCE_CATEGORY)
    {
        [ctrler setNeedsDisplay];
        
        if ([self checkControllerActive:1])
        {
            [slViewCtrler refreshLayout];
        }
    }
    else if ([self checkControllerActive:3])
    {
        if (ctrler.filterType == TYPE_TASK)
        {
            [ctrler loadAndShowList];
        }
    }    
}

- (void) convertRE2Task:(NSInteger)option task:(Task *)task
{
    TaskManager *tm = [TaskManager getInstance];
    
    [tm convertRE2Task:task option:option];
    
    MiniMonthView *mmView = [self getMiniMonth];
    
    if (mmView != nil)
    {
        [mmView refresh];
    }
    
    PlannerBottomDayCal *plannerDayCal = [self getPlannerDayCalendarView];
    [plannerDayCal refreshLayout];
    
    [self reconcileItem:task reSchedule:YES];
}

- (void) convert2Task:(Task *)task
{
    NSDate *sDate = [[task.startTime copy] autorelease];
    
    Task *taskCopy = [[task copy] autorelease];
    
    taskCopy.type = TYPE_TASK;
    
    if (task.original != nil && ![task isREException])
    {
        task = task.original;
    }
    
    //BOOL isRE = [task isRE];
    
    // check if this is STask
    if ([taskCopy isManual]) {
        [taskCopy setManual:NO];
    }
    
    TaskManager *tm = [TaskManager getInstance];
    
    [tm updateTask:task withTask:taskCopy];
    
    /*
    if (isRE)
    {
        MiniMonthView *mmView = [self getMiniMonth];

        if (mmView != nil)
        {
            [mmView refresh];
        }
    }
    else
    {
        AbstractMonthCalendarView *calView = [self getMonthCalendarView];
        
        AbstractMonthCalendarView *plannerCalView = [self getMonthCalendarView];
        
        //if (calView != nil)
        {
            [calView refreshCellByDate:sDate];
            [plannerCalView refreshCellByDate:sDate];
            
            if (task.deadline != nil)
            {
                [calView refreshCellByDate:task.deadline];
                [plannerCalView refreshCellByDate:task.deadline];
            }            
        }
    }
    */
    
    PlannerBottomDayCal *plannerDayCal = [self getPlannerDayCalendarView];
    [plannerDayCal refreshLayout];
    
    [self reconcileItem:task reSchedule:YES];
}

- (void) changeTime:(Task *)task time:(NSDate *)time
{
    TaskManager *tm = [TaskManager getInstance];
    
    //NSDate *sDate = [task.startTime copy];
    //NSDate *dDate = [task.deadline copy];
    
    [tm moveTime:[Common copyTimeFromDate:time toDate:tm.today] forEvent:task];
    
    /*
    if ([task isRE])
    {
        MiniMonthView *mmView = [self getMiniMonth];
        
        if (mmView != nil)
        {
            [mmView refresh];
        }
    }
    else
    {
        AbstractMonthCalendarView *calView = [self getMonthCalendarView];
        
        AbstractMonthCalendarView *plannerCalView = [self getPlannerMonthCalendarView];
        
        //if (calView != nil)
        {
            if (sDate != nil)
            {
                [calView refreshCellByDate:sDate];
                [plannerCalView refreshCellByDate:sDate];
                
                [sDate release];
            }
            
            if (dDate != nil)
            {
                [calView refreshCellByDate:dDate];
                [plannerCalView refreshCellByDate:dDate];
                [dDate release];
            }
            
            [calView refreshCellByDate:task.startTime];
            [plannerCalView refreshCellByDate:task.startTime];
        }
    }*/
    
    [self reconcileItem:task reSchedule:YES];
}

-(void) changeTask:(Task *)task toProject:(NSInteger)prjKey
{
    TaskManager *tm = [TaskManager getInstance];
    DBManager *dbm = [DBManager getInstance];
    
    Task *slTask = [tm getTask2Update:task];
    
    if (slTask != nil)
    {
        slTask.project = prjKey;
        
        [slTask updateIntoDB:[dbm getDatabase]];

        //Task *schedTask = [tm findScheduledTask:slTask];
        //schedTask.project = prjKey;
        
        NSMutableArray *list = [tm findScheduledTasks:slTask];
        
        for (Task *tmp in list)
        {
            tmp.project = prjKey;
        }
       
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];
    }
    
    
    task.project = prjKey;
    
    [self reconcileItem:task reSchedule:NO];
}

-(void)quickAddEvent:(NSString *)name startTime:(NSDate *)startTime
{
	//////printf("quick add - %s, start: %s\n", [name UTF8String], [[startTime description] UTF8String]);
	
	Task *event = [[Task alloc] init];
	
	event.name = name;
	event.startTime = startTime;
	event.endTime = [Common dateByAddNumSecond:3600 toDate:event.startTime];
	
	event.type = TYPE_EVENT;
	
	[[TaskManager getInstance] addTask:event];
	    
    MiniMonthView *mmView = [self getMiniMonth];
	
    [mmView.calView refreshCellByDate:startTime];
	
	[self reconcileItem:event reSchedule:YES];
    
    [event release];
}

- (void) quickAddItem:(NSString *)name type:(NSInteger)type
{
	TaskManager *tm = [TaskManager getInstance];
	
	Task *task = [[Task alloc] init];
	task.type = type;
	task.name = name;
	task.duration = tm.lastTaskDuration;
	task.project = tm.lastTaskProjectKey;

    task.startTime = [Common dateByRoundMinute:15 toDate:tm.today];
    task.endTime = [Common dateByAddNumSecond:3600 toDate:task.startTime];
	
	switch (tm.taskTypeFilter)
	{
		case TASK_FILTER_STAR:
		{
			task.status = TASK_STATUS_PINNED;
		}
			break;
		case TASK_FILTER_DUE:
		{
			task.deadline = [NSDate date];
		}
			break;
	}
    
    [tm addTask:task];
    
    [self reconcileItem:task reSchedule:(type != TYPE_NOTE)];
    
	[task release];
}

#pragma mark Project Actions
- (void) doDeleteCategory:(BOOL) cleanFromDB
{
    Project *plan = [self getActiveProject];
    
    MiniMonthView *mmView = [self getMiniMonth];
    
	if (plan != nil)
	{
        TaskManager *tm = [TaskManager getInstance];
        
		[[ProjectManager getInstance] deleteProject:plan cleanFromDB:cleanFromDB];
		[tm initData];
		
        if (mmView != nil)
        {
            [mmView initCalendar:tm.today];
        }

		[self refreshData];
        
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EventChangeNotification" object:nil];
	}
    
    [self deselect];
}

- (void) deleteCategory
{
    Project *project = [self getActiveProject];
    
    if (project != nil)
    {
		if ([[Settings getInstance] taskDefaultProject] == project.primaryKey)
		{
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_deleteWarningText message:_cannotDeleteDefaultProjectText delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
			
			[alertView show];
			[alertView release];
		}
		else
		{
            UIActionSheet *deleteActionSheet = [[UIActionSheet alloc] initWithTitle:_deleteCategoryWarningText delegate:self cancelButtonTitle:_cancelText destructiveButtonTitle:_deleteText otherButtonTitles: nil];
            
            [deleteActionSheet showInView:contentView];
            
            [deleteActionSheet release];
		}
    }
}

- (void) copyCategory
{
    Project *plan = [self getActiveProject];
    
	if (plan != nil)
	{
        Project *planCopy = [[plan copy] autorelease];
        
        CGRect frm = [activeView.superview convertRect:activeView.frame toView:contentView];
        
        [self deselect];
        
        planCopy.name = [NSString stringWithFormat:@"%@ (copy)", plan.name];
        planCopy.primaryKey = -1;
        planCopy.ekId = @"";
        planCopy.tdId = @"";
        
        [self editProject:planCopy inRect:frm];
	}
    
    //[self deselect];
}


#pragma mark Link Actions
- (void) copyLink
{
    Task *task = [self getActiveTask];
    
    if (task.original != nil && ![task isREException])
    {
        self.task2Link = task.original;
    }
    else
    {
        self.task2Link = task;
    }
}

- (void) pasteLink
{
    Task *task = [self getActiveTask];
    
    task = (task.original != nil && ![task isREException])?task.original:task;
    
    [task retain];
    
    [self deselect];
    
    TaskLinkManager *tlm = [TaskLinkManager getInstance];
    
    int linkId = [tlm createLink:task.primaryKey destId:self.task2Link.primaryKey];
    
    if (linkId != -1)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil]; //trigger sync for Link
    }
    
    [task release];
}

- (void)reconcileLinks:(NSNotification *)notification
{
    TaskManager *tm = [TaskManager getInstance];
    
    [tm reconcileLinks:notification.userInfo];
    
    PageAbstractViewController *ctrlers[4] = {
        [self getCalendarViewController],
        [self getSmartListViewController],
        [self getNoteViewController],
        [self getCategoryViewController]
    };
    
    for (int i=0; i<4; i++)
    {
        PageAbstractViewController *ctrler = ctrlers[i];
        
        [ctrler reconcileLinks:notification.userInfo];
        
        [ctrler setNeedsDisplay];
    }
    
    // refresh link icons in Planner Day Cal
    PlannerBottomDayCal *plannerDayCal = [self getPlannerDayCalendarView];
    if (plannerDayCal != nil) {
        [plannerDayCal reconcileLinks:notification.userInfo];
        [plannerDayCal setNeedsDisplay];
    }
    
    FocusView *focusView = [self getFocusView];
    
    if (focusView != nil)
    {
        [focusView reconcileLinks:notification.userInfo];
        
        [focusView setNeedsDisplay];
    }
}

#pragma mark Actions
- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{    
	if (alertVw.tag == -11000 && buttonIndex != 0) //not Cancel
	{
		[self deleteRE:buttonIndex];
	}
	if (alertVw.tag == -12000 && buttonIndex != 0)
	{
		[self deleteRE];	//all series
	}
	else if (alertVw.tag == -10000)
	{
		if (buttonIndex == 1)
		{
			[self doDeleteTask];
        }
    }
	else if (alertVw.tag == -10001 && buttonIndex != 0)
	{
		[self doDeleteCategory:(buttonIndex == 2)];
	}
	else if (alertVw.tag == -13000)
	{
		if (buttonIndex > 0)
		{
            BOOL isADE = ([actionTask isADE] || [actionTaskCopy isADE]);
            
            if (buttonIndex == 2) //all series
            {
                if ([actionTask.startTime compare:actionTaskCopy.startTime] == NSOrderedSame && [actionTask.endTime compare:actionTaskCopy.endTime] == NSOrderedSame) //user does not change time -> keep root time
                {
                    actionTaskCopy.startTime = actionTask.original.startTime;
                    actionTaskCopy.endTime = actionTask.original.endTime;
                }
            }
            
			[[TaskManager getInstance] updateREInstance:actionTask withRE:actionTaskCopy updateOption:buttonIndex];
            
            if ([self isKindOfClass:[PlannerViewController class]]) {
                if (isADE) {
                    PlannerMonthView *plannerMonthView = (PlannerMonthView*)[self getPlannerMonthCalendarView];
                    // reload openning week
                    [plannerMonthView refreshOpeningWeek:nil];
                } else {
                    PlannerBottomDayCal *plannerDayCal = [self getPlannerDayCalendarView];
                    [plannerDayCal refreshLayout];
                }
            } else {
                MiniMonthView *mmView = [self getMiniMonth];
                
                if (isADE)
                {
                    [self refreshADE];
                }
                
                if (mmView != nil)
                {
                    [mmView refresh];
                }
            }
		}
        
        [self hidePopover];
	}
	else if (alertVw.tag == -13001)
	{
        if (buttonIndex != 0)
        {
            [self convertRE2Task:buttonIndex];
        }
        
        [self hidePopover];
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 1)
    {
        [self doDeleteCategory:NO];
    }
}

#pragma mark Sync & Backup
- (void) autoPush
{
    if (_autoPushPending)
    {
        TDSync *tdSync = [TDSync getInstance];
        SDWSync *sdwSync = [SDWSync getInstance];
        EKSync *ekSync = [EKSync getInstance];
        EKReminderSync *rmdSync = [EKReminderSync getInstance];
        
        Settings *settings = [Settings getInstance];
        
        if (settings.autoSyncEnabled && settings.autoPushEnabled)
        {
            //printf("Auto Push ...\n");
            
            if (settings.sdwSyncEnabled)
            {
                if (settings.sdwLastSyncTime == nil) //first sync
                {
                    //printf("[1] init sdw sync 2-way\n");
                    [sdwSync initBackgroundSync];
                }
                else
                {
                    //printf("task changed -> init sdw sync 1-way\n");
                    [sdwSync initBackgroundAuto1WaySync];
                }
            }
            else if (settings.ekSyncEnabled)
            {
                [ekSync initBackgroundAuto1WaySync];
            }
            else if (settings.tdSyncEnabled)
            {
                if (settings.tdLastSyncTime == nil) //first sync
                {
                    [tdSync initBackgroundSync];
                }
                else
                {
                    [tdSync initBackground1WaySync];
                }
            }
            else if (settings.rmdSyncEnabled)
            {
                if (settings.rmdLastSyncTime == nil) //first sync
                {
                    [rmdSync initBackgroundSync];
                }
                else
                {
                    [rmdSync initBackgroundAuto1WaySync];
                }
                
            }
        }
        
        _autoPushPending = NO;
    }
}

- (void) backup
{
    [self deselect];
    
    [SmartCalAppDelegate backupDB];
}

- (void) sync
{
    Settings *settings = [Settings getInstance];
    
    if (settings.syncEnabled)
    {
        if (settings.sdwSyncEnabled)
        {
            [[SDWSync getInstance] initBackgroundSync];
        }
        else if (settings.ekSyncEnabled)
        {
            [[EKSync getInstance] initBackgroundSync];
        }
        else if (settings.tdSyncEnabled)
        {
            [[TDSync getInstance] initBackgroundSync];
        }
        else if (settings.rmdSyncEnabled)
        {
            [[EKReminderSync getInstance] initBackgroundSync];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_warningText message:_syncOffWarningText delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
            
            [alertView show];
            [alertView release];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_warningText message:_syncOffWarningText delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
        
        [alertView show];
        [alertView release];
    }
}

#pragma mark Notification
- (void)miniMonthResize:(NSNotification *)notification
{
    [UIView beginAnimations:@"mmresize_animation" context:NULL];
    [UIView setAnimationDuration:0.2];
    
    FocusView *focusView = [self getFocusView];
    MiniMonthView *mmView = [self getMiniMonth];
    
    if (focusView != nil && !focusView.hidden && mmView != nil)
    {
        [focusView refreshData];
        
        CGRect frm = focusView.frame;
        
        frm.origin.y = mmView.frame.origin.y + mmView.bounds.size.height + 10;
        
        focusView.frame = frm;
    }
    
    CalendarViewController *ctrler = [self getCalendarViewController];
    [ctrler refreshFrame];
    
    [UIView commitAnimations];
}

- (void)calendarDayReady:(NSNotification *)notification
{
    FocusView *focusView = [self getFocusView];
    
    if (focusView !=nil && !focusView.hidden)
    {
        [focusView refreshData];
        
        CalendarViewController *ctrler = [self getCalendarViewController];
        [ctrler refreshFrame];
    }
}

- (void)taskChanged:(NSNotification *)notification
{
    _autoPushPending = YES;
}

- (void)eventChanged:(NSNotification *)notification
{
    _autoPushPending = YES;
}

- (void)noteChanged:(NSNotification *)notification
{
    _autoPushPending = YES;
}

- (void)ekSyncComplete:(NSNotification *)notification
{
    [self deselect];
    
    TaskManager *tm = [TaskManager getInstance];
    Settings *settings = [Settings getInstance];
    EKSync *ekSync = [EKSync getInstance];
    
    if (ekSync.resultCode != 0)
    {
        return;
    }
    
    int mode = [[notification.userInfo objectForKey:@"SyncMode"] intValue];
    
    //printf("EK Sync complete - mode: %s\n", (mode == SYNC_AUTO_1WAY?"auto 1 way":"2 way"));
    
    if (mode == SYNC_AUTO_1WAY)
    {
        [tm refreshSyncID4AllItems];
        
        CalendarViewController *ctrler = [self getCalendarViewController];
        
        [ctrler.calendarLayoutController refreshSyncID4AllItems];
        
        //if (settings.tdSyncEnabled && settings.tdAutoSyncEnabled)
        if (settings.tdSyncEnabled && settings.autoPushEnabled)
        {
            if (settings.tdLastSyncTime == nil) //first sync
            {
                [[TDSync getInstance] initBackgroundSync];
            }
            else
            {
                [[TDSync getInstance] initBackground1WaySync];
            }
        }
        
        return;
    }
    
    if (mode == SYNC_MANUAL_2WAY_BACK)
    {
        [self resetAllData];
        
        return;
    }
    
    if (settings.tdSyncEnabled)
    {
        if (mode == SYNC_AUTO_2WAY)
        {
            if (settings.autoSyncEnabled)
            {
                [[TDSync getInstance] initBackgroundAuto2WaySync];
            }
            else
            {
                [self resetAllData];
            }
        }
        else if (mode == SYNC_MANUAL_2WAY)
        {
            [[TDSync getInstance] initBackgroundSync];
        }
        else
        {
            [self resetAllData];
        }
    }
    else if (settings.rmdSyncEnabled)
    {
        if (mode == SYNC_AUTO_2WAY)
        {
            if (settings.autoSyncEnabled)
            {
                [[EKReminderSync getInstance] initBackgroundAuto2WaySync];
            }
            else
            {
                [self resetAllData];
            }
        }
        else if (mode == SYNC_MANUAL_2WAY)
        {
            [[EKReminderSync getInstance] initBackgroundSync];
        }
        else
        {
            [self resetAllData];
        }
    }
    else
    {
        [self resetAllData];
    }
    
}

- (void)ekReminderSyncComplete:(NSNotification *)notification
{
    //printf("Toodledo Sync complete\n");
    [self deselect];
    
    Settings *settings = [Settings getInstance];
    TaskManager *tm = [TaskManager getInstance];
    
    int mode = [[notification.userInfo objectForKey:@"SyncMode"] intValue];
    
    if (mode != SYNC_AUTO_1WAY)
    {
        if (settings.ekSyncEnabled)
        {
            [[EKSync getInstance] initBackgroundSyncBack];
        }
        else
        {
            [self resetAllData];
        }
    }
    else
    {
        [tm refreshSyncID4AllItems];
        
        CalendarViewController *ctrler = [self getCalendarViewController];
        
        [ctrler.calendarLayoutController refreshSyncID4AllItems];
        
        return;
    }
}

- (void)tdSyncComplete:(NSNotification *)notification
{
    //printf("Toodledo Sync complete\n");
    [self deselect];
    
    Settings *settings = [Settings getInstance];
    TaskManager *tm = [TaskManager getInstance];
    
    int mode = [[notification.userInfo objectForKey:@"SyncMode"] intValue];
    
    if (mode != SYNC_AUTO_1WAY)
    {
        if (settings.ekSyncEnabled)
        {
            [[EKSync getInstance] initBackgroundSyncBack];
        }
        else
        {
            [self resetAllData];
        }
    }
    else
    {
        [tm refreshSyncID4AllItems];
        
        CalendarViewController *ctrler = [self getCalendarViewController];
        
        [ctrler.calendarLayoutController refreshSyncID4AllItems];
        
        return;
    }
}

- (void)sdwSyncComplete:(NSNotification *)notification
{
    [self deselect];
    
    TaskManager *tm = [TaskManager getInstance];
    
    int mode = [[notification.userInfo objectForKey:@"SyncMode"] intValue];
    
    //printf("SDW Sync complete - mode: %s\n", (mode == SYNC_AUTO_1WAY?"auto 1 way":"2 way"));
    
    if (mode == SYNC_MANUAL_1WAY_mSD2SD)
    {
        [self resetAllData];
        
        return;
    }
    
    if (mode == SYNC_AUTO_1WAY || mode == SYNC_MANUAL_1WAY_SD2mSD)
    {
        [tm refreshSyncID4AllItems];
        
        CalendarViewController *ctrler = [self getCalendarViewController];
        
        [ctrler.calendarLayoutController refreshSyncID4AllItems];
        
        [self refreshData]; //reload sync IDs in other views such as ADE Pane/Notes/Categories so that delete item will not clean it from DB
    }
    else
    {
        [self resetAllData];
    }
}

#pragma mark Alert Handle

- (void)reloadAlerts:(NSNotification *)notification
{
    NSInteger taskId = [[notification.userInfo objectForKey:@"TaskId"] intValue];
    
    [self reloadAlert4Task:taskId];
}

- (void) reloadAlert4Task:(NSInteger)taskId
{
    TaskManager *tm = [TaskManager getInstance];
    
    [tm reloadAlert4Task:taskId];
    
    PageAbstractViewController *ctrlers[4] = {
        [self getCalendarViewController],
        [self getSmartListViewController],
        [self getNoteViewController],
        [self getCategoryViewController]
    };
    
    for (int i=0; i<4; i++)
    {
        PageAbstractViewController *ctrler = ctrlers[i];
        
        [ctrler reloadAlert4Task:taskId];
    }
    
    FocusView *focusView = [self getFocusView];
    
    if (focusView != nil)
    {
        [focusView reloadAlert4Task:taskId];
    }
}

@end
