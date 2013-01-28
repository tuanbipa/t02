    //
//  CategoryNoteViewController.m
//  SmartCal
//
//  Created by MacBook Pro on 5/23/11.
//  Copyright 2011 LCL. All rights reserved.
//

#import "CategoryNoteViewController.h"

#import "Common.h"
#import "GuideWebView.h"

#import "ImageManager.h"

@implementation CategoryNoteViewController

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


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	//GuideWebView *webView = [[GuideWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 416-20)];
	GuideWebView *webView = [[GuideWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
	webView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	[webView loadHTMLFile:@"CategoryHint" extension:@"htm"];
	
	UIButton *closeButton =[Common createButton:_closeText
									  buttonType:UIButtonTypeCustom 
										   frame:CGRectMake(110, 460 - 40, 100, 30) 
									  titleColor:nil 
										  target:self 
										selector:@selector(close:) 
								normalStateImage:@"blue_button.png"
							  selectedStateImage:nil];
	[closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	
	[webView addSubview:closeButton];
	
	self.view = webView;
	
	self.navigationItem.title = _projectsText;
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

- (void) close:(id)sender
{
	//[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)dealloc {
    [super dealloc];
}


@end
