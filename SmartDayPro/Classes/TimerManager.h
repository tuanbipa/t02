//
//  TimerManager.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 2/28/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Task;

@interface TimerManager : NSObject
{
    
}

@property (nonatomic, retain) Task *taskToActivate;

@property (nonatomic, retain) NSMutableArray *activeTaskList;
@property (nonatomic, retain) NSMutableArray *inProgressTaskList;

-(void) refreshActualDuration:(NSArray *) taskList;
-(NSInteger)getTimerDurationForTask:(Task *)task;
-(BOOL)checkActivated:(Task *)task;
-(void)activateTask;
- (void) holdAllActiveTasksAndStart;

- (void) pauseTask:(NSInteger) taskIndex;
- (void) startTask:(NSInteger) taskIndex;

- (void) interrupt;
- (void) continueTimer;
- (void) pauseTimer;
- (void) markDoneTask:(NSInteger) taskIndex inProgress:(BOOL) inProgress;

+(id)getInstance;
+(void)startup;
+(void)free;

@end
