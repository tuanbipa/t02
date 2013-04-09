//
//  DummyMovableController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 3/18/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "MovableController.h"

@interface DummyMovableController : MovableController
{
    MovableView *dummyView;
}

@property (nonatomic, assign) UIView *contentView;

- (CGRect) getMovableRect:(UIView *)view;

@end
