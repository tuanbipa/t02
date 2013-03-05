//
//  iPadTaskSettingViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 2/20/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Settings;

@interface iPadTaskSettingViewController : UIViewController
{
    UITableView *settingTableView;
}

@property (nonatomic, assign) Settings *setting;

@end
