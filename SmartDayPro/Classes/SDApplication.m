//
//  SDApplication.m
//  SmartCal
//
//  Created by Left Coast Logic on 6/18/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import "SDApplication.h"

#import "CustomTextView.h"
#import "BusyController.h"
#import "TaskView.h"
#import "PlanView.h"

#import "AbstractSDViewController.h"
#import "Common.h"

#define MAX_IDLE_TIME 2
#define AUTOSYNC_IDLE_TIME 10

BOOL _screenTouch = NO;

extern AbstractSDViewController *_abstractViewCtrler;

@implementation SDApplication

- (void)sendEvent:(UIEvent *)event
{
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
    /*
    for(UITouch *touch in allTouches)
    {
        BOOL touchEnded = (touch.phase == UITouchPhaseBegan);
        //BOOL isDoubleTap = (touch.tapCount == 2);
        BOOL isHittingCustomTextView = (touch.view.class == [CustomTextView class]);
        if(touchEnded && isHittingCustomTextView)
        {
            CustomTextView *tv = (CustomTextView*)touch.view;
            
            [tv touchDetected:touch withEvent:event];
            //printf("double tap on Custom View");
        }
    } */
}

- (void)resetIdleTimer {
    if (!_screenTouch)
    {
        ////NSLog(@"screen is touched");
        _screenTouch = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserTouchNotification" object:nil];
    }
        
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(idleTimerExceeded) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(idleAutoSync) object:nil];
    
    [self performSelector:@selector(idleTimerExceeded) withObject:nil afterDelay:MAX_IDLE_TIME];
    [self performSelector:@selector(idleAutoSync) withObject:nil afterDelay:AUTOSYNC_IDLE_TIME];
    [self performSelector:@selector(idleAutoBackup) withObject:nil afterDelay:AUTOSYNC_IDLE_TIME];
}

- (void)idleTimerExceeded {
    ////NSLog(@"idle time exceeded");
    _screenTouch = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserIdleNotification" object:nil];
}

- (void)idleAutoSync
{
    if (![[BusyController getInstance] checkBusy])
    {
        [_abstractViewCtrler autoPush];
    }
}

- (void) idleAutoBackup {
    if (![[BusyController getInstance] checkBusy])
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *dBPath = [documentsDirectory stringByAppendingPathComponent:@"SmartCalDB.sql"];
        if ([fileManager fileExistsAtPath:dBPath]) {
            
            // 1. create backup folder if it does not exist
            NSString *backupPath = [documentsDirectory stringByAppendingPathComponent:@"Backup"];
            
            NSError * error = nil;
            [fileManager createDirectoryAtPath:backupPath
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:&error];
            
            // 2. backup
            NSString *fileName = [Common getFullDateString2:[NSDate date]];
            NSString *backupFilePath = [backupPath stringByAppendingPathComponent:fileName];
            if ([fileManager fileExistsAtPath:backupFilePath] == YES) {
                [fileManager removeItemAtPath:backupFilePath error:&error];
            }
            [fileManager copyItemAtPath:dBPath toPath:backupFilePath error:&error];
            
            // 3. remove old backup
            NSArray * directoryContents = [fileManager contentsOfDirectoryAtPath:backupPath error:&error];
            //NSLog(@"directoryContents ====== %@",directoryContents);
            NSInteger maxFile = 5;
            if (directoryContents.count > maxFile) {
                for (int i = 0; i < directoryContents.count - maxFile; i++) {
                    NSString *removedFile = [backupPath stringByAppendingPathComponent:[directoryContents objectAtIndex:i]];
                    [fileManager removeItemAtPath:removedFile error:&error];
                }
            }
        }
    }
}

- (void) cancelAutoSync
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(idleAutoSync) object:nil];
}

@end
