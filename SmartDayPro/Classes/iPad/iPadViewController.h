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
@class GuideWebView;
@class Task;
@class Project;
@class AbstractActionViewController;

@interface iPadViewController : UIViewController<UISearchBarDelegate>
{
    ContentView *contentView;
    UIView *detailView;
    UIView *hintView;
    
    UISearchBar *searchBar;
    UIButton *timerButton;
    UIButton *tagButton;
    UIButton *eyeButton;
    UIButton *commentButton;

    BOOL firstTimeLoad;
    
    // location data filter
    UIButton *taskLocationButton;
    UILabel *taskLocationLable;
}

@property (nonatomic, retain) AbstractActionViewController *activeViewCtrler;

@property (nonatomic, retain) UINavigationController *detailNavCtrler;

@property BOOL inSlidingMode;

@property NSInteger selectedModuleIndex;

- (void) deactivateSearchBar;
- (UIButton *) getTimerButton;

- (void) refreshFilterStatus;

- (void) editNoteContent:(Task *)note;
- (void) editNoteDetail:(Task *)note;
- (void) editMapLocation:(Task *)task;
-(void) editItemDetail:(Task *)item;
- (void) editProjectDetail:(Project *)project;
- (void) closeDetail;
- (void) slideView:(BOOL)enabled;
- (void) slideAndShowDetail;

- (void) changeOrientation:(UIInterfaceOrientation) orientation;

@end
