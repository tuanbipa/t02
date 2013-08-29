//
//  WWWTableViewController.h
//  SmartPlan
//
//  Created by Huy Le on 12/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AddressBookUI/AddressBookUI.h>

@class Task;
@class GrowingTextView;

@interface WWWTableViewController : UITableViewController<ABPeoplePickerNavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate> {
	UIView *contentView;
    UITableView *wwwTableView;
	
	Task *task;
	
    GrowingTextView *titleTextView;
	UIButton *selectedButton;
	UIView *doneBarView;
	UITextView *locationTextView;
}

@property (nonatomic, assign) Task *task;

@end
