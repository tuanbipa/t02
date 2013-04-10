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

#import "CalendarViewController.h"
#import "SmartListViewController.h"
#import "CategoryViewController.h"
#import "NoteViewController.h"
#import "AbstractMonthCalendarView.h"

#import "TaskDetailTableViewController.h"
#import "NoteDetailTableViewController.h"

#import "SmartCalAppDelegate.h"

BOOL _autoPushPending = NO;

@interface AbstractActionViewController ()

@end

@implementation AbstractActionViewController
@synthesize contentView;

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

- (FocusView *) getFocusView
{
    return nil;
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
}

- (void) refreshData
{
    
}

- (void) resetAllData
{
    TaskManager *tm = [TaskManager getInstance];
    ProjectManager *pm = [ProjectManager getInstance];
    DBManager *dbm = [DBManager getInstance];
    
    [pm initProjectList:[dbm getProjects]];
    
    [tm initData];
    
    [self refreshData];
    
    self.task2Link = nil;
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
    
    BOOL calendarTask = [task isTask] && task.original != nil;
    
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
    
    [self deselect];
    
    if (activeView != view)
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

- (void) editItem:(Task *)item inRect:(CGRect)inRect
{
    
}

- (void) editItem:(Task *)item inView:(TaskView *)inView
{
    
}

- (void) editProject:(Project *)project inView:(PlanView *)inView
{
    
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
    
    [[TaskManager getInstance] initCalendarData:date];

    MiniMonthView *mmView = [self getMiniMonth];

    if (mmView != nil)
    {
        [mmView highlight:date];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CalendarDayChangeNotification" object:nil]; //to refresh Calendar layout
}

#pragma mark Task Actions

- (void) changeItem:(Task *)task action:(NSInteger)action
{
    PageAbstractViewController *ctrler = nil;
    
    if (task.listSource == SOURCE_NOTE)
    {
        ctrler = [self getNoteViewController];
    }
    else if (task.listSource == SOURCE_CATEGORY)
    {
        ctrler = [self getCategoryViewController];
    }
    
    if (ctrler != nil)
    {
        [ctrler loadAndShowList];
    }
    
    if ([task isNote])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NoteChangeNotification" object:nil];
    }
}

- (void) deleteRE
{
    TaskManager *tm = [TaskManager getInstance];
    
    //Task *task = [self.activeViewCtrler getSelectedTask];
    Task *task = [self getActiveTask];
    AbstractMonthCalendarView *calView = [self getMonthCalendarView];
    
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
        
        [calView refresh];
        
        if ([task isADE])
        {
            [calView refreshADEView];
            
            CalendarViewController *ctrler = [self getCalendarViewController];
            [ctrler refreshADEPane];//refresh ADE
        }
        
        [self changeItem:task action:TASK_DELETE];
    }
    
    [task release];
}

-(void) deleteRE:(NSInteger)deleteOption
{
    Task *task = [self getActiveTask];
    
    AbstractMonthCalendarView *calView = [self getMonthCalendarView];
    
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
    
    [calView refresh];
    
    CalendarViewController *calCtrler = [self getCalendarViewController];
    
    [calCtrler refreshView];
    
    if ([task isADE])
    {
        [calView refreshADEView];
        
        CalendarViewController *ctrler = [self getCalendarViewController];
        [ctrler refreshADEPane];//refresh ADE
    }
    
    [self changeItem:task action:TASK_DELETE];
    
    [task release];
}

- (void) doDeleteTask
{
    TaskManager *tm = [TaskManager getInstance];
    
    Task *task = [self getActiveTask];
    AbstractMonthCalendarView *calView = [self getMonthCalendarView];
    
    NSInteger pk = task.primaryKey;
    
    if (task.original != nil && ![task isREException])
    {
        pk = task.original.primaryKey;
    }
    
    if (pk == self.task2Link.primaryKey)
    {
        self.task2Link = nil;
    }
    
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
        
        if (type == TYPE_ADE)
        {
            [calView refreshADEView];
        }
        else if (type == TYPE_TASK)
        {
            if (start != nil)
            {
                [calView refreshCellByDate:start];
            }
            
            if (deadline != nil)
            {
                [calView refreshCellByDate:deadline];
            }
        }
        else if (type == TYPE_EVENT)
        {
            [calView refreshCellByDate:start];
        }
        
        CalendarViewController *ctrler = [self getCalendarViewController];
        [ctrler refreshADEPane];//refresh ADE for any link removement
    }
    
    [self changeItem:task action:TASK_DELETE];
    
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

- (void) markDoneTask
{
    Task *task = [self getActiveTask];
    
    AbstractMonthCalendarView *calView = [self getMonthCalendarView];
    
    if (task != nil)
    {
        [task retain];
        
        [self deselect];
        
        TaskManager *tm = [TaskManager getInstance];
        
        NSDate *oldDeadline = [[task.deadline copy] autorelease];
        BOOL isRT = [task isRT];
        
        //[tm markDoneTask:task];
        
        if ([task isDone])
        {
            [tm unDone:task];
        }
        else
        {
            [tm markDoneTask:task];
        }
        
        [calView refreshCellByDate:oldDeadline];
        
        CategoryViewController *ctrler = [self getCategoryViewController];
        
        //remove done task from list
        [ctrler markDoneTask:task];
        
        if (isRT)
        {
            [calView refreshCellByDate:task.deadline];
        }
        
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
    }
}

- (void) markDoneTaskInView:(TaskView *)view
{
    Task *task = view.task;
    
    AbstractMonthCalendarView *calView = [self getMonthCalendarView];
    
    [task retain];
    
    [self deselect];
    
    NSDate *oldDue = [[task.deadline copy] autorelease];
    BOOL isRT = [task isRT]; //note: task original could be removed from task list so need to store this information instead of directly call the method after done
    
    TaskManager *tm = [TaskManager getInstance];
    
    if ([task isDone])
    {
        [tm unDone:task];
    }
    else
    {
        [tm markDoneTask:task];
    }
    
    [calView refreshCellByDate:oldDue];
    
    CategoryViewController *ctrler = [self getCategoryViewController];
    
    //remove done task from list
    [ctrler markDoneTask:task];
    
    if (isRT)
    {
        [calView refreshCellByDate:task.deadline];
        
        [view setNeedsDisplay];
    }
    
    [task release];
}

- (void) starTaskInView:(TaskView *)taskView
{
	TaskManager *tm = [TaskManager getInstance];
	
	Task *task = taskView.task;
    
    [tm starTask:task];
    
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
        
        CategoryViewController *ctrler = [self getCategoryViewController];
        [ctrler loadAndShowList];
		
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
        
        planCopy.name = [NSString stringWithFormat:@"%@ (copy)", plan.name];
        planCopy.primaryKey = -1;
        planCopy.ekId = @"";
        planCopy.tdId = @"";
        
        [self editProject:planCopy inView:activeView];
	}
    
    [self deselect];
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
    
    TaskManager *tm = [TaskManager getInstance];
    
    int mode = [[notification.userInfo objectForKey:@"SyncMode"] intValue];
    
    if (mode != SYNC_AUTO_1WAY)
    {
        [self resetAllData];
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
    
    TaskManager *tm = [TaskManager getInstance];
    
    int mode = [[notification.userInfo objectForKey:@"SyncMode"] intValue];
    
    if (mode != SYNC_AUTO_1WAY)
    {
        [self resetAllData];
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
