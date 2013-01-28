//
//  CalendarADEView.m
//  SmartTime
//
//  Created by Left Coast Logic on 1/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QuickColorPickerView.h"

#import "Common.h"
#import "Settings.h"

#define MAX_DISPLAY_ITEM 9
#define COLOR_SQUARE_SIZE 12
#define COLOR_ADE_HEIGHT 25
#define SELECTION_WIDTH 100

@implementation QuickColorPickerView

@synthesize colorIdList;
@synthesize selected;
@synthesize currentIndex;

-(void)initData
{
	self.colorIdList = [NSMutableArray arrayWithCapacity:PROJECT_COLOR_NUM];
	
	for (int i=0; i<PROJECT_COLOR_NUM; i++)
	{
		[self.colorIdList addObject:[NSNumber numberWithInt:i]];
	}
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		
		self.backgroundColor = [UIColor clearColor];
		
		currentIndex = 0;
		startIndex = 0;
		
		scrollToRight = NO;
		
		selected = NO;
		
		[self initData];
    }
    return self;
}

-(void)resetIndex
{
	self.selected = NO;
	
	currentIndex = 0;
	startIndex = 0;
	
	scrollToRight = NO;
}

- (void) changeBackgroundStyle
{
	[self setNeedsDisplay];
}

-(void)scroll:(BOOL)toRight
{
	self.selected = NO;
	scrollToRight = toRight;
	
	if (toRight && (currentIndex < [self.colorIdList count] - 1))
	{
		currentIndex += 1;
		
		if (currentIndex >= startIndex + MAX_DISPLAY_ITEM)
		{
			startIndex += 1;
		}
		
		[self setNeedsDisplay];
	}
	else if (!toRight && currentIndex > 0)
	{
		currentIndex -= 1;
		
		if (currentIndex < startIndex)
		{
			startIndex = currentIndex;
		}
		
		[self setNeedsDisplay];
	}
}

- (void) setSelected:(BOOL) selectedVal
{
	BOOL needsDisplay = (selected != selectedVal);
	
	selected = selectedVal;
	
	if (needsDisplay)
	{
		[self setNeedsDisplay];
	}
}

- (NSInteger) getSelectedColorId
{
	if (currentIndex >= 0 && currentIndex < colorIdList.count)
	{		
		return currentIndex;
	}
	
	return 0;
}

- (void) selectColorId:(NSInteger) colorId
{
	for (int i=0; i<self.colorIdList.count; i++)
	{
		NSNumber *number = [self.colorIdList objectAtIndex:i];
		
		if ([number intValue] == colorId)
		{
			currentIndex = i;
			
			[self setNeedsDisplay];
			break;
		}
	}
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
	if (self.colorIdList == nil || self.colorIdList.count == 0)
	{
		return;
	}

	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextClearRect(ctx, rect);
	
	UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
	
	CGSize leftSize = [@" Color:" sizeWithFont:font];
	
	Settings *settings = [Settings getInstance];
	
	switch(settings.skinStyle)
	{
		case 0:
			[[UIColor blackColor] set];
			break;
		case 1:
			[[UIColor whiteColor] set];
			break;
	}	
	
	[@" Color:" drawInRect:CGRectMake(0, 10, leftSize.width, leftSize.height) withFont:font lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];	
	
	CGFloat x = 4 + leftSize.width;
	
	for (int i=startIndex; i<currentIndex; i++)
	{
		UIColor *color = [[Common getColorByID:i colorIndex:1] colorWithAlphaComponent:0.5];
		
		[color setFill];
		
		CGContextFillRect(ctx, CGRectMake(x, 12, COLOR_SQUARE_SIZE, COLOR_SQUARE_SIZE));
		
		x += COLOR_SQUARE_SIZE + 4;
	}
	
	//NSNumber *colorNum = [self.colorIdList objectAtIndex:currentIndex];
	
	BOOL moreThanMax = NO;
	
	//if (colorNum != nil)
	{
		NSInteger count = self.colorIdList.count;
		
		if (self.colorIdList.count > MAX_DISPLAY_ITEM)
		{
			if (startIndex < count - MAX_DISPLAY_ITEM)
			{
				moreThanMax = YES;
			}
			
			count = MAX_DISPLAY_ITEM;			
		}
		
		CGRect colorRect = CGRectMake(x, 6, SELECTION_WIDTH, COLOR_ADE_HEIGHT);

		UIColor *prjColor = [Common getColorByID:currentIndex colorIndex:1];
		
		[prjColor setFill];
		
		fillRoundedRect(ctx, colorRect, 4, 4);
		
		if (self.selected)
		{
			[[UIColor yellowColor] set];
			
			CGContextSetLineWidth(ctx, 2);
			
			strokeRoundedRect(ctx, colorRect, 4, 4);
		}		
				
		x += SELECTION_WIDTH + 4;		
	}
	
	for (int i=currentIndex + 1; i<startIndex + MAX_DISPLAY_ITEM; i++)
	{
		if (i < self.colorIdList.count)
		{
			UIColor *color = [[Common getColorByID:i colorIndex:1] colorWithAlphaComponent:0.5];
			[color setFill];
			
			CGContextFillRect(ctx, CGRectMake(x, 12, COLOR_SQUARE_SIZE, COLOR_SQUARE_SIZE));
			
			x += COLOR_SQUARE_SIZE + 4;			
		}
		else
		{
			break;
		}
	}
	
	if (moreThanMax)
	{
		switch(settings.skinStyle)
		{
			case 0:
				[[UIColor blackColor] set];
				break;
			case 1:
				[[UIColor whiteColor] set];
				break;
		}	
		
		[@"..." drawInRect:CGRectMake(x, 6, COLOR_SQUARE_SIZE, COLOR_ADE_HEIGHT) withFont:font lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];	
		
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
	if (touch.tapCount == 2)
	{
	}
	else 
	{		
		UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
		
		CGSize leftSize = [@" Color:" sizeWithFont:font];
		
		NSInteger count = self.colorIdList.count;
		
		BOOL moreThanMax = NO;
		
		if (self.colorIdList.count > MAX_DISPLAY_ITEM)
		{
			if (startIndex < count - MAX_DISPLAY_ITEM)
			{
				moreThanMax = YES;
			}
			
			count = MAX_DISPLAY_ITEM;			
		}
		
		//CGFloat width = self.frame.size.width - leftSize.width - 2*4 - (moreThanMax?count:count-1) *(COLOR_SQUARE_SIZE + 4); 
		
		CGFloat width = SELECTION_WIDTH;
		
		CGFloat x = leftSize.width + 4 + (currentIndex - startIndex) *(COLOR_SQUARE_SIZE + 4);
		
		CGPoint touchPoint = [touch locationInView:self];
		
		////////printf("touch point x = %f, x = %f, w = %f\n", touchPoint.x, x, width);
		
		if (touchPoint.x > x + width)
		{
			[self scroll:YES];
		}
		else if (touchPoint.x < x)
		{
			[self scroll:NO];
		}
		else
		{
			self.selected = !self.selected;
		}
	}
}

- (void)dealloc {
	
	self.colorIdList = nil;
	
    [super dealloc];
}


@end
