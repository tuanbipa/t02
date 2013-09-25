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

#import "iPadTaskSettingViewController.h"

//extern BOOL _isiPad;

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
	
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    //UIViewController *ctrler = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    
    //if ([ctrler isKindOfClass:[iPadTaskSettingViewController class]])
    if (_isiPad)
    {
        frm.size.width = 2*frm.size.width/3;
    }
    else
    {
        frm.size.width = 320;
    }
    
	//UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    UIView *mainView = [[UIView alloc] initWithFrame:frm];
    
	//mainView.backgroundColor = [UIColor colorWithRed:219.0/255 green:222.0/255 blue:227.0/255 alpha:1];
    
    mainView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    
    self.view = mainView;
	[mainView release];
    
    //CGFloat yMargin = (_isiPad?20:0);
    CGFloat yMargin = 0;
    
    UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, yMargin+30, frm.size.width - 20, 150)];
    hintLabel.backgroundColor = [UIColor clearColor];
    hintLabel.font = [UIFont systemFontOfSize:15];
    hintLabel.numberOfLines = 0;
    hintLabel.textColor = [UIColor grayColor];

    hintLabel.text = _mustDoHint;
    
    if (self.keyEdit==SETTING_EDIT_MUSTDO_DAYS)
    {
        [mainView addSubview:hintLabel];
    }
    
    [hintLabel release];
	
	numTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, yMargin+10, frm.size.width - 20, 35)];
	numTextField.backgroundColor = [UIColor whiteColor];
    numTextField.textAlignment = NSTextAlignmentRight;
	numTextField.keyboardType = UIKeyboardTypeNumberPad;
    numTextField.returnKeyType = UIReturnKeyDone;
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
    [numTextField resignFirstResponder];
    
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSInteger number = [textField.text isEqualToString:@""]?0:[textField.text intValue];
    
    if (self.keyEdit == SETTING_EDIT_MUSTDO_DAYS)
    {
        Settings *settings = (Settings *) self.objectEdit;
        
        settings.mustDoDays = number;
    }
}


- (void)dealloc {
    [super dealloc];
}


@end
