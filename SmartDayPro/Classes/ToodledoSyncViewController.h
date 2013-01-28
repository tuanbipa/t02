//
//  ToodledoSyncViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 1/21/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "ViewController.h"

@class Settings;

@interface ToodledoSyncViewController : ViewController
{
    UITableView *settingTableView;
}

@property (nonatomic, assign) Settings *setting;
@property BOOL tdAccountChange;

- (void) refreshView;

@end
