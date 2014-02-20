//
//  iPadTaskSettingViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 2/20/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "iPadTaskSettingViewController.h"

#import "Common.h"
#import "Settings.h"

#import "ContentView.h"

#import "DefaultDurationViewController.h"
#import "NumberInputViewController.h"
#import "MustDoEditViewController.h"

@interface iPadTaskSettingViewController ()

@end

@implementation iPadTaskSettingViewController

@synthesize setting;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) editTaskDuration
{
	DefaultDurationViewController *ctrler = [[DefaultDurationViewController alloc] init];
	ctrler.settings = self.setting;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

- (void) editMustDoDays
{
    /*
	NumberInputViewController *ctrler = [[NumberInputViewController alloc] init];
    
	ctrler.objectEdit = self.setting;
	ctrler.keyEdit = SETTING_EDIT_MUSTDO_DAYS;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];*/
	
	MustDoEditViewController *ctrler = [[MustDoEditViewController alloc] init];
    ctrler.settings = self.setting;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

#pragma mark Actions

- (void) changeEventCombination: (id) sender
{
	UISegmentedControl *segmentedStyleControl = (UISegmentedControl *)sender;
	
	self.setting.eventCombination = segmentedStyleControl.selectedSegmentIndex;
}

- (void) hideFutureTasks: (id) sender
{
	UISegmentedControl *segmentedStyleControl = (UISegmentedControl *)sender;
	
	self.setting.hideFutureTasks = (segmentedStyleControl.selectedSegmentIndex == 0);
}

#pragma mark View

- (void) loadView
{
    CGSize sz = [Common getScreenSize];
    
    CGRect frm = CGRectZero;
    frm.origin.y = 20;
    frm.size = sz;
    
    frm.size.width = 2*frm.size.width/3;
    
    ContentView *contentView = [[ContentView alloc] initWithFrame:frm];
    //contentView.backgroundColor = [UIColor colorWithRed:219.0/255 green:222.0/255 blue:227.0/255 alpha:1];
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

- (void)viewDidAppear:(BOOL)animated {
	[settingTableView reloadData];
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

#pragma mark Cell Creation
- (void) createDurationCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.textLabel.text = _durationText;
	
	UILabel *durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(settingTableView.bounds.size.width - 215 - 30, 10, 205, 20)];
	durationLabel.tag = baseTag;
	durationLabel.textAlignment = NSTextAlignmentRight;
	durationLabel.backgroundColor = [UIColor clearColor];
	durationLabel.font = [UIFont boldSystemFontOfSize:16];
	durationLabel.textColor = [UIColor darkGrayColor];
	
	durationLabel.text = [Common getDurationString:self.setting.taskDuration];
	
	[cell.contentView addSubview:durationLabel];
	[durationLabel release];
	
}

- (void) createMustDoCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = _mustDoRangeText;
    
	UILabel *daysLabel = [[UILabel alloc] initWithFrame:CGRectMake(settingTableView.bounds.size.width - 50 - 30, 10, 40, 20)];
	daysLabel.tag = baseTag;
	daysLabel.textAlignment = NSTextAlignmentRight;
	daysLabel.backgroundColor = [UIColor clearColor];
	daysLabel.font = [UIFont boldSystemFontOfSize:16];
	daysLabel.textColor = [UIColor darkGrayColor];
    daysLabel.text = [NSString stringWithFormat:@"%d", self.setting.mustDoDays];
    
    [cell.contentView addSubview:daysLabel];
    [daysLabel release];
}

- (void) createEventCombinationCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _showInCalendarText;
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(settingTableView.bounds.size.width - 110, 5, 100, 30);
	[segmentedStyleControl addTarget:self action:@selector(changeEventCombination:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;
	segmentedStyleControl.selectedSegmentIndex = self.setting.eventCombination;
	segmentedStyleControl.tag = baseTag;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];
}

- (void) createHideFutureTasksCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _hideFutureTasks;
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(settingTableView.bounds.size.width - 110, 5, 100, 30);
	[segmentedStyleControl addTarget:self action:@selector(hideFutureTasks:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;
	segmentedStyleControl.selectedSegmentIndex = self.setting.hideFutureTasks?0:1;
	segmentedStyleControl.tag = baseTag;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
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
	
    cell.imageView.image = nil;
    cell.textLabel.text = @"";
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor grayColor];
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.backgroundColor = [UIColor clearColor];
	
    switch (indexPath.row)
    {
        case 0:
        {
            [self createDurationCell:cell baseTag:10000];
        }
            break;
        /*case 1:
        {
            [self createMustDoCell:cell baseTag:10010];
        }
            break;*/
        case 1:
        {
            [self createEventCombinationCell:cell baseTag:10020];
        }
            break;
        case 2:
        {
            [self createHideFutureTasksCell:cell baseTag:10030];
        }
            break;
    }
    
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
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

@end
