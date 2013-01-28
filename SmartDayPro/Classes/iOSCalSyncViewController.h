//
//  iOSCalSyncViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 1/22/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "ViewController.h"

@class Settings;

@interface iOSCalSyncViewController : ViewController
{
    UITableView *settingTableView;
}

@property (nonatomic, assign) Settings *setting;

@end
