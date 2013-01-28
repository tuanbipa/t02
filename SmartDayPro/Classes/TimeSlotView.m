//
//  TimeSlotView.m
//  iVo
//
//  Created by Left Coast Logic on 7/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TimeSlotView.h"

#import "Common.h"
#import "Settings.h"
#import "TaskManager.h"
//#import "LandscapeViewController.h"
#import "CalendarViewController.h"
#import "SmartDayViewController.h"

//extern LandscapeViewController *_landscapeViewCtrler;
extern CalendarViewController *_sc2ViewCtrler;
extern SmartDayViewController *_sdViewCtrler;

extern AbstractSDViewController *_abstractViewCtrler;

extern BOOL _is24HourFormat;

@implementation TimeSlotView

@synthesize time;

- (id)initWithFrame:(CGRect)frame {
	
	if (self = [super initWithFrame:frame]) {
		// Initialization code
		self.backgroundColor = [UIColor clearColor];
		
		UILongPressGestureRecognizer *lpHandler = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandler:)];
		lpHandler.minimumPressDuration = 0.4; //seconds
		lpHandler.delegate = self;
		[self addGestureRecognizer:lpHandler];
		[lpHandler release];	  
		
	}
	
	return self;
}

- (void)drawRect:(CGRect)rect {
	// Drawing code
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextClearRect(ctx, rect);
	
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	unsigned unitFlags = 0xFFFF;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:self.time];
	
	NSInteger minute = [comps minute];
	NSInteger hour = [comps hour];

	NSString *timestr = nil;
	
	NSString *timeStrings[24] = 
	{	
		@"12 AM", @"1 AM", @"2 AM", @"3 AM", @"4 AM", @"5 AM", @"6 AM", @"7 AM",
		@"8 AM", @"9 AM", @"10 AM", @"11 AM", @"Noon", @"1 PM", @"2 PM", @"3 PM",
		@"4 PM", @"5 PM", @"6 PM", @"7 PM", @"8 PM", @"9 PM", @"10 PM", @"11 PM"
	};

	NSString *timeStrings_24[24] = 
	{	
		@"0:00", @"1:00", @"2:00", @"3:00", @"4:00", @"5:00", @"6:00", @"7:00",
		@"8:00", @"9:00", @"10:00", @"11:00", @"12:00", @"13:00", @"14:00", @"15:00",
		@"16:00", @"17:00", @"18:00", @"19:00", @"20:00", @"21:00", @"22:00", @"23:00"
	};
	
	if (minute == 0)
	{
//Trung 08102101
		if (_is24HourFormat)
		{
			timestr = timeStrings_24[hour];
		}
		else
		{
			timestr = timeStrings[hour];
		}
	}

	CGFloat fontSize = 12;

	//CGRect bounds = self.bounds;
    CGRect bounds = rect;
	
	CGSize timePaneSize = [TimeSlotView calculateTimePaneSize];
	
	UIFont *font = [UIFont fontWithName:@"Helvetica" size:fontSize-2];
	CGSize amsize = [@"AM" sizeWithFont:font];
	
	CGRect timePaneRec = CGRectZero;
	timePaneRec.size = timePaneSize;
	timePaneRec.origin.y = (bounds.size.height - amsize.height)/2;
	timePaneRec.origin.x = LEFT_MARGIN;
	
	CGPoint points[2];
	
	points[0].x = LEFT_MARGIN + timePaneSize.width + TIME_LINE_PAD;
	points[0].y = bounds.size.height/2;

	points[1].x = bounds.size.width;
	points[1].y = points[0].y;
	
	points[0].x = ceil(points[0].x);
	points[1].x = ceil(points[1].x);
	points[0].y = ceil(points[0].y);
	points[1].y = ceil(points[1].y);
	
	UIColor *lightColor;
	UIColor *darkColor;
	
    /*
	Settings *settings = [Settings getInstance];
	
	switch(settings.skinStyle)
	{
		case 0:
			darkColor = [UIColor colorWithRed:0.19 green:0.25 blue:0.31 alpha:1];
			lightColor = [UIColor blackColor];
			break;
		case 1:
			darkColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
			lightColor = [UIColor whiteColor];
			break;
	}
    */
    
    darkColor = [UIColor colorWithRed:0.19 green:0.25 blue:0.31 alpha:1];
    lightColor = [UIColor blackColor];
	
	if (isHighLighted)
	{
		lightColor = [UIColor yellowColor];
		darkColor = [UIColor yellowColor];
	}
	
	[darkColor set];

	if (timestr != nil)
	{
		CGContextSetLineWidth(ctx, 0.3);
		CGContextStrokeLineSegments(ctx, points, 2);
		
		//*Trung 08102101
		if (_is24HourFormat)
		{
			[lightColor set];
			font = [UIFont fontWithName:@"Helvetica-Bold" size:fontSize];
			[timestr drawInRect:timePaneRec withFont:font lineBreakMode:NSLineBreakByTruncatingMiddle alignment:NSTextAlignmentRight];
		}
		else
		{
			NSString *ampm = [timestr substringFromIndex: timestr.length - 2];
			NSString *s = [timestr substringToIndex:timestr.length - 2];

			if (hour != 12)
			{
				font = [UIFont fontWithName:@"Helvetica" size:fontSize-2];

				[ampm drawInRect:timePaneRec withFont:font lineBreakMode:NSLineBreakByTruncatingMiddle alignment:NSTextAlignmentRight];
				timePaneRec.size.width -= amsize.width;
			}
			else
			{
				s = timeStrings[hour];
			}
		
			[lightColor set];
		
			timePaneRec.size.width += LEFT_MARGIN;
			timePaneRec.origin.x = 0;
		
			font = [UIFont fontWithName:@"Helvetica-Bold" size:fontSize];
			[s drawInRect:timePaneRec withFont:font lineBreakMode:NSLineBreakByTruncatingMiddle alignment:NSTextAlignmentRight];
		}
		//Trung 08102101*
	}
	else
	{
		CGFloat lengths[] = {1, 1};
		CGContextSetLineWidth(ctx, 0.3);
		
		CGContextSetLineDash(ctx, 0, lengths, 2);

		CGContextStrokeLineSegments(ctx, points, 2);		
	}
}

- (TimeSlotView *) hitTestRec: (CGRect) rec
{
	CGRect frm = self.frame;
	
	frm.origin.y += (frm.size.height - 20)/2;
	frm.size.height = 20;
	
	if (CGRectIntersectsRect(frm, rec))
	{
		return self;
	}

	return nil;
}

- (void) highlight
{
	if (!isHighLighted)
	{
		isHighLighted = YES;
	
		[self setNeedsDisplay];
	}
}

- (void) unhighlight
{
	if (isHighLighted)
	{
		isHighLighted = NO;
	
		[self setNeedsDisplay];
	}
}

-(void)changeSkin
{
	[self setNeedsDisplay];
}

-(void)longPressHandler:(UILongPressGestureRecognizer *)gestureRecognizer
{
	if (gestureRecognizer.state != UIGestureRecognizerStateEnded) 
	{
        //if (_sdViewCtrler != nil)
        if (_abstractViewCtrler != nil)
        {
            //CalendarViewController *ctrler = [_sdViewCtrler getCalendarViewController];
            CalendarViewController *ctrler = [_abstractViewCtrler getCalendarViewController];
            [ctrler showQuickAdd:self.time];
        }
	}			
}

- (void)dealloc {
	self.time = nil;
	
	[super dealloc];
}

#pragma mark OS4 Support 

-(void) recover
{
	[self setNeedsDisplay];
}

+ (CGSize) calculateTimePaneSize
{
	CGFloat fontSize = 12;
	
	UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:fontSize];
	CGSize hourSize = [@"12 " sizeWithFont:font];
	
	font = [UIFont fontWithName:@"Helvetica" size:fontSize-2];
	CGSize amSize = [@"AM" sizeWithFont:font];
	
	return CGSizeMake(hourSize.width + amSize.width, hourSize.height);
	
}

@end