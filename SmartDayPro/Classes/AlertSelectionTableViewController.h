//
//  AlertSelectionTableViewController.h
//  SmartCal
//
//  Created by MacBook Pro on 8/16/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;
@class AlertData;

@interface AlertSelectionTableViewController : UIViewController {
	Task *taskEdit;
	NSInteger alertIndex;
	
	AlertData *alertData;
	
	UITableView *alertTableView;
	NSInteger selectedIndex;
	NSDictionary *alertDict;
	
	UILabel *timeLabel;
}

@property (nonatomic, assign) Task *taskEdit;
@property NSInteger alertIndex; 
@property (nonatomic, copy) AlertData *alertData;

@end
