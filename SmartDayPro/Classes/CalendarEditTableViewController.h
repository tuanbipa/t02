//
//  GoalEditTableViewController.h
//  SmartPlan
//
//  Created by Trung Nguyen on 1/29/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Settings;

@interface CalendarEditTableViewController : UITableViewController {
	UITableView *projectTableView;
	
	Settings *settings;
	//NSMutableArray *projectList;
	
	UIBarButtonItem *saveButton;
	
	NSInteger defaultProjectIndex;
}

@property (nonatomic, assign) Settings *settings;
//@property (nonatomic, retain) NSMutableArray *projectList;

@end
