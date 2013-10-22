//
//  iPadAboutUsViewController.h
//  SmartPlan
//
//  Created by MacBook Pro on 1/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GuideWebView;

@interface iPadAboutUsViewController : UIViewController {
	UISegmentedControl *aboutSegment;
    GuideWebView *webView;
}

@end
