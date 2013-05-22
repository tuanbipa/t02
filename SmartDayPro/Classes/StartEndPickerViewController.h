//
//  StartEndPickerViewController.h
//  SmartPlan
//
//  Created by Huy Le on 12/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;

@interface StartEndPickerViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	NSDate *minStartTime;
	
	NSInteger selectedIndex;
	
	UITableView *pickerTableView;
	UIDatePicker *datePicker;
}

@property (nonatomic, copy) NSDate *minStartTime;

@property (nonatomic, assign) Task *task;
@property (nonatomic, copy) Task *taskCopy;

- (void) refreshTimeZone;

@end
