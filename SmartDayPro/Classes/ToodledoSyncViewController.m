//
//  ToodledoSyncViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 1/21/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "ToodledoSyncViewController.h"

#import "Common.h"
#import "Settings.h"

#import "GuideWebView.h"
#import "ToodledoAccountViewController.h"

#import "SettingTableViewController.h"

@interface ToodledoSyncViewController ()

@end

@implementation ToodledoSyncViewController

@synthesize setting;
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

- (void) enableTDSync:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    self.setting.tdSyncEnabled = (segmentedControl.selectedSegmentIndex == 0);
    
    if (self.setting.tdSyncEnabled && self.setting.sdwSyncEnabled)
    {
        self.setting.sdwSyncEnabled = NO;
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


#pragma mark View

- (void) refreshView
{
    [settingTableView reloadData];
}

- (void) loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    UIView *contentView = [[UIView alloc] initWithFrame:frm];
    contentView.backgroundColor = [UIColor darkGrayColor];
    
    self.view = contentView;
    [contentView release];
	
    settingTableView = [[UITableView alloc] initWithFrame:contentView.bounds style:UITableViewStyleGrouped];
	settingTableView.delegate = self;
	settingTableView.dataSource = self;
	
	[contentView addSubview:settingTableView];
	[settingTableView release];
}

- (void) viewWillDisappear:(BOOL)animated
{
    UIViewController *topCtrler = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-1];
    
    if ([topCtrler isKindOfClass:[SettingTableViewController class]])
    {
        SettingTableViewController *ctrler = (SettingTableViewController *) topCtrler;
     
        ctrler.tdAccountChange = self.tdAccountChange;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.title = _toodledoSyncText;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Cell Creation
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
	tdSyncSegmentedControl.selectedSegmentIndex = (self.setting.tdSyncEnabled?0:1);
	tdSyncSegmentedControl.tag = baseTag+1;
	
	[cell.contentView addSubview:tdSyncSegmentedControl];
	[tdSyncSegmentedControl release];
}

- (void) createTDAccountCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    UILabel *verifiedLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 5, 100, 30)];
    verifiedLabel.backgroundColor = [UIColor clearColor];
    verifiedLabel.textAlignment = NSTextAlignmentRight;
    verifiedLabel.textColor = [Colors darkSteelBlue];
    verifiedLabel.tag = baseTag;
    verifiedLabel.text = (self.setting.tdVerified?_verifiedText:_unverifiedText);
    
	[cell.contentView addSubview:verifiedLabel];
	[verifiedLabel release];
    
    cell.textLabel.text = _accountText;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //return self.settingCopy.syncEnabled?8:5;
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
	cell.textLabel.backgroundColor = [UIColor clearColor];
    
    switch (indexPath.row)
    {
        case 0:
        {
            [self createTDSyncEnableCell:cell baseTag:10000];
        }
            break;
        /*case 1:
        {
            cell.textLabel.text = _autoSyncText;
            cell.accessoryType = (self.setting.tdAutoSyncEnabled?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone);
        }
            break;
        */
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
    switch (indexPath.row)
    {
        /*case 1:
        {
            self.setting.tdAutoSyncEnabled = !self.setting.tdAutoSyncEnabled;
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = (self.setting.tdAutoSyncEnabled?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone);
        }
            break;
        */
        case 1:
        {
            [self editToodledoAccount];
        }
            break;
    }
    
}

@end
