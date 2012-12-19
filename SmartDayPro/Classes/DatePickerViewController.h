//
//  DatePickerViewController.h
//  SmartPlan
//
//  Created by Huy Le on 11/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Project;
@class GuideWebView;

@interface DatePickerViewController : UIViewController {
	NSObject *objectEdit;
	
	NSInteger keyEdit;
	
	GuideWebView *pinHint;
}

@property (nonatomic, assign) 	NSObject *objectEdit;
@property 	NSInteger keyEdit;

@end
