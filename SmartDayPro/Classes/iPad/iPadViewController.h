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
@class Task;
@class Project;
@class AbstractActionViewController;

@interface iPadViewController : UIViewController<UISearchBarDelegate>
{
    ContentView *contentView;
    UIView *detailView;
    
    UISearchBar *searchBar;
    UIButton *timerButton;
    UIButton *tagButton;
    UIButton *eyeButton;
}

@property (nonatomic, retain) AbstractActionViewController *activeViewCtrler;

@property (nonatomic, retain) UINavigationController *detailNavCtrler;

- (void) deactivateSearchBar;
- (UIButton *) getTimerButton;

- (void) refreshFilterStatus;

- (void) editNoteDetail:(Task *)note;
-(void) editItemDetail:(Task *)item;
- (void) editProjectDetail:(Project *)project;
- (void) closeDetail;

@end
