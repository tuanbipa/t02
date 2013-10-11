//
//  DurationInputViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 7/10/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "DurationInputViewController.h"

#import "Task.h"

#import "DetailViewController.h"

extern DetailViewController *_detailViewCtrler;

@implementation DurationInputViewController

@synthesize picker;
@synthesize noneItem;

@synthesize task;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
	//self.picker.minuteInterval = 5;
	//self.picker.datePickerMode = UIDatePickerModeCountDownTimer;
    
    self.picker.countDownDuration = self.task.duration;
    
    self.noneItem.tintColor = self.task.duration == 0?[UIColor blueColor]:nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender
{
    self.task.duration = picker.countDownDuration;
    
    if (_detailViewCtrler != nil)
    {
        [_detailViewCtrler refreshDuration];
        
        [_detailViewCtrler closeInputView];
    }
}

- (IBAction)durationChanged:(id)sender
{
    self.task.duration = picker.countDownDuration;
    
    self.noneItem.tintColor = self.task.duration == 0?[UIColor blueColor]:nil;
}

- (IBAction)assignDuration:(id)sender
{
    UIBarButtonItem *item = (UIBarButtonItem *)sender;
    
    switch (item.tag)
    {
        case 0:
            self.task.duration = 0;
            break;
        case 1:
            self.task.duration = 15*60;
            break;
        case 2:
            self.task.duration = 60*60;
            break;
        case 3:
            self.task.duration = 180*60;
            break;
            
    }
    self.picker.countDownDuration = self.task.duration;
    
    self.noneItem.tintColor = self.task.duration == 0?[UIColor blueColor]:nil;
}

@end
