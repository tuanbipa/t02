//
//  NoteViewController.h
//  SmartCal
//
//  Created by Left Coast Logic on 6/21/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PageAbstractViewController.h"

@class ContentView;
@class ContentTableView;
@class Task;

@interface NoteViewController : PageAbstractViewController<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
{
    //ContentView *contentView;
    ContentTableView *listTableView;
    
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
- (void) changeItem:(Task *)task action:(NSInteger)action;
//- (void) initData;
- (void) filter:(NSInteger)type;
- (void) loadAndShowList;

@end
