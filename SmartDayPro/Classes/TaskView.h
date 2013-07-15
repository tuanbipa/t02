//
//  TaskView.h
//  SmartCal
//
//  Created by Trung Nguyen on 5/20/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MovableView.h"

@class Task;

@interface TaskView : MovableView {
	UIImageView *checkImageView;
	UIImageView *starImageView;
    UIView *checkView;
    UIView *starView;
    UIButton *checkButton;
    UIButton *starButton;
	
	BOOL checkEnable;
	BOOL starEnable;
    
    BOOL transparent;
    
    // for view in filter mode
    BOOL showDue;
    BOOL showFlag;
    BOOL showDuration;
}

@property BOOL checkEnable;
@property BOOL starEnable;
@property BOOL transparent;

@property BOOL showDue;
@property BOOL showFlag;
@property BOOL showDuration;

@property BOOL listStyle;
@property BOOL focusStyle;

@property BOOL showListBorder;
@property BOOL showSeparator;

@property (nonatomic, retain) Task *task;

- (void) refresh;
-(void)refreshStarImage;
-(void)refreshCheckImage;
//- (id)initWithTask:(Task *)task;
- (BOOL) isMultiSelected;

@end
