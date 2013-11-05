//
//  MustDoEditViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 11/5/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Settings;

@interface MustDoEditViewController : UIViewController
{
    UITableView *listTableView;
    
    NSInteger selectedIndex;
}

@property (nonatomic, assign) Settings *settings;

@end
