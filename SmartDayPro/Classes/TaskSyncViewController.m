//
//  TaskSyncViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 4/8/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <EventKit/EventKit.h>

#import "TaskSyncViewController.h"

#import "Common.h"
#import "Settings.h"

#import "EKReminderSync.h"

#import "GuideWebView.h"
#import "ToodledoAccountViewController.h"

#import "SettingTableViewController.h"
#import "iPadSyncSettingViewController.h"
#import "iPadSettingViewController.h"

extern BOOL _isiPad;
extern iPadSettingViewController *_iPadSettingViewCtrler;

@interface TaskSyncViewController ()

@end

@implementation TaskSyncViewController
@synthesize tdAccountChange;

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
        self.tdAccountChange = NO;
    }
    
    return self;
}

- (void) checkEKAccess
{
    if (![EKReminderSync checkEKReminderAccessEnabled])
    {
        EKEventStore *ekStore = [[[EKEventStore alloc] init] autorelease];
        
        [ekStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error)
         {
             //[ekStore release];
             
             self.setting.rmdSyncEnabled = granted;
             
             if (!self.setting.rmdSyncEnabled)
             {
                 self.setting.tdSyncEnabled = YES;
                 
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""  message:_reminderAccessHint delegate:self cancelButtonTitle:nil otherButtonTitles:_okText, nil];

                 [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                 
                 [alertView release];
                 
             }
             
             [settingTableView reloadData];
             
         }];
    }    
}

- (void) enableTaskSync:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    if (segmentedControl.selectedSegmentIndex == 1)
    {
        self.setting.tdSyncEnabled = NO;
        self.setting.rmdSyncEnabled = NO;
    }
    else
    {
        if (!self.setting.tdSyncEnabled && !self.setting.rmdSyncEnabled)
        {
            self.setting.rmdSyncEnabled = NO;
            self.setting.tdSyncEnabled = YES;
        }
    }
    
    if ((self.setting.tdSyncEnabled || self.setting.rmdSyncEnabled) && self.setting.sdwSyncEnabled)
    {
        self.setting.sdwSyncEnabled = NO;
    }
        
    [settingTableView reloadData];
}

- (void) switchSyncSource:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    self.setting.tdSyncEnabled = (segmentedControl.selectedSegmentIndex == 0);
    self.setting.rmdSyncEnabled = (segmentedControl.selectedSegmentIndex == 1);
    
    if ((self.setting.tdSyncEnabled || self.setting.rmdSyncEnabled) && self.setting.sdwSyncEnabled)
    {
        self.setting.sdwSyncEnabled = NO;
    }
    
    if (self.setting.rmdSyncEnabled)
    {
        /*
        if (![EKReminderSync checkEKReminderAccessEnabled])
        {
            EKEventStore *ekStore = [[[EKEventStore alloc] init] autorelease];
            
            [ekStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error)
             {
                 //[ekStore release];
                 
                 self.setting.rmdSyncEnabled = granted;
                 
                 if (!self.setting.rmdSyncEnabled)
                 {
                     self.setting.tdSyncEnabled = YES;
                 }

             }];
        }*/
        
        [self checkEKAccess];
    }

    [settingTableView reloadData];
}

-(void) editToodledoAccount
{
	ToodledoAccountViewController *ctrler = [[ToodledoAccountViewController alloc] init];
	
    ctrler.setting = [Settings getInstance];
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

#pragma mark Views
- (void) refreshView
{
    [settingTableView reloadData];
}

- (void) loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    UIViewController *ctrler = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    
    if ([ctrler isKindOfClass:[iPadSyncSettingViewController class]])
    {
        frm.size.width = 2*frm.size.width/3;
    }
    else
    {
        frm.size.width = 320;
    }
    
    contentView = [[UIView alloc] initWithFrame:frm];
    //contentView.backgroundColor = [UIColor darkGrayColor];
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    
    self.view = contentView;
    [contentView release];
	
    settingTableView = [[UITableView alloc] initWithFrame:contentView.bounds style:UITableViewStylePlain];
	settingTableView.delegate = self;
	settingTableView.dataSource = self;
    settingTableView.backgroundColor = [UIColor clearColor];
	
	[contentView addSubview:settingTableView];
	[settingTableView release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    UIViewController *topCtrler = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-1];
    
    if ([topCtrler isKindOfClass:[SettingTableViewController class]])
    {
        SettingTableViewController *ctrler = (SettingTableViewController *) topCtrler;
        
        ctrler.tdAccountChange = self.tdAccountChange;
    }
    else if ([topCtrler isKindOfClass:[iPadSyncSettingViewController class]])
    {
        if (_iPadSettingViewCtrler != nil)
        {
            _iPadSettingViewCtrler.tdAccountChange = self.tdAccountChange;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Cell Creation

- (void) createTaskSyncEnableCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    /*
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 120, 30)];
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.tag = baseTag;
    titleLabel.text = _enableText;
    
	[cell.contentView addSubview:titleLabel];
	[titleLabel release];
    */
    
    cell.textLabel.text = _enableText;
    
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
	UISegmentedControl *tdSyncSegmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	tdSyncSegmentedControl.frame = CGRectMake(settingTableView.bounds.size.width - 130, 5, 120, 30);
	[tdSyncSegmentedControl addTarget:self action:@selector(enableTaskSync:) forControlEvents:UIControlEventValueChanged];
	tdSyncSegmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;
	tdSyncSegmentedControl.selectedSegmentIndex = (!self.setting.tdSyncEnabled && !self.setting.rmdSyncEnabled?1:0);
	tdSyncSegmentedControl.tag = baseTag+1;
	
	[cell.contentView addSubview:tdSyncSegmentedControl];
	[tdSyncSegmentedControl release];
}

- (void) createSyncSourceCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    /*
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 120, 30)];
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.tag = baseTag;
    titleLabel.text = _sourceText;
    
	[cell.contentView addSubview:titleLabel];
	[titleLabel release];*/
    
    cell.textLabel.text = _sourceText;
    
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _toodledoText, _reminderText, nil];
	UISegmentedControl *tdSyncSegmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	tdSyncSegmentedControl.frame = CGRectMake(settingTableView.bounds.size.width - 210, 5, 200, 30);
	[tdSyncSegmentedControl addTarget:self action:@selector(switchSyncSource:) forControlEvents:UIControlEventValueChanged];
	tdSyncSegmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;
	tdSyncSegmentedControl.selectedSegmentIndex = (self.setting.tdSyncEnabled?0:1);
	tdSyncSegmentedControl.tag = baseTag+1;
	
	[cell.contentView addSubview:tdSyncSegmentedControl];
	[tdSyncSegmentedControl release];
}

- (void) createTDAccountCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    UILabel *verifiedLabel = [[UILabel alloc] initWithFrame:CGRectMake(settingTableView.bounds.size.width - 110 - 30, 5, 100, 30)];
    verifiedLabel.backgroundColor = [UIColor clearColor];
    verifiedLabel.textAlignment = NSTextAlignmentRight;
    verifiedLabel.font = [UIFont boldSystemFontOfSize:16];
    verifiedLabel.textColor = [UIColor darkGrayColor];
    verifiedLabel.tag = baseTag;
    verifiedLabel.text = (self.setting.tdVerified?_verifiedText:_unverifiedText);
    
	[cell.contentView addSubview:verifiedLabel];
	[verifiedLabel release];
    
    cell.textLabel.text = _accountText;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.setting.tdSyncEnabled?2:1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    return section == 0 && (self.setting.tdSyncEnabled || self.setting.rmdSyncEnabled)?2:1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 1)
        return 40.0f;
    
    return 0.01f;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        CGRect frm = tableView.bounds;
        frm.size.height = 40;
        
        UILabel *label = [[UILabel alloc] initWithFrame:frm];
        label.backgroundColor = [UIColor clearColor];
        label.text = _toodledoText;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:20];
        label.textColor = [Colors darkSteelBlue];
        
        return [label autorelease];
    }
    
    return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}


/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return _toodledoText;
    }
    
    return @"";
}
*/
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
	cell.textLabel.text = @"";
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor grayColor];
    
    cell.backgroundColor = [UIColor clearColor];
    
    switch (indexPath.section)
    {
        case 0:
        {
            switch (indexPath.row)
            {
                case 0:
                    [self createTaskSyncEnableCell:cell baseTag:10000];                    
                    break;
                case 1:
                    [self createSyncSourceCell:cell baseTag:10010];
                    break;
            }
        }
            break;
        case 1:
        {
            [self createTDAccountCell:cell baseTag:11000];
        }
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 1:
        {
            [self editToodledoAccount];
        }
            break;
    }
    
}

@end
