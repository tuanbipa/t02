//
//  GuideWebView.m
//  SmartTime
//
//  Created by Huy Le on 7/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GuideWebView.h"

#import "Common.h"

@implementation GuideWebView

@synthesize content;

@synthesize safariEnabled;
@synthesize isLoaded;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.delegate = self;
		
		self.backgroundColor = [Colors darkSlateGray];
		self.opaque = NO;
		
		self.safariEnabled = NO;
		self.isLoaded = NO;
		
		self.content = nil;
		
    }
    return self;
}

- (void)loadURL:(NSString *)url fileName:(NSString *)fileName extension:(NSString *)fileExt
{
	NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExt]; 
	NSError *error;
	
	self.content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error]; 
	
	[self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)loadURL:(NSString *)url content:(NSString *)contentParam
{
	self.content = contentParam;
	
	[self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}


- (void)loadHTMLFile:(NSString *)fileName extension:(NSString *)fileExt
{
	NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExt]; 
	NSURL     *bundleUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
	
	NSError *error;
	
	self.content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error]; 
	
	if (self.content) {
		[self loadHTMLString:self.content baseURL:bundleUrl];
	}
}

- (void)loadHTMLContent:(NSString *)html
{
	self.content = html;
	
	NSURL     *bundleUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
	
	if (self.content) 
	{
		[self loadHTMLString:self.content baseURL:bundleUrl];
	}	
}

- (void)webViewDidStartLoad:(UIWebView*)web {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void) webViewDidFinishLoad:(UIWebView*)web {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	self.isLoaded = YES;
}

- (void) webView:(UIWebView*)web didFailLoadWithError:(NSError *)error {
	
	//////printf("error: %d, %s\n", [error code], [[error description] UTF8String]);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	BOOL wifiOff = (error != nil && [error code] == -1009);
	
	BOOL urlCantShown = (error != nil && [error code] == 101);
	
	if (wifiOff || urlCantShown)
	{
		if (self.content != nil)
		{
			[self loadHTMLString:self.content baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
		}
		else if (wifiOff)
		{
			[self stopLoading];
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_errorText message:[error localizedDescription] delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
			
			[alertView show];
			[alertView release];
		}		
	}
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	//NSString *url = [[request URL] relativeString];
	
	//////printf("should Start safari enabled:%s - url:%s\n", (self.safariEnabled?"YES":"NO"), [url UTF8String]);
	
	if (self.safariEnabled && self.isLoaded)
	{
		//[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		
		NSString *url = [[request URL] relativeString];
		
		if (![url isEqualToString:@"about:blank"])
		{
            self.isLoaded = NO;
            
			[[UIApplication sharedApplication] openURL:[request URL]];
            
            return NO;
		}

	}
	
	return YES;
}

- (void)dealloc
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	self.content = nil;
	
    [super dealloc];
}


@end
