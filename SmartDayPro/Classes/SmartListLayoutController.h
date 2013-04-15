//
//  SmartListLayoutController.h
//  SmartCal
//
//  Created by Trung Nguyen on 5/21/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LayoutController.h"

@interface SmartListLayoutController : LayoutController {
	//BOOL checkActive;
	
	BOOL layoutFinished;
	NSMutableArray *taskList;

} 

@property BOOL layoutFinished;
//@property BOOL layoutInPlanner;

@property (nonatomic, retain) NSMutableArray *taskList;

@end
