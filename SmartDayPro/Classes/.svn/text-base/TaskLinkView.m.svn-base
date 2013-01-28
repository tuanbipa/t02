//
//  TaskLinkView.m
//  SmartCal
//
//  Created by MacBook Pro on 8/30/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "TaskLinkView.h"

#import "Common.h"

@implementation TaskLinkView

@synthesize colorId;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.userInteractionEnabled = NO;
		self.backgroundColor = [UIColor clearColor];
		self.colorId = 0;
    }
    return self;
	
}

- (void)drawRect:(CGRect)rect 
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
		
	UIColor *color = [Common getColorByID:self.colorId colorIndex:1];
	[color setStroke];
	
	CGContextSetLineWidth(ctx, 2);
	
	CGFloat x = ceil(rect.origin.x + rect.size.width/2);	
	
	CGFloat lengths[] = {2, 2};
	CGContextSetLineDash(ctx, 0, lengths, 2);		
	
	CGContextMoveToPoint(ctx, x, rect.origin.y);
	CGContextAddLineToPoint( ctx, x, rect.origin.y + rect.size.height);
	CGContextStrokePath(ctx);		
}

@end
