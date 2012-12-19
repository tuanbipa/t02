//
//  MiniMonthMovableController.h
//  SmartCal
//
//  Created by Left Coast Logic on 5/2/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import "MovableController.h"

#import "MovableView.h"

@interface MiniMonthMovableController : MovableController
{
    MovableView *dummyView;
    
    BOOL moveInMM;
}

- (void) doTaskMovementInMM;

@end
