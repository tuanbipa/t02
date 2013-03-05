//
//  TimerViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 2/26/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;
@class ContentView;

@interface TimerViewController : UIViewController
{
    ContentView *contentView;
    UITableView *timerTableView;
    
    NSMutableArray *taskList;
    
    NSTimer *activeTimer;
}

@end
