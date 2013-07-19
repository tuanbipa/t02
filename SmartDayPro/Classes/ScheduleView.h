//
//  ScheduleView.h
//  iVo
//
//  Created by Left Coast Logic on 7/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentView.h"

@class TodayLine;
@class TimeSlotView;

@interface ScheduleView : ContentView {
	TimeSlotView *activeSlot;
	
	TodayLine *todayLine;
    
    CGPoint touchPoint;
    CGPoint firstTouchPoint;
    
    NSInteger touchHandle;
    BOOL dayManagerRefresh;
    
    UIView *dayManagerUpView;
    UIView *dayManagerDownView;
    UIImageView *upHandleImgView;
    UIImageView *downHandleImgView;
}

@property BOOL todayLineHidden;

- (void) highlight:(CGRect) rec;
- (void) unhighlight;
- (NSDate *)getTimeSlot;
- (void)changeSkin;
- (void) refreshTodayLine;
- (void) refreshDayManagerView;
- (CGFloat) getTodayLineY;
- (void) changeFrame:(CGRect)frm;

@end
