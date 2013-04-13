//
//  MiniMonthMovableController.h
//  SmartCal
//
//  Created by Left Coast Logic on 5/2/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

//#import "MovableController.h"
#import "DummyMovableController.h"

#import "MovableView.h"

@interface MiniMonthMovableController : DummyMovableController
{
    //MovableView *dummyView;
    
    BOOL moveInMM;
    
    BOOL moveInFocus;
}

- (void) doTaskMovementInMM;
- (void) doTaskMovementInFocus;

@end
