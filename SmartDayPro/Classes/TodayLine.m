//
//  TodayLine.m
//  SmartPlan
//
//  Created by Trung Nguyen on 1/28/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "TodayLine.h"

#import "Common.h"
#import "Colors.h"

@implementation TodayLine

@synthesize horizontal;
@synthesize dashStyle;
@synthesize focusStyle;
@synthesize date;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		
		self.backgroundColor = [UIColor clearColor];
		self.date = nil;
		self.horizontal = YES;
		self.dashStyle = NO;
        self.focusStyle = NO;
        forPlanner = NO;
	}
    return self;
}

- (id)initForPlannerWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		
		self.backgroundColor = [UIColor clearColor];
		self.date = nil;
		self.horizontal = YES;
		self.dashStyle = NO;
        self.focusStyle = NO;
        forPlanner = YES;
	}
    return self;
}

- (void) setFocusStyle:(BOOL)style
{
    focusStyle = style;
    
    self.dashStyle = YES;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    UIImage *todayLineImg;
	if (forPlanner) {
        todayLineImg = [UIImage imageNamed:@"planner_currenttime.png"];
    } else {
        todayLineImg = [UIImage imageNamed:@"currenttime.png"];
    }
    
    CGRect frm = rect;
    
    //frm.size.height = todayLineImg.size.height;
    
    [todayLineImg drawInRect:frm];
}


- (void)dealloc {
	self.date =  nil;
	
    [super dealloc];
}


@end
