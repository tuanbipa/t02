//
//  PageAbstractViewController.h
//  SmartCal
//
//  Created by Left Coast Logic on 5/10/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MovableController;
@class Task;
@class Project;

@interface PageAbstractViewController : UIViewController
{
    MovableController *movableController;
}

@property (nonatomic, readonly) MovableController *movableController;

- (void) deselect;
- (Task *) getSelectedTask;
- (Project *) getSelectedCategory;

@end
