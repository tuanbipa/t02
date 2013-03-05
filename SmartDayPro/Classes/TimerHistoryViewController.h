//
//  TimerHistoryViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 3/4/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;

@interface TimerHistoryViewController : UIViewController
{
    UITableView *historyTableView;
    
    NSInteger actualDuration;
}

@property (nonatomic, retain) NSMutableArray *progressList;

@property (nonatomic, assign) Task *task;

@end
