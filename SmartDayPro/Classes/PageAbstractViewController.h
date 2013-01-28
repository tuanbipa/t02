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
@class ContentView;

@interface PageAbstractViewController : UIViewController
{
    MovableController *movableController;
    
    ContentView *contentView;
}

@property (nonatomic, readonly) MovableController *movableController;
@property (nonatomic, readonly) ContentView *contentView;

- (void) deselect;
- (Task *) getSelectedTask;
- (Project *) getSelectedCategory;

- (void) changeFrame:(CGRect)frm;
- (void) loadAndShowList;

@end
