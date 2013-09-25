//
//  iOSCalSyncViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 1/22/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//
#import <EventKit/EventKit.h>

#import "iOSCalSyncViewController.h"

#import "Common.h"
#import "Settings.h"

#import "EKSync.h"

#import "GuideWebView.h"

#import "SyncWindow2TableViewController.h"
#import "iPadSyncSettingViewController.h"

//extern BOOL _isiPad;

@interface iOSCalSyncViewController ()

@end

@implementation iOSCalSyncViewController

@synthesize setting;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) editSyncWindow
{
	SyncWindow2TableViewController *ctrler = [[SyncWindow2TableViewController alloc] init];
	ctrler.setting = self.setting;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

- (void) enableiOSCalSync:(id) sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    if (![EKSync checkEKAccessEnabled])
    {
        EKEventStore *ekStore = [[EKEventStore alloc] init];
        
        [ekStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
         {
             [ekStore release];
             
             self.setting.ekSyncEnabled = granted;
             
             [settingTableView reloadData];
         }];
    }
    else
    {
        self.setting.ekSyncEnabled = (segmentedControl.selectedSegmentIndex == 0);
        
        [settingTableView reloadData];
    }
}

#pragma mark View

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
    
    UIView *contentView = [[UIView alloc] initWithFrame:frm];
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
    
    self.navigationItem.title = _iOSCalSyncText;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Cell Creation
- (void) createEKSyncEnableCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(settingTableView.bounds.size.width - 130, 5, 120, 30);
	[segmentedStyleControl addTarget:self action:@selector(enableiOSCalSync:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;
	segmentedStyleControl.selectedSegmentIndex = (self.setting.ekSyncEnabled?0:1);
	segmentedStyleControl.tag = baseTag;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];
    
    cell.textLabel.text = _iOSCalText;
}

- (void) createSyncWindowCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _syncWindowText;
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}


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
    
    switch (indexPath.row)
    {
        case 0:
        {
            [self createEKSyncEnableCell:cell baseTag:10000];
        }
            break;
        case 1:
        {
            [self createSyncWindowCell:cell baseTag:11000];
        }
            break;
    }    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 1:
        {
            [self editSyncWindow];
        }
            break;
            
    }
    
}

@end
