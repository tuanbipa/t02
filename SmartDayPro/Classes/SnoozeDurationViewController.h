//
//  SnoozeDurationViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 3/25/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Settings;

@interface SnoozeDurationViewController : UIViewController
{
    UITableView *listTableView;

    NSInteger selectedIndex;
}

@property (nonatomic, assign) Settings *settings;

@end
