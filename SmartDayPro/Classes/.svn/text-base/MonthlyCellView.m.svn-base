//
//  MonthlyCellView.m
//  SmartTime
//
//  Created by Left Coast Logic on 12/31/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MonthlyCellView.h"
#import "TaskManager.h"
#import "Settings.h"

//extern TaskManager *taskmanager;
//extern BOOL _startDayAsMonday;

@implementation MonthlyCellView

@synthesize day;
@synthesize month;
@synthesize year;

@synthesize index;
//@synthesize selected;
@synthesize gray;
@synthesize isWeekend;
@synthesize isToday;
@synthesize isDot;

@synthesize hasDTask;
@synthesize hasSTask;


@synthesize freeRatio;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		
		dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, 40, 20)];
		dayLabel.font = [UIFont systemFontOfSize:14];
		dayLabel.backgroundColor = [UIColor clearColor];
		
		[self addSubview:dayLabel];
		
		//self.selected = NO;
		self.isWeekend = NO;
		gray = NO;
		isToday = NO;
		isDot = NO;
		
		hasDTask = NO;
		hasSTask = NO;
		
		freeRatio = 0;		
    }
    return self;
}

-(void)changeBusyColor
{
	UIColor *color = [UIColor blackColor];
	
	if ([[Settings getInstance] skinStyle] == 0)
	{
		if (freeRatio == 0)
		{
			color = [UIColor colorWithRed:196.0/255 green:191.0/255 blue:204.0/255 alpha:1];
		}
		else if (freeRatio <= 0.25)
		{
			color = [UIColor colorWithRed:176.0/255 green:171.0/255 blue:184.0/255 alpha:1];
		}
		else if (freeRatio <= 0.5)
		{
			color = [UIColor colorWithRed:156.0/255 green:151.0/255 blue:164.0/255 alpha:1];
		}
		else if (freeRatio <= 0.75)
		{
			color = [UIColor colorWithRed:136.0/255 green:131.0/255 blue:144.0/255 alpha:1];
		}
		else
		{
			color = [UIColor colorWithRed:116.0/255 green:111.0/255 blue:124.0/255 alpha:1];
		}		
	}
	else
	{
		if (freeRatio == 0)
		{
			color = [UIColor colorWithRed:100.0/255 green:100.0/255 blue:100.0/255 alpha:1];				
		}
		else if (freeRatio <= 0.25)
		{
			color = [UIColor colorWithRed:80.0/255 green:80.0/255 blue:80.0/255 alpha:1];
		}
		else if (freeRatio <= 0.5)
		{
			color = [UIColor colorWithRed:60.0/255 green:60.0/255 blue:60.0/255 alpha:1];				
		}
		else if (freeRatio <= 0.75)
		{
			color = [UIColor colorWithRed:40.0/255 green:40.0/255 blue:40.0/255 alpha:1];
		}
		else
		{	
			color = [UIColor colorWithRed:20.0/255 green:20.0/255 blue:20.0/255 alpha:1];
		}
	}
	
	self.backgroundColor = color;
	
}

-(void)setFreeRatio:(CGFloat)ratio
{
	freeRatio = ratio;
	
	[self changeBusyColor];
	
}

-(void)setIsToday:(BOOL) isTodayVal
{
	isToday = isTodayVal;
	
	[self setNeedsDisplay];
}

-(void)setIsDot:(BOOL) isDotVal
{
	isDot = isDotVal;
	
	[self setNeedsDisplay];
}

-(void) setDSDots:(BOOL)dTask sTask:(BOOL)sTask
{
	self.hasDTask = dTask;
	self.hasSTask = sTask;
	
	[self setNeedsDisplay];
}

- (void) changeDayColor
{
	if (gray)
	{
		if ([[Settings getInstance] skinStyle] == 0)
		{
			dayLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
		}
		else
		{
			dayLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
		}			
	}
	else
	{
		if ([[Settings getInstance] skinStyle] == 0)
		{
			dayLabel.textColor = [UIColor blackColor];
		}
		else
		{
			dayLabel.textColor = [UIColor whiteColor];				
		}			
	}	
}

-(void)setGray:(BOOL) isGray
{
	gray = isGray;
	
	[self changeDayColor];
	
}

/*
- (void) select
{
	selected = !selected;
	
	MonthlyCalendarView *parent = [self superview];
	//[parent selectCell:self.index];
	[parent selectCell:self];
}

-(void)setSelected:(BOOL) isSelected
{
	if (selected != isSelected)
	{
		selected = isSelected;
	}
}
*/

-(void)setDay:(NSInteger) dayValue
{
	day = dayValue;
	
	//dayLabel.text = dayValue>0?[NSString stringWithFormat:(self.index==0?@"%d/%d":@"%d"), dayValue, month]:@"";
    dayLabel.text = dayValue>0?[NSString stringWithFormat:@"%d", dayValue]:@"";
}

- (BOOL)checkToday
{
	NSDate *date = [NSDate date];
	
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;			
	
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:date];
	
	if (day == comps.day && month == comps.month && year == comps.year)
	{
		return YES;
	}
	
	return NO;
}

- (NSDate *)getCellDate
{
	NSDate *date = [NSDate date];
	
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;			
	
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:date];

	comps.year = year;
	comps.month = month;
	comps.day = day;
	
	comps.hour = 0;
	comps.minute = 0;
	comps.second = 0;
	
	date = [gregorian dateFromComponents:comps];
	
	return date;
}

- (void) changeSkin
{
	[self changeDayColor];
	[self changeBusyColor];
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
	CGContextRef ctx = UIGraphicsGetCurrentContext();

	UIColor *darkColor = [UIColor grayColor];
	UIColor *lightColor = [UIColor whiteColor];
	UIColor *dotColor = [UIColor whiteColor];
	
	if ([[Settings getInstance] skinStyle] == 0)
	{
		darkColor = [UIColor grayColor];
		lightColor = [UIColor whiteColor];
		dotColor = [UIColor blackColor];
	}
	else
	{
		darkColor = [UIColor darkGrayColor];
		lightColor = [UIColor lightGrayColor];
		dotColor = [UIColor whiteColor];
	}			
	
	[darkColor set];
	
	CGContextSetLineWidth(ctx, 1);	
	CGContextStrokeRect(ctx, self.bounds);	
	
	[lightColor set];
	
	CGContextSetLineWidth(ctx, 0.5);
	
	CGContextMoveToPoint(ctx,  self.bounds.origin.x,  self.bounds.origin.y + 0.5);
	CGContextAddLineToPoint( ctx,  self.bounds.origin.x + self.bounds.size.width, self.bounds.origin.y + 0.5);
	CGContextStrokePath(ctx);
	
	CGContextMoveToPoint(ctx, self.bounds.origin.x + self.bounds.size.width - 0.5, self.bounds.origin.y);	
	CGContextAddLineToPoint( ctx, self.bounds.origin.x + self.bounds.size.width - 0.5, self.bounds.origin.y + self.bounds.size.height);
	CGContextStrokePath(ctx);
	
	if (self.isToday)
	{
		CGContextSetLineWidth(ctx, 2);
		
		[[UIColor colorWithRed:(CGFloat)90/255 green:(CGFloat)111/255 blue:(CGFloat)140/255 alpha:1] set];
		
		CGContextStrokeRect(ctx, CGRectMake(self.bounds.origin.x + 1, self.bounds.origin.y + 1, self.bounds.size.width - 2, self.bounds.size.height - 2));
	}

	CGRect dotFrm = CGRectMake(self.bounds.origin.x + self.bounds.size.width - 10, self.bounds.origin.y + 2 + 5, 5, 5);
	
	if (self.hasSTask)
	{
		[[UIColor greenColor] setFill];
		
		CGContextFillEllipseInRect(ctx, dotFrm);
		
		dotFrm = CGRectOffset(dotFrm, -10, 0);
	}
	
	if (self.hasDTask)
	{
		[[UIColor redColor] setFill];
		
		CGContextFillEllipseInRect(ctx, dotFrm);
	}
	
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	MonthlyCalendarView *parent = (MonthlyCalendarView *)[self superview];
	[parent selectCell:self];
	
}

- (void)dealloc {
	[dayLabel release];
	
    [super dealloc];
}


@end
