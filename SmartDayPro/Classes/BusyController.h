//
//  BusyController.h
//  SmartCal
//
//  Created by MacBook Pro on 9/30/11.
//  Copyright 2011 LCL. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BusyController : NSObject {
	NSInteger busyFlag;
}

- (NSInteger) getBusyFlag;
- (void)setBusy:(BOOL)isBusy withCode:(NSInteger) withCode;

- (void) refreshBusyIndicator;
- (BOOL) checkSyncBusy;
- (BOOL) checkMMBusy;
- (BOOL) checkBusy;

- (void) reset;

+(id)getInstance;
+(void)free;

@end
