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

#import "TaskManager.h"
#import "ImageManager.h"
#import "BusyController.h"
#import "MenuMakerView.h"

#import "ContentView.h"
#import "TaskView.h"
#import "PlannerMonthView.h"
#import "MiniMonthView.h"
#import "MonthlyCalendarView.h"

#import "SmartListViewController.h"
#import "PlannerView.h"
#import "PlannerBottomDayCal.h"

#import "PreviewViewController.h"
#import "SDNavigationController.h"

#import "TaskDetailTableViewController.h"
#import "NoteDetailTableViewController.h"
#import "AbstractSDViewController.h"

#import "SmartListLayoutController.h"
#import "YearViewController.h"

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
        //smartListViewCtrler = [[SmartListViewController alloc] init4Planner];
        //smartListViewCtrler = [[SmartListViewController alloc] init];
        //[smartListViewCtrler resetMovableController:YES];
        
        activeView = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustSubFrame:) name:@"NotificationAdjustPlannerMiniMonthHeight" object:nil];
    }
    
    return self;
}

- (void) dealloc
{
    self.popoverCtrler = nil;
    
    //[smartListViewCtrler release];
    [plannerView release];
    [plannerBottomDayCal release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (SmartListViewController *) getSmartListViewController
{
    //return smartListViewCtrler;
    return [_abstractViewCtrler getSmartListViewController];
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
    //return self.plannerView.monthView;
    return _abstractViewCtrler.miniMonthView.calView;
}

- (AbstractMonthCalendarView *)getPlannerMonthCalendarView
{
    return self.plannerView.monthView;
}

- (PlannerBottomDayCal *)getPlannerDayCalendarView
{
    return self.plannerBottomDayCal;
}
/*
- (void) hidePopover
{
	if (self.popoverCtrler != nil && [self.popoverCtrler isPopoverVisible])
	{
		[self.popoverCtrler dismissPopoverAnimated:NO];
	}	
}
*/

- (void)showPreview: (TaskView *) view {
    [self deselect];
    PreviewViewController *ctrler = [[PreviewViewController alloc] init];
    ctrler.item = view.task;
    
    SDNavigationController *navController = [[SDNavigationController alloc] initWithRootViewController:ctrler];
    [ctrler release];
    
    self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
    
    self.popoverCtrler.passthroughViews = [NSArray arrayWithObjects:view,nil];
    
    [navController release];
    
    CGRect frm = [view.superview convertRect:view.frame toView:contentView];
    
    if (view.task.listSource == SOURCE_PLANNER_CALENDAR) {
        if (frm.origin.x <= ctrler.view.frame.size.width) {
            [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
        } else {
            [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
        }
    } else {
        [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:view.task.listSource == SOURCE_CALENDAR || view.task.listSource == SOURCE_FOCUS?UIPopoverArrowDirectionLeft:UIPopoverArrowDirectionRight animated:YES];
    }
}

- (void) enableActions:(BOOL)enable onView:(TaskView *)view
{
    BOOL showPopover = activeView != view;
    
    [super enableActions:enable onView:view];
    
    if (showPopover) {
        [self showPreview:view];
    }
}

- (BOOL) checkControllerActive:(NSInteger)index
{
    return index == 1?YES:NO;
}

- (void) reconcileItem:(Task *)item reSchedule:(BOOL)reSchedule
{
    // comment this line to fix deleting default task error
    [super reconcileItem:item reSchedule:reSchedule];
    
    if ([item isNote]) {
        //PlannerMonthView *monthView = (PlannerMonthView*)[self getPlannerMonthCalendarView];
        [plannerView.monthView refreshCellByDate:item.startTime];
    } else if ([item isADE]) {
        //PlannerMonthView *monthView = (PlannerMonthView*)[self getPlannerMonthCalendarView];
        [plannerView.monthView refreshOpeningWeek:nil];
    } else if ([item isEvent]) {
        [plannerBottomDayCal refreshLayout];
    } else if ([item isTask]) {
        [plannerView.monthView refreshCellByDate:item.deadline];
    }
}

- (void) deselect
{
    [super deselect];
    
    [self hideDropDownMenu];
}

#pragma mark Actions
- (void) add:(id)sender
{
	TaskDetailTableViewController *ctrler = [[TaskDetailTableViewController alloc] init];
    
    Task *task = [[[Task alloc] init] autorelease];
    
    TaskManager *tm = [TaskManager getInstance];
    
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
	
	ctrler.task = task;
	
	SDNavigationController *navController = [[SDNavigationController alloc] initWithRootViewController:ctrler];
	[ctrler release];
	
	self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
	
	[navController release];
    
    UIButton *addTaskButton = (UIButton *)[contentView viewWithTag:22000];
	
	CGRect frm = [addTaskButton.superview convertRect:addTaskButton.frame toView:contentView];
    
    [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}

- (void) filter:(id) sender
{
    if (!optionView.hidden)
    {
        [self hideDropDownMenu];
    }
    else
    {
        UIView *taskHeaderView = (UIView *)[contentView viewWithTag:21000];
    
        CGRect frm = optionView.frame;
    
        frm.origin.x = taskHeaderView.frame.origin.x + taskHeaderView.frame.size.width - 60;
        frm.origin.y = taskHeaderView.frame.origin.y + taskHeaderView.frame.size.height;
    
        optionView.frame = frm;
    
        [self showOptionMenu];
    }
}

- (void) showTaskWithOption:(id)sender
{
    [self hideDropDownMenu];
    
    UIButton *button = (UIButton *) sender;
    
    SmartListViewController *ctrler = [self getSmartListViewController];
    
    [ctrler filter:button.tag];
    
    NSString *title = [[TaskManager getInstance] getFilterTitle:button.tag];
    
    UILabel *filterLabel = (UILabel *)[contentView viewWithTag:24000];
    
    filterLabel.text = title;
}

- (void) startMultiEdit:(id)sender
{
    [self deselect];
    
    SmartListViewController *ctrler = [self getSmartListViewController];
    
    [ctrler multiEdit:YES];
}

#pragma mark Filter
- (void) refreshTaskFilterTitle
{
    UILabel *taskFilterLabel = (UILabel *)[contentView viewWithTag:24000];
    
    taskFilterLabel.text = [[TaskManager getInstance] getFilterTitle];
}

-(void)shrinkEnd
{
    optionView.hidden = YES;
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

-(void) createTaskOptionView
{
	//optionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 240)];
    optionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 280)];
	optionView.hidden = YES;
	optionView.backgroundColor = [UIColor clearColor];
	[contentView addSubview:optionView];
	[optionView release];
	
	//optionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 240)];
    optionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 280)];
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
    
    UIImageView *startImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 165, 20, 20)];
	startImageView.image = [[ImageManager getInstance] getImageWithName:@"filter_start.png"];
	[optionView addSubview:startImageView];
	[startImageView release];
	
	UILabel *startLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 162, 120, 25)];
	startLabel.text = _startText;
	startLabel.textColor = [UIColor whiteColor];
	startLabel.backgroundColor = [UIColor clearColor];
	startLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:startLabel];
	[startLabel release];
	
	UIButton *startButton=[Common createButton:@""
                                    buttonType:UIButtonTypeCustom
                                         frame:CGRectMake(0, 162, 160, 30)
                                    titleColor:nil
                                        target:self
                                      selector:@selector(showTaskWithOption:)
                              normalStateImage:nil
                            selectedStateImage:nil];
	startButton.titleLabel.font=[UIFont systemFontOfSize:18];
    startButton.tag = TASK_FILTER_ACTIVE;
	[optionView addSubview:startButton];
    
    UIImageView *doneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 200, 20, 20)];
	doneImageView.image = [[ImageManager getInstance] getImageWithName:@"filter_done.png"];
	[optionView addSubview:doneImageView];
	[doneImageView release];
	
	UILabel *doneLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 197, 120, 25)];
	doneLabel.text = _doneText;
	doneLabel.textColor = [UIColor whiteColor];
	doneLabel.backgroundColor = [UIColor clearColor];
	doneLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:doneLabel];
	[doneLabel release];
	
	UIButton *doneButton=[Common createButton:@""
                                   buttonType:UIButtonTypeCustom
                                        frame:CGRectMake(0, 197, 160, 30)
                                   titleColor:nil
                                       target:self
                                     selector:@selector(showTaskWithOption:)
                             normalStateImage:nil
                           selectedStateImage:nil];
	doneButton.titleLabel.font=[UIFont systemFontOfSize:18];
    doneButton.tag = TASK_FILTER_DONE;
	[optionView addSubview:doneButton];
    
    // scheduled filert
    UIImageView *scheduledImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 235, 20, 20)];
	scheduledImageView.image = [[ImageManager getInstance] getImageWithName:@"filter_start.png"];
	[optionView addSubview:scheduledImageView];
	[scheduledImageView release];
	
	UILabel *scheduledLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 232, 120, 25)];
	scheduledLabel.text = _pinnedText;
	scheduledLabel.textColor = [UIColor whiteColor];
	scheduledLabel.backgroundColor = [UIColor clearColor];
	scheduledLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:scheduledLabel];
	[scheduledLabel release];
	
	UIButton *scheduledButton=[Common createButton:@""
                                        buttonType:UIButtonTypeCustom
                                             frame:CGRectMake(0, 232, 160, 30)
                                        titleColor:nil
                                            target:self
                                          selector:@selector(showTaskWithOption:)
                                  normalStateImage:nil
                                selectedStateImage:nil];
	scheduledButton.titleLabel.font=[UIFont systemFontOfSize:18];
    scheduledButton.tag = TASK_FILTER_PINNED;
	[optionView addSubview:scheduledButton];
    // end scheduled filter
    
    MenuMakerView *menu = [[MenuMakerView alloc] initWithFrame:optionView.bounds];
    menu.menuPoint = menu.bounds.size.width/2;
    
    optionImageView.image = [Common takeSnapshot:menu size:menu.bounds.size];
    
    [menu release];
}

- (void)markDoneTaskInView: (TaskView *)view {
    BOOL refreshDayCal = view.task.isManual;
    [super markDoneTaskInView: view];
    
    if (refreshDayCal) {
        [plannerBottomDayCal refreshLayout];
    }
}

#pragma mark Views
- (void) createTaskModuleHeader
{
    CGRect frm = CGRectMake(plannerView.frame.origin.x + plannerView.frame.size.width + 8, 8, contentView.frame.size.width - (plannerView.frame.origin.x + plannerView.frame.size.width + 8) - 8, 30);
    
    UIView *headView = [[UIView alloc] initWithFrame:frm];
    headView.backgroundColor = [UIColor clearColor];
    headView.tag = 21000;
    
    [contentView addSubview:headView];
    [headView release];
    
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:headView.bounds];
    headerImageView.image = [UIImage imageNamed:@"planner_task_top_bg.png"];
    
    [headView addSubview:headerImageView];
    [headerImageView release];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 30)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.text = _tasksText;
    
    [headView addSubview:label];
    [label release];
    
    UIButton *addButton = [Common createButton:@""
                                    buttonType:UIButtonTypeCustom
                                         frame:CGRectMake(headView.bounds.size.width-35, 0, 30, 30)
                                    titleColor:[UIColor whiteColor]
                                        target:self
                                      selector:@selector(add:)
                              normalStateImage:@"module_add.png"
                            selectedStateImage:nil];
    addButton.tag = 22000;
    
    [headView addSubview:addButton];
    
    UIButton *filterButton = [Common createButton:@""
                                       buttonType:UIButtonTypeCustom
                                            frame:CGRectMake(headView.bounds.size.width-70, 0, 30, 30)
                                       titleColor:[UIColor whiteColor]
                                           target:self
                                         selector:@selector(filter:)
                                 normalStateImage:nil
                               selectedStateImage:nil];
    filterButton.tag = 23000;
    [headView addSubview:filterButton];
    
    UIImageView *filterImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 10, 10)];
    
    filterImgView.image = [UIImage imageNamed:@"arrow_down.png"];
    
    [filterButton addSubview:filterImgView];
    [filterImgView release];
    
    UIView *filterSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(headView.bounds.size.width-70, 5, 1, 20)];
    filterSeparatorView.backgroundColor = [UIColor whiteColor];
    
    [headView addSubview:filterSeparatorView];
    [filterSeparatorView release];
    
    UILabel *filterLabel = [[UILabel alloc] initWithFrame:CGRectMake(headView.bounds.size.width-180, 0, 100, 30)];
    filterLabel.backgroundColor = [UIColor clearColor];
    filterLabel.textAlignment =  NSTextAlignmentRight;
    filterLabel.textColor = [UIColor whiteColor];
    filterLabel.font = [UIFont boldSystemFontOfSize:16];
    filterLabel.tag = 24000;
    filterLabel.text = _allText;
    
    [headView addSubview:filterLabel];
    [filterLabel release];
    
    UIButton *taskMultiEditButton = [Common createButton:@"Edit"
                                              buttonType:UIButtonTypeCustom
                                                   frame:CGRectMake(70, 0, 60, 30)
                                              titleColor:[UIColor whiteColor]
                                                  target:self
                                                selector:@selector(startMultiEdit:)
                                        normalStateImage:nil
                                      selectedStateImage:nil];
    taskMultiEditButton.tag = 25000;
    taskMultiEditButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    
    [headView addSubview:taskMultiEditButton];
    
    [self createTaskOptionView];
}

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
    
    SmartListViewController *ctrler = [self getSmartListViewController];
    
    //[contentView addSubview:smartListViewCtrler.view];
    [contentView addSubview:ctrler.view];

    plannerView = [[PlannerView alloc] initWithFrame:CGRectMake(8, 8, 750, 206)];
    [contentView addSubview:plannerView];
    
    [self createTaskModuleHeader];
    
    CGFloat headerHeight = 30;
    
    //CGRect tmp = CGRectMake(plannerView.frame.origin.x + plannerView.frame.size.width + 8, 8, contentView.frame.size.width - (plannerView.frame.origin.x + plannerView.frame.size.width + 8) - 8, frm.size.height - 16);
    frm = CGRectMake(plannerView.frame.origin.x + plannerView.frame.size.width + 8, headerHeight + 8, contentView.frame.size.width - (plannerView.frame.origin.x + plannerView.frame.size.width + 8) - 8, contentView.frame.size.height - headerHeight - 16);
    
    [ctrler changeFrame:frm];
    
    // bottom day cal
    plannerBottomDayCal = [[PlannerBottomDayCal alloc] initWithFrame:CGRectMake(8,plannerView.frame.origin.y + plannerView.frame.size.height + 8, 750, contentView.frame.size.height - (plannerView.frame.origin.y + plannerView.frame.size.height) - 16)];
    [contentView addSubview:plannerBottomDayCal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    SmartListViewController *ctrler = [self getSmartListViewController];
    
    [ctrler resetMovableController:YES];
    
    [ctrler setMovableContentView:self.contentView];
    
    //[ctrler refreshLayout];
    
    [plannerBottomDayCal setMovableContentView:self.contentView];
    
    TaskManager *tm = [TaskManager getInstance];
    NSDate *dt = nil;
    if (tm.today != nil) {
        dt = [[tm.today copy] autorelease];
    } else {
        dt = [NSDate date];
    }
    [plannerView goToDate:dt];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    SmartListViewController *ctrler = [self getSmartListViewController];
    
    [ctrler performSelector:@selector(refreshLayout) withObject:nil afterDelay:0.1];
    
    _plannerViewCtrler = self;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self deselect];
    
    SmartListViewController *ctrler = [self getSmartListViewController];
    
    [ctrler clearLayout];
    [ctrler.view removeFromSuperview];

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

- (void)showYearView: (UIView *) view {
    //[super enableActions:enable onView:view];
    
    YearViewController *yearView = [[YearViewController alloc] init];
    self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:yearView] autorelease];
    [yearView release];
    
    CGRect frm = [view.superview convertRect:view.frame toView:contentView];
    
    //[self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:view.task.listSource == SOURCE_CALENDAR || view.task.listSource == SOURCE_FOCUS?UIPopoverArrowDirectionLeft:UIPopoverArrowDirectionRight animated:YES];
    [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)changeTime:(Task *)task time:(NSDate *)time {
    
    //NSDate *sDate = [task.startTime copy];
    //NSDate *dDate = [task.deadline copy];
    
    TaskManager *tm = [TaskManager getInstance];
    [tm moveTime:time forEvent:task];
    
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
        
        //AbstractMonthCalendarView *plannerCalView = [self getPlannerMonthCalendarView];
        
        //if (calView != nil)
        {
            if (sDate != nil)
            {
                [calView refreshCellByDate:sDate];
                //[plannerCalView refreshCellByDate:sDate];
                
                [sDate release];
            }
            
            if (dDate != nil)
            {
                [calView refreshCellByDate:dDate];
                //[plannerCalView refreshCellByDate:dDate];
                [dDate release];
            }
            
            [calView refreshCellByDate:task.startTime];
            //[plannerCalView refreshCellByDate:task.startTime];
        }
    }*/
    
    [self reconcileItem:task reSchedule:YES];
}
@end
