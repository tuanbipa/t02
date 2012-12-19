//
//  FloatInputViewController.m
//  SmartPlan
//
//  Created by Huy Le on 11/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NumberInputViewController.h"

#import "Common.h"
#import "Colors.h"
#import "Project.h"
#import "Settings.h"

#import "SettingTableViewController.h"

@implementation NumberInputViewController

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

- (id)init
{
	if (self = [super init])
	{
		self.contentSizeForViewInPopover = CGSizeMake(320,418);
	}
	
	return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];	
	mainView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	mainView.backgroundColor = [Colors linen];
    
	self.view = mainView;
	[mainView release];	 
    
    UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 300, 150)];
    hintLabel.backgroundColor = [UIColor clearColor];
    hintLabel.font = [UIFont systemFontOfSize:15];
    hintLabel.numberOfLines = 0;

    hintLabel.text = _mustDoHint;
    
    if (self.keyEdit==SETTING_EDIT_MUSTDO_DAYS)
    {
        [mainView addSubview:hintLabel];
    }
    
    [hintLabel release];
	
	numTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 300, 35)];
	numTextField.backgroundColor = [UIColor whiteColor];
    numTextField.textAlignment = NSTextAlignmentRight;
	numTextField.keyboardType = UIKeyboardTypeNumberPad;
	numTextField.delegate = self;
    numTextField.text = [NSString stringWithFormat:@"%d", (self.keyEdit==SETTING_EDIT_MUSTDO_DAYS?[(Settings *)objectEdit mustDoDays]:0)];
	
	[numTextField becomeFirstResponder];
	
	[mainView addSubview:numTextField];
	[numTextField release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
	UIBarButtonItem *doneButtonItem =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
																			   target:self action:@selector(done:)];
	self.navigationItem.rightBarButtonItem = doneButtonItem;
	[doneButtonItem release];	

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if ([self.navigationController.topViewController isKindOfClass:[SettingTableViewController class]])
    {
        SettingTableViewController *ctrler = (SettingTableViewController *) self.navigationController.topViewController;
        
        [ctrler refreshMustDoCell];
    } 
}

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
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)done:(id)sender
{
    NSInteger number = [numTextField.text isEqualToString:@""]?0:[numTextField.text intValue];
    
    if (self.keyEdit == SETTING_EDIT_MUSTDO_DAYS)
    {
        Settings *settings = (Settings *) self.objectEdit;
    
        settings.mustDoDays = number;
    }
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark TextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	unichar c;
	
	if ([string length]>0)
	{
		c = [string characterAtIndex:0];
	}
	else
	{
		return YES;
	}
	
	if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:c])
	{
        if (self.keyEdit == SETTING_EDIT_MUSTDO_DAYS)
        {
            NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
            
            NSInteger num = [str intValue];
            
            return num >=0 && num <=7;
        }

		return YES;
	}
    	
	return NO;
}

- (void)dealloc {
    [super dealloc];
}


@end
