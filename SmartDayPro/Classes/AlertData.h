//
//  AlertData.h
//  SmartCal
//
//  Created by MacBook Pro on 7/26/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Task;

@interface AlertData : NSObject {
	NSInteger primaryKey;
	NSInteger taskKey;
	
	//NSInteger type; //0:absolute, 1:before
	NSDate *absoluteTime;
	NSInteger beforeDuration; //in seconds
}

@property NSInteger primaryKey;
@property NSInteger taskKey;

//@property NSInteger type;
@property (nonatomic, copy) NSDate *absoluteTime;
@property NSInteger beforeDuration;

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)database;
- (void) insertIntoDB:(sqlite3 *)database;
- (void) updateIntoDB:(sqlite3 *)database;
- (void)deleteFromDatabase:(sqlite3 *)database;
- (void) updateByAlertData:(AlertData *)another;
- (NSString *) getAlertTimeString:(NSInteger)taskType textDict:(NSDictionary *)textDict;
- (NSString *) getAbsoluteTimeString:(Task *)task;
- (NSDate *) getAlertTime:(Task *)task;

+ (NSString *) stringOfAlertData:(AlertData *)data;
+ (AlertData *) parseRepeatData:(NSString *)data;
+ (NSDictionary *) getAlertTextDictionary;
+ (void)finalizeStatements;

@end
