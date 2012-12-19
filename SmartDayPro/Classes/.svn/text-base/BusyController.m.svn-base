//
//  BusyController.m
//  SmartCal
//
//  Created by MacBook Pro on 9/30/11.
//  Copyright 2011 LCL. All rights reserved.
//

#import "BusyController.h"

//#import "SCTabBarController.h"
//extern SCTabBarController *_tabBarCtrler;

#import "Common.h"

#import "SmartCalAppDelegate.h"
#import "SmartDayViewController.h"

extern SmartDayViewController *_sdViewCtrler;

extern SmartCalAppDelegate *_appDelegate;

BusyController *_busyCtrlerSingleton = nil;

@implementation BusyController
- (id) init
{
	if (self = [super init])
	{
		busyFlag = 0;
	}
	
	return self;
}

- (void)dealloc 
{
	[super dealloc];
}

- (void)setBusy:(BOOL)isBusy withCode:(NSInteger) withCode
{
	////printf("setBusy %s with code:%d\n", isBusy?"YES":"NO", withCode);
	
	if (isBusy)
	{
		busyFlag |= withCode;
	}
	else 
	{
		busyFlag &= ~withCode;
	}
		
    [self showBusyIndicator];
}

- (void) showBusyIndicator
{
	BOOL busyEnable = (busyFlag != 0);
    
    [_appDelegate showBusyIndicator:busyEnable];    
}

- (void) refreshBusyIndicator
{
    [_appDelegate showBusyIndicator:NO];
    
    [self performSelector:@selector(showBusyIndicator) withObject:nil afterDelay:0.1];
}

- (NSInteger) getBusyFlag
{
	return busyFlag;
}

- (BOOL) checkSyncBusy
{
    NSInteger syncFlag = BUSY_EK_SYNC | BUSY_TD_SYNC | BUSY_SDW_SYNC;
    
    return (syncFlag & busyFlag) != 0;
}

- (BOOL) checkMMBusy
{
    NSInteger syncFlag = BUSY_WEEKPLANNER_INIT_CALENDAR;
    
    return (syncFlag & busyFlag) != 0;
}

#pragma mark Public Methods

+(id)getInstance
{
	if (_busyCtrlerSingleton == nil)
	{
		_busyCtrlerSingleton = [[BusyController alloc] init];
	}
	
	return _busyCtrlerSingleton;
}

+(void)free
{
	if (_busyCtrlerSingleton != nil)
	{
		[_busyCtrlerSingleton release];
		
		_busyCtrlerSingleton = nil;
	}
}

@end
