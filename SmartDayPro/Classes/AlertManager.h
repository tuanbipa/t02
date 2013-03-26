//
//  AlertManager.h
//  SmartCal
//
//  Created by MacBook Pro on 8/17/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AlertData;
@class Task;

@interface AlertManager : NSObject {

	NSMutableDictionary *alertDict;
}

@property (nonatomic, retain) 	NSMutableDictionary *alertDict;

+(id)getInstance;
+(void)free;

- (void) cancelAlert:(NSInteger) alertKey;
- (void) alertOnTime:(NSDate *)time forKey:(NSInteger)alertKey info:(NSString *)info;
- (void) generateAlert:(AlertData *)alert forTask:(Task *)task;
- (void) generateAlertsForTask:(Task *)task;
- (void) removeAllAlertsForTask:(Task *)task;
- (void) cancelAllAlertsForTask:(Task *)task;
- (void) generateAlerts;
- (void) stopAlert:(UILocalNotification *)notif;
- (void) snoozeAlert:(UILocalNotification *)notif;
- (void) postponeAlert:(UILocalNotification *)notif postponeType:(NSInteger)postponeType;

@end
