//
//  PlannerView.m
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 3/11/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "PlannerView.h"
#import "Common.h"
#import "PlannerHeaderView.h"
#import "PlannerMonthView.h"
#import "PlannerBottomDayCal.h"

extern BOOL _isiPad;

@implementation PlannerView

@synthesize headerView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        
        headerView = [[PlannerHeaderView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 34)];
		[self addSubview:headerView];
		[headerView release];
        
        // month view
        //monthView = [[PlannerMonthView alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height, frame.size.width, frame.size.height-headerView.frame.size.height)];
        monthView = [[PlannerMonthView alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height, frame.size.width, 26*6)];
        
		[self addSubview:monthView];
		[monthView release];
        NSDate *now = [NSDate date];
        NSInteger weeks = [Common getWeeksInMonth:now];
        
        [monthView changeWeekPlanner:7 weeks:weeks];
        [monthView initCalendar:now];
		
        
        // bottom day cal
        PlannerBottomDayCal *bottomDayCal = [[PlannerBottomDayCal alloc] initWithFrame:CGRectMake(0, monthView.frame.origin.y + monthView.frame.size.height, frame.size.width, self.frame.size.height - headerView.frame.size.height - monthView.frame.size.height)];
        [self addSubview:bottomDayCal];
        [bottomDayCal release];
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

@end
