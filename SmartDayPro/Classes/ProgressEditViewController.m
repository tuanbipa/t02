//
//  ProgressEditViewController.m
//  SmartPlan
//
//  Created by Huy Le on 12/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ProgressEditViewController.h"

#import "Common.h"
#import "Colors.h"
#import "TaskProgress.h"
#import "Task.h"
#import "Project.h"
#import "ProjectManager.h"
#import "ImageManager.h"

#import "DBManager.h"

@implementation ProgressEditViewController

@synthesize minStartTime;
@synthesize progress;
@synthesize progressCopy;
@synthesize only1Progress;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	mainView.backgroundColor = [UIColor colorWithRed:161.0/255 green:162.0/255 blue:169.0/255 alpha:1];
	
	UILabel *startLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 40, 30)];
	startLabel.backgroundColor = [UIColor clearColor];
	startLabel.text = _startText;
	[mainView addSubview:startLabel];
	[startLabel release];
	
	startButton = [UIButton buttonWithType:UIButtonTypeCustom];
	startButton.frame = CGRectMake(50, 10, 150, 30);
	startButton.tag = 10000;
	[startButton setTitleColor:[Colors darkSlateBlue] forState:UIControlStateNormal];
	[startButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
	//startButton.backgroundColor = [UIColor yellowColor];
	startButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
	[startButton setTitle:[Common getDateTimeString:self.progress.startTime] forState:UIControlStateNormal];
	[startButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
	
	[mainView addSubview:startButton];	

	UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 40, 30)];
	endLabel.backgroundColor = [UIColor clearColor];
	endLabel.text = _endText;
	[mainView addSubview:endLabel];
	[endLabel release];
	
	endButton = [UIButton buttonWithType:UIButtonTypeCustom];
	endButton.frame = CGRectMake(50, 50, 150, 30);
	endButton.tag = 10001;
	[endButton setTitleColor:[Colors darkSlateBlue] forState:UIControlStateNormal];
	[endButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
	//endButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
	endButton.backgroundColor = [UIColor yellowColor];
	[endButton setTitle:[Common getDateTimeString:self.progress.endTime] forState:UIControlStateNormal];
	[endButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
	
	[mainView addSubview:endButton];
	
	UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 10, 110, 70)];
	hintLabel.numberOfLines = 3;
	hintLabel.backgroundColor = [UIColor clearColor];
	hintLabel.text = _tap2SelectText;
	//hintLabel.font = [UIFont systemFontOfSize:12];
	[mainView addSubview:hintLabel];
	[hintLabel release];
	
	datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 100, 0, 0)];
	[datePicker addTarget:self action:@selector(timeChanged:) forControlEvents:UIControlEventValueChanged];
	datePicker.minuteInterval=5;

	[mainView addSubview: datePicker];
	[datePicker release];

	self.view = mainView;
	[mainView release];
	
	//selectedButton = startButton;
	selectedButton = endButton;
	
	saveButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
															  target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
	
	saveButton.enabled = NO;
	
	self.navigationItem.title = _progressEditTitle;
	
	self.progressCopy = self.progress;
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

- (void)buttonAction:(id)sender
{
	UIButton *button = (UIButton *)sender;
	
	if (selectedButton != button)
	{
		selectedButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
		
		button.backgroundColor = [UIColor yellowColor];
		
		datePicker.date = (button.tag == 10000? self.progressCopy.startTime:self.progressCopy.endTime);
		
		selectedButton = button;
	}
}

- (void)timeChanged:(id)sender
{
	UIDatePicker *picker = (UIDatePicker *) sender;
	
	if ([picker.date compare:self.minStartTime] == NSOrderedAscending)
	{
		picker.date = self.minStartTime;		
	}
	
	if (selectedButton == startButton)
	{
		self.progressCopy.startTime = picker.date;
	}
	else
	{
		self.progressCopy.endTime = picker.date;
	}
	
	if ([self.progressCopy.endTime compare:self.progressCopy.startTime] == NSOrderedAscending)
	{
		if (selectedButton == endButton)
		{
			self.progressCopy.startTime = self.progressCopy.endTime;
		}
		else
		{
			self.progressCopy.endTime = self.progressCopy.startTime;
		}
	}

	[startButton setTitle:[Common getDateTimeString:self.progressCopy.startTime] forState:UIControlStateNormal];	
	[endButton setTitle:[Common getDateTimeString:self.progressCopy.endTime] forState:UIControlStateNormal];	
	
	saveButton.enabled = YES;
}

- (void)save:(id)sender
{
	DBManager *dbm = [DBManager getInstance];
	self.progress.startTime = self.progressCopy.startTime;
	self.progress.endTime = self.progressCopy.endTime;
	
	[self.progress updateIntoDB:[dbm getDatabase]];
	Project *project = [[ProjectManager getInstance] getProjectByKey:self.progress.task.project];	
	
	if (self.only1Progress)
	{
		self.progress.task.startTime = self.progress.startTime;
		self.progress.task.endTime = self.progress.endTime;
		
		[self.progress.task updateTimeIntoDB:[dbm getDatabase]];
	}
	else
	{
		self.progress.task.endTime = self.progress.endTime;
		
		[self.progress.task updateEndTimeIntoDB:[dbm getDatabase]];
	}
	
	[project refreshPlan];
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
	self.minStartTime = nil;
	self.progressCopy = nil;
	
    [super dealloc];
}


@end
