//
//  PlannerMonthView.m
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 3/14/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "PlannerMonthView.h"
#import "Common.h"
#import "Settings.h"
#import "PlannerMonthCellView.h"
#import "TaskManager.h"
#import "Task.h"

extern BOOL _isiPad;

@implementation PlannerMonthView

@synthesize skinStyle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
			
			PlannerMonthCellView *cell = [[PlannerMonthCellView alloc] initWithFrame:frm];
			cell.day = -1;
			//cell.index = i;
            cell.skinStyle = self.skinStyle;
            
			/*if (isWeekend)
			{
				cell.isWeekend = YES;
			}*/
			
			if (mod == 6)
			{
				yoffset += height;
			}
			
			[self addSubview:cell];
			
			[cell release];
		}
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)initCalendar: (NSDate *)date {
    [self setTitleForCells:date];
    [self refresh];
}

- (void)setTitleForCells: (NSDate *) date {
    NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	//NSDateComponents *dtComps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
	NSDateComponents *todayComps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[NSDate date]];
	
	BOOL mondayAsWeekStart = [[Settings getInstance] isMondayAsWeekStart];
	
	NSDate *startDate = [Common getFirstWeekDate:date mondayAsWeekStart:mondayAsWeekStart];
	
	if (todayCellIndex != -1)
	{
		PlannerMonthCellView *cell = [[self subviews] objectAtIndex:todayCellIndex];
		
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
		
		PlannerMonthCellView *cell = [[self subviews] objectAtIndex:i];
        
        cell.year = comps.year;
		cell.month = comps.month;
		cell.day = comps.day;
        
        //cell.freeRatio = 0;
        
		//cell.gray = (cell.month != dtComps.month);
		
		if (cell.day == todayComps.day && cell.month == todayComps.month && cell.year == todayComps.year)
		{
			cell.isToday = YES;
			
			todayCellIndex = i;
		}
		
		/*if (cell.day == dtComps.day && cell.month == dtComps.month && cell.year == dtComps.year)
         {
         [self highlightCell:cell];
         }*/
	}
}

- (void) updateDotFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate {
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
	
	NSInteger firstCellIndex = 0;
	
	for (int i=0; i<42; i++)
	{
		PlannerMonthCellView *cell = [[self subviews] objectAtIndex:firstCellIndex+i];
		
		[cell setDSDots:dTaskDot[i] sTask:sTaskDot[i]];
		
	}
}

- (void) refresh
{
	//////NSLog(@"begin refresh all cells");
    PlannerMonthCellView *firstCell = [[self subviews] objectAtIndex:0];
    PlannerMonthCellView *lastCell = [[self subviews] objectAtIndex:7*nWeeks-1];
    
    NSDate *fromDate = [firstCell getCellDate];
    NSDate *toDate = [Common dateByAddNumDay:1 toDate:[lastCell getCellDate]];
    
	//[self updateBusyTimeFromDate:fromDate toDate:toDate];
	[self updateDotFromDate:fromDate toDate:toDate];
	//[adeView setStartDate:fromDate endDate:toDate];
	
	//////NSLog(@"end refresh all cells");
}

- (void)changeWeekPlanner:(NSInteger)days weeks:(NSInteger)weeks
{
	nDays = days;
	nWeeks = weeks;
	
	/*BOOL weekStartOnMonday = [[Settings getInstance] isMondayAsWeekStart];
	
	CGFloat yoffset = 0;
	
	CGFloat height = _isiPad?48:40;
	CGFloat width = (nDays == 5? 64:(_isiPad?48:46));
	
	for (int i=0; i<42; i++)
	{
		int mod = i%7;
		
		PlannerMonthCellView *cell = [self.subviews objectAtIndex:i];
		
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
	}*/
	
	//adeView.frame = frm;
	//adeView.nameShown = YES;
	
	self.clipsToBounds = YES;
}
@end
