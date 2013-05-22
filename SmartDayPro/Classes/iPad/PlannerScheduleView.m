//
//  PlannerScheduleView.m
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 4/2/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "PlannerScheduleView.h"
#import "TimeSlotView.h"
#import "Common.h"
#import "TodayLine.h"

@implementation PlannerScheduleView

@synthesize todayLineHidden;

- (id)initWithFrame:(CGRect)frame {
	
	if (self = [super initWithFrame:frame]) {
		
		// Initialization code
		self.backgroundColor = [UIColor clearColor];
        
		activeSlot = nil;
		
		//NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
		
		//unsigned unitFlags = 0xFFFF;
		//NSDateComponents *comps = [gregorian components:unitFlags fromDate:[NSDate date]];
		
		int startHour = 0;
		int endHour = 24;
		
		int dy = 0;
        
        NSMutableArray *slotViews = [NSMutableArray arrayWithCapacity:48];
		
		for (int i=startHour; i<=endHour; i++)
		{
			int numSlots = (i==endHour? 1:2);
			
			for (int j=0; j<numSlots;j++)
			{
				//[comps setHour:i];
				//[comps setMinute:j*30];
				//[comps setSecond:0];
                
				TimeSlotView *tsView = [[TimeSlotView alloc] initWithFrame:CGRectMake(0, dy, frame.size.width, TIME_SLOT_HEIGHT)];
				//tsView.time = [gregorian dateFromComponents:comps];
                tsView.timeSegment = i*64+j*30;
                
				//[self addSubview:tsView];
                [slotViews addObject:tsView];
				[tsView release];
				
				dy += TIME_SLOT_HEIGHT;
			}
		}
        
        //todayLine = [[TodayLine alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 17)];
        todayLine = [[TodayLine alloc] initForPlannerWithFrame:CGRectMake(0, 0, frame.size.width, 17)];
		todayLine.dashStyle = YES;
		[self addSubview:todayLine];
		[todayLine release];
		
		CGFloat totalHeight = (endHour-startHour+1)*2*TIME_SLOT_HEIGHT + TIME_SLOT_HEIGHT;
		
		frame.size.height = totalHeight;
		
		self.frame = frame;
        
        for (UIView *view in slotViews)
        {
            [self addSubview:view];
        }
        
        self.todayLineHidden = YES;
        
	}
	//ILOG(@"ScheduleView initWithFrame]\n")
	return self;
}

 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
     [super drawRect:rect];
     
     CGContextRef context = UIGraphicsGetCurrentContext();
     UIColor *darkColor = [UIColor colorWithRed:0.19 green:0.25 blue:0.31 alpha:1];
     CGContextSetStrokeColorWithColor(context, darkColor.CGColor);
     
     // width of Timeline title
     CGFloat titleWidth = 40.0;
     CGFloat cellWidth = (self.frame.size.width - titleWidth)/7;
     for (int i=1; i<=6; i++) {
         CGFloat xPoint = titleWidth + cellWidth*i;
         // Draw them with a 2.0 stroke width so they are a bit more visible.
         CGContextSetLineWidth(context, 0.3);
         
         CGContextMoveToPoint(context, xPoint,12); //start at this point
         
         //CGContextAddLineToPoint(context, xPoint, self.frame.size.height); //draw to this point
         CGContextAddLineToPoint(context, xPoint, self.frame.size.height - 60); //draw to this point
         
         // and now draw the Path!
         CGContextStrokePath(context);
     }
 }

- (TimeSlotView *)getTimeSlot
{
	//ILOG(@"[ScheduleView getTimeSlot\n")
	
	if (activeSlot != nil)
	{
		//ILOG(@"ScheduleView getTimeSlot] NOT NIL\n")
		return activeSlot;
	}
	
	//ILOG(@"ScheduleView getTimeSlot]\n")
	return nil;
}

// hilight title when move over
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

// unhilight title after moving
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

- (void) setTodayLineHidden:(BOOL)hidden
{
    todayLineHidden = hidden;
    
    todayLine.hidden = hidden;
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

- (void) refreshTodayLine
{
    if (!todayLine.hidden)
    {
        CGRect frm = todayLine.frame;
        frm.origin.y = [self getTodayLineY] - frm.size.height/2;
        todayLine.frame = frm;
    }
}

- (CGRect)getTodayLineCGRect {
    return todayLine.frame;
}
@end