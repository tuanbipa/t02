    //
//  iPadAboutUsViewController.m
//  SmartPlan
//
//  Created by MacBook Pro on 1/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "iPadAboutUsViewController.h"

#import "Common.h"

#import "GuideWebView.h"

extern BOOL _spLiteVersion;

extern BOOL _isiPad;

@implementation iPadAboutUsViewController

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
- (void)loadView 
{
	GuideWebView *webView = [[GuideWebView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024 - 20 - 44)];
	webView.safariEnabled = YES;
	
	self.view = webView;
	
	[webView release];
	
	aboutSegment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:_aboutUsTitle, _smartAppsText, _userGuideText , nil]];
	aboutSegment.segmentedControlStyle= UISegmentedControlStyleBar;
	
	[aboutSegment addTarget:self action:@selector(selectOption:) forControlEvents:UIControlEventValueChanged];
	
	aboutSegment.frame = CGRectMake((768-400)/2, 5, 400, 30);
	
	aboutSegment.selectedSegmentIndex = 2;
    
    [self selectOption:aboutSegment];
		
	self.navigationItem.titleView = aboutSegment;
	
	[aboutSegment release];
}

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	//[self.navigationController.navigationBar resetBackground];
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
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (void) aboutUs
{
	GuideWebView *webView = self.view;
	
	webView.safariEnabled = YES;
	
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"SC_aboutUS_768" ofType:@"html"];  
	
	NSString *html = [NSString stringWithContentsOfFile:filePath]; 
	
	if (html) {
		NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        //NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
		if (version == nil || [version isEqualToString:@""])
		{
			version = @"unknown";
		}
		
		NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        //NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
		if (build == nil || [build isEqualToString:@""])
		{
			build = @"unknown";
		}
		
		NSString *info = [NSString stringWithFormat:@"Version %@", version];
		
		html = [html stringByReplacingOccurrencesOfString:@"_SP_VERSION" withString:info];
		
		[webView loadHTMLContent:html];
	}	
	
}

- (void) byLCL 
{
	GuideWebView *webView = self.view;
	
	webView.safariEnabled = YES;
		
	[webView loadHTMLFile:@"LCL_Products_Page_768" extension:@"html"];	
}

- (void) guide
{
	////printf("HELP \n");
	
	GuideWebView *webView = self.view;
	
	webView.safariEnabled = NO;

	//[webView loadHTMLFile:@"ipad_index" extension:@"html"];
    
    [webView loadURL:URL_HELP content:nil];
}

- (void) selectOption: (id) sender
{	
	UISegmentedControl *segmentControl = sender;
	
	switch (segmentControl.selectedSegmentIndex) 
	{
		case 0:
		{
			[self aboutUs];
		}
			break;
		case 1:
		{
			[self byLCL];
		}
			break;
		case 2:
		{
			[self guide];
		}
			break;
	}
}


-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
/*	if(interfaceOrientation==UIInterfaceOrientationPortrait || interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
	{
		self.view.frame=CGRectMake(0, 0, 768, 1024-20-44);
	}
	else
	{
		self.view.frame=CGRectMake(0, 0, 1024, 768-20-44);
	}*/
	
	return NO;
}
/*
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    BOOL portrait = (toInterfaceOrientation==UIInterfaceOrientationPortrait || toInterfaceOrientation==UIInterfaceOrientationPortraitUpsideDown);
    
    [Common setDeviceOrientation:toInterfaceOrientation];
    
	if(portrait)
	{
		self.view.frame=CGRectMake(0, 0, 768, 1024-20-44);
	}
	else
	{
		self.view.frame=CGRectMake(0, 0, 1024, 768-20-44);
	}
    
    [self selectOption:aboutSegment];
}
*/
#pragma mark OS4 Support 
-(void) purge
{
	////printf("About Us purge\n");
}

-(void) recover
{
	////printf("About Us recover\n");
	
	GuideWebView *webView = [[GuideWebView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024 - 20 - 44)];
	webView.safariEnabled = YES;
	
	self.view = webView;
	
	[webView release];
	
	[self selectOption:aboutSegment];
}

@end
