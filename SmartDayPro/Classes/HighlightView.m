//
//  HighlightView.m
//  SmartCal
//
//  Created by MacBook Pro on 3/25/11.
//  Copyright 2011 LCL. All rights reserved.
//

#import "HighlightView.h"


@implementation HighlightView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
	CGContextRef ctx = UIGraphicsGetCurrentContext();

	CGContextSetLineWidth(ctx, 2);
	[[UIColor yellowColor] set];
	CGContextStrokeRect(ctx, rect);
	
}

- (void)dealloc {
    [super dealloc];
}


@end
