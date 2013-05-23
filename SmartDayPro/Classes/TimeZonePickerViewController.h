//
//  TimeZonePickerViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 5/15/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Settings;

@interface TimeZonePickerViewController : UIViewController
{
	UITableView *listTableView;
    UIView *contentView;
	
	NSInteger selectedIndex;
}

//@property (nonatomic, assign) Settings *settings;
@property (nonatomic, assign) NSObject *objectEdit;

@property (nonatomic, retain) NSMutableDictionary *searchDict;

@property (nonatomic, retain) NSMutableArray *tzIDList;

@end
