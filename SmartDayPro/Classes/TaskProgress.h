//
//  TaskProgress.h
//  SmartPlan
//
//  Created by Huy Le on 12/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sqlite3.h>

@class Task;

@interface TaskProgress : NSObject {
	Task *task;
	
	NSInteger primaryKey;
	NSDate *startTime;
	NSDate *endTime;
}

@property NSInteger primaryKey;
@property (nonatomic, assign) Task *task;
@property (nonatomic, copy) NSDate *startTime;
@property (nonatomic, copy) NSDate *endTime;

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)database;
- (void) insertIntoDB:(sqlite3 *)database;
- (void) updateIntoDB:(sqlite3 *)database;

+ (void)finalizeStatements;

@end
