//
//  Settings.h
//  SmartPlan
//
//  Created by Huy Le on 11/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Common.h"

@interface Settings : NSObject {
	//general
	NSInteger skinStyle;
	NSInteger weekStart;
	BOOL soundEnable;
	BOOL landscapeModeEnable;
	BOOL tabBarAutoHide;
	NSInteger filterTab;
    NSInteger snoozeDuration; //in minutes
	
	//task
	NSInteger taskDuration;
	NSInteger taskDefaultProject;
	NSInteger eventCombination;
	NSInteger movableAsEvent;
	NSInteger newTaskPlacement; //at top or at bottom of list
	NSInteger minimumSplitSize; //smallest free time slot to split task
    BOOL hideFutureTasks;
	
	//working time - no more use in v3.0 (WeekPlanner)
	NSString *weekdayStartTime;
	NSString *weekdayEndTime;
	NSString *weekendStartTime;
	NSString *weekendEndTime;
	
	//day manager
	NSString *dayManagerStartTime;
	NSString *dayManagerEndTime;
    NSDate *dayManagerUpdateTime;

	//weekday working time - use in v3.0
	NSString *monStartTime;
	NSString *monEndTime;
	NSString *tueStartTime;
	NSString *tueEndTime;
	NSString *wedStartTime;
	NSString *wedEndTime;
	NSString *thuStartTime;
	NSString *thuEndTime;
	NSString *friStartTime;
	NSString *friEndTime;
	NSString *satStartTime;
	NSString *satEndTime;
	NSString *sunStartTime;
	NSString *sunEndTime;
	
	//EK Sync
	BOOL ekAutoSyncEnabled;
    BOOL ekSyncEnabled;
    BOOL rmdSyncEnabled;
	NSInteger syncWindowStart;
	NSInteger syncWindowEnd;
    NSDate *rmdLastSyncTime;
	
	//sync direction
	NSInteger syncDirection;
	
	//hints
	BOOL eventMapHint;
	BOOL smartListHint;
    BOOL noteHint;
	BOOL weekViewHint;
	BOOL weekDayQuickAddHint;
	BOOL calendarHint;
	BOOL multiSelectHint;
	BOOL monthViewHint;
	BOOL rtDoneHint;
	BOOL syncMatchHint;
	BOOL projectHint;
	BOOL projectDetailHint;
	BOOL firstTimeEventSyncHint;
	BOOL workingTimeHint;
	BOOL starTabHint;
	BOOL gtdoTabHint;
	BOOL tagHint;
	BOOL featureHint;
    BOOL transparentHint;
    BOOL msdBackupHint;
	
	//warning
	BOOL deleteWarning;
	BOOL doneWarning;
	BOOL hideWarning;

	//Toodledo sync
	BOOL tdAutoSyncEnabled;	
    BOOL tdSyncEnabled;
	NSString *tdEmail;
	NSString *tdPassword;
	BOOL tdSyncReset; 
	NSDate *tdLastAddEditTime;
	NSDate *tdLastDeleteTime;
	NSDate *tdLastSyncTime;
    
    //SDW sync
    NSString *sdwDeviceUUID;
    NSInteger syncSource;
    BOOL sdwAutoSyncEnabled;
    BOOL sdwSyncEnabled;
    NSDate *sdwLastBackupTime;
	
	//WeekPlanner
	NSInteger weekPlannerRows;	
    
    //Must Do
    NSInteger mustDoDays;
	
	NSString *dbVersion;
	//NSString *oldAppVersion;	
	
	NSMutableDictionary *settingDict;
	NSMutableDictionary *hintDict;
	NSMutableDictionary *dayManagerDict;
	NSMutableDictionary *toodledoSyncDict;	
    NSMutableDictionary *sdwSyncDict;
    NSMutableDictionary *ekSyncDict;
    
    //NSMutableArray *filterPresets;
    NSMutableDictionary *filterPresets;
    
    BOOL isExternalUpdate;
}

@property NSInteger skinStyle;
@property NSInteger weekStart;
@property BOOL soundEnable;
@property BOOL landscapeModeEnable;
@property BOOL tabBarAutoHide;
@property NSInteger filterTab;
@property NSInteger snoozeDuration;

@property NSInteger taskDuration;
@property NSInteger taskDefaultProject;
@property NSInteger eventCombination;
@property NSInteger movableAsEvent;
@property NSInteger newTaskPlacement;
@property NSInteger minimumSplitSize;
@property BOOL hideFutureTasks;

@property (nonatomic, copy) NSString *weekdayStartTime;
@property (nonatomic, copy) NSString *weekdayEndTime;
@property (nonatomic, copy) NSString *weekendStartTime;
@property (nonatomic, copy) NSString *weekendEndTime;

@property (nonatomic, copy) NSString *dayManagerStartTime;
@property (nonatomic, copy) NSString *dayManagerEndTime;
@property (nonatomic, copy) NSDate *dayManagerUpdateTime;

@property (nonatomic, copy) NSString *monStartTime;
@property (nonatomic, copy) NSString *monEndTime;
@property (nonatomic, copy) NSString *tueStartTime;
@property (nonatomic, copy) NSString *tueEndTime;
@property (nonatomic, copy) NSString *wedStartTime;
@property (nonatomic, copy) NSString *wedEndTime;
@property (nonatomic, copy) NSString *thuStartTime;
@property (nonatomic, copy) NSString *thuEndTime;
@property (nonatomic, copy) NSString *friStartTime;
@property (nonatomic, copy) NSString *friEndTime;
@property (nonatomic, copy) NSString *satStartTime;
@property (nonatomic, copy) NSString *satEndTime;
@property (nonatomic, copy) NSString *sunStartTime;
@property (nonatomic, copy) NSString *sunEndTime;

@property BOOL syncEnabled;
@property BOOL autoSyncEnabled;
@property BOOL autoPushEnabled;

@property BOOL ekAutoSyncEnabled;
@property BOOL ekSyncEnabled;
@property BOOL rmdSyncEnabled;
@property NSInteger syncWindowStart;
@property NSInteger syncWindowEnd;
@property NSInteger syncDirection;
@property (nonatomic, copy) NSDate *rmdLastSyncTime;

@property BOOL eventMapHint;
@property BOOL smartListHint;
@property BOOL noteHint;
@property BOOL weekViewHint;
@property BOOL weekDayQuickAddHint;
@property BOOL calendarHint;
@property BOOL multiSelectHint;
@property BOOL monthViewHint;
@property BOOL rtDoneHint;
@property BOOL syncMatchHint;
@property BOOL projectHint;
@property BOOL projectDetailHint;
@property BOOL firstTimeEventSyncHint;
@property BOOL workingTimeHint;
@property BOOL starTabHint;
@property BOOL gtdoTabHint;
@property BOOL tagHint;
@property BOOL featureHint;
@property BOOL transparentHint;
@property BOOL msdBackupHint;
@property BOOL guruHint;
@property BOOL detailHint;

@property BOOL deleteWarning;
@property BOOL doneWarning;
@property BOOL hideWarning;
@property BOOL move2MMConfirmation;

@property BOOL tdAutoSyncEnabled;
@property BOOL tdSyncEnabled;
@property BOOL tdVerified;
@property (nonatomic, copy) NSString *tdEmail;
@property (nonatomic, copy) NSString *tdPassword;
@property BOOL tdSyncReset; 
@property (nonatomic, copy) NSDate *tdLastAddEditTime;
@property (nonatomic, copy) NSDate *tdLastDeleteTime;
@property (nonatomic, copy) NSDate *tdLastSyncTime;

@property (nonatomic, copy) NSString *sdwEmail;
@property (nonatomic, copy) NSString *sdwPassword;
@property (nonatomic, copy) NSString *sdwDeviceUUID;
@property NSInteger syncSource;
@property BOOL sdwAutoSyncEnabled;
@property BOOL sdwSyncEnabled;
@property BOOL sdwVerified;
@property (nonatomic, copy) NSDate *sdwLastSyncTime;
@property (nonatomic, copy) NSDate *sdwLastBackupTime;

@property NSInteger weekPlannerRows;
@property NSInteger weekPlannerColumns;

@property NSInteger mustDoDays;

@property BOOL timeZoneSupport;
@property NSInteger timeZoneID;

// geo fencing
@property BOOL geoFencingEnable;
@property NSInteger geoFencingInterval;

@property (nonatomic, copy) NSDate *updateTime;

@property (nonatomic, copy) NSString *dbVersion;
@property (nonatomic, copy) NSString *appVersion;

@property (nonatomic, retain) NSMutableDictionary *settingDict;
@property (nonatomic, retain) NSMutableDictionary *hintDict;
@property (nonatomic, retain) NSMutableDictionary *dayManagerDict;
@property (nonatomic, retain) NSMutableDictionary *toodledoSyncDict;
@property (nonatomic, retain) NSMutableDictionary *sdwSyncDict;
@property (nonatomic, retain) NSMutableDictionary *ekSyncDict;

@property (nonatomic, retain) NSMutableDictionary *filterPresets;

@property (nonatomic, retain) NSDictionary *timeZoneDict;

- (WorkingTimeInfo) getWorkingTimeInfo:(BOOL) onWeekend;
- (WorkingTimeInfo) getWorkingTimeInfoForDate:(NSDate *) date;
- (NSDate *)getWorkingStartTimeForDate:(NSDate *)date;
- (NSDate *)getWorkingEndTimeForDate:(NSDate *)date;
- (NSDate *)getWorkingStartTimeOnDay:(NSInteger) wkday;
- (NSDate *)getWorkingEndTimeOnDay:(NSInteger) wkday;
- (NSDate *)getDayManagerStartTime;
- (NSDate *)getDayManagerEndTime;
- (NSDate *)getTodayWorkingStartTime;
- (NSDate *)getTodayWorkingEndTime;
- (void) setWorkingStartTime:(NSDate *)date;
- (void) setWorkingEndTime:(NSDate *)date;
- (void) saveDayManager;
-(void)changeDBVersion:(NSString *)version;
- (BOOL) checkWorkingTimeChange:(Settings *)settings;
- (void) resetToodledoSync;
- (void) resetReminderSync;
-(void) updateSettings:(Settings *) settings;
- (UIColor *)getBackgroundColor;
- (NSDate *) getSyncWindowDate:(BOOL) isStart;
- (BOOL) isMondayAsWeekStart;
- (void) saveWeekPlannerRows:(int) rows;
- (void) changeToodledoSync;
- (void) saveWorkingTimes;
- (void) modifyUpdateTime;
- (void) enableExternalUpdate;

- (void) saveEKSync;
- (void) saveSDWSync;
- (void) resetSDWSync;
- (void) saveMSDAccount;
- (void) saveToodledoAccount;

- (void) saveSettingDict;
- (void) saveDayManagerDict;
- (void) saveHintDict;
- (void) saveToodledoSyncDict;
- (void) saveSDWSyncDict;
- (void) saveFilterPresets;

- (void) loadSettingDict;
- (void) loadDayManagerDict;
- (void) loadHintDict;
- (void) loadToodledoSyncDict;
- (void) loadSDWSyncDict;

-(void)enableEventMapHint:(BOOL)enabled;
-(void)enableSmartListHint:(BOOL)enabled;
-(void)enableNoteHint:(BOOL)enabled;
-(void)enableWeekViewHint:(BOOL)enabled;
-(void)enableWeekDayQuickAddHint:(BOOL)enabled;
-(void)enableCalendarHint:(BOOL)enabled;
-(void)enableMultiSelectHint:(BOOL)enabled;
-(void)enableMonthViewHint:(BOOL)enabled;
-(void)enableRTDoneHint:(BOOL)enabled;
-(void)enableSyncMatchHint:(BOOL)enabled;
-(void)enableProjectHint:(BOOL)enabled;
-(void)enableProjectDetailHint:(BOOL)enabled;
-(void)enableFirstTimeEventSyncHint:(BOOL)enabled;
-(void)enableWorkingTimeHint:(BOOL)enabled;
-(void)enableStarTabHint:(BOOL)enabled;
-(void)enableGTDoTabHint:(BOOL)enabled;
-(void)enableTagHint:(BOOL)enabled;
-(void)enableHideWarning:(BOOL)enabled;
-(void)enableMSDBackupHint:(BOOL)enabled;
-(void)enableGuruHint:(BOOL)enabled;
-(void)enableDetailHint:(BOOL)enabled;

-(void)enableHints;

- (void) refreshTimeZone;

+ (NSInteger) findTimeZoneID:(NSTimeZone *)tz;
+ (NSString *) getTimeZoneDisplayNameByID:(NSInteger)tzID;
+ (NSString *) getTimeZoneNameByID:(NSInteger)tzID;
+ (NSTimeZone *) getTimeZoneByID:(NSInteger)tzID;
+(void)startup;
+(id)getInstance;
+(void)free;

@end
