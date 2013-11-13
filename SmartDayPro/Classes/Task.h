//
//  Task.h
//  SmartPlan
//
//  Created by Huy Le on 11/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sqlite3.h>

@class TaskProgress;
@class RepeatData;

@interface Task : NSObject {
	NSInteger primaryKey; 
	NSInteger groupKey;	
	NSInteger sequenceNo;
	NSInteger mergedSeqNo;
	NSInteger project;
	NSInteger goal;
	NSInteger type;
	
	NSInteger status;
    NSInteger timerStatus;
    NSInteger extraStatus;
	NSInteger duration;
	
	NSString *name;
	NSString *contactName;
	NSString *location;
	NSString *contactEmail;
	NSString *contactPhone;	
	NSString *note;
	NSString *tag;
	NSString *syncId;
    NSString *sdwId;
	
	//NSString *toodledoId;
	
	NSDate *creationTime;
	NSDate *startTime;
	NSDate *endTime;
	NSDate *deadline;
	NSDate *updateTime;
	NSDate *completionTime;
	
	NSDate *smartTime;
	
	RepeatData *repeatData;
	
	NSMutableArray *alerts; // array of AlertData objects
	
	BOOL isActivating;
	NSInteger actualDuration;
	
	NSMutableArray *subTasks; // this field is for SmartPlans to manage sub tasks
	
	TaskProgress *lastProgress; //this field is controlled by Timer, other cases need to invoke [DBManager getLastProgressForTask]
	
	Task *original; //this field is to track root RE or root Task of splitted ones
	BOOL isScheduled;
	
	NSMutableDictionary *exceptions; // this field is for SmartCal to manage RE exceptions;
	
	BOOL isExternalUpdate; //this flag is used to not save update time when syncing
	
	BOOL isTop; //this flag is used to display 'Tasks' icon or not in Task View
	
	BOOL isSplitted; //this flag indicates a splitted part of a long task. Its start/end time needs to reload from DB for correct editing
	
	BOOL hasNoDuration; //this flag is used to reset duration of Task to 0 if Task is of check list when syncing
    
    NSMutableArray *links; //array of link IDs
    
    NSInteger listSource; //where the task comes from? (SmartList or List)
    
    // for planner
    NSInteger plannerDuration;
    NSDate *plannerStartTime;
    
    // location alert
    NSInteger locationAlert;
    NSInteger locationAlertID;
    
    // location ID, reference to Location's primary
    NSInteger locationID;
}

@property NSInteger primaryKey; 
@property NSInteger groupKey; 
@property NSInteger sequenceNo;
@property NSInteger mergedSeqNo;
@property NSInteger project;
@property NSInteger goal;
@property (nonatomic) NSInteger type;

@property NSInteger status;
@property NSInteger timerStatus;
@property NSInteger extraStatus;
@property NSInteger duration;

@property NSInteger timeZoneId;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy)	NSString *contactName;
@property (nonatomic, copy)	NSString *location;
@property (nonatomic, copy)	NSString *contactEmail;
@property (nonatomic, copy)	NSString *contactPhone;
@property (nonatomic, copy)	NSString *note;
@property (nonatomic, copy)	NSString *tag;
@property (nonatomic, copy)	NSString *syncId;
@property (nonatomic, copy)	NSString *sdwId;

//@property (nonatomic, copy)	NSString *toodledoId;

@property (nonatomic, copy) NSDate *creationTime;
@property (nonatomic, copy) NSDate *startTime;
@property (nonatomic, copy) NSDate *endTime;
@property (nonatomic, copy) NSDate *deadline;
@property (nonatomic, copy) NSDate *updateTime;
@property (nonatomic, copy) NSDate *completionTime;

@property (nonatomic, copy) NSDate *smartTime;
@property (nonatomic, copy) NSDate *reInstanceStartTime;

@property (nonatomic, copy) RepeatData *repeatData;

@property (nonatomic, retain) NSMutableArray *alerts;

@property BOOL isActivating;
@property NSInteger actualDuration;

@property (nonatomic, retain) NSMutableArray *subTasks;
@property (nonatomic, retain) TaskProgress *lastProgress;

@property (nonatomic, retain) Task *original;
@property BOOL isScheduled;//not faded

@property (nonatomic, retain) NSMutableDictionary *exceptions;

@property (nonatomic, retain) NSMutableArray *links;

@property NSInteger listSource;

@property BOOL isTop;
@property BOOL isSplitted;
@property BOOL hasNoDuration;
@property BOOL isMultiEdit; // use to keep selected status when multi-edit

@property (nonatomic, assign) NSInteger plannerDuration;
@property (nonatomic, copy) NSDate *plannerStartTime;
@property NSInteger locationAlert;
@property NSInteger locationAlertID;
@property NSInteger locationID;

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)database;
- (void) initialUpdate;
- (void) insertIntoDB:(sqlite3 *)database;
- (void) updateIntoDB:(sqlite3 *)database;
- (void) updateTimeZoneIDIntoDB:(sqlite3 *)database;
- (void) updateSeqNoIntoDB:(sqlite3 *)database;
- (void) updateMergedSeqNoIntoDB:(sqlite3 *)database;
- (void) updateDurationIntoDB:(sqlite3 *)database;
- (void) updateNameIntoDB:(sqlite3 *)database;
- (void) updateStatusIntoDB:(sqlite3 *)database;
- (void) updateTimerStatusIntoDB:(sqlite3 *)database;
- (void) updateTypeIntoDB:(sqlite3 *)database;
- (void) updateProjectIntoDB:(sqlite3 *)database;
- (void) updateStartTimeIntoDB:(sqlite3 *)database;
- (void) updateEndTimeIntoDB:(sqlite3 *)database;
- (void) updateDeadlineIntoDB:(sqlite3 *)database;
- (void) updateTimeIntoDB:(sqlite3 *)database;
- (void) modifyUpdateTimeIntoDB:(sqlite3 *)database;
- (void) updateCompletionTimeIntoDB:(sqlite3 *)database;
- (void) updateRepeatDataIntoDB:(sqlite3 *)database;
- (void) updateTagIntoDB:(sqlite3 *)database;
- (void) updateSyncIDIntoDB:(sqlite3 *)database;
- (void) updateSDWIDIntoDB:(sqlite3 *)database;
- (void) updateLinkIntoDB:(sqlite3 *)database;
- (void) updateLocationAlertIntoDB:(sqlite3 *)database;
- (void) refreshSyncIDFromDB:(sqlite3 *)database;
- (void)deleteFromDatabase:(sqlite3 *)database ;
- (void)cleanFromDatabase:(sqlite3 *)database ;
- (void) updateByTask:(Task*) task ;
- (void) updateByRE:(Task*) reOriginal;
- (void) updateAlerts;
- (NSString *) alertsToString;
- (NSString *) getRepeatString;
-(void) externalUpdate;
-(void) enableExternalUpdate;
-(void) changeProject:(int)key;
- (NSString *) getCombinedTag;
- (void) print;
- (NSDictionary *) tojson;
- (void) fromjson:(NSDictionary *)jsonDict;
- (BOOL) checkChange:(Task *)task;

-(BOOL)isRT;
-(BOOL)isRE;
-(BOOL)isRecurring;
-(BOOL)isNREvent;
-(BOOL)isDTask;
-(BOOL)isSTask;
-(BOOL)isEvent;
-(BOOL)isNormalEvent;
-(BOOL)isADE;
-(BOOL)isTask;
-(BOOL)isNote;
-(BOOL)isREInstance;
-(BOOL)isREException;
-(BOOL)isLong;
-(BOOL)isPartial;
-(BOOL)isDone;
- (BOOL)isStar;
-(BOOL) isMeetingInvited;
-(BOOL) isShared;
-(BOOL) isManual;

- (void) setExtraManual:(NSInteger)intValue;
- (void) setManual:(BOOL)enabled;
- (void) setMeetingInvited:(BOOL)enabled;
- (void) setShared:(BOOL)enabled;

-(BOOL)checkMustDo;

- (NSString *) getRepeatTypeString;
- (NSString *) getRepeatUntilString;
- (NSString *) getRepeatDisplayString;

- (NSString *) getDisplayStartTime;
- (NSString *) getDisplayEndTime;

#pragma mark Due String
- (NSString *)getDueString;
+ (void)finalizeStatements;

#pragma mark Properties
/*- (void)checkHasPinnedCharacterInTitle;
- (NSString *)titleWithoutAnchor;
- (void)addAnchorInTitle;*/
@end
