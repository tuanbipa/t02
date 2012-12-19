//
//  HelpViewController.m
//  SmartPlan
//
//  Created by Huy Le on 1/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HelpViewController.h"

#import "Common.h"
#import "ImageManager.h"

#import "GuideWebView.h"

#import "AboutUsViewController.h"

//#import "SCTabBarController.h"
//extern SCTabBarController *_tabBarCtrler;

@implementation HelpViewController

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
- (void)loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];

    GuideWebView *webView = [[GuideWebView alloc] initWithFrame:frm];
	
	self.view = webView;

	[webView release];
	
	self.navigationItem.title = _userGuideText;	
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//[(GuideWebView *)self.view loadURL:URL_HELP fileName:@"SC_Local_guide_320" extension:@"html"];	
	[(GuideWebView *)self.view loadURL:URL_HELP content:nil];	
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

-(void)aboutUs:(id)sender
{
	AboutUsViewController *ctrler = [[AboutUsViewController alloc] init];

	[self.navigationController pushViewController:ctrler animated:NO];
	[ctrler release];	
}

- (void)dealloc {
    [super dealloc];
}


@end
