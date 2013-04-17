//
//  PlannerViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 1/18/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "AbstractActionViewController.h"

@class MovableView;
@class ContentView;
@class SmartListViewController;
@class PlannerView;
@class PlannerBottomDayCal;
@class TaskView;

@interface PlannerViewController : AbstractActionViewController
{
    SmartListViewController *smartListViewCtrler;
    PlannerView *plannerView;
    PlannerBottomDayCal *plannerBottomDayCal;
    
    UIView *optionView;
    UIImageView *optionImageView;
}

@property (nonatomic, readonly) PlannerView *plannerView;
@property (nonatomic, readonly) PlannerBottomDayCal *plannerBottomDayCal;

//@property (nonatomic, retain) UIPopoverController *popoverCtrler;

- (void) editItem:(Task *)item inView:(UIView *)inView;
- (void) hidePopover;
- (void) refreshTaskFilterTitle;

@end
