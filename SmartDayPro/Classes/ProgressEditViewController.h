//
//  ProgressEditViewController.h
//  SmartPlan
//
//  Created by Huy Le on 12/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TaskProgress;

@interface ProgressEditViewController : UIViewController {
	TaskProgress *progress;
	TaskProgress *progressCopy;
	BOOL only1Progress;
	
	NSDate *minStartTime;
	
	UIButton *startButton;
	UIButton *endButton;
	UIButton *selectedButton;
	
	UIDatePicker *datePicker;
	
	UIBarButtonItem *saveButton;
}

@property (nonatomic, copy) NSDate *minStartTime;
@property (nonatomic, assign) TaskProgress *progress;
@property (nonatomic, copy) TaskProgress *progressCopy;
@property BOOL only1Progress;
		   
@end
