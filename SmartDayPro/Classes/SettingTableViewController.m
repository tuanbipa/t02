//
//  SettingTableViewController.m
//  SmartPlan
//
//  Created by Huy Le on 12/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import <EventKit/EventKit.h>

#import "SettingTableViewController.h"

#import "Common.h"
#import "Colors.h"

#import "Settings.h"
#import "GuideWebView.h"
#import "ProjectManager.h"
#import "TaskManager.h"
#import "DBManager.h"
#import "ImageManager.h"
#import "Project.h"
#import "Task.h"

#import "TDSync.h"
#import "EKSync.h"
#import "SDWSync.h"
#import "EKReminderSync.h"

#import "DurationPickerViewController.h"
#import "ProjectSelectionTableViewController.h"
#import "CalendarEditTableViewController.h"
#import "WorkingTime7ViewController.h"

#import "HelpViewController.h"
#import "SyncWindow2TableViewController.h"
#import "SyncDirectionTableViewController.h"
#import "ToodledoAccountViewController.h"
#import "SDWAccountViewController.h"

#import "CalendarSelectionTableViewController.h"
#import "DefaultDurationViewController.h"
#import "SnoozeDurationViewController.h"
#import "TimeZonePickerViewController.h"

#import "AboutTableViewController.h"

#import "TagListViewController.h"

#import "HintModalViewController.h"

#import "TagDictionary.h"

#import "SmartCalAppDelegate.h"

#import "CalendarViewController.h"
#import "NumberInputViewController.h"

#import "ToodledoSyncViewController.h"
#import "TaskSyncViewController.h"

#import "iOSCalSyncViewController.h"
#import "DataRecoveryViewController.h"

#import "AbstractSDViewController.h"

extern BOOL _scFreeVersion;

extern AbstractSDViewController *_abstractViewCtrler;

@implementation SettingTableViewController

@synthesize settingCopy;

@synthesize sdwAccountChange;
@synthesize tdAccountChange;

/*
 - (id)initWithStyle:(UITableViewStyle)style {
 // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 if (self = [super initWithStyle:style]) {
 }
 return self;
 }
 */

- (void)loadView 
{
	self.settingCopy = [Settings getInstance];
    
    self.sdwAccountChange = NO;
    self.tdAccountChange = NO;
    
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
	//UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    UIView *contentView = [[UIView alloc] initWithFrame:frm];
	//contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    contentView.backgroundColor = [UIColor darkGrayColor];
	
	//settingTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 416) style:UITableViewStyleGrouped];
    settingTableView = [[UITableView alloc] initWithFrame:contentView.bounds style:UITableViewStyleGrouped];
	settingTableView.delegate = self;
	settingTableView.dataSource = self;
	
	[contentView addSubview:settingTableView];
	[settingTableView release];
	
	self.view = contentView;
	[contentView release];	
	
	UIBarButtonItem *saveButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
																			   target:self action:@selector(save:)];
	
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
		
	self.navigationItem.title = _settingTitle;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:_backText style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = backButton;
    [backButton release];    
}

- (void) help: (id) sender
{
	//[self.navigationController pushViewController:CreateHelpCtrl() animated:YES];
	
	HelpViewController *ctrler = [[HelpViewController alloc] init];
	
	[self.navigationController pushViewController:ctrler animated:NO];
	[ctrler release];	
	
}

- (void) confirmSyncOn
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_synchronizationText message:_confirmSyncOnText delegate:self cancelButtonTitle:_okText otherButtonTitles:_syncWizardText,nil];
    alertView.tag = 10000;
    
    [alertView show];
    [alertView release];
    
}

- (void) popupSyncGuide
{
    HintModalViewController *ctrler = [[HintModalViewController alloc] init];
    ctrler.closeEnabled = YES;
    
    CGSize sz = [Common getScreenSize];
    
    CGRect frm = CGRectZero;
    frm.size = sz;
    
    GuideWebView *hintView = [[GuideWebView alloc] initWithFrame:frm];
    [hintView loadURL:URL_SYNC content:nil];    
    
    ctrler.view = hintView;
    
    [hintView release];
    
    /*
	UIButton *closeButton = [Common createButton:@""
                                      buttonType:UIButtonTypeCustom
                                           frame:CGRectMake(sz.width-25, 5, 20, 20)
                                      titleColor:[UIColor whiteColor]
                                          target:self
                                        selector:@selector(closeHint:)
                                normalStateImage:@"close.png"
                              selectedStateImage:nil];
    
    [hintView addSubview:closeButton];
    
    ctrler.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    */
    
    [self presentViewController:ctrler animated:YES completion:NULL];
}

- (void) save
{
	TaskManager *tm = [TaskManager getInstance];
    DBManager *dbm = [DBManager getInstance];
    ProjectManager *pm = [ProjectManager getInstance];
	
	Settings *settings = [Settings getInstance];
    
    BOOL hideFutureTaskChange = settings.hideFutureTasks != self.settingCopy.hideFutureTasks;
    
    BOOL workTimeChange = [settings checkWorkingTimeChange:self.settingCopy];
	
	BOOL reSchedule = (settings.eventCombination != self.settingCopy.eventCombination || settings.minimumSplitSize != self.settingCopy.minimumSplitSize || workTimeChange);
	
	BOOL changeSkin = (settings.skinStyle != self.settingCopy.skinStyle);
	
	BOOL weekStartChange = (settings.weekStart != self.settingCopy.weekStart);
	
	BOOL tabBarChanged = (settings.tabBarAutoHide != self.settingCopy.tabBarAutoHide);
    
    /*
	BOOL ekAutoSyncChange = (settings.ekAutoSyncEnabled != self.settingCopy.ekAutoSyncEnabled);
	BOOL tdAutoSyncChange = (settings.tdAutoSyncEnabled != self.settingCopy.tdAutoSyncEnabled);
	BOOL sdwAutoSyncChange = (settings.sdwAutoSyncEnabled != self.settingCopy.sdwAutoSyncEnabled);
    */
    BOOL autoSyncChange = settings.autoSyncEnabled != self.settingCopy.autoSyncEnabled;
    
    BOOL taskSyncChange = settings.tdSyncEnabled != self.settingCopy.tdSyncEnabled || settings.rmdSyncEnabled != self.settingCopy.rmdSyncEnabled || settings.sdwSyncEnabled != self.settingCopy.sdwSyncEnabled;
    
    BOOL ekSyncChange = settings.ekSyncEnabled != settings.ekSyncEnabled;
    
    BOOL mustDoDaysChange = (settings.mustDoDays != self.settingCopy.mustDoDays);
    
    BOOL defaultCatChange = (settings.taskDefaultProject != self.settingCopy.taskDefaultProject);
    
    BOOL ekSyncWindowChange = (settings.syncWindowStart != self.settingCopy.syncWindowStart) || (settings.syncWindowEnd != self.settingCopy.syncWindowEnd);
    
    BOOL timeZoneSupportChange = settings.timeZoneSupport != self.settingCopy.timeZoneSupport;
    
    BOOL timeZoneChange = settings.timeZoneID != self.settingCopy.timeZoneID;
    	
	if (settings.taskDuration != self.settingCopy.taskDuration)
	{
		tm.lastTaskDuration = self.settingCopy.taskDuration;
	}
	
	if (settings.taskDefaultProject != self.settingCopy.taskDefaultProject)
	{
		tm.lastTaskProjectKey = self.settingCopy.taskDefaultProject;
	}
	
    if (self.tdAccountChange || taskSyncChange)
	{
        [dbm resetProjectSyncIds];
		[dbm resetTaskSyncIds];
        [pm resetSyncIds];
        
        [settings resetToodledoSync];
        [settings resetReminderSync];
        
        if (self.tdAccountChange)
        {
            [[TDSync getInstance] resetSyncSection];
        }
	}
    
    if (self.sdwAccountChange || taskSyncChange)
	{
		[settings resetSDWSync];
        [dbm resetSDWIds];
        [pm resetSDWIds];

        if (self.sdwAccountChange)
        {
            [[SDWSync getInstance] resetSyncSection];
        }
	}
    
	[settings updateSettings:self.settingCopy];
    
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
	
    if (timeZoneSupportChange || timeZoneChange)
    {
        [tm initData];
    }
	else if (reSchedule && !mustDoDaysChange)
	{
		[tm scheduleTasks];
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
	
	if (weekStartChange && !mustDoDaysChange)
	{
        [_abstractViewCtrler.miniMonthView initCalendar:tm.today];
	}
	
	[[TagDictionary getInstance] saveDict];
    
    BOOL toodledoAccountValid = ![settings.tdEmail isEqualToString:@""] && ![settings.tdPassword isEqualToString:@""] && settings.tdVerified;
    
    BOOL sdwAccountValid = ![settings.sdwEmail isEqualToString:@""] && ![settings.sdwEmail isEqualToString:@""] && settings.sdwVerified;
/*
	BOOL ekAutoSyncON = (settings.ekSyncEnabled && settings.ekAutoSyncEnabled) && (ekAutoSyncChange || ekSyncWindowChange);
	BOOL tdAutoSyncON = (settings.tdSyncEnabled && settings.tdAutoSyncEnabled) && tdAutoSyncChange;
	BOOL sdwAutoSyncON = (settings.sdwSyncEnabled && settings.sdwAutoSyncEnabled) && sdwAutoSyncChange;
    BOOL rmdAutoSyncON = settings.rmdSyncEnabled && settings.ekAutoSyncEnabled && ekAutoSyncChange;
*/
    
	BOOL ekAutoSyncON = (settings.ekSyncEnabled && settings.autoSyncEnabled) && (autoSyncChange || ekSyncWindowChange || ekSyncChange);
	BOOL tdAutoSyncON = settings.tdSyncEnabled && settings.autoSyncEnabled && (autoSyncChange || taskSyncChange);
	BOOL sdwAutoSyncON = settings.sdwSyncEnabled && settings.autoSyncEnabled && (autoSyncChange || taskSyncChange);
    BOOL rmdAutoSyncON = settings.rmdSyncEnabled && settings.autoSyncEnabled && (autoSyncChange || taskSyncChange);
    
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
        [_abstractViewCtrler resetAllData];
    }
	
    if (defaultCatChange)
    {
        tm.eventDummy.project = settings.taskDefaultProject;
        tm.taskDummy.project = settings.taskDefaultProject;
        
        [[_abstractViewCtrler getCategoryViewController] loadAndShowList];
    }
    
    Project *prj = [pm getProjectByKey:settings.taskDefaultProject];
    
    if (prj != nil)
    {
        // to refresh visibility in mySD if it was hidden in mySD before
        [prj modifyUpdateTimeIntoDB:[dbm getDatabase]];
    }
    
    if (workTimeChange)
    {
        [[_abstractViewCtrler getCalendarViewController] refreshCalendarDay];
    }    
}

/*
 - (void)viewDidLoad {
 [super viewDidLoad];
 
 // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
 // self.navigationItem.rightBarButtonItem = self.editButtonItem;
 }
 */


- (void)viewWillAppear:(BOOL)animated {
    //[super viewWillAppear:animated];
	
	[settingTableView reloadData];
}

/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

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

#pragma mark Support
-(void) editTaskDuration
{
	DefaultDurationViewController *ctrler = [[DefaultDurationViewController alloc] init];
	ctrler.settings = self.settingCopy;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

-(void) editSnoozeDuration
{
	SnoozeDurationViewController *ctrler = [[SnoozeDurationViewController alloc] init];
	ctrler.settings = self.settingCopy;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

-(void) editTaskDefaultProject
{
	ProjectSelectionTableViewController *ctrler = [[ProjectSelectionTableViewController alloc] init];
	ctrler.objectEdit = self.settingCopy;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];	
}

-(void) editMinimumSplitSize
{
	DurationPickerViewController *ctrler = [[DurationPickerViewController alloc] init];
	ctrler.objectEdit = self.settingCopy;
	ctrler.keyEdit = SETTING_EDIT_MIN_SPLIT_SIZE;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];	
}

- (void) editMustDoDays
{
	NumberInputViewController *ctrler = [[NumberInputViewController alloc] init];
	ctrler.objectEdit = self.settingCopy;
	ctrler.keyEdit = SETTING_EDIT_MUSTDO_DAYS;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];	
}

-(void) editProjectNames
{
	CalendarEditTableViewController *ctrler = [[CalendarEditTableViewController alloc] init];
	ctrler.settings = self.settingCopy;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];	
}

-(void) editWorkingTime
{	
	WorkingTime7ViewController *ctrler = [[WorkingTime7ViewController alloc] init];
	ctrler.settings = self.settingCopy;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];	
}

-(void) editTimeZone
{
    TimeZonePickerViewController *ctrler = [[TimeZonePickerViewController alloc] init];
    ctrler.objectEdit = self.settingCopy;
    
    [self.navigationController pushViewController:ctrler animated:YES];
    
    [ctrler release];    
}

-(void) editTagList
{	
	TagListViewController *ctrler = [[TagListViewController alloc] init];
	//ctrler.settings = self.settingCopy;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];	
}

- (void) editSyncWindow
{
	SyncWindow2TableViewController *ctrler = [[SyncWindow2TableViewController alloc] init];
	ctrler.setting = self.settingCopy;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];	
}

- (void) editToodledoSync
{
    ToodledoSyncViewController *ctrler = [[ToodledoSyncViewController alloc] init];
    ctrler.setting = self.settingCopy;
    
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];    
}

-(void) editTaskSync
{
    TaskSyncViewController *ctrler = [[TaskSyncViewController alloc] init];
    ctrler.setting = self.settingCopy;
    
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];    
}

- (void) editCalSync
{
    iOSCalSyncViewController *ctrler = [[iOSCalSyncViewController alloc] init];
    ctrler.setting = self.settingCopy;
    
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

- (void) showDataRecovery
{
    DataRecoveryViewController *ctrler = [[DataRecoveryViewController alloc] init];
    
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

-(void) viewAbout
{
	AboutTableViewController *ctrler = [[AboutTableViewController alloc] init];
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];		
}

- (void)refreshMustDoCell
{
    UITableViewCell *cell = [settingTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:2]];
    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:11050];
    
    if (label != nil)
    {
        label.text = [NSString stringWithFormat:@"%d", self.settingCopy.mustDoDays];
    }
}

- (void) refreshTimeZone
{
    [settingTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:3 inSection:3]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Sync Support
/*
- (void) refreshSyncWindowButtons
{
	UITableViewCell *cell = [settingTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
	
	UIButton *syncWindowOption1Button = (UIButton *) [cell viewWithTag:12000];
	syncWindowOption1Button.selected = NO;
	
	UIButton *syncWindowOption2Button =  (UIButton *) [cell viewWithTag:12001];
	syncWindowOption2Button.selected = NO;
	
	UIButton *syncWindowOption3Button =  (UIButton *) [cell viewWithTag:12002];
	syncWindowOption3Button.selected = NO;
	
	NSInteger syncWindowStart = self.settingCopy.syncWindowStart;
	NSInteger syncWindowEnd = self.settingCopy.syncWindowEnd;
	
	if (syncWindowStart == 0 && syncWindowEnd == 0)
	{
		syncWindowOption1Button.selected = YES;
	}
	else if (syncWindowStart == 1 && syncWindowEnd == 1)
	{
		syncWindowOption2Button.selected = YES;
	}
	else if (syncWindowStart == 2 && syncWindowEnd == 2)
	{
		syncWindowOption3Button.selected = YES;
	}
	
}

- (void) changeSyncWindow: (id) sender
{
	switch ([sender tag])
	{
		case 12000:
		{
			self.settingCopy.syncWindowStart = 0;
			self.settingCopy.syncWindowEnd = 0;
			
			[self refreshSyncWindowButtons];
		}
			break;
		case 12001:
		{
			self.settingCopy.syncWindowStart = 1;
			self.settingCopy.syncWindowEnd = 1;
			
			[self refreshSyncWindowButtons];			
		}
			break;
		case 12002:
		{
			self.settingCopy.syncWindowStart = 2;
			self.settingCopy.syncWindowEnd = 2;
			
			[self refreshSyncWindowButtons];			
		}
			break;
	}
	
}

-(void) editSyncWindow
{	
	SyncWindow2TableViewController *ctrler = [[SyncWindow2TableViewController alloc] init];
	ctrler.setting = self.settingCopy;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

-(void) editSyncDirection
{	
	SyncDirectionTableViewController *ctrler = [[SyncDirectionTableViewController alloc] init];
	ctrler.setting = self.settingCopy;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}


-(void) editEventSync
{	
	EventSyncTableViewController *ctrler = [[EventSyncTableViewController alloc] init];
	ctrler.setting = self.settingCopy;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}
*/

-(void) editToodledoAccount
{	
	ToodledoAccountViewController *ctrler = [[ToodledoAccountViewController alloc] init];
	
	//ctrler.setting = self.settingCopy;
    ctrler.setting = [Settings getInstance];
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

-(void) editSDWAccount
{	
	SDWAccountViewController *ctrler = [[SDWAccountViewController alloc] init];
	
	//ctrler.setting = self.settingCopy;
    ctrler.setting = [Settings getInstance];
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

- (void) sync1way2SDW
{
    [self.navigationController popViewControllerAnimated:YES];
    
    [[SDWSync getInstance] initBackground1WayPush];
}

- (void) sync1way2SD
{
    [self.navigationController popViewControllerAnimated:YES];
     
    [[DBManager getInstance] cleanDB];
    
    [[SDWSync getInstance] initBackground1WayGet];
}

- (void) sync
{
    [self.navigationController popViewControllerAnimated:YES];
    
    /*Settings *settings = [Settings getInstance];
    
    if (settings.ekSyncEnabled)
    {
        [[EKSync getInstance] initBackgroundSync];
    }
    else if (settings.sdwSyncEnabled)
    {
        [[SDWSync getInstance] initBackgroundSync];
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
    }*/
    
    [_abstractViewCtrler sync];
}

#pragma mark Actions
- (void) changeSkin: (id) sender
{
	UISegmentedControl *segmentedStyleControl = (UISegmentedControl *)sender;
	
	self.settingCopy.skinStyle = segmentedStyleControl.selectedSegmentIndex;
}

- (void) changeWeekStart: (id) sender
{
	UISegmentedControl *segmentedStyleControl = (UISegmentedControl *)sender;
	
	self.settingCopy.weekStart = segmentedStyleControl.selectedSegmentIndex;	
}

- (void) changeTimeZoneSupport: (id) sender
{
	UISegmentedControl *segmentedStyleControl = (UISegmentedControl *)sender;
	
	self.settingCopy.timeZoneSupport = (segmentedStyleControl.selectedSegmentIndex == 0);
    
    self.settingCopy.timeZoneID = 0;
    
    if (self.settingCopy.timeZoneSupport)
    {
        NSTimeZone *tz = [NSTimeZone defaultTimeZone];
        
        self.settingCopy.timeZoneID = [Settings findTimeZoneIDe:tz];
    }
    
    //[settingTableView reloadData];
    [settingTableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) changeEventCombination: (id) sender
{
	UISegmentedControl *segmentedStyleControl = (UISegmentedControl *)sender;
	
	self.settingCopy.eventCombination = segmentedStyleControl.selectedSegmentIndex;	

    /*
	UITableViewCell *cell = [settingTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:2]];
	
	segmentedStyleControl = (UISegmentedControl *)[cell.contentView viewWithTag:11030]; // disable 'Move in Calendar'
	
	if (self.settingCopy.eventCombination == 1)
	{
		segmentedStyleControl.selectedSegmentIndex = 1;
		
		[segmentedStyleControl setEnabled:NO forSegmentAtIndex:0];
		
		self.settingCopy.movableAsEvent = NO;
		
		cell.textLabel.textColor = [UIColor grayColor];
	}
	else 
	{
		[segmentedStyleControl setEnabled:YES forSegmentAtIndex:0];
		
		cell.textLabel.textColor = [UIColor blackColor];
	}
    */
}

- (void) hideFutureTasks: (id) sender
{
	UISegmentedControl *segmentedStyleControl = (UISegmentedControl *)sender;
	
	self.settingCopy.hideFutureTasks = (segmentedStyleControl.selectedSegmentIndex == 0);
}

- (void) changeTaskMovable: (id) sender
{
	UISegmentedControl *segmentedStyleControl = (UISegmentedControl *)sender;
	
	self.settingCopy.movableAsEvent = segmentedStyleControl.selectedSegmentIndex;	
}

- (void) changeNewTaskPlacement: (id) sender
{
	UISegmentedControl *segmentedStyleControl = (UISegmentedControl *)sender;
	
	self.settingCopy.newTaskPlacement = segmentedStyleControl.selectedSegmentIndex;	
}

- (void) changeDeleteWarning: (id) sender
{
	UISegmentedControl *segmentedStyleControl = (UISegmentedControl *)sender;
	
	self.settingCopy.deleteWarning = (segmentedStyleControl.selectedSegmentIndex == 0);	
}

- (void) enableSound: (id) sender
{
	UISegmentedControl *segmentedStyleControl = (UISegmentedControl *)sender;
	
	self.settingCopy.soundEnable = (segmentedStyleControl.selectedSegmentIndex == 0);
}

- (void) changeDoneWarning: (id) sender
{
	UISegmentedControl *segmentedStyleControl = (UISegmentedControl *)sender;
	
	self.settingCopy.doneWarning = (segmentedStyleControl.selectedSegmentIndex == 0);	
}

- (void) changeTDSyncReset: (id) sender
{
	UISegmentedControl *segmentedStyleControl = (UISegmentedControl *)sender;
	
	self.settingCopy.tdSyncReset = (segmentedStyleControl.selectedSegmentIndex == 0);	
}

/*
- (void) changeSyncEnabled: (id) sender
{
	UISegmentedControl *segmentedStyleControl = (UISegmentedControl *)sender;
	
	if (segmentedStyleControl.tag == 14000)
	{
		self.settingCopy.ekAutoSyncEnabled = (segmentedStyleControl.selectedSegmentIndex == 0);
	}
	else if (segmentedStyleControl.tag == 15010)
	{
		if (_scFreeVersion && segmentedStyleControl.selectedSegmentIndex == 0)
		{
			segmentedStyleControl.selectedSegmentIndex = 1;
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_warningText message:_paidUpgradeText delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
			
			[alertView show];
			[alertView release];			
		}
		else
		{
            if (self.settingCopy.syncSource == 0)
            {
                self.settingCopy.sdwAutoSyncEnabled = (segmentedStyleControl.selectedSegmentIndex == 0);
            }
            else 
            {
                self.settingCopy.tdAutoSyncEnabled = (segmentedStyleControl.selectedSegmentIndex == 0);
            }
		}
	}

}
*/

- (void) resetHint: (id) sender
{
	[[Settings getInstance] enableHints];
	
	self.settingCopy.hideWarning = YES;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:_hintResetCompleteText delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
    
    [alertView show];
    [alertView release];			            
}

- (void) enableLandscapeMode: (id) sender
{
	UISegmentedControl *segmentedStyleControl = (UISegmentedControl *)sender;
	
	self.settingCopy.landscapeModeEnable = (segmentedStyleControl.selectedSegmentIndex == 0);
}

- (void) changeTabBarAutoHide: (id) sender
{
	UISegmentedControl *segmentedStyleControl = (UISegmentedControl *)sender;

	self.settingCopy.tabBarAutoHide = (segmentedStyleControl.selectedSegmentIndex == 0);
}

-(void) save:(id) sender
{
    [self save];
    
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) backup: (id) sender
{
	[SmartCalAppDelegate backupDB];
}

/*
- (void) closeHint: (id) sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
*/

- (void) switchSyncSource: (id) sender
{
    UISegmentedControl *ctrl = (UISegmentedControl *) sender;

    if (ctrl.selectedSegmentIndex == 0)
    {
        self.settingCopy.sdwSyncEnabled = YES;
    }
    else
    {
        self.settingCopy.sdwSyncEnabled = NO;
    }

    if (self.settingCopy.sdwSyncEnabled)
    {
        self.settingCopy.tdSyncEnabled = NO;
        self.settingCopy.rmdSyncEnabled =  NO;
    }
    
    [settingTableView reloadData];
}

- (void) enableSynchronization:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    self.settingCopy.syncEnabled = (segmentedControl.selectedSegmentIndex == 0);
    
    if (!self.settingCopy.syncEnabled)
    {
        self.settingCopy.autoSyncEnabled = NO;
        self.settingCopy.tdSyncEnabled = NO;
        self.settingCopy.ekSyncEnabled = NO;
        self.settingCopy.sdwSyncEnabled = NO;
    }
    else
    {
        self.settingCopy.sdwSyncEnabled = YES;
    }
    
    [settingTableView reloadData];
    
    if (self.settingCopy.syncEnabled)
    {
        [self confirmSyncOn];
    }
}

- (void) enableAutoSync:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    self.settingCopy.autoSyncEnabled = (segmentedControl.selectedSegmentIndex == 0);
    
    [settingTableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if (self.settingCopy.autoSyncEnabled)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_synchronizationText message:_syncAtStartUpHint delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
        
        [alertView show];
        [alertView release];
    }
}

- (void) enableAutoPush:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    self.settingCopy.autoPushEnabled = (segmentedControl.selectedSegmentIndex == 0);
}

/*
- (void) enableSDWSync:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    self.settingCopy.sdwSyncEnabled = (segmentedControl.selectedSegmentIndex == 0);
    
    if (self.settingCopy.tdSyncEnabled && self.settingCopy.sdwSyncEnabled)
    {
        self.settingCopy.tdSyncEnabled = NO;
    }
    
    [settingTableView reloadData];
}
*/

- (void) confirmSync1way2SDW:(id) sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_warningText message:_deleteAllMySDDataConfirmation delegate:self cancelButtonTitle:_cancelText otherButtonTitles:_okText,nil];
    alertView.tag = -10000;
    
    [alertView show];
    [alertView release];			
   
}

- (void) confirmSync1way2SD:(id) sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_warningText message:_deleteAllSDDataConfirmation delegate:self cancelButtonTitle:_cancelText otherButtonTitles:_okText,nil];
    
    alertView.tag = -10001;
    
    [alertView show];
    [alertView release];			    
}

- (void) enableTDSync:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    self.settingCopy.tdSyncEnabled = (segmentedControl.selectedSegmentIndex == 0);
    
    if (self.settingCopy.tdSyncEnabled && self.settingCopy.sdwSyncEnabled)
    {
        self.settingCopy.sdwSyncEnabled = NO;
    }
    
    [settingTableView reloadData];    
}

- (void) enableiOSCalSync:(id) sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    if (![EKSync checkEKAccessEnabled])
    {
        EKEventStore *ekStore = [[EKEventStore alloc] init];
        
        [ekStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
        {
            self.settingCopy.ekSyncEnabled = granted;
                
            [settingTableView reloadData];
        }];
    }
    else
    {
        self.settingCopy.ekSyncEnabled = (segmentedControl.selectedSegmentIndex == 0);
    
        [settingTableView reloadData];
    }
}

- (void) deleteSuspectedDuplication:(id) sender
{
    [[DBManager getInstance] deleteSuspectedDuplication];
    
    [_abstractViewCtrler resetAllData];
    
    BOOL syncEnabled = self.settingCopy.syncEnabled && (self.settingCopy.ekSyncEnabled || self.settingCopy.tdSyncEnabled || self.settingCopy.sdwSyncEnabled || self.settingCopy.rmdSyncEnabled);
    
    NSString *msg = (syncEnabled? [NSString stringWithFormat:@"%@ %@", _deleteSuspectedDuplicationCompleteText, _syncAgainText]: _deleteSuspectedDuplicationCompleteText);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:self cancelButtonTitle:(syncEnabled?_cancelText:_okText) otherButtonTitles:nil];
    
    if (syncEnabled)
    {
        [alertView addButtonWithTitle:_okText];
    }
    
    alertView.tag = -10002;
    
    [alertView show];
    [alertView release];			            
}

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertVw.tag == -10000 && buttonIndex != 0) //not Cancel
	{
        [self sync1way2SDW];
	}
	else if (alertVw.tag == -10001 && buttonIndex != 0) //not Cancel
	{
        [self sync1way2SD];
	}
	else if (alertVw.tag == -10002 && buttonIndex != 0) //not Cancel
	{
        [self sync];
	}
    else if (alertVw.tag == 10000 && buttonIndex != 0)
    {
        [self popupSyncGuide];
    }
}

#pragma mark Cell Creation
- (void) createSkinCell:(UITableViewCell *)cell
{
	//cell.text = _skinText;
	cell.textLabel.text = _skinText;
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _blueText, _blackText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(120, 5, 170, 30);
	[segmentedStyleControl addTarget:self action:@selector(changeSkin:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;	
	segmentedStyleControl.selectedSegmentIndex = self.settingCopy.skinStyle;
	segmentedStyleControl.tag = 10000;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];	
}

- (void) createWeekStartCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _weekStartText;
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _sundayText, _mondayText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(120, 5, 170, 30);
	[segmentedStyleControl addTarget:self action:@selector(changeWeekStart:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;	
	segmentedStyleControl.selectedSegmentIndex = self.settingCopy.weekStart;
	segmentedStyleControl.tag = baseTag;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];		
}

- (void) createTimeZoneSupportCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _timeZoneSupport;
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(170, 5, 120, 30);
	[segmentedStyleControl addTarget:self action:@selector(changeTimeZoneSupport:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;
	segmentedStyleControl.selectedSegmentIndex = self.settingCopy.timeZoneSupport?0:1;
	segmentedStyleControl.tag = baseTag;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];
}

- (void) createTimeZoneCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.textLabel.text = _timeZone;
	
	UILabel *tzLabel=[[UILabel alloc] initWithFrame:CGRectMake(60, 10, 205, 20)];
	tzLabel.tag = baseTag;
	tzLabel.textAlignment=NSTextAlignmentRight;
	tzLabel.backgroundColor=[UIColor clearColor];
	tzLabel.font=[UIFont systemFontOfSize:15];
	tzLabel.textColor= [Colors darkSteelBlue];
	
	tzLabel.text = [Settings getTimeZoneDisplayNameByID:self.settingCopy.timeZoneID];
	
	[cell.contentView addSubview:tzLabel];
	[tzLabel release];
	
}


- (void) createLandscapeEnableCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _landscapeModeEnableText;
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(170, 5, 120, 30);
	[segmentedStyleControl addTarget:self action:@selector(enableLandscapeMode:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;	
	segmentedStyleControl.selectedSegmentIndex = (self.settingCopy.landscapeModeEnable?0:1);
	segmentedStyleControl.tag = baseTag;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];	
}

- (void) createWorkingTimeCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	cell.textLabel.text = _workingTimeText;	
}

- (void) createTagListCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.textLabel.text = _tagListText;
}

- (void) createHintCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _hintsText;
	
	UIButton *resetButton = [Common createButton:_resetText 
										 buttonType:UIButtonTypeCustom 
											  frame:CGRectMake(210, 5, 80, 30)
										 titleColor:[UIColor whiteColor]
											 target:self
										   selector:@selector(resetHint:) 
								   normalStateImage:@"hint_button.png" 
								 selectedStateImage:nil];	
	resetButton.tag = baseTag;
	[cell.contentView addSubview:resetButton];
}

- (void) createDeleteSuspectedDuplicationCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _deleteSyncDuplicationText;
	
	UIButton *deleteButton = [Common createButton:_deleteText 
                                      buttonType:UIButtonTypeCustom 
                                           frame:CGRectMake(210, 5, 80, 30)
                                      titleColor:[UIColor whiteColor]
                                          target:self
                                        selector:@selector(deleteSuspectedDuplication:) 
                                normalStateImage:@"delete_button.png" 
                              selectedStateImage:nil];	
	deleteButton.tag = baseTag;
	[cell.contentView addSubview:deleteButton];
}

- (void) createDurationCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.textLabel.text = _durationText;
	
	UILabel *durationLabel=[[UILabel alloc] initWithFrame:CGRectMake(60, 10, 205, 20)];
	durationLabel.tag = baseTag;
	durationLabel.textAlignment=NSTextAlignmentRight;
	durationLabel.backgroundColor=[UIColor clearColor];
	durationLabel.font=[UIFont systemFontOfSize:15];
	durationLabel.textColor= [Colors darkSteelBlue];
	
	durationLabel.text = [Common getDurationString:self.settingCopy.taskDuration];
	
	[cell.contentView addSubview:durationLabel];
	[durationLabel release];
	
}

- (void) createSnoozeDurationCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.textLabel.text = _snoozeDuration;
	
	UILabel *durationLabel=[[UILabel alloc] initWithFrame:CGRectMake(60, 10, 205, 20)];
	durationLabel.tag = baseTag;
	durationLabel.textAlignment=NSTextAlignmentRight;
	durationLabel.backgroundColor=[UIColor clearColor];
	durationLabel.font=[UIFont systemFontOfSize:15];
	durationLabel.textColor= [Colors darkSteelBlue];
	
	durationLabel.text = [Common getDurationString:self.settingCopy.snoozeDuration*60];
	
	[cell.contentView addSubview:durationLabel];
	[durationLabel release];
	
}


- (void) createDefaultCategoryCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.textLabel.text = _defaultProjectText;
	
	Project *prj = [[ProjectManager getInstance] getProjectByKey:self.settingCopy.taskDefaultProject];
	
	UILabel *projectNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(150, 10, 120, 20)];
	projectNameLabel.tag = baseTag;
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

- (void) createEventCombinationCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _showInCalendarText;
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(190, 5, 100, 30);
	[segmentedStyleControl addTarget:self action:@selector(changeEventCombination:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;	
	segmentedStyleControl.selectedSegmentIndex = self.settingCopy.eventCombination;
	segmentedStyleControl.tag = baseTag;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];		
}

- (void) createHideFutureTasksCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _hideFutureTasks;
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(190, 5, 100, 30);
	[segmentedStyleControl addTarget:self action:@selector(hideFutureTasks:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;
	segmentedStyleControl.selectedSegmentIndex = self.settingCopy.hideFutureTasks?0:1;
	segmentedStyleControl.tag = baseTag;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];
}

- (void) createMovableAsEventCell:(UITableViewCell *)cell
{
	UILabel *textLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 5, 200, 20)];
	textLabel.tag = 11031;
	textLabel.text = _moveInCalendarText;
	textLabel.textAlignment=NSTextAlignmentLeft;
	textLabel.backgroundColor=[UIColor clearColor];
	textLabel.font=[UIFont boldSystemFontOfSize:16];
	[cell.contentView addSubview:textLabel];
	[textLabel release];
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _convertIntoEventText, _changeOrderText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(10, 30, 280, 30);
	[segmentedStyleControl addTarget:self action:@selector(changeTaskMovable:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;	
	segmentedStyleControl.selectedSegmentIndex = self.settingCopy.movableAsEvent;
	segmentedStyleControl.tag = 11030;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];		
}

- (void) createNewTaskPlacementCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _newTaskPlaceText;
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _topText, _bottomText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(150, 5, 140, 30);
	[segmentedStyleControl addTarget:self action:@selector(changeNewTaskPlacement:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;	
	segmentedStyleControl.selectedSegmentIndex = self.settingCopy.newTaskPlacement;
	segmentedStyleControl.tag = baseTag;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];		
}

- (void) createMinimumSplitSizeCell:(UITableViewCell *)cell
{
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	//cell.text = _minSplitSizeText;
	cell.textLabel.text = _minSplitSizeText;
	
	UILabel *durationLabel=[[UILabel alloc] initWithFrame:CGRectMake(60, 10, 205, 20)];
	durationLabel.tag = 11050;
	durationLabel.textAlignment=NSTextAlignmentRight;
	durationLabel.backgroundColor=[UIColor clearColor];
	durationLabel.font=[UIFont systemFontOfSize:15];
	durationLabel.textColor= [Colors darkSteelBlue];
	
	durationLabel.text = [Common getDurationString:self.settingCopy.minimumSplitSize];
	
	[cell.contentView addSubview:durationLabel];
	[durationLabel release];	
}

- (void) createMustDoCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = _mustDoRangeText;
    
	UILabel *daysLabel=[[UILabel alloc] initWithFrame:CGRectMake(300-70, 10, 40, 20)];
	daysLabel.tag = baseTag;
	daysLabel.textAlignment=NSTextAlignmentRight;
	daysLabel.backgroundColor=[UIColor clearColor];
	daysLabel.font=[UIFont systemFontOfSize:15];
	daysLabel.textColor= [Colors darkSteelBlue];
    daysLabel.text = [NSString stringWithFormat:@"%d", self.settingCopy.mustDoDays];
    
    [cell.contentView addSubview:daysLabel];
    [daysLabel release];
    
}

/*
- (void) createSyncWindowCell:(UITableViewCell *)cell
{
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.text = _timeWindowText;
	
	UIButton *syncWindowOption1Button = [Common createButton:_1WText 
												  buttonType:UIButtonTypeCustom
													   frame:CGRectMake(130, 5, 40, 30) 
												  titleColor:[UIColor whiteColor] 
													  target:self 
													selector:@selector(changeSyncWindow:) 
											normalStateImage:@"gray_button.png"
										  selectedStateImage:@"blue_button.png"];	
	syncWindowOption1Button.tag = 12000;
	
	[cell.contentView addSubview:syncWindowOption1Button];	
	
	UIButton *syncWindowOption2Button = [Common createButton:_3WText 
												  buttonType:UIButtonTypeCustom
													   frame:CGRectMake(180, 5, 40, 30) 
												  titleColor:[UIColor whiteColor] 
													  target:self 
													selector:@selector(changeSyncWindow:) 
											normalStateImage:@"gray_button.png"
										  selectedStateImage:@"blue_button.png"];	
	syncWindowOption2Button.tag = 12001;
	
	[cell.contentView addSubview:syncWindowOption2Button];
	
	UIButton *syncWindowOption3Button = [Common createButton:_3MText 
												  buttonType:UIButtonTypeCustom
													   frame:CGRectMake(230, 5, 40, 30) 
												  titleColor:[UIColor whiteColor] 
													  target:self 
													selector:@selector(changeSyncWindow:) 
											normalStateImage:@"gray_button.png"
										  selectedStateImage:@"blue_button.png"];	
	syncWindowOption3Button.tag = 12002;
	
	[cell.contentView addSubview:syncWindowOption3Button];
	
	NSInteger syncWindowStart = self.settingCopy.syncWindowStart;
	NSInteger syncWindowEnd = self.settingCopy.syncWindowEnd;
	
	if (syncWindowStart == 0 && syncWindowEnd == 0)
	{
		syncWindowOption1Button.selected = YES;
	}
	else if (syncWindowStart == 1 && syncWindowEnd == 1)
	{
		syncWindowOption2Button.selected = YES;
	}
	else if (syncWindowStart == 2 && syncWindowEnd == 2)
	{
		syncWindowOption3Button.selected = YES;
	}
}

- (void) createSyncMappingCell:(UITableViewCell *)cell
{
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.text = _calendarMappingText;
}

- (void) createSyncDirectionCell:(UITableViewCell *)cell
{
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.text = _syncDirectionText;
	
	UILabel *directionLabel=[[UILabel alloc] initWithFrame:CGRectMake(60, 10, 205, 20)];
	directionLabel.tag = 11010;
	directionLabel.textAlignment=NSTextAlignmentRight;
	directionLabel.backgroundColor=[UIColor clearColor];
	directionLabel.font=[UIFont systemFontOfSize:15];
	
	NSString *directions[3] = {_2wayText, _importText, _exportText};
	directionLabel.text = directions[self.settingCopy.syncDirection];
	directionLabel.textColor = [Colors steelBlue];
	
	[cell.contentView addSubview:directionLabel];
	[directionLabel release];
}

- (void) createTDSyncAccountCell:(UITableViewCell *)cell
{
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.text = _accountText;
}

- (void) createTDSyncMappingCell:(UITableViewCell *)cell
{
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.text = _calendarsText;
}

- (void) createTDSyncResetCell:(UITableViewCell *)cell
{
	cell.text = _resetText;
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(190, 5, 100, 30);
	[segmentedStyleControl addTarget:self action:@selector(changeTDSyncReset:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;	
	segmentedStyleControl.selectedSegmentIndex = (self.settingCopy.tdSyncReset?0:1);
	segmentedStyleControl.tag = 14001;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];	
}

- (void) createEventSyncCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _autoSyncText;
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];	
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(190, 5, 100, 30);
	[segmentedStyleControl addTarget:self action:@selector(changeSyncEnabled:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;	
	segmentedStyleControl.selectedSegmentIndex = (self.settingCopy.ekAutoSyncEnabled?0:1);
	segmentedStyleControl.tag = baseTag;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];
}
*/
- (void) createSyncWindowCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _syncWindowText;
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

/*
- (void) createTaskSyncCell:(UITableViewCell *)cell
{
	cell.textLabel.text = _autoSyncText;
	
	//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];	
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(190, 5, 100, 30);
	[segmentedStyleControl addTarget:self action:@selector(changeSyncEnabled:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;	
	segmentedStyleControl.selectedSegmentIndex = (self.settingCopy.tdAutoSyncEnabled?0:1);
	segmentedStyleControl.tag = 14001;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];	
    
    if ([self.settingCopy.tdEmail isEqualToString:@""] && [self.settingCopy.tdPassword isEqualToString:@""])
    {
        segmentedStyleControl.selectedSegmentIndex = 1;
        
        segmentedStyleControl.enabled = NO;
        
        self.settingCopy.tdAutoSyncEnabled = NO;
    }
    else
    {
        segmentedStyleControl.enabled = YES;
    }
}
*/

- (void) createTaskSyncCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.textLabel.text = _tasksText;
	
	UILabel *nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(150, 10, 120, 20)];
	nameLabel.tag = baseTag;
	nameLabel.textAlignment=NSTextAlignmentRight;
	nameLabel.backgroundColor=[UIColor clearColor];
	nameLabel.font=[UIFont systemFontOfSize:15];
	nameLabel.text = (!self.settingCopy.tdSyncEnabled && !self.settingCopy.rmdSyncEnabled)?_offText:(self.settingCopy.tdSyncEnabled?_toodledoText:_reminderText);

	[cell.contentView addSubview:nameLabel];
	[nameLabel release];
}

- (void) createDeleteWarningCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _deleteWarningText;
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(190, 5, 100, 30);
	[segmentedStyleControl addTarget:self action:@selector(changeDeleteWarning:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;	
	segmentedStyleControl.selectedSegmentIndex = (self.settingCopy.deleteWarning?0:1);
	segmentedStyleControl.tag = baseTag;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];		
}

- (void) createSoundEnabledCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _soundEnabledText;
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(190, 5, 100, 30);
	[segmentedStyleControl addTarget:self action:@selector(enableSound:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;
	segmentedStyleControl.selectedSegmentIndex = (self.settingCopy.soundEnable?0:1);
	segmentedStyleControl.tag = baseTag;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];
}

- (void) createTabBarAutoHideCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _tabBarAutoHideText;
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(190, 5, 100, 30);
	[segmentedStyleControl addTarget:self action:@selector(changeTabBarAutoHide:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;
	segmentedStyleControl.selectedSegmentIndex = (self.settingCopy.tabBarAutoHide?0:1);
	segmentedStyleControl.tag = baseTag;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];
}

- (void) createSynchronizationCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _enableText;
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(190, 5, 100, 30);
	[segmentedStyleControl addTarget:self action:@selector(enableSynchronization:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;
	segmentedStyleControl.selectedSegmentIndex = self.settingCopy.syncEnabled?0:1;
	segmentedStyleControl.tag = baseTag;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];
}

- (void) createSyncAtStartUpCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 40)];
    titleLabel.numberOfLines = 2;
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.tag = baseTag;
    titleLabel.text = _syncAtStartUp;
    
	[cell.contentView addSubview:titleLabel];
	[titleLabel release];
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(190, 5, 100, 30);
	[segmentedStyleControl addTarget:self action:@selector(enableAutoSync:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;
	segmentedStyleControl.selectedSegmentIndex = self.settingCopy.autoSyncEnabled?0:1;
	segmentedStyleControl.tag = baseTag+1;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];
    
    /*
    UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, 280, 40)];
    hintLabel.font = [UIFont italicSystemFontOfSize:14];
    hintLabel.numberOfLines = 0;
    hintLabel.backgroundColor = [UIColor clearColor];
    hintLabel.textColor = [Colors darkSteelBlue];
    hintLabel.tag = baseTag+2;
    hintLabel.text = _syncAtStartUpHint;
    
    [cell.contentView addSubview:hintLabel];
    [hintLabel release];
    */
}

- (void) createAutoPushCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _pushChanges;
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(190, 5, 100, 30);
	[segmentedStyleControl addTarget:self action:@selector(enableAutoPush:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;
	segmentedStyleControl.selectedSegmentIndex = self.settingCopy.autoPushEnabled?0:1;
	segmentedStyleControl.tag = baseTag;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];
}

- (void) createDoneWarningCell:(UITableViewCell *)cell
{
	cell.textLabel.text = _doneWarningText;
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(190, 5, 100, 30);
	[segmentedStyleControl addTarget:self action:@selector(changeDoneWarning:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;	
	segmentedStyleControl.selectedSegmentIndex = (self.settingCopy.doneWarning?0:1);
	segmentedStyleControl.tag = 15002;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];		
}

/*
- (void) createTDSDWSwitchCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _mySmartDayText, _toodledoText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(10, 5, 280, 30);
	[segmentedStyleControl addTarget:self action:@selector(switchSyncSource:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;	
	segmentedStyleControl.selectedSegmentIndex = self.settingCopy.syncSource;
	segmentedStyleControl.tag = baseTag;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];		    
}

- (void) createTDSDWSyncCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _autoSyncText;
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];	
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(190, 5, 100, 30);
	[segmentedStyleControl addTarget:self action:@selector(changeSyncEnabled:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;	
	segmentedStyleControl.selectedSegmentIndex = (self.settingCopy.syncSource == 0?(self.settingCopy.sdwAutoSyncEnabled?0:1):(self.settingCopy.tdAutoSyncEnabled?0:1));
	segmentedStyleControl.tag = baseTag;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];
    
}
*/

- (void) createAccountCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    cell.textLabel.text = (self.settingCopy.syncSource == 0?_mySDAccountText:_toodledoAccountText);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void) createSyncSourceSwitchCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _mySmartDayDotCom, _others, nil];
    
	UISegmentedControl *syncSegmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	syncSegmentedControl.frame = CGRectMake(10, 5, 280, 30);
	[syncSegmentedControl addTarget:self action:@selector(switchSyncSource:) forControlEvents:UIControlEventValueChanged];
	syncSegmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;
	syncSegmentedControl.selectedSegmentIndex = (self.settingCopy.sdwSyncEnabled?0:1);
	syncSegmentedControl.tag = baseTag+1;
    
    [syncSegmentedControl setWidth:180 forSegmentAtIndex:0];
    [syncSegmentedControl setWidth:100 forSegmentAtIndex:1];
    
	
	[cell.contentView addSubview:syncSegmentedControl];
	[syncSegmentedControl release];
}

/*
- (void) createSDWSyncEnableCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 160, 30)];
    titleLabel.font = [UIFont boldSystemFontOfSize:16]; 
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.tag = baseTag;
    titleLabel.text = _mySmartDayText;
    
	[cell.contentView addSubview:titleLabel];
	[titleLabel release];    
    
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
    
	UISegmentedControl *sdwSyncSegmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	sdwSyncSegmentedControl.frame = CGRectMake(170, 5, 120, 30);
	[sdwSyncSegmentedControl addTarget:self action:@selector(enableSDWSync:) forControlEvents:UIControlEventValueChanged];
	sdwSyncSegmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;	
	sdwSyncSegmentedControl.selectedSegmentIndex = (self.settingCopy.sdwSyncEnabled?0:1);
	sdwSyncSegmentedControl.tag = baseTag+1;
	
	[cell.contentView addSubview:sdwSyncSegmentedControl];
	[sdwSyncSegmentedControl release];

    UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 280, 40)];
    hintLabel.font = [UIFont italicSystemFontOfSize:14]; 
    hintLabel.numberOfLines = 0;
    hintLabel.backgroundColor = [UIColor clearColor];
    hintLabel.textColor = [Colors darkSteelBlue];
    hintLabel.tag = baseTag+2;
    hintLabel.text = _mySmartDaySyncHint;
    hintLabel.hidden = self.settingCopy.sdwSyncEnabled;
    
	[cell.contentView addSubview:hintLabel];
	[hintLabel release];     
}
*/
- (void) createSDWAccountCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    UILabel *verifiedLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 5, 100, 30)];
    verifiedLabel.backgroundColor = [UIColor clearColor];
    verifiedLabel.textAlignment = NSTextAlignmentRight;
    verifiedLabel.textColor = [Colors darkSteelBlue];
    verifiedLabel.tag = baseTag;
    verifiedLabel.text = (self.settingCopy.sdwVerified?_verifiedText:_unverifiedText);
                            
	[cell.contentView addSubview:verifiedLabel];
	[verifiedLabel release];
    
    cell.textLabel.text = _accountText;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void) createSDW1WaySyncCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 120, 20)];
    titleLabel.font = [UIFont boldSystemFontOfSize:16]; 
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.tag = baseTag;
    titleLabel.text = _replaceDataText;
    
	[cell.contentView addSubview:titleLabel];
	[titleLabel release];
/*
    UILabel *toSDLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, 300, 20)];
    toSDLabel.font = [UIFont systemFontOfSize:14];
    toSDLabel.backgroundColor = [UIColor clearColor];
    toSDLabel.textColor = [UIColor blackColor];
    toSDLabel.tag = baseTag+3;
    toSDLabel.text = _toSmartDay;
    
	[cell.contentView addSubview:toSDLabel];
	[toSDLabel release];
    
    UILabel *fromSDLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 65, 300, 20)];
    fromSDLabel.font = [UIFont systemFontOfSize:14];
    fromSDLabel.backgroundColor = [UIColor clearColor];
    fromSDLabel.textColor = [UIColor blackColor];
    fromSDLabel.tag = baseTag;
    fromSDLabel.text = _fromSmartDay;
    
	[cell.contentView addSubview:fromSDLabel];
	[fromSDLabel release];

	UIButton *toSDButton = [Common createButton:_goText
                                     buttonType:UIButtonTypeCustom
                                          frame:CGRectMake(300-45, 30, 40, 30)
                                     titleColor:[UIColor whiteColor]
                                         target:self
                                       selector:@selector(confirmSync1way2SD:)
                               normalStateImage:@"hint_button.png"
                             selectedStateImage:nil];
	toSDButton.tag = baseTag + 2;
	[cell.contentView addSubview:toSDButton];
        
	UIButton *fromSDButton = [Common createButton:_goText
                                       buttonType:UIButtonTypeCustom
                                            frame:CGRectMake(300-45, 60, 40, 30)
                                       titleColor:[UIColor whiteColor]
                                           target:self
                                         selector:@selector(confirmSync1way2SDW:)
                                 normalStateImage:@"hint_button.png"
                               selectedStateImage:nil];
	fromSDButton.tag = baseTag + 1;
	[cell.contentView addSubview:fromSDButton];
    */

	UIButton *fromSDButton = [Common createButton:@""
                                      buttonType:UIButtonTypeCustom 
                                           frame:CGRectMake(10, 25, 135, 60)
                                      titleColor:[UIColor whiteColor]
                                          target:self
                                        selector:@selector(confirmSync1way2SDW:) 
                                normalStateImage:@"replace_SDtomSD.png" 
                              selectedStateImage:nil];
	fromSDButton.tag = baseTag + 1;
	[cell.contentView addSubview:fromSDButton];
    
	UIButton *toSDButton = [Common createButton:@""
                                       buttonType:UIButtonTypeCustom
                                            frame:CGRectMake(155, 25, 135, 60)
                                       titleColor:[UIColor whiteColor]
                                           target:self
                                         selector:@selector(confirmSync1way2SD:) 
                                 normalStateImage:@"replace_mSDtoSD.png" 
                               selectedStateImage:nil];	
	toSDButton.tag = baseTag + 2;
	[cell.contentView addSubview:toSDButton];
    
}

- (void) createTDSyncEnableCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 120, 30)];
    titleLabel.font = [UIFont boldSystemFontOfSize:16]; 
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.tag = baseTag;
    titleLabel.text = _toodledoText;
    
	[cell.contentView addSubview:titleLabel];
	[titleLabel release];  
    
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
	UISegmentedControl *tdSyncSegmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	tdSyncSegmentedControl.frame = CGRectMake(170, 5, 120, 30);
	[tdSyncSegmentedControl addTarget:self action:@selector(enableTDSync:) forControlEvents:UIControlEventValueChanged];
	tdSyncSegmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;	
	tdSyncSegmentedControl.selectedSegmentIndex = (self.settingCopy.tdSyncEnabled?0:1);
	tdSyncSegmentedControl.tag = baseTag+1;
	
	[cell.contentView addSubview:tdSyncSegmentedControl];
	[tdSyncSegmentedControl release];
    
    if (self.settingCopy.tdSyncEnabled)
    {
		GuideWebView *guideView = [[GuideWebView alloc] initWithFrame:CGRectMake(0, 30, 300, 70)];
        guideView.backgroundColor = [UIColor clearColor];
        guideView.safariEnabled = YES;
		guideView.tag = baseTag+2;
		[guideView loadHTMLFile:@"ToodledoSyncHint" extension:@"htm"];
		
		[cell.contentView addSubview:guideView];
		[guideView release];
    
    }
    else
    {
        UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 280, 40)];
        hintLabel.font = [UIFont italicSystemFontOfSize:14];
        hintLabel.numberOfLines = 0;
        hintLabel.backgroundColor = [UIColor clearColor];
        hintLabel.textColor = [Colors darkSteelBlue];
        hintLabel.tag = baseTag+2;
        hintLabel.text = _toodledoSyncHint;
        hintLabel.hidden = self.settingCopy.tdSyncEnabled;
        
        [cell.contentView addSubview:hintLabel];
        [hintLabel release];         
    }
}

- (void) createTDAccountCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    UILabel *verifiedLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 5, 100, 30)];
    verifiedLabel.backgroundColor = [UIColor clearColor];
    verifiedLabel.textAlignment = NSTextAlignmentRight;
    verifiedLabel.textColor = [Colors darkSteelBlue];
    verifiedLabel.tag = baseTag;
    verifiedLabel.text = (self.settingCopy.tdVerified?_verifiedText:_unverifiedText);
    
	[cell.contentView addSubview:verifiedLabel];
	[verifiedLabel release];
    
    cell.textLabel.text = _accountText;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void) createEKSyncEnableCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(170, 5, 120, 30);
	[segmentedStyleControl addTarget:self action:@selector(enableiOSCalSync:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;	
	segmentedStyleControl.selectedSegmentIndex = (self.settingCopy.ekSyncEnabled?0:1);
	segmentedStyleControl.tag = baseTag;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];
    
    cell.textLabel.text = _iOSCalText;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //return self.settingCopy.syncEnabled?8:5;
    return self.settingCopy.syncEnabled?(self.settingCopy.sdwVerified && self.settingCopy.sdwSyncEnabled?7:6):5;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section)
	{
		case 0: //About
			return 1;
		case 1: //General
			return 8;
		case 2: //Task
			return 4;
		case 3: //Calendar
			return self.settingCopy.timeZoneSupport?4:3;
        case 4: //Syncronization
            return (self.settingCopy.autoSyncEnabled?3:(self.settingCopy.syncEnabled?2:1));
		case 5: //Split Source
			//return (self.settingCopy.sdwSyncEnabled?(self.settingCopy.sdwVerified?4:3):1);
            return (self.settingCopy.sdwSyncEnabled?2:3);
        case 6:
            return 1;
/*		case 6: //TD Sync
			return (self.settingCopy.tdSyncEnabled?3:1);
		case 7: //iCal Sync
			return (self.settingCopy.ekSyncEnabled?3:1);
*/
	}
	
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 1:
			return _generalText;
		case 2:
			return _tasksText;
		case 3:
			return _calendarText;
        case 4:
            return _synchronizationText;
		case 5:
			return _syncSetupText;
	}
	return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*if (indexPath.section == 4)
    {
        if (indexPath.row == 1)
        {
            return 80;
        }
    }
    else*/ if (indexPath.section == 5)
    {
        /*if (indexPath.row == 0 && !self.settingCopy.sdwSyncEnabled)
        {
            return 80;
        }*/
        
        if (indexPath.row == 3) // SDW sync 1 way
        {
            return 95;
        }
    }
/*    else if (indexPath.section == 6)
    {
        if (indexPath.row == 0)
        {
            return self.settingCopy.tdSyncEnabled?100:80;
        }
    }
    else if (indexPath.section == 7)
    {
    }
*/    
	return 40;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	else
	{
		for(UIView *view in cell.contentView.subviews)
		{
			if(view.tag >= 10000)
			{
				[view removeFromSuperview];
			}
		}		
	}
    
    // Set up the cell...
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryNone;
	//cell.text = @"";
	cell.textLabel.text = @"";
	cell.textLabel.backgroundColor = [UIColor clearColor];
	
	switch (indexPath.section)
	{
		case 0:
		{
			cell.textLabel.text = _aboutText;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
			break;
		case 1:
		{			
			switch (indexPath.row)
			{
				case 0:
				{
					[self createLandscapeEnableCell:cell baseTag:11000];
				}
					break;
				case 1:
				{
					[self createHintCell:cell baseTag:11010];
				}
					break;
				case 2:
				{
					[self createDefaultCategoryCell:cell baseTag:11020];
				}
					break;					
				case 3:
				{
					[self createTagListCell:cell baseTag:11030];
				}
					break;
				case 4:
				{
					[self createSnoozeDurationCell:cell baseTag:11040];
				}
					break;
				case 5:
				{
                    [self createDeleteWarningCell:cell baseTag:11050];
				}
					break;
				case 6:
				{
                    [self createSoundEnabledCell:cell baseTag:11060];
				}
					break;
				case 7:
				{
                    [self createTabBarAutoHideCell:cell baseTag:11070];
				}
					break;
				case 8:
				{
                    [self createDeleteSuspectedDuplicationCell:cell baseTag:11080];
				}
					break;
			}
			
		}
			break;
		case 2:
		{
			switch (indexPath.row)
			{
				case 0:
				{
					[self createDurationCell:cell baseTag:12000];
				}
					break;
				case 1:
				{
					[self createMustDoCell:cell baseTag:12010];
				}
					break;
				case 2:
				{
					[self createEventCombinationCell:cell baseTag:12020];
				}
					break;
				case 3:
				{
					//[self createNewTaskPlacementCell:cell baseTag:12030];
                    [self createHideFutureTasksCell:cell baseTag:12030];
				}
					break;					
			}
			break;
		}
		case 3:
		{
			switch (indexPath.row)
			{
				case 0:
				{
					[self createWorkingTimeCell:cell baseTag:13000];
				}
					break;
				case 1:
				{
					[self createWeekStartCell:cell baseTag:13010];
				}
					break;
                case 2:
                {
                    [self createTimeZoneSupportCell:cell baseTag:13020];
                }
                    break;
                case 3:
                {
                    [self createTimeZoneCell:cell baseTag:13030];
                }
                    break;
			}
		}
			break;
        case 4:
        {
			switch (indexPath.row)
			{
				case 0:
				{
                    [self createSynchronizationCell:cell baseTag:10400];
                }
                    break;
                case 1:
                {
                    [self createSyncAtStartUpCell:cell baseTag:10410];
                }
                    break;
                case 2:
                {
                    [self createAutoPushCell:cell baseTag:10420];
                }
                    break;
            }
            
            break;
        }
		case 5:
		{
			switch (indexPath.row)
			{
				case 0:
				{
                    [self createSyncSourceSwitchCell:cell baseTag:14000];
                }
                    break;
				case 1:
				{
                    if (self.settingCopy.sdwSyncEnabled)
                    {
                        [self createSDWAccountCell:cell baseTag:14010];
                    }
                    else
                    {
                        //cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)",_toodledoSyncText, _tasksText];
                        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        [self createTaskSyncCell:cell baseTag:14010];
                    }
                }
                    break;
				case 2:
				{
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)",_iOSCalSyncText, _eventsText];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                    break;
            }
        }
            break;
        case 6:
        {
			switch (indexPath.row)
			{
				case 0:
				{
                    cell.textLabel.text = _dataRecovery;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
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
	
	switch (indexPath.section) 
	{
		case 0:
		{
			switch (indexPath.row) 
			{
				case 0:
				{
					[self viewAbout];
				}
					break;
			}
		}
			break;
		case 1:
		{
			switch (indexPath.row) 
			{
                case 2:
                {
                    [self editTaskDefaultProject];
                }
                    break;
				case 3:
				{
                    [self editTagList];
				}
					break;
					
				case 4:
				{
					//[self editProjectNames];
                    [self editSnoozeDuration];
				}
					break;
				case 5:
				{
					
				}
					break;
			}
		}
			break;
		case 2:
		{
			switch (indexPath.row) 
			{
				case 0:
				{
					[self editTaskDuration];
				}
					break;
				case 1:
				{
					[self editMustDoDays];
				}
					break;
			}			
		}
			break;
		case 3:
		{
			switch (indexPath.row) 
			{
				case 0:
				{
					[self editWorkingTime];
				}
					break;
                case 3:
                {
                    [self editTimeZone];
                }
                    break;
			}
		}
			break;
		case 5:
		{
            if (self.settingCopy.sdwSyncEnabled)
            {
                switch (indexPath.row)
                {
                    case 1:
                    {
                        [self editSDWAccount];
                    }
                        break;
                }
            }
            else
            {
                switch (indexPath.row)
                {
                    case 1:
                    {
                        //[self editToodledoSync];
                        [self editTaskSync];
                    }
                        break;
                    case 2:
                    {
                        [self editCalSync];
                    }
                        break;
                }
            }

		}
            break;
        case 6:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    [self showDataRecovery];
                }
                    break;
            }
        }
            break;
	}
	
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark TextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{	
    [textField resignFirstResponder];
	
	return YES;	
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if (textField.tag == 11050) //Must Do
	{
		
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if (textField.tag == 11050) //Must Do
	{
		NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		
		if (![text isEqualToString:@""])
		{
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (void)dealloc {
	self.settingCopy = nil;
	
    [super dealloc];
}


@end

