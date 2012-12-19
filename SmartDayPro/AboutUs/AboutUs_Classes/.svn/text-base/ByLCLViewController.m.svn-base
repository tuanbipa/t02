//
//  ByLCLViewController.m
//  SmartPlan
//
//  Created by Huy Le on 1/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ByLCLViewController.h"

#import "Common.h"
#import "ImageManager.h"

#import "GuideWebView.h"

//#import "SCTabBarController.h"
//extern SCTabBarController *_tabBarCtrler;

@implementation ByLCLViewController

@synthesize offline;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

-(id) init
{
	if (self = [super init])
	{
		self.offline = NO;
	}
	
	return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];

    GuideWebView *webView = [[GuideWebView alloc] initWithFrame:frm];
	webView.safariEnabled = YES;
	self.view = webView;
	
	[webView release];
	
	self.navigationItem.title = _byLCLTitle;
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];	
	GuideWebView *webView = (GuideWebView *) self.view;
	
	webView.safariEnabled = YES;	
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	//GuideWebView *webView = (GuideWebView *) self.view;
	
/*	
	if (self.offline)
	{
		[webView loadHTMLFile:@"LCL_Products_Page_320" extension:@"html"];
	}
	else
	{
		[webView loadURL:URL_ALSOLCL fileName:@"LCL_Products_Page" extension:@"html"];
	}
*/	
	[(GuideWebView *)self.view loadURL:URL_ALSOLCL fileName:@"LCL_Products_Page_320" extension:@"html"];		
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
	[ImageManager free];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
