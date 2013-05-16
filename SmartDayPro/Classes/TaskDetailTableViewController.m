//
//  TaskDetailTableViewController.m
//  SmartPlan
//
//  Created by Huy Le on 12/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "TaskDetailTableViewController.h"

#import "Common.h"
#import "Settings.h"
#import "Colors.h"
#import "Task.h"
#import "TaskProgress.h"
#import "RepeatData.h"

#import "WWWTableViewController.h"
#import "DurationPickerViewController.h"
#import "ProjectSelectionTableViewController.h"
#import "TaskNoteViewController.h"
#import "ProgressEditViewController.h"
#import "DatePickerViewController.h"
#import "StartEndPickerViewController.h"
#import "RepeatTableViewController.h"
#import "AlertListViewController.h"
//#import "CheckListViewController.h"
#import "SmartListViewController.h"
#import "CategoryViewController.h"

#import "Project.h"
#import "ProjectManager.h"

#import "TaskManager.h"
#import "DBManager.h"
#import "AlertManager.h"
#import "ImageManager.h"
#import "BusyController.h"

#import "CalendarViewController.h"
#import "MiniMonthView.h"
#import "MonthlyCalendarView.h"

#import "TagDictionary.h"
#import "TagEditViewController.h"

#import "LinkViewController.h"
#import "TimerHistoryViewController.h"

#import "SmartDayViewController.h"

#import "HPGrowingTextView.h"

#import "AbstractSDViewController.h"
#import "PlannerViewController.h"

extern AbstractSDViewController *_abstractViewCtrler;
extern PlannerViewController *_plannerViewCtrler;

extern BOOL _isiPad;

@implementation TaskDetailTableViewController

@synthesize keyEdit;
@synthesize task;
@synthesize taskCopy;
@synthesize taskIndex;

@synthesize progressHistory;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

- (id)init
{
	if (self = [super init])
	{
		self.keyEdit = -1;
        
        self.contentSizeForViewInPopover = CGSizeMake(320,416);
/*
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(appBusy:)
													 name:@"AppBusyNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(appNoBusy:)
													 name:@"AppNoBusyNotification" object:nil];
*/
	}
	
	return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [titleTextView release];
    
	self.task = nil;
	self.taskCopy = nil;
	
	self.progressHistory = nil;
	
    [super dealloc];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView 
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    if (_isiPad)
    {
        frm.size.width = 320;
        frm.size.height = 416;
    }
    
	UIView *contentView = [[UIView alloc] initWithFrame:frm];
	contentView.backgroundColor = [UIColor clearColor];
	
	//taskTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 416) style:UITableViewStyleGrouped];
    taskTableView = [[UITableView alloc] initWithFrame:frm style:UITableViewStyleGrouped];
	taskTableView.delegate = self;
	taskTableView.dataSource = self;
	
	[contentView addSubview:taskTableView];
	[taskTableView release];
	
	self.view = contentView;
	[contentView release];
    
	titleTextView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(0, 0, 300-30, 30)];
    //titleTextView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    titleTextView.placeholder = _titleGuideText;
    
	titleTextView.minNumberOfLines = 1;
	titleTextView.maxNumberOfLines = 4;
	titleTextView.returnKeyType = UIReturnKeyDone; //just as an example
	titleTextView.font = [UIFont systemFontOfSize:15.0f];
	titleTextView.delegate = self;
    //titleTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    titleTextView.backgroundColor = [UIColor clearColor];
	
	saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
															  target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
	
	if (task.original != nil && ![task isREException]) //Calendar Task or REException
	{
        //printf("task original: %s\n", [[task.original name] UTF8String]);
        
		self.taskCopy = task.original;
        
        if ([task isREInstance])
        {
            self.taskCopy.startTime = task.startTime;
            self.taskCopy.endTime = task.endTime;
        }
	}
	else
	{
		self.taskCopy = task;	
	}
    	
	if (self.taskCopy.type == TYPE_EVENT && (self.taskCopy.startTime == nil || self.taskCopy.endTime == nil)) // new Event
	{
		self.taskCopy.startTime = [Common dateByRoundMinute:15 toDate:[NSDate date]];
		self.taskCopy.endTime = [Common dateByAddNumSecond:3600 toDate:self.taskCopy.startTime];
	}
	
	/*if (self.taskCopy.name == nil || [self.taskCopy.name isEqualToString:@""])
	{
		saveButton.enabled = NO;
	}	
	*/
	
    [self check2EnableSave];
	
    showMore = NO;
    deadlineEnabled = self.taskCopy.deadline != nil;
    titleTextView.text = self.taskCopy.name;
    
	selectedDurationButton = nil;
	selectedDeadlineButton = nil;
	selectedStartButton = nil;
	
	BOOL isTask = (self.taskCopy.type == TYPE_TASK || self.taskCopy.type == TYPE_SHOPPING_ITEM);
	
	taskTypeSegmentedControl = [[UISegmentedControl alloc] initWithItems:
								[NSArray arrayWithObjects:_taskText, _eventText,nil]];
	
	[taskTypeSegmentedControl addTarget:self action:@selector(changeTaskType:) forControlEvents:UIControlEventValueChanged];
	taskTypeSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBordered;
	taskTypeSegmentedControl.selectedSegmentIndex = (isTask?0:1);
	taskTypeSegmentedControl.tintColor = [UIColor blueColor];
	
	frm = taskTypeSegmentedControl.frame;
	frm.size.height = 30;
	taskTypeSegmentedControl.frame = frm;
	
	self.navigationItem.titleView = taskTypeSegmentedControl;
	[taskTypeSegmentedControl release];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	
	//isOfListStyle = [[ProjectManager getInstance] checkListStyle:self.taskCopy.project];
    
    deadlineEnabled = self.taskCopy.deadline != nil;
	
	[taskTableView reloadData];
	
    /*
	if ([self.taskCopy.name isEqualToString:@""])
	{
		saveButton.enabled = NO;
	}
	else
	{
		saveButton.enabled = YES;
	}*/
    
    [self check2EnableSave];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
	
	//[taskTitleTextField becomeFirstResponder];	
}


 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
{
     [super viewDidLoad];
    
    Task *original = (self.task.original != nil?self.task.original:self.task);
    
    if (original.primaryKey == -1)
    {
        [titleTextView becomeFirstResponder];
    }
}


/*
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
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)changeDuration:(id) sender
{
	if (selectedDurationButton != nil)
	{
		selectedDurationButton.selected = NO;
	}
	
	selectedDurationButton = (UIButton *)sender;
	selectedDurationButton.selected = YES;
	
	switch ((selectedDurationButton.tag % 10)-4)
	{
		case 0:
			self.taskCopy.duration = 900;
			break;
		case 1:
			self.taskCopy.duration = 3600;
			break;
		case 2:
			self.taskCopy.duration = 10800;
			break;
	}
	
	durationValueLabel.text = [Common getDurationString:self.taskCopy.duration];	
}

- (void)changeDeadline:(id) sender
{
    Settings *settings = [Settings getInstance];
    
	if (selectedDeadlineButton != nil)
	{
		selectedDeadlineButton.selected = NO;
	}
	
	selectedDeadlineButton = (UIButton *)sender;
	selectedDeadlineButton.selected = YES;
    
    NSInteger diff = 0;
    
    if (task.startTime != nil)
    {
        diff = [task.deadline timeIntervalSinceDate:task.startTime];
    }
	
	NSDate *today = [NSDate date];
	
	switch ((selectedDeadlineButton.tag % 10)-4)
	{
		case 0:
			self.taskCopy.deadline = [settings getWorkingEndTimeForDate:today];
			break;
		case 1:
			self.taskCopy.deadline = [settings getWorkingEndTimeForDate:[Common dateByAddNumDay:1 toDate:today]];
			break;
		case 2:
			self.taskCopy.deadline = [settings getWorkingEndTimeForDate:[Common dateByAddNumDay:7 toDate:today]];
			break;
		case 3:
			self.taskCopy.deadline = [settings getWorkingEndTimeForDate:[Common dateByAddNumDay:30 toDate:today]];
			break;
	}
    
    /*
    if (self.taskCopy.startTime != nil && [self.taskCopy.deadline compare:self.taskCopy.startTime] == NSOrderedAscending)
    {
        self.taskCopy.startTime = [settings getWorkingStartTimeForDate:self.taskCopy.deadline];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        
        [taskTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    */
	
	deadlineValueLabel.text = [Common getFullDateString3:self.taskCopy.deadline];
    
    if (diff > 0)
    {
        NSDate *dt = [NSDate dateWithTimeInterval:-diff sinceDate:self.taskCopy.deadline];
        
        self.taskCopy.startTime = [settings getWorkingStartTimeForDate:dt];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        
        [taskTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)changeStart:(id) sender
{
    Settings *settings = [Settings getInstance];
    
	if (selectedStartButton != nil)
	{
		selectedStartButton.selected = NO;
	}
	
	selectedStartButton = (UIButton *)sender;
	selectedStartButton.selected = YES;
	
	NSDate *today = [NSDate date];
	
	switch ((selectedStartButton.tag % 10)-4)
	{
		case 0:
			self.taskCopy.startTime = [settings getWorkingStartTimeForDate:today];
			break;
		case 1:
			self.taskCopy.startTime = [settings getWorkingStartTimeForDate:[Common dateByAddNumDay:1 toDate:today]];
			break;
		case 2:
			self.taskCopy.startTime = [settings getWorkingStartTimeForDate:[Common dateByAddNumDay:7 toDate:today]];
			break;
		case 3:
			self.taskCopy.startTime = [settings getWorkingStartTimeForDate:[Common dateByAddNumDay:30 toDate:today]];
			break;
	}
    
    if (self.taskCopy.deadline != nil && [self.taskCopy.deadline compare:self.taskCopy.startTime] == NSOrderedAscending)
    {
        self.taskCopy.deadline = [settings getWorkingEndTimeForDate:self.taskCopy.startTime];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
        
        [taskTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];        
    }
	
	startValueLabel.text = [Common getFullDateString3:self.taskCopy.startTime];
}


- (void)changeTaskType:(id) sender
{
	UISegmentedControl *segment = (UISegmentedControl *)sender;
	
    /*
	if (segment.selectedSegmentIndex == 1)
	{
		if ([self.taskCopy isTask] || self.taskCopy.startTime == nil)
		{
			self.taskCopy.startTime = [Common dateByRoundMinute:15 toDate:[NSDate date]];
			//self.taskCopy.endTime = [Common dateByAddNumSecond:3600 toDate:self.taskCopy.startTime];
			self.taskCopy.endTime = [Common dateByAddNumSecond:(self.taskCopy.duration>0?self.taskCopy.duration:3600) toDate:self.taskCopy.startTime];
		}
	}
    */
    
	NSInteger taskType = ([self.task isEvent]?TYPE_TASK:self.task.type);//keep original type (Task or Check List Item) if original is not Event
    
	self.taskCopy.type = (segment.selectedSegmentIndex == 0? taskType: (self.taskCopy.type == TYPE_ADE?TYPE_ADE:TYPE_EVENT));

    BOOL re2Task = ([self.task isREException] || [self.task isREInstance]) && [self.taskCopy isTask];
	    
    if ([self.taskCopy isTask])
    {
        self.taskCopy.duration = [[Settings getInstance] taskDuration];
        self.taskCopy.startTime = [Common dateByRoundMinute:15 toDate:[NSDate date]];
        
        self.taskCopy.endTime = [Common dateByAddNumSecond:(self.taskCopy.duration>0?self.taskCopy.duration:3600) toDate:self.taskCopy.startTime];
        
        if (re2Task)
        {
            self.taskCopy.original = nil;
            self.taskCopy.repeatData = nil;
            self.taskCopy.groupKey = -1;
        }
    }
    else 
    {
        NSDate *date = [[TaskManager getInstance] today];
        
        if (self.taskCopy.type == TYPE_ADE)
        {
            self.taskCopy.startTime = [Common clearTimeForDate:date];
            self.taskCopy.endTime = [Common getEndDate:date];
        }
        else 
        {
            self.taskCopy.startTime = [Common dateByRoundMinute:15 toDate:date];
            self.taskCopy.endTime = [Common dateByAddNumSecond:3600 toDate:self.taskCopy.startTime];            
        }        
    }
	
	if (self.taskCopy.alerts != nil && self.taskCopy.alerts.count > 0 && [self.taskCopy isTask] && self.taskCopy.deadline == nil)
	{
		self.taskCopy.deadline = [[Settings getInstance] getWorkingEndTimeForDate:[NSDate date]]; //Task has alerts -> set due Today
	}
	
	historyView.hidden = (segment.selectedSegmentIndex == 1);
	historyTableView.hidden = (segment.selectedSegmentIndex == 1);
	
	//taskTableView.frame = (segment.selectedSegmentIndex == 1? CGRectMake(0, 0, 320, 385):CGRectMake(0, 0, 320, 455));
	
	[taskTableView reloadData];
}

- (void)changeEventType:(id) sender
{
	UISegmentedControl *segment = (UISegmentedControl *)sender;
    
	self.taskCopy.type = (segment.selectedSegmentIndex == 0? TYPE_ADE: TYPE_EVENT);
	
    if (self.taskCopy.type == TYPE_ADE)
    {
		self.taskCopy.startTime = [Common clearTimeForDate:self.taskCopy.startTime];
		//self.taskCopy.endTime = [Common dateByAddNumSecond:-1 toDate:[Common getEndDate:self.taskCopy.endTime]];
        self.taskCopy.endTime = [Common getEndDate:self.taskCopy.endTime];
        self.taskCopy.alerts = [NSMutableArray arrayWithCapacity:0];
    }
    else 
    {
        TaskManager *tm = [TaskManager getInstance];
        
        self.taskCopy.startTime = [Common dateByRoundMinute:15 toDate:tm.today];
        self.taskCopy.endTime = [Common dateByAddNumSecond:3600 toDate:self.taskCopy.startTime];            
    } 
    
    [taskTableView reloadData];
}

- (void)editProgress:(id) sender
{
	ProgressEditViewController *ctrler = [[ProgressEditViewController alloc] init];
	
	ctrler.progress = (TaskProgress *) [self.progressHistory objectAtIndex:0];
	ctrler.progress.task = self.task; //assign the actual link to update Task's start time and end time if any
	
	ctrler.minStartTime = nil;
	ctrler.only1Progress = YES;
	
	if (self.progressHistory.count > 1)
	{
		ctrler.minStartTime = ((TaskProgress *) [self.progressHistory objectAtIndex:1]).endTime;
		ctrler.only1Progress = NO;
	}
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

- (void)editTitle:(id) sender
{
    [titleTextView resignFirstResponder];
    
	WWWTableViewController *ctrler = [[WWWTableViewController alloc] init];
	ctrler.task = self.taskCopy;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

- (void)editDuration:(id) sender
{
	DurationPickerViewController *ctrler = [[DurationPickerViewController alloc] init];
	ctrler.objectEdit = self.taskCopy;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

- (void)editDeadline:(id) sender
{
	DatePickerViewController *ctrler = [[DatePickerViewController alloc] init];
	ctrler.objectEdit = self.taskCopy;
	ctrler.keyEdit = TASK_EDIT_DEADLINE;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];		
}

- (void)editStart:(id) sender
{
	DatePickerViewController *ctrler = [[DatePickerViewController alloc] init];
	ctrler.objectEdit = self.taskCopy;
	ctrler.keyEdit = TASK_EDIT_START;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];		
}


//- (void)editWhen:(id) sender
- (void)editWhen
{
	StartEndPickerViewController *ctrler = [[StartEndPickerViewController alloc] init];
	ctrler.objectEdit = self.taskCopy;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];	
}

//- (void)editRepeat:(id) sender
- (void)editRepeat
{
    if ([self.taskCopy isREException])
    {
        return;
    }
    
	RepeatTableViewController *ctrler = [[RepeatTableViewController alloc] init];
	ctrler.task = self.taskCopy;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];	
}

- (void)editProject
{
	ProjectSelectionTableViewController *ctrler = [[ProjectSelectionTableViewController alloc] init];
	ctrler.objectEdit = self.taskCopy;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];		
}

- (void)editNote
{
	TaskNoteViewController *ctrler = [[TaskNoteViewController alloc] init];
	ctrler.task = self.taskCopy;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];	
}

- (void)editAlert
{
	AlertListViewController *ctrler = [[AlertListViewController alloc] init];
	ctrler.taskEdit = self.taskCopy;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];	
}

- (void)editLink
{
	LinkViewController *ctrler = [[LinkViewController alloc] init];
    //ctrler.task = self.taskCopy;
    
    Task *tmp = (self.task.original != nil && ![self.task isREException])?self.task.original:self.task;
    
    ctrler.task = tmp;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];		
}

- (void) showTimerHistory
{
	TimerHistoryViewController *ctrler = [[TimerHistoryViewController alloc] init];
    ctrler.task = self.taskCopy;
    
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

- (void) scroll
{
	[taskTableView setContentOffset:CGPointMake(0, 360)];
}

/*
- (NSString *) getCombinedTag
{
    NSString *parentTag = [[ProjectManager getInstance] getProjectTagByKey:self.taskCopy.project];
    
    NSString *tag = self.taskCopy.tag;
    
    if (![parentTag isEqualToString:@""])
    {
        tag = [NSString stringWithFormat:@"%@%@", parentTag, [tag isEqualToString:@""]?@"":[NSString stringWithFormat:@",%@",tag]];
    }
    
    return tag;
}
*/

- (BOOL) checkExistingTag:(NSString *)tag
{
    NSString *allTag = [self.taskCopy getCombinedTag];
    
    NSDictionary *dict = [TagDictionary getTagDict:allTag];
    
    return ([dict objectForKey:tag] != nil);
}

- (void) tagInputReset
{
	tagInputTextField.text = @"";
    
	//tagInputTextField.placeholder = self.taskCopy.tag;
    tagInputTextField.placeholder = [self.taskCopy getCombinedTag];
	
	[tagInputTextField resignFirstResponder];
	
	TagDictionary *dict = [TagDictionary getInstance];
	
	int j = 0;
	
	NSDictionary *prjDict = [ProjectManager getProjectDictionaryByName];
	
	for (NSString *tag in [dict.presetTagDict allKeys])
	{
		[tagButtons[j] setTitle:tag forState:UIControlStateNormal];
		[tagButtons[j] setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[tagButtons[j] setEnabled:YES];
		
		Project *prj = [prjDict objectForKey:tag];
		
		if (prj != nil)
		{
			NSDictionary *tagDict = [TagDictionary getTagDict:prj.tag];
			
			if ([tagDict objectForKey:tag] != nil) //Project has the tag with the same name as Project name
			{
				[tagButtons[j] setTitleColor:[Common getColorByID:prj.colorId colorIndex:0]  forState:UIControlStateNormal];
			}
		}
		
		j++;
	}
	
	for (;j<9;j++)
	{
		[tagButtons[j] setTitle:@"" forState:UIControlStateNormal];
		
		[tagButtons[j] setEnabled:NO];
	}	
}

- (void) check2EnableSave
{
    saveButton.enabled = [self.taskCopy isShared] || self.taskCopy.name == nil || [self.taskCopy.name isEqualToString:@""]?NO:YES;
}

#pragma mark Actions

- (void) selectTag:(id) sender
{
	UIButton *tagButton = sender;
	
	NSString *tag = tagButton.titleLabel.text;
	
	if (tag != nil)
	{
        if (![self checkExistingTag:tag])
        {
            self.taskCopy.tag = [TagDictionary addTagToList:self.taskCopy.tag tag:tag];
        }
		
		[self tagInputReset];
	}		
}

- (void) editTag:(id) sender
{
	TagEditViewController *ctrler = [[TagEditViewController alloc] init];
	
	ctrler.objectEdit = self.taskCopy;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];		
	
}

- (void) enableDeadline:(id) sender
{
    deadlineEnabled = !deadlineEnabled;
    
    if (deadlineEnabled)
    {
        if (self.taskCopy.deadline == nil)
        {
            NSDate *dt = (self.taskCopy.startTime != nil? self.taskCopy.startTime:[NSDate date]);
            
            self.taskCopy.deadline = [[Settings getInstance] getWorkingEndTimeForDate:dt];
        }
    }
    else
    {
        self.taskCopy.deadline = nil;
        
        if ([taskCopy isTask])
        {
            taskCopy.alerts = [NSMutableArray arrayWithCapacity:0];
        }
        
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    
    [taskTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) selectContact:(id) sender
{
	ABPeoplePickerNavigationController *contactList=[[ABPeoplePickerNavigationController alloc] init];
	contactList.peoplePickerDelegate = self;

    contactList.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:contactList animated:YES completion:NULL];
    
	[contactList release];
}

- (void)save:(id) sender
{
    [titleTextView resignFirstResponder];
    //[taskLocation resignFirstResponder];

    UITableViewCell *cell = [taskTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                             
    UITextField *taskLocation = (UITextField * )[cell.contentView viewWithTag:10005];
    
    if (taskLocation != nil)
    {
        [taskLocation resignFirstResponder];
    }
    
    if (_plannerViewCtrler != nil)
    {
        [_plannerViewCtrler updateTask:self.task withTask:self.taskCopy];
    }
    else if (_abstractViewCtrler != nil)
    {
        [_abstractViewCtrler updateTask:self.task withTask:self.taskCopy];
    }
        
	[self.navigationController popViewControllerAnimated:YES];	
}
/*
- (void) convertRE2Task:(NSInteger)option
{
    TaskManager *tm = [TaskManager getInstance];
    
    BOOL isADE = [self.task isADE];
    
    Task *rt = [tm convertRE2Task:self.task option:option];
    
    //self.taskCopy.original = nil;
    self.taskCopy.primaryKey = rt.primaryKey;
    
    [tm updateTask:self.task withTask:self.taskCopy];
        
    [_abstractViewCtrler.miniMonthView refresh];
    
    if (isADE)
    {
        CalendarViewController *ctrler = [_abstractViewCtrler getCalendarViewController];
        
        [ctrler refreshADEPane];
    }
}
*/
- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertVw.tag == -10000)
	{
		self.taskCopy.project = self.task.project;
		[taskTableView reloadData];
	}
/*	else if (alertVw.tag == -11000)
	{
		if (buttonIndex > 0)
		{
            BOOL isADE = ([self.task isADE] || [self.taskCopy isADE]);
            
            if (buttonIndex == 2) //all series
            {
                if ([self.task.startTime compare:self.taskCopy.startTime] == NSOrderedSame && [self.task.endTime compare:self.taskCopy.endTime] == NSOrderedSame) //user does not change time -> keep root time
                {
                    self.taskCopy.startTime = task.original.startTime;
                    self.taskCopy.endTime = task.original.endTime;
                }
            }
            
			[[TaskManager getInstance] updateREInstance:self.task withRE:self.taskCopy updateOption:buttonIndex];	
            if (isADE)
            {
                [_abstractViewCtrler.miniMonthView.calView refreshADEView];
                
                CalendarViewController *ctrler = [_abstractViewCtrler getCalendarViewController];
                [ctrler refreshADEPane];
            }
            
            [_abstractViewCtrler.miniMonthView refresh];
		}
        
        [_abstractViewCtrler hidePopover];
		
		[self.navigationController popViewControllerAnimated:YES];
	}
	else if (alertVw.tag == -11002)
	{
        if (buttonIndex != 0)
        {
            [self convertRE2Task:buttonIndex];
        }
        
        [_abstractViewCtrler hidePopover];
        
        [self.navigationController popViewControllerAnimated:YES];
    }*/
    
}

#pragma mark Task Cell Creation
- (void) createTitleCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	//task title
    titleTextView.text = self.taskCopy.name;
    [cell.contentView addSubview:titleTextView];
    
    CGFloat y = [titleTextView getHeight];
    
    UIButton *contactButton = [UIButton buttonWithType:UIButtonTypeCustom];
    contactButton.frame = CGRectMake(5, y, 25, 25);
    [contactButton setBackgroundImage:[UIImage imageNamed:@"contact.png"] forState:UIControlStateNormal];
    [contactButton addTarget:self action:@selector(selectContact:) forControlEvents:UIControlEventTouchUpInside];
    contactButton.tag = baseTag + 4;
    
    [cell.contentView addSubview:contactButton];
    
	//task Location
	UITextField *taskLocation=[[UITextField alloc] initWithFrame:CGRectMake(35, y, 300-75, 26)];
	taskLocation.font=[UIFont systemFontOfSize:16];
	taskLocation.textColor=[UIColor brownColor];
	taskLocation.keyboardType=UIKeyboardTypeDefault;
	taskLocation.returnKeyType = UIReturnKeyDone;
	taskLocation.placeholder=_locationGuideText;//@"Location";
	taskLocation.textAlignment=NSTextAlignmentLeft;
	taskLocation.backgroundColor=[UIColor clearColor];
	taskLocation.clearButtonMode=UITextFieldViewModeWhileEditing;
	//taskLocation.enabled=NO;
	taskLocation.delegate=self;
	taskLocation.tag = baseTag + 5;
	taskLocation.text = self.taskCopy.location;
    
	[cell.contentView addSubview:taskLocation];
	[taskLocation release];
	
	UIButton *editTitleButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	editTitleButton.frame = CGRectMake(260, y/2, 30, 30);
	[editTitleButton addTarget:self action:@selector(editTitle:) forControlEvents:UIControlEventTouchUpInside];					
	
	editTitleButton.tag = baseTag + 3;
	
	[cell.contentView addSubview:editTitleButton];
}

- (void) createDurationCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	UILabel *durationLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 80, 30)];
	durationLabel.tag = baseTag + 1;
	durationLabel.text=_durationText;//@"Duration";
	durationLabel.backgroundColor=[UIColor clearColor];
	durationLabel.font=[UIFont boldSystemFontOfSize:16];
	durationLabel.textColor=[UIColor blackColor];
	
	[cell.contentView addSubview:durationLabel];
	[durationLabel release];
	
	//Duration
	durationValueLabel=[[UILabel alloc] initWithFrame:CGRectMake(90, 0, 175, 25)];
	durationValueLabel.tag = baseTag + 2;
	durationValueLabel.textAlignment=NSTextAlignmentRight;
	durationValueLabel.textColor= [Colors darkSteelBlue];
	durationValueLabel.font=[UIFont systemFontOfSize:15];
	durationValueLabel.backgroundColor=[UIColor clearColor];
	
	durationValueLabel.text = [Common getDurationString:self.taskCopy.duration];
	
	[cell.contentView addSubview:durationValueLabel];
	[durationValueLabel release];
	
	UIView *durationButtonView=[[UIView alloc] initWithFrame:CGRectMake(10, 25, 250, 25)];
	durationButtonView.backgroundColor=[UIColor clearColor];
	durationButtonView.tag = baseTag + 3;
	
	[cell.contentView addSubview:durationButtonView];
	[durationButtonView release];
	
	//Howlong icons
	
	UIButton *firstIconPeriod = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	firstIconPeriod.frame = CGRectMake(0, 0, 75, 25);
	firstIconPeriod.titleLabel.font = [UIFont systemFontOfSize:14];
	[firstIconPeriod setTitle:_15minText forState:UIControlStateNormal];
	[firstIconPeriod setTitleColor:[UIColor brownColor]  forState:UIControlStateNormal];	
	[firstIconPeriod setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[firstIconPeriod setBackgroundImage:[[ImageManager getInstance] getImageWithName:@"1-mash-white.png"] forState:UIControlStateNormal];
	[firstIconPeriod setBackgroundImage:[[ImageManager getInstance] getImageWithName:@"1-mash-blue.png"] forState:UIControlStateSelected];
	[firstIconPeriod addTarget:self action:@selector(changeDuration:) forControlEvents:UIControlEventTouchUpInside];
	firstIconPeriod.tag = baseTag + 4;
	firstIconPeriod.selected = (self.taskCopy.duration == 900);
	
	[durationButtonView addSubview:firstIconPeriod];
	
	UIButton *secondIconPeriod = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	secondIconPeriod.frame = CGRectMake(85, 0, 75, 25);
	secondIconPeriod.titleLabel.font = [UIFont systemFontOfSize:14];					
	[secondIconPeriod setTitle:_1hourText forState:UIControlStateNormal];
	[secondIconPeriod setTitleColor:[UIColor brownColor]  forState:UIControlStateNormal];	
	[secondIconPeriod setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[secondIconPeriod setBackgroundImage:[[ImageManager getInstance] getImageWithName:@"2-mash-white.png"] forState:UIControlStateNormal];
	[secondIconPeriod setBackgroundImage:[[ImageManager getInstance] getImageWithName:@"2-mash-blue.png"] forState:UIControlStateSelected];
	[secondIconPeriod addTarget:self action:@selector(changeDuration:) forControlEvents:UIControlEventTouchUpInside];
	secondIconPeriod.tag = baseTag + 5;
	secondIconPeriod.selected = (self.taskCopy.duration == 3600);					
	
	[durationButtonView addSubview:secondIconPeriod];
	
	UIButton *thirdIconPeriod = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	thirdIconPeriod.frame = CGRectMake(170, 0, 75, 25);
	thirdIconPeriod.titleLabel.font = [UIFont systemFontOfSize:14];					
	[thirdIconPeriod setTitle:_3hourText forState:UIControlStateNormal];
	[thirdIconPeriod setTitleColor:[UIColor brownColor]  forState:UIControlStateNormal];	
	[thirdIconPeriod setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[thirdIconPeriod setBackgroundImage:[[ImageManager getInstance] getImageWithName:@"3-mash-white.png"] forState:UIControlStateNormal];
	[thirdIconPeriod setBackgroundImage:[[ImageManager getInstance] getImageWithName:@"3-mash-blue.png"] forState:UIControlStateSelected];
	[thirdIconPeriod addTarget:self action:@selector(changeDuration:) forControlEvents:UIControlEventTouchUpInside];
	thirdIconPeriod.tag = baseTag + 6;
	thirdIconPeriod.selected = (self.taskCopy.duration == 10800);						
	
	[durationButtonView addSubview:thirdIconPeriod];
	
	selectedDurationButton = nil;
	if (firstIconPeriod.selected)
	{
		selectedDurationButton = firstIconPeriod;
	}
	else if (secondIconPeriod.selected)
	{
		selectedDurationButton = secondIconPeriod;
	}
	else if (thirdIconPeriod.selected)
	{
		selectedDurationButton = thirdIconPeriod;
	}
	
	UIButton *editDurationButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	editDurationButton.frame = CGRectMake(260, 0, 40, 60);
	editDurationButton.tag = baseTag + 7;
	[editDurationButton addTarget:self action:@selector(editDuration:) forControlEvents:UIControlEventTouchUpInside];
	
	[cell.contentView addSubview:editDurationButton];	
}

- (void) createDeadlineCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	UILabel *deadlineLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, deadlineEnabled?0:5, 60, 30)];
	deadlineLabel.tag = baseTag + 1;
	deadlineLabel.text=_dueText;
	deadlineLabel.backgroundColor=[UIColor clearColor];
	deadlineLabel.font=[UIFont boldSystemFontOfSize:16];
	deadlineLabel.textColor=[UIColor blackColor];
	
	[cell.contentView addSubview:deadlineLabel];
	[deadlineLabel release];
    	
	deadlineValueLabel=[[UILabel alloc] initWithFrame:CGRectMake(50, deadlineEnabled?0:5, 215, 25)];
	deadlineValueLabel.tag = baseTag + 2;
	deadlineValueLabel.textAlignment=NSTextAlignmentRight;
	deadlineValueLabel.textColor= [Colors darkSteelBlue];
	deadlineValueLabel.font=[UIFont systemFontOfSize:15];
	deadlineValueLabel.backgroundColor=[UIColor clearColor];
	
	deadlineValueLabel.text = (self.taskCopy.deadline == nil? _noneText: [Common getFullDateString3:self.taskCopy.deadline]);
	
	[cell.contentView addSubview:deadlineValueLabel];
	[deadlineValueLabel release];
	
	UIView *deadlineButtonView=[[UIView alloc] initWithFrame:CGRectMake(10, 25, 250, 25)];
	deadlineButtonView.backgroundColor=[UIColor clearColor];
	deadlineButtonView.tag = baseTag + 3;
    deadlineButtonView.hidden = !deadlineEnabled;
	
	[cell.contentView addSubview:deadlineButtonView];
	[deadlineButtonView release];
	
	UIButton *firstIconPeriod = [Common createButton:_todayText 
										  buttonType:UIButtonTypeCustom
											   //frame:CGRectMake(0, 0, 75, 25)
                                 frame:CGRectMake(0, 0, 55, 25)
										  titleColor:[UIColor whiteColor] 
											  target:self 
											selector:@selector(changeDeadline:) 
									normalStateImage:@"gray_button.png"
								  selectedStateImage:@"blue_button.png"];
	firstIconPeriod.tag = baseTag + 4;
	
	firstIconPeriod.selected = (self.taskCopy.deadline != nil && 
								//[Common compareDateNoTime:self.taskCopy.deadline withDate:[NSDate date]] == NSOrderedSame);
                                [Common daysBetween:self.taskCopy.deadline sinceDate:[NSDate date]] == 0);
    
	[deadlineButtonView addSubview:firstIconPeriod];
	
	UIButton *secondIconPeriod = [Common createButton:[NSString stringWithFormat:@"+ %@", _1DayText]//_tomorrowText
										   buttonType:UIButtonTypeCustom
												//frame:CGRectMake(85, 0, 75, 25)
                                  frame:CGRectMake(60, 0, 60, 25)
										   titleColor:[UIColor whiteColor] 
											   target:self 
											 selector:@selector(changeDeadline:) 
									 normalStateImage:@"gray_button.png"
								   selectedStateImage:@"blue_button.png"];	
	secondIconPeriod.tag = baseTag + 5;
	
	secondIconPeriod.selected = (self.taskCopy.deadline != nil && 
								 //[Common compareDateNoTime:self.taskCopy.deadline withDate:[Common dateByAddNumDay:1 toDate:[NSDate date]]] == NSOrderedSame);
                                 [Common daysBetween:self.taskCopy.deadline sinceDate:[NSDate date]] == 1);
	
	[deadlineButtonView addSubview:secondIconPeriod];
	
	UIButton *thirdIconPeriod = [Common createButton:[NSString stringWithFormat:@"+ %@", _weekText]//_oneWeekText
										  buttonType:UIButtonTypeCustom
											   //frame:CGRectMake(170, 0, 75, 25)
                                 frame:CGRectMake(125, 0, 60, 25)
										  titleColor:[UIColor whiteColor] 
											  target:self 
											selector:@selector(changeDeadline:) 
									normalStateImage:@"gray_button.png"
								  selectedStateImage:@"blue_button.png"];		
	thirdIconPeriod.tag = baseTag + 6;
	
	thirdIconPeriod.selected = (self.taskCopy.deadline != nil && 
								//[Common compareDateNoTime:self.taskCopy.deadline withDate:[Common dateByAddNumDay:7 toDate:[NSDate date]]] == NSOrderedSame);
                                [Common daysBetween:self.taskCopy.deadline sinceDate:[NSDate date]] == 7);
	
	[deadlineButtonView addSubview:thirdIconPeriod];
	
	UIButton *fourthIconPeriod = [Common createButton:[NSString stringWithFormat:@"+ %@", _monthText]
										  buttonType:UIButtonTypeCustom
                                 //frame:CGRectMake(170, 0, 75, 25)
                                               frame:CGRectMake(190, 0, 60, 25)
										  titleColor:[UIColor whiteColor]
											  target:self
											selector:@selector(changeDeadline:)
									normalStateImage:@"gray_button.png"
								  selectedStateImage:@"blue_button.png"];
	fourthIconPeriod.tag = baseTag + 7;
	
	fourthIconPeriod.selected = (self.taskCopy.deadline != nil &&
								//[Common compareDateNoTime:self.taskCopy.deadline withDate:[Common dateByAddNumDay:7 toDate:[NSDate date]]] == NSOrderedSame);
                                [Common daysBetween:self.taskCopy.deadline sinceDate:[NSDate date]] == 30);
	
	[deadlineButtonView addSubview:fourthIconPeriod];
    
	selectedDeadlineButton = nil;
	if (firstIconPeriod.selected)
	{
		selectedDeadlineButton = firstIconPeriod;
	}
	else if (secondIconPeriod.selected)
	{
		selectedDeadlineButton = secondIconPeriod;
	}
	else if (thirdIconPeriod.selected)
	{
		selectedDeadlineButton = thirdIconPeriod;
	}
	
	UIButton *editDeadlineButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	editDeadlineButton.frame = CGRectMake(265, deadlineEnabled?10:5, 30, 30);
	editDeadlineButton.tag = baseTag + 7;
	[editDeadlineButton addTarget:self action:@selector(editDeadline:) forControlEvents:UIControlEventTouchUpInside];
	
	[cell.contentView addSubview:editDeadlineButton];
    
	UIButton *deadlineCheckButton = [Common createButton:@""
                                    buttonType:UIButtonTypeCustom
                                         frame:CGRectMake(40, deadlineEnabled?-1:5, 30, 30)
                                    titleColor:[UIColor whiteColor]
                                        target:self
                                      selector:@selector(enableDeadline:)
                              normalStateImage:@"Trans_CheckOff.png"
                            selectedStateImage:@"Trans_CheckOn.png"];
    deadlineCheckButton.tag = baseTag + 8;
    
    deadlineCheckButton.selected = deadlineEnabled;
	
	[cell.contentView addSubview:deadlineCheckButton];
    
}
- (void) createProjectCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.textLabel.text = _projectText;
	
	ProjectManager *pm = [ProjectManager getInstance];
	
	Project *prj = [pm getProjectByKey:self.taskCopy.project];
	
	UILabel *projectNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(90, 0, 175, 35)];
	projectNameLabel.tag = baseTag + 1;
	projectNameLabel.textAlignment=NSTextAlignmentRight;
	projectNameLabel.backgroundColor=[UIColor clearColor];
	projectNameLabel.font=[UIFont systemFontOfSize:15];
	
	if (prj != nil)
	{
		projectNameLabel.text = prj.name;
		projectNameLabel.textColor = [Common getColorByID:prj.colorId colorIndex:0];
	}
	
	[cell.contentView addSubview:projectNameLabel];
	[projectNameLabel release];
}

- (void) createNoteCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.text = _descriptionText;
	
	UILabel *taskNoteLabel=[[UILabel alloc] initWithFrame:CGRectMake(105, 2, 160, 35)];
	taskNoteLabel.tag = baseTag + 1;
	taskNoteLabel.textAlignment=NSTextAlignmentRight;
	taskNoteLabel.backgroundColor=[UIColor clearColor];
	taskNoteLabel.textColor = [Colors darkSteelBlue];
	taskNoteLabel.font=[UIFont systemFontOfSize:15];
	taskNoteLabel.text = taskCopy.note;
	
	[cell.contentView addSubview:taskNoteLabel];
	[taskNoteLabel release];	
}

- (void) createTagCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	UILabel *tagLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 30)];
	tagLabel.tag = baseTag + 1;
	tagLabel.text=_tagText;
	tagLabel.backgroundColor=[UIColor clearColor];
	tagLabel.font=[UIFont boldSystemFontOfSize:16];
	tagLabel.textColor=[UIColor blackColor];
	
	[cell.contentView addSubview:tagLabel];
	[tagLabel release];	
	
	tagInputTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 5, 220, 25)];
	tagInputTextField.tag = baseTag + 2;
	tagInputTextField.textAlignment=NSTextAlignmentLeft;
	tagInputTextField.backgroundColor=[UIColor clearColor];
	tagInputTextField.textColor = [Colors darkSteelBlue];
	tagInputTextField.font=[UIFont systemFontOfSize:15];
	//tagInputTextField.text = taskCopy.tag;
	tagInputTextField.placeholder=_tagGuideText;
	tagInputTextField.keyboardType=UIKeyboardTypeDefault;
	tagInputTextField.returnKeyType = UIReturnKeyDone;
	tagInputTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
	tagInputTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;

	tagInputTextField.delegate = self;
	
	[cell.contentView addSubview:tagInputTextField];
	[tagInputTextField release];	

	UIButton *tagDetailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	tagDetailButton.frame = CGRectMake(270, 0, 25, 25);
	tagDetailButton.tag = baseTag + 3;
	[tagDetailButton addTarget:self action:@selector(editTag:) forControlEvents:UIControlEventTouchUpInside];
	[cell.contentView addSubview:tagDetailButton];
	
	for (int i=0; i<9; i++)
	{
		int div = i/3;
		int mod = i%3;
		
		UIButton *tagButton = [Common createButton:@"" 
										buttonType:UIButtonTypeCustom
											 frame:CGRectMake(mod*100 + 5, div*30 + 30, 90, 25)
										titleColor:[UIColor blackColor]
											target:self 
										  selector:@selector(selectTag:) 
								  normalStateImage:@"sort_button.png"
								selectedStateImage:nil];
		tagButton.tag = baseTag + 4 +i;
		
		[cell.contentView addSubview:tagButton];
		
		tagButtons[i] = tagButton;
	}
    
	[self tagInputReset];
}

- (void) createAlertCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.text = _alertsText;
}	

- (void) createStartCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	UILabel *startLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 30)];
	startLabel.tag = baseTag + 1;
	startLabel.text=_startText;
	startLabel.backgroundColor=[UIColor clearColor];
	startLabel.font=[UIFont boldSystemFontOfSize:16];
	startLabel.textColor=[UIColor blackColor];
	
	[cell.contentView addSubview:startLabel];
	[startLabel release];
	
	startValueLabel=[[UILabel alloc] initWithFrame:CGRectMake(50, 0, 215, 25)];
	startValueLabel.tag = baseTag + 2;
	startValueLabel.textAlignment=NSTextAlignmentRight;
	startValueLabel.textColor= [Colors darkSteelBlue];
	startValueLabel.font=[UIFont systemFontOfSize:15];
	startValueLabel.backgroundColor=[UIColor clearColor];
	
	startValueLabel.text = (self.taskCopy.startTime == nil? _noneText: [Common getFullDateString3:self.taskCopy.startTime]);
	
	[cell.contentView addSubview:startValueLabel];
	[startValueLabel release];
	
	UIView *startButtonView=[[UIView alloc] initWithFrame:CGRectMake(10, 25, 250, 25)];
	startButtonView.backgroundColor=[UIColor clearColor];
	startButtonView.tag = baseTag + 3;
	
	[cell.contentView addSubview:startButtonView];
	[startButtonView release];
	
	UIButton *firstIconPeriod = [Common createButton:_todayText 
										  buttonType:UIButtonTypeCustom
											   //frame:CGRectMake(0, 0, 75, 25)
                                 frame:CGRectMake(0, 0, 55, 25)
										  titleColor:[UIColor whiteColor] 
											  target:self 
											selector:@selector(changeStart:) 
									normalStateImage:@"gray_button.png"
								  selectedStateImage:@"blue_button.png"];	
	firstIconPeriod.tag = baseTag + 4;
	
	firstIconPeriod.selected = (self.taskCopy.startTime != nil && 
								//[Common compareDateNoTime:self.taskCopy.startTime withDate:[NSDate date]] == NSOrderedSame);
                                [Common daysBetween:self.taskCopy.startTime sinceDate:[NSDate date]] == 0);
	
	[startButtonView addSubview:firstIconPeriod];
	
	UIButton *secondIconPeriod = [Common createButton:[NSString stringWithFormat:@"+ %@", _1DayText] //_tomorrowText
										   buttonType:UIButtonTypeCustom
												//frame:CGRectMake(85, 0, 75, 25)
                                  frame:CGRectMake(60, 0, 60, 25)
										   titleColor:[UIColor whiteColor] 
											   target:self 
											 selector:@selector(changeStart:) 
									 normalStateImage:@"gray_button.png"
								   selectedStateImage:@"blue_button.png"];	
	secondIconPeriod.tag = baseTag + 5;
	
	secondIconPeriod.selected = (self.taskCopy.startTime != nil && 				
								 //[Common compareDateNoTime:self.taskCopy.startTime withDate:[Common dateByAddNumDay:1 toDate:[NSDate date]]] == NSOrderedSame);
                                 [Common daysBetween:self.taskCopy.startTime sinceDate:[NSDate date]] == 1);
	
	[startButtonView addSubview:secondIconPeriod];
	
	UIButton *thirdIconPeriod = [Common createButton:[NSString stringWithFormat:@"+ %@", _weekText]//_oneWeekText
										  buttonType:UIButtonTypeCustom
											   //frame:CGRectMake(170, 0, 75, 25)
                                 frame:CGRectMake(125, 0, 60, 25)
										  titleColor:[UIColor whiteColor] 
											  target:self 
											selector:@selector(changeStart:) 
									normalStateImage:@"gray_button.png"
								  selectedStateImage:@"blue_button.png"];		
	thirdIconPeriod.tag = baseTag + 6;
    
	thirdIconPeriod.selected = (self.taskCopy.startTime != nil && 
								//[Common compareDateNoTime:self.taskCopy.startTime withDate:[Common dateByAddNumDay:7 toDate:[NSDate date]]] == NSOrderedSame);
                                [Common daysBetween:self.taskCopy.startTime sinceDate:[NSDate date]] == 7);
	
	[startButtonView addSubview:thirdIconPeriod];
    
	UIButton *fourthIconPeriod = [Common createButton:[NSString stringWithFormat:@"+ %@", _monthText]
										  buttonType:UIButtonTypeCustom
                                               frame:CGRectMake(190, 0, 60, 25)
										  titleColor:[UIColor whiteColor]
											  target:self
											selector:@selector(changeStart:)
									normalStateImage:@"gray_button.png"
								  selectedStateImage:@"blue_button.png"];
	fourthIconPeriod.tag = baseTag + 7;
	
	fourthIconPeriod.selected = (self.taskCopy.startTime != nil &&
								[Common daysBetween:self.taskCopy.startTime sinceDate:[NSDate date]] == 30);
	
	[startButtonView addSubview:fourthIconPeriod];    
	
	selectedStartButton = nil;
	if (firstIconPeriod.selected)
	{
		selectedStartButton = firstIconPeriod;
	}
	else if (secondIconPeriod.selected)
	{
		selectedStartButton = secondIconPeriod;
	}
	else if (thirdIconPeriod.selected)
	{
		selectedStartButton = thirdIconPeriod;
	}
	
	UIButton *editStartButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	editStartButton.frame = CGRectMake(260, 0, 40, 60);
	editStartButton.tag = baseTag + 7;
	[editStartButton addTarget:self action:@selector(editStart:) forControlEvents:UIControlEventTouchUpInside];
	
	[cell.contentView addSubview:editStartButton];	
}

- (void) createLinkCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    Task *tmp = (self.task.original != nil && ![self.task isREException])?self.task.original:self.task;
        
    cell.textLabel.text = _linksText;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
	UILabel *label = [[UILabel alloc] initWithFrame:(self.taskCopy.primaryKey == -1?CGRectZero:CGRectMake(210, 5, 60, 25))];
	label.tag = baseTag;
	//label.text = [NSString stringWithFormat:@"%d links", self.taskCopy.links.count];
    label.text = [NSString stringWithFormat:@"%d links", tmp.links.count];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [Colors darkSteelBlue];
    label.textAlignment = NSTextAlignmentRight;
	
	[cell.contentView addSubview:label];
	[label release];	
    
}

#pragma mark Event Cell Creation
- (void) createWhenCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	UILabel *startLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 25)];
	startLabel.tag = baseTag + 1;
	startLabel.text=_startText;
	startLabel.backgroundColor=[UIColor clearColor];
	startLabel.font=[UIFont boldSystemFontOfSize:16];
	startLabel.textColor=[UIColor blackColor];
	
	[cell.contentView addSubview:startLabel];
	[startLabel release];
	
	UILabel *startValLabel=[[UILabel alloc] initWithFrame:CGRectMake(60, 0, 205, 25)];
	startValLabel.tag = baseTag + 2;
	startValLabel.textAlignment=NSTextAlignmentRight;
	startValLabel.textColor= [Colors darkSteelBlue];
	startValLabel.font=[UIFont systemFontOfSize:15];
	startValLabel.backgroundColor=[UIColor clearColor];
	
	startValLabel.text = [self.taskCopy isADE]?[Common getFullDateString3:self.taskCopy.startTime]
							:[Common getFullDateTimeString:self.taskCopy.startTime];
	
	[cell.contentView addSubview:startValLabel];
	[startValLabel release];
	
	UILabel *endLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 25, 60, 25)];
	endLabel.tag = baseTag + 3;
	endLabel.text=_endText;
	endLabel.backgroundColor=[UIColor clearColor];
	endLabel.font=[UIFont boldSystemFontOfSize:16];
	endLabel.textColor=[UIColor blackColor];
	
	[cell.contentView addSubview:endLabel];
	[endLabel release];
	
	UILabel *endValueLabel=[[UILabel alloc] initWithFrame:CGRectMake(60, 25, 205, 25)];
	endValueLabel.tag = baseTag + 4;
	endValueLabel.textAlignment=NSTextAlignmentRight;
	endValueLabel.textColor= [Colors darkSteelBlue];
	endValueLabel.font=[UIFont systemFontOfSize:15];
	endValueLabel.backgroundColor=[UIColor clearColor];
	
	endValueLabel.text = [self.taskCopy isADE]?[Common getFullDateString3:self.taskCopy.endTime]
						:[Common getFullDateTimeString:self.taskCopy.endTime];
	
	[cell.contentView addSubview:endValueLabel];
	[endValueLabel release];
}

- (void) createRepeatCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.accessoryType = [self.taskCopy isREException]?UITableViewCellAccessoryNone: UITableViewCellAccessoryDisclosureIndicator;
		
	UILabel *repeatLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 80, 25)];
	repeatLabel.tag = baseTag + 1;
	repeatLabel.text=_repeatText;
	repeatLabel.backgroundColor=[UIColor clearColor];
	repeatLabel.font=[UIFont boldSystemFontOfSize:16];
	repeatLabel.textColor=[UIColor blackColor];
	
	[cell.contentView addSubview:repeatLabel];
	[repeatLabel release];
	
	UILabel *repeatValueLabel=[[UILabel alloc] initWithFrame:CGRectMake(60, 0, 205, 25)];
	repeatValueLabel.tag = baseTag + 2;
	repeatValueLabel.textAlignment=NSTextAlignmentRight;
	repeatValueLabel.textColor= [Colors darkSteelBlue];
	repeatValueLabel.font=[UIFont systemFontOfSize:15];
	repeatValueLabel.backgroundColor=[UIColor clearColor];
	
	repeatValueLabel.text = [self.taskCopy getRepeatTypeString];
	
	[cell.contentView addSubview:repeatValueLabel];
	[repeatValueLabel release];
	
	UILabel *repeatUntilLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 25, 120, 25)];
	repeatUntilLabel.tag = baseTag + 3;
	repeatUntilLabel.text=_untilText;
	repeatUntilLabel.backgroundColor=[UIColor clearColor];
	repeatUntilLabel.font=[UIFont boldSystemFontOfSize:16];
	repeatUntilLabel.textColor=[UIColor blackColor];
	
	[cell.contentView addSubview:repeatUntilLabel];
	[repeatUntilLabel release];
	
	UILabel *repeatUntilValueLabel=[[UILabel alloc] initWithFrame:CGRectMake(60, 25, 205, 25)];
	repeatUntilValueLabel.tag = baseTag + 4;
	repeatUntilValueLabel.textAlignment=NSTextAlignmentRight;
	repeatUntilValueLabel.textColor= [Colors darkSteelBlue];
	repeatUntilValueLabel.font=[UIFont systemFontOfSize:15];
	repeatUntilValueLabel.backgroundColor=[UIColor clearColor];
	
	repeatUntilValueLabel.text = [self.taskCopy getRepeatUntilString];
	
	[cell.contentView addSubview:repeatUntilValueLabel];
	[repeatUntilValueLabel release];
}

- (void) createADECell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _allDayText;
	
	UISegmentedControl *adeSegmentedControl = [[UISegmentedControl alloc] initWithItems:
											   [NSArray arrayWithObjects:_onText, _offText,nil]];
	adeSegmentedControl.tag = baseTag + 1;
	
	[adeSegmentedControl addTarget:self action:@selector(changeEventType:) forControlEvents:UIControlEventValueChanged];
	adeSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBordered;
	adeSegmentedControl.selectedSegmentIndex = (self.taskCopy.type == TYPE_ADE?0:1);
	adeSegmentedControl.tintColor = [UIColor blueColor];
	
	adeSegmentedControl.frame = CGRectMake(190, 5, 100, 30);
	
	[cell.contentView addSubview:adeSegmentedControl];
	[adeSegmentedControl release];	
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {	
	return _isiPad?(showMore?3:2):2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    /*if (tableView == taskTableView && section == 0)
	{
		return (taskTypeSegmentedControl.selectedSegmentIndex == 0? 10: 9);
	}*/
    
    if (section == 0)
    {
        return (taskTypeSegmentedControl.selectedSegmentIndex == 0? 5: 4);
    }
    else if (section == 1)
    {
        return showMore?5:1;
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView == taskTableView)
	{
        if (indexPath.section == 1 && showMore)
        {
            if (self.taskCopy.primaryKey == -1 && indexPath.row == 3)
            {
                return 0; //don't allow Links
            }
            
            if (indexPath.row == 4) // tag cell
            {
                return 120;
            }
            
            if (indexPath.row == 0) // repeat cell
            {
                return 55;
            }
        }
        else if (indexPath.section == 0)
        {
            if (indexPath.row == 0)
            {
                CGFloat h = [titleTextView getHeight];
                
                return h + 30;
            }
            
            if (taskTypeSegmentedControl.selectedSegmentIndex == 0 && indexPath.row >= 1 && indexPath.row <= 3)
            {
                if (indexPath.row == 3 && deadlineEnabled == NO)
                {
                    return 40;
                }
                
                return 55;
            }
            
            //if (taskTypeSegmentedControl.selectedSegmentIndex == 1 && indexPath.row >= 1 && indexPath.row <= 1)
            if (taskTypeSegmentedControl.selectedSegmentIndex == 1 && indexPath.row == 1)
            {
                Settings *settings = [Settings getInstance];
                
                return settings.timeZoneSupport?75:55;
            }            
        }
	}
	
	return 40; 
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UITableViewCell *cell = nil;
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	/*else
	{
		for(UIView *view in cell.contentView.subviews)
		{
			if(view.tag >= 10000)
			{
				[view removeFromSuperview];
			}
		}		
	}*/
    
    // Set up the cell...
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.textLabel.text = @"";
	cell.textLabel.backgroundColor = [UIColor clearColor];
    
    
    switch (indexPath.section)
    {
        case 0:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    [self createTitleCell:cell baseTag:10000];
                }
                    break;
                case 1:
                {
                    taskTypeSegmentedControl.selectedSegmentIndex == 0? [self createDurationCell:cell baseTag:10010]:[self createWhenCell:cell baseTag:10110];
                }
                    break;
                case 2:
                {
                    taskTypeSegmentedControl.selectedSegmentIndex == 0? [self createStartCell:cell baseTag:10020]:[self createADECell:cell baseTag:10120];
                }
                    break;
                case 3:
                {
                    taskTypeSegmentedControl.selectedSegmentIndex == 0? [self createDeadlineCell:cell baseTag:10030]:[self createProjectCell:cell baseTag:10130];
                }
                    break;
                case 4:
                {
                    taskTypeSegmentedControl.selectedSegmentIndex == 1? :[self createProjectCell:cell baseTag:10040];
                }
                    break;
            }
        }
            break;
        case 1:
        {
            if (showMore)
            {
                switch (indexPath.row)
                {
                    case 0:
                    {
                        [self createRepeatCell:cell baseTag:11000];
                    }
                        break;
                    case 1:
                    {
                        [self createNoteCell:cell baseTag:11010];
                    }
                        break;
                    case 2:
                    {
                        [self createAlertCell:cell baseTag:11020];
                    }
                        break;
                    case 3:
                    {
                        [self createLinkCell:cell baseTag:11030];
                    }
                        break;
                    case 4:
                    {
                        [self createTagCell:cell baseTag:11040];
                    }
                        break;
                }
            }
            else
            {
                UILabel *showMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
                showMoreLabel.backgroundColor = [UIColor clearColor];
                showMoreLabel.font = [UIFont boldSystemFontOfSize:16];
                showMoreLabel.userInteractionEnabled = NO;

                showMoreLabel.textAlignment = NSTextAlignmentCenter;
                showMoreLabel.text = _showMoreText;
                
                showMoreLabel.tag = 11000;
                
                [cell.contentView addSubview:showMoreLabel];
                [showMoreLabel release];
                
            }
        }
            break;
        case 2:
        {
            if (indexPath.row == 0)
            {
                cell.textLabel.text = _timerHistoryText;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
            break;
    }
	
	return cell;
}	

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];

	if (indexPath.section == 0)
	{
		switch (indexPath.row)
		{
			case 1:
				taskTypeSegmentedControl.selectedSegmentIndex == 0?:[self editWhen];
				break;
			case 3:
				taskTypeSegmentedControl.selectedSegmentIndex == 0?:[self editProject];
				break;
			case 4:
				taskTypeSegmentedControl.selectedSegmentIndex == 1?:[self editProject];
            break;
        }
    }
    else if (indexPath.section == 1)
    {
        if (!showMore)
        {
            showMore = YES;
            
            [taskTableView reloadData];
        }
        else
        {
            switch (indexPath.row)
            {
                case 0:
                    [self editRepeat];
                    break;
                case 1:
                    [self editNote];
                    break;
                case 2:
                    [self editAlert];
                    break;
                case 3:
                    [self editLink];
                    break;
            }
        }
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            [self showTimerHistory];
        }
    }
    
}


#pragma mark TextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

	return YES;	
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if (textField.tag == 10001) //edit title
	{
		NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		
		/*if ([text isEqualToString:@""])
		{
			saveButton.enabled = NO;
		}
		else
		{
			saveButton.enabled = YES;
		}
		*/
        
		self.taskCopy.name = text;
        
        [self check2EnableSave];
	}
	else if (textField.tag == 10005) //edit location
    {
		NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        self.taskCopy.location = text;
    }
	//else if (textField.tag == 11800 + 2 || textField.tag == 10900 + 2) //edit tag
    else if (textField.tag == 11040 + 2)
	{
		NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		
		if (![text isEqualToString:@""])
		{
            if (![self checkExistingTag:text])
            {
                self.taskCopy.tag = [TagDictionary addTagToList:self.taskCopy.tag tag:text];
            }
		}
		
		[self tagInputReset];
	}
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	//if (textField.tag == 11800 + 2 || textField.tag == 10900 + 2) //tag
    if (textField.tag == 11040 + 2)
	{
		[self scroll];
	}
	else if (textField.tag == 10001) //edit title
	{
		saveButton.enabled = NO;
		
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		UITableViewCell *cell = [taskTableView cellForRowAtIndexPath:indexPath];
		
		UIButton *editTitleButton = (UIButton *) [cell.contentView viewWithTag:10002];
		editTitleButton.enabled = NO;
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	//if (textField.tag == 11800 + 2 || textField.tag == 10900 + 2)
    if (textField.tag == 11040 + 2)
	{
		NSString *s = [textField.text stringByReplacingCharactersInRange:range withString:string];	
		
		TagDictionary *dict = [TagDictionary getInstance];
		
		NSArray *tags = [dict findTags:s];
		
		int j = 0;
		
		for (NSString *tag in tags)
		{
			[tagButtons[j] setTitle:tag forState:UIControlStateNormal];
			[tagButtons[j] setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [tagButtons[j] setEnabled:YES];            
			j++;
			
			if (j == 8)
			{
				break;
			}
		}	
		
		for (;j<9;j++)
		{
			[tagButtons[j] setTitle:@"" forState:UIControlStateNormal];
			[tagButtons[j] setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [tagButtons[j] setEnabled:NO];
		}		
	}
	
	return YES;
}

#pragma mark ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
	//[peoplePicker dismissModalViewControllerAnimated:YES];
    [peoplePicker dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
	CFStringRef firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
	CFStringRef lastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
	CFStringRef company = ABRecordCopyValue(person, kABPersonOrganizationProperty);
	
	if (firstName==nil && lastName==nil && company==nil){
		firstName=(CFStringRef)_nonameText;
		lastName=(CFStringRef)@" ";
		company=(CFStringRef)@" ";
	}else{
		if(firstName==nil) {
			firstName=(CFStringRef) @" ";
		}
		if(lastName==nil){
			lastName=(CFStringRef)@" ";
		}
		if(company==nil){
			company=(CFStringRef)@" ";
		}
		
	}
	
	NSString *contactName=[NSString stringWithFormat:@"%@ %@",firstName, lastName];
	contactName=[contactName stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];//remove new line character;
	contactName=[contactName stringByReplacingOccurrencesOfString:@"\n" withString:@" "];//remove new line character;
	contactName=[contactName stringByReplacingOccurrencesOfString:@"\r" withString:@" "];//remove new line character;
	
	NSString *contactComName=[NSString stringWithFormat:@"%@",company];
	contactComName=[contactComName stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];//remove new line character;
	contactComName=[contactComName stringByReplacingOccurrencesOfString:@"\n" withString:@" "];//remove new line character;
	contactComName=[contactComName stringByReplacingOccurrencesOfString:@"\r" withString:@" "];//remove new line character;
	
	if ([[contactName stringByReplacingOccurrencesOfString:@" " withString:@""] length]==0) {
		contactName=contactComName;
	}
	
	self.taskCopy.contactName=contactName;
	
	//get PHONE NUMBER from contact
	NSString *phoneNumber=@"";
	ABMutableMultiValueRef phoneEmailValue = ABRecordCopyValue(person, kABPersonPhoneProperty);
	if(ABMultiValueGetCount(phoneEmailValue)>0){
		phoneNumber=@"";
		
		for(NSInteger i=0;i<ABMultiValueGetCount(phoneEmailValue);i++){
			CFStringRef phoneNo = ABMultiValueCopyValueAtIndex(phoneEmailValue, i);
			CFStringRef label=ABMultiValueCopyLabelAtIndex(phoneEmailValue, i);
			
			if(label==nil){
				label=(CFStringRef)@" ";
			}
			
			if(phoneNo==nil){
				phoneNo=(CFStringRef)@" ";
			}
			phoneNumber=[phoneNumber stringByAppendingFormat:@"/%@|%@",label,phoneNo];
		}
		
	}
	CFRelease(phoneEmailValue);
	self.taskCopy.contactPhone=phoneNumber;
	
	NSString *contactAddress=nil;
	//get first address for this contact
	ABMutableMultiValueRef multiValue = ABRecordCopyValue(person, kABPersonAddressProperty);
	
	if(ABMultiValueGetCount(multiValue)>0){
		
		//get all address from the contact
		CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(multiValue, 0);
		CFStringRef street = CFDictionaryGetValue(dict, kABPersonAddressStreetKey);
		CFStringRef city = CFDictionaryGetValue(dict, kABPersonAddressCityKey);
		CFStringRef country = CFDictionaryGetValue(dict, kABPersonAddressCountryKey);
		CFStringRef state = CFDictionaryGetValue(dict,kABPersonAddressStateKey);
		CFStringRef zip = CFDictionaryGetValue(dict,kABPersonAddressZIPKey);
		
		CFRelease(dict);
		
		if(street!=nil){
			contactAddress=[NSString stringWithFormat:@"%@",street];
		}else {
			contactAddress=@"";
		}
		
		if(city!=nil){
			if(street!=nil){
				NSString *cityNameAppend=[NSString stringWithFormat:@", %@",city];
				contactAddress=[contactAddress stringByAppendingString:cityNameAppend];
			}else{
				NSString *cityNameAsLoc=[NSString stringWithFormat:@"%@",city];
				contactAddress=[contactAddress stringByAppendingString:cityNameAsLoc];
			}
		}
		
		if(country!=nil){
			if(![contactAddress isEqualToString:@""]){
				NSString *countryNameAppend=[NSString stringWithFormat:@", %@",country];
				contactAddress=[contactAddress stringByAppendingString:countryNameAppend];
			}else{
				NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",country];
				contactAddress=[contactAddress stringByAppendingString:countryNameAsLoc];
			}
		}
		
		if(state !=nil){
			if(![contactAddress isEqualToString:@""]){
				NSString *countryNameAppend=[NSString stringWithFormat:@", %@",state];
				contactAddress=[contactAddress stringByAppendingString:countryNameAppend];
			}else{
				NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",state];
				contactAddress=[contactAddress stringByAppendingString:countryNameAsLoc];
			}
		}
		
		if(zip !=nil){
			if(![contactAddress isEqualToString:@""]){
				NSString *countryNameAppend=[NSString stringWithFormat:@", %@",zip];
				contactAddress=[contactAddress stringByAppendingString:countryNameAppend];
			}else{
				NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",zip];
				contactAddress=[contactAddress stringByAppendingString:countryNameAsLoc];
			}
		}
		
	}else {
		contactAddress=@"";
	}
	
	contactAddress=[contactAddress stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];//remove the newline character
	contactAddress=[contactAddress stringByReplacingOccurrencesOfString:@"\n" withString:@" "];//remove new line character;
	contactAddress=[contactAddress stringByReplacingOccurrencesOfString:@"\r" withString:@" "];//remove new line character;
	
	CFRelease(multiValue);
	
	self.taskCopy.location=contactAddress;
	
	//get email address from contact
	NSString *emailAddress=@"";
	ABMutableMultiValueRef multiEmailValue = ABRecordCopyValue(person, kABPersonEmailProperty);
	if(ABMultiValueGetCount(multiEmailValue)>0){
		CFStringRef emailAddr = ABMultiValueCopyValueAtIndex(multiEmailValue, 0);
		
		if(emailAddr==nil){
			emailAddr=(CFStringRef)@" ";
		}
		emailAddress=[NSString stringWithFormat:@"%@",emailAddr];
	}
	CFRelease(multiEmailValue);
	self.taskCopy.contactEmail=emailAddress;
	
    self.taskCopy.name = [NSString stringWithFormat:@"%@ %@", _meetText, self.taskCopy.contactName];
    
    titleTextView.text = self.taskCopy.name;
	
	// remove the controller
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [taskTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property
							  identifier:(ABMultiValueIdentifier)identifier{
	return NO;
}

#pragma mark GrowingTextView Delegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    //printf("reload \n");
    self.taskCopy.name = growingTextView.text;
    
    BOOL isFirstResponder = [titleTextView isFirstResponder];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [taskTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if (isFirstResponder)
    {
        [titleTextView becomeFirstResponder];
    }
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView
{
    return NO;
}

- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView;
{
    NSString *text = [titleTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    /*if ([text isEqualToString:@""])
    {
        saveButton.enabled = NO;
    }
    else
    {
        saveButton.enabled = YES;
    }*/
    
    self.taskCopy.name = text;
    
    [self check2EnableSave];
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
{
    NSString *text = [titleTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([text isEqualToString:@""])
    {
        saveButton.enabled = NO;
    }
}

#pragma mark Notification

- (void)appBusy:(NSNotification *)notification
{
    saveButton.enabled = NO;
}

- (void)appNoBusy:(NSNotification *)notification
{
    //saveButton.enabled = YES;
    [self check2EnableSave];
}

#pragma mark OS4 Support
-(void) purge
{
	originalTaskKey = -1;
	originalTaskType = -1;
	
	if (self.task.original != nil)
	{
		originalTaskKey = self.task.original.primaryKey;
		originalTaskType = self.task.original.type;
		
		self.task.original = nil;
	}
}

-(void) recover
{
	TaskManager *tm = [TaskManager getInstance];
	
	Task *original = nil;
	
	if (originalTaskKey != -1)
	{		
		if (originalTaskType == TYPE_EVENT)
		{
			original = [tm findREByKey:originalTaskKey];
		}
		else 
		{
			original = [tm findTaskByKey:originalTaskKey];
		}
		
		self.task.original = original;
	}
	else 
	{
		if (self.task.type == TYPE_TASK)
		{
			original = [tm findTaskByKey:self.task.primaryKey];
		}
		else if ([self.task isRE])
		{
			original = [tm findREByKey:self.task.primaryKey];
		}
		else 
		{
			original = [tm findEventByKey:self.task.primaryKey];
		}

		self.task = original;
	}
	
	if (original == nil)
	{
		[self.navigationController popViewControllerAnimated:YES];
	}
}

@end
