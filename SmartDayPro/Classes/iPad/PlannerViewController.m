//
//  PlannerViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 1/18/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PlannerViewController.h"

#import "Common.h"
#import "Task.h"

#import "BusyController.h"

#import "ContentView.h"
#import "TaskView.h"
#import "PlannerMonthView.h"

#import "SmartListViewController.h"
#import "PlannerView.h"
#import "PlannerBottomDayCal.h"

#import "PreviewViewController.h"
#import "SDNavigationController.h"

#import "TaskDetailTableViewController.h"
#import "NoteDetailTableViewController.h"
#import "AbstractSDViewController.h"

PlannerViewController *_plannerViewCtrler = nil;

extern AbstractSDViewController *_abstractViewCtrler;

@interface PlannerViewController ()

@end

@implementation PlannerViewController

@synthesize plannerView;
@synthesize plannerBottomDayCal;

@synthesize popoverCtrler;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) init
{
    if (self = [super init])
    {
        smartListViewCtrler = [[SmartListViewController alloc] init4Planner];
        //plannerView = [[PlannerView alloc] initWithFrame:CGRectMake(0, 0, 300, 100)];
        
        activeView = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustSubFrame:) name:@"NotificationAdjustPlannerMiniMonthHeight" object:nil];
    }
    
    return self;
}

- (void) dealloc
{
    self.popoverCtrler = nil;
    
    [smartListViewCtrler release];
    [plannerView release];
    [plannerBottomDayCal release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (SmartListViewController *) getSmartListViewController
{
    return smartListViewCtrler;
}

- (CalendarViewController *) getCalendarViewController
{
    return [_abstractViewCtrler getCalendarViewController];
}

- (NoteViewController *) getNoteViewController
{
    return [_abstractViewCtrler getNoteViewController];
}

- (CategoryViewController *) getCategoryViewController
{
    return [_abstractViewCtrler getCategoryViewController];
}

- (FocusView *) getFocusView
{
    return [_abstractViewCtrler getFocusView];
}

- (MiniMonthView *) getMiniMonth
{
    return [_abstractViewCtrler getMiniMonth];
}

- (AbstractMonthCalendarView *) getMonthCalendarView
{
    return self.plannerView.monthView;
}

- (void) hidePopover
{
	if (self.popoverCtrler != nil && [self.popoverCtrler isPopoverVisible])
	{
		[self.popoverCtrler dismissPopoverAnimated:NO];
	}	
}

- (void) enableActions:(BOOL)enable onView:(TaskView *)view
{
    [super enableActions:enable onView:view];
    
    PreviewViewController *ctrler = [[PreviewViewController alloc] init];
    ctrler.item = view.task;
    
    SDNavigationController *navController = [[SDNavigationController alloc] initWithRootViewController:ctrler];
    [ctrler release];
    
    self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
    
    [navController release];
    
    CGRect frm = [view.superview convertRect:view.frame toView:contentView];
    
    [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:view.task.listSource == SOURCE_CALENDAR || view.task.listSource == SOURCE_FOCUS?UIPopoverArrowDirectionLeft:UIPopoverArrowDirectionRight animated:YES];
}

- (void) editItem:(Task *)item inView:(UIView *)inView
{
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
        SDNavigationController *navController = [[SDNavigationController alloc] initWithRootViewController:editCtrler];
        [editCtrler release];
        
        self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
        
        [navController release];
        
        CGRect frm = [inView.superview convertRect:inView.frame toView:contentView];
        
        [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:item.listSource == SOURCE_PLANNER_CALENDAR?UIPopoverArrowDirectionAny:(item.listSource == SOURCE_CALENDAR || item.listSource == SOURCE_FOCUS?UIPopoverArrowDirectionLeft:UIPopoverArrowDirectionRight) animated:YES];
        
        //[self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

#pragma mark Views

- (void) loadView
{
    CGSize sz = [Common getScreenSize];
    
    CGRect frm = CGRectZero;
    frm.size.width = sz.height + 20 + 44;
    //frm.size.height = sz.width - 20 - 44;
    frm.size.height = sz.width - 20;
    
    contentView = [[ContentView alloc] initWithFrame:frm];
    //contentView.backgroundColor = [UIColor magentaColor];
    
    self.view = contentView;
    
    [contentView release];
    
    [contentView addSubview:smartListViewCtrler.view];
    
    frm.origin.x = frm.size.width - 234;
    frm.size.width = 234;
    
    //[smartListViewCtrler changeFrame:frm];
    
    // planer view in left
    //plannerView
    //plannerView = [[PlannerView alloc] initWithFrame:CGRectMake(8, 0, contentView.frame.size.width - smartListViewCtrler.contentView.frame.size.width, frm.size.height)];
    //[contentView addSubview:plannerView];

    plannerView = [[PlannerView alloc] initWithFrame:CGRectMake(8, 8, 750, 206)];
    [contentView addSubview:plannerView];
    
    CGRect tmp = CGRectMake(plannerView.frame.origin.x + plannerView.frame.size.width + 8, 8, contentView.frame.size.width - (plannerView.frame.origin.x + plannerView.frame.size.width + 8) - 8, frm.size.height - 16);
    
    [smartListViewCtrler changeFrame:tmp];
    
    // bottom day cal
    plannerBottomDayCal = [[PlannerBottomDayCal alloc] initWithFrame:CGRectMake(8,plannerView.frame.origin.y + plannerView.frame.size.height + 8, 750, contentView.frame.size.height - (plannerView.frame.origin.y + plannerView.frame.size.height) - 16)];
    [contentView addSubview:plannerBottomDayCal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [smartListViewCtrler setMovableContentView:self.contentView];
    
    [smartListViewCtrler refreshLayout];
    
    [plannerBottomDayCal setMovableContentView:self.contentView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _plannerViewCtrler = self;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _plannerViewCtrler = nil;
}

- (void) adjustSubFrame: (NSNotification*) notification {
    
    CGRect frm = CGRectMake(8,plannerView.frame.origin.y + plannerView.frame.size.height + 8, 750, contentView.frame.size.height - (plannerView.frame.origin.y + plannerView.frame.size.height) - 16);
    plannerBottomDayCal.frame = frm;
    
    // change date
    NSDictionary *userInfo = [notification userInfo];
    NSDate *firstDate = [userInfo objectForKey:@"firstDate"];
    
    [plannerBottomDayCal changeWeek:firstDate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
