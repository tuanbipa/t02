//
//  ScheduleView.m
//  iVo
//
//  Created by Left Coast Logic on 7/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import "Common.h"
#import "ScheduleView.h"
#import "TimeSlotView.h"
#import "TodayLine.h"
#import "TaskManager.h"
#import "Settings.h"

@implementation ScheduleView

@synthesize todayLineHidden;

- (id)initWithFrame:(CGRect)frame {
	//ILOG(@"[ScheduleView initWithFrame\n")
	
	if (self = [super initWithFrame:frame]) {
		
		// Initialization code
		self.backgroundColor = [UIColor clearColor];
        
		activeSlot = nil;
		
		NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
		
		unsigned unitFlags = 0xFFFF;
		NSDateComponents *comps = [gregorian components:unitFlags fromDate:[NSDate date]];
		
		int startHour = 0;
		int endHour = 24;
		
		int dy = 0;
        
        NSMutableArray *slotViews = [NSMutableArray arrayWithCapacity:48];
		
		for (int i=startHour; i<=endHour; i++)
		{
			int numSlots = (i==endHour? 1:2);
			
			for (int j=0; j<numSlots;j++)
			{
				[comps setHour:i];
				[comps setMinute:j*30];
				[comps setSecond:0];
			
				TimeSlotView *tsView = [[TimeSlotView alloc] initWithFrame:CGRectMake(0, dy, frame.size.width, TIME_SLOT_HEIGHT)];
                tsView.timeSegment = i*64+j*30;
                
				//tsView.time = [gregorian dateFromComponents:comps];
			
			
                [slotViews addObject:tsView];
				[tsView release];
				
				dy += TIME_SLOT_HEIGHT;
			}
		}

        todayLine = [[TodayLine alloc] initWithFrame:CGRectMake(0, 0, 320, 17)];
		todayLine.dashStyle = YES;
		[self addSubview:todayLine];
		[todayLine release];
		
		CGFloat totalHeight = (endHour-startHour+1)*2*TIME_SLOT_HEIGHT + TIME_SLOT_HEIGHT;
		
		frame.size.height = totalHeight;
		
		self.frame = frame;
        
        dayManagerUpView = [[UIView alloc] initWithFrame:CGRectZero];
        dayManagerUpView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
        [self addSubview:dayManagerUpView];
        [dayManagerUpView release];
        
        upHandleImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"focus_handle.png"]];
        upHandleImgView.frame = CGRectMake(dayManagerUpView.bounds.size.width-30, dayManagerUpView.bounds.size.height-20, 30, 20);
        
        [dayManagerUpView addSubview:upHandleImgView];
        [upHandleImgView release];
        
        dayManagerDownView = [[UIView alloc] initWithFrame:CGRectZero];
        dayManagerDownView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
        [self addSubview:dayManagerDownView];
        [dayManagerDownView release];
        
        downHandleImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"focus_handle.png"]];
        downHandleImgView.frame = CGRectMake(dayManagerDownView.bounds.size.width-30, 0, 30, 20);
        
        [dayManagerDownView addSubview:downHandleImgView];
        [downHandleImgView release];
        
        for (UIView *view in slotViews)
        {
            [self addSubview:view];
        }
        
        self.todayLineHidden = YES;
        
        dayManagerUpView.hidden = YES;
        dayManagerDownView.hidden = YES;
				
		//[gregorian release];
	}
	//ILOG(@"ScheduleView initWithFrame]\n")
	return self;
}

- (void) changeFrame:(CGRect)frm
{
    CGRect rec = frm;
    
    rec.size.height = self.frame.size.height;
    
    self.frame = rec;
    
    todayLine.frame = CGRectMake(0, 0, frm.size.width, 17);
    
    for (UIView *view in self.subviews)
    {
        if ([view isKindOfClass:[TimeSlotView class]])
        {
            CGRect rec = view.frame;
            rec.size.width = frm.size.width;
            
            view.frame = rec;
        }
    }
    
    [self refreshDayManagerView];
}

- (void) setTodayLineHidden:(BOOL)hidden
{
    todayLineHidden = hidden;
    
    todayLine.hidden = hidden;
}

- (void) refreshDayManagerView
{
    TaskManager *tm = [TaskManager getInstance];
    
    if (tm.today == nil)
    {
        return;
    }
    
    //NSDate *start = [tm dayManagerStartTime];
    //NSDate *end = [tm dayManagerEndTime]; 
    
    Settings *settings = [Settings getInstance];
    
    NSDate *start = [settings getWorkingStartTimeForDate:tm.today];
    NSDate *end = [settings getWorkingEndTimeForDate:tm.today];
    
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	unsigned unitFlags = 0xFFFF;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:start];
	
	int minute = comps.minute;
	
	NSInteger slotIdx = 2*comps.hour + minute/30;
	
	if (minute >= 30)
	{
		minute -= 30;
	}
	
	CGFloat y = TIME_SLOT_HEIGHT/2 + slotIdx * TIME_SLOT_HEIGHT + minute*TIME_SLOT_HEIGHT/30;
    
    dayManagerUpView.frame = CGRectMake(40, 0, self.frame.size.width-40, y);
    
    comps = [gregorian components:unitFlags fromDate:end];
    minute = comps.minute;
    slotIdx = 2*comps.hour + minute/30;
	
	if (minute >= 30)
	{
		minute -= 30;
	}
	
	y = TIME_SLOT_HEIGHT/2 + slotIdx * TIME_SLOT_HEIGHT + minute*TIME_SLOT_HEIGHT/30;
    
    CGRect frm = CGRectMake(40, y, self.frame.size.width-40, self.frame.size.height-y);
    
    dayManagerDownView.frame = frm;
    
    upHandleImgView.frame = CGRectMake(dayManagerUpView.bounds.size.width-30, dayManagerUpView.bounds.size.height-20, 30, 20);
    
    downHandleImgView.frame = CGRectMake(dayManagerDownView.bounds.size.width-30, 0, 30, 20);
    
    dayManagerUpView.hidden = NO;
    dayManagerDownView.hidden = NO;
    
}

- (void) refreshTodayLine
{
    if (!todayLine.hidden)
    {
        CGRect frm = todayLine.frame;
        frm.origin.y = [self getTodayLineY] - frm.size.height/2;
        todayLine.frame = frm;        
    }
}

- (CGFloat) getTodayLineY
{
    NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
    
    unsigned unitFlags = 0xFFFF;
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:[NSDate date]];
    
    int minute = comps.minute;
    
    NSInteger slotIdx = 2*comps.hour + minute/30;
    
    if (minute >= 30)
    {
        minute -= 30;
    }
    
    CGFloat y = TIME_SLOT_HEIGHT/2 + slotIdx * TIME_SLOT_HEIGHT + minute*TIME_SLOT_HEIGHT/30;
    
    return y;
}

- (NSDate *)getTimeSlot
{
	//ILOG(@"[ScheduleView getTimeSlot\n")
	
	if (activeSlot != nil)
	{
		//ILOG(@"ScheduleView getTimeSlot] NOT NIL\n")
		return [activeSlot getTime];
	}
	
	//ILOG(@"ScheduleView getTimeSlot]\n")
	return nil;
}

- (TimeSlotView *) hitTestRec: (CGRect) rec
{
	//ILOG(@"[ScheduleView hitTestRec\n")
	
	//for (TimeSlotView *view in self.subviews)
	for (UIView *view in self.subviews)
	{
		if ([view isKindOfClass:[TimeSlotView class]] && [(TimeSlotView *)view hitTestRec:rec] != nil)
		{
			//ILOG(@"ScheduleView hitTestRec] NOT NIL\n")
			return (TimeSlotView *)view;
		}
	}
	
	//ILOG(@"ScheduleView hitTestRec]\n")
	return nil;
}

- (void) highlight:(CGRect) rec
{
	//ILOG(@"[ScheduleView hightlight\n")
	
	rec.origin.x -= self.frame.origin.x;
	rec.origin.y -= self.frame.origin.y;
	
	TimeSlotView *slot = [self hitTestRec:rec];
	
	if (activeSlot == slot)
	{
		return;
	}
	
	[activeSlot unhighlight];
	
	activeSlot = slot;
	
	if (activeSlot != nil)
	{
		////////printf("high light slot:%s\n", [[activeSlot.time description] UTF8String] );
		[activeSlot highlight];
	}
	
	//ILOG(@"ScheduleView hightlight]\n")
}

- (void) unhighlight
{
	//ILOG(@"[ScheduleView unhightlight\n")
	
	if (activeSlot != nil)
	{
		[activeSlot unhighlight];
		activeSlot = nil;
	}
	//ILOG(@"ScheduleView unhightlight]\n")
}

- (void)drawRect:(CGRect)rect {
	// Drawing code
}

-(void)changeSkin
{
	for (UIView *view in self.subviews)
	{
		if ([view respondsToSelector:@selector(changeSkin)])
		{
			[view changeSkin];
		}
	}
}

- (void)dealloc {
	[super dealloc];
}

#pragma mark Touch

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGRect upHandle = CGRectMake(dayManagerUpView.frame.origin.x + dayManagerUpView.frame.size.width - 40, dayManagerUpView.frame.origin.y + dayManagerUpView.frame.size.height - 40, 40, 40);
    
    CGRect downHandle = CGRectMake(dayManagerDownView.frame.origin.x + dayManagerDownView.frame.size.width - 40, dayManagerDownView.frame.origin.y, 40, 40);
    
    touchHandle = 0;
    dayManagerRefresh = NO;
    
	touchPoint = [[touches anyObject] locationInView:self];
    firstTouchPoint = touchPoint;
	
	if (CGRectContainsPoint(upHandle, touchPoint))
	{
        ////printf("up handle touch\n");
        touchHandle = 1;
    }
    else if (CGRectContainsPoint(downHandle, touchPoint)) 
    {
        ////printf("down handle touch\n");
        touchHandle = 2;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //TaskManager *tm = [TaskManager getInstance];
    //Settings *settings = [Settings getInstance];
    
    CGPoint p = [[touches anyObject] locationInView:self];
    
    CGFloat dy = p.y - touchPoint.y;
    ////printf("move dy:%f\n", dy);
    
    /*
    NSInteger moveUnit = TIME_SLOT_HEIGHT/6;
    
    if (abs(dy) >= moveUnit)
    {
        NSInteger dMinute = dy>0?moveUnit:-moveUnit;
        
        //printf("move dy: %f - minute: %d\n", dy, dMinute);
        
        if (touchHandle == 1)
        {
            //NSDate *dt = tm.dayManagerStartTime;
            NSDate *dt = [settings getWorkingStartTimeForDate:tm.today];
            
            dt = [Common dateByAddNumSecond:dMinute*60 toDate:dt];
            
            [settings setWorkingStartTime:dt];
        }
        else if (touchHandle == 2)
        {
            //NSDate *dt = tm.dayManagerEndTime;
            NSDate *dt = [settings getWorkingEndTimeForDate:tm.today];
            
            dt = [Common dateByAddNumSecond:dMinute*60 toDate:dt];
            
            //tm.dayManagerEndTime = dt;
            [settings setWorkingEndTime:dt];
        }
        
        [self refreshDayManagerView];
        
        dayManagerRefresh = YES;

        touchPoint = p; 
    }
    */
    
    if (touchHandle == 1)
    {
        CGRect frm = dayManagerUpView.frame;
        
        frm.size.height += dy;
        
        dayManagerUpView.frame = frm;
        
        upHandleImgView.frame = CGRectMake(dayManagerUpView.bounds.size.width-30, dayManagerUpView.bounds.size.height-20, 30, 20);
    }
    else if (touchHandle == 2)
    {
        CGRect frm = dayManagerDownView.frame;
        
        frm.origin.y += dy;
        frm.size.height -= dy;
        
        dayManagerDownView.frame = frm;
                
        downHandleImgView.frame = CGRectMake(dayManagerDownView.bounds.size.width-30, 0, 30, 20);
    }
    
    touchPoint = p;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    TaskManager *tm = [TaskManager getInstance];
    Settings *settings = [Settings getInstance];
    
    /*
    if (dayManagerRefresh)
    {
        [[TaskManager getInstance] scheduleTasks];
        
        Settings *settings = [Settings getInstance];

        [settings saveWorkingTimes];
    }
    */
    
    if (touchHandle == 1 || touchHandle == 2)
    {
        CGPoint p = [[touches anyObject] locationInView:self];
        
        CGFloat dy = p.y - firstTouchPoint.y;
        
        CGFloat secs = dy*1800/TIME_SLOT_HEIGHT;
        
        if (touchHandle == 1)
        {
            NSDate *dt = [settings getWorkingStartTimeForDate:tm.today];
            
            dt = [Common dateByRoundMinute:5 toDate:[Common dateByAddNumSecond:secs toDate:dt]];
            
            [settings setWorkingStartTime:dt];
        }
        else if (touchHandle == 2)
        {
            NSDate *dt = [settings getWorkingEndTimeForDate:tm.today];
            
            dt = [Common dateByRoundMinute:5 toDate:[Common dateByAddNumSecond:secs toDate:dt]];
            
            [settings setWorkingEndTime:dt];
        }
     
        [[TaskManager getInstance] scheduleTasks];
        
        [settings saveWorkingTimes];        
    }
    
    [super touchesEnded:touches withEvent:event];
}

#pragma mark OS4 Support 

-(void) recover
{
	for (UIView *view in self.subviews)
	{
		if ([view respondsToSelector:@selector(recover)])
		{
			[view recover];
		}
	}	
}

@end
