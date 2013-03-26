//
//  PlannerMonthCellView.m
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 3/15/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "PlannerMonthCellView.h"

@implementation PlannerMonthCellView

@synthesize day;
@synthesize month;
@synthesize year;

@synthesize hasDTask;
@synthesize hasSTask;
@synthesize isToday;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
		
		//dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, 40, 20)];
        dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 20, 0, 40, 20)];
		dayLabel.font = [UIFont systemFontOfSize:14];
		dayLabel.backgroundColor = [UIColor clearColor];
		
		[self addSubview:dayLabel];
        
        // init status
        //self.isWeekend = NO;
		//gray = NO;
		isToday = NO;
		isDot = NO;
		
		hasDTask = NO;
		hasSTask = NO;
		
		//freeRatio = 0;
        
        self.skinStyle = 1;
        
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef ctx = UIGraphicsGetCurrentContext();
    
	UIColor *darkColor = [UIColor grayColor];
	UIColor *lightColor = [UIColor whiteColor];
	UIColor *dotColor = [UIColor whiteColor];
	
	//if ([[Settings getInstance] skinStyle] == 0)
    if (self.skinStyle == 0)
	{
		//darkColor = [UIColor grayColor];
        darkColor = [UIColor lightGrayColor];
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
    
	CGRect dotFrm = CGRectMake(self.bounds.origin.x + self.bounds.size.width - 40, self.bounds.origin.y + 2 + 5, 5, 5);
	
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

- (void)setDay:(NSInteger) dayValue
{
	day = dayValue;
	
    dayLabel.text = dayValue>0?[NSString stringWithFormat:@"%d", dayValue]:@"";
}

// set dot if this day has DS Task
-(void) setDSDots:(BOOL)dTask sTask:(BOOL)sTask
{
	self.hasDTask = dTask;
	self.hasSTask = sTask;
	
	[self setNeedsDisplay];
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

// expand cell
- (void)expandDayCell {
    CGRect frm = self.frame;
    frm.size.height = self.frame.size.height + PLANNER_DAY_CELL_HEIGHT;
    self.frame = frm;
}

- (void)collapseDayCell {
}
@end
