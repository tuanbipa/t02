//
//  TaskNoteViewController.m
//  SmartPlan
//
//  Created by Huy Le on 12/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TaskNoteViewController.h"

#import "Common.h"
#import "Task.h"

#import "ImageManager.h"

#import "DetailViewController.h"

//extern BOOL _isiPad;

@implementation TaskNoteViewController

@synthesize task;

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
        self.preferredContentSize = CGSizeMake(320,416);
    }
    
    return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    /*
    frm.size.width = 320;
    
    if (_isiPad)
    {
        frm.size.height = 416;
    }*/

    if (_isiPad)
    {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        {
            frm.size.height = frm.size.width - 20;
        }
        
        frm.size.width = 384;
    }
    else
    {
        frm.size.width = 320;
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        frm.origin.y += 44 + 20;
    }
    
    UIView *contentView = [[UIView alloc] initWithFrame:frm];
	//contentView.backgroundColor = [UIColor colorWithRed:209.0/255 green:212.0/255 blue:217.0/255 alpha:1];
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    
	self.view = contentView;
	[contentView release];
    
//    editTextView=[[UITextView alloc] initWithFrame:CGRectMake(10, 10, frm.size.width - 20, frm.size.height - (_isiPad?0:[Common getKeyboardHeight] + 40) - 20)];
    
    frm = CGRectMake(10, 10, frm.size.width - 20, 160);

    editTextView = [[UITextView alloc] initWithFrame:frm];
    
	editTextView.delegate=self;
	editTextView.keyboardType=UIKeyboardTypeDefault;
	editTextView.font=[UIFont systemFontOfSize:18];
    
    editTextView.editable = ![self.task isShared];
	
	editTextView.text = self.task.note;
	[editTextView becomeFirstResponder];
	
	[contentView addSubview:editTextView];
	[editTextView release];	

	self.navigationItem.title = _descriptionText;
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

- (void)viewDidLoad
{
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)done:(id) sender
{
	//doneBarView.hidden = YES;
	//self.task.note = editTextView.text;
    
    [editTextView resignFirstResponder];
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)clean:(id) sender
{
	editTextView.text = @"";
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.navigationController.topViewController isKindOfClass:[DetailViewController class]])
    {
        DetailViewController *ctrler = (DetailViewController *)self.navigationController.topViewController;
        
        [ctrler refreshDescription];
    }
}


#pragma mark textView delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
	//doneBarView.hidden = NO;
    
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"DescriptionInputAccessoryView"
                                                   owner:self
                                                 options:nil];
    
    editTextView.inputAccessoryView = [views objectAtIndex:0];
    
	return YES;
}

- (void) textViewDidEndEditing:(UITextView *)textView
{
    self.task.note = editTextView.text;
}

/*
- (void)textViewDidEndEditing:(UITextView *)textView{
	self.task.note = editTextView.text;
}
*/
- (void)dealloc {
    [super dealloc];
}


@end
