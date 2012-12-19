//
//  LocationViewController.h
//  iVo
//
//  Created by Nang Le on 7/8/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Task.h"

@interface LocationViewController : UIViewController < UITableViewDataSource, UITableViewDelegate,
														UITextViewDelegate,UITextFieldDelegate > 
{

	Task 				*task;
	UITableView			*tableView;
	UIBarButtonItem		*saveButton;
	NSIndexPath			*oldSelectedIndex;
	
	NSString			*selectedLocation;
	UIView				*contentView;
	UISegmentedControl	*sortAddress;
	
	NSMutableArray		*indexArrayList;
}
@property (nonatomic, assign)	Task			*task;
@property (nonatomic, copy)		NSString		*selectedLocation;
@property (nonatomic, retain)	NSIndexPath		*oldSelectedIndex;
@property (nonatomic, retain)	NSMutableArray	*indexArrayList;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;


@end
