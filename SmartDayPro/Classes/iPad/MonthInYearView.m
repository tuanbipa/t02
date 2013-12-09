//
//  MonthInYearView.m
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 4/22/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "MonthInYearView.h"
#import "Settings.h"
#import "MonthlyCellView.h"
#import "TaskManager.h"
#import "Common.h"
#import "Task.h"
#import "PlannerViewController.h"
#import "PlannerView.h"

@implementation MonthInYearView

@synthesize monthDate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        //self.backgroundColor = [UIColor blueColor];
        
        CGRect contentRect = CGRectMake(5, 5, frame.size.width - 10, frame.size.height - 10);
        
        // drawing day cells
        CGFloat headerWidth = 52;
        CGFloat dayHeight = (contentRect.size.height-headerWidth)/6;
        CGFloat dayWidth = contentRect.size.width/7;
        CGFloat xOffset = contentRect.origin.x;
        CGFloat x = xOffset;
        CGFloat y = contentRect.origin.y + headerWidth;
        for (int i=0; i<42; i++) {
            CGRect dayFrm = CGRectMake(x, y, dayWidth, dayHeight);
            
            MonthlyCellView *cell = [[MonthlyCellView alloc] initWithFrame:dayFrm];
            cell.day = -1;
            cell.index = i;
            cell.skinStyle = 0;
            
            [self addSubview:cell];
            [cell release];
            
            x += dayWidth;
            //x = cell.frame.origin.x + cell.frame.size.width;
            if ((i+1)%7 == 0) {
                y += dayHeight;
                x = xOffset;
            }
        }
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
    [monthDate release];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGRect contentRect = CGRectMake(rect.origin.x + 5, rect.origin.y + 5, rect.size.width - 10, rect.size.height - 10);
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [self drawMonthTitle:contentRect context:ctx];
}

- (void)drawMonthTitle: (CGRect)rect context:(CGContextRef) ctx {
    // set boder
    [[UIColor lightGrayColor] set];
	CGContextSetLineWidth(ctx, 1);
	CGContextStrokeRect(ctx, rect);
    
    // drawing month title
    UIFont *font = [UIFont systemFontOfSize:16];
    NSString *title = [Common getFullMonthYearString:self.monthDate];
    
    
    // background title
    CGRect monRec = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, 30);
    [[UIColor lightGrayColor] set];
    CGContextFillRect(ctx, monRec);
    
    // title
    [[UIColor blackColor] set];
    CGFloat yOffset = (monRec.size.height - font.pointSize) / 2.0;
    CGRect textRect = CGRectMake(monRec.origin.x, yOffset, monRec.size.width, font.pointSize);
    [title drawInRect:textRect withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
    // end drawing month title
    
    // drawing day header
    NSString* _dayNamesMon[7] = {_monText, _tueText, _wedText, _thuText, _friText, _satText, _sunText};
	NSString* _dayNamesSun[7] = {_sunText, _monText, _tueText, _wedText, _thuText, _friText, _satText};
    
    BOOL weekStartOnMonday = [[Settings getInstance] isMondayAsWeekStart];
    font = [UIFont systemFontOfSize:12];
    
    CGRect dayRec = rect;
    dayRec.origin.y += monRec.size.height;
	dayRec.size.width /= 7;
    dayRec.size.height = 22;
    
    yOffset = (dayRec.size.height - font.pointSize) / 2.0;
    textRect = CGRectMake(dayRec.origin.x, dayRec.origin.y + yOffset, dayRec.size.width, font.pointSize);
    
    for (int i=0; i<7; i++)
	{
		NSString *dayName = weekStartOnMonday?_dayNamesMon[i]:_dayNamesSun[i];
		
        textRect.origin.x = rect.origin.x + i*textRect.size.width;
		
		[[UIColor darkGrayColor] set];
        [dayName drawInRect:textRect withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
	}
}

- (void)showWeekCalendar:(NSDate *)date
{
	
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSDateComponents *dtComps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
	NSDateComponents *todayComps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[NSDate date]];
    
    BOOL checkToday = (dtComps.month == todayComps.month && dtComps.year == todayComps.year);
	
	BOOL mondayAsWeekStart = [[Settings getInstance] isMondayAsWeekStart];
	
	NSDate *startDate = [Common getFirstWeekDate:date mondayAsWeekStart:mondayAsWeekStart];
	
	if (todayCellIndex != -1)
	{
		MonthlyCellView *cell = [[self subviews] objectAtIndex:todayCellIndex];
		
		cell.isToday = NO;
		
		todayCellIndex = -1;
	}
	
	NSDate *lastDate = startDate;
	
	for (int i=0; i<42; i++)
	{
		/*if (i > 0)
		{
			lastDate = [Common dateByAddNumDay:i toDate:startDate];
		}*/
        
		NSDateComponents *comps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:lastDate];
		
		MonthlyCellView *cell = [[self subviews] objectAtIndex:i];
        
        cell.year = comps.year;
		cell.month = comps.month;
		cell.day = comps.day;
        
        cell.freeRatio = 0;
        
		cell.gray = (cell.month != dtComps.month);
		
		if (checkToday && cell.day == todayComps.day && cell.month == todayComps.month)
		{
			cell.isToday = YES;
			
			todayCellIndex = i;
		}
        
        lastDate = [Common dateByAddNumDay:i+1 toDate:startDate];
	}
}

- (void) initCalendar//:(NSDate *)date
{
    [self showWeekCalendar:self.monthDate];
}

- (void) refresh
{
	//[self performSelectorInBackground:@selector(updateBusyTimeFromDate) withObject:nil];
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    
    dispatch_async(backgroundQueue, ^{
        [self updateBusyTimeFromDate];
    });
}

- (void) updateBusyTimeFromDate//:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    MonthlyCellView *cell = [[self subviews] objectAtIndex:7];
    NSDate *fromDate = [Common getFirstMonthDate:[cell getCellDate]];
    NSDate *toDate = [Common getEndMonthDate:fromDate withMonths:1];
    
	NSInteger allocTime[42];
	
	for (int i=0; i<42; i++)
	{
		allocTime[i] = 0;
	}
	
	TaskManager *tm = [TaskManager getInstance];
    
    MonthlyCellView *firstCell = [[self subviews] objectAtIndex:0];
    NSDate *firstDate = [firstCell getCellDate];
    
	NSMutableArray *eventList = [tm getEventListFromDate:fromDate toDate:toDate];
	
	for (Task *task in eventList)
	{
		NSTimeInterval diff = [Common timeIntervalNoDST:task.startTime sinceDate:firstDate];
		
		NSInteger index = diff/(24*60*60);
		
		allocTime[index] = allocTime[index] + [Common timeIntervalNoDST:task.endTime sinceDate:task.startTime];
	}
	
	NSInteger firstCellIndex = 0;
	
	for (int i=0; i<42; i++)
	{
		MonthlyCellView *cell = [[self subviews] objectAtIndex:firstCellIndex+i];
		
		CGFloat ratio = (CGFloat) allocTime[i]/(24*3600);
		
		if (allocTime[i] == 0)
		{
			ratio = 0;
		}
		
		cell.freeRatio = ratio;
	}
}

- (void)selectCell: (MonthlyCellView *) cell {
    //[_plannerViewCtrler.popoverCtrler dismissPopoverAnimated:NO];
    //[_plannerViewCtrler.plannerView goToDate:[cell getCellDate]];
    PlannerViewController *ctrler = (PlannerViewController*)[AbstractActionViewController getInstance];
    [ctrler.popoverCtrler dismissPopoverAnimated:NO];
    [ctrler.plannerView goToDate:[cell getCellDate]];
}

#pragma mark Properties

- (void)setMonthDate:(NSDate *)_monthDate {
    [_monthDate retain];
    [monthDate release];
    monthDate = _monthDate;
    [self setNeedsDisplay];
    
}
@end
