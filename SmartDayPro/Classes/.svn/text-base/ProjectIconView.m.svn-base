//
//  ProjectIconView.m
//  SmartCal
//
//  Created by MacBook Pro on 7/22/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "ProjectIconView.h"

#import "Common.h"
#import "ImageManager.h"

@implementation ProjectIconView

@synthesize colorId;
@synthesize type;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void) createNotePath:(CGRect)rect ctx:(CGContextRef) ctx
{
    CGContextBeginPath(ctx);   
    
    CGContextMoveToPoint(ctx, rect.origin.x, rect.origin.y);
    CGContextAddLineToPoint(ctx, rect.origin.x + rect.size.width - 3, rect.origin.y);
    CGContextAddLineToPoint(ctx, rect.origin.x + rect.size.width, rect.origin.y + 3);
    CGContextAddLineToPoint(ctx, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    CGContextAddLineToPoint(ctx, rect.origin.x, rect.origin.y + rect.size.height);
    
    CGContextClosePath(ctx);
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
    UIColor *color = [UIColor blackColor];
    
    if (self.colorId == -1) //transparent project color
    {
        color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"transparent_pattern.png"]];        
    }
    else
    {
        color = [Common getColorByID:self.colorId colorIndex:0];
	}
    
	[color setFill];
	[color setStroke];
    CGContextSetLineWidth(ctx, 1);
	
	switch (self.type) {
		case ICON_CIRCLE:
        {
			CGContextFillEllipseInRect(ctx, rect);
        }
			break;
        case ICON_SQUARE:
        {
            CGContextFillRect(ctx, rect);
        }
            break;
        case ICON_ROUNDED_SQUARE:
        {
            fillRoundedRect(ctx, rect, 4, 4);
        }
            break;
		case ICON_RECT:
        {
            ////printf("rec w = %f, h = %f\n", rect.size.width, rect.size.height);
			CGContextFillRect(ctx, rect);
            
            [[UIColor whiteColor] setStroke];

            CGContextStrokeRect(ctx, rect);
        }
			break;
		case ICON_LIST:
		{
			rect = CGRectOffset(rect, 1, 1);
			rect.size.width -= 2;
			rect.size.height -= 2;
			
			CGContextSetLineWidth(ctx, 1);
			CGContextStrokeEllipseInRect(ctx, rect);
		}
			break;
        case ICON_TASK:
        {
            //CGContextSetLineWidth(ctx, 1);
            //CGContextStrokeRect(ctx, rect);
            
            [[color colorWithAlphaComponent:0.5] setFill];
            CGContextFillRect(ctx, rect);
            
            CGContextSetLineWidth(ctx, 2);
            CGContextStrokeRect(ctx, rect);            
        }
            break;
		case ICON_EVENT:
        {
			CGContextFillEllipseInRect(ctx, rect);
            
            UIImage *eventImg = [[ImageManager getInstance] getImageWithName:@"event_lines.png"];
            [eventImg drawInRect:rect];
            
        }
			break;
        case ICON_NOTE:
        {
            [self createNotePath:rect ctx:ctx];
            
            CGContextClip(ctx);
            
            CGContextFillRect(ctx, rect);
            
            UIImage *noteImg = [[ImageManager getInstance] getImageWithName:@"note_lines.png"];
            [noteImg drawInRect:rect];
            
        }
            break;			
	}
}


- (void)dealloc {
    [super dealloc];
}


@end
