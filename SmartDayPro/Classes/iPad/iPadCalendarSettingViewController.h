//
//  iPadCalendarSettingViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 2/20/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Settings;
@class ContentView;

@interface iPadCalendarSettingViewController : UIViewController
{
    ContentView *contentView;
    UITableView *settingTableView;
    
    UIView *pickerView;
    
    UIDatePicker *datePicker;
    UISegmentedControl *segmentedStyleControl;
    
    NSInteger selectedIndex;
}

@property (nonatomic, assign) Settings *setting;

@end
