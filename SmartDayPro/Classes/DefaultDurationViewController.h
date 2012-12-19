//
//  DefaultDurationViewController.h
//  SmartCal
//
//  Created by Left Coast Logic on 9/14/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Settings;

@interface DefaultDurationViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *listTableView;
    
    NSInteger selectedIndex;
}

@property (nonatomic, assign) Settings *settings;

@end
