//
//  TaskDetailTableViewController.h
//  SmartPlan
//
//  Created by Huy Le on 12/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@class Task;
@class HPGrowingTextView;

@interface TaskDetailTableViewController : UITableViewController<UITextFieldDelegate> {
	UITableView *taskTableView;
	UITableView *historyTableView;
	
	//UITextField *taskTitleTextField;
    HPGrowingTextView *titleTextView;
    UITextField *taskLocation;
	
	NSInteger keyEdit;
	
	Task *task;
	TaskIndex taskIndex;
	
	Task *taskCopy;
	
	UIView *historyView;
	
	UIButton *selectedDurationButton;
	UILabel *durationValueLabel;

	UIButton *selectedDeadlineButton;
	UILabel *deadlineValueLabel;
    //UIButton *deadlineCheckButton;
	
	UIButton *selectedStartButton;
	UILabel *startValueLabel;
	
	UISegmentedControl *taskTypeSegmentedControl;
	
	UIBarButtonItem *saveButton;
	NSArray *progressHistory;
	
	UITextField *tagInputTextField;
	UIButton *tagButtons[9];
	
	//BOOL isOfListStyle;
    
    BOOL showMore;
    BOOL deadlineEnabled;
	
	//OS4 Support
	NSInteger originalTaskKey;
	NSInteger originalTaskType;
}

@property NSInteger keyEdit; 
@property (nonatomic, retain) 	Task *task;
@property (nonatomic, copy) 	Task *taskCopy;

@property (nonatomic, retain) NSArray *progressHistory;

@property 	TaskIndex taskIndex;

- (void) refreshHistory;
- (void) tabBarChanged:(BOOL)mini;

@end
