//
//  iPadSettingViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 2/19/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Settings;
@class ContentView;

@interface iPadSettingViewController : UIViewController
{
    ContentView *contentView;
    UITableView *masterTableView;
    UIView *detailView;
    
    UIView *separatorView;
    UIView *navView;
    UILabel *navLabel;
    UIButton *backButton;
    
    NSInteger selectedIndex;
}

@property (nonatomic, retain) UINavigationController *navCtrler;
@property (nonatomic, copy) Settings *settingCopy;

@property BOOL sdwAccountChange;
@property BOOL tdAccountChange;

- (void) refresh;

@end
