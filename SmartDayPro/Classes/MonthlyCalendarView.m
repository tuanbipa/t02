//
//  MonthlyCalendarView.m
//  SmartTime
//
//  Created by Left Coast Logic on 12/31/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MonthlyCalendarView.h"

#import "Common.h"
#import "Settings.h"
#import "Task.h"

#import "MonthlyCellView.h"
//#import "MonthlyView.h"
#import "MonthlyADEView.h"
#import "TaskManager.h"
#import "DBManager.h"
#import "MiniMonthView.h"

#import "BusyController.h"
#import "HighlightView.h"
#import "CalendarViewController.h"

extern CalendarViewController *_sc2ViewCtrler;
extern BOOL _isiPad;

@implementation MonthlyCalendarView

@synthesize highlightView;
@synthesize skinStyle;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
		
		todayCellIndex = -1;
        nDays = 0;
        nWeeks = 0;
        self.skinStyle = _isiPad?0:1;
		
		CGFloat width = frame.size.width;
		CGFloat dayWidth = floor(width/7);
		CGFloat cellHeight = floor(frame.size.height/6);
		
		CGFloat ymargin = 0;
		CGFloat yoffset = 0;
		
		for (int i=0; i<42; i++)
		{
			int mod = i%7;
			
			CGFloat height = cellHeight;
			
			BOOL isWeekend = ([[Settings getInstance] isMondayAsWeekStart] ?(mod == 5 || mod == 6):(mod == 0 || mod == 6));
			
			CGRect frm = CGRectMake(mod*dayWidth, ymargin+ yoffset, dayWidth, height);
			
			MonthlyCellView *cell = [[MonthlyCellView alloc] initWithFrame:frm];
			cell.day = -1;
			cell.index = i;
            cell.skinStyle = self.skinStyle;
            
			if (isWeekend)
			{
				cell.isWeekend = YES;
			}
			
			if (mod == 6)
			{
				yoffset += height;
			}
			
			[self addSubview:cell];
			
			[cell release];
		}
		
		adeView = [[MonthlyADEView alloc] initWithFrame: CGRectMake(0, ymargin, frame.size.width, frame.size.height - ymargin)];
		
		[self addSubview:adeView];
		
		highlightView = [[HighlightView alloc] initWithFrame:CGRectZero];
		highlightView.hidden = YES;
		[self addSubview:highlightView];
		[highlightView release];		
    }
    return self;
}

- (void)changeWeekPlanner:(NSInteger)days weeks:(NSInteger)weeks
{
	nDays = days;
	nWeeks = weeks;
	
	BOOL weekStartOnMonday = [[Settings getInstance] isMondayAsWeekStart];
	
	CGFloat yoffset = 0;
	
	CGFloat height = _isiPad?48:40;
	CGFloat width = (nDays == 5? 64:(_isiPad?48:46));
	
	for (int i=0; i<42; i++)
	{
		int mod = i%7;
		
		MonthlyCellView *cell = [self.subviews objectAtIndex:i];
		
		CGRect frm = CGRectMake(mod*width, yoffset, width, height);		

		if (nDays == 5 && !weekStartOnMonday)
		{
			frm.origin.x -= width; //shift left 1 column to start as Monday
		}
		
		cell.frame = frm;
		
		if (mod == 6)
		{
			yoffset += height;
		}
	}
	
	CGRect frm = CGRectMake(0, 0, 7*width, 6*height);
	
	if (nDays == 5 && !weekStartOnMonday)
	{
		frm.origin.x -= width; //shift left 1 column to start as Monday
	}
	
	adeView.frame = frm;
	adeView.nameShown = YES;
	
	self.clipsToBounds = YES;
}

- (void) changeSkin
{
	for (int i=0; i<42; i++)
	{
		MonthlyCellView *cell = [[self subviews] objectAtIndex:i];
		
		[cell changeSkin];
	}		
}

-(void)highlightCell:(MonthlyCellView *)cell
{
	highlightView.hidden = NO;
	highlightView.frame = cell.frame;
	highlightView.tag = cell;
	[highlightView setNeedsDisplay];	
}

-(void)selectCell:(MonthlyCellView *)cell
{
	[self highlightCell:cell];
	
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSDateComponents *comps = [gregorian components:0xFF fromDate:[NSDate date]];
	
	[comps setYear:cell.year];
	[comps setMonth:cell.month];
	[comps setDay:cell.day];
	
	NSDate *date = [gregorian dateFromComponents:comps];
	
	UIView *parent = [self superview];
	
	/*if ([parent isKindOfClass:[MonthlyView class]])
	{
		[(MonthlyView *)parent setCalendarDate:date];
	}
	else */if ([parent isKindOfClass:[MiniMonthView class]])
	{
        /*
		if (_sc2ViewCtrler != nil)
		{
			[_sc2ViewCtrler jumpToDate:date];
		}*/
        [(MiniMonthView *)parent jumpToDate:date];
	}
}

- (MonthlyCellView *) findCellByDate:(NSDate *)date
{
    if (date == nil)
    {
        return nil;
    }
    
	MonthlyCellView *ret = nil;
	
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	
	NSDateComponents *dtComps = [gregorian components:unitFlags fromDate:date];
	
	NSInteger dtMonth = [dtComps month];
	NSInteger dtYear = [dtComps year];
	NSInteger dtDay = [dtComps day];
	
	for (int i=0; i<42; i++)
	{
		MonthlyCellView *cell = [[self subviews] objectAtIndex:i];
		
		if (cell.month == dtMonth && cell.year == dtYear && cell.day == dtDay)
		{
			ret = cell;
			
			break;
		}
	}
	
	return ret;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}

/*
-(void)showFocus: (NSString *)focus 
{
	MonthlyView *parent = (MonthlyView *)[[self superview] superview];
	
	[parent showFocus:focus];
}
*/

-(NSString *) getMonthTitle
{
	NSString* _monthNames[12] = {@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"};
	
	return [NSString stringWithFormat:@"%@ %4d", _monthNames[currentMonth-1], currentYear];
}

- (void) updateDotFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
	BOOL dTaskDot[42];
	BOOL sTaskDot[42];
	
	for (int i=0; i<42; i++)
	{
		dTaskDot[i] = NO;
		sTaskDot[i] = NO;
	}
	
	TaskManager *tm = [TaskManager getInstance];
    
	NSMutableArray *dTaskList = [tm getDTaskListFromDate:fromDate toDate:toDate];
	
	for (Task *task in dTaskList)
	{
		NSTimeInterval diff = [Common timeIntervalNoDST:task.deadline sinceDate:fromDate];
		
		NSInteger index = diff/(24*60*60);
		
		dTaskDot[index] = YES;
	}
	
    /*
	NSMutableArray *sTaskList = [tm getSTaskListFromDate:fromDate toDate:toDate];
	
	for (Task *task in sTaskList)
	{
		NSTimeInterval diff = [Common timeIntervalNoDST:task.startTime sinceDate:fromDate];
		
		NSInteger index = diff/(24*60*60);
		
		sTaskDot[index] = YES;
	}
	*/
	NSInteger firstCellIndex = 0;
	
	for (int i=0; i<42; i++)
	{
		MonthlyCellView *cell = [[self subviews] objectAtIndex:firstCellIndex+i];
		
		[cell setDSDots:dTaskDot[i] sTask:sTaskDot[i]];
		
	}
	
}

- (void) updateBusyTimeFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
	NSInteger allocTime[42];
	
	for (int i=0; i<42; i++)
	{
		allocTime[i] = 0;
	}
	
	TaskManager *tm = [TaskManager getInstance];
    
	NSMutableArray *eventList = [tm getEventListFromDate:fromDate toDate:toDate];
	
	for (Task *task in eventList)
	{
		NSTimeInterval diff = [Common timeIntervalNoDST:task.startTime sinceDate:fromDate];
		
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


- (void)showWeekCalendar:(NSDate *)date
{
	////NSLog(@"begin show week calendar");
	//NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSDateComponents *dtComps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
	NSDateComponents *todayComps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[NSDate date]];
	
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
		if (i > 0)
		{
			lastDate = [Common dateByAddNumDay:i toDate:startDate];
		}

		NSDateComponents *comps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:lastDate];
		
		MonthlyCellView *cell = [[self subviews] objectAtIndex:i];

        cell.year = comps.year;
		cell.month = comps.month;
		cell.day = comps.day;
        
        cell.freeRatio = 0;
        
		cell.gray = (cell.month != dtComps.month);
		
		if (cell.day == todayComps.day && cell.month == todayComps.month && cell.year == todayComps.year)
		{
			cell.isToday = YES;
			
			todayCellIndex = i;
		}
		
		if (cell.day == dtComps.day && cell.month == dtComps.month && cell.year == dtComps.year)
		{
			[self highlightCell:cell];
		}
	}
	
	//NSDate *fromDate = [Common clearTimeForDate:startDate];
	//NSDate *toDate = [Common getEndDate:lastDate];
    
    /*
    if (nDays > 0 && nWeeks > 0)
    {
        NSInteger days = nWeeks*nDays;
        
        toDate = [Common getEndDate:[Common dateByAddNumDay:days toDate:fromDate]];
    }
	*/
    
	//[self updateBusyTimeFromDate:fromDate toDate:toDate];
	
	//[adeView setStartDate:fromDate endDate:toDate];
    
	////NSLog(@"end show week calendar");
	//[pool release];
}

- (void) showCalendar:(NSDate *)date
{
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	
	NSDateComponents *dtComps = [gregorian components:unitFlags fromDate:date];
	
	currentMonth = dtComps.month;
	currentYear = dtComps.year;
	
	dtComps.day = 1;
	
	[self showWeekCalendar:[gregorian dateFromComponents:dtComps]];
	
	MonthlyCellView *cell = [self findCellByDate:date];
	[self selectCell:cell];
}

- (void) showNextMonth
{
	if (currentMonth == 12)
	{
		currentMonth = 1;
		currentYear += 1;
	}	
	else
	{
		currentMonth += 1;
	}
	
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	
	NSDateComponents *dtComps = [gregorian components:unitFlags fromDate:[NSDate date]];
	
	dtComps.year = currentYear;
	dtComps.month = currentMonth;
	dtComps.day = 1;
	
	NSDate *firstDate = [gregorian dateFromComponents:dtComps];
	
	[self showWeekCalendar:firstDate];
	
}

- (void) showPreviousMonth
{
	if (currentMonth == 1)
	{
		currentMonth = 12;
		currentYear -= 1;
	}
	else
	{
		currentMonth -= 1;
	}
	
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	
	NSDateComponents *dtComps = [gregorian components:unitFlags fromDate:[NSDate date]];
	
	dtComps.year = currentYear;
	dtComps.month = currentMonth;
	dtComps.day = 1;
	
	NSDate *firstDate = [gregorian dateFromComponents:dtComps];
	
	[self showWeekCalendar:firstDate];
}

- (void) refreshADEView
{
	MonthlyCellView *cell = [[self subviews] objectAtIndex:0];
	
	NSDate *fromDate = [cell getCellDate];
	
	cell = [[self subviews] objectAtIndex:41];
	
	NSDate *toDate = [cell getCellDate];

    /*
    if (nDays > 0 && nWeeks > 0)
    {
        NSInteger days = nWeeks*nDays;
        
        toDate = [Common getEndDate:[Common dateByAddNumDay:days toDate:fromDate]];
    }*/   
    
    [adeView setStartDate:fromDate endDate:toDate];
}

/*
- (void) refreshDot
{
	MonthlyCellView *cell = [[self subviews] objectAtIndex:0];
	
	NSDate *fromDate = [cell getCellDate];
	
	cell = [[self subviews] objectAtIndex:41];
	
	NSDate *toDate = [cell getCellDate];
    
    [self updateDotFromDate:fromDate toDate:toDate];
}
*/

- (void) refreshCellByDate:(NSDate *)date
{
	MonthlyCellView *cell = [self findCellByDate:date];
	
	if (cell != nil)
	{
		////NSLog(@"refresh cell on date: %@", [date description]);
		
		TaskManager *tm = [TaskManager getInstance];

		NSMutableArray *eventList = [tm getEventListOnDate:date];
		
		NSInteger allocTime = 0;
		
		for (Task *task in eventList)
		{
			allocTime += [Common timeIntervalNoDST:task.endTime sinceDate:task.startTime];
		}
		
		NSMutableArray *dTaskList = [tm getDTaskListOnDate:date];
		
		BOOL hasDTask = (dTaskList.count > 0);
		
        /*
		NSMutableArray *sTaskList = [tm getSTaskListOnDate:date];
		
		BOOL hasSTask = (sTaskList.count > 0);
        */
        
        BOOL hasSTask = NO;

		[cell setDSDots:hasDTask sTask:hasSTask];
        		
		CGFloat ratio = (CGFloat) allocTime/(24*3600);
		
		cell.freeRatio = (allocTime == 0?0:ratio);			
	}
}

//- (void) refreshAllCells
- (void) refresh
{
	//////NSLog(@"begin refresh all cells");
    MonthlyCellView *firstCell = [[self subviews] objectAtIndex:0];
    MonthlyCellView *lastCell = [[self subviews] objectAtIndex:7*nWeeks-1];
    
    NSDate *fromDate = [firstCell getCellDate];
    NSDate *toDate = [Common dateByAddNumDay:1 toDate:[lastCell getCellDate]];
    
	[self updateBusyTimeFromDate:fromDate toDate:toDate];
	[self updateDotFromDate:fromDate toDate:toDate];
	[adeView setStartDate:fromDate endDate:toDate];
	
	//////NSLog(@"end refresh all cells");
}

- (void)refreshBackground
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    /*
    MonthlyCellView *firstCell = [[self subviews] objectAtIndex:0];
    MonthlyCellView *lastCell = [[self subviews] objectAtIndex:7*nWeeks-1];
    
    NSDate *fromDate = [firstCell getCellDate];
    NSDate *toDate = [Common dateByAddNumDay:1 toDate:[lastCell getCellDate]];
    
	[self updateBusyTimeFromDate:fromDate toDate:toDate];
	
	[adeView setStartDate:fromDate endDate:toDate];
    
    [self refreshDot];
    */
    
    [self refresh];
    
    [[BusyController getInstance] setBusy:NO withCode:BUSY_WEEKPLANNER_INIT_CALENDAR];
    
    [[TaskManager getInstance] initMiniMonth:NO];
    
    [pool release];
}

- (void) showDot
{
	if (highlightView.tag != -1 && !highlightView.hidden)
	{
		MonthlyCellView *cell = (MonthlyCellView *)highlightView.tag;
		
		cell.isDot = YES;
	}
}

- (void) refreshCalendar:(NSDate *)date
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	if (![self checkDateInCalendar:date])
	{
		[self showWeekCalendar:date];
		
		//[self refreshDot];
	}
	
	[self highlightCellOnDate:date];
    
	if ([self.superview isKindOfClass:[MiniMonthView class]])
	{
		MiniMonthView *plannerView = (MiniMonthView *) self.superview;
		
		[plannerView finishInitCalendar];
	}    
	
	[pool release];
}

- (void) initCalendar:(NSDate *)date
{
	////NSLog(@"begin MonthView initCalendar");
	
	//NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	//[self showWeekCalendar:date];
	
	//[self refreshDot];
	
    [self showWeekCalendar:date];
    
	[self highlightCellOnDate:date];
		
	if ([self.superview isKindOfClass:[MiniMonthView class]])
	{
		MiniMonthView *plannerView = (MiniMonthView *) self.superview;
		
		[plannerView finishInitCalendar];
	}
    
    if (![[BusyController getInstance] checkMMBusy])
    {
        [[BusyController getInstance] setBusy:YES withCode:BUSY_WEEKPLANNER_INIT_CALENDAR];
        
        [self performSelectorInBackground:@selector(refreshBackground) withObject:nil];
    }
        
	
	//[[BusyController getInstance] setBusy:NO withCode:BUSY_WEEKPLANNER_INIT_CALENDAR];
	
	//[pool release];
	
	////NSLog(@"end MonthView initCalendar");
	
}

- (void) highlightCellOnDate:(NSDate *)date
{
	MonthlyCellView *foundCell = [self findCellByDate:date];
	
	if (foundCell)
	{
		[self highlightCell:foundCell];
	}	
}

- (void) highlightCellAtPoint:(CGPoint) point
{
	MonthlyCellView *foundCell = nil;
	
	for (int i=0; i<42; i++)
	{
		MonthlyCellView *cell = [self.subviews objectAtIndex:i];
		
		if (CGRectContainsPoint(cell.frame, point))
		{
			foundCell = cell;
			break;
		}
	}

	if (foundCell)
	{
		[self highlightCell:foundCell];
	}
}

- (void) unhighlight
{
	highlightView.hidden = YES;
}

- (NSDate *)getSelectedDate
{
	NSDate *ret = nil;
	
	if (!highlightView.hidden)
	{
		MonthlyCellView *cell = (MonthlyCellView *)highlightView.tag;
		
		NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
		
		NSDate *today = [NSDate date];
		
		NSDateComponents *comps = [gregorian components:0xFF fromDate:today]; //today
		
		[comps setYear:cell.year];
		[comps setMonth:cell.month];
		[comps setDay:cell.day];
		
		ret = [gregorian dateFromComponents:comps];
	}
	
	return ret;
}

- (BOOL) checkDateInCalendar:(NSDate *)date
{
	MonthlyCellView *firstCell = [self.subviews objectAtIndex:0];
	MonthlyCellView *lastCell = [self.subviews objectAtIndex:34];
	
	NSDate *firstDate = [firstCell getCellDate];
	NSDate *lastDate = [lastCell getCellDate];

	if ([Common compareDateNoTime:firstDate withDate:date] != NSOrderedDescending &&
		[Common compareDateNoTime:lastDate withDate:date] != NSOrderedAscending)
	{
		return YES;
	}
	
	return NO;
}

- (NSDate *) getFirstDate
{
    MonthlyCellView *firstCell = [self.subviews objectAtIndex:0];
    
    return [firstCell getCellDate];
}

- (NSDate *) getLastDate
{
    return [Common getEndDate:[Common dateByAddNumDay:7*nWeeks-1 toDate:[self getFirstDate]]];
}

- (void)dealloc {
	
	[adeView release];
	
    [super dealloc];
}


@end
