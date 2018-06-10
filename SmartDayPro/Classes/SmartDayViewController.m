//
//  SmartDayViewController.m
//  SmartCal
//
//  Created by Left Coast Logic on 6/15/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "SmartDayViewController.h"

#import "Common.h"
#import "Settings.h"
#import "ImageManager.h"
#import "TaskManager.h"
#import "ProjectManager.h"
#import "TaskLinkManager.h"
#import "DBManager.h"
#import "BusyController.h"
#import "CommentManager.h"

#import "Task.h"
#import "Project.h"
#import "EKSync.h"
#import "SDWSync.h"
#import "TDSync.h"
#import "FilterData.h"

#import "MovableView.h"
#import "MiniMonthView.h"
#import "MonthlyCalendarView.h"
#import "ContentView.h"
#import "MenuMakerView.h"
#import "TaskView.h"
#import "PlanView.h"
#import "NoteView.h"
#import "FilterView.h"
#import "DateJumpView.h"
#import "LinkPreviewPane.h"
#import "GuideWebView.h"

#import "SettingTableViewController.h"
//#import "TaskDetailTableViewController.h"
//#import "NoteDetailTableViewController.h"
#import "ProjectEditViewController.h"
#import "CalendarSelectionTableViewController.h"

#import "NoteDetailViewController.h"
#import "TaskReadonlyDetailViewController.h"
#import "DetailViewController.h"
#import "NoteContentViewController.h"

#import "CalendarViewController.h"
#import "SmartListViewController.h"
#import "CategoryViewController.h"
#import "NoteViewController.h"
#import "NoteViewController.h"
#import "WeekViewController.h"
#import "HintModalViewController.h"

#import "MapLocationViewController.h"
#import "GuruViewController.h"

#import "SmartCalAppDelegate.h"
#import "FontManager.h"

#define TAG_CURRENTDATE_CALENDAR_TABBAR 9999

extern SmartCalAppDelegate *_appDelegate;
extern BOOL _calendarHintShown;
extern BOOL _smartListHintShown;
extern BOOL _noteHintShown;
extern BOOL _projectHintShown;
extern BOOL _starTabHintShown;
extern BOOL _gtdoTabHintShown;
extern BOOL _detailHintShown;

@interface SmartDayViewController ()

@end

@implementation SmartDayViewController

//@synthesize miniMonthView;
@synthesize activeViewCtrler;
//@synthesize contentView;
@synthesize filterView;
@synthesize previewPane;

//@synthesize task2Link;

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
        self.activeViewCtrler = nil;
        
        selectedTabButton = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(detectTouch:)
													 name:@"UserTouchNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(detectIdle:)
													 name:@"UserIdleNotification" object:nil];
        
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(tabBarModeChanged:)
													 name:@"TabBarModeChangeNotification" object:nil];
        
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(calendarDayReady:)
													 name:@"CalendarDayReadyNotification" object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(appBusy:)
													 name:@"AppBusyNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(appNoBusy:)
													 name:@"AppNoBusyNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveNewComments:)
                                                     name:@"NewCommentReceivedNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshUnreadComments:)
                                                     name:@"CommentUpdateNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshGeoTaskLocation:)
                                                     name:@"GeoLocationUpdateNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshGeoTaskLocation:)
                                                     name:@"TaskCreatedNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshGeoTaskLocation:)
                                                     name:@"TaskChangeNotification" object:nil];
    }
    
    return self;
}

- (void) dealloc
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.activeViewCtrler = nil;
    
    for (int i=0; i<TAB_NUM; i++)
    {
        [viewCtrlers[i] release];
    }
    
    [super dealloc];
}

- (BOOL) checkControllerActive:(NSInteger)index
{
    UIViewController *ctrler = viewCtrlers[index];
    
    if (self.activeViewCtrler == ctrler)
    {
        return YES;
    }
    
    return NO;
}

-(void)changeSkin
{
    /*
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        [self.navigationController.navigationBar setBackgroundImage:[[ImageManager getInstance] getImageWithName:@"top_bg.png"] forBarMetrics:UIBarMetricsDefault];
    }*/
}


-(void)shrinkEnd
{
    menuView.hidden = YES;
    
    addMenuView.hidden = YES;
    
    optionView.hidden = YES;
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
    
	if (!optionView.hidden)
	{
		[Common animateShrinkView:optionView toPosition:CGPointMake(160,0) target:self shrinkEnd:@selector(shrinkEnd)];
	}
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
    [self shrinkEnd];
    
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];

    if (!previewPane.hidden)
    {
        [previewPane show];//hide Preview Pane
    }
    
    activeView = nil;
     
     */
    
    [super deselect];
    
    if (!previewPane.hidden)
    {
        [previewPane show];//hide Preview Pane
    }
}

- (void) refreshTopBar
{
    TaskManager *tm = [TaskManager getInstance];
    
    if (topButton != nil && [topButton superview])
    {
        [topButton removeFromSuperview];
        
        topButton = nil;
    }
    
    if (optionView != nil && [optionView superview])
    {
        [optionView removeFromSuperview];
        
        optionView = nil;
    }
    
    if ([filterIndicator superview])
    {
        [filterIndicator removeFromSuperview];
    }
    
    //commentButton = nil;
    //taskLocationButton = nil;
    //notifButton = nil;

    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.titleView = nil;
    self.navigationItem.title = nil;
    
    NSInteger countListSelectedItems = [self countAllObjectSelectedInEditMode];
    if (countListSelectedItems > 0) {// Show navigationbar Edit Mode
        arrowDownImgView.hidden = YES;
        
        UIBarButtonItem *cancelBarBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                      target:self
                                                                                      action:@selector(cancelEditMode:)];
        self.navigationItem.leftBarButtonItem = cancelBarBtn;
        [cancelBarBtn release];
        
        self.navigationItem.title = [NSString stringWithFormat:@"%ld %@", countListSelectedItems, _selectedText];
    }
    else {
        arrowDownImgView.hidden = NO;
        
        if ([self.activeViewCtrler isKindOfClass:[WeekViewController class]])
        {
            NSString *title = @"";
            switch (tm.taskTypeFilter)
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
                    /*case TASK_FILTER_ACTIVE:
                     title = _startText;
                     break;*/
                case TASK_FILTER_LONG:
                    title = _longText;
                    break;
                case TASK_FILTER_SHORT:
                    title = _shortText;
                    break;
                case TASK_FILTER_DONE:
                    title = _doneText;
                    break;
            }
            //landscape mode
            self.navigationItem.title = [NSString stringWithFormat:@"%@ - %@", _overviewText, title];
            
            UIButton *exportButton = [Common createButton:@""
                                               buttonType:UIButtonTypeCustom
                                                    frame:CGRectMake(0, 10, 30, 30)
                                               titleColor:nil
                                                   target:self
                                                 selector:@selector(export:)
                                         normalStateImage:@"menu_export.png"
                                       selectedStateImage:nil];
            
            UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithCustomView:exportButton];
            
            self.navigationItem.rightBarButtonItem = menuItem;
            
            [menuItem release];
            
        }
        else {
            UIImage *leftImageIcon = [FontManager flowasticImageWithIconName:@"task-view-copy"
                                                                     andSize:SIZE_ICON_TOPBAR
                                                                   iconColor:[UIColor whiteColor]];
            
            UIButton *menuButton = [Common createButtonWith:@""
                                                 buttonType:UIButtonTypeCustom
                                                      frame:CGRectMake(0, 0, SIZE_ICON_TOPBAR, SIZE_ICON_TOPBAR)
                                                 titleColor:nil target:self
                                                   selector:@selector(showMenu:)
                                           normalStateImage:leftImageIcon
                                         selectedStateImage:nil];
            
            UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
            
            self.navigationItem.leftBarButtonItem = menuItem;
            
            [menuItem release];
            
            self.navigationItem.titleView = nil;
            
            topButton = [Common createButton:@""
                                  buttonType:UIButtonTypeCustom
                                       frame:CGRectMake(50, 0, 180, 40)
                                  titleColor:[UIColor whiteColor]
                                      target:self
                                    selector:selectedTabButton.tag==0?@selector(showMiniMonth:):@selector(showOptionMenu:)
                            normalStateImage:nil
                          selectedStateImage:nil];
            
            topButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
            
            topButton.tag = selectedTabButton.tag;
            
            [self.navigationController.navigationBar addSubview:topButton];
            
            switch (selectedTabButton.tag)
            {
                case 0:
                {
                    NSDate *today = [[TaskManager getInstance] today];
                    
                    self.navigationItem.title = [Common getCalendarDateString_EEEMMMDD:(today == nil?[NSDate date]:today)];
                }
                    break;
                case 1:
                {
                    NSString *title = @"";
                    switch (tm.taskTypeFilter)
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
                            /*
                             case TASK_FILTER_ACTIVE:
                             title = _startText;
                             break;
                             */
                        case TASK_FILTER_LONG:
                            title = _longText;
                            break;
                        case TASK_FILTER_SHORT:
                            title = _shortText;
                            break;
                        case TASK_FILTER_DONE:
                            title = _doneText;
                            break;
                    }
                    
                    self.navigationItem.title = [NSString stringWithFormat:@"%@ - %@",_smartTasksText,title];
                    
                    //[self createTaskOptionView];
                }
                    break;
                case 2:
                {
                    NSString *title = @"";
                    
                    NoteViewController *ctrler = [self getNoteViewController];
                    
                    switch (ctrler.filterType)
                    {
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
                    
                    self.navigationItem.title = [NSString stringWithFormat:@"%@ - %@",_notesText,title];
                    
                    //[self createNoteOptionView];
                }
                    
                    break;
                case 3:
                {
                    NSString *title = @"";
                    
                    CategoryViewController *ctrler = [self getCategoryViewController];
                    
                    switch (ctrler.filterType)
                    {
                        case TYPE_TASK:
                            title = _tasksText;
                            break;
                        case TYPE_EVENT:
                            title = _eventsText;
                            break;
                        case TYPE_NOTE:
                            title = _notesText;
                            break;
                        case TASK_FILTER_PINNED:
                            title = _anchoredText;
                            break;
                    }
                    self.navigationItem.title = [NSString stringWithFormat:@"%@ - %@",_projectsText,title];
                    
                    //[self createProjectOptionView];
                }
                    break;
            }
            
            /*
             notifButton = [Common createButton:@""
             buttonType:UIButtonTypeCustom
             //frame:CGRectMake(0, 0, 40, 40)
             frame:CGRectMake(0, 0, 40, 40)
             titleColor:[UIColor whiteColor]
             target:self
             selector:@selector(showNotifMenu:)
             normalStateImage:@"bar_notification_red.png"
             selectedStateImage:nil];
             notifButton.hidden = YES;
             
             UIBarButtonItem *notifItem = [[UIBarButtonItem alloc] initWithCustomView:notifButton];
             */
            
            /*
             commentButton = [Common createButton:@""
             buttonType:UIButtonTypeCustom
             //frame:CGRectMake(0, 0, 40, 40)
             frame:CGRectZero
             titleColor:[UIColor whiteColor]
             target:self
             selector:@selector(showUnreadComments:)
             normalStateImage:@"bar_comments.png"
             selectedStateImage:nil];
             commentButton.hidden = YES;
             
             UILabel *commentBadgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 20, 15)];
             commentBadgeLabel.font = [UIFont boldSystemFontOfSize:12];
             commentBadgeLabel.textColor = [UIColor whiteColor];
             commentBadgeLabel.textAlignment = NSTextAlignmentCenter;
             commentBadgeLabel.tag = 10000;
             commentBadgeLabel.layer.cornerRadius = 3;
             commentBadgeLabel.backgroundColor = [Colors redButton];
             
             [commentButton addSubview:commentBadgeLabel];
             [commentBadgeLabel release];
             
             UIBarButtonItem *commentItem = [[UIBarButtonItem alloc] initWithCustomView:commentButton];
             
             // task location =========================
             taskLocationButton = [Common createButton:@""
             buttonType:UIButtonTypeCustom
             //frame:CGRectMake(0, 0, 40, 40)
             frame:CGRectZero
             titleColor:[UIColor whiteColor]
             target:self
             selector:@selector(showGeoTaskLocation:)
             normalStateImage:@"bar_location.png"
             selectedStateImage:nil];
             taskLocationButton.hidden = YES;
             
             taskLocationLable = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 20, 15)];
             taskLocationLable.font = [UIFont boldSystemFontOfSize:12];
             taskLocationLable.textColor = [UIColor whiteColor];
             taskLocationLable.textAlignment = NSTextAlignmentCenter;
             //taskLocationLable.tag = 10000;
             taskLocationLable.text = @"0";
             taskLocationLable.layer.cornerRadius = 3;
             taskLocationLable.backgroundColor = [Colors redButton];
             
             [taskLocationButton addSubview:taskLocationLable];
             [taskLocationLable release];
             
             UIBarButtonItem *taskLocationButtonItem = [[UIBarButtonItem alloc] initWithCustomView:taskLocationButton];
             // end task location
             
             */
            
            UIImage *imageRightBar = [FontManager flowasticImageWithIconName:@"clock"
                                                                     andSize:SIZE_ICON_TOPBAR
                                                                   iconColor:[UIColor whiteColor]];
            
            UIButton *timerButton = [UIButton buttonWithType:UIButtonTypeCustom];
            timerButton.backgroundColor = [UIColor clearColor];
            [timerButton setImage:imageRightBar forState:UIControlStateNormal];
            timerButton.frame = CGRectMake(0, 0, SIZE_ICON_TOPBAR, SIZE_ICON_TOPBAR);
            [timerButton addTarget:self action:@selector(showTimer:)  forControlEvents:UIControlEventTouchUpInside];
            
            UIBarButtonItem *timerItem = [[UIBarButtonItem alloc] initWithCustomView:timerButton];
            
            self.navigationItem.rightBarButtonItem = timerItem;
            //self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:timerItem, commentItem, taskLocationButtonItem, nil];
            //self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:timerItem, notifItem, nil];
            
            [timerItem release];
            //[commentItem release];
            //[taskLocationButtonItem release];
            //[notifItem release];
            
            [self.navigationController.navigationBar addSubview:filterIndicator];
        }
    }
}

- (void) showNotifBadge
{
    UIButton *notifButton = [Common createButton:@""
                            buttonType:UIButtonTypeCustom
                   //frame:CGRectMake(0, 0, 40, 40)
                                 frame:CGRectMake(0, 0, 40, 40)
                            titleColor:[UIColor whiteColor]
                                target:self
                              selector:@selector(showNotifMenu:)
                      normalStateImage:@"bar_notification_red.png"
                    selectedStateImage:nil];
    //notifButton.hidden = YES;
    
    UIBarButtonItem *notifItem = [[UIBarButtonItem alloc] initWithCustomView:notifButton];
    
    UIButton *timerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    timerButton.backgroundColor = [UIColor clearColor];
    [timerButton setImage:[[ImageManager getInstance] getImageWithName:@"bar_timer.png"] forState:UIControlStateNormal];
    timerButton.frame = CGRectMake(0, 0, 40, 40);
    [timerButton addTarget:self action:@selector(showTimer:)  forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *timerItem = [[UIBarButtonItem alloc] initWithCustomView:timerButton];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:timerItem, notifItem, nil];
    
    [notifItem release];
    [timerItem release];
    
}

- (void) enableMiniMonth:(BOOL)enabled
{
    self.miniMonthView.hidden = !enabled;
}

- (void) showMiniMonth:(id) sender
{
    [self hideDropDownMenu];
    
    [self enableMiniMonth:(self.miniMonthView.hidden?YES:NO)];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MiniMonthResizeNotification" object:self.miniMonthView];
}

- (void) hideMiniMonth
{
    if (!self.miniMonthView.hidden)
    {
        [self enableMiniMonth:NO];
    
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MiniMonthResizeNotification" object:self.miniMonthView];
    }
}

- (void) hidePreview
{
    if (!previewPane.hidden)
    {
        [previewPane show];
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
        [contentView bringSubviewToFront:filterView];
        
		[filterView popUpView];	
	}
}

- (void) showDateJumper:(id)sender
{
	[self hideDropDownMenu];
	
	if (dateJumpView.userInteractionEnabled == YES)
	{
		[dateJumpView popDownView];
		
		self.activeViewCtrler.view.userInteractionEnabled = YES;
	}
	else
	{		
		[dateJumpView popUpView];		
		
		self.activeViewCtrler.view.userInteractionEnabled = NO;
	}	
}

- (void) showCalendarView
{
    [self tab:tabButtons[0]];
}

-(void) switchView:(NSInteger)idx
{
    UIButton *btn = [navigationView viewWithTag:idx];
    
    if (btn != nil)
    {
        [self tab:btn];
    }
    
}

/*
- (void) refreshView
{
    for (int i=0; i<TAB_NUM;i++)
    {
        UIViewController *ctrler = viewCtrlers[i];
        
        if ([ctrler respondsToSelector:@selector(refreshView)])
        {
            [ctrler refreshView];
        }
    }
}

- (void) setNeedsDisplay
{
    for (int i=0; i<TAB_NUM; i++)
    {
        PageAbstractViewController *ctrler = viewCtrlers[i];
        
        [ctrler setNeedsDisplay];
        
        if ([ctrler isKindOfClass:[CalendarViewController class]])
        {
            CalendarViewController *calCtrler = [self getCalendarViewController];
            [calCtrler refreshADEPane];
        }
    }
}
*/
/*
- (void) showBusyIndicator:(BOOL)enable
{
	if (enable)
	{
		if (self.busyIndicatorView.hidden)
		{
            self.busyIndicatorView.hidden = NO;
			[self.busyIndicatorView performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:NO];
		}
	}
	else
	{
		[self.busyIndicatorView performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
        self.busyIndicatorView.hidden = YES;
	}
    
    [_focusViewCtrler showBusyIndicator:enable];
}
*/

/*
- (void) jumpToDate:(NSDate *)date
{
    [super jumpToDate:date];
    
    self.activeViewCtrler.view.userInteractionEnabled = YES;
}
*/

- (void) scrollToDate:(NSDate *)date {
    [super scrollToDate:date];
    
    self.navigationItem.title = [Common getCalendarDateString_EEEMMMDD:date];
    [self refreshDayOnCalendarTabbarWithDate:date];
}

- (void) applyFilter
{
    /*
    TaskManager *tm = [TaskManager getInstance];
    
    NSDate *dt = [tm.today copy];
    
    [tm initCalendarData:dt];
    [tm initSmartListData];
    
    [dt release];
    
    [miniMonthView initCalendar:tm.today];
    
    NoteViewController *noteCtrler = [self getNoteViewController];
    [noteCtrler loadAndShowList];
    
    CategoryViewController *catCtrler = [self getCategoryViewController];
    [catCtrler loadAndShowList];
    */
    
    [super applyFilter];
    
    TaskManager *tm = [TaskManager getInstance];
    
    filterIndicator.hidden = (tm.filterData == nil);    
}

- (void) refreshFilterTag
{
    if (filterView.userInteractionEnabled)
    {
        [filterView tagInputReset];
    }
}

/*
- (void) refreshData
{
    if ([self.activeViewCtrler isKindOfClass:[NoteViewController class]])
    {
        NoteViewController *ctrler = (NoteViewController *) self.activeViewCtrler;
        
        [ctrler loadAndShowList];
    }
    else if ([self.activeViewCtrler isKindOfClass:[CategoryViewController class]])
    {
        CategoryViewController *ctrler = (CategoryViewController *) self.activeViewCtrler;
        
        [ctrler loadAndShowList];
    }
    
    [self.miniMonthView initCalendar:[[TaskManager getInstance] today]];
    
    CalendarViewController *ctrler = [self getCalendarViewController];
    [ctrler refreshADEPane];
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
*/

- (void) expandPreview
{
    [self hideMiniMonth];
    
    if (activeView != nil)
    {
        CGRect frm = activeView.frame;
        frm.origin = [activeView.superview convertPoint:frm.origin toView:contentView];
    
        if (frm.origin.y + frm.size.height > previewPane.frame.origin.y)
        {
            CGFloat dyScroll = frm.origin.y + frm.size.height - previewPane.frame.origin.y + 20;
            
            if ([activeView.superview isKindOfClass:[UIScrollView class]])
            {
                UIScrollView *scrollView = (UIScrollView *)activeView.superview;
                
                ////printf("scroll view content height:%f\n", scrollView.contentSize.height);
                
                CGPoint contentOffset = scrollView.contentOffset;
                
                contentOffset.y += dyScroll;
                
                [scrollView setContentOffset:contentOffset animated:YES];
            }
        }
    }
}

- (void) showModuleByIndex:(NSInteger)index
{
    //index: 0-Calendar, 1-Task, 2-Note, 3-Project
    [self tab:tabButtons[index]];
}

- (void) jumpToDate:(NSDate *)date
{
    [self.navigationController popToRootViewControllerAnimated:YES];

    self.activeViewCtrler.view.userInteractionEnabled = YES;
    
    [super jumpToDate: date];
    
    [self showModuleByIndex:0];
}

/*
- (Task *) getActiveTask
{
    if (activeView != nil && [activeView isKindOfClass:[TaskView class]])
    {
        //return (Task *) activeView.tag;
        return ((TaskView *) activeView).task;
    }
}

- (Project *) getActiveProject
{
    if (activeView != nil && [activeView isKindOfClass:[PlanView class]])
    {
        //return (Project *) activeView.tag;
        return ((PlanView *) activeView).project;
    }
}

#pragma mark Controllers

- (CalendarViewController *) getCalendarViewController
{
    return viewCtrlers[0];
}

- (SmartListViewController *) getSmartListViewController
{
    return viewCtrlers[1];
}

- (NoteViewController *) getNoteViewController
{
    return viewCtrlers[2];
}

- (CategoryViewController *) getCategoryViewController
{
    return viewCtrlers[3];
}

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
*/
#pragma mark Link Handle
- (void) copyLink
{
    //Task *task = [self.activeViewCtrler getSelectedTask];
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
    
    int linkId = [tlm createLink:task.primaryKey destId:self.task2Link.primaryKey destType:ASSET_ITEM];
    
    if (linkId != -1)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil]; //trigger sync for Link
    }
    
    [task release];
}

#pragma mark Category Handle
- (void) enableCategoryActions:(BOOL)enable onView:(PlanView *)view
{
/*
    if ([[BusyController getInstance] checkSyncBusy])
    {
        return;
    }
        
    [self hideDropDownMenu];
    
    if (activeView != nil)
    {
        [activeView doSelect:NO];
    }
    
    if (previewPane.hidden)
    {
        UIMenuController *menuCtrler = [UIMenuController sharedMenuController];
        
        CGRect frm = view.frame;
        
        if (enable)
        {
            frm.origin = [view.superview convertPoint:frm.origin toView:contentView];
            
            contentView.actionType = ACTION_CATEGORY_EDIT;
            
            [contentView becomeFirstResponder];
            [menuCtrler setTargetRect:frm inView:contentView];
            [menuCtrler setMenuVisible:YES animated:YES];
            
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
        
        [previewPane show];
    }
*/
    
    if (!previewPane.hidden)
    {
        [previewPane show]; //hide preview
    }
    
    [super enableCategoryActions:enable onView:view];
}

/*
- (void) copyCategory
{
    //Project *plan = [self.activeViewCtrler getSelectedCategory];
    
    Project *plan = [self getActiveProject];
    
	if (plan != nil)
	{
        Project *planCopy = [[plan copy] autorelease];
        
        planCopy.name = [NSString stringWithFormat:@"%@ (copy)", plan.name];
        planCopy.primaryKey = -1;
        
        [self editCategory:planCopy];        
	}
}
*/

- (void) doDeleteCategory:(BOOL) cleanFromDB
{
	//Project *plan = [self.activeViewCtrler getSelectedCategory];
	
    Project *plan = [self getActiveProject];
    
    [plan retain];
    
    [self deselect];
    
	if (plan != nil)
	{
        TaskManager *tm = [TaskManager getInstance];
        
		[[ProjectManager getInstance] deleteProject:plan cleanFromDB:cleanFromDB];
		[tm initData];
		
		[self.miniMonthView initCalendar:tm.today];
		
		CategoryViewController *ctrler = self.activeViewCtrler;
        
        [ctrler loadAndShowList];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EventChangeNotification" object:nil];
	}
    
    [plan release];
}

/*
- (void) deleteCategory
{
    //Project *project = [self.activeViewCtrler getSelectedCategory];
    
    Project *project = [self getActiveProject];
    
    if (project != nil)
    {
		if ([[Settings getInstance] taskDefaultProject] == project.primaryKey)
		{
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_deleteWarningText message:_cannotDeleteDefaultProjectText delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
			
			[alertView show];
			[alertView release];			
		}
        else if (project.source == CATEGORY_SOURCE_ICAL)
        {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_deleteWarningText message:_cannotDeleteExternalProjectText delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
			
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
*/

- (void) showHideCategory: (id) sender
{
    [self hideDropDownMenu];
    
	CalendarSelectionTableViewController *ctrler = [[CalendarSelectionTableViewController alloc] init];
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];			
	
}

#pragma mark Task Handle
- (void)showActionMenu:(TaskView *)view
{
    //Task *task = (Task *)view.tag;
    Task *task = view.task;
    
    if ([task isShared])
    {
        return;
    }
    
    NSInteger pk = (task.original != nil && ![task isREException]?task.original.primaryKey:task.primaryKey);
    
    BOOL calendarTask = [self.activeViewCtrler isKindOfClass:[CalendarViewController class]] && [task isTask];
    
    contentView.actionType = calendarTask?ACTION_TASK_EDIT:([task isNote]?ACTION_NOTE_EDIT:ACTION_ITEM_EDIT);
    contentView.tag = pk;
    
    CGRect frm = view.frame;
    frm.origin = [view.superview convertPoint:frm.origin toView:contentView];
    
    if (frm.origin.y + frm.size.height > previewPane.frame.origin.y)
    {
        CGFloat dyScroll = frm.origin.y + frm.size.height - previewPane.frame.origin.y + 40;
        
        if ([view.superview isKindOfClass:[UIScrollView class]])
        {
            UIScrollView *scrollView = (UIScrollView *)view.superview;
            
            CGPoint contentOffset = scrollView.contentOffset;
            
            contentOffset.y += dyScroll;
            
            [scrollView setContentOffset:contentOffset animated:YES];
            
            frm.origin.y -= dyScroll;
        }
    }
    
    UIMenuController *menuCtrler = [UIMenuController sharedMenuController];
    
    [contentView becomeFirstResponder];
    [menuCtrler setTargetRect:frm inView:contentView];
    [menuCtrler setMenuVisible:YES animated:YES];
}

/*
- (void) enableActions:(BOOL)enable onView:(TaskView *)view
{
	if ([[BusyController getInstance] checkSyncBusy])
    {
        return;
    }
    
    if ([self.activeViewCtrler isKindOfClass:[SmartListViewController class]])
    {
        SmartListViewController *ctrler = (SmartListViewController *) self.activeViewCtrler;
        
        if ([ctrler isInMultiEditMode])
        {
            return;
        }
    }
    
    [self hideDropDownMenu];
    
    if (activeView != nil)
    {
        [activeView doSelect:NO];
    }    
    
    if (previewPane.hidden)
    {
        UIMenuController *menuCtrler = [UIMenuController sharedMenuController];
        
        if (enable)
        {
            Task *task = view.task;
            
            previewPane.task = task;
            
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
    
    [previewPane show];
}
*/
 
-(void) editItemDetail:(Task *)item
{
    UIViewController *editCtrler = nil;
    
    if ([item isNote])
    {
        NoteDetailViewController *ctrler = [[NoteDetailViewController alloc] init];
        ctrler.note = item;
        
        editCtrler = ctrler;

    }
    else if ([item isShared])
    {
        TaskReadonlyDetailViewController *ctrler = [[TaskReadonlyDetailViewController alloc] init];
        ctrler.task = item;

        editCtrler = ctrler;
    }
    else
    {
        DetailViewController *ctrler = [[DetailViewController alloc] init];
        
        ctrler.task = item;
        
        editCtrler = ctrler;
    }
    
    if (editCtrler != nil)
    {
        [self.navigationController pushViewController:editCtrler animated:YES];
        [editCtrler release];
        
        [self performSelector:@selector(popupDetailHint) withObject:nil afterDelay:0.5];
    }
}

- (void) editProjectDetail:(Project *)project
{
    ProjectEditViewController *ctrler = [[ProjectEditViewController alloc] init];
    ctrler.project = project;

    [self.navigationController pushViewController:ctrler animated:YES];
    [ctrler release];
}

- (void) editNoteContent:(Task *)note
{
    if ([self.navigationController.topViewController isKindOfClass:[NoteContentViewController class]]) {
//        NoteContentViewController *ctrler = (NoteContentViewController *)self.navigationController.topViewController;
//        ctrler.note = note;
        return;
    }
    NoteContentViewController *ctrler = [[NoteContentViewController alloc] init];
    ctrler.note = note;

    [self.navigationController pushViewController:ctrler animated:YES];
    [ctrler release];
}

- (void) editMapLocation:(Task *)task
{
    MapLocationViewController *ctrler = [[MapLocationViewController alloc] init];
    ctrler.task = task;
    
    [self.navigationController pushViewController:ctrler animated:YES];
    [ctrler release];
}

#pragma mark Actions
/*
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

- (void) addEvent:(id) sender
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

- (void) addTask:(id) sender
{
	TaskDetailTableViewController *ctrler = [[TaskDetailTableViewController alloc] init];
    
	TaskManager *tm = [TaskManager getInstance];
    Settings *settings = [Settings getInstance];

	Task *newTask = [[Task alloc] init];
	newTask.type = TYPE_TASK;
	
    newTask.startTime = [settings getWorkingStartTimeForDate:tm.today];
	
	switch (tm.taskTypeFilter) 
	{
		case TASK_FILTER_STAR:
		{
			newTask.status = TASK_STATUS_PINNED;
		}
			break;
		case TASK_FILTER_DUE:
		{
			newTask.deadline = [settings getWorkingEndTimeForDate:tm.today];
		}
			break;
	}	
	
	ctrler.task = newTask;
	
	[newTask release];
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];				
}

- (void) editCategory:(Project *) project
{
	ProjectEditViewController *ctrler = [[ProjectEditViewController alloc] init];
	
	ctrler.project = project;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];		        
}

- (void) addCategory:(id) sender
{
	Project *project = [[Project alloc] init];
	project.name = _newCalendarText;
	project.type = TYPE_PLAN;
	
    [self editCategory:project];
}

- (void) add:(id)sender
{
    switch (selectedTabButton.tag)
    {
        case 0:
            [self addEvent:nil];
            break;
        case 1:
            [self addTask:nil];
            break;
        case 2:
            [self addNote:nil];
            break;  
        case 3:
            [self addCategory:nil];
            break;
    }
}

- (void)longPressHandler:(UILongPressGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state != UIGestureRecognizerStateEnded) 
	{    
        ////NSLog(@"Long press");
        [self showAddMenu:nil];
    }
}
*/

- (void)tab:(id)sender
{
    //NSDate *dt = [[DBManager getInstance] getLastestTaskUpdateTime];
    
    //printf("Task latest update time: %s\n", [[dt description] UTF8String]);

    UIButton *btn = (UIButton *) sender;
    
    if (btn != selectedTabButton)
    {
        [self deselect];
        
        if (selectedTabButton != nil)
        {
            selectedTabButton.selected = NO;
        }
 
        selectedTabButton = btn;
        
        selectedTabButton.selected = YES;
        
        [self refreshColorForTextTabbarAtIndex:(btn.tag + 1) andIsSelected:selectedTabButton.isSelected];
                
        if (self.activeViewCtrler != nil)
        {
            [self.activeViewCtrler.view removeFromSuperview];
        }
        
        UIViewController *ctrler = viewCtrlers[btn.tag];
        
        self.activeViewCtrler = ctrler;
        
        if (self.activeViewCtrler != nil)
        {
            [moduleView addSubview:self.activeViewCtrler.view];
            
            if ([self.activeViewCtrler isKindOfClass:[SmartListViewController class]])
            {
                SmartListViewController *slCtrler = (SmartListViewController *) self.activeViewCtrler;
                //[slCtrler hideQuickAdd];
            }
        }
        
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.4];
        [animation setType:kCATransitionPush];
        [animation setSubtype:(selectedTabButton.tag>btn.tag?kCATransitionFromLeft:kCATransitionFromRight)];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        [[moduleView layer] addAnimation:animation forKey:@"slideTransition"];
        
        [self createMenuView];
        
        [self refreshTopBar];
        
        //[self popupHint];
    }
    
    if (!miniMonthView.hidden && (selectedTabButton.tag != 0))
    {
        [self hideMiniMonth];
    }
}

- (void) editSetting: (id) sender
{
	[self hideDropDownMenu];
	
	SettingTableViewController *ctrler = [[SettingTableViewController alloc] init];
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];	
}

- (void) showMenu: (id) sender
{
    BOOL menuVisible = !menuView.hidden;
    
	[self deselect];
    
	//if (menuView.hidden)
    if (!menuVisible)
	{
		UILabel *label = (UILabel *)[menuView viewWithTag:10000 + TASK_FILTER_GLOBAL];
		
		if (label != nil)
		{
			label.textColor = ([[TaskManager getInstance] filterData] == nil?[UIColor whiteColor]:[UIColor yellowColor]);
		}
		
		menuView.hidden = NO;
		[contentView  bringSubviewToFront:menuView];
		
		[Common animateGrowViewFromPoint:CGPointMake(0,0) toPoint:CGPointMake(menuView.bounds.size.width/2, menuView.bounds.size.height/2) forView:menuView];
	}
	/*else
	{
		[Common animateShrinkView:menuView toPosition:CGPointMake(0,0) target:self shrinkEnd:@selector(shrinkEnd)];
	}*/		
}

- (void) showAddMenu: (id) sender
{
    BOOL menuVisible = !addMenuView.hidden;
    
    [self deselect];
    
	//if (addMenuView.hidden)
    if (!menuVisible)
	{		
		addMenuView.hidden = NO;
		[contentView  bringSubviewToFront:addMenuView];
		
		[Common animateGrowViewFromPoint:CGPointMake(320,0) toPoint:CGPointMake(320-addMenuView.bounds.size.width/2, addMenuView.bounds.size.height/2) forView:addMenuView];
	}
	/*else
	{
		[Common animateShrinkView:addMenuView toPosition:CGPointMake(320,0) target:self shrinkEnd:@selector(shrinkEnd)];
	}*/
}

- (void) showOptionMenu: (id) sender
{
    UIButton *btn = (UIButton *) sender;
    
    BOOL menuVisible = (optionView != nil && !optionView.hidden);
    
    [self deselect];
    
	//if (optionView.hidden)
    if (!menuVisible)
	{
        if (btn != nil)
        {
            switch (btn.tag)
            {
                case 1:
                {
                    [self createTaskOptionView];
                }
                    break;
                case 2:
                {
                    [self createNoteOptionView];
                }
                    break;
                case 3:
                {
                    [self createProjectOptionView];
                }
                    break;
            }
        }
        else
        {
            [self createNotifOptionView];
        }
        
		optionView.hidden = NO;
		[contentView  bringSubviewToFront:optionView];
		
		[Common animateGrowViewFromPoint:CGPointMake(160,0) toPoint:CGPointMake(160, optionView.bounds.size.height/2) forView:optionView];
	}
}

- (void) filter: (id)sender
{
    UISegmentedControl *segmentedCtrl = (UISegmentedControl *)sender;
    
    CategoryViewController *ctrler = (CategoryViewController *) self.activeViewCtrler;
    
    switch (segmentedCtrl.selectedSegmentIndex)
    {
        case 0:
            ctrler.filterType = TYPE_TASK;
            break;
        case 1:
            ctrler.filterType = TYPE_EVENT;
            break;
        case 2:
            ctrler.filterType = TYPE_NOTE;
            break;
    }
    
    [ctrler loadAndShowList];
}

- (void) sync:(id) sender
{
    [super sync];
}

/*
- (void) multiEdit:(id) sender
{
    [self hideDropDownMenu];
    
    if ([self.activeViewCtrler isKindOfClass:[SmartListViewController class]])
    {
        SmartListViewController *ctrler = (SmartListViewController *) self.activeViewCtrler;
        
        [ctrler multiEdit:YES];
    }
    else if ([self.activeViewCtrler isKindOfClass:[NoteViewController class]])
    {
        NoteViewController *ctrler = (NoteViewController *) self.activeViewCtrler;
        
        [ctrler multiEdit:YES];
    }
}
*/

- (void) showToday:(id)sender
{
    [self deselect];
    
    [self jumpToDate:[NSDate date]];
}

- (void) showDate:(id)sender
{
    [self deselect];
    
    //CalendarViewController *ctrler = [self getCalendarViewController];
    
    //[ctrler showDateJumper:nil];
    
    [contentView bringSubviewToFront:dateJumpView];
    
    [self showDateJumper:nil];
}

- (void) backup:(id)sender
{
    [super backup];
}

- (NSString *) showProjectWithOption:(id)sender
{
    NSString *title = [super showProjectWithOption:sender];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@ - %@",_projectsText,title];
    
    return title;
}

- (NSString *) showTaskWithOption:(id)sender
{
    NSString *title = [super showTaskWithOption:sender];

    self.navigationItem.title = [NSString stringWithFormat:@"%@ - %@",_smartTasksText,title];
    
    return title;
}

- (NSString *) showNoteWithOption:(id)sender
{
    NSString *title = [super showNoteWithOption:sender];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@ - %@",_notesText,title];
    
    return title;
}

/*
- (void) showProjectWithOption:(id)sender
{
    [self hideDropDownMenu];
    
    UIButton *button = (UIButton *) sender;
    
    CategoryViewController *ctrler = (CategoryViewController *) self.activeViewCtrler;
    
    NSString *title = @"";
    
    switch (button.tag)
    {
        case 0:
        {
            //ctrler.filterType = TYPE_TASK;
            title = _tasksText;
        }
            break;
        case 1:
        {
            ctrler.filterType = TYPE_EVENT;
            title = _eventsText;
        }
            break;
        case 2:
        {
            ctrler.filterType = TYPE_NOTE;
            title = _notesText;
        }
            break;
    }
    
    [ctrler loadAndShowList];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@ - %@",_projectsText,title];
}

- (void) showTaskWithOption:(id)sender
{
    [self hideDropDownMenu];
    
    UIButton *button = (UIButton *) sender;
    
    SmartListViewController *ctrler = (SmartListViewController *) self.activeViewCtrler;
    
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
    }
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@ - %@",_smartTasksText,title];

}

- (void) showNoteWithOption:(id)sender
{
    [self hideDropDownMenu];
    
    UIButton *button = (UIButton *) sender;
    
    NoteViewController *ctrler = (NoteViewController *) self.activeViewCtrler;
    
    [ctrler filter:button.tag];
    
    NSString *title = @"";
    
    switch (button.tag)
    {
        case NOTE_FILTER_ALL:
            title = _allText;
            break;
        case NOTE_FILTER_CURRENT:
            title = _todayText;
            break;
    }
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@ - %@",_notesText,title];
}
*/
- (void) export:(id)sender
{
    if ([self.activeViewCtrler isKindOfClass:[WeekViewController class]])
    {
        WeekViewController *ctrler = (WeekViewController *) self.activeViewCtrler;
        [ctrler exportPNG];
    }
}

- (void) test:(id)sender
{
    //printf("test\n");
}

- (void) showTimer:(id)sender
{
    [super showTimer];
}

- (void) showUnreadComments:(id) sender
{
    [[AbstractActionViewController getInstance] showUnreadCommentsWithCGRect:((UIButton*)sender).frame];
}

- (void)showGeoTaskLocation:(id)sender
{
    [[AbstractActionViewController getInstance] showGeoTaskLocationWithCGRect:((UIButton*)sender).frame];
}

- (void) showNotifMenu:(id) sender
{
    [self showOptionMenu:nil];
}

- (void) showNotifWithOptions:(id) sender
{
    UIButton *btn = (UIButton *) sender;
    
    switch (btn.tag)
    {
        case 0:
            [self showUnreadComments:btn];
            break;
            
        case 1:
            [self showGeoTaskLocation:btn];
            break;
    }
}

#pragma mark Hint

- (void) hint: (id) sender
{
    _detailHintShown = YES;
    
	Settings *settings = [Settings getInstance];
    
    NSInteger tag = [(UIButton *)sender tag];
	
	if (tag == 10001) //Don't Show
	{
		[settings enableDetailHint:NO];
	}
    
    [self popdownDetailHint];
    
}

-(UIView *) createDetailHintView
{
    CGSize sz = [Common getScreenSize];
    sz.height += 44;
    
    CGRect frm = CGRectZero;
    
    frm.origin.y = 20;
    frm.size = sz;
    
	UIView *view = [[[UIView alloc] initWithFrame:frm] autorelease];
	view.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
	
    frm.size.height -= 40;
    
	GuideWebView *hintLabel = [[GuideWebView alloc] initWithFrame:frm];
    hintLabel.backgroundColor = [UIColor clearColor];
    
    NSArray* availableLocalizations = [[NSBundle mainBundle] localizations];
    NSArray* userPrefered = [NSBundle preferredLocalizationsFromArray:availableLocalizations forPreferences:[NSLocale preferredLanguages]];
    
    NSString *localization = [userPrefered objectAtIndex:0];
    
    NSString *hintFile = @"detail_hint_";
    
    if ([localization isEqualToString:@"ja"] || [localization isEqualToString:@"de"])
    {
        hintFile = [hintFile stringByAppendingString:localization];
    }
    else // else is EN
    {
        hintFile = [hintFile stringByAppendingString:@"en"];
    }
    
	[hintLabel loadHTMLFile:hintFile extension:@"htm"];
	
	[view addSubview:hintLabel];
	
	[hintLabel release];
	
	UIButton *hintOKButton = [Common createButton:_okText
                                       buttonType:UIButtonTypeCustom
                                            frame:CGRectMake(frm.size.width - 110, frm.size.height + 25, 100, 30)
                                       titleColor:[Colors blueButton]
                                           target:self
                                         selector:@selector(hint:)
                                 normalStateImage:nil
                               selectedStateImage:nil];
	hintOKButton.tag = 10000;
    
    hintOKButton.layer.cornerRadius = 4;
    hintOKButton.layer.borderWidth = 1;
    hintOKButton.layer.borderColor = [[Colors blueButton] CGColor];
    
    sz = [_dontShowText sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f]}];
	
	UIButton *hintDontShowButton =[Common createButton:_dontShowText
											buttonType:UIButtonTypeCustom
                                                 //frame:CGRectMake(10, frm.size.height + 25, 100, 30)
                                                 frame:CGRectMake(10, frm.size.height + 25, sz.width + 20, 30)
											titleColor:[Colors blueButton]
												target:self
											  selector:@selector(hint:)
									  normalStateImage:nil
									selectedStateImage:nil];
	hintDontShowButton.tag = 10001;
    
    hintDontShowButton.layer.cornerRadius = 4;
    hintDontShowButton.layer.borderWidth = 1;
    hintDontShowButton.layer.borderColor = [[Colors blueButton] CGColor];
	
	[view addSubview:hintOKButton];
	
	[view addSubview:hintDontShowButton];
    
    return view;
}

- (void) popupDetailHint
{
    Settings *settings = [Settings getInstance];
    
    if (!_detailHintShown && settings.detailHint)
    {
        HintModalViewController *ctrler = [[HintModalViewController alloc] init];
        ctrler.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        UIView *hintView = [self createDetailHintView];
        
        ctrler.view = hintView;
        
        [self presentViewController:ctrler animated:YES completion:NULL];
    }
}

- (void) popdownDetailHint
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Views

- (void)createNavigationView {
    UIView *viewTopLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentView.bounds.size.width, 1)];
    viewTopLine.backgroundColor = COLOR_LINE;
    
    navigationView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                              contentView.frame.size.height,
                                                              contentView.bounds.size.width,
                                                              [Common heightTabbar])];
    navigationView.backgroundColor = BACKGROUND_TABBAR;
    [navigationView addSubview:viewTopLine];
    [viewTopLine release];
    [contentView addSubview:navigationView];
    [navigationView release];
    
    NSString *iconNames[TAB_NUM] = {@"calendar-view-sel", @"task-view", @"note-view", @"project-view"};
    NSString *selectedImages[TAB_NUM] = {@"calendar-view-sel", @"task-view-sel", @"note-view-sel", @"project-sel"};
    NSString *tabNames[TAB_NUM] = {_calendarText, _tasksText, _notesText, _projectsText};
    
    CGSize sz = [Common getScreenSize];
    CGFloat w = sz.width/TAB_NUM;
    
    for (int i=0; i < TAB_NUM; i++) {
        UIImage *normalStateImage = [FontManager flowasticImageWithIconName:iconNames[i]
                                                                    andSize:SIZE_ICON_TABBAR
                                                                  iconColor:COLOR_ICON_TABBAR];
        
        UIImage *selectStateImage = [FontManager flowasticImageWithIconName:selectedImages[i]
                                                                    andSize:SIZE_ICON_TABBAR
                                                                  iconColor:COLOR_ICON_TABBAR_SEL];
        
        UIButton *button = [Common createButtonWith:@""
                                         buttonType:UIButtonTypeCustom
                                              frame:CGRectMake(i*w, 5, w, SIZE_ICON_TABBAR)
                                         titleColor:nil target:self
                                           selector:@selector(tab:)
                                   normalStateImage:normalStateImage
                                 selectedStateImage:selectStateImage];
        button.tag = i;
        
        if (i == 0) {
            UILabel *labelDay = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, w, SIZE_ICON_TABBAR)];
            labelDay.tag = TAG_CURRENTDATE_CALENDAR_TABBAR;
            labelDay.userInteractionEnabled = NO;
            labelDay.backgroundColor = [UIColor clearColor];
            labelDay.textAlignment = NSTextAlignmentCenter;
            labelDay.font = [UIFont boldSystemFontOfSize:16];
            labelDay.textColor = [UIColor whiteColor];
            labelDay.text = [self getCurrentDayFromDate:[NSDate date]];
            
            [button addSubview:labelDay];
            [labelDay release];
        }

        [navigationView addSubview:button];
        
        [button setImage:normalStateImage forState:UIControlStateNormal];
        [button setImage:selectStateImage forState:UIControlStateSelected];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i*w, 30, w, 14)];
        label.tag = i + 1;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:SIZE_TEXT_TABBAR];
        label.textColor = COLOR_TEXT_TABBAR;
        label.text = tabNames[i];

        [navigationView addSubview:label];
        [label release];

        tabButtons[i] = button;
    }
}

-(void) createAddMenuView
{
	addMenuView = [[UIView alloc] initWithFrame:CGRectMake(160, 0, 120, 180)];
	addMenuView.hidden = YES;
	addMenuView.backgroundColor = [UIColor clearColor];
	[contentView addSubview:addMenuView];
	[addMenuView release];	
	
	addMenuImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 180)];
	addMenuImageView.alpha = 0.9;
	[addMenuView addSubview:addMenuImageView];
	[addMenuImageView release];
    
	UIImageView *eventImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 25, 20, 20)];
	eventImageView.image = [[ImageManager getInstance] getImageWithName:@"newEvent.png"];
	[addMenuView addSubview:eventImageView];
	[eventImageView release];
	
	UILabel *eventLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 22, 120, 25)];
	eventLabel.text = _eventText;
	eventLabel.textColor = [UIColor whiteColor];
	eventLabel.backgroundColor = [UIColor clearColor];
	eventLabel.font=[UIFont systemFontOfSize:18];
	[addMenuView addSubview:eventLabel];
	[eventLabel release];
	
	UIButton *eventButton=[Common createButton:@"" 
                                    buttonType:UIButtonTypeCustom 
                                         frame:CGRectMake(0, 22, 160, 30)
                                    titleColor:nil
                                        target:self 
                                      selector:@selector(addEvent:) 
                              normalStateImage:nil
                            selectedStateImage:nil];
	eventButton.titleLabel.font=[UIFont systemFontOfSize:18];
	[addMenuView addSubview:eventButton];		
    
	
	UIImageView *taskImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 60, 20, 20)];
	taskImageView.image = [[ImageManager getInstance] getImageWithName:@"newTask.png"];
	[addMenuView addSubview:taskImageView];
	[taskImageView release];
	
	UILabel *taskLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 57, 120, 25)];
	taskLabel.text = _taskText;
	taskLabel.textColor = [UIColor whiteColor];
	taskLabel.backgroundColor = [UIColor clearColor];
	taskLabel.font=[UIFont systemFontOfSize:18];
	[addMenuView addSubview:taskLabel];
	[taskLabel release];	
	
	UIButton *taskButton=[Common createButton:@"" 
                                   buttonType:UIButtonTypeCustom 
                                        frame:CGRectMake(0, 57, 160, 30) 
                                   titleColor:nil
                                       target:self 
                                     selector:@selector(addTask:) 
                             normalStateImage:nil
                           selectedStateImage:nil];
	taskButton.titleLabel.font=[UIFont systemFontOfSize:18];
	
	[addMenuView addSubview:taskButton];
    
	UIImageView *noteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 95, 20, 20)];
	noteImageView.image = [[ImageManager getInstance] getImageWithName:@"newNote.png"];
	[addMenuView addSubview:noteImageView];
	[noteImageView release];
	
	UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 92, 120, 25)];
	noteLabel.text = _noteText;
	noteLabel.textColor = [UIColor whiteColor];
	noteLabel.backgroundColor = [UIColor clearColor];
	noteLabel.font=[UIFont systemFontOfSize:18];
	[addMenuView addSubview:noteLabel];
	[noteLabel release];	
	
	UIButton *noteButton=[Common createButton:@""
                                   buttonType:UIButtonTypeCustom 
                                        frame:CGRectMake(0, 92, 160, 30) 
                                   titleColor:nil 
                                       target:self 
                                     selector:@selector(addNote:) 
                             normalStateImage:nil
                           selectedStateImage:nil];
	noteButton.titleLabel.font=[UIFont systemFontOfSize:18];
	[addMenuView addSubview:noteButton]; 
    
	UIImageView *categoryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 130, 20, 20)];
	categoryImageView.image = [[ImageManager getInstance] getImageWithName:@"newCate.png"];
	[addMenuView addSubview:categoryImageView];
	[categoryImageView release];
	
	UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 127, 120, 25)];
	categoryLabel.text = _projectText;
	categoryLabel.textColor = [UIColor whiteColor];
	categoryLabel.backgroundColor = [UIColor clearColor];
	categoryLabel.font=[UIFont systemFontOfSize:18];
	[addMenuView addSubview:categoryLabel];
	[categoryLabel release];	
	
	UIButton *categoryButton=[Common createButton:@"" 
                                       buttonType:UIButtonTypeCustom 
                                            frame:CGRectMake(0, 127, 160, 30) 
                                       titleColor:nil
                                           target:self 
                                         selector:@selector(addCategory:) 
                                 normalStateImage:nil
                               selectedStateImage:nil];
	categoryButton.titleLabel.font=[UIFont systemFontOfSize:18];
	[addMenuView addSubview:categoryButton]; 
    
    MenuMakerView *menu = [[MenuMakerView alloc] initWithFrame:addMenuView.bounds];
    menu.menuPoint = menu.bounds.size.width-20;
    
    addMenuImageView.image = [Common takeSnapshot:menu size:menu.bounds.size];
    [menu release];
    
}

- (void) createCalendarMenuView
{
    NSString *texts[7] = {
        _todayText,
        _gotoDateText,
        _filterText,
        _syncText,
        _showHideCategoryText,
        _settingTitle,
        _backupText
    };
    
    CGFloat maxWidth = 0;
    
    for (int i=0; i<7; i++)
    {
        CGSize sz = [texts[i] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.0f]}];
        
        if (sz.width > maxWidth)
        {
            maxWidth = sz.width;
        }
    }
    
    maxWidth += 50;
	//menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 290)];
    menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maxWidth, 290)];
	menuView.hidden = YES;
	menuView.backgroundColor = [UIColor clearColor];
	[contentView addSubview:menuView];
	[menuView release];	
	
	//menuImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 290)];
    menuImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, maxWidth, 290)];
	menuImageView.alpha = 0.9;
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
	
	UIButton *todayButton = [Common createButton:@""
                                       buttonType:UIButtonTypeCustom 
                                            frame:CGRectMake(0, 22, menuView.bounds.size.width, 30) 
                                       titleColor:nil 
                                           target:self
                                         selector:@selector(showToday:) 
                                 normalStateImage:nil
                               selectedStateImage:nil];
	todayButton.titleLabel.font = [UIFont systemFontOfSize:18];
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
	
	UIButton *gotoDateButton = [Common createButton:@""
                                       buttonType:UIButtonTypeCustom 
                                            frame:CGRectMake(0, 57, menuView.bounds.size.width, 30) 
                                       titleColor:nil 
                                           target:self 
                                         selector:@selector(showDate:) 
                                 normalStateImage:nil
                               selectedStateImage:nil];
	gotoDateButton.titleLabel.font = [UIFont systemFontOfSize:18];
	[menuView addSubview:gotoDateButton];
	
    UIImageView *separatorImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 85, menuView.bounds.size.width-10, 2)];
	separatorImgView.image = [[ImageManager getInstance] getImageWithName:@"menu_separator.png"];
	[menuView addSubview:separatorImgView];
	[separatorImgView release];    
    
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
	
	UIButton *filterButton = [Common createButton:@""
                                       buttonType:UIButtonTypeCustom 
                                            frame:CGRectMake(0, 92, menuView.bounds.size.width, 30) 
                                       titleColor:nil 
                                           target:self 
                                         selector:@selector(showFilterView:) 
                                 normalStateImage:nil
                               selectedStateImage:nil];
	filterButton.titleLabel.font = [UIFont systemFontOfSize:18];
	[menuView addSubview:filterButton];	
    	    
	UIImageView *syncImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 125, 30, 30)];
	syncImageView.image = [[ImageManager getInstance] getImageWithName:@"menu_sync.png"];
	[menuView addSubview:syncImageView];
	[syncImageView release];
    
	UILabel *syncLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 127, 160, 25)];
	syncLabel.text = _syncText;
	syncLabel.textColor = [UIColor whiteColor];
	syncLabel.backgroundColor = [UIColor clearColor];
	syncLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:syncLabel];
	[syncLabel release];	
	
	UIButton *syncButton=[Common createButton:@"" 
								   buttonType:UIButtonTypeCustom 
										frame:CGRectMake(0, 127, menuView.bounds.size.width, 30) 
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
                                        frame:CGRectMake(0, 162, menuView.bounds.size.width, 30) 
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
										   frame:CGRectMake(0, 197, menuView.bounds.size.width, 30)
									  titleColor:nil
										  target:self 
										selector:@selector(editSetting:) 
								normalStateImage:nil
							  selectedStateImage:nil];
	settingButton.titleLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:settingButton];	
    
	UIImageView *backupImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 230, 30, 30)];
	backupImageView.image = [[ImageManager getInstance] getImageWithName:@"menu_backup.png"];
	[menuView addSubview:backupImageView];
	[backupImageView release];
	
	UILabel *backupLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 232, 120, 25)];
	backupLabel.text = _backupText;
	backupLabel.textColor = [UIColor whiteColor];
	backupLabel.backgroundColor = [UIColor clearColor];
	backupLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:backupLabel];
	[backupLabel release];	
	
	UIButton *backupButton=[Common createButton:@"" 
									  buttonType:UIButtonTypeCustom 
										   frame:CGRectMake(0, 232, menuView.bounds.size.width, 30)
									  titleColor:nil
										  target:self 
										selector:@selector(backup:) 
								normalStateImage:nil
							  selectedStateImage:nil];
	backupButton.titleLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:backupButton];    

}

- (void) createTasksMenuView
{
    NSString *texts[5] = {
        _filterText,
        _syncText,
        _showHideCategoryText,
        _settingTitle,
        _backupText
    };
    
    CGFloat maxWidth = 0;
    
    for (int i=0; i<5; i++)
    {
        CGSize sz = [texts[i] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.0f]}];
        
        if (sz.width > maxWidth)
        {
            maxWidth = sz.width;
        }
    }
    
    maxWidth += 50;
    
	//menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 210)];
    menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maxWidth, 210)];
	menuView.hidden = YES;
	menuView.backgroundColor = [UIColor clearColor];
	[contentView addSubview:menuView];
	[menuView release];	
	
	//menuImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 210)];
    menuImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, maxWidth, 210)];
	menuImageView.alpha = 0.9;
	[menuView addSubview:menuImageView];
	[menuImageView release];
    
	UIImageView *filterImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 30, 30)];
	filterImageView.image = [[ImageManager getInstance] getImageWithName:@"menu_filter.png"];
	[menuView addSubview:filterImageView];
	[filterImageView release];
	
	UILabel *filterLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 22, 160, 25)];
	filterLabel.text = _filterText;
	filterLabel.textColor = [UIColor whiteColor];
	filterLabel.backgroundColor = [UIColor clearColor];
	filterLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:filterLabel];
	[filterLabel release];
	filterLabel.tag = 10000 + TASK_FILTER_GLOBAL;
	
	UIButton *filterButton = [Common createButton:@""
                                       buttonType:UIButtonTypeCustom 
                                            frame:CGRectMake(0, 22, menuView.bounds.size.width, 30)
                                       titleColor:nil 
                                           target:self 
                                         selector:@selector(showFilterView:) 
                                 normalStateImage:nil
                               selectedStateImage:nil];
	filterButton.titleLabel.font = [UIFont systemFontOfSize:18];
	[menuView addSubview:filterButton];	
	
	UIImageView *syncImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 55, 30, 30)];
	syncImageView.image = [[ImageManager getInstance] getImageWithName:@"menu_sync.png"];
	[menuView addSubview:syncImageView];
	[syncImageView release];
    
	UILabel *syncLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 57, 120, 25)];
	syncLabel.text = _syncText;
	syncLabel.textColor = [UIColor whiteColor];
	syncLabel.backgroundColor = [UIColor clearColor];
	syncLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:syncLabel];
	[syncLabel release];	
	
	UIButton *syncButton=[Common createButton:@"" 
								   buttonType:UIButtonTypeCustom 
										frame:CGRectMake(0, 57, menuView.bounds.size.width, 30)
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
                                        frame:CGRectMake(0, 92, menuView.bounds.size.width, 30)
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
										   frame:CGRectMake(0, 127, menuView.bounds.size.width, 30)
									  titleColor:nil
										  target:self 
										selector:@selector(editSetting:) 
								normalStateImage:nil
							  selectedStateImage:nil];
	settingButton.titleLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:settingButton];
    
	UIImageView *backupImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 160, 30, 30)];
	backupImageView.image = [[ImageManager getInstance] getImageWithName:@"menu_backup.png"];
	[menuView addSubview:backupImageView];
	[backupImageView release];
	
	UILabel *backupLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 162, 120, 25)];
	backupLabel.text = _backupText;
	backupLabel.textColor = [UIColor whiteColor];
	backupLabel.backgroundColor = [UIColor clearColor];
	backupLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:backupLabel];
	[backupLabel release];	
	
	UIButton *backupButton=[Common createButton:@"" 
                                     buttonType:UIButtonTypeCustom 
                                          frame:CGRectMake(0, 162, menuView.bounds.size.width, 30)
                                     titleColor:nil
                                         target:self 
                                       selector:@selector(backup:) 
                               normalStateImage:nil
                             selectedStateImage:nil];
	backupButton.titleLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:backupButton];    
    
}

- (void) createCommonMenuView
{
    NSString *texts[5] = {
        _filterText,
        _syncText,
        _showHideCategoryText,
        _settingTitle,
        _backupText
    };
    
    CGFloat maxWidth = 0;
    
    for (int i=0; i<5; i++)
    {
        CGSize sz = [texts[i] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.0f]}];
        
        if (sz.width > maxWidth)
        {
            maxWidth = sz.width;
        }
    }
    
    maxWidth += 50;
    
	//menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 210)];
    menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maxWidth, 210)];
	menuView.hidden = YES;
	menuView.backgroundColor = [UIColor clearColor];
	[contentView addSubview:menuView];
	[menuView release];	
	
	//menuImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 210)];
    menuImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, maxWidth, 210)];
	menuImageView.alpha = 0.9;
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
	
	UIButton *filterButton = [Common createButton:@""
                                       buttonType:UIButtonTypeCustom 
                                            frame:CGRectMake(0, 22, menuView.bounds.size.width, 30) 
                                       titleColor:nil 
                                           target:self 
                                         selector:@selector(showFilterView:) 
                                 normalStateImage:nil
                               selectedStateImage:nil];
	filterButton.titleLabel.font = [UIFont systemFontOfSize:18];
	[menuView addSubview:filterButton];	
	
	UIImageView *syncImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 55, 30, 30)];
	syncImageView.image = [[ImageManager getInstance] getImageWithName:@"menu_sync.png"];
	[menuView addSubview:syncImageView];
	[syncImageView release];
    
	UILabel *syncLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 57, 160, 25)];
	syncLabel.text = _syncText;
	syncLabel.textColor = [UIColor whiteColor];
	syncLabel.backgroundColor = [UIColor clearColor];
	syncLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:syncLabel];
	[syncLabel release];	
	
	UIButton *syncButton=[Common createButton:@"" 
								   buttonType:UIButtonTypeCustom 
										frame:CGRectMake(0, 57, menuView.bounds.size.width, 30) 
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
                                        frame:CGRectMake(0, 92, menuView.bounds.size.width, 30) 
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
										   frame:CGRectMake(0, 127, menuView.bounds.size.width, 30)
									  titleColor:nil
										  target:self 
										selector:@selector(editSetting:) 
								normalStateImage:nil
							  selectedStateImage:nil];
	settingButton.titleLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:settingButton];
    
	UIImageView *backupImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 160, 30, 30)];
	backupImageView.image = [[ImageManager getInstance] getImageWithName:@"menu_backup.png"];
	[menuView addSubview:backupImageView];
	[backupImageView release];
	
	UILabel *backupLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 162, 120, 25)];
	backupLabel.text = _backupText;
	backupLabel.textColor = [UIColor whiteColor];
	backupLabel.backgroundColor = [UIColor clearColor];
	backupLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:backupLabel];
	[backupLabel release];	
	
	UIButton *backupButton=[Common createButton:@"" 
                                     buttonType:UIButtonTypeCustom 
                                          frame:CGRectMake(0, 162, menuView.bounds.size.width, 30)
                                     titleColor:nil
                                         target:self 
                                       selector:@selector(backup:) 
                               normalStateImage:nil
                             selectedStateImage:nil];
	backupButton.titleLabel.font=[UIFont systemFontOfSize:18];
	[menuView addSubview:backupButton];      
}

- (void) createMenuView
{
    if (menuView.superview != nil)
    {
        [menuView removeFromSuperview];
    }
    
    switch (selectedTabButton.tag) 
    {
        case 0:
        {
            [self createCalendarMenuView];
        }
            break;
        case 1:
        case 2:
        {
            [self createTasksMenuView];
            break;
        }
        case 3:
        {
            [self createCommonMenuView];
            break;
        }
    }
    
    MenuMakerView *menu = [[MenuMakerView alloc] initWithFrame:menuImageView.bounds];
    menu.menuPoint = 20;
    
    menuImageView.image = [Common takeSnapshot:menu size:menu.bounds.size];
    
    [menu release];
}

-(void) createProjectOptionView
{
    NSString *texts[4] = {
        _tasksText,
        _eventsText,
        _notesText,
        _anchoredText
    };
    
    CGFloat maxWidth = 0;
    
    for (int i=0; i<4; i++)
    {
        CGSize sz = [texts[i] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.0f]}];
        
        if (sz.width > maxWidth)
        {
            maxWidth = sz.width;
        }
    }
    
    maxWidth += 50;
    
	//optionView = [[UIView alloc] initWithFrame:CGRectMake(160, 0, 140, 180)];
    optionView = [[UIView alloc] initWithFrame:CGRectMake(160, 0, maxWidth, 180)];
	optionView.hidden = YES;
	optionView.backgroundColor = [UIColor clearColor];
	[contentView addSubview:optionView];
	[optionView release];
	
	//optionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 140, 180)];
    optionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, maxWidth, 180)];
	optionImageView.alpha = 0.9;
	[optionView addSubview:optionImageView];
	[optionImageView release];
    
	//UIImageView *taskImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 60, 20, 20)];
    UIImageView *taskImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 25, 20, 20)];
	taskImageView.image = [[ImageManager getInstance] getImageWithName:@"newTask.png"];
	[optionView addSubview:taskImageView];
	[taskImageView release];
	
	//UILabel *taskLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 57, 120, 25)];
    UILabel *taskLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 22, 120, 25)];
	taskLabel.text = _tasksText;
	taskLabel.textColor = [UIColor whiteColor];
	taskLabel.backgroundColor = [UIColor clearColor];
	taskLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:taskLabel];
	[taskLabel release];
	
	UIButton *taskButton=[Common createButton:@""
                                   buttonType:UIButtonTypeCustom
                          //frame:CGRectMake(0, 57, 160, 30)
                                        frame:CGRectMake(0, 22, 160, 30)
                                   titleColor:nil
                                       target:self
                                     selector:@selector(showProjectWithOption:)
                             normalStateImage:nil
                           selectedStateImage:nil];
	taskButton.titleLabel.font=[UIFont systemFontOfSize:18];
	taskButton.tag = 0;
	[optionView addSubview:taskButton];
    
	//UIImageView *eventImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 25, 20, 20)];
    UIImageView *eventImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 60, 20, 20)];
	eventImageView.image = [[ImageManager getInstance] getImageWithName:@"newEvent.png"];
	[optionView addSubview:eventImageView];
	[eventImageView release];
	
	//UILabel *eventLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 22, 120, 25)];
    UILabel *eventLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 57, 120, 25)];
	eventLabel.text = _eventsText;
	eventLabel.textColor = [UIColor whiteColor];
	eventLabel.backgroundColor = [UIColor clearColor];
	eventLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:eventLabel];
	[eventLabel release];
	
	UIButton *eventButton=[Common createButton:@""
                                    buttonType:UIButtonTypeCustom
                                         //frame:CGRectMake(0, 22, 160, 30)
                           frame:CGRectMake(0, 57, 160, 30)
                                    titleColor:nil
                                        target:self
                                      selector:@selector(showProjectWithOption:)
                              normalStateImage:nil
                            selectedStateImage:nil];
	eventButton.titleLabel.font=[UIFont systemFontOfSize:18];
    eventButton.tag = 1;
	[optionView addSubview:eventButton];
    
    UIImageView *noteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 95, 20, 20)];
	noteImageView.image = [[ImageManager getInstance] getImageWithName:@"newNote.png"];
	[optionView addSubview:noteImageView];
	[noteImageView release];
	
	UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 92, 120, 25)];
	noteLabel.text = _notesText;
	noteLabel.textColor = [UIColor whiteColor];
	noteLabel.backgroundColor = [UIColor clearColor];
	noteLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:noteLabel];
	[noteLabel release];
	
	UIButton *noteButton=[Common createButton:@""
                                   buttonType:UIButtonTypeCustom
                                        frame:CGRectMake(0, 92, 160, 30)
                                   titleColor:nil
                                       target:self
                                     selector:@selector(showProjectWithOption:)
                             normalStateImage:nil
                           selectedStateImage:nil];
	noteButton.titleLabel.font=[UIFont systemFontOfSize:18];
    noteButton.tag = 2;
	[optionView addSubview:noteButton];
    
    UIImageView *anchoredImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 130, 20, 20)];
	anchoredImageView.image = [[ImageManager getInstance] getImageWithName:@"filter_atask.png"];
	[optionView addSubview:anchoredImageView];
	[anchoredImageView release];
	
	UILabel *anchoredLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 127, 120, 25)];
	anchoredLabel.text = _anchoredText;
	anchoredLabel.textColor = [UIColor whiteColor];
	anchoredLabel.backgroundColor = [UIColor clearColor];
	anchoredLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:anchoredLabel];
	[anchoredLabel release];
	
	UIButton *anchoredButton=[Common createButton:@""
                                  buttonType:UIButtonTypeCustom
                                       frame:CGRectMake(0, 127, 160, 30)
                                  titleColor:nil
                                      target:self
                                    selector:@selector(showProjectWithOption:)
                            normalStateImage:nil
                          selectedStateImage:nil];
	anchoredButton.titleLabel.font=[UIFont systemFontOfSize:18];
    anchoredButton.tag = 3;
    
	[optionView addSubview:anchoredButton];
    
    MenuMakerView *menu = [[MenuMakerView alloc] initWithFrame:optionView.bounds];
    menu.menuPoint = menu.bounds.size.width/2;
    
    optionImageView.image = [Common takeSnapshot:menu size:menu.bounds.size];
    [menu release];
}


-(void) createTaskOptionView
{
    NSString *texts[7] = {
        _allText,
        _starText,
        _gtdoText,
        _dueText,
        _longText,
        _shortText,
        _doneText
    };
    
    CGFloat maxWidth = 0;
    
    for (int i=0; i<7; i++)
    {
        CGSize sz = [texts[i] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.0f]}];
        
        if (sz.width > maxWidth)
        {
            maxWidth = sz.width;
        }
    }
    
    maxWidth += 50;
    
	//optionView = [[UIView alloc] initWithFrame:CGRectMake(160, 0, 120, 280)];
    optionView = [[UIView alloc] initWithFrame:CGRectMake(160, 0, maxWidth, 280)];
	optionView.hidden = YES;
	optionView.backgroundColor = [UIColor clearColor];
	[contentView addSubview:optionView];
	[optionView release];
	
	//optionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 280)];
    optionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, maxWidth, 280)];
	optionImageView.alpha = 0.9;
	[optionView addSubview:optionImageView];
	[optionImageView release];
    
    UIImageView *allImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 25, 20, 20)];
	allImageView.image = [[ImageManager getInstance] getImageWithName:@"filter_all.png"];
	[optionView addSubview:allImageView];
	[allImageView release];
	
    UILabel *allLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 22, 120, 25)];
	allLabel.text = _allText;
	allLabel.textColor = [UIColor whiteColor];
	allLabel.backgroundColor = [UIColor clearColor];
	allLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:allLabel];
	[allLabel release];
	
	UIButton *allButton=[Common createButton:@""
                                   buttonType:UIButtonTypeCustom
                                        frame:CGRectMake(0, 22, 160, 30)
                                   titleColor:nil
                                       target:self
                                     selector:@selector(showTaskWithOption:)
                             normalStateImage:nil
                           selectedStateImage:nil];
	allButton.titleLabel.font=[UIFont systemFontOfSize:18];
	allButton.tag = TASK_FILTER_ALL;
	[optionView addSubview:allButton];
    
    UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 60, 20, 20)];
	starImageView.image = [[ImageManager getInstance] getImageWithName:@"filter_star.png"];
	[optionView addSubview:starImageView];
	[starImageView release];
	
    UILabel *starLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 57, 120, 25)];
	starLabel.text = _starText;
	starLabel.textColor = [UIColor whiteColor];
	starLabel.backgroundColor = [UIColor clearColor];
	starLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:starLabel];
	[starLabel release];
	
	UIButton *starButton=[Common createButton:@""
                                    buttonType:UIButtonTypeCustom
                                         frame:CGRectMake(0, 57, 160, 30)
                                    titleColor:nil
                                        target:self
                                      selector:@selector(showTaskWithOption:)
                              normalStateImage:nil
                            selectedStateImage:nil];
	starButton.titleLabel.font=[UIFont systemFontOfSize:18];
    starButton.tag = TASK_FILTER_STAR;
	[optionView addSubview:starButton];
    
    UIImageView *gtdImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 95, 20, 20)];
	gtdImageView.image = [[ImageManager getInstance] getImageWithName:@"filter_gtd.png"];
	[optionView addSubview:gtdImageView];
	[gtdImageView release];
	
	UILabel *gtdLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 92, 120, 25)];
	gtdLabel.text = _gtdoText;
	gtdLabel.textColor = [UIColor whiteColor];
	gtdLabel.backgroundColor = [UIColor clearColor];
	gtdLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:gtdLabel];
	[gtdLabel release];
	
	UIButton *gtdButton=[Common createButton:@""
                                   buttonType:UIButtonTypeCustom
                                        frame:CGRectMake(0, 92, 160, 30)
                                   titleColor:nil
                                       target:self
                                     selector:@selector(showTaskWithOption:)
                             normalStateImage:nil
                           selectedStateImage:nil];
	gtdButton.titleLabel.font=[UIFont systemFontOfSize:18];
    gtdButton.tag = TASK_FILTER_TOP;
	[optionView addSubview:gtdButton];
    
    UIImageView *dueImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 130, 20, 20)];
	dueImageView.image = [[ImageManager getInstance] getImageWithName:@"filter_due.png"];
	[optionView addSubview:dueImageView];
	[dueImageView release];
	
	UILabel *dueLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 127, 120, 25)];
	dueLabel.text = _dueText;
	dueLabel.textColor = [UIColor whiteColor];
	dueLabel.backgroundColor = [UIColor clearColor];
	dueLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:dueLabel];
	[dueLabel release];
	
	UIButton *dueButton=[Common createButton:@""
                                  buttonType:UIButtonTypeCustom
                                       frame:CGRectMake(0, 127, 160, 30)
                                  titleColor:nil
                                      target:self
                                    selector:@selector(showTaskWithOption:)
                            normalStateImage:nil
                          selectedStateImage:nil];
	dueButton.titleLabel.font=[UIFont systemFontOfSize:18];
    dueButton.tag = TASK_FILTER_DUE;
	[optionView addSubview:dueButton];
  
    UIImageView *longImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 165, 20, 20)];
	longImageView.image = [[ImageManager getInstance] getImageWithName:@"filter_long.png"];
	[optionView addSubview:longImageView];
	[longImageView release];
	
	UILabel *longLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 162, 120, 25)];
	longLabel.text = _longText;
	longLabel.textColor = [UIColor whiteColor];
	longLabel.backgroundColor = [UIColor clearColor];
	longLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:longLabel];
	[longLabel release];
	
	UIButton *longButton=[Common createButton:@""
                                    buttonType:UIButtonTypeCustom
                                         frame:CGRectMake(0, 162, 160, 30)
                                    titleColor:nil
                                        target:self
                                      selector:@selector(showTaskWithOption:)
                              normalStateImage:nil
                            selectedStateImage:nil];
	longButton.titleLabel.font=[UIFont systemFontOfSize:18];
    longButton.tag = TASK_FILTER_LONG;
	[optionView addSubview:longButton];
    
    UIImageView *shortImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 200, 20, 20)];
	shortImageView.image = [[ImageManager getInstance] getImageWithName:@"filter_short.png"];
	[optionView addSubview:shortImageView];
	[shortImageView release];
	
	UILabel *shortLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 197, 120, 25)];
	shortLabel.text = _shortText;
	shortLabel.textColor = [UIColor whiteColor];
	shortLabel.backgroundColor = [UIColor clearColor];
	shortLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:shortLabel];
	[shortLabel release];
	
	UIButton *shortButton=[Common createButton:@""
                                   buttonType:UIButtonTypeCustom
                                        frame:CGRectMake(0, 197, 160, 30)
                                   titleColor:nil
                                       target:self
                                     selector:@selector(showTaskWithOption:)
                             normalStateImage:nil
                           selectedStateImage:nil];
	shortButton.titleLabel.font=[UIFont systemFontOfSize:18];
    shortButton.tag = TASK_FILTER_SHORT;
	[optionView addSubview:shortButton];
    
    UIImageView *doneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 235, 20, 20)];
	doneImageView.image = [[ImageManager getInstance] getImageWithName:@"filter_done.png"];
	[optionView addSubview:doneImageView];
	[doneImageView release];
	
	UILabel *doneLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 232, 120, 25)];
	doneLabel.text = _doneText;
	doneLabel.textColor = [UIColor whiteColor];
	doneLabel.backgroundColor = [UIColor clearColor];
	doneLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:doneLabel];
	[doneLabel release];
	
	UIButton *doneButton=[Common createButton:@""
                                   buttonType:UIButtonTypeCustom
                                        frame:CGRectMake(0, 232, 160, 30)
                                   titleColor:nil
                                       target:self
                                     selector:@selector(showTaskWithOption:)
                             normalStateImage:nil
                           selectedStateImage:nil];
	doneButton.titleLabel.font=[UIFont systemFontOfSize:18];
    doneButton.tag = TASK_FILTER_DONE;
	[optionView addSubview:doneButton];
    
    MenuMakerView *menu = [[MenuMakerView alloc] initWithFrame:optionView.bounds];
    menu.menuPoint = menu.bounds.size.width/2;
    
    optionImageView.image = [Common takeSnapshot:menu size:menu.bounds.size];
    
    [menu release];
}


-(void) createNoteOptionView
{
    NSString *texts[7] = {
        _allText,
        _currentText,
        _thisWeekText
    };
    
    CGFloat maxWidth = 0;
    
    for (int i=0; i<7; i++)
    {
        CGSize sz = [texts[i] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.0f]}];
        
        if (sz.width > maxWidth)
        {
            maxWidth = sz.width;
        }
    }
    
    maxWidth += 50;
    
	//optionView = [[UIView alloc] initWithFrame:CGRectMake(160, 0, 140, 140)];
    optionView = [[UIView alloc] initWithFrame:CGRectMake(160, 0, maxWidth, 140)];
	optionView.hidden = YES;
	optionView.backgroundColor = [UIColor clearColor];
	[contentView addSubview:optionView];
	[optionView release];
	
	//optionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 140, 140)];
    optionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, maxWidth, 140)];
	optionImageView.alpha = 0.9;
	[optionView addSubview:optionImageView];
	[optionImageView release];
    
    UIImageView *allImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 25, 20, 20)];
	allImageView.image = [[ImageManager getInstance] getImageWithName:@"filter_all.png"];
	[optionView addSubview:allImageView];
	[allImageView release];
	
    UILabel *allLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 22, 120, 25)];
	allLabel.text = _allText;
	allLabel.textColor = [UIColor whiteColor];
	allLabel.backgroundColor = [UIColor clearColor];
	allLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:allLabel];
	[allLabel release];
	
	UIButton *allButton=[Common createButton:@""
                                  buttonType:UIButtonTypeCustom
                                       frame:CGRectMake(0, 22, 160, 30)
                                  titleColor:nil
                                      target:self
                                    selector:@selector(showNoteWithOption:)
                            normalStateImage:nil
                          selectedStateImage:nil];
	allButton.titleLabel.font=[UIFont systemFontOfSize:18];
	allButton.tag = NOTE_FILTER_ALL;
	[optionView addSubview:allButton];
    
    UIImageView *todayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 60, 20, 20)];
	todayImageView.image = [[ImageManager getInstance] getImageWithName:@"filter_today.png"];
	[optionView addSubview:todayImageView];
	[todayImageView release];
	
    UILabel *todayLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 57, 120, 25)];
	//todayLabel.text = _todayText;
    todayLabel.text = _currentText;
	todayLabel.textColor = [UIColor whiteColor];
	todayLabel.backgroundColor = [UIColor clearColor];
	todayLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:todayLabel];
	[todayLabel release];
	
	UIButton *todayButton=[Common createButton:@""
                                   buttonType:UIButtonTypeCustom
                                        frame:CGRectMake(0, 57, 160, 30)
                                   titleColor:nil
                                       target:self
                                     selector:@selector(showNoteWithOption:)
                             normalStateImage:nil
                           selectedStateImage:nil];
	todayButton.titleLabel.font=[UIFont systemFontOfSize:18];
    todayButton.tag = NOTE_FILTER_CURRENT;
	[optionView addSubview:todayButton];
    
    UIImageView *weekImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 95, 20, 20)];
	weekImageView.image = [[ImageManager getInstance] getImageWithName:@"filter_thisweek.png"];
	[optionView addSubview:weekImageView];
	[weekImageView release];
	
    UILabel *weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 92, 120, 25)];
    weekLabel.text = _thisWeekText;
	weekLabel.textColor = [UIColor whiteColor];
	weekLabel.backgroundColor = [UIColor clearColor];
	weekLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:weekLabel];
	[weekLabel release];
	
	UIButton *weekButton=[Common createButton:@""
                                    buttonType:UIButtonTypeCustom
                                         frame:CGRectMake(0, 92, 160, 30)
                                    titleColor:nil
                                        target:self
                                      selector:@selector(showNoteWithOption:)
                              normalStateImage:nil
                            selectedStateImage:nil];
	weekButton.titleLabel.font=[UIFont systemFontOfSize:18];
    weekButton.tag = NOTE_FILTER_WEEK;
	[optionView addSubview:weekButton];
    
    MenuMakerView *menu = [[MenuMakerView alloc] initWithFrame:optionView.bounds];
    menu.menuPoint = menu.bounds.size.width/2;
    
    optionImageView.image = [Common takeSnapshot:menu size:menu.bounds.size];
    [menu release];
}

-(void) createNotifOptionView
{
    DBManager *dbm = [DBManager getInstance];
    
    NSString *texts[2] = {
        _conversationsText,
        _locationsText
    };
    
    CGFloat maxWidth = 0;
    
    for (int i=0; i<2; i++)
    {
        CGSize sz = [texts[i] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.0f]}];
        
        if (sz.width > maxWidth)
        {
            maxWidth = sz.width;
        }
    }
    
    maxWidth += 90;
    
    optionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maxWidth, 100)];
    //optionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maxWidth, 60)];
	optionView.hidden = YES;
	optionView.backgroundColor = [UIColor clearColor];
	[contentView addSubview:optionView];
	[optionView release];
	
    optionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, maxWidth, 100)];
    //optionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, maxWidth, 60)];
	optionImageView.alpha = 0.9;
	[optionView addSubview:optionImageView];
	[optionImageView release];
    
    //UIImageView *locationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 53, 40, 40)];
    UIImageView *locationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 18, 40, 40)];
	locationImageView.image = [[ImageManager getInstance] getImageWithName:@"bar_location.png"];
	[optionView addSubview:locationImageView];
	[locationImageView release];
	
    //UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 57, 120, 25)];
    UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 22, 120, 25)];
	locationLabel.text = _locationsText;
	locationLabel.textColor = [UIColor whiteColor];
	locationLabel.backgroundColor = [UIColor clearColor];
	locationLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:locationLabel];
	[locationLabel release];
	
	UIButton *locationButton=[Common createButton:@""
                                       buttonType:UIButtonTypeCustom
                                            //frame:CGRectMake(0, 57, 160, 30)
                              frame:CGRectMake(0, 22, 160, 30)
                                       titleColor:nil
                                           target:self
                                         selector:@selector(showNotifWithOptions:)
                                 normalStateImage:nil
                               selectedStateImage:nil];
    locationButton.tag = 1;
	[optionView addSubview:locationButton];
    
    NSInteger count = [dbm countTasksAtCurrentLocation];
    
    if (count > 0)
    {
        //UILabel *locationBadgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(maxWidth - 40, 60, 30, 20)];
        UILabel *locationBadgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(maxWidth - 40, 25, 30, 20)];
        locationBadgeLabel.font = [UIFont boldSystemFontOfSize:12];
        locationBadgeLabel.textColor = [UIColor whiteColor];
        locationBadgeLabel.textAlignment = NSTextAlignmentCenter;
        locationBadgeLabel.tag = 10000;
        locationBadgeLabel.layer.cornerRadius = 3;
        locationBadgeLabel.backgroundColor = [Colors redButton];
        
        locationBadgeLabel.text = [NSString stringWithFormat:@"%d", count];
        
        [optionView addSubview:locationBadgeLabel];
        [locationBadgeLabel release];
    }
    
    //UIImageView *commentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 18, 40, 40)];
    UIImageView *commentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 53, 40, 40)];
	commentImageView.image = [[ImageManager getInstance] getImageWithName:@"bar_comments.png"];
	[optionView addSubview:commentImageView];
	[commentImageView release];
	
    //UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 22, 120, 25)];
    UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 57, 120, 25)];
	commentLabel.text = _conversationsText;
	commentLabel.textColor = [UIColor whiteColor];
	commentLabel.backgroundColor = [UIColor clearColor];
	commentLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:commentLabel];
	[commentLabel release];
	
	UIButton *commentButton=[Common createButton:@""
                                  buttonType:UIButtonTypeCustom
                                       //frame:CGRectMake(0, 22, 160, 30)
                             frame:CGRectMake(0, 57, 160, 30)
                                  titleColor:nil
                                      target:self
                                    selector:@selector(showNotifWithOptions:)
                            normalStateImage:nil
                          selectedStateImage:nil];

	commentButton.tag = 0;
	[optionView addSubview:commentButton];
    
    count = [dbm countUnreadComments];
    
    if (count > 0)
    {
        //UILabel *commentBadgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(maxWidth - 40, 25, 30, 20)];
        UILabel *commentBadgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(maxWidth - 40, 60, 30, 20)];
        commentBadgeLabel.font = [UIFont boldSystemFontOfSize:12];
        commentBadgeLabel.textColor = [UIColor whiteColor];
        commentBadgeLabel.textAlignment = NSTextAlignmentCenter;
        commentBadgeLabel.tag = 10000;
        commentBadgeLabel.layer.cornerRadius = 3;
        commentBadgeLabel.backgroundColor = [Colors redButton];
        
        commentBadgeLabel.text = [NSString stringWithFormat:@"%d", count];
        
        [optionView addSubview:commentBadgeLabel];
        [commentBadgeLabel release];
    }
    
    MenuMakerView *menu = [[MenuMakerView alloc] initWithFrame:optionView.bounds];
    menu.menuPoint = menu.bounds.size.width/2 + 80;
    
    optionImageView.image = [Common takeSnapshot:menu size:menu.bounds.size];
    [menu release];
}

- (void)loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    //contentView = [[ContentView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
    contentView = [[ContentView alloc] initWithFrame:frm];
    
    self.view = contentView;
    [contentView release];

    //moduleView = [[ContentView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
    moduleView = [[ContentView alloc] initWithFrame:contentView.bounds];

    [contentView addSubview:moduleView];
    [moduleView release];
    
	//int nRows = [[Settings getInstance] weekPlannerRows];
    int nRows = 1;
    
	//miniMonthView = [[MiniMonthView alloc] initWithFrame:CGRectMake(0, 0, contentView.frame.size.width, 40*nRows + MINI_MONTH_HEADER_HEIGHT + 6)];
    miniMonthView = [[MiniMonthView alloc] initWithFrame:CGRectMake(0, 0, contentView.frame.size.width, 40*nRows + MINI_MONTH_HEADER_HEIGHT)];
	
	[contentView addSubview:miniMonthView];
	[miniMonthView release];
    
 	filterView = [[FilterView alloc] initWithOrientation:0];
	[contentView addSubview:filterView];
	[filterView release];  
    
    dateJumpView = [[DateJumpView alloc] initWithFrame:CGRectMake(0, frm.size.height - [Common getKeyboardHeight] - 40, frm.size.width, [Common getKeyboardHeight] + 40)];
    
	[contentView addSubview:dateJumpView];
	[dateJumpView release];
    
    previewPane = [[LinkPreviewPane alloc] initWithFrame:CGRectMake(0, frm.size.height - 80, frm.size.width, 80)];
                   
    [contentView addSubview:previewPane];
    [previewPane release];
    
    filterIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(260, 15, 15, 15)];
    filterIndicator.image = [UIImage imageNamed:@"filterWKV.png"];
    filterIndicator.hidden = YES;
    
    [self createMultiEditBar];
    
    [self createAddMenuView];

    [self createNavigationView];
    
    //[self createHintView];

    [self hideMiniMonth];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    filterIndicator.hidden = ([[TaskManager getInstance] filterData] == nil);
    arrowDownImgView.hidden = NO;
    
    //[self changeSkin];
    
    if (firstTimeLoad)
    {
        /*
        for (int i=0; i<TAB_NUM-1; i++)
        {
            [viewCtrlers[i] viewWillAppear:animated];
        }*/
    }
    
    if (topButton != nil)
    {
        topButton.hidden = NO;
    }    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    filterIndicator.hidden = YES;
    arrowDownImgView.hidden = YES;
    
    if (topButton != nil)
    {
        topButton.hidden = YES;
    }
    
    [self deselect];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    previewPane.frame = CGRectMake(0, contentView.bounds.size.height - 80, contentView.bounds.size.width, 80);
    
    Settings *settings = [Settings getInstance];
    
    if (settings.guruHint && firstTimeLoad)
    {
        [self showGuruIsWhatsNew:NO];
    } else if (settings.whatsNewHint) {
        [self showGuruIsWhatsNew:YES];
        settings.whatsNewHint = NO;
    }
    
    firstTimeLoad = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    firstTimeLoad = YES;
    
    [self resetMovableContentView];
    
    //[self performSelector:@selector(tab:) withObject:tabButtons[0] afterDelay:0];
    
    [self changeOrientation:self.interfaceOrientation];
    
    NSInteger sizeArrowDownIcon = 5;
    NSInteger orginX = (contentView.frame.size.width - sizeArrowDownIcon)/2;
    arrowDownImgView = [[UIImageView alloc] initWithFrame:CGRectMake(orginX, 33, sizeArrowDownIcon, sizeArrowDownIcon)];
    arrowDownImgView.image = [FontManager flowasticImageWithIconName:@"arrow-down" andSize:sizeArrowDownIcon iconColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar addSubview:arrowDownImgView];
    [arrowDownImgView release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL) checkAlertIsShowing
{
    for( UIView* subview in [UIApplication sharedApplication].keyWindow.subviews ) {
        if( [subview isKindOfClass:[UIAlertView class]] ) {
            ////NSLog( @"Alert is showing" );
            
            return YES;
        }
    }
    
    return NO;
}

- (void) showGuruIsWhatsNew:(BOOL)whatsNew
{
    GuruViewController *ctrler = [[GuruViewController alloc] init];
    ctrler.whatsNew = whatsNew;
    
    [self presentViewController:ctrler animated:YES completion:nil];
    
    [ctrler release];
}

- (void) showLandscapeView
{
    [self hideMiniMonth];
    
    if (filterView.userInteractionEnabled == YES)
	{
		[filterView popDownView];
	}    
    
    if (self.activeViewCtrler != nil)
    {
        [self.activeViewCtrler.view removeFromSuperview];
    }
    
    
    WeekViewController *ctrler = [[WeekViewController alloc] init];
    
    self.activeViewCtrler = ctrler;
    
    [ctrler release];
    
    if (self.activeViewCtrler != nil)
    {
        [moduleView addSubview:self.activeViewCtrler.view];
    }
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.4];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [[moduleView layer] addAnimation:animation forKey:@"slideTransition"];
    
    [self refreshTopBar];
}

- (void) showPortraitView
{
    
    NSInteger index = selectedTabButton.tag;
    
    selectedTabButton = nil;
    
    [self tab:tabButtons[index]];
}

- (void) changeOrientation:(UIInterfaceOrientation) orientation
{
    CGSize sz = [Common getScreenSize];
    sz.height += 20 + 44;
    
    CGRect frm = CGRectZero;
    
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        frm.size.height = sz.width;
        frm.size.width = sz.height;
    }
    else
    {
        frm.size = sz;
    }
    
    frm.size.height -= 20 + 44;
    
    contentView.frame = frm;
    moduleView.frame = contentView.bounds;
    
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        Settings *settings = [Settings getInstance];
        
        if (settings.landscapeModeEnable)
        {
            [self deselect];
            
            [self showLandscapeView];
        }
    }
    else
    {
        [self showPortraitView];
    }
}


-(NSUInteger)supportedInterfaceOrientations
{
    Settings *settings = [Settings getInstance];
    
    NSInteger mask = UIInterfaceOrientationMaskAll;
    
    if (!settings.landscapeModeEnable || [self checkAlertIsShowing])
    {
        mask = UIInterfaceOrientationMaskPortrait;
    }
    
    return mask;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    [_appDelegate dismissAllAlertViews];
    
    [self changeOrientation:toInterfaceOrientation];
}


#pragma mark Notification

- (void)detectTouch:(NSNotification *)notification
{
    Settings *settings = [Settings getInstance];
    
    if (settings.tabBarAutoHide)
    {
        [UIView animateWithDuration:2.0
                              delay:0.0
                            options: UIViewAnimationCurveLinear
                         animations:^{
                             navigationView.hidden = YES;
                         }
                         completion:^(BOOL finished){
                         }];        
    }
}

- (void)detectIdle:(NSNotification *)notification
{
    Settings *settings = [Settings getInstance];
    
    if (settings.tabBarAutoHide)
    {
        [UIView animateWithDuration:2.0
                              delay:0.0
                            options: UIViewAnimationCurveLinear
                         animations:^{
                             navigationView.hidden = NO;
                         }
                         completion:^(BOOL finished){
                         }];        
    }
}

- (void)tabBarModeChanged:(NSNotification *)notification
{
    Settings *settings = [Settings getInstance];
    
    if (!settings.tabBarAutoHide)
    {
        navigationView.hidden = NO;
    }
}

- (void)calendarDayReady:(NSNotification *)notification {
    if (selectedTabButton.tag == 0) {
        NSDate *today = [[TaskManager getInstance] today];
        self.navigationItem.title = [Common getCalendarDateString_EEEMMMDD:(today == nil?[NSDate date]:today)];
    }
}

- (void)appBusy:(NSNotification *)notification
{
    if (self.navigationItem.rightBarButtonItem != nil)
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)appNoBusy:(NSNotification *)notification
{
    if (self.navigationItem.rightBarButtonItem != nil)
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void)receiveNewComments:(NSNotification *)notification
{
    NSMutableArray *list = [notification.userInfo objectForKey:@"CommentList"];
    
    printf("\n\n New Comment List\n");
    
    /*
     for (Comment *comment in list)
     {
     printf("[%s - %s] %s\n", [comment.firstName UTF8String], [comment.lastName UTF8String], [comment.content UTF8String]);
     }*/
    
    UIApplication *app = [UIApplication sharedApplication];
    
    if (list.count > 0 && app.applicationState == UIApplicationStateBackground)
    {
        CommentManager *cmdM = [CommentManager getInstance];
        [cmdM notify:list];
    }
}

- (void)refreshUnreadComments:(NSNotification *)notification
{
    DBManager *dbm = [DBManager getInstance];
    
    NSInteger count = [dbm countUnreadComments];
    
    if (count > 0)
    {
        dispatch_async(dispatch_get_main_queue(),^ {
            [self showNotifBadge];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(),^ {
            [self checkForHidingNotifBadge:YES];
        });
    }
    
}

- (void)checkForHidingNotifBadge: (BOOL)zeroComment
{
    NSInteger count = 0;
    
    DBManager *dbm = [DBManager getInstance];
    if (zeroComment) {
        count = [dbm countTasksAtCurrentLocation];
    } else {
        count = [dbm countUnreadComments];
    }
    
    if (count <= 0) {
        [self refreshTopBar];
    }
}

- (void)refreshGeoTaskLocation:(NSNotification *)notification
{
    DBManager *dbm = [DBManager getInstance];
    NSInteger count = [dbm countTasksAtCurrentLocation];
    if (count > 0)
    {
        dispatch_async(dispatch_get_main_queue(),^ {
            [self showNotifBadge];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(),^ {
            [self checkForHidingNotifBadge:NO];
        });
    }
}

#pragma mark - Refresh color for Text tabbar
- (void)refreshColorForTextTabbarAtIndex:(NSInteger)index andIsSelected:(BOOL)isSelected {
    
    // Reset text color
    for (id view in navigationView.subviews) {
        if (view && [view isKindOfClass:[UILabel class]]) {
            UILabel *textLabel = (UILabel *)view;
            textLabel.textColor = COLOR_TEXT_TABBAR;
        }
    }
    
    // Set color for text at bar button selected
    id object = [navigationView viewWithTag:index];
    if (object && [object isKindOfClass:[UILabel class]]) {
        UILabel *textLabel = (UILabel *)object;
        textLabel.textColor = isSelected ? COLOR_TEXT_TABBAR_SEL : COLOR_TEXT_TABBAR;
    }
}

- (NSString *)getCurrentDayFromDate:(NSDate *)date {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    
    return [NSString stringWithFormat:@"%ld", components.day];
}

- (void)refreshDayOnCalendarTabbarWithDate:(NSDate *)date {
    if (date) {
        if (navigationView && navigationView.subviews.count > 1) {
            id calendarButton = [navigationView.subviews objectAtIndex:1];
            if (calendarButton && [calendarButton isKindOfClass:[UIButton class]]) {
                UIButton *calendarBtn = (UIButton *)calendarButton;
                if (calendarBtn && calendarBtn.subviews.count > 0) {
                    id dayLabel = [calendarBtn viewWithTag:TAG_CURRENTDATE_CALENDAR_TABBAR];
                    if (dayLabel && [dayLabel isKindOfClass:[UILabel class]]) {
                        UILabel *dayLabelUpdate = (UILabel *)dayLabel;
                        dayLabelUpdate.text = [self getCurrentDayFromDate:date];
                    }
                }
            }
        }
    }
}

#pragma mark - Button Cancel Edit Mode
- (void)cancelEditMode:(id)sender {
    [[[AbstractActionViewController getInstance] getActiveModule] cancelMultiEdit];
}

- (NSInteger)countAllObjectSelectedInEditMode {
    NSInteger countListSelectedItems = 0;
    if ([self.activeViewCtrler isKindOfClass:[CategoryViewController class]] ||
        [self.activeViewCtrler isKindOfClass:[SmartListViewController class]] ||
        [self.activeViewCtrler isKindOfClass:[NoteViewController class]]) {
        countListSelectedItems = [self.activeViewCtrler getMultiEditList].count;
    }
    
    return countListSelectedItems;
}

@end
