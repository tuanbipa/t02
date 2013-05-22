//
//  SettingTableViewController.h
//  SmartPlan
//
//  Created by Huy Le on 12/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Settings;
@class GuideWebView;

@interface SettingTableViewController : UITableViewController
{
	Settings *settingCopy;
	
	UITableView *settingTableView;
    
	GuideWebView *hint;
}

@property (nonatomic, copy) Settings *settingCopy;
@property BOOL sdwAccountChange;
@property BOOL tdAccountChange;

- (void) tabBarChanged:(BOOL)mini;
- (void) refreshMustDoCell;
- (void) refreshTimeZone;
- (void) save;

@end
