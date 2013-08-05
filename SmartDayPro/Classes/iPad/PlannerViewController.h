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
@class PageAbstractViewController;

@interface PlannerViewController : AbstractActionViewController
{
    //SmartListViewController *smartListViewCtrler;
    PlannerView *plannerView;
    PlannerBottomDayCal *plannerBottomDayCal;
    
    BOOL firstOpen;
    
    UIView *moduleHeaderView;
    UIView *moduleView;
    UISegmentedControl *filterSegmentedControl;
    UIView *editBarView;
    
    UIButton *selectedModuleButton;
    
    PageAbstractViewController *viewCtrlers[3];
    
    NSInteger selectedCounter;
    
    NSMutableArray *moduleSeparatorList;
}

@property (nonatomic, readonly) PlannerView *plannerView;
@property (nonatomic, readonly) PlannerBottomDayCal *plannerBottomDayCal;

//@property (nonatomic, retain) UIPopoverController *popoverCtrler;

- (void) editItem:(Task *)item inView:(UIView *)inView;
- (void) hideDropDownMenu;
- (void) hidePopover;
- (void) refreshTaskFilterTitle;
- (void)showYearView: (UIView *) view;
- (void)showPreview: (UIView *) view;

- (void) showPlannerOff:(BOOL)enabled;
@end
