//
//  TaskSyncViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 4/8/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Settings;

@interface TaskSyncViewController : UIViewController
{
    UITableView *settingTableView;
    
    UIView *contentView;
}

@property (nonatomic, assign) Settings *setting;
@property BOOL tdAccountChange;

- (void) refreshView;

@end
