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
#import "Settings.h"
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
#import "NoteViewController.h"
#import "CategoryViewController.h"

#import "iPadViewController.h"

PlannerViewController *_plannerViewCtrler = nil;
extern iPadViewController *_iPadViewCtrler;

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
        
        activeView = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustSubFrame:) name:@"NotificationAdjustPlannerMiniMonthHeight" object:nil];
        
        firstOpen = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(scheduleFinished:)
													 name:@"ScheduleFinishedNotification" object:nil];
        
        [self initViewControllers];
        moduleSeparatorList = [[NSMutableArray alloc] initWithCapacity:2];
    }
    
    return self;
}

- (void) initViewControllers
{
    for (int i=0; i<4; i++)
    {
        PageAbstractViewController *ctrler = nil;
        
        switch (i)
        {
            case 0:
            {
                ctrler = [self getSmartListViewController];
            }
                break;
            case 1:
                ctrler = [self getNoteViewController];
                break;
            case 2:
                ctrler = [self getCategoryViewController];
                break;
        }
        
        [ctrler loadView];
        
        viewCtrlers[i] = ctrler;
    }
}

- (void) dealloc
{
    self.popoverCtrler = nil;
    
    //[plannerView release];
    //[plannerBottomDayCal release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    moduleHeaderView = nil;
    moduleView = nil;
    selectedModuleButton = nil;
    for (int i=0; i<3; i++)
    {
        viewCtrlers[i] = nil;
    }
    
    for (UIView *view in moduleSeparatorList) {
        view = nil;
    }
    [moduleSeparatorList release];
    copyLinkButton = nil;
    
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

/*
- (void) enableActions:(BOOL)enable onView:(TaskView *)view
{
    BOOL showPopover = activeView != view;
    
    [super enableActions:enable onView:view];
    
    if (showPopover) {
        [self showPreview:view];
    }
}
*/

- (BOOL) checkControllerActive:(NSInteger)index
{
    //return index == 1?YES:NO;
    
    if (selectedModuleButton != nil && (selectedModuleButton.tag-31000+1) == index)
    {
        return YES;
    }
    
    return NO;
}

- (void) reconcileItem:(Task *)item reSchedule:(BOOL)reSchedule
{
    // comment this line to fix deleting default task error
    [super reconcileItem:item reSchedule:reSchedule];
    
    [plannerView.monthView refreshOpeningWeek:nil];
}

- (void) deselect
{
    [super deselect];
    
    [self hideDropDownMenu];
    
    [plannerBottomDayCal stopResize];
    [plannerBottomDayCal stopQuickAdd];
}

- (void) resetMovableContentView
{
    [super resetMovableContentView];
    
    [plannerBottomDayCal setMovableContentView:self.contentView];
}

- (void) jumpToDate:(NSDate *)date
{
    [super jumpToDate:date];
    
    [self.plannerView goToDate:date];
}

#pragma mark Actions
- (void) add:(id)sender
{
	TaskDetailTableViewController *ctrler = [[TaskDetailTableViewController alloc] init];
    
    Task *task = [[[Task alloc] init] autorelease];
    
    TaskManager *tm = [TaskManager getInstance];
    Settings *settings = [Settings getInstance];
    
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

- (void) showTaskWithOption_old:(id)sender
{
    [self hideDropDownMenu];
    
    UIButton *button = (UIButton *) sender;
    
    SmartListViewController *ctrler = [self getSmartListViewController];
    
    [ctrler filter:button.tag];
    
    NSString *title = [[TaskManager getInstance] getFilterTitle:button.tag];
    
    UILabel *filterLabel = (UILabel *)[contentView viewWithTag:24000];
    
    filterLabel.text = title;
}

/*
- (void) startMultiEdit:(id)sender
{
    [self deselect];
    
    SmartListViewController *ctrler = [self getSmartListViewController];
    
    [ctrler multiEdit:YES];
}
*/
#pragma mark Filter
- (void) refreshTaskFilterTitle
{
    UILabel *taskFilterLabel = (UILabel *)[contentView viewWithTag:24000];
    
    taskFilterLabel.text = [[TaskManager getInstance] getFilterTitle];
}

/*
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
*/

-(void) createTaskOptionView
{
	optionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 240)];
    //optionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 280)];
	optionView.hidden = YES;
	optionView.backgroundColor = [UIColor clearColor];
	[contentView addSubview:optionView];
	[optionView release];
	
	optionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 240)];
    //optionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 280)];
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
    /*UIImageView *scheduledImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 235, 20, 20)];
	scheduledImageView.image = [[ImageManager getInstance] getImageWithName:@"filter_start.png"];
	[optionView addSubview:scheduledImageView];
	[scheduledImageView release];
	
	UILabel *scheduledLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 232, 120, 25)];
	scheduledLabel.text = _anchoredText;
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
	[optionView addSubview:scheduledButton];*/
    // end scheduled filter
    
    MenuMakerView *menu = [[MenuMakerView alloc] initWithFrame:optionView.bounds];
    menu.menuPoint = menu.bounds.size.width/2;
    
    optionImageView.image = [Common takeSnapshot:menu size:menu.bounds.size];
    
    [menu release];
}

- (NSString *) showTaskWithOption:(id)sender
{
    
    UISegmentedControl *segmented = (UISegmentedControl *)sender;
    
    NSString *title = [segmented titleForSegmentAtIndex:segmented.selectedSegmentIndex];
    
    switch (segmented.selectedSegmentIndex) {
        case 0:
            segmented.tag = TASK_FILTER_ALL;
            break;
            
        case 1:
            segmented.tag = TASK_FILTER_STAR;
            break;
            
        case 2:
            segmented.tag = TASK_FILTER_TOP;
            break;
            
        case 3:
            segmented.tag = TASK_FILTER_DUE;
            break;
            
        case 4:
            //segmented.tag = TASK_FILTER_ACTIVE;
            segmented.tag = TASK_FILTER_LONG;
            break;
            
        case 5:
            //segmented.tag = TASK_FILTER_DONE;
            segmented.tag = TASK_FILTER_SHORT;
            break;
            
        default:
            break;
    }
    //[super showTaskWithOption:segmented];
    SmartListViewController *ctrler = [self getSmartListViewController];
    
    [ctrler filter:segmented.tag];
    
    return title;
}

- (NSString *) showNoteWithOption:(id)sender
{
    
    UISegmentedControl *segmented = (UISegmentedControl *)sender;
    
    NSString *title = [segmented titleForSegmentAtIndex:segmented.selectedSegmentIndex];
    
    switch (segmented.selectedSegmentIndex) {
        case 0:
            segmented.tag = NOTE_FILTER_ALL;
            break;
            
        case 1:
            segmented.tag = NOTE_FILTER_CURRENT;
            break;
            
        case 2:
            segmented.tag = NOTE_FILTER_WEEK;
            break;
    }
    //[super showNoteWithOption:segmented];
    NoteViewController *ctrler = [self getNoteViewController];
    [ctrler filter:segmented.tag];
    
    return title;
}

- (NSString *) showProjectWithOption:(id)sender
{
    
    UISegmentedControl *segmented = (UISegmentedControl *)sender;
    
    NSString *title = [segmented titleForSegmentAtIndex:segmented.selectedSegmentIndex];
    
    segmented.tag = segmented.selectedSegmentIndex;
    [_abstractViewCtrler showProjectWithOption:segmented];
    
    return title;
}

#pragma mark Views

- (void) showPlannerOff:(BOOL)enabled
{
    CGRect moduleFrm = contentView.bounds;
    
    NSArray *normalImages;
    NSArray *selectedImages;
    if (enabled)
    {
        moduleFrm.origin.x = 384 + 8;
        
        moduleFrm.size.width = moduleFrm.size.width - moduleFrm.origin.x - 8;
        
        // image for module button
        normalImages = [NSArray arrayWithObjects:@"tab_tasks_left.png", @"tab_notes_left.png", @"tab_projects_left.png", nil];
        selectedImages = [NSArray arrayWithObjects:@"tab_tasks_left_selected.png", @"tab_notes_left_selected.png", @"tab_projects_left_selected.png", nil];
    }
    else
    {
        moduleFrm.origin.x = 750 + 16;
        moduleFrm.size.width = moduleFrm.size.width - moduleFrm.origin.x - 8;
        
        normalImages = [NSArray arrayWithObjects:@"tab_tasks_landscape.png", @"tab_notes_landscape.png", @"tab_projects_landscape.png", nil];
        selectedImages = [NSArray arrayWithObjects:@"tab_tasks_landscape_selected.png", @"tab_notes_landscape_selected.png", @"tab_projects_landscape_selected.png", nil];
    }
    
    moduleFrm.origin.y = 8;
    moduleFrm.size.height -= 8;
    
    CGRect frm = moduleFrm;
    
    CGFloat btnWidth = frm.size.width/3;
    
    for (int i=0; i<3; i++)
    {
        UIButton *moduleButton = (UIButton *)[contentView viewWithTag:31000+i];
        moduleButton.frame = CGRectMake(frm.origin.x + i*btnWidth, frm.origin.y, btnWidth, 50);
        // update image
        UIImage *img = [UIImage imageNamed:normalImages[i]];
        [moduleButton setBackgroundImage:img forState:UIControlStateNormal];
        img = [UIImage imageNamed:selectedImages[i]];
        [moduleButton setBackgroundImage:img forState:UIControlStateSelected];
        
        if (i != 2)
        {
            UIView *moduleSeparator = [moduleSeparatorList objectAtIndex:i];
            moduleSeparator.frame = CGRectMake(frm.origin.x + (i+1)*btnWidth - 1, frm.origin.y, 1, 50);
        }

    }
    
    // filter
    CGRect filterFrm = filterSegmentedControl.frame;
    filterFrm.size.width = frm.size.width;
    filterSegmentedControl.frame = filterFrm;
    
    frm = moduleFrm;

    frm.origin.y += 50;
    frm.size.height = 40;
    
    moduleHeaderView.frame = frm;
    
    frm = moduleFrm;
    
    frm.origin.y += 90;
    frm.size.height -= 90;
    
    moduleView.frame = frm;
    
    plannerView.hidden = enabled;
    plannerBottomDayCal.hidden = enabled;
    
    PageAbstractViewController *ctrler = viewCtrlers[selectedModuleButton.tag - 31000];
    
    [ctrler changeFrame:moduleView.bounds];
    [ctrler refreshLayout];
}

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

- (void) loadView_old
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
    
    plannerView = [[PlannerView alloc] initWithFrame:CGRectMake(8, 8, 750, 206)];
    [contentView addSubview:plannerView];
    [plannerView release];

    // bottom day cal
    plannerBottomDayCal = [[PlannerBottomDayCal alloc] initWithFrame:CGRectMake(8,plannerView.frame.origin.y + plannerView.frame.size.height + 8, 750, contentView.frame.size.height - (plannerView.frame.origin.y + plannerView.frame.size.height) - 16)];
    [contentView addSubview:plannerBottomDayCal];
    [plannerBottomDayCal release];
   
    [self createTaskModuleHeader];
    
    CGFloat headerHeight = 30;
    
    //CGRect tmp = CGRectMake(plannerView.frame.origin.x + plannerView.frame.size.width + 8, 8, contentView.frame.size.width - (plannerView.frame.origin.x + plannerView.frame.size.width + 8) - 8, frm.size.height - 16);
    frm = CGRectMake(plannerView.frame.origin.x + plannerView.frame.size.width + 8, headerHeight + 8, contentView.frame.size.width - (plannerView.frame.origin.x + plannerView.frame.size.width + 8) - 8, contentView.frame.size.height - headerHeight - 16);

    SmartListViewController *ctrler = [self getSmartListViewController];
    
    [contentView addSubview:ctrler.view];
    
    [ctrler changeFrame:frm];
    
}

- (void) loadView
{
    CGSize sz = [Common getScreenSize];
    
    CGRect frm = CGRectZero;
    frm.size.width = sz.height + 20 + 44;
    frm.size.height = sz.width - 20;
    
    contentView = [[ContentView alloc] initWithFrame:frm];
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    
    self.view = contentView;
    
    [contentView release];
    
    plannerView = [[PlannerView alloc] initWithFrame:CGRectMake(8, 8, 750, 206)];
    [contentView addSubview:plannerView];
    
    // bottom day cal
    plannerBottomDayCal = [[PlannerBottomDayCal alloc] initWithFrame:CGRectMake(8,plannerView.frame.origin.y + plannerView.frame.size.height + 8, 750, contentView.frame.size.height - (plannerView.frame.origin.y + plannerView.frame.size.height) - 16)];
    [contentView addSubview:plannerBottomDayCal];
    
    // tab module
    NSString *normalImages[3] = {@"tab_tasks_landscape.png", @"tab_notes_landscape.png", @"tab_projects_landscape.png"};
    NSString *selectedImages[3] = {@"tab_tasks_landscape_selected.png", @"tab_notes_landscape_selected.png", @"tab_projects_landscape_selected.png"};
    
    frm = CGRectMake(plannerView.frame.origin.x + plannerView.frame.size.width + 8, 8, contentView.frame.size.width - (plannerView.frame.origin.x + plannerView.frame.size.width) -16, contentView.frame.size.height - 16);
    
    CGFloat btnWidth = frm.size.width/3;
    
    UIButton *taskButton = nil;
    
    for (int i=0; i<3; i++)
    {
        UIButton *moduleButton = [Common createButton:@""
                                           buttonType:UIButtonTypeCustom
                                                frame:CGRectMake(frm.origin.x + i*btnWidth, frm.origin.y, btnWidth, 50)
                                           titleColor:[UIColor whiteColor]
                                               target:self
                                             selector:@selector(showModule:)
                                     normalStateImage:normalImages[i]
                                   selectedStateImage:selectedImages[i]];
        //moduleButton.backgroundColor = [UIColor grayColor]
        ;
        //[moduleButton setTitle:titles[i] forState:UIControlStateNormal];
        moduleButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        moduleButton.tag = 31000+i;
        
        [contentView addSubview:moduleButton];
        
        if (i != 2)
        {
            UIView *moduleSeparator = [[UIView alloc] initWithFrame:CGRectMake(frm.origin.x + (i+1)*btnWidth - 1, frm.origin.y, 1, 50)];
            moduleSeparator.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
            
            [contentView addSubview:moduleSeparator];
            [moduleSeparatorList addObject:moduleSeparator];
            [moduleSeparator release];
        }
        
        if (i==0)
        {
            taskButton = moduleButton;
        }
    }
    
    moduleHeaderView = [[UIView alloc] initWithFrame:CGRectMake(frm.origin.x, 50, frm.size.width, 40)];
    //moduleHeaderView.backgroundColor = [UIColor brownColor];
    moduleHeaderView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    //moduleHeaderView.backgroundColor = [UIColor clearColor];
    //headerView.tag = TAG_VIEW_HEADER_VIEW;
    
    [contentView addSubview:moduleHeaderView];
    [moduleHeaderView release];
    
    moduleView = [[UIView alloc] initWithFrame:CGRectMake(frm.origin.x, 90, frm.size.width, frm.size.height - 90)];
    //moduleView.backgroundColor = [UIColor greenColor];
    moduleView.backgroundColor = [UIColor clearColor];
    moduleView.tag = 33000;
    
    [contentView addSubview:moduleView];
    [moduleView release];
    
    [self createMultiEditBar];
}

-(void) createMultiEditBar
{
    multiEditBar = [[UIToolbar alloc] initWithFrame:moduleHeaderView.frame];
    multiEditBar.hidden = YES;
    
    [contentView addSubview:multiEditBar];
    [multiEditBar release];
    
    multiCount = 0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
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
    [self deselect];
    [super viewWillDisappear:animated];
    
    //[self deselect];
    
    //SmartListViewController *ctrler = [self getSmartListViewController];
    
    //[ctrler clearLayout];
    //[ctrler.view removeFromSuperview];

    _plannerViewCtrler = nil;
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MiniMonthResizeNotification" object:self];
    
    CalendarViewController *ctrler = [self getCalendarViewController];
    
    [ctrler refreshLayout];//fix bug: create Event in landscape, rotate to portrait -> events are shown incorrectly in day calendar
}

- (void) adjustSubFrame: (NSNotification*) notification {
    
    CGRect frm = CGRectMake(8,plannerView.frame.origin.y + plannerView.frame.size.height + 8, 750, contentView.frame.size.height - (plannerView.frame.origin.y + plannerView.frame.size.height) - 16);
    plannerBottomDayCal.frame = frm;
    
    // change date
    NSDictionary *userInfo = [notification userInfo];
    NSDate *firstDate = [userInfo objectForKey:@"firstDate"];
    
    if (firstDate == nil) {
        [plannerBottomDayCal refreshLayout];
    } else {
        [plannerBottomDayCal changeWeek:firstDate];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showYearView: (UIView *) view {
    //[super enableActions:enable onView:view];
    CGRect frm = [view.superview convertRect:view.frame toView:contentView];
    frm.size.height -= frm.size.height/2;
    
    CGSize contentSize = contentView.bounds.size;
    
    CGSize yearViewSize = CGSizeMake(contentSize.width - 50, contentSize.height - (frm.origin.y + 6*frm.size.height));
    YearViewController *yearView = [[YearViewController alloc] initWithSize:yearViewSize];
    self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:yearView] autorelease];
    [yearView release];
    
    [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)changeTime:(Task *)task time:(NSDate *)time {
    
    TaskManager *tm = [TaskManager getInstance];
    [tm moveTime:time forEvent:task];
    
    [self reconcileItem:task reSchedule:YES];
}

- (void)scheduleFinished:(NSNotification *)notification
{
    if (firstOpen) {
        firstOpen = NO;
        [plannerView.monthView refreshOpeningWeek:nil];
    }
}

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    /*PlannerMonthView *plannerCalView = (PlannerMonthView *)[self getPlannerMonthCalendarView];

    [plannerCalView refresh];
    [plannerCalView refreshOpeningWeek:nil];
    NSLog(@"planner view set need display");*/
    
    for (UIView *view in plannerView.monthView.subviews)
	{
        if ([view isKindOfClass:[TaskView class]])
        {
            [view refresh];
        }
	}
    
    [plannerBottomDayCal setNeedsDisplay];
}

#pragma mark Modules
- (void) showModuleByIndex:(NSInteger)index
{
    //index: 0-Task, 1-Note, 2-Project
    UIButton *button = (UIButton *) [contentView viewWithTag:31000+index];
    
    if (selectedModuleButton != nil)
    {
        UIView *moduleView = [contentView viewWithTag:33000];
        [[moduleView.subviews lastObject] removeFromSuperview];
        
        selectedModuleButton = nil;
    }
    
    [self showModule:button];
    
    PageAbstractViewController *ctrler = [self getModuleAtIndex:index+1];
    
    [ctrler refreshLayout];
}

- (void) showModule:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    if (selectedModuleButton != btn)
    {
        //UIView *moduleView = [contentView viewWithTag:33000];
        
        if (selectedModuleButton != nil)
        {
            [[moduleView.subviews lastObject] removeFromSuperview];
        }
        
        _iPadViewCtrler.selectedModuleIndex = btn.tag - 31000;
        
        PageAbstractViewController *ctrler = [self getModuleAtIndex:_iPadViewCtrler.selectedModuleIndex + 1];
        
        [ctrler changeFrame:moduleView.bounds];
        
        [moduleView addSubview:ctrler.view];
        
        selectedModuleButton.selected = NO;
        selectedModuleButton = btn;
        selectedModuleButton.selected = YES;
        
        [self refreshHeaderView];
    }
}

- (void) refreshHeaderView
{
    
    for (UIView *view in moduleHeaderView.subviews)
    {
        [view removeFromSuperview];
    }
    
    switch (selectedModuleButton.tag - 31000)
    {
        case 0:
        {
            [self createTaskOptionFilter];
        }
            break;
            
        case 1:
            [self createNoteOptionFilter];
            break;
            
        case 2:
            [self createProjectOptionFilter];
            break;
    }
}

- (void)createTaskOptionFilter
{
    // refresh selected counter
    selectedCounter = 0;
    
    NSArray *itemArray = [NSArray arrayWithObjects: _allText, _starText, _gtdoText, _dueText, _longText, _shortText, nil];
    
    filterSegmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    CGRect frm = moduleHeaderView.bounds;
    frm.size.height -= 10;
    frm.origin.y = (moduleHeaderView.frame.size.height - frm.size.height)/2;
    filterSegmentedControl.frame = frm;
    
    // customizing appearance
    filterSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    filterSegmentedControl.selectedSegmentIndex = 0;
    filterSegmentedControl.tintColor = [UIColor colorWithRed:237.0/250 green:237.0/250 blue:237.0/250 alpha:1];
    [filterSegmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    [UIColor grayColor], UITextAttributeTextColor,
                                                    //[UIColor blackColor], UITextAttributeTextShadowColor,
                                                    //[NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
                                                    nil] forState:UIControlStateNormal];
    UIColor *selectedColor = [UIColor colorWithRed:5.0/255 green:80.0/255 blue:185.0/255 alpha:1];
    [filterSegmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    selectedColor, UITextAttributeTextColor,
                                                    nil] forState:UIControlStateSelected];
    
    [filterSegmentedControl addTarget:self action:@selector(showTaskWithOption:) forControlEvents:UIControlEventValueChanged];
    
    // set selected
    NSString *title = [[TaskManager getInstance] getFilterTitle];
    for (int i = 0; i < filterSegmentedControl.numberOfSegments; i++) {
        NSString *segmentText = [filterSegmentedControl titleForSegmentAtIndex:i];
        if (title == segmentText) {
            filterSegmentedControl.selectedSegmentIndex = i;
            break;
        }
    }
    
    [moduleHeaderView addSubview:filterSegmentedControl];
    [filterSegmentedControl release];
}

- (void)refreshEditBarViewWithCheck: (BOOL) check
{
    BOOL firstCheck = selectedCounter == 0;
    
    selectedCounter = check ?  ++selectedCounter : --selectedCounter;
    
    if (selectedCounter > 0) {
        editBarView.hidden = NO;
        filterSegmentedControl.hidden = YES;
    } else {
        editBarView.hidden = YES;
        filterSegmentedControl.hidden = NO;
    }
    
    //UIButton *copyLinkButton = (UIButton*)[contentView viewWithTag:TAG_VIEW_COPY_BUTTON];
    copyLinkButton.enabled = (selectedCounter == 2);
    
    if (firstCheck) {
        switch (selectedModuleButton.tag - 31000)
        {
            case 0:
            {
                SmartListViewController *ctrler = [self getSmartListViewController];
                
                [ctrler multiEdit:YES];
                //[ctrler hideQuickAdd];
            }
                break;
            case 1:
            {
                NoteViewController *ctrler = [self getNoteViewController];
                
                [ctrler multiEdit:YES];
            }
                
                break;
            case 2:
            {
                CategoryViewController *ctrler = [self getCategoryViewController];
                
                [ctrler multiEdit:YES];
            }
                break;
        }
    } else if (selectedCounter == 0) {
        switch (selectedModuleButton.tag - 31000)
        {
            case 0:
            {
                SmartListViewController *ctrler = [self getSmartListViewController];
                
                [ctrler multiEdit:NO];
            }
                break;
            case 1:
            {
                NoteViewController *ctrler = [self getNoteViewController];
                
                [ctrler multiEdit:NO];
            }
                
                break;
            case 2:
            {
                CategoryViewController *ctrler = [self getCategoryViewController];
                
                [ctrler multiEdit:NO];
            }
                break;
        }
    }
}

- (void) createNoteOptionFilter
{
    //NSArray *itemArray = [NSArray arrayWithObjects: _allText, _selectedText, nil];
    NSArray *itemArray = [NSArray arrayWithObjects: _allText, _currentText, _thisWeekText, nil];
    
    filterSegmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    CGRect frm = moduleHeaderView.bounds;
    frm.size.height -= 10;
    frm.origin.y = (moduleHeaderView.frame.size.height - frm.size.height)/2;
    filterSegmentedControl.frame = frm;
    
    filterSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    filterSegmentedControl.selectedSegmentIndex = 0;
    filterSegmentedControl.tintColor = [UIColor colorWithRed:237.0/250 green:237.0/250 blue:237.0/250 alpha:1];
    [filterSegmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    [UIColor grayColor], UITextAttributeTextColor,
                                                    //[UIColor blackColor], UITextAttributeTextShadowColor,
                                                    //[NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
                                                    nil] forState:UIControlStateNormal];
    UIColor *selectedColor = [UIColor colorWithRed:5.0/255 green:80.0/255 blue:185.0/255 alpha:1];
    [filterSegmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    selectedColor, UITextAttributeTextColor,
                                                    nil] forState:UIControlStateSelected];
    
    [filterSegmentedControl addTarget:self action:@selector(showNoteWithOption:) forControlEvents:UIControlEventValueChanged];
    
    // set selected
    NoteViewController *ctrler = [self getNoteViewController];
    filterSegmentedControl.selectedSegmentIndex = ctrler.filterType;
    
    [moduleHeaderView addSubview:filterSegmentedControl];
    [filterSegmentedControl release];
}

- (void)createProjectOptionFilter
{
    NSArray *itemArray = [NSArray arrayWithObjects: _tasksText, _eventsText, _notesText, _anchoredText, nil];
    
    filterSegmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    CGRect frm = moduleHeaderView.bounds;
    frm.size.height -= 10;
    frm.origin.y = (moduleHeaderView.frame.size.height - frm.size.height)/2;
    filterSegmentedControl.frame = frm;
    
    filterSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    filterSegmentedControl.selectedSegmentIndex = 0;
    filterSegmentedControl.tintColor = [UIColor colorWithRed:237.0/250 green:237.0/250 blue:237.0/250 alpha:1];
    [filterSegmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    [UIColor grayColor], UITextAttributeTextColor,
                                                    //[UIColor blackColor], UITextAttributeTextShadowColor,
                                                    //[NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
                                                    nil] forState:UIControlStateNormal];
    UIColor *selectedColor = [UIColor colorWithRed:5.0/255 green:80.0/255 blue:185.0/255 alpha:1];
    [filterSegmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    selectedColor, UITextAttributeTextColor,
                                                    nil] forState:UIControlStateSelected];
    
    [filterSegmentedControl addTarget:self action:@selector(showProjectWithOption:) forControlEvents:UIControlEventValueChanged];
    
    // set selected
    CategoryViewController *ctrler = [self getCategoryViewController];
    switch (ctrler.filterType) {
        case TYPE_TASK:
            filterSegmentedControl.selectedSegmentIndex = 0;
            break;
            
        case TYPE_EVENT:
            filterSegmentedControl.selectedSegmentIndex = 1;
            break;
            
        case TYPE_NOTE:
            filterSegmentedControl.selectedSegmentIndex = 2;
            break;
            
        case TASK_FILTER_PINNED:
            filterSegmentedControl.selectedSegmentIndex = 3;
            break;
    }
    
    [moduleHeaderView addSubview:filterSegmentedControl];
    [filterSegmentedControl release];
}

/*
#pragma mark multi actions
- (void)multiMarkDone: (id) sender
{
    SmartListViewController *ctrlr = [self getSmartListViewController];
    [ctrlr multiDone:sender];
}

- (void)multiMoveTop: (id)sender
{
    SmartListViewController *ctrlr = [self getSmartListViewController];
    [ctrlr multiMoveTop:sender];
}

- (void)multiDefer: (id)sender
{
    SmartListViewController *ctrlr = [self getSmartListViewController];
    [ctrlr multiDefer:sender];
}

- (void)multiMarkStar: (id)sender
{
    SmartListViewController *ctrlr = [self getSmartListViewController];
    [ctrlr multiMarkStar:sender];
}

- (void)multiDelete: (id) sender
{
    switch (selectedModuleButton.tag - 31000) {
        case 0:
        {
            SmartListViewController *ctrlr = [self getSmartListViewController];
            [ctrlr multiDelete: sender];
        }
            break;
            
        case 1:
        {
            NoteViewController *ctrlr = [self getNoteViewController];
            [ctrlr multiDelete: sender];
        }
            break;
            
        case 2:
        {
            CategoryViewController *ctrlr = [self getCategoryViewController];
            [ctrlr multiDelete:sender];
        }
            break;
    }
}

- (void)createLink: (id)sender
{
    SmartListViewController *ctrlr = [self getSmartListViewController];
    [ctrlr createLink:sender];
    [self cancelEdit];
}

- (void)cancelEdit
{
    selectedCounter = 0;
    
    editBarView.hidden = YES;
    filterSegmentedControl.hidden = NO;
}
 
 */
@end
