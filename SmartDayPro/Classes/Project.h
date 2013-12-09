//
//  Project.h
//  SmartPlan
//
//  Created by Huy Le on 11/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sqlite3.h>

#import "Common.h"

@class Task;

@interface Project : NSObject {
	NSInteger primaryKey; 
	NSInteger sequenceNo;
	NSInteger colorId;
    BOOL isTransparent;
	NSString *name;
    NSString *ownerName;
	NSString *tag;
	//NSString *syncId;
    NSString *sdwId;
	
	NSDate *actualStartTime;
	NSDate *startTime;
	NSDate *endTime;
	CGFloat workBalance;
	CGFloat estimatedHours;
	BOOL isPinnedDeadline;	
	
	NSDate *creationTime;
	NSDate *updateTime;
	
	NSInteger type;
	NSInteger goal;
	
	NSString *ekId; //Calendar ID
	NSString *tdId; //Toodledo ID
    NSString *rmdId; //Reminder ID
	
	NSString *suggestedEventMappingName;	
	
	CGFloat yMargin;
	
	Task *tbdTask;
	
	CGFloat planDuration;
	CGFloat latestEstimatedDuration;
	CGFloat doneDuration;
	CGFloat delayedDuration;
	CGFloat revisedWorkBalance;
	NSDate *revisedDeadline;
	
	BOOL isInitial;
	BOOL isExpanded;
	
	NSInteger status;
    NSInteger extraStatus;
    NSInteger source;
	
	BOOL isExternalUpdate; //this flag is used to not save update time when syncing
    
    // location fielf
    NSInteger locationID;
}

@property NSInteger primaryKey; 
@property NSInteger sequenceNo;
@property NSInteger colorId;
@property BOOL isTransparent;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *ownerName;
@property (nonatomic, copy) NSString *tag;
//@property (nonatomic, copy) NSString *syncId;
@property (nonatomic, copy) NSString *sdwId;

@property (nonatomic, copy) NSDate *actualStartTime;
@property (nonatomic, copy) NSDate *startTime;
@property (nonatomic, copy) NSDate *endTime;
@property CGFloat workBalance;
@property CGFloat estimatedHours;

@property BOOL isPinnedDeadline;

@property (nonatomic, copy) NSDate *creationTime;
@property (nonatomic, copy) NSDate *updateTime;

@property NSInteger type;
@property NSInteger goal;

@property (nonatomic, copy) NSString *ekId;
@property (nonatomic, copy) NSString *tdId;
@property (nonatomic, copy) NSString *rmdId;

@property (nonatomic, copy) NSString *suggestedEventMappingName;

@property CGFloat yMargin;

@property (nonatomic, retain) Task *tbdTask;

@property CGFloat planDuration;
@property CGFloat latestEstimatedDuration;
@property CGFloat doneDuration;
@property CGFloat delayedDuration;
@property CGFloat revisedWorkBalance;
@property (nonatomic, copy) NSDate *revisedDeadline;

@property BOOL isInitial;
@property BOOL isExpanded;

@property NSInteger status;
@property NSInteger extraStatus;
@property NSInteger source;
// location field
@property NSInteger locationID;

- (NSDictionary *) tojson;
- (void) fromjson:(NSDictionary *)jsonDict;

- (void) initialUpdate;
- (void) resetDefault;
- (void) resetPlan;
- (void) updateEstimatedHours:(CGFloat) hours;
- (void)updateByProject:(Project *)prj;
- (void) refreshPlan;
- (CGFloat) getTotalDuration;
- (NSDate *)getPlanStartTime;
- (NSDate *) calculateDefaultEndTime;
- (CGFloat) calculateDefaultWeeks;
- (CGFloat) calculateWeeks;
- (void) calculateDeadline;
- (void) calculateWorkBalance;
- (PlanInfo) getInfo;
- (BOOL) checkChange:(Project *)project;
- (BOOL) checkTransparent;
- (BOOL) checkDefault;
- (BOOL) checkCleanable;
- (BOOL) isShared;
- (void) setIsOwner: (BOOL)enabled;
- (BOOL) isOwner;
- (void) saveSnapshot;
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)database;
- (void) insertIntoDB:(sqlite3 *)database;
- (void) updateIntoDB:(sqlite3 *)database;
- (void) updateSeqNoIntoDB:(sqlite3 *)database;
- (void) updateTypeIntoDB:(sqlite3 *)database;
- (void) updateYMarginIntoDB:(sqlite3 *)database;
- (void) updateMappingIntoDB:(sqlite3 *)database;
- (void) updateToodledoIDIntoDB:(sqlite3 *)database;
- (void) updateEKIDIntoDB:(sqlite3 *)database;
- (void) updateReminderIDIntoDB:(sqlite3 *)database;
- (void) updateActualStartTimeIntoDB:(sqlite3 *)database;
- (void) updateEndTimeIntoDB:(sqlite3 *)database;
- (void) updateEndTimeWBIntoDB:(sqlite3 *)database;
- (void) updateHoursIntoDB:(sqlite3 *)database;
- (void) updateNameIntoDB:(sqlite3 *)database;
//- (void) updateSyncIDIntoDB:(sqlite3 *)database;
- (void) updateSDWIDIntoDB:(sqlite3 *)database;
- (void) updateColorIDIntoDB:(sqlite3 *)database;
- (void) updateStatusIntoDB:(sqlite3 *)database;
- (void) updateTagIntoDB:(sqlite3 *)database;
- (void) modifyUpdateTimeIntoDB:(sqlite3 *)database;
- (void) deleteFromDatabase;
- (void) cleanFromDatabase;
- (void) externalUpdate;
- (void) enableExternalUpdate;
+ (void)finalizeStatements;
	

@end
