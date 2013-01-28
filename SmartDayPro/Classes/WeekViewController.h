//
//  WeekViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 10/22/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeekViewController : UIViewController
{
    UITableView *listTableView;
    
    NSMutableArray *adeLists[7];
    NSMutableArray *eventLists[7];
    NSMutableArray *taskLists[7];
}

- (void) exportPNG;

@end
