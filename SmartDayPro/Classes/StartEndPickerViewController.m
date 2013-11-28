//
//  StartEndPickerViewController.m
//  SmartPlan
//
//  Created by Huy Le on 12/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StartEndPickerViewController.h"

#import "Common.h"
#import "Settings.h"
#import "Colors.h"
#import "Task.h"

#import "DBManager.h"
#import "ImageManager.h"

#import "TimeZonePickerViewController.h"
//#import "TaskDetailTableViewController.h"

@implementation StartEndPickerViewController

@synthesize minStartTime;
@synthesize task;
@synthesize taskCopy;

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
		//saveButton = nil;
        
        self.preferredContentSize = CGSizeMake(320,416);
	}
	
	return self;
}

- (void)dealloc {
	self.minStartTime = nil;
	
	self.taskCopy = nil;
	
    [super dealloc];
}

-(void) refreshPicker
{
	switch (selectedIndex) 
	{
		case 0:
			datePicker.date = [self.taskCopy startTime];
			break;
		case 1:
			datePicker.date = [self.taskCopy endTime];
			break;			
	}	
}

- (void) editTimeZone
{
    TimeZonePickerViewController *ctrler = [[TimeZonePickerViewController alloc] init];
    ctrler.objectEdit = self.taskCopy;
    
    [self.navigationController pushViewController:ctrler animated:YES];
    
    [ctrler release];
}

- (void) refreshTimeZone
{
    NSInteger secs = [datePicker.timeZone secondsFromGMT]-[Common getSecondsFromTimeZoneID:self.taskCopy.timeZoneId];
    
    self.taskCopy.startTime = [self.taskCopy.startTime dateByAddingTimeInterval:secs];
    self.taskCopy.endTime = [self.taskCopy.endTime dateByAddingTimeInterval:secs];
    
    //datePicker.timeZone = self.taskCopy.timeZoneId == 0? [NSTimeZone defaultTimeZone]:[NSTimeZone timeZoneWithName:[Settings getTimeZoneDisplayNameByID:self.taskCopy.timeZoneId]];
    datePicker.timeZone =[Settings getTimeZoneByID:self.taskCopy.timeZoneId];
    
    [self refreshPicker];
    
    [pickerTableView reloadData];    
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	self.taskCopy = self.task;
    
    /*
    //convert time to event timezone
    NSInteger secs = [Common getSecondsFromTimeZoneID:self.taskCopy.timeZoneId] - [[NSTimeZone defaultTimeZone] secondsFromGMT];
    
    self.taskCopy.startTime = [self.task.startTime dateByAddingTimeInterval:secs];
    self.taskCopy.endTime = [self.task.endTime dateByAddingTimeInterval:secs];
    */
    
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    frm.size.width = 320;
	
	UIView *contentView = [[UIView alloc] initWithFrame:frm];
	contentView.backgroundColor = [UIColor colorWithRed:161.0/255 green:162.0/255 blue:169.0/255 alpha:1];
	
	datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 150, 0, 0)];
	[datePicker addTarget:self action:@selector(timeChanged:) forControlEvents:UIControlEventValueChanged];
	datePicker.minuteInterval=5;
    
    //datePicker.timeZone =  self.taskCopy.timeZoneId == 0?[NSTimeZone defaultTimeZone]:[NSTimeZone timeZoneWithName:[Settings getTimeZoneDisplayNameByID:self.taskCopy.timeZoneId]];
    datePicker.timeZone = [Settings getTimeZoneByID:self.taskCopy.timeZoneId];
    
	datePicker.datePickerMode = ([self.taskCopy isADE]? UIDatePickerModeDate: UIDatePickerModeDateAndTime);
	
    datePicker.date = (self.taskCopy.startTime == nil?[NSDate date]:self.taskCopy.startTime);
	
	[contentView addSubview: datePicker];
	[datePicker release];
	
	pickerTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 150) style:UITableViewStyleGrouped];
    pickerTableView.delegate = self;
    pickerTableView.dataSource = self;
	pickerTableView.scrollEnabled=NO;
	pickerTableView.sectionHeaderHeight=5;
	pickerTableView.sectionFooterHeight=3;
	
    [contentView addSubview:pickerTableView];
	[pickerTableView release];	
	
	self.view = contentView;
	[contentView release];
	
	self.navigationItem.title = _timeEditTitle;	
	
	selectedIndex = 0;
	[self refreshPicker];
}


/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
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

- (void)viewDidAppear:(BOOL)animated 
{
	[pickerTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];	
	
	UITableViewCell *cell = [pickerTableView cellForRowAtIndexPath:pickerTableView.indexPathForSelectedRow];
	
	UILabel *label = (UILabel *)[cell viewWithTag:10000+selectedIndex];
	label.textColor = [UIColor whiteColor];	
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self save];
    
    /*
    if ([self.navigationController.topViewController isKindOfClass:[TaskDetailTableViewController class]])
    {
        TaskDetailTableViewController *ctrler = (TaskDetailTableViewController *)self.navigationController.topViewController;
        
        [ctrler refreshWhen];
    }*/
}

#pragma mark Actions
- (void)timeChanged:(id)sender
{
	UIDatePicker *picker = (UIDatePicker *) sender;
    
    //NSInteger secs = [[NSTimeZone defaultTimeZone] secondsFromGMT]-[picker.timeZone secondsFromGMT];
    
    NSDate *dt = picker.date;
	
	if ([dt compare:self.minStartTime] == NSOrderedAscending)
	{
		dt = self.minStartTime;		
	}
	
	if (selectedIndex == 0)
	{
        self.taskCopy.startTime = [self.taskCopy isADE]?[Common clearTimeForDate:dt]:dt;
	}
	else
	{
        self.taskCopy.endTime = [self.taskCopy isADE]?[Common getEndDate:dt]:dt;
	}
	
	if ([self.taskCopy.endTime compare:self.taskCopy.startTime] != NSOrderedDescending)
	{
		if (selectedIndex == 1)
		{
            self.taskCopy.startTime = [self.taskCopy isADE]?[Common clearTimeForDate:self.taskCopy.endTime]:[Common dateByAddNumSecond:-3600 toDate:self.taskCopy.endTime];
		}
		else
		{
            self.taskCopy.endTime = [self.taskCopy isADE]?[Common getEndDate:self.taskCopy.startTime]:[Common dateByAddNumSecond:3600 toDate:self.taskCopy.startTime];
		}
	}
    
	UITableViewCell *cell = [pickerTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	
    cell.detailTextLabel.text = [self.taskCopy getDisplayStartTime];
	
	cell = [pickerTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
	
    cell.detailTextLabel.text = [self.taskCopy getDisplayEndTime];
}

- (void)save
{
    task.timeZoneId = taskCopy.timeZoneId;
    
    task.startTime = taskCopy.startTime;
    task.endTime = taskCopy.endTime;
    
    //convert to default time zone
    /*NSInteger secs = [Common getSecondsFromTimeZoneID:task.timeZoneId]-[[NSTimeZone defaultTimeZone] secondsFromGMT];
    
    task.startTime = [taskCopy.startTime dateByAddingTimeInterval:secs];
    task.endTime = [taskCopy.endTime dateByAddingTimeInterval:secs];*/
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    Settings *settings = [Settings getInstance];
    
    return settings.timeZoneSupport?([self.taskCopy isADE]?2:3):2;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
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
	
	NSString *titles[3] = {_startText, _endText, _timeZone};
	
	cell.textLabel.text = titles[indexPath.row]; 
    NSInteger tzId = self.taskCopy.timeZoneId;

    NSString *details[3] = {[self.taskCopy getDisplayStartTime],[self.taskCopy getDisplayEndTime],[Settings getTimeZoneDisplayNameByID:tzId]};
    
    cell.detailTextLabel.text = details[indexPath.row];
    
    cell.accessoryType = indexPath.row == 2?UITableViewCellAccessoryDisclosureIndicator:UITableViewCellAccessoryNone;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
    
    if (indexPath.row == 2)
    {
        [self editTimeZone];
    }
	else
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]];
        
        UILabel *label = (UILabel *)[cell viewWithTag:10000+selectedIndex];
        label.textColor = [Colors darkSteelBlue];
        
        selectedIndex = indexPath.row;
        
        cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]];
        label = (UILabel *)[cell viewWithTag:10000+selectedIndex];
        label.textColor = [UIColor whiteColor];
        
        [self refreshPicker];        
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


@end
