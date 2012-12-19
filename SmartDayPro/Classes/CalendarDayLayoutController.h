//
//  CalendarDayLayoutController.h
//  SmartCal
//
//  Created by Trung Nguyen on 6/14/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LayoutController.h"

@interface CalendarDayLayoutController : LayoutController {
	NSDate *calendarDate;
	NSMutableArray *objectList;
	
	NSMutableArray *slotObjects[48];	
}

@property (nonatomic, copy) NSDate *calendarDate;
@property (nonatomic, retain) NSMutableArray *objectList;

- (void) setContentOffsetForTime:(NSDate *)time;

@end
