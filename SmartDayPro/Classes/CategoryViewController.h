//
//  CategoryViewController.h
//  SmartCal
//
//  Created by Left Coast Logic on 6/25/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PageAbstractViewController.h"

@class ContentView;
@class ContentScrollView;
@class Project;
@class CategoryLayoutController;

@interface CategoryViewController : PageAbstractViewController
{
    ContentScrollView *listView;
    CategoryLayoutController *layoutController;
    
    //ContentView *contentView;
    
    NSInteger selectedIndex;
    NSInteger tapCount;
    NSInteger tapRow;
}

@property (nonatomic, retain) NSMutableArray *list;
@property NSInteger filterType;
@property BOOL showDone;
@property (nonatomic, readonly) ContentScrollView *listView;

-(void)expandProject:(Project *)prj;
- (void) loadAndShowList;
-(void)setNeedsDisplay;

- (void) markDoneTask:(Task *)task;
#pragma mark Multi Edit
- (void) multiDelete:(id)sender;
- (void) multiEdit:(BOOL)enabled;
@end
