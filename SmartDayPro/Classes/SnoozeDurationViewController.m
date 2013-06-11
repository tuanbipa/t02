//
//  SnoozeDurationViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 3/25/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "SnoozeDurationViewController.h"

#import "Common.h"
#import "Settings.h"

#import "iPadGeneralSettingViewController.h"

@interface SnoozeDurationViewController ()

@end

@implementation SnoozeDurationViewController

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
    
    UIViewController *ctrler = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    
    if ([ctrler isKindOfClass:[iPadGeneralSettingViewController class]])
    {
        frm.size.width = 2*frm.size.width/3;
    }
    else
    {
        frm.size.width = 320;
    }
    
    UIView *contentView = [[UIView alloc] initWithFrame:frm];
    contentView.backgroundColor = [UIColor colorWithRed:219.0/255 green:222.0/255 blue:227.0/255 alpha:1];
    
    self.view = contentView;
    [contentView release];
    
    listTableView = [[UITableView alloc] initWithFrame:frm style:UITableViewStyleGrouped];
    
	listTableView.delegate = self;
	listTableView.dataSource = self;
    
	[contentView addSubview:listTableView];
    
    [listTableView release];
    
    selectedIndex = -1;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.title = _snoozeDuration;
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
    return 5;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger durations[5] = {5*60, 10*60, 15*60, 30*60, 60*60};
    
    NSInteger duration = durations[indexPath.row];
    
    if (settings.snoozeDuration*60 == duration)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        selectedIndex = indexPath.row;
    }
    
    cell.textLabel.text = [Common getDurationString:duration];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger durations[5] = {5*60, 10*60, 15*60, 30*60, 60*60};
    
    if (selectedIndex >= 0)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    selectedIndex = indexPath.row;
    
    settings.snoozeDuration = durations[selectedIndex]/60;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
}

@end
