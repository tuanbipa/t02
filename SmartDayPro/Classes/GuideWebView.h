//
//  GuideWebView.h
//  SmartTime
//
//  Created by Huy Le on 7/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GuideWebView : UIWebView<UIWebViewDelegate> {
	NSString *content;
	
	BOOL safariEnabled;
	BOOL isLoaded;
}

@property (nonatomic, copy) NSString *content;

@property BOOL safariEnabled;
@property BOOL isLoaded;

- (void)loadURL:(NSString *)url fileName:(NSString *)fileName extension:(NSString *)fileExt;
- (void)loadURL:(NSString *)url content:(NSString *)content;
- (void)loadHTMLContent:(NSString *)html;
- (void)loadHTMLFile:(NSString *)fileName extension:(NSString *)fileExt;

@end
