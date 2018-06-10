//
//  AbstractSDViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 12/4/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "AbstractSDViewController.h"

#import "Common.h"
#import "Settings.h"
#import "Task.h"
#import "Project.h"

#import "ProjectManager.h"
#import "TaskManager.h"
#import "BusyController.h"
#import "TaskLinkManager.h"
#import "ImageManager.h"
#import "DBManager.h"

#import "TDSync.h"
#import "SDWSync.h"
#import "EKSync.h"
#import "EKReminderSync.h"

#import "ContentView.h"
#import "MiniMonthView.h"
#import "MonthlyCalendarView.h"
#import "FocusView.h"
#import "TaskView.h"
#import "NoteView.h"
#import "PlanView.h"

#import "CalendarViewController.h"
#import "SmartListViewController.h"
#import "NoteViewController.h"
#import "CategoryViewController.h"
#import "PlannerViewController.h"

//#import "NoteDetailTableViewController.h"
//#import "TaskDetailTableViewController.h"

#import "SmartListLayoutController.h"

#import "iPadViewController.h"

#import "SmartCalAppDelegate.h"

//extern BOOL _isiPad;

extern PlannerViewController *_plannerViewCtrler;

extern iPadViewController *_iPadViewCtrler;

@interface AbstractSDViewController ()

@end

@implementation AbstractSDViewController

@synthesize miniMonthView;
@synthesize focusView;
//@synthesize contentView;

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
        [self initViewControllers];
        
        //activeView = nil;
        
        //self.task2Link = nil;
    }

    return self;
}

- (void) dealloc
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //self.task2Link = nil;
     
    for (int i=0; i<4; i++)
    {
        [viewCtrlers[i] release];
    }
    
    [super dealloc];
}

- (void) hidePreview //to support change size in calendar view 
{
    [self hidePopover];
}

-(void) deselect
{
    /*
    if (activeView != nil)
    {
        [CATransaction begin];
        [activeView doSelect:NO];
        [CATransaction commit];
    }
    
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
    
    activeView = nil;
    */
    
    [super deselect];
    
    [self shrinkEnd];
}

- (void) initViewControllers
{
    for (int i=0; i<4; i++)
    {
        PageAbstractViewController *ctrler = nil;
        
        switch (i)
        {
            case 0:
                ctrler = [[CalendarViewController alloc] init];
                break;
            case 1:
            {
                ctrler = [[SmartListViewController alloc] init];
                //((SmartListViewController *)ctrler).smartListLayoutController.layoutInPlanner = NO;
            }
                break;
            case 2:
                ctrler = [[NoteViewController alloc] init];
                break;
            case 3:
                ctrler = [[CategoryViewController alloc] init];
                break;
        }
        
        [ctrler loadView];
        
        viewCtrlers[i] = ctrler;
    }
}

- (CalendarViewController *) getCalendarViewController
{
    return (CalendarViewController *)viewCtrlers[0];
}

- (SmartListViewController *) getSmartListViewController
{
    return (SmartListViewController *)viewCtrlers[1];
}

- (NoteViewController *) getNoteViewController
{
    return (NoteViewController *)viewCtrlers[2];
}

- (CategoryViewController *) getCategoryViewController
{
    return (CategoryViewController *)viewCtrlers[3];
}

- (FocusView *) getFocusView
{
    return focusView;
}

- (AbstractMonthCalendarView *) getMonthCalendarView
{
    return self.miniMonthView.calView;
}

- (MiniMonthView *) getMiniMonth
{
    return self.miniMonthView;
}

- (AbstractMonthCalendarView *)getPlannerMonthCalendarView
{
    return _plannerViewCtrler != nil?[_plannerViewCtrler getPlannerMonthCalendarView]:nil;
}

- (PlannerBottomDayCal *) getPlannerDayCalendarView
{
    return _plannerViewCtrler != nil?[_plannerViewCtrler getPlannerDayCalendarView]:nil;
}

- (NSString *) showTaskWithOption:(id)sender
{
    [self hideDropDownMenu];
    
    UIButton *button = (UIButton *) sender;
    
    SmartListViewController *ctrler = [self getSmartListViewController];
    
    [ctrler filter:button.tag];
    
    NSString *title = @"";
    
    switch (button.tag)
    {
        case TASK_FILTER_ALL:
            title = _allText;
            break;
        case TASK_FILTER_STAR:
            title = _starText;
            break;
        case TASK_FILTER_TOP:
            title = _gtdoText;
            break;
        case TASK_FILTER_DUE:
            title = _dueText;
            break;
        case TASK_FILTER_ACTIVE:
            title = _startText;
            break;
        case TASK_FILTER_DONE:
            title = _doneText;
            break;
        case TASK_FILTER_LONG:
            title = _longText;
            break;
        case TASK_FILTER_SHORT:
            title = _shortText;
            break;
    }
    
    if ([self checkControllerActive:3] && (button.tag == TASK_FILTER_DUE || button.tag == TASK_FILTER_ACTIVE))
    {
        //fix bug: change Due filter -> task order in project module is not the same
        CategoryViewController *catCtrler = [self getCategoryViewController];
        
        if (catCtrler.filterType == TYPE_TASK)
        {
            [catCtrler loadAndShowList];
        }
    }
    
    return title;
    
    /*
    if (!_isiPad)
    {
        self.navigationItem.title = [NSString stringWithFormat:@"%@ - %@",_smartTasksText,title];
    }
    */
}

//- (NSString *) showNoteWithOption:(id)sender
//{
//    [self hideDropDownMenu];
//
//    UIButton *button = (UIButton *) sender;
//
//    NoteViewController *ctrler = [self getNoteViewController];
//
//    [ctrler filter:button.tag];
//
//    NSString *title = @"";
//
//    switch (button.tag)
//    {
//        case NOTE_FILTER_ALL:
//            title = _allText;
//            break;
//        case NOTE_FILTER_CURRENT:
//            title = _currentText;
//            break;
//        case NOTE_FILTER_WEEK:
//            title = _thisWeekText;
//            break;
//    }
//
//    return title;
//
//    /*
//    if (!_isiPad)
//    {
//        self.navigationItem.title = [NSString stringWithFormat:@"%@ - %@",_notesText,title];
//    }
//    */
//}

- (NSString *)showNoteWithOption:(NSInteger)filterType {
    [self hideDropDownMenu];
    
    NoteViewController *ctrler = [self getNoteViewController];
    [ctrler filter:filterType];
    
    NSString *title = @"";
    switch (filterType) {
        case NOTE_FILTER_ALL:
            title = _allText;
            break;
        case NOTE_FILTER_CURRENT:
            title = _currentText;
            break;
        case NOTE_FILTER_WEEK:
            title = _thisWeekText;
            break;
    }
    
    return title;
    
    /*
     if (!_isiPad)
     {
     self.navigationItem.title = [NSString stringWithFormat:@"%@ - %@",_notesText,title];
     }
     */
}

- (NSString *) showProjectWithOption_old:(id)sender
{
    [self hideDropDownMenu];
    
    UIButton *button = (UIButton *) sender;
    
    CategoryViewController *ctrler = [self getCategoryViewController];
    
    NSString *title = @"";
    
    NSInteger type = TYPE_TASK;
    
    switch (button.tag)
    {
        case 0:
        {
            type = TYPE_TASK;
            title = _tasksText;
        }
            break;
        case 1:
        {
            type = TYPE_EVENT;
            title = _eventsText;
        }
            break;
        case 2:
        {
            type = TYPE_NOTE;
            title = _notesText;
        }
            break;
        case 3:
        {
            type = TASK_FILTER_PINNED;
            title = _anchoredText;
        }
            break;
    }
    
    BOOL filterChange = (ctrler.filterType != type);
    
    ctrler.filterType = type;
    
    [ctrler loadAndShowList];
    
    if (filterChange)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FilterChangeNotification" object:nil]; //refresh Detail view in sliding mode

    }
    
    return title;
    
    /*
    if (!_isiPad)
    {
        self.navigationItem.title = [NSString stringWithFormat:@"%@ - %@",_projectsText,title];
    }*/
}

- (NSString *)showProjectWithOption:(NSInteger)filterType {
    [self hideDropDownMenu];
    
    CategoryViewController *ctrler = [self getCategoryViewController];
    
    NSString *title = @"";
    
    NSInteger type = TYPE_TASK;
    
    switch (filterType)
    {
        case 0:
        {
            type = TYPE_TASK;
            title = _tasksText;
        }
            break;
        case 1:
        {
            type = TYPE_EVENT;
            title = _eventsText;
        }
            break;
        case 2:
        {
            type = TYPE_NOTE;
            title = _notesText;
        }
            break;
        case 3:
        {
            type = TASK_FILTER_PINNED;
            title = _anchoredText;
        }
            break;
    }
    
    BOOL filterChange = (ctrler.filterType != type);
    
    ctrler.filterType = type;
    
    [ctrler loadAndShowList];
    
    if (filterChange)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FilterChangeNotification" object:nil]; //refresh Detail view in sliding mode
        
    }
    
    return title;
    
    /*
     if (!_isiPad)
     {
     self.navigationItem.title = [NSString stringWithFormat:@"%@ - %@",_projectsText,title];
     }*/
}

#pragma mark View

-(void)changeSkin
{
    /*
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        [self.navigationController.navigationBar setBackgroundImage:[[ImageManager getInstance] getImageWithName:@"top_bg.png"] forBarMetrics:UIBarMetricsDefault];
    }*/
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self changeSkin];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
