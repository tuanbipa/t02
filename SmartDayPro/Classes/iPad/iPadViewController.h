//
//  iPadSmartDayViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 12/3/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AbstractSDViewController.h"

@class ContentView;

@interface iPadViewController : UIViewController
{
    ContentView *contentView;
    
    UISearchBar *searchBar;
    UIButton *timerButton;
}

@property (nonatomic, retain) UIViewController *activeViewCtrler;

- (void) deactivateSearchBar;
- (UIButton *) getTimerButton;

@end
