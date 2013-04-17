//
//  PlannerScheduleView.h
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 4/2/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentView.h"

@class TodayLine;
@class TimeSlotView;

@interface PlannerScheduleView : ContentView {
    TimeSlotView *activeSlot;
	
	TodayLine *todayLine;
    
    CGPoint touchPoint;
    NSInteger touchHandle;
    BOOL dayManagerRefresh;
}

@property (nonatomic) BOOL todayLineHidden;

- (TimeSlotView *)getTimeSlot;
- (void) highlight:(CGRect) rec;
- (void) unhighlight;
- (void) refreshTodayLine;
@end