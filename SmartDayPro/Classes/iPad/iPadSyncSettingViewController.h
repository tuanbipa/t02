//
//  iPadSyncSettingViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 2/21/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Settings;

@interface iPadSyncSettingViewController : UIViewController
{
    UITableView *settingTableView;
}

@property (nonatomic, assign) Settings *setting;

@end
