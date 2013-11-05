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
#import "AlertData.h"

#import "SDWSync.h"
#import "TDSync.h"
#import "EKSync.h"
#import "EKReminderSync.h"

#import "TaskManager.h"
#import "TaskLinkManager.h"
#import "ProjectManager.h"
#import "DBManager.h"
#import "BusyController.h"
#import "TimerManager.h"
#import "TagDictionary.h"

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

//#import "TaskDetailTableViewController.h"
//#import "NoteDetailTableViewController.h"

#import "TaskReadonlyDetailViewController.h"
#import "NoteDetailViewController.h"
#import "ProjectEditViewController.h"
#import "DetailViewController.h"
#import "iPadTagListViewController.h"
#import "CalendarSelectionTableViewController.h"
#import "TimerViewController.h"
#import "MenuTableViewController.h"
#import "SeekOrCreateViewController.h"
#import "UnreadCommentViewController.h"

#import "SDNavigationController.h"

#import "SmartCalAppDelegate.h"
#import "PlannerViewController.h"
#import "PlannerMonthView.h"
#import "iPadViewController.h"
#import "SmartDayViewController.h"
#import "PlannerView.h"

#import "TaskLocationListViewController.h"

//extern BOOL _isiPad;

BOOL _autoPushPending = NO;

extern iPadViewController *_iPadViewCtrler;
extern SmartDayViewController *_sdViewCtrler;

extern DetailViewController *_detailViewCtrler;

@interface AbstractActionViewController ()

@end

@implementation AbstractActionViewController
@synthesize contentView;
@synthesize activeView;

@synthesize popoverCtrler;

@synthesize actionTask;
@synthesize actionTaskCopy;
@synthesize actionProject;

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
        self.activeView = nil;
        
        self.task2Link = nil;
        self.actionTask = nil;
        self.actionTaskCopy = nil;
        self.actionProject = nil;
        
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
    self.actionTask = nil;
    self.actionTaskCopy = nil;
    self.actionProject = nil;
    
    self.popoverCtrler = nil;
    
    self.activeView = nil;
    
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
    if (self.activeView != nil)
    {
        [CATransaction begin];
        [self.activeView doSelect:NO];
        [CATransaction commit];
    }

    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
    
    [self hidePopover];
    
    self.activeView = nil;
    
    [[self getCalendarViewController] deselect]; //remove outline if event is resized
}

- (void) clearActiveItems
{
    self.actionTask = nil;
    self.actionTaskCopy = nil;
    self.actionProject = nil;
}

- (Task *) getActiveTask
{
    /*
    if (self.activeView != nil && [self.activeView isKindOfClass:[TaskView class]])
    {
        return ((TaskView *) self.activeView).task;
    }
    
    return nil;
    */
    
    return self.actionTask;
}

- (Project *) getActiveProject
{
    /*if (self.activeView != nil && [self.activeView isKindOfClass:[PlanView class]])
    {
        return ((PlanView *) self.activeView).project;
    }
    
    return nil;*/
    
    return self.actionProject;
}

- (MovableView *) getActiveView4Item:(NSObject *)item
{
    PageAbstractViewController *ctrler = [self getActiveModule];
    
    if (ctrler != nil)
    {
        return [ctrler getMovableView4Item:item];
    }
    
    return nil;
}

- (PageAbstractViewController *)getActiveModule
{
    PageAbstractViewController *ctrlers[4] = {
        [self getCalendarViewController],
        [self getSmartListViewController],
        [self getNoteViewController],
        [self getCategoryViewController]
    };
    
    for (int i=1; i<4; i++)
    {
        if ([self checkControllerActive:i])
        {
            return ctrlers[i];
        }
    }
    
    return nil;    
}

- (PageAbstractViewController *)getModuleAtIndex:(NSInteger)index
{
    PageAbstractViewController *ctrlers[4] = {
        [self getCalendarViewController],
        [self getSmartListViewController],
        [self getNoteViewController],
        [self getCategoryViewController]
    };

    return ctrlers[index];
}

- (BOOL) checkControllerActive:(NSInteger)index
{
    //0:Calendar, 1:Tasks, 2:Notes, 3:Projects
    return NO;
}

- (void) resetMovableContentView
{
    PageAbstractViewController *ctrlers[4] = {
        [self getCalendarViewController],
        [self getSmartListViewController],
        [self getNoteViewController],
        [self getCategoryViewController]
    };
    
    for (int i=0; i<4; i++)
    {
        [ctrlers[i] setMovableContentView:self.contentView];
    }
}

-(void)shrinkEnd
{
    if (optionView != nil && [optionView superview])
    {
        optionView.hidden = YES;
    }
}

- (void) hideDropDownMenu
{
	if (!optionView.hidden)
	{
        CGPoint p = optionView.frame.origin;
        p.x += optionView.frame.size.width/2;
        
		[Common animateShrinkView:optionView toPosition:p target:self shrinkEnd:@selector(shrinkEnd)];
	}
}

- (void) showOptionMenu
{
    BOOL menuVisible = !optionView.hidden;
    
    if (!menuVisible)
	{
		optionView.hidden = NO;
		[contentView  bringSubviewToFront:optionView];
		
        [Common animateGrowViewFromPoint:optionView.frame.origin toPoint:CGPointMake(optionView.frame.origin.x, optionView.frame.origin.y + optionView.bounds.size.height/2) forView:optionView];
	}
}

- (void) showModuleByIndex:(NSInteger)index
{
    
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
    
    MiniMonthView *mmView = [self getMiniMonth];
    
    [mmView.calView refreshADEView];
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
    
    PlannerMonthView *plannerCalView = (PlannerMonthView *)[self getPlannerMonthCalendarView];
    
    [plannerCalView refresh];
    [plannerCalView refreshOpeningWeek:nil];
    
    [_iPadViewCtrler refreshFilterStatus];
    
    //PlannerBottomDayCal *planerDayCal = [self getPlannerDayCalendarView];
    //[planerDayCal refreshLayout];
}

- (void) resetAllData
{
    TaskManager *tm = [TaskManager getInstance];
    ProjectManager *pm = [ProjectManager getInstance];
    DBManager *dbm = [DBManager getInstance];
    Settings *settings = [Settings getInstance];
    
    [self deselect];
    
    [settings refreshTimeZone];
    
    [pm initProjectList:[dbm getProjects]];
    
    [tm initData];
    
    [[self getMiniMonth] initCalendar:[NSDate date]];
    
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

- (void) applyFilter
{
    [self hidePopover];
    
    TaskManager *tm = [TaskManager getInstance];
    
    NSDate *dt = [tm.today copy];
    
    [tm initCalendarData:dt];
    [tm initSmartListData];
    
    [dt release];
    
    [self refreshData];
}

#pragma mark Top Toolbar Actions

- (void) showCategory
{
    [self hidePopover];
    
    CalendarSelectionTableViewController *ctrler = [[CalendarSelectionTableViewController alloc] init];
    
    self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:ctrler] autorelease];
    
    [ctrler release];
    
    
    CGRect frm = CGRectMake(100-contentView.frame.origin.x, 0, 20, 10);
    
    [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void) showUnreadComments
{
    [self hidePopover];
    
    UnreadCommentViewController *ctrler = [[UnreadCommentViewController alloc] init];
 
    if (_isiPad)
    {
        self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:ctrler] autorelease];
        
        CGRect frm = CGRectMake(260-contentView.frame.origin.x, 0, 20, 10);
        
        [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    else
    {
        [self.navigationController pushViewController:ctrler animated:YES];
    }
    
    [ctrler release];
}

- (void)showGeoTaskLocation: (CGRect)rect
{
    [self hidePopover];
    
    TaskLocationListViewController *ctrler = [[TaskLocationListViewController alloc] init];
    
    if (_isiPad)
    {
        self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:ctrler] autorelease];
        
        //CGRect frm = CGRectMake(260-contentView.frame.origin.x, 0, 20, 10);
        rect.origin.y = 0;
        
        [self.popoverCtrler presentPopoverFromRect:rect inView:contentView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    else
    {
        [self.navigationController pushViewController:ctrler animated:YES];
    }
    
    [ctrler release];
}

- (void) showTag
{
    [self hidePopover];
    
    iPadTagListViewController *ctrler = [[iPadTagListViewController alloc] init];
    
    self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:ctrler] autorelease];
    
    [ctrler release];
    
    CGRect frm = CGRectMake(180-contentView.frame.origin.x, 0, 20, 10);
    
    [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
}

- (void) showTimer
{
    TimerManager *timer = [TimerManager getInstance];
    
    Task *task = [self getActiveTask];
    
    if (task.original != nil && ![task isREException])
    {
        task = task.original;
    }
    
    [[task retain] autorelease];
    
    [self deselect];
    
    if (task != nil && [task isTask])
    {
        if (![timer checkActivated:task])
        {
            timer.taskToActivate = task;
        }
    }
    else
    {
        Settings *settings = [Settings getInstance];
        
        Task *todo = [[[Task alloc] init] autorelease];
        
        todo.project = settings.taskDefaultProject;
        todo.name = _newItemText;
        todo.listSource = SOURCE_TIMER;
        
        timer.taskToActivate = todo;
    }
    
    TimerViewController *ctrler = [[TimerViewController alloc] init];
    
    if (_isiPad)
    {
        [_iPadViewCtrler closeDetail];
        
        self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:ctrler] autorelease];
        
        //[ctrler release];
        
        CGSize sz = [[UIScreen mainScreen] bounds].size;
        
        CGFloat x = UIInterfaceOrientationIsLandscape(_iPadViewCtrler.interfaceOrientation)?sz.height/2:sz.width/2;
        
        CGRect frm = CGRectMake(x-10-contentView.frame.origin.x, 0, 20, 10);
        
        [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    else
    {
        [_sdViewCtrler.navigationController pushViewController:ctrler animated:YES];
    }
    
    [self clearActiveItems];
    
    [ctrler release];
}

- (void) showSettingMenu
{
    //MenuTableViewController *ctrler = [[MenuTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    MenuTableViewController *ctrler = [[MenuTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:ctrler] autorelease];
	[self.popoverCtrler setPopoverContentSize:CGSizeMake(250, 210)];
    
    [ctrler release];
    
    CGRect frm = CGRectMake(40-contentView.frame.origin.x, 0, 20, 10);
    
    [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
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
    
    BOOL calendarTask = ([task isTask] && task.original != nil);
    
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
    
    BOOL showAction = self.activeView != view;
    
    [self deselect];
    
    if (showAction)
    {
        self.activeView = enable?view:nil;
        
        if (self.activeView != nil)
        {
            [self.activeView doSelect:YES];
        }
    }
    else
    {
        self.activeView = nil;
    }
    
    if (self.activeView != nil && [self.activeView isKindOfClass:[TaskView class]])
    {
        self.actionTask = ((TaskView *)self.activeView).task;
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
    
    BOOL showAction = self.activeView != view;
    
    [self deselect];
    
    if (showAction)
    {
        self.activeView = enable?view:nil;
        
        if (self.activeView != nil)
        {
            [self.activeView doSelect:YES];
        }
    }
    else
    {
        self.activeView = nil;
    }
    
    if (self.activeView != nil && [self.activeView isKindOfClass:[PlanView class]])
    {
        self.actionProject = ((PlanView *)self.activeView).project;
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

#pragma mark Seek&Create
- (void) showSeekOrCreate:(NSString *)text
{
    if (self.popoverCtrler != nil && ![self.popoverCtrler isPopoverVisible])
    {
        [self.popoverCtrler dismissPopoverAnimated:YES];
        
        self.popoverCtrler = nil;
    }
    
    if (self.popoverCtrler != nil && [self.popoverCtrler.contentViewController isKindOfClass:[SeekOrCreateViewController class]])
    {
        if ([text isEqualToString:@""])
        {
            [self.popoverCtrler dismissPopoverAnimated:YES];
        }
        else
        {
            SeekOrCreateViewController *ctrler = (SeekOrCreateViewController *) self.popoverCtrler.contentViewController;
            
            [ctrler search:text];
        }
    }
    else if (![text isEqualToString:@""])
    {
        [self.popoverCtrler dismissPopoverAnimated:NO];
        
        SeekOrCreateViewController *ctrler = [[SeekOrCreateViewController alloc] init];
        
        [ctrler search:text];
        
        self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:ctrler] autorelease];
        [self.popoverCtrler setPopoverContentSize:CGSizeMake(320, 440)];
        
        [ctrler release];
        
        //CGRect frm = CGRectMake(600-contentView.frame.origin.x, 0, 20, 10);
        CGRect frm = CGRectMake(contentView.bounds.size.width - 140, 0, 20, 10);
        
        [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

- (void) createItem:(NSInteger)index title:(NSString *)title
{
    TaskManager *tm = [TaskManager getInstance];
    Settings *settings = [Settings getInstance];
    
    Task *task = [[[Task alloc] init] autorelease];
    task.name = title;
    task.listSource = SOURCE_NONE;
    
    switch (index)
    {
        case 0:
        {
            task.type = TYPE_TASK;
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
            
        }
            break;
        case 1:
        {
            task.type = TYPE_EVENT;
            
            task.timeZoneId = [Settings findTimeZoneID:[NSTimeZone defaultTimeZone]];
            
            task.startTime = [Common dateByRoundMinute:15 toDate:tm.today];
            task.endTime = [Common dateByAddNumSecond:3600 toDate:task.startTime];
            
        }
            break;
        case 2:
        {
            task.type = TYPE_NOTE;
            task.note = title;
            
            task.startTime = [Common dateByRoundMinute:15 toDate:tm.today];
            
        }
            break;
    }
	
    if (_isiPad)
    {
        [_iPadViewCtrler editItemDetail:task];
    }
    else
    {
        [_sdViewCtrler editItemDetail:task];
    }
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
    UINavigationController *navCtrler = self.navigationController;
    
    if (_isiPad && _iPadViewCtrler.detailNavCtrler != nil)
    {
        navCtrler = _iPadViewCtrler.detailNavCtrler;
    }
    
    if ([item isNote])
    {
        NoteDetailViewController *ctrler = [[NoteDetailViewController alloc] init];
        ctrler.note = item;
        
        [navCtrler pushViewController:ctrler animated:YES];
        [ctrler release];
    }
    else if ([item isShared])
    {
        TaskReadonlyDetailViewController *ctrler = [[TaskReadonlyDetailViewController alloc] init];
        
        ctrler.task = item;
        
        [navCtrler pushViewController:ctrler animated:YES];
        [ctrler release];
    }
    else
    {
        DetailViewController *ctrler = [[DetailViewController alloc] init];
        
        ctrler.task = item;
        
        [navCtrler pushViewController:ctrler animated:YES];
        [ctrler release];
        
    }
}

/*
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
    else if ([task isShared])
    {
        TaskReadonlyDetailViewController *taskCtrler = [[TaskReadonlyDetailViewController alloc] init];
        
        taskCtrler.task = task;
        
        ctrler = taskCtrler;
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
    
    //[self.popoverCtrler presentPopoverFromRect:inRect inView:contentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    if (task.listSource == SOURCE_PLANNER_CALENDAR) {
        if (inRect.origin.x <= ctrler.view.frame.size.width) {
            [self.popoverCtrler presentPopoverFromRect:inRect inView:contentView permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
        } else {
            [self.popoverCtrler presentPopoverFromRect:inRect inView:contentView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
        }
    } else {
        [self.popoverCtrler presentPopoverFromRect:inRect inView:contentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void) editItem:(Task *)item inView:(TaskView *)inView
{
    [self editItem:item];
}
*/

- (void) editItem:(Task *)item inView:(TaskView *)inView
{
    if (inView != nil)
    {
        [self enableActions:YES onView:inView]; //to make activeView not nil to do actions
    }

    if (!_isiPad)
    {
        [_sdViewCtrler editItemDetail:item];
    }
    else
    {
        [_iPadViewCtrler editItemDetail:item];
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
        [self enableCategoryActions:YES onView:inView];
        [self editCategory:project];
        
        return;
    }
    
    /*
    ProjectEditViewController *editCtrler = [[ProjectEditViewController alloc] init];
    editCtrler.project = project;
    
    SDNavigationController *navController = [[SDNavigationController alloc] initWithRootViewController:editCtrler];
    [editCtrler release];
    
    self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
    
    [navController release];
    
    CGRect frm = [inView.superview convertRect:inView.frame toView:contentView];
    
    [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    */
    
    [self enableCategoryActions:YES onView:inView]; //to make activeView not nil to do actions
    
    [_iPadViewCtrler editProjectDetail:project];
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
    
    AbstractMonthCalendarView *calView = [self getMonthCalendarView];
    AbstractMonthCalendarView *plannerCalView = [self getPlannerMonthCalendarView];

    [calView refresh];
    [plannerCalView refresh];
    [calCtrler refreshADEPane];
}

- (void) updateTask:(Task *)task withTask:(Task *)taskCopy
{
    TaskManager *tm = [TaskManager getInstance];
    
    BOOL reSchedule = NO;
    
    if (taskCopy.primaryKey == -1)
    {
        [task updateByTask:taskCopy];
        
        [tm addTask:task];
        
        reSchedule = YES;
        
        //[self clearActiveItems];
    }
    else
    {
        BOOL reEdit = [task isREInstance];
        
        BOOL convertRE2Task = reEdit && [taskCopy isTask];
        
        if (convertRE2Task)
        {
            self.actionTask = task;
            self.actionTaskCopy = taskCopy;
            
            NSString *mss = [task isManual] ? _convertATaskIntoTaskConfirmation : _convertREIntoTaskConfirmation;
            NSString *headMss = [task isManual] ? _convertATaskIntoTaskHeader : _warningText;
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:headMss  message:mss delegate:self cancelButtonTitle:_cancelText otherButtonTitles:_onlyInstanceText, _allFollowingText, nil];
            
            alertView.tag = -13001;
            
            [alertView show];
            [alertView release];
            
            return;
        }
        else if (reEdit) //change RE
        {
            self.actionTask = task;
            self.actionTaskCopy = taskCopy;
            
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
            
            //[self clearActiveItems];
        }
    }
    
    [self deselect];
    
    [self reconcileItem:task reSchedule:reSchedule];
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
    Task *rootRE = [tm findREByKey:task.primaryKey];
        
    [task retain];
    [rootRE retain];
    
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
    
    if (rootRE != nil)
    {
        Task *instance = [[rootRE copy] autorelease];
        instance.original = rootRE;
        
        [tm deleteREInstance:instance deleteOption:2];

        [self reconcileItem:task reSchedule:YES];
    }
    
    [task release];
    [rootRE release];
    
    [self clearActiveItems];
}

-(void) deleteRE:(NSInteger)deleteOption
{
    Task *task = [self getActiveTask];

    [task retain];
        
    NSInteger pk = task.primaryKey;
    
    if (task.original != nil && ![task isREException])
    {
        pk = task.original.primaryKey;
    }
    
    if (pk == self.task2Link.primaryKey)
    {
        self.task2Link = nil;
    }
    
    [self deselect];
	
	[[TaskManager getInstance] deleteREInstance:task deleteOption:deleteOption];
    
    [self reconcileItem:task reSchedule:YES];
    
    [task release];
    
    [self clearActiveItems];
}

-(void) updateRE:(NSInteger)option
{
    BOOL isADE = ([self.actionTask isADE] || [self.actionTaskCopy isADE]);
    
    if (option == 2) //all series
    {
        if ([Common daysBetween:actionTask.startTime sinceDate:actionTaskCopy.startTime] == 0 && [Common daysBetween:actionTask.endTime sinceDate:actionTaskCopy.endTime] == 0 && actionTask.timeZoneId == actionTaskCopy.timeZoneId) //user does not change date -> keep root date
        {
            actionTaskCopy.startTime = [Common copyTimeFromDate:actionTaskCopy.startTime toDate:actionTask.original.startTime];
            actionTaskCopy.endTime = [Common copyTimeFromDate:actionTaskCopy.endTime toDate:actionTask.original.endTime];
        }
    }
    
    [[TaskManager getInstance] updateREInstance:actionTask withRE:actionTaskCopy updateOption:option];
    
    [self reconcileItem:actionTask reSchedule:YES];
    
    if ([self isKindOfClass:[PlannerViewController class]]) {
        if (isADE) {
            PlannerMonthView *plannerMonthView = (PlannerMonthView*)[self getPlannerMonthCalendarView];
            // reload openning week
            [plannerMonthView refreshOpeningWeek:nil];
        } else {
            PlannerBottomDayCal *plannerDayCal = [self getPlannerDayCalendarView];
            [plannerDayCal refreshLayout];
        }
    }
    
    [self clearActiveItems];
}

- (void) doDeleteTask
{
    TaskManager *tm = [TaskManager getInstance];
    
    Task *task = [self getActiveTask];

    [task retain];
    
    NSInteger pk = task.primaryKey;
    
    if (task.original != nil && ![task isREException])
    {
        pk = task.original.primaryKey;
    }
    
    if (pk == self.task2Link.primaryKey)
    {
        self.task2Link = nil;
    }

    [tm deleteTask:task];
    
    [self reconcileItem:task reSchedule:([task isNote]?NO:YES)];
    
    [self deselect];
    
    [task release];
    
    [self clearActiveItems];
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

- (Task *) copyTask:(Task *)task
{
    Task *ret = nil;
    
    //Task *task = [self getActiveTask];
    
    if (task == nil)
    {
        task = [self getActiveTask];
    }
    
    if (task != nil)
    {
        [task retain];
        
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
        
        [task release];
        
        ret = taskCopy;
    }
    
    return ret;
}

- (void) markDoneTask:(Task *)task
{
    TaskManager *tm = [TaskManager getInstance];
    
    if ([task isDone])
    {
        [tm unDone:task];
    }
    else
    {
        [tm markDoneTask:task];
    }
    
    [self reconcileItem:task reSchedule:YES];
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
        
        [self clearActiveItems];
    }
}

- (void) starTask
{
    Task *task = [self getActiveTask];
    
    if (task != nil)
    {
        [task retain];
        
        [self deselect];
        
        [[TaskManager getInstance] starTask:task];
        
        SmartListViewController *slViewCtrler = [self getSmartListViewController];
        
        [slViewCtrler setNeedsDisplay];
        
        CategoryViewController *ctrler = [self getCategoryViewController];
        
        if (task.listSource == SOURCE_CATEGORY)
        {
            [ctrler setNeedsDisplay];
        }
        else if ([self checkControllerActive:3])
        {
            if (ctrler.filterType == TYPE_TASK)
            {
                [ctrler loadAndShowList];
            }
        }
        
        [task release];
        
        [self clearActiveItems];
    }
}

- (void) share2AirDrop
{
    ProjectManager *pm = [ProjectManager getInstance];
    
    Project *prj = [self getActiveProject];
    
    NSMutableArray *tasks = nil;
    
    if (prj != nil)
    {
        DBManager *dbm = [DBManager getInstance];
        
        NSArray *prjTasks = [dbm getTasksForProject:prj.primaryKey isInitial:NO groupExcluded:YES];
        
        tasks = [NSMutableArray arrayWithCapacity:tasks.count];
        
        for (Task *task in prjTasks)
        {
            NSDictionary *taskDict = [task tojson];
            
            [tasks addObject:taskDict];
        }
    }
    else
    {
        Task *task = [self getActiveTask];
        
        if (task.original != nil && ![task isREException])
        {
            task = task.original;
        }
        
        prj = [pm getProjectByKey:task.project];
        
        if (task != nil)
        {
            NSDictionary *taskDict = [task tojson];
            
            tasks = [NSMutableArray arrayWithObject:taskDict];
        }
    }
    
    if (tasks != nil && prj != nil)
    {
        NSMutableDictionary *prjDict = [NSMutableDictionary dictionaryWithDictionary:[prj tojson]];
    
        [prjDict setObject:tasks forKey:@"tasks"];
        
        NSError *error = nil;
        
        NSData *jsonBody = [NSJSONSerialization dataWithJSONObject:prjDict options:0 error:&error];
        
        NSString *dataStr = [[[NSString alloc] initWithData:jsonBody encoding:NSUTF8StringEncoding] autorelease];
        
        NSString *urlString = [NSString stringWithFormat:@"SmartDay://localhost/shareData?data=%@", [dataStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSArray *activityItems = @[url];
        UIActivityViewController *activityController =
        [[UIActivityViewController alloc]
         initWithActivityItems:activityItems applicationActivities:nil];
        activityController.excludedActivityTypes = @[UIActivityTypePostToFacebook,UIActivityTypePostToTwitter,UIActivityTypePostToWeibo,UIActivityTypeMessage,UIActivityTypeMail,UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll,UIActivityTypeAddToReadingList];
        
        UIViewController *ctrler = (_isiPad?_iPadViewCtrler:_sdViewCtrler);
        
        [ctrler presentViewController:activityController
                           animated:YES completion:^{
                               /*if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
                                   
                                   // show cancel button in landscape
                                   CGRect frm = activityController.view.frame;
                                   frm.size = CGSizeMake(frm.size.width, 700);
                                   activityController.view.frame = frm;
                               }*/
                           }];
        [self deselect];
    }
    
    [self clearActiveItems];
    
}

-(void) createTaskFromNote:(Task *)fromNote
{
    TaskManager *tm = [TaskManager getInstance];
    Settings *settings = [Settings getInstance];
    TaskLinkManager *tlm = [TaskLinkManager getInstance];
    
    Task *note = fromNote != nil?fromNote:[self getActiveTask];
    
    if (note != nil)
    {
        [note retain];
        
        [self deselect];
        
        Task *task = [[Task alloc] init];
        
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
        
        task.project = note.project;
        task.name = note.name;
        
        [tm addTask:task];
        
        NSInteger linkId = [tlm createLink:task.primaryKey destId:note.primaryKey destType:ASSET_ITEM];
        
        if (linkId != -1)
        {
            //edit in Category view
            task.links = [tlm getLinkIds4Task:task.primaryKey];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil]; //trigger sync for Link
        }
        
        [note release];
        
        [self reconcileItem:task reSchedule:YES];
        
        [self clearActiveItems];
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
    
    //BOOL isManual = [task isManual]; // for refesh minimonth
    
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
    
    /*if (isManual) {
        [calView refresh];
    }*/
    
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
    
    if (_iPadViewCtrler.inSlidingMode && _detailViewCtrler != nil && _detailViewCtrler.task.primaryKey == task.primaryKey)
    {
        _detailViewCtrler.taskCopy.status = task.status;
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
    Task *taskCopy = [[task copy] autorelease];
    
    taskCopy.type = TYPE_TASK;
    
    if (task.original != nil && ![task isREException])
    {
        task = task.original;
    }
    
    // check if this is STask
    if ([taskCopy isManual]) {
        [taskCopy setManual:NO];
    }
    
    TaskManager *tm = [TaskManager getInstance];
    
    [tm updateTask:task withTask:taskCopy];
        
    PlannerBottomDayCal *plannerDayCal = [self getPlannerDayCalendarView];
    [plannerDayCal refreshLayout];
    
    [self reconcileItem:task reSchedule:YES];
}

- (void) changeTime:(Task *)task time:(NSDate *)time
{
    TaskManager *tm = [TaskManager getInstance];
    
    [tm moveTime:[Common copyTimeFromDate:time toDate:tm.today] forEvent:task];
    
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
        
        NSMutableArray *list = [tm findScheduledTasks:slTask];
        
        for (Task *tmp in list)
        {
            tmp.project = prjKey;
        }
        
        [tm refreshTopTasks];
        [self setNeedsDisplay];
       
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

- (void) quickAddProject:(NSString *)name
{
    ProjectManager *pm = [ProjectManager getInstance];
    
    Project *project = [[Project alloc] init];
    project.name = name;
    project.type = TYPE_PLAN;
    
    [pm addProject:project];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EventChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];
    
    CategoryViewController *ctrler = [self getCategoryViewController];
    
    [ctrler loadAndShowList];
    
    [project release];
}

- (void) quickAddItem:(NSString *)name type:(NSInteger)type defer:(NSInteger)defer
{
	TaskManager *tm = [TaskManager getInstance];
    Settings *settings = [Settings getInstance];

    Task *task = [[Task alloc] init];
    task.type = type;
    task.name = name;
    //task.duration = tm.lastTaskDuration;
    task.duration = settings.taskDuration;
    task.project = tm.lastTaskProjectKey;
    
    task.startTime = type==TYPE_TASK? [settings getWorkingStartTimeForDate:tm.today]:[Common dateByRoundMinute:15 toDate:tm.today];
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
            task.deadline = [settings getWorkingEndTimeForDate:tm.today];
        }
            break;
    }
    
    NSInteger taskPlacement = settings.newTaskPlacement;
    
    if ([task isTask])
    {
        switch (defer)
        {
            case DO_TODAY:
            {
                task.deadline = [settings getWorkingEndTimeForDate:[NSDate date]];
                AlertData *alertDat = [[AlertData alloc] init];
                
                alertDat.beforeDuration = -15*60;
                alertDat.absoluteTime = nil;
                
                [task.alerts addObject:alertDat];
                
                [alertDat release];
                
                settings.newTaskPlacement = 0; //move Task to top
            }
                break;
            case DO_NEXT_WEEK:
            {
                /*
                NSDate *dt = [Common getEndWeekDate:[NSDate date] withWeeks:1 mondayAsWeekStart:(settings.weekStart == 1)];
                
                task.deadline = [Common copyTimeFromDate:[settings getWorkingEndTimeForDate:dt] toDate:dt];
                
                dt = [Common getFirstWeekDate:dt mondayAsWeekStart:(settings.weekStart == 1)];
                
                task.startTime = [Common copyTimeFromDate:[settings getWorkingStartTimeForDate:dt] toDate:dt];
                */
                
                NSDate *dt = [Common dateByAddNumDay:7 toDate:[Common dateByWeekday:2]];
                
                task.startTime = [Common copyTimeFromDate:[settings getWorkingStartTimeForDate:dt] toDate:dt];
                
                dt = [Common dateByAddNumDay:4 toDate:dt];
                
                task.deadline = [Common copyTimeFromDate:[settings getWorkingEndTimeForDate:dt] toDate:dt];
                
            }
                break;
            case DO_NEXT_MONTH:
            {
                NSDate *dt = [Common getEndMonthDate:[NSDate date] withMonths:2];
                
                task.deadline = [Common copyTimeFromDate:[settings getWorkingEndTimeForDate:dt] toDate:dt];
                
                dt = [Common getFirstMonthDate:dt];
                
                task.startTime = [Common copyTimeFromDate:[settings getWorkingStartTimeForDate:dt] toDate:dt];
            }
                break;
            case DO_ANYTIME:
            {
                task.startTime = [settings getWorkingStartTimeForDate:[NSDate date]];
                //task.deadline = nil;
            }
                break;
        }
    }
    
    [tm addTask:task];
    
    if (defer == DO_TODAY)
    {
        settings.newTaskPlacement = taskPlacement;
    }
    
    [self reconcileItem:task reSchedule:(type != TYPE_NOTE)];
    
    [task release];
}

- (void) moveTask2Top
{
    Task *task = [self getActiveTask];
    
    if (task != nil)
    {
        [task retain];
        
        [self deselect];
        
        [[TaskManager getInstance] moveTask2Top:task];
        
        if ([self checkControllerActive:3])
        {
            CategoryViewController *ctrler = [self getCategoryViewController];
            
            if (ctrler.filterType == TYPE_TASK)
            {
                [ctrler loadAndShowList];
            }
        }
        
        [task release];
        
        [self clearActiveItems];
    }
}

- (void) defer:(NSInteger)option
{
    Task *task = [self getActiveTask];
    
    if (task != nil)
    {
        [task retain];
        
        [self deselect];
        
        [[TaskManager getInstance] defer:task deferOption:option];
        
        [self reconcileItem:task reSchedule:YES];
        
        [task release];
        
        [self clearActiveItems];
    }
}

/*
- (void) deleteNote:(Task *)note
{
    DBManager *dbm = [DBManager getInstance];
    
    [note deleteFromDatabase:[dbm getDatabase]];
    
    [self reconcileItem:note reSchedule:NO];
}
*/
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
    
    [self clearActiveItems];
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
            
            //[deleteActionSheet showInView:contentView];
            [deleteActionSheet showInView:_isiPad?contentView:_sdViewCtrler.navigationController.topViewController.view];
            
            [deleteActionSheet release];
		}
    }
}

- (Project *) copyCategory
{
    Task *ret = nil;
    
    Project *plan = [self getActiveProject];
    
	if (plan != nil)
	{
        Project *planCopy = [[plan copy] autorelease];
        
        //CGRect frm = [activeView.superview convertRect:activeView.frame toView:contentView];
        
        [self deselect];
        
        planCopy.name = [NSString stringWithFormat:@"%@ (copy)", plan.name];
        planCopy.primaryKey = -1;
        planCopy.ekId = @"";
        planCopy.tdId = @"";
        
        ret = planCopy;
        
        //[self editProject:planCopy inRect:frm];
	}
    
    return ret;
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
    
    [self deselect];
}

- (void) pasteLink
{
    Task *task = [self getActiveTask];
    
    task = (task.original != nil && ![task isREException])?task.original:task;
    
    [task retain];
    
    [self deselect];
    
    TaskLinkManager *tlm = [TaskLinkManager getInstance];
    
    int linkId = [tlm createLink:task.primaryKey destId:self.task2Link.primaryKey destType:ASSET_ITEM];
    
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
    
    // refresh link planner month view
    PlannerMonthView *plannerMonthView = (PlannerMonthView *)[self getPlannerMonthCalendarView];
    if (plannerMonthView != nil) {
        [plannerMonthView reconcileLinks:notification.userInfo];
    }
    
    FocusView *focusView = [self getFocusView];
    
    if (focusView != nil)
    {
        [focusView reconcileLinks:notification.userInfo];
        
        [focusView setNeedsDisplay];
    }
}

#pragma mark Settings Actions
- (void) changeSettings:(Settings *)settingCopy syncAccountChange:(NSInteger) syncAccountChange
{
    //syncAccountChange value: -1 - no change, 0:sdw account change, 1: td account change
	TaskManager *tm = [TaskManager getInstance];
    DBManager *dbm = [DBManager getInstance];
    ProjectManager *pm = [ProjectManager getInstance];
	
	Settings *settings = [Settings getInstance];
    
    BOOL hideFutureTaskChange = settings.hideFutureTasks != settingCopy.hideFutureTasks;
	
    BOOL workTimeChange = [settings checkWorkingTimeChange:settingCopy];
    
	BOOL reSchedule = (settings.eventCombination != settingCopy.eventCombination || settings.minimumSplitSize != settingCopy.minimumSplitSize || workTimeChange);
	
	BOOL changeSkin = (settings.skinStyle != settingCopy.skinStyle);
	
	BOOL weekStartChange = (settings.weekStart != settingCopy.weekStart);
	
	BOOL tabBarChanged = (settings.tabBarAutoHide != settingCopy.tabBarAutoHide);
    
    BOOL autoSyncChange = settings.autoSyncEnabled != settings.autoSyncEnabled;
    
    BOOL taskSyncChange = settings.tdSyncEnabled != settingCopy.tdSyncEnabled || settings.rmdSyncEnabled != settingCopy.rmdSyncEnabled || settings.sdwSyncEnabled != settingCopy.sdwSyncEnabled;
    
    BOOL ekSyncChange = settings.ekSyncEnabled != settings.ekSyncEnabled;
    
    BOOL mustDoDaysChange = (settings.mustDoDays != settingCopy.mustDoDays);
    
    BOOL defaultCatChange = (settings.taskDefaultProject != settingCopy.taskDefaultProject);
    
    BOOL ekSyncWindowChange = (settings.syncWindowStart != settingCopy.syncWindowStart) || (settings.syncWindowEnd != settingCopy.syncWindowEnd);
    
    BOOL timeZoneSupportChange = settings.timeZoneSupport != settingCopy.timeZoneSupport;
    
    BOOL timeZoneChange = settings.timeZoneID != settingCopy.timeZoneID;
    
	if (settings.taskDuration != settingCopy.taskDuration)
	{
		tm.lastTaskDuration = settingCopy.taskDuration;
	}
	
	if (settings.taskDefaultProject != settingCopy.taskDefaultProject)
	{
		tm.lastTaskProjectKey = settingCopy.taskDefaultProject;
	}
	
    if (syncAccountChange == 1 || taskSyncChange)
	{
        [dbm resetProjectSyncIds];
		[dbm resetTaskSyncIds];
        [pm resetSyncIds];
        [settings resetToodledoSync];
        [settings resetReminderSync];
        
        if (syncAccountChange == 1)
        {
            [[TDSync getInstance] resetSyncSection];
        }
	}
    
    if (syncAccountChange == 0 || taskSyncChange)
	{
		[settings resetSDWSync];
        [dbm resetSDWIds];
        [pm resetSDWIds];
        
        if (syncAccountChange == 0)
        {
            [[SDWSync getInstance] resetSyncSection];
        }
	}
    
	[settings updateSettings:settingCopy];
    
    if (!settings.timeZoneSupport)
    {
        settings.timeZoneID = [Settings findTimeZoneID:[NSTimeZone systemTimeZone]];
    }
    
    if (timeZoneSupportChange)
    {
        if (!settings.timeZoneSupport)
        {
            [NSTimeZone setDefaultTimeZone:[NSTimeZone systemTimeZone]];
        }
        else
        {
            [NSTimeZone setDefaultTimeZone:[Settings getTimeZoneByID:settings.timeZoneID]];
        }
    }
    else if (timeZoneChange)
    {
        [NSTimeZone setDefaultTimeZone:[Settings getTimeZoneByID:settings.timeZoneID]];
    }
    
    if (weekStartChange)
    {
        [[NSCalendar currentCalendar] setFirstWeekday:settings.weekStart==0?1:2];
    }
    
    if (tabBarChanged)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TabBarModeChangeNotification" object:nil];
    }
	
	if (changeSkin)
	{
		for (UIViewController *ctrler in self.navigationController.viewControllers)
		{
			if ([ctrler respondsToSelector:@selector(changeSkin)])
			{
				[ctrler changeSkin];
			}
		}
	}
    
    if (timeZoneSupportChange || timeZoneChange)
    {
        [tm initData];
        
        [[AbstractActionViewController getInstance] refreshData];
    }
	else if (reSchedule && !mustDoDaysChange)
	{
		[tm scheduleTasks];
	}
	
	if ((weekStartChange && !mustDoDaysChange) || timeZoneSupportChange || timeZoneChange)
	{
        //[_abstractViewCtrler.miniMonthView initCalendar:tm.today];
        [[[AbstractActionViewController getInstance] getMiniMonth] initCalendar:tm.today];
        
        if ([[AbstractActionViewController getInstance] isKindOfClass:[PlannerViewController class]]) {
            PlannerViewController *ctrler = (PlannerViewController*)[AbstractActionViewController getInstance];
            [ctrler.plannerView goToDate:[[tm.today copy] autorelease]];
        }
	}
	
	[[TagDictionary getInstance] saveDict];
    
    BOOL toodledoAccountValid = ![settings.tdEmail isEqualToString:@""] && ![settings.tdPassword isEqualToString:@""] && settings.tdVerified;
    
    BOOL sdwAccountValid = ![settings.sdwEmail isEqualToString:@""] && ![settings.sdwEmail isEqualToString:@""] && settings.sdwVerified;
    
	BOOL ekAutoSyncON = (settings.ekSyncEnabled && settings.autoSyncEnabled) && (autoSyncChange || ekSyncWindowChange || ekSyncChange);
	BOOL tdAutoSyncON = settings.tdSyncEnabled && settings.autoSyncEnabled && (autoSyncChange || taskSyncChange);
	BOOL sdwAutoSyncON = settings.sdwSyncEnabled && settings.autoSyncEnabled && (autoSyncChange || taskSyncChange);
    BOOL rmdAutoSyncON = settings.ekAutoSyncEnabled && settings.autoSyncEnabled && (autoSyncChange || taskSyncChange);
    
	if (ekAutoSyncON)
	{
		[[EKSync getInstance] performSelector:@selector(initBackgroundAuto2WaySync) withObject:nil afterDelay:0.5];
	}
    else if (rmdAutoSyncON)
    {
        [[EKReminderSync getInstance] performSelector:@selector(initBackgroundAuto2WaySync) withObject:nil afterDelay:0.5];
    }
    else if (toodledoAccountValid && tdAutoSyncON)
	{
		[[TDSync getInstance] performSelector:@selector(initBackgroundAuto2WaySync) withObject:nil afterDelay:0.5];
	}
    else if (sdwAccountValid && sdwAutoSyncON)
	{
		[[SDWSync getInstance] performSelector:@selector(initBackgroundAuto2WaySync) withObject:nil afterDelay:0.5];
	}
    
    if (hideFutureTaskChange || mustDoDaysChange)
    {
        [[AbstractActionViewController getInstance] resetAllData];
    }
	
    if (defaultCatChange)
    {
        tm.eventDummy.project = settings.taskDefaultProject;
        tm.taskDummy.project = settings.taskDefaultProject;
        
        [[[AbstractActionViewController getInstance] getCategoryViewController] loadAndShowList];
        [[[AbstractActionViewController getInstance] getSmartListViewController] refreshQuickAddColor];
        
        Project *prj = [pm getProjectByKey:settings.taskDefaultProject];
        
        if (prj != nil)
        {
            // to refresh visibility in mySD if it was hidden in mySD before
            [prj modifyUpdateTimeIntoDB:[dbm getDatabase]];
        }
    }
    
    if (workTimeChange)
    {
        [[[AbstractActionViewController getInstance] getCalendarViewController] refreshCalendarDay];
    }
}

#pragma mark MultiEdits
- (NSMutableArray *) getMultiEditList
{
    PageAbstractViewController *ctrler = [self getActiveModule];
    
    if (ctrler != nil)
    {
        return [ctrler getMultiEditList];
    }
    
    return nil;
}

- (void) confirmMultiDeleteTask
{
	if ([[Settings getInstance] deleteWarning])
	{
		NSString *msg = _itemDeleteText;
		NSInteger tag = -14000;
		
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

- (void) confirmMultiMarkDone
{
	if ([[Settings getInstance] doneWarning])
	{
        TaskManager *tm = [TaskManager getInstance];
        
		NSString *title = tm.taskTypeFilter==TASK_FILTER_DONE?_taskUnMarkDoneTitle: _taskMarkDoneTitle;
		NSString *msg = tm.taskTypeFilter==TASK_FILTER_DONE?_taskUnMarkDoneText: _taskMarkDoneText;
		
		UIAlertView *taskDoneAlertView = [[UIAlertView alloc] initWithTitle:title  message:msg delegate:self cancelButtonTitle:_cancelText otherButtonTitles:nil];
		taskDoneAlertView.tag = -14001;
		
		[taskDoneAlertView addButtonWithTitle:_okText];
		[taskDoneAlertView show];
		[taskDoneAlertView release];
	}
	else
	{
		[self doMultiMarkDoneTask];
	}
}

- (void) doMultiDeleteTask
{
    NSMutableArray *list = [self getMultiEditList];
    
    [[self getActiveModule] cancelMultiEdit];
    
    [self hideMultiEditBar];
    
    [[TaskManager getInstance] deleteTasks:list];
    
    [[AbstractActionViewController getInstance] refreshData];
}

- (void) doMultiMarkDoneTask
{
    NSMutableArray *list = [self getMultiEditList];
    
    [[self getActiveModule] cancelMultiEdit];
    
    [self hideMultiEditBar];
    
    TaskManager *tm = [TaskManager getInstance];
    
    if (tm.taskTypeFilter == TASK_FILTER_DONE)
    {
        [tm markUnDoneTasks:list];
    }
    else
    {
        [tm markDoneTasks:list];
    }
    
    [[AbstractActionViewController getInstance] refreshData];
}

- (void)doMultiDefer: (NSInteger) option
{
    NSMutableArray *list = [self getMultiEditList];
    
    [[self getActiveModule] cancelMultiEdit];
    
    [self hideMultiEditBar];
    
    TaskManager *tm = [TaskManager getInstance];
        
    [tm deferTasks:list withOption:option];
    
    [[AbstractActionViewController getInstance] refreshData];
}

- (void) multiDelete:(id)sender
{
    [self confirmMultiDeleteTask];
}

- (void)multiDefer: (id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_deferText
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:_cancelText
                                              otherButtonTitles:_nextWeekText, _nextMonthText,nil];
    alertView.tag = -14002;
    [alertView show];
    [alertView release];
}

- (void) multiDoToday:(id)sender
{
    NSMutableArray *list = [self getMultiEditList];
    
    [[self getActiveModule] cancelMultiEdit];
    
    [self hideMultiEditBar];
    
    TaskManager *tm = [TaskManager getInstance];
    
    [tm moveTop:list];
    
    [[AbstractActionViewController getInstance] refreshData];
}

- (void) multiMarkDone:(id)sender
{
    [self confirmMultiMarkDone];
}

- (void) multiEdit:(BOOL) check
{
    BOOL firstCheck = (multiCount == 0 && check);
    BOOL lastCheck = (multiCount == 1 && !check);
    
    multiCount = check ? multiCount+1 : multiCount-1;
    
    if (firstCheck)
    {
        [self showMultiEditBar];
    }
    else if (lastCheck)
    {
        [self hideMultiEditBar];
    }
}

-(void) createMultiEditBar
{
    multiEditBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, contentView.bounds.size.width, 40)];
    multiEditBar.hidden = YES;
    
    [contentView addSubview:multiEditBar];
    [multiEditBar release];
    
    multiCount = 0;
}

- (void) hideMultiEditBar
{
    multiEditBar.hidden = YES;
    
    multiCount = 0;
}

- (void) showMultiEditBar
{
    UIButton *deleteButton = [Common createButton:@""
                                       buttonType:UIButtonTypeCustom
                                            frame:CGRectMake(0, 0, 30, 30)
                                       titleColor:[UIColor whiteColor]
                                           target:self
                                         selector:@selector(multiDelete:)
                                 normalStateImage:@"menu_trash.png"
                               selectedStateImage:nil];
    
    UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithCustomView:deleteButton];
    
    UIButton *deferButton = [Common createButton:@""
                                      buttonType:UIButtonTypeCustom
                                           frame:CGRectMake(0, 0, 30, 30)
                                      titleColor:[UIColor whiteColor]
                                          target:self
                                        selector:@selector(multiDefer:)
                                normalStateImage:@"menu_defer.png"
                              selectedStateImage:nil];
    
    UIBarButtonItem *deferItem = [[UIBarButtonItem alloc] initWithCustomView:deferButton];
    
    UIButton *todayButton = [Common createButton:@""
                                      buttonType:UIButtonTypeCustom
                                           frame:CGRectMake(0, 0, 30, 30)
                                      titleColor:[UIColor whiteColor]
                                          target:self
                                        selector:@selector(multiDoToday:)
                                normalStateImage:@"menu_dotoday.png"
                              selectedStateImage:nil];
    
    UIBarButtonItem *todayItem = [[UIBarButtonItem alloc] initWithCustomView:todayButton];
    
    UIButton *markDoneButton = [Common createButton:@""
                                         buttonType:UIButtonTypeCustom
                                              frame:CGRectMake(0, 0, 30, 30)
                                         titleColor:[UIColor whiteColor]
                                             target:self
                                           selector:@selector(multiMarkDone:)
                                   normalStateImage:@"menu_done.png"
                                 selectedStateImage:nil];
    
    UIBarButtonItem *markDoneItem = [[UIBarButtonItem alloc] initWithCustomView:markDoneButton];
    
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    PageAbstractViewController *ctrler = [self getActiveModule];
    
    multiEditBar.items = [ctrler isKindOfClass:[SmartListViewController class]]?[NSArray arrayWithObjects:markDoneItem,flexItem, todayItem, flexItem, deferItem, flexItem, deleteItem, nil]:[NSArray arrayWithObjects:flexItem, deleteItem, nil];
    
    [multiEditBar.superview bringSubviewToFront:multiEditBar];
    multiEditBar.hidden = NO;
    
    [deleteItem release];
    [deferItem release];
    [todayItem release];
    [markDoneItem release];
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
            /*
            BOOL isADE = ([actionTask isADE] || [actionTaskCopy isADE]);
            
            if (buttonIndex == 2) //all series
            {
                if ([Common daysBetween:actionTask.startTime sinceDate:actionTaskCopy.startTime] == 0 && [Common daysBetween:actionTask.endTime sinceDate:actionTaskCopy.endTime] == 0 && actionTask.timeZoneId == actionTaskCopy.timeZoneId) //user does not change date -> keep root date
                {
                    actionTaskCopy.startTime = [Common copyTimeFromDate:actionTaskCopy.startTime toDate:actionTask.original.startTime];
                    actionTaskCopy.endTime = [Common copyTimeFromDate:actionTaskCopy.endTime toDate:actionTask.original.endTime];
                }
            }
            
			[[TaskManager getInstance] updateREInstance:actionTask withRE:actionTaskCopy updateOption:buttonIndex];
            
            [self reconcileItem:actionTask reSchedule:YES];
            
            if ([self isKindOfClass:[PlannerViewController class]]) {
                if (isADE) {
                    PlannerMonthView *plannerMonthView = (PlannerMonthView*)[self getPlannerMonthCalendarView];
                    // reload openning week
                    [plannerMonthView refreshOpeningWeek:nil];
                } else {
                    PlannerBottomDayCal *plannerDayCal = [self getPlannerDayCalendarView];
                    [plannerDayCal refreshLayout];
                }
            }*/
            
            [self updateRE:buttonIndex];
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
    else if (alertVw.tag == -14000 && buttonIndex == 1)
    {
        [self doMultiDeleteTask];
    }
    else if (alertVw.tag == -14001 && buttonIndex == 1)
    {
        [self doMultiMarkDoneTask];
    }
    else if (alertVw.tag == -14002)
    {
        [self doMultiDefer:buttonIndex];
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
    [self deselect];
    
    if (_isiPad)
    {
        [_iPadViewCtrler closeDetail];
    }
    
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
    
    [[[AbstractActionViewController getInstance] getSmartListViewController] refreshQuickAddColor];
    
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
    //NSInteger taskId = [[notification.userInfo objectForKey:@"TaskId"] intValue];
    
    //[self reloadAlert4Task:taskId];
    
    [self applyFilter];
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

+ (AbstractActionViewController *) getInstance
{
    if (_iPadViewCtrler != nil)
    {
        return _iPadViewCtrler.activeViewCtrler;
    }
    else if (_sdViewCtrler != nil)
    {
        return _sdViewCtrler;
    }
    
    return nil;
}

@end
