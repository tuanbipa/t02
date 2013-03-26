//
//  DatePickerViewController.m
//  SmartPlan
//
//  Created by Huy Le on 11/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DatePickerViewController.h"
#import "Common.h"
#import "Settings.h"
#import "Project.h"
#import "Task.h"
#import "ImageManager.h"

#import "GuideWebView.h"

#import "NoteDetailTableViewController.h"

@implementation DatePickerViewController

@synthesize objectEdit;
@synthesize keyEdit;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

- (id) init
{
    if (self = [super init])
    {
        self.contentSizeForViewInPopover = CGSizeMake(320,416);
    }
    
    return self;
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
	//UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    UIView *mainView = [[UIView alloc] initWithFrame:frm];
	mainView.backgroundColor = [UIColor colorWithRed:161.0/255 green:162.0/255 blue:169.0/255 alpha:1];
	
	UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 110, 0, 0)];
	[picker addTarget:self action:@selector(timeChanged:) forControlEvents:UIControlEventValueChanged];
	picker.minuteInterval=5;
	[mainView addSubview: picker];
	[picker release];
	
	UIButton *clearButton = nil;
	UISegmentedControl *segmentedStyleControl = nil;
	
	if ([objectEdit isKindOfClass:[Project class]])
	{
		NSArray *segmentTextContent = [NSArray arrayWithObjects: _pinText, _unPinText, nil];
		segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
		segmentedStyleControl.frame = CGRectMake(10, 10, 300, 30);
		[segmentedStyleControl addTarget:self action:@selector(pinAction:) forControlEvents:UIControlEventValueChanged];
		segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;	
		segmentedStyleControl.selectedSegmentIndex = (((Project *)self.objectEdit).isPinnedDeadline?0:1);
		segmentedStyleControl.hidden = YES;
		
		[mainView addSubview:segmentedStyleControl];
		[segmentedStyleControl release];		
	}
	else if ([objectEdit isKindOfClass:[Task class]])
	{
        Task *task = (Task *) objectEdit;
        
        if (task.type != TYPE_NOTE)
        {
            clearButton = [Common createButton:_noneText 
                                    buttonType:UIButtonTypeCustom
                                         frame:CGRectMake(130, 20, 60, 30) 
                                    titleColor:[UIColor whiteColor] 
                                        target:self 
                                      selector:@selector(clear:) 
                              normalStateImage:@"gray_button.png"
                            selectedStateImage:@"blue_button.png"];
            clearButton.hidden = YES;
            clearButton.tag = 10000;
            
            clearButton.selected = (self.keyEdit == TASK_EDIT_DEADLINE && task.deadline == nil) || (self.keyEdit == TASK_EDIT_START && task.startTime == nil);
            
            [mainView addSubview:clearButton];            
        }
	}
	
	//if (self.project != nil)
	if (self.objectEdit != nil)
	{
		switch (self.keyEdit)
		{
			case PROJECT_EDIT_START:
			{
				//picker.date = self.project.startTime;
				picker.date = ((Project *)self.objectEdit).startTime;
				
				self.navigationItem.title = _startText;
				
				GuideWebView *hint = [[GuideWebView alloc] initWithFrame:CGRectMake(10, 416 - 90, 300, 90)];
				
				[hint loadHTMLFile:@"StartHint" extension:@"htm"];
				
				[mainView addSubview:hint];
				
				[hint release];			
				
			}
				break;
			case PROJECT_EDIT_DEADLINE:
			{
				Project *project = (Project *) self.objectEdit;
				//picker.date = self.project.revisedDeadline;
				picker.date = project.revisedDeadline;
				
				self.navigationItem.title = _deadlineText;
				
				segmentedStyleControl.hidden = NO;
				
				GuideWebView *hint = [[GuideWebView alloc] initWithFrame:CGRectMake(10, 416 - 90, 300, 90)];
				
				[hint loadHTMLFile:@"DeadlineHint" extension:@"htm"];
				
				[mainView addSubview:hint];
				
				[hint release];	
				
				pinHint = [[GuideWebView alloc] initWithFrame:CGRectMake(10, 40, 300, 80)];
				
				if (project.isPinnedDeadline)
				{
					[pinHint loadHTMLFile:@"PinHint" extension:@"htm"];
				}
				else
				{
					[pinHint loadHTMLFile:@"UnPinHint" extension:@"htm"];
				}
				
				[mainView addSubview:pinHint];
				
				[pinHint release];				
				
			}
				break;
			case TASK_EDIT_DEADLINE:
			{
				Task *task = (Task *) self.objectEdit;
				
				/*picker.date = (task.deadline != nil? task.deadline:
							   (task.startTime != nil? task.startTime: [[Settings getInstance] getWorkingEndTimeForDate:[NSDate date]]));*/
                
                picker.date = (task.deadline != nil? task.deadline: [NSDate date]);
                picker.datePickerMode = UIDatePickerModeDate;
				
				self.navigationItem.title = _deadlineText;
				
				clearButton.hidden = NO;
				
			}
				break;
			case TASK_EDIT_START:
			{
				Task *task = (Task *) self.objectEdit;
				
				picker.date = (task.startTime != nil? task.startTime: [NSDate date]);
                picker.datePickerMode = [task isNote]?UIDatePickerModeDateAndTime:UIDatePickerModeDate;
                
				self.navigationItem.title = _startText;
				
				clearButton.hidden = NO;				
			}
				break;
		}		
	}
	
	self.view = mainView;
	[mainView release];	
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

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.navigationController.topViewController isKindOfClass:[NoteDetailTableViewController class]])
    {
        NoteDetailTableViewController *ctrler = (NoteDetailTableViewController *) self.navigationController.topViewController;
        
        [ctrler refreshStart];
    }
}

-(void)pinAction:(id)sender
{
	UISegmentedControl *ctrl = (UISegmentedControl *) sender;
	
	Project *project = (Project *) objectEdit;
	
	project.isPinnedDeadline = (ctrl.selectedSegmentIndex == 0? YES: NO);
	
	if (project.isPinnedDeadline)
	{
		[pinHint loadHTMLFile:@"PinHint" extension:@"htm"];		
	}
	else
	{
		[pinHint loadHTMLFile:@"UnPinHint" extension:@"htm"];
	}
}

- (void)timeChanged:(id)sender
{
    Settings *settings = [Settings getInstance];
    
	UIDatePicker *picker = (UIDatePicker *)sender;
	switch (keyEdit)
	{
		case PROJECT_EDIT_START:
		{
			Project *project = (Project *) objectEdit;
			project.startTime = picker.date;				
		}
			break;
		case PROJECT_EDIT_DEADLINE:
		{
			Project *project = (Project *) objectEdit;
			project.revisedDeadline = picker.date;
		}
			break;
		case TASK_EDIT_DEADLINE:
		{
			Task *task = (Task *) objectEdit;
            
            NSInteger diff = 0;
            
            if (task.startTime != nil)
            {
                diff = [task.deadline timeIntervalSinceDate:task.startTime];
            }
            
			task.deadline = [settings getWorkingEndTimeForDate:picker.date];
            
            /*
            if (task.startTime != nil && [task.deadline compare:task.startTime] == NSOrderedAscending)
            {
                task.startTime = [settings getWorkingStartTimeForDate:task.deadline];
            }*/
            
            if (diff > 0)
            {
                NSDate *dt = [NSDate dateWithTimeInterval:-diff sinceDate:task.deadline];
                
                task.startTime = [settings getWorkingStartTimeForDate:dt];
            }
		}
			break;			
		case TASK_EDIT_START:
		{
			Task *task = (Task *) objectEdit;
            
            if ([task isNote])
            {
                task.startTime = picker.date;
            }
            else
            {
                task.startTime = [settings getWorkingStartTimeForDate: picker.date];
                
                if (task.deadline != nil && [task.deadline compare:task.startTime] == NSOrderedAscending)
                {
                    task.deadline = [settings getWorkingEndTimeForDate:task.startTime];
                }                
            }
		}
			break;			
	}
    
    UIButton *clearButton = [self.view viewWithTag:10000];
    
    if (clearButton != nil)
    {
        clearButton.selected = NO;
    }
}

-(void)clear:(id)sender
{
    UIButton *button = (UIButton *) sender;
    
	Task *task = (Task *) objectEdit;
	
	switch (keyEdit)
	{
		case TASK_EDIT_DEADLINE:
		{
			task.deadline = nil;
			
			//if (task.type == TYPE_TASK)
            if ([task isTask])
			{
				task.alerts = [NSMutableArray arrayWithCapacity:0];
			}
		}
			break;			
		case TASK_EDIT_START:
		{
			task.startTime = nil;
		}
			break;
	}
    
    button.selected = YES;
}

- (void)dealloc {
    [super dealloc];
}


@end
