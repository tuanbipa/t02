    //
//  WorkingTime7ViewController.m
//  SmartCal
//
//  Created by MacBook Pro on 4/25/11.
//  Copyright 2011 LCL. All rights reserved.
//

#import "WorkingTime7ViewController.h"

#import "Settings.h"
#import "Colors.h"
#import "ImageManager.h"

//#import "SCTabBarController.h"

//extern SCTabBarController *_tabBarCtrler;
extern BOOL _workingTimeHintShown;

@implementation WorkingTime7ViewController

@synthesize settings;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

- (id) init
{
	if (self = [super init])
	{
	}
	return self;
}

-(void) refreshPicker
{
	datePicker.date = (segmentedStyleControl.selectedSegmentIndex == 0? 
					   [self.settings getWorkingStartTimeOnDay:selectedIndex+1]:
					   [self.settings getWorkingEndTimeOnDay:selectedIndex+1]);			
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
	//UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIView *contentView = [[UIView alloc] initWithFrame:frm];
	//contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    contentView.backgroundColor = [UIColor darkGrayColor];
	
	//doneBarView = [[UIView alloc] initWithFrame:CGRectMake(0, halfHeight - 40, 320, 40)];
    doneBarView = [[UIView alloc] initWithFrame:CGRectMake(0, frm.size.height - [Common getKeyboardHeight] - 40, 320, 40)];
	doneBarView.backgroundColor = [UIColor clearColor];
	
	[contentView addSubview:doneBarView];
	[doneBarView release];	
	
	UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frm.size.width, 40)];
	backgroundView.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	backgroundView.alpha = 0.3;
	
	[doneBarView addSubview:backgroundView];
	[backgroundView release];
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _startText, _endText, nil];
	
	segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(10, 5, 100, 30);
	
	[segmentedStyleControl addTarget:self action:@selector(changeStartEnd:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;	
	segmentedStyleControl.selectedSegmentIndex = 0;
	
	[doneBarView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];		
	
	//datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 200, 0, 0)];
	datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, frm.size.height - [Common getKeyboardHeight], 0, 0)];
	
	[datePicker addTarget:self action:@selector(timeChanged:) forControlEvents:UIControlEventValueChanged];
	datePicker.minuteInterval=5;
	datePicker.datePickerMode=UIDatePickerModeTime;
	[contentView addSubview: datePicker];
	[datePicker release];
		
	tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frm.size.width, frm.size.height - [Common getKeyboardHeight] -doneBarView.frame.size.height) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
	
    [contentView addSubview:tableView];
	[tableView release];	
		
	self.view = contentView;
	[contentView release];
	
	self.navigationItem.title = _workingTimeText;
	
	selectedIndex = 0;
	
	[self refreshPicker];
}

- (void)viewDidAppear:(BOOL)animated 
{
	[tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];	
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:tableView.indexPathForSelectedRow];
	
	UILabel *label = (UILabel *)[cell viewWithTag:10000+selectedIndex];
	label.textColor = [UIColor whiteColor];
	
	BOOL showHint = [[Settings getInstance] workingTimeHint];
	
	if (showHint && !_workingTimeHintShown)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_hintText message:_workingTimeHintText delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
		
		alertView.tag = -12000;
		
		[alertView addButtonWithTitle:_dontShowText];
		
		[alertView show];
		[alertView release];
		
		_workingTimeHintShown = YES;
	}
	
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
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
	[ImageManager free];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


#pragma mark Actions
- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertVw.tag == -12000 && buttonIndex != 0) //not Cancel
	{
		if (buttonIndex == 1) //Don't Show
		{
			[[Settings getInstance] enableWorkingTimeHint:NO];
		}
	}	
}

- (void)changeStartEnd:(id)sender
{
	[self refreshPicker];
}

- (void)done:(id)sender
{
}

-(void)timeChanged:(id)sender
{
	//Settings *settings = [Settings getInstance];
	
	NSString *time = [Common get24TimeString:datePicker.date];
	
	NSString *workingTimeStr = @"";
	
	switch (selectedIndex) 
	{
		case 0:
		{
			if (segmentedStyleControl.selectedSegmentIndex == 0)
			{
				if ([self.settings.sunEndTime compare:time] == NSOrderedAscending)
				{
					time = settings.sunEndTime;
					
					datePicker.date = [self.settings getWorkingEndTimeOnDay:selectedIndex+1];
					
				}
				
				self.settings.sunStartTime = time;
			}
			else
			{
				if ([self.settings.sunStartTime compare:time] == NSOrderedDescending)
				{
					time = self.settings.sunStartTime;
					
					datePicker.date = [self.settings getWorkingStartTimeOnDay:selectedIndex+1];
				}
				
				self.settings.sunEndTime = time;
			}
			
			workingTimeStr = [NSString stringWithFormat:@"%@ ~ %@", 
							  [Common convertWorkingTimeString:self.settings.sunStartTime], 
							  [Common convertWorkingTimeString:self.settings.sunEndTime]];
		}
			break;
		case 1:
		{
			if (segmentedStyleControl.selectedSegmentIndex == 0)
			{
				if ([self.settings.monEndTime compare:time] == NSOrderedAscending)
				{
					time = self.settings.monEndTime;
					
					datePicker.date = [self.settings getWorkingEndTimeOnDay:selectedIndex+1];
					
				}
				
				self.settings.monStartTime = time;
			}
			else
			{
				if ([self.settings.monStartTime compare:time] == NSOrderedDescending)
				{
					time = self.settings.monStartTime;
					
					datePicker.date = [self.settings getWorkingStartTimeOnDay:selectedIndex+1];
				}
				
				self.settings.monEndTime = time;
			}
			
			workingTimeStr = [NSString stringWithFormat:@"%@ ~ %@", 
							  [Common convertWorkingTimeString:self.settings.monStartTime], 
							  [Common convertWorkingTimeString:self.settings.monEndTime]];
			
		}
			break;			
		case 2:
		{
			if (segmentedStyleControl.selectedSegmentIndex == 0)
			{
				if ([self.settings.tueEndTime compare:time] == NSOrderedAscending)
				{
					time = self.settings.tueEndTime;
					
					datePicker.date = [self.settings getWorkingEndTimeOnDay:selectedIndex+1];
					
				}
				
				self.settings.tueStartTime = time;
			}
			else
			{
				if ([self.settings.tueStartTime compare:time] == NSOrderedDescending)
				{
					time = self.settings.tueStartTime;
					
					datePicker.date = [self.settings getWorkingStartTimeOnDay:selectedIndex+1];
				}
				
				self.settings.tueEndTime = time;
			}
			
			workingTimeStr = [NSString stringWithFormat:@"%@ ~ %@", 
							  [Common convertWorkingTimeString:self.settings.tueStartTime], 
							  [Common convertWorkingTimeString:self.settings.tueEndTime]];
			
		}
			break;
		case 3:
		{
			if (segmentedStyleControl.selectedSegmentIndex == 0)
			{
				if ([self.settings.wedEndTime compare:time] == NSOrderedAscending)
				{
					time = self.settings.wedEndTime;
					
					datePicker.date = [self.settings getWorkingEndTimeOnDay:selectedIndex+1];
					
				}
				
				self.settings.wedStartTime = time;
			}
			else
			{
				if ([self.settings.wedStartTime compare:time] == NSOrderedDescending)
				{
					time = self.settings.wedStartTime;
					
					datePicker.date = [self.settings getWorkingStartTimeOnDay:selectedIndex+1];
				}
				
				self.settings.wedEndTime = time;
			}
			
			workingTimeStr = [NSString stringWithFormat:@"%@ ~ %@", 
							  [Common convertWorkingTimeString:self.settings.wedStartTime], 
							  [Common convertWorkingTimeString:self.settings.wedEndTime]];
			
		}
			break;			
		case 4:
		{
			if (segmentedStyleControl.selectedSegmentIndex == 0)
			{
				if ([self.settings.thuEndTime compare:time] == NSOrderedAscending)
				{
					time = self.settings.thuEndTime;
					
					datePicker.date = [self.settings getWorkingEndTimeOnDay:selectedIndex+1];
					
				}
				
				self.settings.thuStartTime = time;
			}
			else
			{
				if ([self.settings.thuStartTime compare:time] == NSOrderedDescending)
				{
					time = self.settings.thuStartTime;
					
					datePicker.date = [self.settings getWorkingStartTimeOnDay:selectedIndex+1];
				}
				
				self.settings.thuEndTime = time;
			}
		
			workingTimeStr = [NSString stringWithFormat:@"%@ ~ %@", 
							  [Common convertWorkingTimeString:self.settings.thuStartTime], 
							  [Common convertWorkingTimeString:self.settings.thuEndTime]];
		}
			break;			
		case 5:
		{
			if (segmentedStyleControl.selectedSegmentIndex == 0)
			{
				if ([self.settings.friEndTime compare:time] == NSOrderedAscending)
				{
					time = self.settings.friEndTime;
					
					datePicker.date = [self.settings getWorkingEndTimeOnDay:selectedIndex+1];
					
				}
				
				self.settings.friStartTime = time;
			}
			else
			{
				if ([self.settings.friStartTime compare:time] == NSOrderedDescending)
				{
					time = self.settings.friStartTime;
					
					datePicker.date = [self.settings getWorkingStartTimeOnDay:selectedIndex+1];
				}
				
				self.settings.friEndTime = time;
			}
			
			workingTimeStr = [NSString stringWithFormat:@"%@ ~ %@", 
							  [Common convertWorkingTimeString:self.settings.friStartTime], 
							  [Common convertWorkingTimeString:self.settings.friEndTime]];

		}
			break;			
		case 6:
		{
			if (segmentedStyleControl.selectedSegmentIndex == 0)
			{
				if ([self.settings.satEndTime compare:time] == NSOrderedAscending)
				{
					time = self.settings.satEndTime;
					
					datePicker.date = [self.settings getWorkingEndTimeOnDay:selectedIndex+1];
					
				}
				
				self.settings.satStartTime = time;
			}
			else
			{
				if ([self.settings.friStartTime compare:time] == NSOrderedDescending)
				{
					time = self.settings.friStartTime;
					
					datePicker.date = [self.settings getWorkingStartTimeOnDay:selectedIndex+1];
				}
				
				self.settings.satEndTime = time;
			}
			
			workingTimeStr = [NSString stringWithFormat:@"%@ ~ %@", 
							  [Common convertWorkingTimeString:self.settings.satStartTime], 
							  [Common convertWorkingTimeString:self.settings.satEndTime]];	
		}
			break;			
	}	
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]];
	
	UILabel *label = (UILabel *)[cell viewWithTag:10000+selectedIndex];
	
	label.text = workingTimeStr;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableViewParam cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"WorkingTimeCell";
    
    UITableViewCell *cell = [tableViewParam dequeueReusableCellWithIdentifier:CellIdentifier];
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
	
	NSString *wkStrings[7] = {@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday"}; 
	
	cell.textLabel.text = wkStrings[indexPath.row]; 
	
	UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(60, 10, 205, 20)];
	label.tag = 10000 + indexPath.row;
	label.textAlignment=NSTextAlignmentRight;
	label.backgroundColor=[UIColor clearColor];
	label.font=[UIFont systemFontOfSize:15];
	label.textColor= [Colors darkSteelBlue];
	
	NSString *wkStartTime[7] = {self.settings.sunStartTime, self.settings.monStartTime, self.settings.tueStartTime, self.settings.wedStartTime,
		self.settings.thuStartTime, self.settings.friStartTime, self.settings.satStartTime};	
	
	NSString *wkEndTime[7] = {self.settings.sunEndTime, self.settings.monEndTime, self.settings.tueEndTime, self.settings.wedEndTime,
		self.settings.thuEndTime, self.settings.friEndTime, self.settings.satEndTime};
	
	
	NSString *workingTimeStr = [NSString stringWithFormat:@"%@ ~ %@", 
								[Common convertWorkingTimeString:wkStartTime[indexPath.row]], 
								[Common convertWorkingTimeString:wkEndTime[indexPath.row]]];
	
	label.text = workingTimeStr; 
	
	[cell.contentView addSubview:label];
	[label release];
	
    return cell;
}


- (void)tableView:(UITableView *)tableViewParam didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	UITableViewCell *cell = [tableViewParam cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]];
	
	UILabel *label = (UILabel *)[cell viewWithTag:10000+selectedIndex];
	label.textColor = [Colors darkSteelBlue];	
	
	selectedIndex = indexPath.row;
		
	cell = [tableViewParam cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]];
	label = (UILabel *)[cell viewWithTag:10000+selectedIndex];
	label.textColor = [UIColor whiteColor];		
	
	[self refreshPicker];
}


@end
