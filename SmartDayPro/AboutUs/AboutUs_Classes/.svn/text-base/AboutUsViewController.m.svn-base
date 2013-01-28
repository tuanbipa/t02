//
//  AboutUsViewController.m
//  SmartPlan
//
//  Created by Huy Le on 1/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AboutUsViewController.h"

#import "Common.h"
#import "ImageManager.h"

#import "GuideWebView.h"

#import "ByLCLViewController.h"
#import "MiniProductPageViewController.h"

//#import "SCTabBarController.h"
//extern SCTabBarController *_tabBarCtrler;

extern BOOL _scFreeVersion;

@implementation AboutUsViewController

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
	
	self.navigationItem.title = _aboutUsTitle;
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

	GuideWebView *webView = (GuideWebView *)self.view;
	
	//webView.safariEnabled = NO;
    
    CGSize sz = [Common getScreenSize];
    
    BOOL isiP5 = (sz.height + 20 + 44 == 568);
	
	NSString *filePath = [[NSBundle mainBundle] pathForResource:isiP5?@"SC_aboutUS_320_ip5":@"SC_aboutUS_320" ofType:@"html"];

	NSError *error;
	
	NSString *html = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error]; 
	
	if (html) {
		NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
		if (build == nil || [build isEqualToString:@""])
		{
			build = @"unknown";
		}
		
		NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
		if (version == nil || [version isEqualToString:@""])
		{
			version = @"unknown";
		}
		
		/*
		NSString *info = [NSString stringWithFormat:@"Version %@ build %@", version, build];
		NSString *title = (_scFreeVersion?@"SmartPlans Lite":@"SmartPlans");
		NSString *icon = (_scFreeVersion?@"SmartPlanLite.png":@"SmartPlan.png");
		*/
		
		NSString *name = (_scFreeVersion?@"SmartDay Free":@"SmartDay");
		NSString *icon = (_scFreeVersion?@"SC_free_205.png":@"SD_205.png");
		
		html = [html stringByReplacingOccurrencesOfString:@"_SC_VERSION" withString:version];
		html = [html stringByReplacingOccurrencesOfString:@"_SC_BUILD_NUMBER" withString:build];
		html = [html stringByReplacingOccurrencesOfString:@"_SC_NAME" withString:name];
		html = [html stringByReplacingOccurrencesOfString:@"_SC_ICON" withString:icon];
		
		[webView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
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
	[ImageManager free];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

-(void)byLCL:(id)sender
{
	ByLCLViewController *ctrler = [[ByLCLViewController alloc] init];
	//MiniProductPageViewController *ctrler = [[MiniProductPageViewController alloc] init];

	[self.navigationController pushViewController:ctrler animated:NO];
	[ctrler release];	
}

- (void)dealloc {
    [super dealloc];
}


@end
