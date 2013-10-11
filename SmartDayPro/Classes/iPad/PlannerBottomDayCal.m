//
//  PlannerBottomDayCal.m
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 3/18/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "PlannerBottomDayCal.h"
#import "ContentScrollView.h"
#import "PlannerScheduleView.h"
#import "PlannerCalendarLayoutController.h"
#import "TaskView.h"
#import "Task.h"
#import "CalendarPlannerMovableController.h"
#import "TaskOutlineView.h"
#import "Common.h"
#import "TaskManager.h"
#import "TimeSlotView.h"
#import "PlannerViewController.h"
#import "PlannerView.h"
#import "PlannerMonthView.h"
#import "HPGrowingTextView.h"
#import "Common.h"
#import "Settings.h"

#import "TaskLinkManager.h"

extern PlannerViewController *_plannerViewCtrler;

@implementation PlannerBottomDayCal

@synthesize movableController;
@synthesize plannerScheduleView;

@synthesize calendarLayoutController;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        //self.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor colorWithRed:237 green:237 blue:237 alpha:1.0];
        
        // add scroll view
        scrollView = [[ContentScrollView alloc] initWithFrame:self.bounds];
        scrollView.canCancelContentTouches = NO;
        scrollView.backgroundColor = [UIColor clearColor];
        //scrollView.delegate = calendarLayoutController;
        [self addSubview:scrollView];
        [scrollView release];
        
        plannerScheduleView = [[PlannerScheduleView alloc] initWithFrame:scrollView.bounds];
        //plannerScheduleView = [[PlannerScheduleView alloc] initWithFrame:CGRectOffset(scrollView.bounds, scrollView.bounds.size.width, 0)];
        [scrollView addSubview:plannerScheduleView];
        [plannerScheduleView release];
        
        calendarLayoutController = [[PlannerCalendarLayoutController alloc] init];
        // add movable controller
        movableController = [[CalendarPlannerMovableController alloc] init];
        calendarLayoutController.movableController = movableController;
        
        calendarLayoutController.viewContainer = scrollView;
        TaskManager *tm = [TaskManager getInstance];
        
        scrollView.contentSize = CGSizeMake(plannerScheduleView.frame.size.width, plannerScheduleView.frame.size.height);
        //scrollView.contentOffset = CGPointMake(self.bounds.size.width, 0);
        scrollView.scrollEnabled = YES;
        scrollView.scrollsToTop = NO;
        scrollView.showsHorizontalScrollIndicator = YES;
        scrollView.showsVerticalScrollIndicator = YES;
        scrollView.directionalLockEnabled = YES;
        
        // outline for resizing event
        outlineView = [[TaskOutlineView alloc] initWithFrame:CGRectZero];
        [self addSubview:outlineView];
        [outlineView release];
        
        // init quick-add-event view
        CGFloat dayWidth = (self.bounds.size.width - TIMELINE_TITLE_WIDTH)/7;
        
        quickAddBackgroundView = [[TaskView alloc] initWithFrame:CGRectMake(0, 0, dayWidth, 2*TIME_SLOT_HEIGHT)];
        quickAddBackgroundView.task = tm.eventDummy;
        [self addSubview:quickAddBackgroundView];
        [quickAddBackgroundView release];
        quickAddBackgroundView.hidden = YES;
        
        CGRect frm = quickAddBackgroundView.bounds;
        frm.origin.x += 15;
        frm.size.width -= 15;
        
        quickAddTextView = [[HPGrowingTextView alloc] initWithFrame:frm];
        quickAddTextView.delegate = self;
        quickAddTextView.backgroundColor = [UIColor clearColor];
        
        quickAddTextView.minNumberOfLines = 1;
        quickAddTextView.maxNumberOfLines = 2;
        quickAddTextView.contentInset = UIEdgeInsetsZero;
        quickAddTextView.returnKeyType = UIReturnKeyDone; //just as an example
        quickAddTextView.font = [UIFont boldSystemFontOfSize:12];
        quickAddTextView.textColor = [UIColor whiteColor];
        
        [quickAddBackgroundView addSubview:quickAddTextView];
        [quickAddTextView release];
    }
    return self;
}

- (void)changeWeek: (NSDate*) startDate {
    [self stopResize];
    
    [UIView beginAnimations:@"resize_animation" context:NULL];
    [UIView setAnimationDuration:0.3];

    [self updateFrame];
    
    // reload week view
    calendarLayoutController.startDate = startDate;
    [calendarLayoutController layout];
    
    // show/hide today line
    [self refeshTodayLine:startDate];
    [self scrollToCurrentTimeAnimated:YES];
    
    [UIView commitAnimations];
}

- (void)refeshTodayLine: (NSDate *) startDate {
    NSDate *today = [NSDate date];
    NSDate *endWeek = [Common dateByAddNumDay:7 toDate:startDate];
    if ([Common compareDate:today withDate:startDate] == NSOrderedDescending && [Common compareDate:today withDate:endWeek] == NSOrderedAscending) {
        plannerScheduleView.todayLineHidden = NO;
        [plannerScheduleView refreshTodayLine];
    } else {
        plannerScheduleView.todayLineHidden = YES;
    }
}

- (void)updateFrame {
    scrollView.frame = self.bounds;
    scrollView.contentSize = CGSizeMake(plannerScheduleView.frame.size.width, plannerScheduleView.frame.size.height);
}

- (void) refreshLayout
{
    [calendarLayoutController layout];
}

- (void) refreshTaskView4Key:(NSInteger)taskKey
{
	for (UIView *view in scrollView.subviews)
	{
		if ([view isKindOfClass:[TaskView class]])
		{
            TaskView *taskView = (TaskView *) view;
            
            Task *task = taskView.task;
            
            if (task.original != nil && ![task isREException])
            {
                task = task.original;
            }
            
            if (task.primaryKey == taskKey)
            {
                [taskView setNeedsDisplay];
                
                break;
            }
		}
	}
}

- (void)dealloc {
    [movableController release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void) setMovableContentView:(UIView *)contentView
{
    if ([movableController isKindOfClass:[DummyMovableController class]])
    {
        ((DummyMovableController *) movableController).contentView = contentView;
    }
}

- (void)scrollToCurrentTimeAnimated: (BOOL) animate{
    CGRect frm = [plannerScheduleView getTodayLineCGRect];
    if (frm.origin.y - self.frame.size.height/2 > 0) {
        frm.origin.y -= self.frame.size.height/2;
    }
    
    //[scrollView scrollRectToVisible:frm animated:animate];
    scrollView.contentOffset = frm.origin;
}

#pragma mark resizing handle

- (void)beginResize:(TaskView *)view
{
    outlineView.tag = view.task;
	
	CGRect frm = view.frame;
	
	frm.origin = [view.superview convertPoint:frm.origin toView:self];
	
	[outlineView changeFrame:frm];
	
	outlineView.hidden = NO;
	
	scrollView.scrollEnabled = NO;
	scrollView.userInteractionEnabled = NO;
}

- (void)finishResize
{
	Task *task = (Task *)outlineView.tag;
	
	int segments = [outlineView getResizedSegments];
	
	if (segments != 0 && outlineView.handleFlag != 0)
	{
		//if ([task isEvent])
		{
			if (outlineView.handleFlag == 1)
			{
				task.startTime = [Common dateByAddNumSecond:-segments*15*60 toDate:task.startTime];
			}
			else if (outlineView.handleFlag == 2)
			{
				task.endTime = [Common dateByAddNumSecond:segments*15*60 toDate:task.endTime];
			}
		}
        
		[[TaskManager getInstance] resizeTask:task];
        
        [calendarLayoutController layout];
	}
    
	[self stopResize];
}

- (void) stopResize
{
	outlineView.hidden = YES;
	
	scrollView.scrollEnabled = YES;
	scrollView.userInteractionEnabled = YES;
}


#pragma mark quick add event

-(void)showQuickAdd:(TimeSlotView *)timeSlot sender: (UILongPressGestureRecognizer *)sender
{
    // collapse current week
    if (_plannerViewCtrler != nil) {
        [_plannerViewCtrler.plannerView.monthView collapseCurrentWeek];
        NSDate *dt = [_plannerViewCtrler.plannerView.monthView getSelectedDate];
        [_plannerViewCtrler.plannerView.monthView highlightCellOnDate:dt];
    }
    
    scrollView.scrollEnabled = NO;
	scrollView.userInteractionEnabled = NO;
    
    _plannerViewCtrler.plannerView.userInteractionEnabled = NO;
    
    // 1, calculate X
    CGPoint coords = [sender locationInView:sender.view];
    //CGFloat dayWidth = (self.bounds.size.width - TIMELINE_TITLE_WIDTH)/7;
    CGFloat dayWidth = quickAddBackgroundView.frame.size.width;
    NSInteger dayNumber = (coords.x-TIMELINE_TITLE_WIDTH)/dayWidth;
    
    CGFloat x = dayNumber * dayWidth + TIMELINE_TITLE_WIDTH;
    
    CGRect frm = quickAddBackgroundView.frame;
    
    frm.origin.x = x;
    
    // 2, calculate Y
    CGFloat ymargin = TIME_SLOT_HEIGHT/2;
	
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSDateComponents *comps = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[timeSlot getTime]];
    
	NSInteger hour = [comps hour];
	NSInteger minute = [comps minute];
	
	NSInteger slotIdx = 2*hour + minute/30;
	
	CGPoint offset = scrollView.contentOffset;
	
	frm.origin.y = ymargin + slotIdx * TIME_SLOT_HEIGHT + 1;
	
	if (minute >= 30)
	{
		minute -= 30;
	}
	
	frm.origin.y += minute*TIME_SLOT_HEIGHT/30;
	
	CGPoint p = [scrollView convertPoint:frm.origin toView:self];
	p.x = frm.origin.x;
    
    CGFloat kbH = 352;//[Common getKeyboardHeight];
	
    //if (p.y + frm.size.height > contentView.bounds.size.height - kbH)
    {
        CGFloat dy = (p.y + frm.size.height - self.bounds.size.height + kbH) + 20;
        
		p.y -= dy;
		offset.y += dy;
		
		[scrollView setContentOffset:offset animated:NO];
    }
	
	frm.origin = p;
    if (offset.y < 0) {
        frm.origin.y += offset.y;
        offset.y = 0;
    }
    
    // 3, show quick-add
    quickAddBackgroundView.frame = frm;
	quickAddTextView.text = @"";
	quickAddBackgroundView.hidden = NO;
    
    // calculate time
    NSDate *startDate = [[self.calendarLayoutController.startDate copy] autorelease];
    //startDate = [Common copyTimeFromDate:timeSlot.time toDate:startDate];
    startDate = [Common copyTimeFromDate:[timeSlot getTime] toDate:startDate];
    NSDate *toDate = [Common dateByAddNumDay:dayNumber toDate:startDate];
	quickAddTextView.tag = [toDate timeIntervalSince1970];
	
	[quickAddTextView becomeFirstResponder];
    scrollView.contentOffset = offset;
}

-(void)quickAdd:(NSString *)name startTime:(NSDate *)startTime
{
	[_plannerViewCtrler quickAddEvent:name startTime:startTime];
}

#pragma mark GrowingTextView Delegate
- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView
{
    return NO;
}

- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView;
{
    NSString *text = [quickAddTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    quickAddBackgroundView.hidden = YES;
	scrollView.scrollEnabled = YES;
	scrollView.userInteractionEnabled = YES;
    
	_plannerViewCtrler.plannerView.userInteractionEnabled = YES;
	
	if (![text isEqualToString:@""])
	{
		NSDate *startTime = [NSDate dateWithTimeIntervalSince1970:quickAddTextView.tag];
		
		[self quickAdd:text startTime:startTime];
	}
    
    // expand current week
    /*if (_plannerViewCtrler != nil) {
        [_plannerViewCtrler.plannerView.monthView expandCurrentWeek];
    }*/
    
    NSDate *dt = [_plannerViewCtrler.plannerView.monthView getSelectedDate];
    [_plannerViewCtrler.plannerView.monthView highlightCellOnDate:dt];
}

#pragma mark Links

- (void) reconcileLinks:(NSDictionary *)dict
{
    TaskLinkManager *tlm = [TaskLinkManager getInstance];
    
    int sourceId = [[dict objectForKey:@"LinkSourceID"] intValue];
    int destId = [[dict objectForKey:@"LinkDestID"] intValue];
    
    NSArray *list = calendarLayoutController.objList;
    
    for (Task *task in list)
    {
        if (task.original == nil || [task isREException])
        {
            if (task.primaryKey == sourceId)
            {
                task.links = [tlm getLinkIds4Task:sourceId];
            }
            else if (task.primaryKey == destId)
            {
                task.links = [tlm getLinkIds4Task:destId];
            }
        }
    }
}

- (void)setNeedsDisplay
{
	for (UIView *view in scrollView.subviews)
	{
        if ([view isKindOfClass:[TaskView class]])
        {
            [view refresh];
        }
	}
}
@end