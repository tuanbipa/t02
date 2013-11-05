//
//  MustDoEditViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 11/5/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "MustDoEditViewController.h"

#import "Common.h"
#import "Settings.h"

#import "iPadGeneralSettingViewController.h"
#import "SettingTableViewController.h"

@interface MustDoEditViewController ()

@end

@implementation MustDoEditViewController

@synthesize settings;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    if (_isiPad)
    {
        frm.size.width = 2*frm.size.width/3;
    }
    else
    {
        frm.size.width = 320;
    }
    
    frm.size.height = 9*35;
    
    UIView *contentView = [[UIView alloc] initWithFrame:frm];
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    
    self.view = contentView;
    [contentView release];
    
    listTableView = [[UITableView alloc] initWithFrame:frm style:UITableViewStylePlain];
    
	listTableView.delegate = self;
	listTableView.dataSource = self;
    listTableView.backgroundColor = [UIColor clearColor];
    
	[contentView addSubview:listTableView];
    
    [listTableView release];
    
    
    UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 8*35 - 10, frm.size.width - 20, 150)];
    hintLabel.backgroundColor = [UIColor clearColor];
    hintLabel.font = [UIFont systemFontOfSize:15];
    hintLabel.numberOfLines = 0;
    hintLabel.textColor = [Colors darkSteelBlue];
    
    hintLabel.text = _mustDoHint;

    [contentView addSubview:hintLabel];
    
    [hintLabel release];
    
    selectedIndex = -1;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.title = _mustDoRangeText;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.navigationController.topViewController isKindOfClass:[SettingTableViewController class]])
    {
        SettingTableViewController *ctrler = (SettingTableViewController *) self.navigationController.topViewController;
        
        [ctrler refreshMustDoCell];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self.settings.mustDoDays == indexPath.row)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        selectedIndex = indexPath.row;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d %@", indexPath.row, _daysText];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor grayColor];
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedIndex >= 0)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    selectedIndex = indexPath.row;
    
    self.settings.mustDoDays = indexPath.row;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
}


@end
