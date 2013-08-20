//
//  SyncWindow2TableViewController.h
//  SmartTime
//
//  Created by Huy Le on 9/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Settings;

@interface SyncWindow2TableViewController : UIViewController {
	UITableView *syncFromTableView;
	UITableView *syncToTableView;
    
    UITableView *settingTableView;
	
	NSInteger syncFromIndex;
	NSInteger syncToIndex;
	
	Settings *setting;
}

@property (nonatomic, assign) Settings *setting;

@end
