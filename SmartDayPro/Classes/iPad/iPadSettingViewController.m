//
//  iPadSettingViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 2/19/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "iPadSettingViewController.h"

#import "Common.h"
#import "Settings.h"
#import "ContentView.h"

#import "TaskManager.h"
#import "ProjectManager.h"
#import "DBManager.h"
#import "TagDictionary.h"
#import "TDSync.h"
#import "SDWSync.h"
#import "EKSync.h"

#import "iPadGeneralSettingViewController.h"
#import "iPadCalendarSettingViewController.h"
#import "iPadTaskSettingViewController.h"
#import "iPadSyncSettingViewController.h"

#import "ProjectSelectionTableViewController.h"
#import "TagListViewController.h"
#import "DefaultDurationViewController.h"
#import "NumberInputViewController.h"
#import "SDWAccountViewController.h"
#import "ToodledoSyncViewController.h"
#import "ToodledoAccountViewController.h"
#import "iOSCalSyncViewController.h"
#import "SyncWindow2TableViewController.h"
#import "DataRecoveryViewController.h"
#import "SnoozeDurationViewController.h"

#import "AbstractSDViewController.h"
#import "iPadViewController.h"

extern AbstractSDViewController *_abstractViewCtrler;

iPadSettingViewController *_iPadSettingViewCtrler;

@interface iPadSettingViewController ()

@end

@implementation iPadSettingViewController

@synthesize navCtrler;
@synthesize settingCopy;

@synthesize sdwAccountChange;
@synthesize tdAccountChange;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void) refresh
{
    [masterTableView reloadData];
}

- (void) save
{
	TaskManager *tm = [TaskManager getInstance];
    DBManager *dbm = [DBManager getInstance];
    ProjectManager *pm = [ProjectManager getInstance];
	
	Settings *settings = [Settings getInstance];
    
    BOOL hideFutureTaskChange = settings.hideFutureTasks != self.settingCopy.hideFutureTasks;
	
	BOOL reSchedule = (settings.eventCombination != self.settingCopy.eventCombination || settings.minimumSplitSize != self.settingCopy.minimumSplitSize || [settings checkWorkingTimeChange:self.settingCopy]);
	
	BOOL changeSkin = (settings.skinStyle != self.settingCopy.skinStyle);
	
	BOOL weekStartChange = (settings.weekStart != self.settingCopy.weekStart);
	
	BOOL tabBarChanged = (settings.tabBarAutoHide != self.settingCopy.tabBarAutoHide);
    
	BOOL ekAutoSyncChange = (settings.ekAutoSyncEnabled != self.settingCopy.ekAutoSyncEnabled);
	BOOL tdAutoSyncChange = (settings.tdAutoSyncEnabled != self.settingCopy.tdAutoSyncEnabled);
	BOOL sdwAutoSyncChange = (settings.sdwAutoSyncEnabled != self.settingCopy.sdwAutoSyncEnabled);
    
    BOOL mustDoDaysChange = (settings.mustDoDays != self.settingCopy.mustDoDays);
    
    BOOL defaultCatChange = (settings.taskDefaultProject != self.settingCopy.taskDefaultProject);
    
    BOOL ekSyncWindowChange = (settings.syncWindowStart != self.settingCopy.syncWindowStart) || (settings.syncWindowEnd != self.settingCopy.syncWindowEnd);
    
	if (settings.taskDuration != self.settingCopy.taskDuration)
	{
		tm.lastTaskDuration = self.settingCopy.taskDuration;
	}
	
	if (settings.taskDefaultProject != self.settingCopy.taskDefaultProject)
	{
		tm.lastTaskProjectKey = self.settingCopy.taskDefaultProject;
	}
	
    if (self.tdAccountChange)
	{
		[settings resetToodledoSync];
		
		[dbm resetToodledoIds];
        [pm resetToodledoIds];
        
        [[TDSync getInstance] resetSyncSection];
	}
    
    if (self.sdwAccountChange)
	{
		[settings resetSDWSync];
		
		[dbm resetSDWIds];
        [pm resetSDWIds];
        
        [[SDWSync getInstance] resetSyncSection];
	}
    
	[settings updateSettings:self.settingCopy];
    
    if (weekStartChange)
    {
        [[NSCalendar currentCalendar] setFirstWeekday:settings.weekStart==0?1:2];
    }
    
    if (tabBarChanged)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TabBarModeChangeNotification" object:nil];
    }
	
	if (reSchedule && !mustDoDaysChange)
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
    
	BOOL ekAutoSyncON = (settings.ekSyncEnabled && settings.ekAutoSyncEnabled) && (ekAutoSyncChange || ekSyncWindowChange);
	BOOL tdAutoSyncON = (settings.tdSyncEnabled && settings.tdAutoSyncEnabled) && tdAutoSyncChange;
	BOOL sdwAutoSyncON = (settings.sdwSyncEnabled && settings.sdwAutoSyncEnabled) && sdwAutoSyncChange;
    
	if (ekAutoSyncON)
	{
		[[EKSync getInstance] performSelector:@selector(initBackgroundAuto2WaySync) withObject:nil afterDelay:0.5];
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
        [[_abstractViewCtrler getCategoryViewController] loadAndShowList];
    }
    
    Project *prj = [pm getProjectByKey:settings.taskDefaultProject];
    
    if (prj != nil)
    {
        // to refresh visibility in mySD if it was hidden in mySD before
        [prj modifyUpdateTimeIntoDB:[dbm getDatabase]];
    }
}

- (void) dealloc
{
    self.navCtrler = nil;
    
    [super dealloc];
}

- (void) back:(id) sender
{
    [self.navCtrler popViewControllerAnimated:YES];
}

- (void) loadView
{
    self.settingCopy = [Settings getInstance];
    
    self.sdwAccountChange = NO;
    self.tdAccountChange = NO;
    
    CGSize sz = [Common getScreenSize];
    
    CGRect frm = CGRectZero;
    frm.size = sz;
    
    ContentView *contentView = [[ContentView alloc] initWithFrame:frm];
    contentView.backgroundColor = [UIColor colorWithRed:219.0/255 green:222.0/255 blue:227.0/255 alpha:1];
    
    self.view = contentView;
    
    [contentView release];
    
	masterTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, contentView.frame.size.width/3, contentView.frame.size.height) style:UITableViewStyleGrouped];
	masterTableView.delegate = self;
	masterTableView.dataSource = self;
    
	[contentView addSubview:masterTableView];
	[masterTableView release];
    
    detailView = [[UIView alloc] initWithFrame:CGRectMake(contentView.frame.size.width/3, -20, 2*contentView.frame.size.width/3, contentView.frame.size.height+20)];
    detailView.clipsToBounds = YES;

    [contentView addSubview:detailView];
    [detailView release];
    
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(contentView.frame.size.width/3, 0, 1, contentView.frame.size.height)];
    
    separatorView.backgroundColor = [UIColor lightGrayColor];
    
    [contentView addSubview:separatorView];
    
    [separatorView release];
    
    navView = [[UIView alloc] initWithFrame:CGRectMake(contentView.frame.size.width/3, 0, 2*contentView.frame.size.width/3, 40)];
    navView.backgroundColor = [UIColor clearColor];
    navView.hidden = YES;
    
    [self.navigationController.navigationBar addSubview:navView];
    [navView release];
    
	UIButton *backButton = [Common createButton:_doneText
                                         buttonType:UIButtonTypeCustom
                                              frame:CGRectMake(0, 5, 60, 30)
                                         titleColor:[UIColor whiteColor]
                                             target:self
                                           selector:@selector(back:)
                                   normalStateImage:@"blue_button.png"
                                 selectedStateImage:nil];
    [navView addSubview:backButton];
    
    navLabel = [[UILabel alloc] initWithFrame:navView.bounds];
    navLabel.font = [UIFont boldSystemFontOfSize:18];
    navLabel.backgroundColor = [UIColor clearColor];
    navLabel.textColor = [UIColor whiteColor];
    navLabel.textAlignment = NSTextAlignmentCenter;
    
    [navView addSubview:navLabel];
    [navLabel release];
    
}

- (void) showDetail:(NSInteger)index
{
    UIViewController *detailCtrler = nil;
    
    switch (index)
    {
        case 0:
        {
            iPadGeneralSettingViewController *ctrler = [[[iPadGeneralSettingViewController alloc] init] autorelease];
            
            ctrler.setting = self.settingCopy;
            
            detailCtrler = ctrler;
        }
            break;
        case 1:
        {
            iPadCalendarSettingViewController *ctrler = [[[iPadCalendarSettingViewController alloc] init] autorelease];
            
            ctrler.setting = self.settingCopy;
            
            detailCtrler = ctrler;
        }
            break;
        case 2:
        {
            iPadTaskSettingViewController *ctrler = [[[iPadTaskSettingViewController alloc] init] autorelease];
            
            ctrler.setting = self.settingCopy;
            
            detailCtrler = ctrler;
        }
            break;
        case 3:
        {
            iPadSyncSettingViewController *ctrler = [[[iPadSyncSettingViewController alloc] init] autorelease];
            
            ctrler.setting = self.settingCopy;
            
            detailCtrler = ctrler;
        }
            break;
        case 4:
        {
            DataRecoveryViewController *ctrler = [[[DataRecoveryViewController alloc] init] autorelease];
            
            detailCtrler = ctrler;
        }
            break;
    }

    selectedIndex = index;
    
    if ([self.navCtrler.view superview])
    {
        [self.navCtrler.view removeFromSuperview];
    }
    
    if (detailCtrler != nil)
    {
        self.navCtrler = [[UINavigationController alloc] initWithRootViewController:detailCtrler];
        
        self.navCtrler.delegate = self;
        self.navCtrler.navigationBar.hidden = YES;
        
        [detailView addSubview:self.navCtrler.view];        
    }
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    _iPadSettingViewCtrler = self;
    
    [self showDetail:0];
    
    [masterTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.navigationController.topViewController isKindOfClass:[iPadViewController class]])
    {
        [navView removeFromSuperview];
        
        [self save];
    }
    
    _iPadSettingViewCtrler = nil;
}

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

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    navView.hidden = [viewController isKindOfClass:[iPadGeneralSettingViewController class]] ||
                      [viewController isKindOfClass:[iPadCalendarSettingViewController class]] ||
                        [viewController isKindOfClass:[iPadTaskSettingViewController class]] ||
                        [viewController isKindOfClass:[iPadSyncSettingViewController class]] ||
                        [viewController isKindOfClass:[DataRecoveryViewController class]];
    
    if ([viewController isKindOfClass:[ProjectSelectionTableViewController class]])
    {
        navLabel.text = _defaultProjectText;
    }
    else if ([viewController isKindOfClass:[TagListViewController class]])
    {
        navLabel.text = _tagListText;
    }
    else if ([viewController isKindOfClass:[DefaultDurationViewController class]])
    {
        navLabel.text = _defaultDurationText;
    }
    else if ([viewController isKindOfClass:[NumberInputViewController class]] && selectedIndex == 2)
    {
        navLabel.text = _mustDoRangeText;
    }
    else if ([viewController isKindOfClass:[SDWAccountViewController class]])
    {
        navLabel.text = _mySDAccountText;
    }
    else if ([viewController isKindOfClass:[ToodledoSyncViewController class]])
    {
        navLabel.text = _toodledoSyncText;
    }
    else if ([viewController isKindOfClass:[ToodledoAccountViewController class]])
    {
        navLabel.text = _toodledoAccountText;
    }
    else if ([viewController isKindOfClass:[iOSCalSyncViewController class]])
    {
        navLabel.text = _iOSCalSyncText;
    }
    else if ([viewController isKindOfClass:[SyncWindow2TableViewController class]])
    {
        navLabel.text = _syncWindowText;
    }
    else if ([viewController isKindOfClass:[SnoozeDurationViewController class]])
    {
        navLabel.text = _snoozeDuration;
    }
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:masterTableView])
    {
        return self.settingCopy.sdwVerified && self.settingCopy.sdwSyncEnabled?5:4;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40;
}

/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	cell.backgroundView.backgroundColor = [UIColor clearColor];
	cell.contentView.backgroundColor = [UIColor clearColor];
	cell.textLabel.backgroundColor = [UIColor clearColor];
	cell.backgroundColor = [UIColor clearColor];
}
*/
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
	
    cell.imageView.image = nil;
    cell.textLabel.text = @"";
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	//cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
    if ([tableView isEqual:masterTableView])
    {
		switch (indexPath.section)
        {
			case 0:
			{
				switch (indexPath.row)
                {
					case 0:
					{
						cell.imageView.image=[UIImage imageNamed:@"settings_general.png"];
						cell.textLabel.text = _generalText;
					}
						break;
					case 1:
					{
						cell.imageView.image = [UIImage imageNamed:@"settings_calendars.png"];
						cell.textLabel.text = _calendarText;
					}
						break;
					case 2:
					{
						cell.imageView.image=[UIImage imageNamed:@"settings_tasks.png"];
						cell.textLabel.text = _taskText;
					}
						break;
					case 3:
					{
						cell.imageView.image = [UIImage imageNamed:@"settings_sync.png"];
						cell.textLabel.text = _synchronizationText;
					}
						break;
					case 4:
					{
						//cell.imageView.image = [UIImage imageNamed:@"settings_sync.png"];
						cell.textLabel.text = _dataRecovery;
					}
						break;
				}
			}
				break;
		}
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showDetail:indexPath.row];
}

@end
