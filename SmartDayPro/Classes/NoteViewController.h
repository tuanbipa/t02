//
//  NoteViewController.h
//  SmartCal
//
//  Created by Left Coast Logic on 6/21/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PageAbstractViewController.h"
@class NoteLayoutController;
//@class ContentTableView;
@class ContentScrollView;
@class Task;

@interface NoteViewController : PageAbstractViewController<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
{
    NoteLayoutController *noteLayoutCtrler;
    //ContentTableView *listTableView;
    ContentScrollView *noteListView;
    UIButton *emptyNoteButton;
    
    UIView *editBarPlaceHolder;
    
    NSInteger focusIndex;
    BOOL checkFocus;
    
    NSInteger selectedIndex;
    NSInteger tapCount;
    NSInteger tapRow;
    
    NSInteger filterType;
}

@property (nonatomic, retain) NSMutableArray *noteList;

@property NSInteger filterType;

- (Task *) getSelectedTask;
//- (void) changeItem:(Task *)task action:(NSInteger)action;
- (void) filter:(NSInteger)type;
- (void) loadAndShowList;
- (void) multiEdit:(BOOL)enabled;
- (void) multiDelete:(id)sender;

@end
