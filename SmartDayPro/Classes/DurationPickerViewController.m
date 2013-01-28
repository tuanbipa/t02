//
//  DurationPickerViewController.m
//  SmartPlan
//
//  Created by Huy Le on 12/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DurationPickerViewController.h"

#import "Common.h"
#import "Task.h"
#import "Settings.h"
#import "ImageManager.h"

#import "TaskDetailTableViewController.h"

@implementation DurationPickerViewController

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

- (void) clear:(id) sender
{
    noneButton.selected = YES;

    if ([objectEdit isKindOfClass:[Task class]]) 
	{
		[(Task *)objectEdit setDuration:0];
        
        picker.countDownDuration = 0;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    frm.size.width = 320;
    
	//UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    UIView *mainView = [[UIView alloc] initWithFrame:frm];
	mainView.backgroundColor = [UIColor colorWithRed:161.0/255 green:162.0/255 blue:169.0/255 alpha:1];
    
    noneButton = [Common createButton:_noneText 
                            buttonType:UIButtonTypeCustom
                                 frame:CGRectMake(130, 20, 60, 30) 
                            titleColor:[UIColor whiteColor] 
                                target:self 
                              selector:@selector(clear:) 
                      normalStateImage:@"gray_button.png"
                    selectedStateImage:@"blue_button.png"];
    
    if ([objectEdit isKindOfClass:[Task class]]) 
	{
        [mainView addSubview:noneButton]; 
    }
	
	picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 100, 0, 0)];
	[picker addTarget:self action:@selector(durationChanged:) forControlEvents:UIControlEventValueChanged];
	picker.minuteInterval=5;
	picker.datePickerMode=UIDatePickerModeCountDownTimer;
	
	NSInteger duration = 0;
	
	if ([objectEdit isKindOfClass:[Task class]]) 
	{
		duration = [(Task *)objectEdit duration];
	}
	else if ([objectEdit isKindOfClass:[Settings class]]) 
	{		
		if (self.keyEdit == SETTING_EDIT_DEFAULT_DURATION)
		{
			duration = [(Settings *)objectEdit taskDuration];
		}
		else if (self.keyEdit == SETTING_EDIT_MIN_SPLIT_SIZE)
		{
			duration = [(Settings *)objectEdit minimumSplitSize];
		}			
	}
    
    if (duration == 0)
    {
        noneButton.selected = YES;
    }
	
	picker.countDownDuration = duration;
	
	[mainView addSubview: picker];
	[picker release];	
	
	self.view = mainView;
	[mainView release];	
	
	self.navigationItem.title = _durationText;

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

- (void)durationChanged:(id)sender
{
	UIDatePicker *picker = (UIDatePicker *) sender;
	
	if ([objectEdit isKindOfClass:[Task class]]) 
	{
		[(Task *)objectEdit setDuration: (picker.countDownDuration < 5*60?5*60:picker.countDownDuration)];
        
        noneButton.selected = NO;
	}
	else if ([objectEdit isKindOfClass:[Settings class]]) 
	{
		if (self.keyEdit == SETTING_EDIT_DEFAULT_DURATION)
		{
			[(Settings *)objectEdit setTaskDuration: picker.countDownDuration];
		}
		else if (self.keyEdit == SETTING_EDIT_MIN_SPLIT_SIZE)
		{
			[(Settings *)objectEdit setMinimumSplitSize: picker.countDownDuration];
		}
	}
}

- (void)dealloc {
    [super dealloc];
}

@end
