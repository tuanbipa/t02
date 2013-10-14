//
//  SeekOrCreateViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 2/25/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SeekOrCreateViewController : UIViewController
{
    UITableView *searchTableView;
    
    NSInteger tapCount;
    NSInteger tapRow;
    NSInteger tapSection;
}

@property (nonatomic, retain) NSMutableArray *taskList;
@property (nonatomic, retain) NSMutableArray *eventList;
@property (nonatomic, retain) NSMutableArray *noteList;
@property (nonatomic, retain) NSMutableArray *anchorList;

@property (nonatomic, copy) NSString *title;

- (void) search:(NSString *)title;

@end
