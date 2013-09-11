//
//  TaskReadonlyDetailViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 6/27/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;

@interface TaskReadonlyDetailViewController : UIViewController
{
    UIView *contentView;
    UITableView *taskTableView;
}

@property (nonatomic, assign) Task *task;

@property (nonatomic, copy) Task *taskCopy;

@end
