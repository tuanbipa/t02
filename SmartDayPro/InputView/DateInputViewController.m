//
//  DateInputViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 7/10/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "DateInputViewController.h"

#import "Common.h"
#import "Settings.h"

#import "Task.h"

#import "DetailViewController.h"
#import "NoteDetailViewController.h"
#import "RepeatTableViewController.h"

extern DetailViewController *_detailViewCtrler;
extern NoteDetailViewController *_noteDetailViewCtrler;
extern RepeatTableViewController *_repeatViewCtrler;

@implementation DateInputViewController

@synthesize picker;
@synthesize task;
@synthesize dateEdit;
@synthesize noneItem;
@synthesize toolbar;

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
    
    if ([task isNote] || [task isEvent])
    {
        NSMutableArray *items = [NSMutableArray arrayWithArray:self.toolbar.items];
        
        [items removeObjectAtIndex:0];
        
        self.toolbar.items = items;
        
        self.noneItem = nil;
    }
    
    if ([task isADE] || [task isTask] || [task isNote] || dateEdit == TASK_EDIT_UNTIL)
    {
        picker.datePickerMode = UIDatePickerModeDate;
    }
    
    if ([task isEvent])
    {
        picker.timeZone = [Settings getTimeZoneByID:task.timeZoneId];
    }
    
    switch (dateEdit)
    {
        case TASK_EDIT_START:
        {
            if (self.task.startTime == nil)
            {
                self.noneItem.tintColor = [UIColor blueColor];
            }
            else
            {
                picker.date = self.task.startTime;
            }
        }
            break;
        case TASK_EDIT_END:
        {
            noneItem.enabled = NO;
            
            picker.date = self.task.endTime;
        }
            break;
        case TASK_EDIT_DEADLINE:
        {
            if (self.task.deadline == nil)
            {
                self.noneItem.tintColor = [UIColor blueColor];
            }
            else
            {
                picker.date = self.task.deadline;
            }
        }
            break;
        case TASK_EDIT_UNTIL:
        {
            noneItem.enabled = NO;
        }
            break;
    }
    
    NSString *texts[5] = {_noneText, _todayText, _tomorrowText, _1WeekText, _doneText};
    
    for (UIBarButtonItem *item in self.toolbar.items)
    {
        item.title = texts[item.tag];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender
{
    if (_detailViewCtrler != nil)
    {
        [_detailViewCtrler refreshWhen];
        [_detailViewCtrler closeInputView];
    }
    else if (_noteDetailViewCtrler != nil)
    {
        [_noteDetailViewCtrler refreshDate];
        [_noteDetailViewCtrler closeInputView];
    }
    else if (_repeatViewCtrler != nil)
    {
        [_repeatViewCtrler closeInputView];
    }
}

- (void) changeDate:(NSDate *)date
{
    Settings *settings = [Settings getInstance];
    
    switch (dateEdit)
    {
        case TASK_EDIT_START:
        {
            if ([task isTask])
            {
                task.startTime = [settings getWorkingStartTimeForDate: date];
                
                if (task.deadline != nil && [task.deadline compare:task.startTime] == NSOrderedAscending)
                {
                    task.deadline = [settings getWorkingEndTimeForDate:task.startTime];
                }
            }
            else
            {
                if (task.endTime != nil && [task.endTime compare:date] != NSOrderedDescending)
                {
                    NSTimeInterval diff = [task.endTime timeIntervalSinceDate:task.startTime];
                    
                    task.endTime = [Common dateByAddNumSecond:diff toDate:date];
                }
                
                task.startTime = ([task isADE]?[Common clearTimeForDate:date]:date);
            }
        }
            break;
        case TASK_EDIT_END:
        {
            if (task.startTime != nil && [date compare:task.startTime] != NSOrderedDescending)
            {
                NSTimeInterval diff = [task.endTime timeIntervalSinceDate:task.startTime];
                
                task.startTime = [Common dateByAddNumSecond:-diff toDate:date];
            }
            
            task.endTime = [task isADE]?[Common getEndDate:date]:date;
        }
            break;
        case TASK_EDIT_DEADLINE:
        {
            NSInteger diff = 0;
            
            if (task.startTime != nil && task.deadline != nil && date != nil)
            {
                diff = [task.deadline timeIntervalSinceDate:task.startTime];
            }
            
			task.deadline = date == nil?nil:[settings getWorkingEndTimeForDate:date];
            
            if (diff > 0)
            {
                NSDate *dt = [NSDate dateWithTimeInterval:-diff sinceDate:task.deadline];
                
                task.startTime = [settings getWorkingStartTimeForDate:dt];
            }
        }
            break;
        case TASK_EDIT_UNTIL:
        {
            if (_repeatViewCtrler != nil)
            {
                [_repeatViewCtrler changeUntil:date];
            }
        }
    }
    
    noneItem.tintColor = date == nil?[UIColor blueColor]:nil;
}

- (IBAction)dateChanged:(id)sender
{
    [self changeDate:picker.date];
}

- (IBAction)assignDate:(id)sender
{
    UIBarButtonItem *item = (UIBarButtonItem *)sender;
    
    NSDate *dt = nil;
    
    switch (item.tag)
    {
        case 1:
            dt = [NSDate date];
            break;
        case 2:
            dt = [Common dateByAddNumDay:1 toDate:[NSDate date]];
            break;
        case 3:
            dt = [Common dateByAddNumDay:7 toDate:[NSDate date]];
            break;
    }
    
    for (UIBarButtonItem *barItem in toolbar.items)
    {
        barItem.tintColor = (barItem.tag == item.tag?[UIColor blueColor]:nil);
    }
    
    [self changeDate:dt];
    
    if (dt != nil)
    {
        picker.date = dt;
    }
}

@end
