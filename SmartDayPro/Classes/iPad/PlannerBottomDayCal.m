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

@implementation PlannerBottomDayCal

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
        calendarLayoutController.viewContainer = scrollView;
        [calendarLayoutController layout];
        
        scrollView.contentSize = CGSizeMake(plannerScheduleView.frame.size.width, plannerScheduleView.frame.size.height);
        //scrollView.contentOffset = CGPointMake(self.bounds.size.width, 0);
        scrollView.scrollEnabled = YES;
        scrollView.scrollsToTop = NO;
        scrollView.showsHorizontalScrollIndicator = YES;
        scrollView.showsVerticalScrollIndicator = YES;
        scrollView.directionalLockEnabled = YES;
    }
    return self;
}

- (void)changeFrame: (NSDate*) startDate {
    scrollView.frame = self.bounds;
    scrollView.contentSize = CGSizeMake(plannerScheduleView.frame.size.width, plannerScheduleView.frame.size.height);
    
    // reload week view
    calendarLayoutController.startDate = startDate;
    [calendarLayoutController layout];
}
@end
