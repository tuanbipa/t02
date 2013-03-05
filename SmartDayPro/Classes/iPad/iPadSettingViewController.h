//
//  iPadSettingViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 2/19/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Settings;

@interface iPadSettingViewController : UIViewController
{
    UITableView *masterTableView;
    UIView *detailView;
    
    UIView *navView;
    UILabel *navLabel;
    
    NSInteger selectedIndex;
}

@property (nonatomic, retain) UINavigationController *navCtrler;
@property (nonatomic, copy) Settings *settingCopy;

@property BOOL sdwAccountChange;
@property BOOL tdAccountChange;

- (void) refresh;

@end
