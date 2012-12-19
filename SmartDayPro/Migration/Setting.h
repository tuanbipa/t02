//
//  Setting.h
//  iVo_DatabaseAccess
//
//  Created by Nang Le on 4/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Setting : NSObject {
	
    // Primary key in the database.
    NSInteger	primaryKey;
    // Attributes.
	NSInteger	skinID;
	
	//for logic
	NSInteger	startWorkingWDay;
	NSInteger	endWorkingWDay;

	double		deskTimeNDStart;//work time start on week day, time in minutes, not date
	double		deskTimeNDEnd;//work time end on week day, time in minutes, not date
	double		deskTimeWEStart;//work time start on weekend day, time in minutes, not date
	double		deskTimeWEEnd;//work time end on weekend day, time in minutes, not date
	
	//for default values
	double		durationDefEventVal;
	double		durationDefTaskVal;//task duration
	
	NSInteger	contextDefID;//context: home/work
    NSInteger	calendarDefID;
	NSInteger	isFlexibleDefaultDuration;//0: fixed duration setting; 1: dynamic duration setting (get recent used)
	NSInteger	isFlexibleDefaultCalendar;//0: fixed Project setting; 1: dynamic Project setting (get recent used)
	
	//Gcal sync
	NSString	*gCalAccountID;
	NSString	*gCalAccountPassword;
	NSDate		*gCalLastSyncedTime; 
	NSString	*gCalDeleteItemsInTaskList; 
	NSInteger	gCalSyncType;
	NSInteger	gCalSyncWindowStart;
	NSInteger	gCalSyncWindowEnd;
	NSInteger	enableSyncGcal;
	NSString	*gcalDeletedCalendars;
	
	//General
	NSInteger	isWarningForDeleting;
	NSInteger	numberOfRestartTimes;
	NSInteger	badgeType;
	NSInteger	weekStartDay;
	NSString	*previousDevToken;
	NSInteger	cleanOldThanDays; //0: never clean; >0: clean after a number days
	NSInteger	isMultiSelection;
	
	NSInteger	snoozeDuration;
	NSInteger	snoozeUnit;
	NSInteger	taskTypeDefault;//0: duration task; 1: list task
	
	NSDate		*dayManagerStart;
	NSDate		*dayManagerEnd;
	NSDate		*dayManagerForDate;

	NSInteger	showNeededShoppingItemOnly;
	NSInteger	defaultListId;
	NSDate		*shutDownTime;
	
	//Toodledo Sync
	NSString	*toodledoToken;
	NSDate		*toodledoTokenTime;
	NSString	*toodledoUserId;
	NSString	*toodledoUserName;
	NSString	*toodledoPassword;
	NSString	*toodledoKey;
	NSDate		*toodledoSyncTime;
	NSInteger	toodledoSyncType;
	NSString	*toodledoDeletedFolders;
	NSInteger	isFirstTimeToodledoSync;
	NSString	*toodledoDeletedTasks;
	NSInteger	enableSyncToodledo;
	NSInteger	autoTDSync;
	
	//iCal sync
	NSInteger	iCalSyncWindowStart;
	NSInteger	iCalSyncWindowEnd;
	NSString	*deletedICalCalendars;
	NSString	*deletedICalEvents;
	NSDate		*iCalLastSyncTime;
	NSInteger	autoICalSync;
	
	//UI uses
	double	landscapeUISizeRatio;//37.5%, 75%, 100%
	double	portraitUISizeRatio;//50%, 100%
	
	NSInteger	isAutoSyncToodledo;
	NSInteger	isAutoSyncGcal;
	NSInteger	moveTaskInCalendar;
	
	NSInteger	showFaded;
	NSInteger	hasFirstTimeStarted;
	NSInteger	needInformSyncAtStart;
	NSInteger	syncDisplayedGcalOnly;
	
	NSInteger	noNeedMultiSelectHint;
	
	NSInteger	dontShowDefaultViewHint;
	NSInteger	dontShowDayViewHint;
	
	NSInteger	dontShowTaskViewHint;
	NSInteger	dontShowMonthViewHint;
	NSInteger	dontShowNoteViewHint;
	NSInteger	dontShowGcalSetupViewHint;
	NSInteger	dontShowTDSetupViewHint;
	NSInteger	dontShowProjectViewHint;
	
	NSTimeInterval gmtSecondsValue;
	NSInteger	isEKSync;
	
	NSInteger	lastEventSyncType;
	
	NSInteger	zenScreenAtOpen;
	
	NSInteger	filterIndex;
	
	NSInteger	projectViewType;
	NSInteger	dontShowHideTaskHint;
	NSInteger	newTaskAtTop;
	NSInteger	noteFontIndex;
	
	//local uses
	NSDate		*loadedREFromDate;
	NSDate		*loadedREToDate;
	NSInteger	hasReconcileDSTForVersion21;
    
	NSInteger	hasToodledoFirstTimeSynced;
    
    NSInteger   taskSyncSource;
    NSString    *SDWAccUserName;
    NSString    *SDWAccPassword;
    NSString    *SDWDeletedCalendars;
    NSDate      *SDWLastSyncTime;
    
    NSInteger    SDWautoSync;
    NSDate      *SDWTokenTime;
    NSString    *SDWToken;
    NSString    *SDWKey;
    NSInteger	hasSDWFirstTimeSynced;
    NSString    *SDWDeletedTasks;
    
    NSInteger   syncSourceOption;//SDW or Others
    NSInteger   needReplaceSyncData;
    
    NSDate      *lastTasksUpdate;
    NSDate      *lastCalendarsUpdate;
    NSDate      *dateUpdate;
    
    NSInteger   playTimerSound;
	// Internal state variables. Hydrated tracks whether attribute data is in the object or the database.
    BOOL		hydrated;
    // Dirty tracks whether there are in-memory changes to data which have no been written to the database.
    BOOL		dirty;
    NSData		*data;
	
}

@property(nonatomic,assign) NSInteger	primaryKey;
// Attributes.
@property(nonatomic,assign) NSInteger	skinID;

//for logic
@property(nonatomic,assign) NSInteger startWorkingWDay;
@property(nonatomic,assign) NSInteger endWorkingWDay;

@property(nonatomic,assign) double	deskTimeNDStart;//work time start on week day, time in minutes, not date
@property(nonatomic,assign) double	deskTimeNDEnd;//work time end on week day, time in minutes, not date
@property(nonatomic,assign) double	deskTimeWEStart;//work time start on weekend day, time in minutes, not date
@property(nonatomic,assign) double	deskTimeWEEnd;//work time end on weekend day, time in minutes, not date

//@property(nonatomic,assign) double	homeTimeNDStart;//home time start on week day, time in minutes, not date
//@property(nonatomic,assign) double	homeTimeNDEnd;//home time end on week day, time in minutes, not date
//@property(nonatomic,assign) double	homeTimeWEStart;//home time star on weekend day, time in minutes, not date
//@property(nonatomic,assign) double	homeTimeWEEnd;//home time end on weekend day, time in minutes, not date

//for default values
@property(nonatomic,assign) double durationDefEventVal;//event duration
@property(nonatomic,assign) double durationDefTaskVal;//task duration

@property(nonatomic,assign) NSInteger contextDefID;//context: home/work
@property(nonatomic,assign) NSInteger	calendarDefID;
@property(nonatomic,assign) NSInteger	isFlexibleDefaultDuration;//0: fixed duration setting; 1: dynamic duration setting (get recent used)
@property(nonatomic,assign) NSInteger	isFlexibleDefaultCalendar;//0: fixed Project setting; 1: dynamic Project setting (get recent used)

//Gcal sync
@property(nonatomic,copy)	NSString	*gCalAccountID;
@property(nonatomic,copy)	NSString	*gCalAccountPassword;
@property(nonatomic,copy)	NSDate		*gCalLastSyncedTime; 
@property(nonatomic,copy)	NSString	*gCalDeleteItemsInTaskList; 
@property(nonatomic,assign) NSInteger	gCalSyncType;
@property(nonatomic,assign) NSInteger	gCalSyncWindowStart;
@property(nonatomic,assign) NSInteger	gCalSyncWindowEnd;
@property(nonatomic,copy)	NSString	*gcalDeletedCalendars;

//General
@property(nonatomic,assign) NSInteger	isWarningForDeleting;
@property(nonatomic,assign) NSInteger	numberOfRestartTimes;
@property(nonatomic,assign) NSInteger	badgeType;
@property(nonatomic,assign) NSInteger	weekStartDay;
@property(nonatomic,copy)	NSString	*previousDevToken;
@property(nonatomic,assign) NSInteger	cleanOldThanDays; //0: never clean; >0: clean after a number days
@property(nonatomic,assign) NSInteger	isMultiSelection;

@property(nonatomic,assign)	NSInteger	snoozeDuration;
@property(nonatomic,assign)	NSInteger	snoozeUnit;
@property(nonatomic,assign)	NSInteger	taskTypeDefault;//0: duration task; 1: list task

@property(nonatomic,copy)	NSDate	*dayManagerStart;
@property(nonatomic,copy)	NSDate	*dayManagerEnd;
@property(nonatomic,copy)   NSDate	*dayManagerForDate;

@property(nonatomic,assign) NSInteger	showNeededShoppingItemOnly;
@property(nonatomic,assign) NSInteger	defaultListId;
@property(nonatomic,copy)	NSDate		*shutDownTime;

//Toodledo Sync
@property(nonatomic,copy) 	NSString	*toodledoToken;
@property(nonatomic,copy) 	NSDate		*toodledoTokenTime;
@property(nonatomic,copy) 	NSString	*toodledoUserId;
@property(nonatomic,copy) 	NSString	*toodledoUserName;
@property(nonatomic,copy) 	NSString	*toodledoPassword;
@property(nonatomic,copy) 	NSString	*toodledoKey;
@property(nonatomic,copy) 	NSDate		*toodledoSyncTime;
@property(nonatomic,assign) NSInteger	toodledoSyncType;
@property(nonatomic,copy) 	NSString	*toodledoDeletedFolders;
@property(nonatomic,assign) NSInteger	isFirstTimeToodledoSync;
@property(nonatomic,copy) 	NSString	*toodledoDeletedTasks;

//Gcal sync
@property(nonatomic,assign) NSInteger	enableSyncGcal;
@property(nonatomic,assign) NSInteger	enableSyncToodledo;
@property(nonatomic,assign) NSInteger	syncDisplayedGcalOnly;

//iCal sync
@property(nonatomic,assign) NSInteger	iCalSyncWindowStart;
@property(nonatomic,assign) NSInteger	iCalSyncWindowEnd;
@property(nonatomic,copy) 	NSString	*deletedICalEvents;
@property(nonatomic,copy) 	NSDate		*iCalLastSyncTime;

//UI uses
@property(nonatomic,assign) double	landscapeUISizeRatio;//37.5%, 75%, 100%
@property(nonatomic,assign) double	portraitUISizeRatio;//50%, 100%

@property(nonatomic,assign) NSInteger	isAutoSyncToodledo;
@property(nonatomic,assign) NSInteger	isAutoSyncGcal;
@property(nonatomic,assign) NSInteger	moveTaskInCalendar;
@property(nonatomic,assign) NSInteger	showFaded;
@property(nonatomic,assign) NSInteger	hasFirstTimeStarted;
@property(nonatomic,assign) NSInteger	needInformSyncAtStart;

//hints
@property(nonatomic,assign) NSInteger	noNeedMultiSelectHint;
@property(nonatomic,assign) NSInteger	dontShowDefaultViewHint;
@property(nonatomic,assign) NSInteger	dontShowDayViewHint;

@property(nonatomic,assign) NSInteger	dontShowTaskViewHint;
@property(nonatomic,assign) NSInteger	dontShowMonthViewHint;
@property(nonatomic,assign) NSInteger	dontShowNoteViewHint;
@property(nonatomic,assign) NSInteger	dontShowGcalSetupViewHint;
@property(nonatomic,assign) NSInteger	dontShowTDSetupViewHint;

@property(nonatomic,assign) NSTimeInterval gmtSecondsValue;
@property(nonatomic,assign) NSInteger	isEKSync;

@property (nonatomic,assign) NSInteger	lastEventSyncType;
@property (nonatomic,assign) NSInteger	zenScreenAtOpen;

@property (nonatomic,assign) NSInteger	projectViewType;
@property (nonatomic,assign) NSInteger	dontShowHideTaskHint;
@property (nonatomic,assign) NSInteger	newTaskAtTop;
@property (nonatomic,assign) NSInteger	noteFontIndex;

//local uses
@property(nonatomic, retain) NSDate		*loadedREFromDate;
@property(nonatomic, retain) NSDate		*loadedREToDate;

@property(nonatomic,assign) NSInteger	filterIndex;

@property(nonatomic,assign) NSInteger	dontShowProjectViewHint;
@property(nonatomic,assign) NSInteger	hasReconcileDSTForVersion21;
@property(nonatomic,assign) NSInteger	autoTDSync;
@property(nonatomic,assign) NSInteger	autoICalSync;
@property(nonatomic,assign) NSInteger	hasToodledoFirstTimeSynced;
@property(nonatomic,copy) 	NSString	*deletedICalCalendars;

@property(nonatomic,assign) NSInteger   taskSyncSource;
@property(nonatomic,copy) NSString    *SDWAccUserName;
@property(nonatomic,copy) NSString    *SDWAccPassword;
@property(nonatomic,copy) NSString    *SDWDeletedCalendars;
@property(nonatomic,copy) NSDate      *SDWLastSyncTime;

@property(nonatomic,copy) NSDate      *SDWTokenTime;
@property(nonatomic,copy) NSString    *SDWToken;
@property(nonatomic,copy) NSString    *SDWKey;

@property(nonatomic,assign) NSInteger	hasSDWFirstTimeSynced;
@property(nonatomic,copy) NSString    *SDWDeletedTasks;
@property(nonatomic,assign) NSInteger   syncSourceOption;//SDW or Others
@property(nonatomic,assign) NSInteger    SDWautoSync;
@property(nonatomic,assign) NSInteger   needReplaceSyncData;

@property(nonatomic,copy) NSDate      *lastTasksUpdate;
@property(nonatomic,copy) NSDate      *lastCalendarsUpdate;
@property(nonatomic,copy) NSDate      *dateUpdate;
@property(nonatomic,assign) NSInteger   playTimerSound;

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;
- (void)insertIntoDatabase:(sqlite3 *)db ;
- (void)deleteFromDatabase;
- (void)dehydrate;
+ (void)finalizeStatements;

@end
