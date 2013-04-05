//
//  PlannerCalendarLayoutController.h
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 4/3/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayoutController.h"

@interface PlannerCalendarLayoutController : LayoutController {
    
    NSMutableArray *slotObjects[7][48];
    //NSMutableArray *slotObjects[336];
    NSDate *startDate;
}

@property (nonatomic, retain) NSMutableArray *objList;
@property (nonatomic, retain) NSDate *startDate;
@end
