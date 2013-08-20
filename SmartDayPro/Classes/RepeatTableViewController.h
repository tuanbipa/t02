//
//  RepeatTableViewController.h
//  SmartPlan
//
//  Created by Huy Le on 12/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;
@class RepeatData;

@interface RepeatTableViewController : UIViewController<UITextFieldDelegate> {
	UITableView *repeatTableView;
	
	NSInteger selectedIndex;
	
    UIView *contentView;
	UIView *doneBarView;
	
	UITextField *activeTextField;
	UIButton *monthOptionButton;
	UILabel *untilValueLabel;
	UIDatePicker *untilPicker;
	
	Task *task;
	
	RepeatData *repeatData;
}

@property (nonatomic, assign) Task *task;
@property (nonatomic, copy) RepeatData *repeatData;

@end
