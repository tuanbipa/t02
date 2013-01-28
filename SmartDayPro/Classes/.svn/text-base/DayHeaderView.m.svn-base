//
//  DayHeaderView.m
//  SmartCal
//
//  Created by Left Coast Logic on 5/8/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import "DayHeaderView.h"

#import "Common.h"
#import "Colors.h"

@implementation DayHeaderView

@synthesize date;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.date = [NSDate date];
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"category_header.png"]];
        //self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	if (self.date != nil)
	{
		NSString *dayStr = [Common getDayLineString:self.date];
        
        NSString *weekdays[7] = {_sundayText, _mondayText, _tuesdayText, _wednesdayText, _thursdayText, _fridayText, _saturdayText};
        
        NSInteger wkday = [Common getWeekday:self.date];
        
        if ([Common compareDateNoTime:self.date withDate:[NSDate date]] == NSOrderedSame)
        {
            dayStr = [NSString stringWithFormat:@"%@ - %@", _todayText, weekdays[wkday-1]];
            
        }
        else if ([Common compareDateNoTime:self.date withDate:[Common dateByAddNumDay:1 toDate:[NSDate date]]] == NSOrderedSame)
        {
            dayStr = [NSString stringWithFormat:@"%@ - %@", _tomorrowText, weekdays[wkday-1]];
        }        
        
        [[UIColor grayColor] set];
        
		[dayStr drawInRect:rect withFont:[UIFont italicSystemFontOfSize:15] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentLeft];
        
        rect.origin.y -= 1;
        
		[[UIColor whiteColor] set];
        
        UIFont *font = [UIFont italicSystemFontOfSize:15];
        		
		[dayStr drawInRect:rect withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentLeft];
        
        /*
        CGSize sz = [dayStr sizeWithFont:font];
        
        CGFloat lengths[] = {4, 2};
        
        UIColor *color = [UIColor brownColor];
        
        [color setFill];
        [color setStroke];
        
        CGContextSetLineDash(ctx, 0, lengths, 2);	
        CGContextSetLineWidth(ctx, 1);
        
        CGContextMoveToPoint(ctx, rect.origin.x + (rect.size.width - sz.width)/2, rect.origin.y + rect.size.height -1);
        CGContextAddLineToPoint( ctx, rect.origin.x + (rect.size.width - sz.width)/2 + sz.width, rect.origin.y +rect.size.height - 1);
        CGContextStrokePath(ctx);
        */
        
	}
        
}

@end
