//
//  PlannerViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 1/18/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "ViewController.h"

@class ContentView;
@class SmartListViewController;

@interface PlannerViewController : ViewController
{
    ContentView *contentView;
    
    SmartListViewController *smartListViewCtrler;
}

@end
