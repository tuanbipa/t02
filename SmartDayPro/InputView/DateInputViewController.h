//
//  DateInputViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 7/10/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;

@interface DateInputViewController : UIViewController

@property (nonatomic, assign) IBOutlet UIDatePicker *picker;
@property (nonatomic, assign) IBOutlet UIBarButtonItem *noneItem;

@property (nonatomic, assign) Task *task;

@property NSInteger dateEdit;

- (IBAction)done:(id)sender;
- (IBAction)dateChanged:(id)sender;
- (IBAction)assignDate:(id)sender;

@end
