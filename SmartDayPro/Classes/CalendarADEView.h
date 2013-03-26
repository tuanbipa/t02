//
//  CalendarADEView.h
//  SmartCal
//
//  Created by Left Coast Logic on 6/25/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ContentScrollView.h"

@interface CalendarADEView : ContentScrollView
{
}

@property (nonatomic, retain) NSMutableArray *adeList;

- (void) refreshData;

- (void) reconcileLinks:(NSDictionary *)dict;
- (void) reloadAlert4Task:(NSInteger)taskId;

@end
