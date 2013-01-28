//
//  TransparentToolbar.m
//  SmartCal
//
//  Created by MacBook Pro on 10/27/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "TransparentToolbar.h"


@implementation TransparentToolbar
// Override init.
- (id) init
{
	self = [super init];
	[self applyTranslucentBackground];
	return self;
}

// Override initWithFrame.
- (id) initWithFrame:(CGRect) frame
{
	self = [super initWithFrame:frame];
	[self applyTranslucentBackground];
	return self;
}

// Override draw rect to avoid
// background coloring
- (void)drawRect:(CGRect)rect {
    // do nothing in here
}

// Set properties to make background
// translucent.
- (void) applyTranslucentBackground
{
	self.backgroundColor = [UIColor clearColor];
	self.opaque = NO;
	self.translucent = YES;
}

@end
