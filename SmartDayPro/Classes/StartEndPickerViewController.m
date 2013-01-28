//
//  StartEndPickerViewController.m
//  SmartPlan
//
//  Created by Huy Le on 12/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StartEndPickerViewController.h"

#import "Common.h"
#import "Colors.h"
#import "Task.h"

#import "DBManager.h"
#import "ImageManager.h"

@implementation StartEndPickerViewController

@synthesize minStartTime;
@synthesize objectEdit;
@synthesize objectCopy;

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
		saveButton = nil;
        
        self.contentSizeForViewInPopover = CGSizeMake(320,416);
	}
	
	return self;
}

-(void) refreshPicker
{
	switch (selectedIndex) 
	{
		case 0:
			datePicker.date = [self.objectCopy startTime];			
			break;
		case 1:
			datePicker.date = [self.objectCopy endTime];			
			break;			
	}	
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	self.objectCopy = self.objectEdit;
    
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    frm.size.width = 320;
	
	UIView *contentView = [[UIView alloc] initWithFrame:frm];
	contentView.backgroundColor = [UIColor colorWithRed:161.0/255 green:162.0/255 blue:169.0/255 alpha:1];
	
	datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 100, 0, 0)];
	[datePicker addTarget:self action:@selector(timeChanged:) forControlEvents:UIControlEventValueChanged];
	datePicker.minuteInterval=5;
	BOOL isADE = [self.objectCopy isKindOfClass:[Task class]] && [(Task *)self.objectCopy isADE];
	
	datePicker.datePickerMode = (isADE? UIDatePickerModeDate: UIDatePickerModeDateAndTime);
	NSDate *startTime = [self.objectEdit startTime];
	
	datePicker.date = (startTime == nil?[NSDate date]:startTime);
	
	[contentView addSubview: datePicker];
	[datePicker release];
	
	pickerTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 100) style:UITableViewStyleGrouped];
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
	
	if(![self.objectCopy isKindOfClass:[Task class]])
	{
		saveButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
																  target:self action:@selector(save:)];
		saveButton.enabled = NO;
		
		self.navigationItem.rightBarButtonItem = saveButton;	
		self.navigationItem.title = _progressEditTitle;
		
		[saveButton release];
	}
	
	
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

- (void)dealloc {
	self.minStartTime = nil;
	
	self.objectCopy = nil;
	
    [super dealloc];
}

#pragma mark Actions
- (void)timeChanged:(id)sender
{
	UIDatePicker *picker = (UIDatePicker *) sender;
	
	if ([picker.date compare:self.minStartTime] == NSOrderedAscending)
	{
		picker.date = self.minStartTime;		
	}
	
	if (selectedIndex == 0)
	{
		if ([self.objectCopy isKindOfClass:[Task class]] && [self.objectCopy type] == TYPE_ADE)
		{
			[self.objectCopy setStartTime:[Common clearTimeForDate:picker.date]];
		}
		else 
		{
			[self.objectCopy setStartTime:picker.date];			
		}
	}
	else
	{
		if ([self.objectCopy isKindOfClass:[Task class]] && [self.objectCopy type] == TYPE_ADE)
		{
			//[self.objectCopy setEndTime:[Common dateByAddNumSecond:-1 toDate:[Common getEndDate:picker.date]]];
            [self.objectCopy setEndTime:[Common getEndDate:picker.date]];
		}
		else 
		{			
			[self.objectCopy setEndTime:picker.date];
		}
	}
	
	if ([[self.objectCopy endTime] compare:[self.objectCopy startTime]] != NSOrderedDescending)
	{
		if (selectedIndex == 1)
		{
			if ([self.objectCopy isKindOfClass:[Task class]] && [self.objectCopy type] == TYPE_ADE)
			{
				[self.objectCopy setStartTime:[Common clearTimeForDate:[self.objectCopy endTime]]];
			}
			else 
			{				
				[self.objectCopy setStartTime:[Common dateByAddNumSecond:-3600 toDate:[self.objectCopy endTime]]];
			}
		}
		else
		{
			if ([self.objectCopy isKindOfClass:[Task class]] && [self.objectCopy type] == TYPE_ADE)
			{
				//[self.objectCopy setEndTime:[Common dateByAddNumSecond:-1 toDate:[Common getEndDate:[self.objectCopy startTime]]]];
                [self.objectCopy setEndTime:[Common getEndDate:[self.objectCopy startTime]]];
			}
			else 
			{								
				[self.objectCopy setEndTime:[Common dateByAddNumSecond:3600 toDate:[self.objectCopy startTime]]];
			}
		}
	}

	if (saveButton != nil)
	{
		saveButton.enabled = YES;
	}
	else 
	{
		[self.objectEdit setStartTime:[self.objectCopy startTime]];
		[self.objectEdit setEndTime:[self.objectCopy endTime]];		
	}
	
	NSString *startTime = [self.objectCopy isADE]?[Common getFullDateString3:[self.objectCopy startTime]]
	:[Common getFullDateTimeString:[self.objectCopy startTime]];
	
	NSString *endTime = [self.objectCopy isADE]?[Common getFullDateString3:[self.objectCopy endTime]]
	:[Common getFullDateTimeString:[self.objectCopy endTime]];
	
	UITableViewCell *cell = [pickerTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	
	UILabel *label = (UILabel *)[cell viewWithTag:10000];
	label.text = startTime;
	
	cell = [pickerTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
	label = (UILabel *)[cell viewWithTag:10001];
	label.text = endTime;
}

- (void)save:(id)sender
{
	[self.objectEdit setStartTime:[self.objectCopy startTime]];
	[self.objectEdit setEndTime:[self.objectCopy endTime]];
	
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
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
	
    // Set up the cell...
	
	//cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	NSString *titles[2] = {_startText, _endText};
	
	cell.textLabel.text = titles[indexPath.row]; 
	
	UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(60, 10, 205, 20)];
	label.tag = 10000 + indexPath.row;
	label.textAlignment=NSTextAlignmentRight;
	label.backgroundColor=[UIColor clearColor];
	label.font=[UIFont systemFontOfSize:15];
	label.textColor= [Colors darkSteelBlue];
	
	NSString *startTime = [self.objectCopy isADE]?[Common getFullDateString3:[self.objectCopy startTime]]
	:[Common getFullDateTimeString:[self.objectCopy startTime]];

	NSString *endTime = [self.objectCopy isADE]?[Common getFullDateString3:[self.objectCopy endTime]]
	:[Common getFullDateTimeString:[self.objectCopy endTime]];
	
	label.text = (indexPath.row == 0?startTime:endTime);
	
	[cell.contentView addSubview:label];
	[label release];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]];
	
	UILabel *label = (UILabel *)[cell viewWithTag:10000+selectedIndex];
	label.textColor = [Colors darkSteelBlue];		
	
	selectedIndex = indexPath.row;
	
	cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]];
	label = (UILabel *)[cell viewWithTag:10000+selectedIndex];
	label.textColor = [UIColor whiteColor];	
	
	[self refreshPicker];
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
