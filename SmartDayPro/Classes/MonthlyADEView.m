//
//  MonthlyADEView.m
//  SmartTime
//
//  Created by Left Coast Logic on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MonthlyADEView.h"

#import "Common.h"
#import "TaskManager.h"
#import "ProjectManager.h"
#import "DBManager.h"
#import "Task.h"
#import "Settings.h"
#import "MonthlyCalendarView.h" 

extern TaskManager *taskmanager;

#define ADE_LINE_WIDTH 7
#define ADE_LINE_SPACE (ADE_LINE_WIDTH + 2)
#define ADE_LINE_MARGIN 20
#define TIME_LINE_WIDTH 7

#define MAX_ADE_NUM 2

@implementation MonthlyADEView

@synthesize startDate;
@synthesize endDate;
@synthesize adeList;

@synthesize nameShown;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		
		self.backgroundColor = [UIColor clearColor];
		
		self.userInteractionEnabled = NO;
		
		startDate = nil;
		endDate = nil;
		
		self.nameShown = NO;
    }
	
    return self;
}

-(void) setStartDate:(NSDate *)startDateVal endDate:(NSDate *)endDateVal
{
    //printf("get ADE list from %s - to %s\n", [[startDateVal description] UTF8String], [[endDateVal description] UTF8String]);
    
	self.startDate = startDateVal;
	self.endDate = endDateVal;
	
	self.adeList = [[TaskManager getInstance] getADEListFromDate:self.startDate toDate:self.endDate];
	
    /*for (Task *ade in self.adeList)
    {
        printf("ade %s - start: %s - end: %s\n",[ade.name UTF8String], [[ade.startTime description] UTF8String], [[ade.endTime description] UTF8String]);
    }*/
	
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
	
	//////NSLog(@"ade pane begin draw");
	
	if (startDate == nil || endDate == nil)
	{
		return;
	}
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	//NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSInteger duration[42][MAX_ADE_NUM];
	NSInteger project[42][MAX_ADE_NUM];
	NSInteger adeNum[42][2]; //count of primary ADEs and secondary ADEs in 1 cell. 
							// Primary ADE starts on the cell date.
							//Secondary ADE starts before the cell date and spans accross the cell date. 
	Task *ades[42][MAX_ADE_NUM];
	
	for (int i=0; i<42; i++)
	{
		for (int j=0; j<MAX_ADE_NUM; j++)
		{
			duration[i][j] = -1;
			project[i][j] = -1;
			ades[i][j] = nil;
			
			if (j<2)
			{
				adeNum[i][j] = 0;
			}
		}
	}
	
	//NSMutableArray *adeList = [[TaskManager getInstance] getADEListFromDate:startDate toDate:endDate];
	
	for (Task *ade in self.adeList)
	{
		if ([ade.startTime compare:self.startDate] == NSOrderedAscending)
		{
			ade.startTime = self.startDate;
		}
		
		if ([self.endDate compare:ade.endTime] == NSOrderedAscending)
		{
			ade.endTime = self.endDate;
		}
		
		//NSTimeInterval diff = [Common timeIntervalNoDST:ade.startTime sinceDate:self.startDate];
        NSTimeInterval diff = [ade.startTime timeIntervalSinceDate:self.startDate];
		
		NSInteger index = diff/(24*60*60) ;
		
		//NSInteger days = ([Common timeIntervalNoDST:ade.endTime sinceDate:ade.startTime] + 1)/(24*60*60);
        //NSInteger days = [Common daysBetween:ade.endTime sinceDate:ade.startTime];
        
        NSInteger days = ([ade.endTime timeIntervalSinceDate:ade.startTime] + 1)/(24*60*60);
        
        //printf("ade %s - start: %s - end: %s - days: %d\n",[ade.name UTF8String], [[ade.startTime description] UTF8String], [[ade.endTime description] UTF8String], days);
		
		for (int j=0; j<MAX_ADE_NUM; j++)
		{
			if (duration[index][j] == -1)
			{
				duration[index][j] = days;
				project[index][j] = ade.project;
				ades[index][j] = ade;
				
				adeNum[index][0] += 1;
				
				for (int k=1;k<days;k++)
				{
					if (index + k < 42)
					{
						adeNum[index+k][1] += 1;
					}
				}
				
				break;
			}
		}		
	}	
	
	//////NSLog(@"finish prepare ADE data");
	
	CGFloat dayWidth = self.frame.size.width/7; 
	CGFloat dayHeight = self.frame.size.height/6;
	
	CGFloat adeMargin = self.nameShown?18:ADE_LINE_MARGIN;
	
	CGFloat adeHeight = self.nameShown?11:ADE_LINE_WIDTH;
	CGFloat adeSpace = self.nameShown?11:ADE_LINE_SPACE;
	
	CGContextSetLineWidth(ctx, ADE_LINE_WIDTH);	
	
	for (int i=0; i<42; i++)
	{
		int div = i/7;
		int mod = i%7;

		NSInteger num = adeNum[i][1];
		
		CGFloat yoffset = adeMargin + num*adeSpace;
		
		for (int j=0; j<MAX_ADE_NUM-num; j++)
		{
			if (duration[i][j] != -1)
			{
                int prj = project[i][j];
                
				UIColor *color = [[ProjectManager getInstance] getProjectColor0:prj];
				
				BOOL toBreak = (mod + duration[i][j] > 7); 
				
				NSInteger segment = (toBreak?7-mod:duration[i][j]);
				
				CGRect adeRect = CGRectMake(mod*dayWidth, div*dayHeight + yoffset + j*adeSpace, segment*dayWidth, adeHeight);
				[color setFill];
				CGContextFillRect(ctx, adeRect);
				
				if (self.nameShown && ades[i][j] != nil)
				{
					Task *ade = ades[i][j];
					
					////////printf("ade name: %s - x:%f, y:%f, w:%f, h:%f\n", [ade.name UTF8String], adeRect.origin.x, adeRect.origin.y, adeRect.size.width, adeRect.size.height);
					[[UIColor whiteColor] set];
					
					[ade.name drawInRect:CGRectOffset(adeRect, 0, -2) withFont:[UIFont boldSystemFontOfSize:10] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
				}
				
				if (toBreak)
				{
					segment = duration[i][j] - segment;
					NSInteger segmentDiv = div + 1;
					
					while (segment > 7)
					{
						adeRect = CGRectMake(0, segmentDiv*dayHeight + yoffset + j*adeSpace, self.frame.size.width, adeHeight);
						[color setFill];
						CGContextFillRect(ctx, adeRect);
						
						if (self.nameShown && ades[i][j] != nil)
						{
							Task *ade = ades[i][j];
							[[UIColor whiteColor] set];
							[ade.name drawInRect:CGRectOffset(adeRect, 0, -2) withFont:[UIFont boldSystemFontOfSize:10] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
						}
						
						
						segment -= 7;
						segmentDiv += 1;
						
						if (segmentDiv == 5)
						{
							break;
						}
					}
					
					if (segment > 0 && segmentDiv <= 5)
					{
						adeRect = CGRectMake(0, segmentDiv*dayHeight + yoffset + j*adeSpace, segment*dayWidth, adeHeight);
						[color setFill];
						CGContextFillRect(ctx, adeRect);
						
						if (self.nameShown && ades[i][j] != nil)
						{
							Task *ade = ades[i][j];
							[[UIColor whiteColor] set];
							[ade.name drawInRect:CGRectOffset(adeRect, 0, -2) withFont:[UIFont boldSystemFontOfSize:10] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
						}
						
					}
				}
			}
		}
	}
	
	//////NSLog(@"ade pane end draw");
}

- (void)dealloc {
	self.startDate = nil;
	self.endDate = nil;
	
	self.adeList = nil;
	
    [super dealloc];
}


@end
