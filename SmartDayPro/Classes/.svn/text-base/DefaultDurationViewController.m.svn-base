//
//  DefaultDurationViewController.m
//  SmartCal
//
//  Created by Left Coast Logic on 9/14/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import "DefaultDurationViewController.h"

#import "Common.h"
#import "Settings.h"

@interface DefaultDurationViewController ()

@end

@implementation DefaultDurationViewController

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
    listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 416) style:UITableViewStyleGrouped];
    
	listTableView.delegate = self;
	listTableView.dataSource = self;

	self.view = listTableView;
    
    [listTableView release];
    
    selectedIndex = -1;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.title = _defaultDurationText;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger durations[6] = {15*60, 30*60, 60*60, 90*60, 120*60, 180*60};
    
    NSInteger duration = durations[indexPath.row];
    
    if (settings.taskDuration == duration)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        selectedIndex = indexPath.row;
    }
    
    cell.textLabel.text = [Common getDurationString:duration];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger durations[6] = {15*60, 30*60, 60*60, 90*60, 120*60, 180*60};

    if (selectedIndex >= 0)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    selectedIndex = indexPath.row;
    
    settings.taskDuration = durations[selectedIndex];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
}

@end
