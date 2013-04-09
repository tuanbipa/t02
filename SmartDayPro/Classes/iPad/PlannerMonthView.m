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
#import "PlannerItemView.h"
#import "TaskView.h"
#import "PlannerView.h"
#import "HighlightView.h"

extern BOOL _isiPad;

@implementation PlannerMonthView

@synthesize nWeeks;
@synthesize skinStyle;
@synthesize plannerItemsList;
@synthesize highlightView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        //self.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor colorWithRed:217.0/255 green:217.0/255 blue:217.0/255 alpha:1];
        
        todayCellIndex = -1;
        nDays = 0;
        nWeeks = 0;
        self.skinStyle = _isiPad?0:1;
		
		//CGFloat width = frame.size.width;
        CGFloat width = frame.size.width - TIMELINE_TITLE_WIDTH;
        
        CGFloat dayWidth = (width)/7;
		CGFloat cellHeight = floor((frame.size.height)/6);
		
		CGFloat ymargin = 0;
		CGFloat yoffset = 0;
		
		for (int i=0; i<42; i++)
		{
			int mod = i%7;
			
			CGFloat height = cellHeight;
			
			//BOOL isWeekend = ([[Settings getInstance] isMondayAsWeekStart] ?(mod == 5 || mod == 6):(mod == 0 || mod == 6));
            CGFloat thisWidth = dayWidth;//(mod==0 ? dayWidth+titleWidth : dayWidth);
            CGFloat x = mod*dayWidth;
            if (mod == 0) {
                thisWidth += TIMELINE_TITLE_WIDTH;
            } else {
                x += TIMELINE_TITLE_WIDTH;
            }
			
			CGRect frm = CGRectMake(x, ymargin+ yoffset, thisWidth, height);
			
			PlannerMonthCellView *cell = [[PlannerMonthCellView alloc] initWithFrame:frm];
			cell.day = -1;
			//cell.index = i;
            cell.skinStyle = self.skinStyle;
            cell.weekNumberInMonth = i/7;
            
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
        
        // init plannerItemsList
        self.plannerItemsList = [NSMutableArray array];
        
        highlightView = [[HighlightView alloc] initWithFrame:CGRectZero];
		highlightView.hidden = YES;
		[self addSubview:highlightView];
		[highlightView release];
        
        openningWeek = -1;
    }
    return self;
}

- (void)initCalendar: (NSDate *)date {
    
    [self setTitleForCells:date];
    // don't user expand button anymore
    //[self addExpandButton];
    [self refresh];
}

- (void)changeMonth: (NSDate *) date {
    [self setTitleForCells:date];
    [self refresh];
}

- (void)setTitleForCells: (NSDate *) date {
    NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
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
    
	[self updateDotFromDate:fromDate toDate:toDate];
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
    
    /*if (weeks < 6) {
        
        PlannerMonthCellView *cell = [[self subviews] objectAtIndex:42];
        
        CGFloat alterHeight = (6-weeks) * cell.frame.size.height;
        // update height
        CGRect selfFrm = self.frame;
        selfFrm.size.height = selfFrm.size.height - alterHeight;
        self.frame = selfFrm;

        // update height of supper view
        PlannerView *plannerView = (PlannerView *) self.superview;
        CGRect supperFrm = plannerView.frame;
        supperFrm.size.height = supperFrm.size.height - alterHeight;
        plannerView.frame = supperFrm;
    }*/

	self.clipsToBounds = YES;
}

// expand week when user tap on carat
- (void)expandWeek: (int) week {
    openningWeek = week;
    
    // initial last y point
    CGFloat trackY[7] = {
        0, 0, 0, 0, 0, 0, 0,
    };
    
    // init track y
    for (int i = week*7; i < (week+1)*7; i++) {
        PlannerMonthCellView *cell = [self.subviews objectAtIndex:i];
        trackY[i-week*7] = cell.frame.origin.y + cell.frame.size.height;
    }
    int originY = trackY[0];
    
    PlannerMonthCellView *firstCell = [[self subviews] objectAtIndex: week*7];
    PlannerMonthCellView *lastCell = [[self subviews] objectAtIndex: (week*7)+6];
    
    NSDate *fromDate = [firstCell getCellDate];
    NSDate *toDate = [Common dateByAddNumDay:1 toDate:[lastCell getCellDate]];
    
    // a1. get ADEs
    //TaskManager *tm = [[TaskManager alloc] init];
    TaskManager *tm = [TaskManager getInstance];
    NSMutableArray *ades = [tm getADEListFromDate: fromDate toDate: toDate];
    // a2. sort ades
    for (Task *ade in ades) {
        if ([Common compareDate:ade.startTime withDate:fromDate] == NSOrderedAscending) {
            ade.plannerStartTime = fromDate;
            ade.plannerDuration = (NSInteger)[ade.endTime timeIntervalSinceDate:ade.plannerStartTime]/60;
        } else {
            ade.plannerStartTime = ade.startTime;
            ade.plannerDuration = (NSInteger)[ade.endTime timeIntervalSinceDate:ade.startTime]/60;
        }
    }
    
    NSSortDescriptor *startTimeSorter = [[NSSortDescriptor alloc] initWithKey:@"plannerStartTime" ascending:YES];
    NSSortDescriptor *durationSorter = [[NSSortDescriptor alloc] initWithKey:@"plannerDuration"  ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects: startTimeSorter, durationSorter, nil];
    [ades sortUsingDescriptors:sortDescriptors];
    
    // a3. draw ades
    for (Task *ade in ades) {
        
        NSTimeInterval timeInterval = [ade.startTime timeIntervalSinceDate:fromDate];
        NSInteger dayIndex = 0;
        NSInteger endDayIndex = 0;
        dayIndex = timeInterval/86400;
        if(dayIndex<0)
            dayIndex = 0;
        
        if (trackY[dayIndex] >= 12*20+originY) {
            continue;
        }
        
        // calculate width
        CGFloat width = 0;
        if ([Common compareDate:ade.endTime withDate:fromDate] == NSOrderedAscending) {
            width = (7 - dayIndex) * lastCell.frame.size.width;
        } else {
            // end day index
            timeInterval = [ade.endTime timeIntervalSinceDate:fromDate];
            endDayIndex = timeInterval/86400;
            //endDayIndex = endDayIndex < 0 ? 0 : endDayIndex;
            endDayIndex = endDayIndex > 7 ? 7 : endDayIndex;
            width = (endDayIndex - dayIndex + 1) * lastCell.frame.size.width;
        }
        width = (dayIndex==0 ? width + TIMELINE_TITLE_WIDTH : width);
        
        // calculate x
        CGFloat x = firstCell.frame.origin.x + dayIndex * lastCell.frame.size.width;
        x += (dayIndex==0 ? 0 : TIMELINE_TITLE_WIDTH);
        
        PlannerItemView *item = [[PlannerItemView alloc] initWithFrame:CGRectMake(x, trackY[dayIndex], width, PLANNER_ITEM_HEIGHT)];
        
        item.task = ade;
        item.starEnable = NO;
        [item enableMove:NO];
        [self addSubview:item];
        
        [self.plannerItemsList addObject:item];
        [item release];
        
        // increment track y
        int originY = trackY[dayIndex];
        for (int i = dayIndex; i <= endDayIndex; i++) {
            trackY[i] = originY + PLANNER_ITEM_HEIGHT;
        }
    }
    
    // b1. get due tasks
    NSMutableArray *dTasks = [tm getDTaskListFromDate:fromDate toDate:toDate];
    // b2. draw due tasks
    for (Task *task in dTasks) {
        NSTimeInterval timeInterval = [task.deadline timeIntervalSinceDate:fromDate];
        NSInteger dayIndex = 0;
        dayIndex = timeInterval/86400;
        if(dayIndex<0)
            dayIndex = 0;
        
        if (trackY[dayIndex] >= 12*20+originY) {
            continue;
        }
        
        // calculate width
        CGFloat width = (dayIndex == 0 ? firstCell.frame.size.width : lastCell.frame.size.width);
        
        // calculate x
        CGFloat x = firstCell.frame.origin.x + dayIndex * lastCell.frame.size.width;
        x += (dayIndex==0 ? 0 : TIMELINE_TITLE_WIDTH);
        
        PlannerItemView *item = [[PlannerItemView alloc] initWithFrame:CGRectMake(firstCell.frame.origin.x + dayIndex * firstCell.frame.size.width, trackY[dayIndex], width, PLANNER_ITEM_HEIGHT)];
        item.task = task;
        item.starEnable = NO;
        item.listStyle = YES;
        [item enableMove:NO];
        [self addSubview:item];
        
        [self.plannerItemsList addObject:item];
        [item release];
        
        // increment track y
        trackY[dayIndex] = trackY[dayIndex] + PLANNER_ITEM_HEIGHT;
    }
    
    // c1. get notes
    NSMutableArray *notes = [tm getNoteListFromDate:fromDate toDate:toDate];
    // c2. draw notes
    for (Task *note in notes) {
        NSTimeInterval timeInterval = [note.startTime timeIntervalSinceDate:fromDate];
        NSInteger dayIndex = 0;
        dayIndex = timeInterval/86400;
        if(dayIndex<0)
            dayIndex = 0;
        
        if (trackY[dayIndex] >= 12*20+originY) {
            continue;
        }
        
        // calculate width
        CGFloat width = (dayIndex == 0 ? firstCell.frame.size.width : lastCell.frame.size.width);
        
        // calculate x
        CGFloat x = firstCell.frame.origin.x + dayIndex * lastCell.frame.size.width;
        x += (dayIndex==0 ? 0 : TIMELINE_TITLE_WIDTH);
        
        PlannerItemView *item = [[PlannerItemView alloc] initWithFrame:CGRectMake(x, trackY[dayIndex], width, PLANNER_ITEM_HEIGHT)];
        item.task = note;
        item.starEnable = NO;
        item.listStyle = YES;
        [item enableMove:NO];
        [self addSubview:item];
        
        [self.plannerItemsList addObject:item];
        [item release];
        
        // increment track y
        trackY[dayIndex] = trackY[dayIndex] + PLANNER_ITEM_HEIGHT;
    }
    
    // get max y
    int maxY = trackY[0];
    for (int i = 1; i < 7; i++) {
        if (trackY[i] > maxY) {
            maxY = trackY[i];
        }
    }
    
    int alterHeight = maxY - originY;
    if (alterHeight < PLANNER_ITEM_HEIGHT*6) {
        alterHeight = PLANNER_ITEM_HEIGHT*6;
    }
    for (int i = openningWeek*7; i < 42; i++) {
        PlannerMonthCellView *cell = [self.subviews objectAtIndex:i];
        if (i < (openningWeek+1)*7) {
            [cell expandDayCell:alterHeight];
        } else {
            CGRect frm = cell.frame;
            frm.origin.y = frm.origin.y + alterHeight;
            cell.frame = frm;
        }
    }
    
    // update height
    CGRect selfFrm = self.frame;
    selfFrm.size.height = selfFrm.size.height + alterHeight;
    self.frame = selfFrm;
    
    // update height of supper view
    PlannerView *plannerView = (PlannerView *) self.superview;
    CGRect supperFrm = plannerView.frame;
    supperFrm.size.height = supperFrm.size.height + alterHeight;
    plannerView.frame = supperFrm;
}

// return adjust height
- (void)collapseWeek {
    if (openningWeek == -1) {
        return;
    }
    
    if (self.plannerItemsList.count > 0) {
        // reset array
        for (PlannerItemView *itemView in self.plannerItemsList) {
            [itemView removeFromSuperview];
        }
        [self.plannerItemsList removeAllObjects];
    }
    
    // get adjust y
    PlannerMonthCellView *cell = [[self subviews] objectAtIndex:openningWeek*7];
    int adjustY = cell.frame.size.height - PLANNER_DAY_CELL_COLLAPSE_HEIGHT;
    
    for (int i = openningWeek*7; i < openningWeek*7 + 7; i++) {
        PlannerMonthCellView *cell = [[self subviews] objectAtIndex:i];
        // collapse cell
        [cell collapseDayCell];
    }
    
    for (int i = openningWeek*7+7; i < self.subviews.count; i++) {
        PlannerMonthCellView *cell = [[self subviews] objectAtIndex:i];
        CGRect frm = cell.frame;
        frm.origin.y = frm.origin.y - adjustY;
        cell.frame = frm;
    }
    
    openningWeek = -1;
    
    // update height
    CGRect selfFrm = self.frame;
    selfFrm.size.height = selfFrm.size.height - adjustY;
    self.frame = selfFrm;
    
    // update height of supper view
    PlannerView *plannerView = (PlannerView *) self.superview;
    CGRect supperFrm = plannerView.frame;
    supperFrm.size.height = supperFrm.size.height - adjustY;
    plannerView.frame = supperFrm;
}

- (void)addExpandButton {
    
    for (int i=0; i<42; i=i+7) {
        PlannerMonthCellView *cell = [[self subviews] objectAtIndex:i];
        
        [cell disPlayExpandButton:YES];
        
    }
}

- (void)collapseExpand: (int) week {
    BOOL isExpand = week != openningWeek;
    if (!isExpand) {
        return;
    }
    [self collapseWeek];
    
    // get first date in week
    NSDate *firstDate;
    
    if (isExpand && week != -1) {
        [self expandWeek:week];
        
        // get first date in month
        PlannerMonthCellView *cell = [[self subviews] objectAtIndex:openningWeek*7];
        firstDate = [cell getCellDate];
    } else {
        PlannerMonthCellView *cell = [[self subviews] objectAtIndex:0];
        firstDate = [cell getCellDate];
    }

    NSDictionary *aDictionary = [[[NSDictionary alloc] initWithObjectsAndKeys:
                                 firstDate, @"firstDate",
                                 nil] autorelease];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationAdjustPlannerMiniMonthHeight" object:nil userInfo:aDictionary];
}

- (void) dealloc {
    
    [super dealloc];
}

- (NSDate *)getFirstDate {
    PlannerMonthCellView *firstCell = [self.subviews objectAtIndex:0];
    return [firstCell getCellDate];
}

-(void)highlightCell:(PlannerMonthCellView *)cell
{
	highlightView.hidden = NO;
	highlightView.frame = cell.frame;
	highlightView.tag = cell;
	[highlightView setNeedsDisplay];
}

- (void)selectCell: (PlannerMonthCellView *) cell {
    
	[self collapseExpand:cell.weekNumberInMonth];
    [self highlightCell:cell];
}

- (void)highlightCellOnDate: (NSDate *) dt {
    PlannerMonthCellView *foundCell = [self findCellByDate:dt];
	
	if (foundCell)
	{
		[self highlightCell:foundCell];
	}
}

- (PlannerMonthCellView *) findCellByDate:(NSDate *)date
{
    if (date == nil)
    {
        return nil;
    }
    
	PlannerMonthCellView *ret = nil;
	
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	
	NSDateComponents *dtComps = [gregorian components:unitFlags fromDate:date];
	
	NSInteger dtMonth = [dtComps month];
	NSInteger dtYear = [dtComps year];
	NSInteger dtDay = [dtComps day];
	
	for (int i=0; i<42; i++)
	{
		PlannerMonthCellView *cell = [[self subviews] objectAtIndex:i];
		
		if (cell.month == dtMonth && cell.year == dtYear && cell.day == dtDay)
		{
			ret = cell;
			
			break;
		}
	}
	
	return ret;
}
@end
