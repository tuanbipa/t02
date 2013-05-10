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
        self.contentSizeForViewInPopover = CGSizeMake(320,416);
    }
    
    return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    frm.size.width = 320;
    
	//UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    UIView *contentView = [[UIView alloc] initWithFrame:frm];
	contentView.backgroundColor=[UIColor darkGrayColor];
    
	self.view = contentView;
	[contentView release];    
	
	//editTextView=[[UITextView alloc] initWithFrame:CGRectMake(10, 20, frm.size.width - 20, 140)];
    editTextView=[[UITextView alloc] initWithFrame:CGRectMake(10, 10, frm.size.width - 20, frm.size.height - [Common getKeyboardHeight] - 40 - 20)];
    
	editTextView.delegate=self;
	//editTextView.backgroundColor=[UIColor clearColor];
	editTextView.keyboardType=UIKeyboardTypeDefault;
	editTextView.font=[UIFont systemFontOfSize:18];
	
	editTextView.text = self.task.note;
	[editTextView becomeFirstResponder];
	
	[contentView addSubview:editTextView];
	[editTextView release];	

    /*
    doneBarView=[[UIView alloc] initWithFrame:CGRectMake(0, frm.size.height - [Common getKeyboardHeight] - 40, frm.size.width, 40)];
	doneBarView.backgroundColor=[UIColor clearColor];
	doneBarView.hidden = YES;
	
	[contentView addSubview:doneBarView];
	[doneBarView release];	
	
	UIView *backgroundView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, frm.size.width, 40)];
	backgroundView.backgroundColor=[UIColor viewFlipsideBackgroundColor];
	backgroundView.alpha=0.3;
	
	[doneBarView addSubview:backgroundView];
	[backgroundView release];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    doneButton.frame = CGRectMake(frm.size.width-70, 5, 60, 30);
	doneButton.alpha=1;
	[doneButton setTitle:_doneText forState:UIControlStateNormal];
	doneButton.titleLabel.font=[UIFont systemFontOfSize:14];
	[doneButton setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];		
	[doneButton setBackgroundImage:[[ImageManager getInstance] getImageWithName:@"blue-small.png"] forState:UIControlStateNormal];
	
	[doneButton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
	
	UIButton *cleanButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	cleanButton.frame = CGRectMake(10, 5, 60, 30);
	cleanButton.alpha=1;
	[cleanButton setTitle:_cleanText forState:UIControlStateNormal];
	cleanButton.titleLabel.font=[UIFont systemFontOfSize:14];
	[cleanButton setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];		
	[cleanButton setBackgroundImage:[[ImageManager getInstance] getImageWithName:@"blue-small.png"] forState:UIControlStateNormal];
	
	[cleanButton addTarget:self action:@selector(clean:) forControlEvents:UIControlEventTouchUpInside];	
	
	[doneBarView addSubview:doneButton];
	[doneBarView addSubview:cleanButton];
	*/
	
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
