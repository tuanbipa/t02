//
//  AlertListViewController.h
//  SmartCal
//
//  Created by MacBook Pro on 8/2/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;
//@class GuideWebView;

@interface AlertListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	UITableView *alertTableView;
	//GuideWebView *hintView;
    UILabel *hintView;
	
	Task *taskEdit;
	
	//NSDictionary *alertDict;
    UIView *alertBasedLocationView;
    UILabel *alertBasedLocationLable;
    UISegmentedControl *alertBasedLocationSegmented;
}

@property (nonatomic, assign) Task *taskEdit;

@end
