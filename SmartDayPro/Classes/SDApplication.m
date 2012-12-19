//
//  SDApplication.m
//  SmartCal
//
//  Created by Left Coast Logic on 6/18/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import "SDApplication.h"

#import "CustomTextView.h"

#define MAX_IDLE_TIME 2

BOOL _screenTouch = NO;

@implementation SDApplication

- (void)sendEvent:(UIEvent *)event {
    [super sendEvent:event];
    
    // Only want to reset the timer on a Began touch or an Ended touch, to reduce the number of timer resets.
    NSSet *allTouches = [event allTouches];
    
    if ([allTouches count] > 0) 
    {
        // allTouches count only ever seems to be 1, so anyObject works here.
        UITouchPhase phase = ((UITouch *)[allTouches anyObject]).phase;
        
        //if (phase == UITouchPhaseBegan || phase == UITouchPhaseEnded)
        if (phase == UITouchPhaseBegan)
        {
            [self resetIdleTimer];
        }
    }
    
    for(UITouch *touch in allTouches)
    {
        BOOL touchEnded = (touch.phase == UITouchPhaseBegan);
        //BOOL isDoubleTap = (touch.tapCount == 2);
        BOOL isHittingCustomTextView = (touch.view.class == [CustomTextView class]);
        if(touchEnded && isHittingCustomTextView)
        {
            CustomTextView *tv = (CustomTextView*)touch.view;
            
            [tv touchDetected:touch withEvent:event];
            ////printf("double tap on Custom View");
        }
    }
}

- (void)resetIdleTimer {
    if (!_screenTouch)
    {
        ////NSLog(@"screen is touched");
        _screenTouch = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserTouchNotification" object:nil];
    }
        
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(idleTimerExceeded) object:nil];
    
    [self performSelector:@selector(idleTimerExceeded) withObject:nil afterDelay:MAX_IDLE_TIME];
}

- (void)idleTimerExceeded {
    ////NSLog(@"idle time exceeded");
    _screenTouch = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserIdleNotification" object:nil];
}

@end
