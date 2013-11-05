//
//  DurationInputViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 7/10/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;

@interface DurationInputViewController : UIViewController
{
    BOOL zeroPick;
}

@property (nonatomic, assign) IBOutlet UIDatePicker *picker;
@property (nonatomic, assign) IBOutlet UIBarButtonItem *noneItem;

@property (nonatomic, assign) Task *task;

- (IBAction)done:(id)sender;
- (IBAction)durationChanged:(id)sender;
- (IBAction)assignDuration:(id)sender;

@end
