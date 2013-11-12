//
//  ProjectInputViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 7/11/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;

@interface ProjectInputViewController : UIViewController
{
    NSInteger selectedIndex;
}

@property (nonatomic, retain) NSMutableArray *projectList;

@property (nonatomic, assign) IBOutlet UITableView *listTableView;

@property (nonatomic, assign) IBOutlet UIBarButtonItem *doneItem;

@property (nonatomic, assign) Task *task;

- (IBAction)done:(id)sender;

@end
