//
//  Setting.m
//  iVo_DatabaseAccess
//
//  Created by Nang Le on 4/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Setting.h"
#import <sqlite3.h>
#import "MigrationData.h"

extern sqlite3 *database;
extern double			gmtSeconds; 
extern BOOL isSyncing;
extern BOOL     isLockingDB;

static sqlite3_stmt *insert_statement = nil;
static sqlite3_stmt *init_statement = nil;
static sqlite3_stmt *delete_statement = nil;
static sqlite3_stmt *hydrate_statement = nil;
static sqlite3_stmt *dehydrate_statement = nil;

@implementation Setting
@synthesize loadedREFromDate;
@synthesize loadedREToDate;

+ (void)finalizeStatements {
    if (insert_statement) {
        sqlite3_finalize(insert_statement);
        insert_statement = nil;
    }
    if (init_statement) {
        sqlite3_finalize(init_statement);
        init_statement = nil;
    }
    if (delete_statement) {
        sqlite3_finalize(delete_statement);
        delete_statement = nil;
    }
    if (hydrate_statement) {
        sqlite3_finalize(hydrate_statement);
        hydrate_statement = nil;
    }
    if (dehydrate_statement) {
        sqlite3_finalize(dehydrate_statement);
        dehydrate_statement = nil;
    }
	
}

-(id)init{
	if (self=[super init]) {
		self.loadedREFromDate=[NSDate date];
		self.loadedREToDate=[NSDate date];
	}
	
	return self; 
}

// Creates the object with primary key and title is brought into memory.
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db {
    if (self = [super init]) {
        while (isLockingDB) {
            //usleep(20);
        [NSThread sleepForTimeInterval:0.01];
        }
        isLockingDB=YES;

        primaryKey = pk;
        // Compile the query for retrieving book data. See insertNewBookIntoDatabase: for more detail.
        if (init_statement == nil) {
            // Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
            // This is a great way to optimize because frequently used queries can be compiled once, then with each
            // use new variable values can be bound to placeholders.
            const char *sql = "SELECT skinID,\
			startWorkingWDay,\
			endWorkingWDay,\
			deskTimeNDStart,\
			deskTimeNDEnd,\
			deskTimeWEStart,\
			deskTimeWEEnd,\
			durationDefTaskVal,\
			contextDefID,\
			calendarDefID,\
			isFlexibleDefaultDuration,\
			isFlexibleDefaultCalendar,\
			gCalAccountID,\
			gCalAccountPassword,\
			gCalLastSyncedTime,\
			gCalDeleteItemsInTaskList,\
			gCalSyncType,\
			gCalSyncWindowStart,\
			gCalSyncWindowEnd,\
			isWarningForDeleting,\
			numberOfRestartTimes,\
			badgeType,\
			weekStartDay,\
			previousDevToken,\
			cleanOldThanDays,\
			isMultiSelection,\
			snoozeDuration,\
			snoozeUnit,\
			taskTypeDefault,\
			dayManagerStart,\
			dayManagerEnd,\
			dayManagerForDate,\
			showNeededShoppingItemOnly,\
			defaultListId,\
			toodledoToken,\
			toodledoTokenTime,\
			toodledoUserId,\
			toodledoUserName,\
			toodledoPassword,\
			toodledoKey,\
			toodledoSyncTime,\
			toodledoSyncType,\
			toodledoDeletedFolders,\
			isFirstTimeToodledoSync,\
			toodledoDeletedTasks,\
			landscapeUISizeRatio,\
			portraitUISizeRatio,\
			durationDefEventVal,\
			isAutoSyncToodledo,\
			isAutoSyncGcal,\
			moveTaskInCalendar,\
			showFaded,\
			shutDownTime,\
			enableSyncGcal,\
			enableSyncToodledo,\
			hasFirstTimeStarted,\
			needInformSyncAtStart,\
			syncDisplayedGcalOnly,\
			noNeedMultiSelectHint,\
			gcalDeletedCalendars,\
			dontShowDefaultViewHint,\
			dontShowDayViewHint,\
			dontShowTaskViewHint,\
			dontShowMonthViewHint,\
			dontShowNoteViewHint,\
			dontShowGCalSetupViewHint,\
			dontShowTDSetupViewHint,\
			gmtSecondsValue,\
			isEKSync,\
			iCalSyncWindowStart,\
			iCalSyncWindowEnd,\
			deletedICalEvents,\
			iCalLastSyncTime,\
			lastEventSyncType,\
			zenScreenAtOpen,\
			filterIndex,\
			projectViewType,\
			dontShowHideTaskHint,\
			newTaskAtTop,\
			noteFontIndex,\
			dontShowProjectViewHint,\
			hasReconcileDSTForVersion21,\
			autoTDSync,\
			autoICalSync,\
			hasToodledoFirstTimeSynced,\
            deletedICalCalendars,\
            taskSyncSource,\
            SDWAccUserName,\
            SDWAccPassword,\
            SDWDeletedCalendars,\
            SDWLastSyncTime,\
            SDWTokenTime,\
            SDWToken,\
            SDWKey,\
            hasSDWFirstTimeSynced,\
            SDWDeletedTasks,\
            syncSourceOption,\
            SDWautoSync,\
            needReplaceSyncData,\
            lastTasksUpdate,\
            lastCalendarsUpdate,\
            dateUpdate,\
            playTimerSound \
			FROM Settings WHERE primaryKey=?";
            if (sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // For this query, we bind the primary key to the first (and only) placeholder in the statement.
        // Note that the parameters are numbered from 1, not from 0.
        sqlite3_bind_int(init_statement, 1, primaryKey);
        if (sqlite3_step(init_statement) == SQLITE_ROW) {
			self.skinID =sqlite3_column_int(init_statement, 0);
			self.startWorkingWDay=sqlite3_column_int(init_statement, 1);
			self.endWorkingWDay=sqlite3_column_int(init_statement, 2);
			
			self.deskTimeNDStart=sqlite3_column_double(init_statement, 3);
			self.deskTimeNDEnd=sqlite3_column_double(init_statement, 4);
			self.deskTimeWEStart=sqlite3_column_double(init_statement, 5);
			self.deskTimeWEEnd=sqlite3_column_double(init_statement, 6);
			
//			self.homeTimeNDStart=sqlite3_column_double(init_statement, 7);
//			self.homeTimeNDEnd=sqlite3_column_double(init_statement, 8);
//			self.homeTimeWEStart=sqlite3_column_double(init_statement, 9);
//			self.homeTimeWEEnd=sqlite3_column_double(init_statement, 10);
			
			//for default values
			self.durationDefTaskVal=sqlite3_column_double(init_statement, 7);
			self.contextDefID=sqlite3_column_int(init_statement, 8);
			self.calendarDefID=sqlite3_column_int(init_statement, 9);
			self.isFlexibleDefaultDuration=sqlite3_column_int(init_statement, 10);
			self.isFlexibleDefaultCalendar=sqlite3_column_int(init_statement, 11);
			
			//Gcal sync
			char *uid=(char *)sqlite3_column_text(init_statement, 12);
			self.gCalAccountID=(uid)?[NSString stringWithUTF8String:uid] : @"";
			
			char *upd=(char *)sqlite3_column_text(init_statement, 13);
			self.gCalAccountPassword=(upd)?[NSString stringWithUTF8String:upd] : @"";
			
			self.gCalLastSyncedTime=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 14)];

			char *delGcalItems=(char *)sqlite3_column_text(init_statement, 15);
			self.gCalDeleteItemsInTaskList=(delGcalItems)?[NSString stringWithUTF8String:delGcalItems] : @"";

			self.gCalSyncType=sqlite3_column_int(init_statement, 16);
			self.gCalSyncWindowStart=sqlite3_column_int(init_statement, 17);
			self.gCalSyncWindowEnd=sqlite3_column_int(init_statement, 18);
			
			//General
			self.isWarningForDeleting=sqlite3_column_int(init_statement, 19);
			self.numberOfRestartTimes=sqlite3_column_int(init_statement, 20);
			self.badgeType=sqlite3_column_int(init_statement, 21);
			self.weekStartDay=sqlite3_column_int(init_statement, 22);
			
			char *lastToken=(char *)sqlite3_column_text(init_statement, 23);
			self.previousDevToken=(lastToken)?[NSString stringWithUTF8String:lastToken] : @"";

			self.cleanOldThanDays=sqlite3_column_int(init_statement, 24);
			self.isMultiSelection=sqlite3_column_int(init_statement, 25);
			self.snoozeDuration=sqlite3_column_int(init_statement, 26);
			self.snoozeUnit=sqlite3_column_int(init_statement, 27);
			self.taskTypeDefault=sqlite3_column_int(init_statement, 28);
			
			self.dayManagerStart=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 29)-gmtSeconds];
			self.dayManagerEnd=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 30)-gmtSeconds];
			self.dayManagerForDate=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 31)-gmtSeconds];
			
			self.showNeededShoppingItemOnly=sqlite3_column_int(init_statement, 32);
			self.defaultListId=sqlite3_column_int(init_statement, 33);
			
			//toodledoToken
			char *token=(char *)sqlite3_column_text(init_statement, 34);
			self.toodledoToken=(token)?[NSString stringWithUTF8String:token] : @"";
			
			self.toodledoTokenTime=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 35)];
			
			char *usrid=(char *)sqlite3_column_text(init_statement, 36);
			self.toodledoUserId=(usrid)?[NSString stringWithUTF8String:usrid] : @"";
			
			char *usrname=(char *)sqlite3_column_text(init_statement, 37);
			self.toodledoUserName=(usrname)?[NSString stringWithUTF8String:usrname] : @"";
			
			char *password=(char *)sqlite3_column_text(init_statement, 38);
			self.toodledoPassword=(password)?[NSString stringWithUTF8String:password] : @"";

			char *key=(char *)sqlite3_column_text(init_statement, 39);
			self.toodledoKey=(key)?[NSString stringWithUTF8String:key] : @"";
			
			self.toodledoSyncTime=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 40)];
			self.toodledoSyncType=sqlite3_column_int(init_statement, 41);
			
			char *deletedKeys=(char *)sqlite3_column_text(init_statement, 42);
			self.toodledoDeletedFolders=(deletedKeys)?[NSString stringWithUTF8String:deletedKeys] : @"";
			
			self.isFirstTimeToodledoSync=sqlite3_column_int(init_statement, 43);
			
			char *deletedTasks=(char *)sqlite3_column_text(init_statement, 44);
			self.toodledoDeletedTasks=(deletedTasks)?[NSString stringWithUTF8String:deletedTasks] : @"";
			
			self.landscapeUISizeRatio=sqlite3_column_double(init_statement, 45);
			self.portraitUISizeRatio=sqlite3_column_double(init_statement, 46);
			self.durationDefEventVal=sqlite3_column_double(init_statement, 47);
			
			self.isAutoSyncToodledo=sqlite3_column_int(init_statement, 48);
			self.isAutoSyncGcal=sqlite3_column_int(init_statement, 49);
			self.moveTaskInCalendar=sqlite3_column_int(init_statement, 50);
			self.showFaded=sqlite3_column_int(init_statement, 51);
			
			self.shutDownTime=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 52)];
			self.enableSyncGcal=sqlite3_column_int(init_statement, 53);
			self.enableSyncToodledo=sqlite3_column_int(init_statement, 54);
			self.hasFirstTimeStarted=sqlite3_column_int(init_statement, 55);
			self.needInformSyncAtStart=sqlite3_column_int(init_statement, 56);
			self.syncDisplayedGcalOnly=sqlite3_column_int(init_statement, 57);
			self.noNeedMultiSelectHint=sqlite3_column_int(init_statement, 58);
			
			char *deletedCals=(char *)sqlite3_column_text(init_statement, 59);
			self.gcalDeletedCalendars=(deletedCals)?[NSString stringWithUTF8String:deletedCals] : @"";
			
			self.dontShowDefaultViewHint=sqlite3_column_int(init_statement, 60);
			self.dontShowDayViewHint=sqlite3_column_int(init_statement, 61);
			
			self.dontShowTaskViewHint=sqlite3_column_int(init_statement, 62);
			self.dontShowMonthViewHint=sqlite3_column_int(init_statement, 63);
			self.dontShowNoteViewHint=sqlite3_column_int(init_statement, 64);
			self.dontShowGcalSetupViewHint=sqlite3_column_int(init_statement, 65);
			self.dontShowTDSetupViewHint=sqlite3_column_int(init_statement, 66);
			
			self.gmtSecondsValue=sqlite3_column_double(init_statement, 67);
			self.isEKSync=sqlite3_column_double(init_statement, 68);
			
			self.iCalSyncWindowStart=sqlite3_column_double(init_statement, 69);
			self.iCalSyncWindowEnd=sqlite3_column_double(init_statement, 70);
			
			//deletedICalEvents
			char *deletedICalsEvents=(char *)sqlite3_column_text(init_statement, 71);
			self.deletedICalEvents=(deletedICalsEvents)?[NSString stringWithUTF8String:deletedICalsEvents] : @"";
			
			self.iCalLastSyncTime=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 72)];
			self.lastEventSyncType=sqlite3_column_int(init_statement, 73);
			
			//zenScreenAtOpen
			self.zenScreenAtOpen=sqlite3_column_int(init_statement, 74);
			
			self.filterIndex=sqlite3_column_int(init_statement, 75);
			
			self.projectViewType=sqlite3_column_int(init_statement, 76);
			self.dontShowHideTaskHint=sqlite3_column_int(init_statement, 77);
			self.newTaskAtTop=sqlite3_column_int(init_statement, 78);
			self.noteFontIndex=sqlite3_column_int(init_statement, 79);
			self.dontShowProjectViewHint=sqlite3_column_int(init_statement, 80);
			self.hasReconcileDSTForVersion21=sqlite3_column_int(init_statement, 81);
			self.autoTDSync=sqlite3_column_int(init_statement, 82);
			self.autoICalSync=sqlite3_column_int(init_statement, 83);
			self.hasToodledoFirstTimeSynced=sqlite3_column_int(init_statement, 84);
            
            char *deletedICalsCals=(char *)sqlite3_column_text(init_statement, 85);
			self.deletedICalCalendars=(deletedICalsCals)?[NSString stringWithUTF8String:deletedICalsCals] : @"";

            self.taskSyncSource=sqlite3_column_int(init_statement, 86);
            
            char *swdusr=(char *)sqlite3_column_text(init_statement, 87);
			self.SDWAccUserName=(swdusr)?[NSString stringWithUTF8String:swdusr] : @"";

            char *swdpwd=(char *)sqlite3_column_text(init_statement, 88);
			self.SDWAccPassword=(swdpwd)?[NSString stringWithUTF8String:swdpwd] : @"";

            //SDWDeletedCalendars
            char *delSDWCal=(char *)sqlite3_column_text(init_statement, 89);
			self.SDWDeletedCalendars=(delSDWCal)?[NSString stringWithUTF8String:delSDWCal] : @"";
            
            //SDWLastSyncTime
            self.SDWLastSyncTime=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 90)];
            
            self.SDWTokenTime=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 91)];
            
            char *sdwtoken=(char *)sqlite3_column_text(init_statement, 92);
			self.SDWToken=(sdwtoken)?[NSString stringWithUTF8String:sdwtoken] : @"";
            
            //SDWKey
            char *sdwkey=(char *)sqlite3_column_text(init_statement, 93);
			self.SDWKey=(sdwkey)?[NSString stringWithUTF8String:sdwkey] : @"";
            
            self.hasSDWFirstTimeSynced=sqlite3_column_int(init_statement, 94);
            
            char *sdwdeltasks=(char *)sqlite3_column_text(init_statement, 95);
			self.SDWDeletedTasks=(sdwdeltasks)?[NSString stringWithUTF8String:sdwdeltasks] : @"";
            
            self.syncSourceOption=sqlite3_column_int(init_statement, 96);
            
            self.SDWautoSync=sqlite3_column_int(init_statement, 97);
            self.needReplaceSyncData=sqlite3_column_int(init_statement, 98);
            
            //lastTasksUpdate
            self.lastTasksUpdate=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 99)];
            self.lastCalendarsUpdate=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 100)];
            
            self.dateUpdate=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 101)];
            
            self.playTimerSound=sqlite3_column_int(init_statement, 102);
        } else {
			
        }
        // Reset the statement for future reuse.
        sqlite3_reset(init_statement);
        dirty = NO;
        isLockingDB=NO;
    }
    return self;
}

-(void)dealloc{
	[gCalAccountID release];
	[gCalAccountPassword release];
	[gCalLastSyncedTime release];
	[gCalDeleteItemsInTaskList release];
	
	[previousDevToken release];
	[dayManagerEnd release];
	[dayManagerForDate release];
	
	[toodledoSyncTime release];
	[toodledoUserId release];
	[toodledoUserName release];
	[toodledoPassword release];
	[toodledoKey release];
	[toodledoToken release];
	[toodledoTokenTime release];
	[toodledoDeletedFolders release];
	[toodledoDeletedTasks release];
	[shutDownTime release];
	
	[gcalDeletedCalendars release];
	[deletedICalEvents release];
	[iCalLastSyncTime release];
	
    [deletedICalCalendars release];
    
    [SDWAccUserName release];
    [SDWAccPassword release];
    
    [SDWDeletedCalendars release];
    [SDWLastSyncTime release];
    
    [SDWTokenTime release];
    [SDWToken release];
    
    [SDWKey release];
    
    [SDWDeletedTasks release];
    
    [lastTasksUpdate release];
    [lastCalendarsUpdate release];
    [dateUpdate release];
	[super dealloc];
}

- (void)insertIntoDatabase:(sqlite3 *)db {
    while (isLockingDB) {
        //usleep(20);
        [NSThread sleepForTimeInterval:0.01];
    }
    isLockingDB=YES;

    // This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed by any Book object.
    if (insert_statement == nil) {
        static char *sql = "INSERT INTO Settings (skinID) VALUES(?)";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    sqlite3_bind_int(dehydrate_statement, 1, self.skinID);
	
    int success = sqlite3_step(insert_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(insert_statement);
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
    } else {
        // SQLite provides a method which retrieves the value of the most recently auto-generated primary key sequence
        // in the database. To access this functionality, the table should have a column declared of type 
        // "INTEGER PRIMARY KEY"
        primaryKey = sqlite3_last_insert_rowid(database);
    }
    // All data for the book is already in memory, but has not be written to the database
    // Mark as hydrated to prevent empty/default values from overwriting what is in memory
    hydrated = YES;
    isLockingDB=NO;
}

- (void)deleteFromDatabase {
    while (isLockingDB) {
        //usleep(20);
        [NSThread sleepForTimeInterval:0.01];
    }
    isLockingDB=YES;

    // Compile the delete statement if needed.
    if (delete_statement == nil) {
        const char *sql = "DELETE FROM Settings WHERE primaryKey=?";
        if (sqlite3_prepare_v2(database, sql, -1, &delete_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    // Bind the primary key variable.
    sqlite3_bind_int(delete_statement, 1, primaryKey);
    // Execute the query.
    int success = sqlite3_step(delete_statement);
    // Reset the statement for future use.
    sqlite3_reset(delete_statement);
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }
    
    isLockingDB=NO;
}

- (void)dehydrate{
    while (isLockingDB) {
        //usleep(20);
        [NSThread sleepForTimeInterval:0.01];
    }
    isLockingDB=YES;

    if (dirty) {
        // Write any changes to the database.
        // First, if needed, compile the dehydrate query.
        if (dehydrate_statement == nil) {
            const char *sql = "UPDATE Settings SET skinID=?,startWorkingWDay=?,endWorkingWDay=?,deskTimeNDStart=?,deskTimeNDEnd=?,deskTimeWEStart=?,deskTimeWEEnd=?,durationDefTaskVal=?,contextDefID=?,calendarDefID=?,isFlexibleDefaultDuration=?,isFlexibleDefaultCalendar=?,gCalAccountID=?,gCalAccountPassword=?,gCalLastSyncedTime=?,gCalDeleteItemsInTaskList=?,gCalSyncType=?,gCalSyncWindowStart=?,gCalSyncWindowEnd=?,isWarningForDeleting=?,numberOfRestartTimes=?,badgeType=?,weekStartDay=?,previousDevToken=?,cleanOldThanDays=?,isMultiSelection=?,snoozeDuration=?,snoozeUnit=?,taskTypeDefault=?,dayManagerStart=?,dayManagerEnd=?,dayManagerForDate=?,showNeededShoppingItemOnly=?,defaultListId=?,toodledoToken=?,toodledoTokenTime=?,toodledoUserId=?,toodledoUserName=?,toodledoPassword=?,toodledoKey=?,toodledoSyncTime=?,toodledoSyncType=?,toodledoDeletedFolders=?,isFirstTimeToodledoSync=?,toodledoDeletedTasks=?,landscapeUISizeRatio=?,portraitUISizeRatio=?,durationDefEventVal=?,isAutoSyncToodledo=?,isAutoSyncGcal=?,moveTaskInCalendar=?,showFaded=?,shutDownTime=?,enableSyncGcal=?,enableSyncToodledo=?,hasFirstTimeStarted=?,needInformSyncAtStart=?,syncDisplayedGcalOnly=?,noNeedMultiSelectHint=?,gcalDeletedCalendars=?,dontShowDefaultViewHint=?,dontShowDayViewHint=?,dontShowTaskViewHint=?,dontShowMonthViewHint=?,dontShowNoteViewHint=?,dontShowGcalSetupViewHint=?,dontShowTDSetupViewHint=?,gmtSecondsValue=?,isEKSync=?,iCalSyncWindowStart=?,iCalSyncWindowEnd=?,deletedICalEvents=?,iCalLastSyncTime=?,lastEventSyncType=?,zenScreenAtOpen=?,filterIndex=?,projectViewType=?,dontShowHideTaskHint=?,newTaskAtTop=?,noteFontIndex=?,dontShowProjectViewHint=?,hasReconcileDSTForVersion21=?,autoTDSync=?,autoICalSync=?,hasToodledoFirstTimeSynced=?,deletedICalCalendars=?,taskSyncSource=?,SDWAccUserName=?,SDWAccPassword=?,SDWDeletedCalendars=?,SDWLastSyncTime=?,SDWTokenTime=?,SDWToken=?,SDWKey=?,hasSDWFirstTimeSynced=?,SDWDeletedTasks=?,syncSourceOption=?,SDWautoSync=?,needReplaceSyncData=?,lastTasksUpdate=?,lastCalendarsUpdate=?,dateUpdate=?,playTimerSound=? WHERE primaryKey=?";
            if (sqlite3_prepare_v2(database, sql, -1, &dehydrate_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        
		self.dateUpdate=[NSDate date];
		sqlite3_bind_int(dehydrate_statement,1,self.skinID);
		sqlite3_bind_int(dehydrate_statement,2,self.startWorkingWDay);
		sqlite3_bind_int(dehydrate_statement,3,self.endWorkingWDay);
		
		sqlite3_bind_double(dehydrate_statement,4,self.deskTimeNDStart);
		sqlite3_bind_double(dehydrate_statement,5,self.deskTimeNDEnd);
		sqlite3_bind_double(dehydrate_statement,6,self.deskTimeWEStart);
		sqlite3_bind_double(dehydrate_statement,7,self.deskTimeWEEnd);
		
//		sqlite3_bind_double(dehydrate_statement,8,self.homeTimeNDStart);
//		sqlite3_bind_double(dehydrate_statement,9,self.homeTimeNDEnd);
//		sqlite3_bind_double(dehydrate_statement,10,self.homeTimeWEStart);
//		sqlite3_bind_double(dehydrate_statement,11,self.homeTimeWEEnd);
		
		//for default values
		sqlite3_bind_double(dehydrate_statement, 8,self.durationDefTaskVal);
		sqlite3_bind_int(dehydrate_statement, 9,self.contextDefID);
		sqlite3_bind_int(dehydrate_statement, 10,self.calendarDefID);
		sqlite3_bind_int(dehydrate_statement, 11,self.isFlexibleDefaultDuration);
		sqlite3_bind_int(dehydrate_statement, 12,self.isFlexibleDefaultCalendar);
		
		//Gcal sync
		sqlite3_bind_text(dehydrate_statement, 13, [self.gCalAccountID UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(dehydrate_statement, 14, [self.gCalAccountPassword UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_double(dehydrate_statement, 15, [self.gCalLastSyncedTime timeIntervalSince1970]);
		sqlite3_bind_text(dehydrate_statement, 16, [self.gCalDeleteItemsInTaskList UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(dehydrate_statement, 17,self.gCalSyncType);
		sqlite3_bind_int(dehydrate_statement, 18,self.gCalSyncWindowStart);
		sqlite3_bind_int(dehydrate_statement, 19,self.gCalSyncWindowEnd);

		//General
		sqlite3_bind_int(dehydrate_statement, 20,self.isWarningForDeleting);
		sqlite3_bind_int(dehydrate_statement, 21,self.numberOfRestartTimes);
		sqlite3_bind_int(dehydrate_statement, 22,self.badgeType);
		sqlite3_bind_int(dehydrate_statement, 23,self.weekStartDay);
		
		sqlite3_bind_text(dehydrate_statement, 24, [self.previousDevToken UTF8String], -1, SQLITE_TRANSIENT);
		
		sqlite3_bind_int(dehydrate_statement, 25,self.cleanOldThanDays);
		sqlite3_bind_int(dehydrate_statement, 26,self.isMultiSelection);
		sqlite3_bind_int(dehydrate_statement, 27,self.snoozeDuration);
		sqlite3_bind_int(dehydrate_statement, 28,self.snoozeUnit);
		sqlite3_bind_int(dehydrate_statement, 29,self.taskTypeDefault);
		
		sqlite3_bind_double(dehydrate_statement, 30, [self.dayManagerStart timeIntervalSince1970]+gmtSeconds);
		sqlite3_bind_double(dehydrate_statement, 31, [self.dayManagerEnd timeIntervalSince1970]+gmtSeconds);
		sqlite3_bind_double(dehydrate_statement, 32, [self.dayManagerForDate timeIntervalSince1970]+gmtSeconds);
		
		sqlite3_bind_int(dehydrate_statement, 33,self.showNeededShoppingItemOnly);
		sqlite3_bind_int(dehydrate_statement, 34,self.defaultListId);
		
		//Toodledo sync
		sqlite3_bind_text(dehydrate_statement, 35, [self.toodledoToken UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_double(dehydrate_statement,36, [self.toodledoTokenTime timeIntervalSince1970]);
		sqlite3_bind_text(dehydrate_statement, 37, [self.toodledoUserId UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(dehydrate_statement, 38, [self.toodledoUserName UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(dehydrate_statement, 39, [self.toodledoPassword UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(dehydrate_statement, 40, [self.toodledoKey UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_double(dehydrate_statement, 41, [self.toodledoSyncTime timeIntervalSince1970]);
		sqlite3_bind_int(dehydrate_statement, 42,self.toodledoSyncType);
		sqlite3_bind_text(dehydrate_statement, 43, [self.toodledoDeletedFolders UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(dehydrate_statement, 44, self.isFirstTimeToodledoSync);
		sqlite3_bind_text(dehydrate_statement, 45, [self.toodledoDeletedTasks UTF8String], -1, SQLITE_TRANSIENT);
		
		//portraitUISizeRatio
		sqlite3_bind_double(dehydrate_statement, 46, self.landscapeUISizeRatio);
		sqlite3_bind_double(dehydrate_statement, 47, self.portraitUISizeRatio);
		//durationDefEventVal
		sqlite3_bind_double(dehydrate_statement, 48, self.durationDefEventVal);
		
		sqlite3_bind_int(dehydrate_statement, 49, self.isAutoSyncToodledo);		
		//isAutoSyncGcal
		sqlite3_bind_int(dehydrate_statement, 50, self.isAutoSyncGcal);
		
		//moveTaskInCalendar
		sqlite3_bind_int(dehydrate_statement, 51, self.moveTaskInCalendar);
		
		//showFaded
		sqlite3_bind_int(dehydrate_statement, 52, self.showFaded);
		//shutDownTime
		sqlite3_bind_double(dehydrate_statement, 53, [self.shutDownTime timeIntervalSince1970]);
		
		//enableSyncToodledo
		sqlite3_bind_int(dehydrate_statement, 54, self.enableSyncGcal);
		sqlite3_bind_int(dehydrate_statement, 55, self.enableSyncToodledo);
		
		//hasFirstTimeStarted
		sqlite3_bind_int(dehydrate_statement, 56, self.hasFirstTimeStarted);
		
		//needInformSyncAtStart
		sqlite3_bind_int(dehydrate_statement, 57, self.needInformSyncAtStart);
		
		//syncDisplayedGcalOnly
		sqlite3_bind_int(dehydrate_statement, 58, self.syncDisplayedGcalOnly);
		
		//noNeedMultiSelectHint
		sqlite3_bind_int(dehydrate_statement, 59, self.noNeedMultiSelectHint);
		
		//gcalDeletedCalendars
		sqlite3_bind_text(dehydrate_statement, 60, [self.gcalDeletedCalendars UTF8String], -1, SQLITE_TRANSIENT);
		//dontShowDefaultViewHint
		sqlite3_bind_int(dehydrate_statement, 61, self.dontShowDefaultViewHint);
		
		//dontShowDayViewHint
		sqlite3_bind_int(dehydrate_statement, 62, self.dontShowDayViewHint);
		//dontShowTaskViewHint
		sqlite3_bind_int(dehydrate_statement, 63, self.dontShowTaskViewHint);
		sqlite3_bind_int(dehydrate_statement, 64, self.dontShowMonthViewHint);
		sqlite3_bind_int(dehydrate_statement, 65, self.dontShowNoteViewHint);
		sqlite3_bind_int(dehydrate_statement, 66, self.dontShowGcalSetupViewHint);
		sqlite3_bind_int(dehydrate_statement, 67, self.dontShowTDSetupViewHint);
		
		//gmtSecondsValue
		sqlite3_bind_double(dehydrate_statement, 68, self.gmtSecondsValue);
		
		//isEKSync
		sqlite3_bind_int(dehydrate_statement, 69, self.isEKSync);
		//iCalSyncWindowStart
		sqlite3_bind_int(dehydrate_statement, 70, self.iCalSyncWindowStart);
		sqlite3_bind_int(dehydrate_statement, 71, self.iCalSyncWindowEnd);
		
		//deletedICalEvents
		sqlite3_bind_text(dehydrate_statement, 72, [self.deletedICalEvents UTF8String], -1, SQLITE_TRANSIENT);
		//iCalLastSyncTime
		sqlite3_bind_double(dehydrate_statement, 73, [self.iCalLastSyncTime timeIntervalSince1970]);
		
		//lastEventSyncType
		sqlite3_bind_int(dehydrate_statement, 74, self.lastEventSyncType);
		
		//zenScreenAtOpen
		sqlite3_bind_int(dehydrate_statement, 75, self.zenScreenAtOpen);
		
		//filterIndex
		sqlite3_bind_int(dehydrate_statement, 76, self.filterIndex);
		//projectViewType
		sqlite3_bind_int(dehydrate_statement, 77, self.projectViewType);
		//dontShowHideTaskHint
		sqlite3_bind_int(dehydrate_statement, 78, self.dontShowHideTaskHint);
		//newTaskOnTop
		sqlite3_bind_int(dehydrate_statement, 79, self.newTaskAtTop);
		//noteFontIndex
		sqlite3_bind_int(dehydrate_statement, 80, self.noteFontIndex);
		//dontShowProjectViewHint
		sqlite3_bind_int(dehydrate_statement, 81, self.dontShowProjectViewHint);
		//hasReconcileDSTForVersion21
		sqlite3_bind_int(dehydrate_statement, 82, self.hasReconcileDSTForVersion21);
		//autoTDSync
		sqlite3_bind_int(dehydrate_statement, 83, self.autoTDSync);
		sqlite3_bind_int(dehydrate_statement, 84, self.autoICalSync);
		//hasToodledoFirstTimeSynced
		sqlite3_bind_int(dehydrate_statement, 85, self.hasToodledoFirstTimeSynced);
		//deletedICalCalendars
        sqlite3_bind_text(dehydrate_statement, 86, [self.deletedICalCalendars UTF8String], -1, SQLITE_TRANSIENT);
        
        sqlite3_bind_int(dehydrate_statement, 87, self.taskSyncSource);
        sqlite3_bind_text(dehydrate_statement, 88, [self.SDWAccUserName UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(dehydrate_statement, 89, [self.SDWAccPassword UTF8String], -1, SQLITE_TRANSIENT);
        //SDWAccUserName
        
        //SDWDeletedCalendars
        sqlite3_bind_text(dehydrate_statement, 90, [self.SDWDeletedCalendars UTF8String], -1, SQLITE_TRANSIENT);
        //SDWLastSyncTime
        sqlite3_bind_double(dehydrate_statement, 91, [self.SDWLastSyncTime timeIntervalSince1970]);
        
        //SDWTokenTime
        sqlite3_bind_double(dehydrate_statement, 92, [self.SDWTokenTime timeIntervalSince1970]);
        
        sqlite3_bind_text(dehydrate_statement, 93, [self.SDWToken UTF8String], -1, SQLITE_TRANSIENT);
        
        //SDWKey
        sqlite3_bind_text(dehydrate_statement, 94, [self.SDWKey UTF8String], -1, SQLITE_TRANSIENT);
        
        //hasSDWFirstTimeSynced
        sqlite3_bind_int(dehydrate_statement, 95, self.hasSDWFirstTimeSynced);
        
        sqlite3_bind_text(dehydrate_statement, 96, [self.SDWDeletedTasks UTF8String], -1, SQLITE_TRANSIENT);
        //syncSourceOption
        sqlite3_bind_int(dehydrate_statement, 97, self.syncSourceOption);
        
        //SDWautoSync
        sqlite3_bind_int(dehydrate_statement, 98, self.SDWautoSync);
        //needReplaceSyncData
        sqlite3_bind_int(dehydrate_statement, 99, self.needReplaceSyncData);
        
        //lastTasksUpdate
        sqlite3_bind_double(dehydrate_statement, 100, [self.lastTasksUpdate timeIntervalSince1970]);
        sqlite3_bind_double(dehydrate_statement, 101, [self.lastCalendarsUpdate timeIntervalSince1970]);
        //dateUpdate
        sqlite3_bind_double(dehydrate_statement, 102, [[NSDate date] timeIntervalSince1970]);
        //playTimerSound
        sqlite3_bind_int(dehydrate_statement, 103, self.playTimerSound);
        
		sqlite3_bind_int(dehydrate_statement, 104, primaryKey);
		
        // Execute the query.
        int success = sqlite3_step(dehydrate_statement);
        // Reset the query for the next use.
        sqlite3_reset(dehydrate_statement);
        // Handle errors.
        if (success != SQLITE_DONE) {
            NSAssert1(0, @"Error: failed to dehydrate with message '%s'.", sqlite3_errmsg(database));
        }
        // Update the object state with respect to unwritten changes.
        dirty = NO;
    }
    // Release member variables to reclaim memory. Set to nil to avoid over-releasing them 
	
	
    // if dehydrate is called multiple times.
    [data release];
    data = nil;
    // Update the object state with respect to hydration.
    hydrated = NO;
    isLockingDB=NO;
}

#pragma mark Properties

-(NSInteger )primaryKey{
	return primaryKey;
}

-(void)setPrimaryKey:(NSInteger)pk{
	primaryKey=pk;
}

-(NSInteger)skinID{
	return skinID;
}

-(void)setSkinID:(NSInteger)anum{
	if(skinID==anum) return;
	dirty=YES;
	skinID=anum;
}

-(NSInteger)startWorkingWDay{
	return startWorkingWDay;
}

-(void)setStartWorkingWDay:(NSInteger)anum{
	if(startWorkingWDay==anum) return;
	dirty=YES;
	startWorkingWDay=anum;
}

-(NSInteger)endWorkingWDay{
	return endWorkingWDay;
}

-(void)setEndWorkingWDay:(NSInteger)anum{
	if(endWorkingWDay==anum) return;
	dirty=YES;
	endWorkingWDay=anum;
}

-(double)deskTimeNDStart{
	return deskTimeNDStart;
}

-(void)setDeskTimeNDStart:(double)anum{
	if(deskTimeNDStart==anum) return;
	dirty=YES;
	deskTimeNDStart=anum;
}

-(double)deskTimeNDEnd{
	return deskTimeNDEnd;
}

-(void)setDeskTimeNDEnd:(double)anum{
	if(deskTimeNDEnd==anum) return;
	dirty=YES;
	deskTimeNDEnd=anum;
}

-(double)deskTimeWEStart{
	return deskTimeWEStart;
}

-(void)setDeskTimeWEStart:(double)anum{
	if(deskTimeWEStart==anum) return;
	dirty=YES;
	deskTimeWEStart=anum;
}

-(double)deskTimeWEEnd{
	return deskTimeWEEnd;
}

-(void)setDeskTimeWEEnd:(double)anum{
	if(deskTimeWEEnd==anum) return;
	dirty=YES;
	deskTimeWEEnd=anum;
}


//
-(double)durationDefTaskVal{
	return durationDefTaskVal;
}

-(void)setDurationDefTaskVal:(double)anum{
	if(durationDefTaskVal==anum) return;
	dirty=YES;
	durationDefTaskVal=anum;
}

//contextDefID
-(NSInteger)contextDefID{
	return contextDefID;
}

-(void)setContextDefID:(NSInteger)anum{
	if(contextDefID==anum) return;
	dirty=YES;
	contextDefID=anum;
}

//calendarDefID
-(NSInteger)calendarDefID{
	return calendarDefID;
}

-(void)setCalendarDefID:(NSInteger)anum{
	if(calendarDefID==anum) return;
	dirty=YES;
	calendarDefID=anum;
}

//isFlexibleDefaultDuration
-(NSInteger)isFlexibleDefaultDuration{
	return isFlexibleDefaultDuration;
}

-(void)setIsFlexibleDefaultDuration:(NSInteger)anum{
	if(isFlexibleDefaultDuration==anum) return;
	dirty=YES;
	isFlexibleDefaultDuration=anum;
}

//isFlexibleDefaultCalendar
-(NSInteger)isFlexibleDefaultCalendar{
	return isFlexibleDefaultCalendar;
}

-(void)setIsFlexibleDefaultCalendar:(NSInteger)anum{
	if(isFlexibleDefaultCalendar==anum) return;
	dirty=YES;
	isFlexibleDefaultCalendar=anum;
}

//gCalAccountID
- (NSString *)gCalAccountID {
    return gCalAccountID;
}

- (void)setGCalAccountID:(NSString *)aString {
    if ((!gCalAccountID && !aString) || (gCalAccountID && aString && [gCalAccountID isEqualToString:aString])) return;
    dirty = YES;
    [gCalAccountID release];
    gCalAccountID = [aString copy];
}

//gCalAccountPassword
- (NSString *)gCalAccountPassword {
    return gCalAccountPassword;
}

- (void)setGCalAccountPassword:(NSString *)aString {
    if ((!gCalAccountPassword && !aString) || (gCalAccountPassword && aString && [gCalAccountPassword isEqualToString:aString])) return;
    dirty = YES;
    [gCalAccountPassword release];
    gCalAccountPassword = [aString copy];
}

//gCalLastSyncedTime
- (NSDate *)gCalLastSyncedTime{
	return gCalLastSyncedTime;
}

- (void)setGCalLastSyncedTime:(NSDate *)aDate{
	if ([gCalLastSyncedTime isEqualToDate:aDate]) return;
	dirty=YES;
	
	[gCalLastSyncedTime release];
	gCalLastSyncedTime=[aDate copy];
}

//gCalDeleteItemsInTaskList
- (NSString *)gCalDeleteItemsInTaskList {
    return gCalDeleteItemsInTaskList;
}

- (void)setGCalDeleteItemsInTaskList:(NSString *)aString {
    if ((!gCalDeleteItemsInTaskList && !aString) || (gCalDeleteItemsInTaskList && aString && [gCalDeleteItemsInTaskList isEqualToString:aString])) return;
    dirty = YES;
    [gCalDeleteItemsInTaskList release];
    gCalDeleteItemsInTaskList = [aString copy];
}

//gCalSyncType
-(NSInteger)gCalSyncType{
	return gCalSyncType;
}

-(void)setGCalSyncType:(NSInteger)anum{
	if(gCalSyncType==anum) return;
	dirty=YES;
	gCalSyncType=anum;
}

//gCalSyncWindowStart
-(NSInteger)gCalSyncWindowStart{
	return gCalSyncWindowStart;
}

-(void)setGCalSyncWindowStart:(NSInteger)anum{
	if(gCalSyncWindowStart==anum) return;
	dirty=YES;
	gCalSyncWindowStart=anum;
}

//gCalSyncWindowEnd
-(NSInteger)gCalSyncWindowEnd{
	return gCalSyncWindowEnd;
}

-(void)setGCalSyncWindowEnd:(NSInteger)anum{
	if(gCalSyncWindowEnd==anum) return;
	dirty=YES;
	gCalSyncWindowEnd=anum;
}

//isWarningForDeleting
-(NSInteger)isWarningForDeleting{
	return isWarningForDeleting;
}

-(void)setIsWarningForDeleting:(NSInteger)anum{
	if(isWarningForDeleting==anum) return;
	dirty=YES;
	isWarningForDeleting=anum;
}

//numberOfRestartTimes
-(NSInteger)numberOfRestartTimes{
	return numberOfRestartTimes;
}

-(void)setNumberOfRestartTimes:(NSInteger)anum{
	if(numberOfRestartTimes==anum) return;
	dirty=YES;
	numberOfRestartTimes=anum;
}

//badgeType
-(NSInteger)badgeType{
	return badgeType;
}

-(void)setBadgeType:(NSInteger)anum{
	if(badgeType==anum) return;
	dirty=YES;
	badgeType=anum;
}

//weekStartDay
-(NSInteger)weekStartDay{
	return weekStartDay;
}

-(void)setWeekStartDay:(NSInteger)anum{
	if(weekStartDay==anum) return;
	dirty=YES;
	weekStartDay=anum;
}

//previousDevToken
- (NSString *)previousDevToken {
    return previousDevToken;
}

- (void)setPreviousDevToken:(NSString *)aString {
    if ((!previousDevToken && !aString) || (previousDevToken && aString && [previousDevToken isEqualToString:aString])) return;
    dirty = YES;
    [previousDevToken release];
    previousDevToken = [aString copy];
}

//cleanOldThanDays
-(NSInteger)cleanOldThanDays{
	return cleanOldThanDays;
}

-(void)setCleanOldThanDays:(NSInteger)anum{
	if(cleanOldThanDays==anum) return;
	dirty=YES;
	cleanOldThanDays=anum;
}

//isMultiSelection
-(NSInteger)isMultiSelection{
	return isMultiSelection;
}

-(void)setIsMultiSelection:(NSInteger)anum{
	if(isMultiSelection==anum) return;
	dirty=YES;
	isMultiSelection=anum;
}

//snoozeDuration
-(NSInteger)snoozeDuration{
	return snoozeDuration;
}

-(void)setSnoozeDuration:(NSInteger)anum{
	if(snoozeDuration==anum) return;
	dirty=YES;
	snoozeDuration=anum;
}

//snoozeUnit
-(NSInteger)snoozeUnit{
	return snoozeUnit;
}

-(void)setSnoozeUnit:(NSInteger)anum{
	if(snoozeUnit==anum) return;
	dirty=YES;
	snoozeUnit=anum;
}

//taskTypeDefault
-(NSInteger)taskTypeDefault{
	return taskTypeDefault;
}

-(void)setTaskTypeDefault:(NSInteger)anum{
	if(taskTypeDefault==anum) return;
	dirty=YES;
	taskTypeDefault=anum;
}

//dayManagerStart
- (NSDate *)dayManagerStart{
	return dayManagerStart;
}

- (void)setDayManagerStart:(NSDate *)aDate{
	if ([dayManagerStart isEqualToDate:aDate]) return;
	dirty=YES;
	
	[dayManagerStart release];
	dayManagerStart=[aDate copy];
}

//dayManagerEnd
- (NSDate *)dayManagerEnd{
	return dayManagerEnd;
}

- (void)setDayManagerEnd:(NSDate *)aDate{
	if ([dayManagerEnd isEqualToDate:aDate]) return;
	dirty=YES;
	
	[dayManagerEnd release];
	dayManagerEnd=[aDate copy];
}

//dayManagerForDate
- (NSDate *)dayManagerForDate{
	return dayManagerForDate;
}

- (void)setDayManagerForDate:(NSDate *)aDate{
	if ([dayManagerForDate isEqualToDate:aDate]) return;
	dirty=YES;
	
	[dayManagerForDate release];
	dayManagerForDate=[aDate copy];
}

//showNeededShoppingItemOnly
-(NSInteger)showNeededShoppingItemOnly{
	return showNeededShoppingItemOnly;
}

-(void)setShowNeededShoppingItemOnly:(NSInteger)anum{
	if(showNeededShoppingItemOnly==anum) return;
	dirty=YES;
	showNeededShoppingItemOnly=anum;
}

//defaultListId
-(NSInteger)defaultListId{
	return defaultListId;
}

-(void)setDefaultListId:(NSInteger)anum{
	if(defaultListId==anum) return;
	dirty=YES;
	defaultListId=anum;
}

//toodledoToken
- (NSString *)toodledoToken {
    return toodledoToken;
}

- (void)setToodledoToken:(NSString *)aString {
    if ((!toodledoToken && !aString) || (toodledoToken && aString && [toodledoToken isEqualToString:aString])) return;
    dirty = YES;
    [toodledoToken release];
    toodledoToken = [aString copy];
}

//toodledoTokenTime
- (NSDate *)toodledoTokenTime{
	return toodledoTokenTime;
}

- (void)setToodledoTokenTime:(NSDate *)aDate{
	if ([toodledoTokenTime isEqualToDate:aDate]) return;
	dirty=YES;
	
	[toodledoTokenTime release];
	toodledoTokenTime=[aDate copy];
}

//toodledoUserId
- (NSString *)toodledoUserId {
    return toodledoUserId;
}

- (void)setToodledoUserId:(NSString *)aString {
    if ((!toodledoUserId && !aString) || (toodledoUserId && aString && [toodledoUserId isEqualToString:aString])) return;
    dirty = YES;
    [toodledoUserId release];
    toodledoUserId = [aString copy];
}

- (NSString *)toodledoUserName {
    return toodledoUserName;
}

- (void)setToodledoUserName:(NSString *)aString {
    if ((!toodledoUserName && !aString) || (toodledoUserName && aString && [toodledoUserName isEqualToString:aString])) return;
    dirty = YES;
    [toodledoUserName release];
    toodledoUserName = [aString copy];
}

- (NSString *)toodledoPassword {
    return toodledoPassword;
}

- (void)setToodledoPassword:(NSString *)aString {
    if ((!toodledoPassword && !aString) || (toodledoPassword && aString && [toodledoPassword isEqualToString:aString])) return;
    dirty = YES;
    [toodledoPassword release];
    toodledoPassword = [aString copy];
}

- (NSString *)toodledoKey {
    return toodledoKey;
}

- (void)setToodledoKey:(NSString *)aString {
    if ((!toodledoKey && !aString) || (toodledoKey && aString && [toodledoKey isEqualToString:aString])) return;
    dirty = YES;
    [toodledoKey release];
    toodledoKey = [aString copy];
}

//toodledoSyncTime
- (NSDate *)toodledoSyncTime{
	return toodledoSyncTime;
}

- (void)setToodledoSyncTime:(NSDate *)aDate{
	if ([toodledoSyncTime isEqualToDate:aDate]) return;
	dirty=YES;
	
	[toodledoSyncTime release];
	toodledoSyncTime=[aDate copy];
}

//toodledoSyncType
-(NSInteger)toodledoSyncType{
	return toodledoSyncType;
}

-(void)setToodledoSyncType:(NSInteger)anum{
	if(toodledoSyncType==anum) return;
	dirty=YES;
	toodledoSyncType=anum;
}

//toodledoDeletedFolders
- (NSString *)toodledoDeletedFolders {
    return toodledoDeletedFolders;
}

- (void)setToodledoDeletedFolders:(NSString *)aString {
    if ((!toodledoDeletedFolders && !aString) || (toodledoDeletedFolders && aString && [toodledoDeletedFolders isEqualToString:aString])) return;
    dirty = YES;
    [toodledoDeletedFolders release];
    toodledoDeletedFolders = [aString copy];
}

//isFirstTimeToodledoSync
-(NSInteger)isFirstTimeToodledoSync{
	return isFirstTimeToodledoSync;
}

-(void)setIsFirstTimeToodledoSync:(NSInteger)anum{
	if(isFirstTimeToodledoSync==anum) return;
	dirty=YES;
	isFirstTimeToodledoSync=anum;
}

//toodledoDeletedTasks
- (NSString *)toodledoDeletedTasks {
    return toodledoDeletedTasks;
}

- (void)setToodledoDeletedTasks:(NSString *)aString {
    if ((!toodledoDeletedTasks && !aString) || (toodledoDeletedTasks && aString && [toodledoDeletedTasks isEqualToString:aString])) return;
    dirty = YES;
    [toodledoDeletedTasks release];
    toodledoDeletedTasks = [aString copy];
}

//landscapeUISizeRatio
-(double)landscapeUISizeRatio{
	return landscapeUISizeRatio;
}

-(void)setLandscapeUISizeRatio:(double)anum{
	if(landscapeUISizeRatio==anum) return;
	dirty=YES;
	landscapeUISizeRatio=anum;
}

//portraitUISizeRatio
-(double)portraitUISizeRatio{
	return portraitUISizeRatio;
}

-(void)setPortraitUISizeRatio:(double)anum{
	if(portraitUISizeRatio==anum) return;
	dirty=YES;
	portraitUISizeRatio=anum;
}

//durationDefEventVal
-(double)durationDefEventVal{
	return durationDefEventVal;
}

-(void)setDurationDefEventVal:(double)anum{
	if(durationDefEventVal==anum) return;
	dirty=YES;
	durationDefEventVal=anum;
}

//isAutoSyncToodledo
-(NSInteger)isAutoSyncToodledo{
	return isAutoSyncToodledo;
}

-(void)setIsAutoSyncToodledo:(NSInteger)anum{
	if(isAutoSyncToodledo==anum) return;
	dirty=YES;
	isAutoSyncToodledo=anum;
}

-(NSInteger)isAutoSyncGcal{
	return isAutoSyncGcal;
}

-(void)setIsAutoSyncGcal:(NSInteger)anum{
	if(isAutoSyncGcal==anum) return;
	dirty=YES;
	isAutoSyncGcal=anum;
}

//moveTaskInCalendar
-(NSInteger)moveTaskInCalendar{
	return moveTaskInCalendar;
}

-(void)setMoveTaskInCalendar:(NSInteger)anum{
	if(moveTaskInCalendar==anum) return;
	dirty=YES;
	moveTaskInCalendar=anum;
}

//showFaded
-(NSInteger)showFaded{
	return showFaded;
}

-(void)setShowFaded:(NSInteger)anum{
	if(showFaded==anum) return;
	dirty=YES;
	showFaded=anum;
}


//shutDownTime
- (NSDate *)shutDownTime{
	return shutDownTime;
}

- (void)setShutDownTime:(NSDate *)aDate{
	if ([shutDownTime isEqualToDate:aDate]) return;
	dirty=YES;
	
	[shutDownTime release];
	shutDownTime=[aDate copy];
}

-(NSInteger)enableSyncGcal{
	return enableSyncGcal;
}

-(void)setEnableSyncGcal:(NSInteger)anum{
	if(enableSyncGcal==anum) return;
	dirty=YES;
	enableSyncGcal=anum;
}

-(NSInteger)enableSyncToodledo{
	return enableSyncToodledo;
}

-(void)setEnableSyncToodledo:(NSInteger)anum{
	if(enableSyncToodledo==anum) return;
	dirty=YES;
	enableSyncToodledo=anum;
}

//hasFirstTimeStarted
-(NSInteger)hasFirstTimeStarted{
	return hasFirstTimeStarted;
}

-(void)setHasFirstTimeStarted:(NSInteger)anum{
	if(hasFirstTimeStarted==anum) return;
	dirty=YES;
	hasFirstTimeStarted=anum;
}

//needInformSyncAtStart
-(NSInteger)needInformSyncAtStart{
	return needInformSyncAtStart;
}

-(void)setNeedInformSyncAtStart:(NSInteger)anum{
	if(needInformSyncAtStart==anum) return;
	dirty=YES;
	needInformSyncAtStart=anum;
}

//syncDisplayedGcalOnly
-(NSInteger)syncDisplayedGcalOnly{
	return syncDisplayedGcalOnly;
}

-(void)setSyncDisplayedGcalOnly:(NSInteger)anum{
	if(syncDisplayedGcalOnly==anum) return;
	dirty=YES;
	syncDisplayedGcalOnly=anum;
}

//noNeedMultiSelectHint
-(NSInteger)noNeedMultiSelectHint{
	return noNeedMultiSelectHint;
}

-(void)setNoNeedMultiSelectHint:(NSInteger)anum{
	if(noNeedMultiSelectHint==anum) return;
	dirty=YES;
	noNeedMultiSelectHint=anum;
}

//gcalDeletedCalendars
- (NSString *)gcalDeletedCalendars {
    return gcalDeletedCalendars;
}

- (void)setGcalDeletedCalendars:(NSString *)aString {
    if ((!gcalDeletedCalendars && !aString) || (gcalDeletedCalendars && aString && [gcalDeletedCalendars isEqualToString:aString])) return;
    dirty = YES;
    [gcalDeletedCalendars release];
    gcalDeletedCalendars = [aString copy];
}

//dontShowDefaultViewHint
-(NSInteger)dontShowDefaultViewHint{
	return dontShowDefaultViewHint;
}

-(void)setDontShowDefaultViewHint:(NSInteger)anum{
	if(dontShowDefaultViewHint==anum) return;
	dirty=YES;
	dontShowDefaultViewHint=anum;
}

//dontShowDayViewHint
-(NSInteger)dontShowDayViewHint{
	return dontShowDayViewHint;
}

-(void)setDontShowDayViewHint:(NSInteger)anum{
	if(dontShowDayViewHint==anum) return;
	dirty=YES;
	dontShowDayViewHint=anum;
}

//dontShowTaskViewHint
-(NSInteger)dontShowTaskViewHint{
	return dontShowTaskViewHint;
}

-(void)setDontShowTaskViewHint:(NSInteger)anum{
	if(dontShowTaskViewHint==anum) return;
	dirty=YES;
	dontShowTaskViewHint=anum;
}

//dontShowMonthViewHint
-(NSInteger)dontShowMonthViewHint{
	return dontShowMonthViewHint;
}

-(void)setDontShowMonthViewHint:(NSInteger)anum{
	if(dontShowMonthViewHint==anum) return;
	dirty=YES;
	dontShowMonthViewHint=anum;
}

//dontShowNoteViewHint
-(NSInteger)dontShowNoteViewHint{
	return dontShowNoteViewHint;
}

-(void)setDontShowNoteViewHint:(NSInteger)anum{
	if(dontShowNoteViewHint==anum) return;
	dirty=YES;
	dontShowNoteViewHint=anum;
}

//dontShowGcalSetupViewHint
-(NSInteger)dontShowGcalSetupViewHint{
	return dontShowGcalSetupViewHint;
}

-(void)setDontShowGcalSetupViewHint:(NSInteger)anum{
	if(dontShowGcalSetupViewHint==anum) return;
	dirty=YES;
	dontShowGcalSetupViewHint=anum;
}

//dontShowTDSetupViewHint
-(NSInteger)dontShowTDSetupViewHint{
	return dontShowTDSetupViewHint;
}

-(void)setDontShowTDSetupViewHint:(NSInteger)anum{
	if(dontShowTDSetupViewHint==anum) return;
	dirty=YES;
	dontShowTDSetupViewHint=anum;
}

//gmtSecondsValue
-(NSTimeInterval)gmtSecondsValue{
	return gmtSecondsValue;
}

-(void)setGmtSecondsValue:(NSTimeInterval)anum{
	if (anum==gmtSecondsValue) return;
	dirty=YES;
	
	gmtSecondsValue=anum;
}

//isEKSync
-(NSInteger)isEKSync{
	return isEKSync;
}

-(void)setIsEKSync:(NSInteger)anum{
	if(isEKSync==anum) return;
	dirty=YES;
	isEKSync=anum;
}

//iCalSyncWindowStart
-(NSInteger)iCalSyncWindowStart{
	return iCalSyncWindowStart;
}

-(void)setICalSyncWindowStart:(NSInteger)anum{
	if(iCalSyncWindowStart==anum) return;
	dirty=YES;
	iCalSyncWindowStart=anum;
}

//iCalSyncWindowEnd
-(NSInteger)iCalSyncWindowEnd{
	return iCalSyncWindowEnd;
}

-(void)setICalSyncWindowEnd:(NSInteger)anum{
	if(iCalSyncWindowEnd==anum) return;
	dirty=YES;
	iCalSyncWindowEnd=anum;
}

//deletedICalEvents
- (NSString *)deletedICalEvents {
    return deletedICalEvents;
}

- (void)setDeletedICalEvents:(NSString *)aString {
    if ((!deletedICalEvents && !aString) || (deletedICalEvents && aString && [deletedICalEvents isEqualToString:aString])) return;
    dirty = YES;
    [deletedICalEvents release];
    deletedICalEvents = [aString copy];
}

//iCalLastSyncTime
- (NSDate *)iCalLastSyncTime{
	return iCalLastSyncTime;
}

- (void)setICalLastSyncTime:(NSDate *)aDate{
	if ([iCalLastSyncTime isEqualToDate:aDate]) return;
	dirty=YES;
	
	[iCalLastSyncTime release];
	if (!aDate) {
		iCalLastSyncTime=[[NSDate date] copy];
	}else {
		iCalLastSyncTime=[aDate copy];
	}

}

//lastEventSyncType
-(NSInteger)lastEventSyncType{
	return lastEventSyncType;
}

-(void)setLastEventSyncType:(NSInteger)anum{
	if(lastEventSyncType==anum) return;
	dirty=YES;
	lastEventSyncType=anum;
}

//zenScreenAtOpen
-(NSInteger)zenScreenAtOpen{
	return zenScreenAtOpen;
}

-(void)setZenScreenAtOpen:(NSInteger)anum{
	if(zenScreenAtOpen==anum) return;
	dirty=YES;
	zenScreenAtOpen=anum;
}

//filterIndex
-(NSInteger)filterIndex{
	return filterIndex;
}

-(void)setFilterIndex:(NSInteger)anum{
	if(filterIndex==anum) return;
	dirty=YES;
	filterIndex=anum;
}

//projectViewType
-(NSInteger)projectViewType{
	return projectViewType;
}

-(void)setProjectViewType:(NSInteger)anum{
	if(projectViewType==anum) return;
	dirty=YES;
	projectViewType=anum;
}

//dontShowHideTaskHint
-(NSInteger)dontShowHideTaskHint{
	return dontShowHideTaskHint;
}

-(void)setDontShowHideTaskHint:(NSInteger)anum{
	if(dontShowHideTaskHint==anum) return;
	dirty=YES;
	dontShowHideTaskHint=anum;
}

//newTaskOnTop
-(NSInteger)newTaskAtTop{
	return newTaskAtTop;
}

-(void)setNewTaskAtTop:(NSInteger)anum{
	if(newTaskAtTop==anum) return;
	dirty=YES;
	newTaskAtTop=anum;
}

//noteFontIndex
-(NSInteger)noteFontIndex{
	return noteFontIndex;
}

-(void)setNoteFontIndex:(NSInteger)anum{
	if(noteFontIndex==anum) return;
	dirty=YES;
	noteFontIndex=anum;
}

//dontShowProjectViewHint
-(NSInteger)dontShowProjectViewHint{
	return dontShowProjectViewHint;
}

-(void)setDontShowProjectViewHint:(NSInteger)anum{
	if(dontShowProjectViewHint==anum) return;
	dirty=YES;
	dontShowProjectViewHint=anum;
}

//hasReconcileDSTForVersion21
-(NSInteger)hasReconcileDSTForVersion21{
	return hasReconcileDSTForVersion21;
}

-(void)setHasReconcileDSTForVersion21:(NSInteger)anum{
	if(hasReconcileDSTForVersion21==anum) return;
	dirty=YES;
	hasReconcileDSTForVersion21=anum;
}

//autoTDSync
-(NSInteger)autoTDSync{
	return autoTDSync;
}

-(void)setAutoTDSync:(NSInteger)anum{
	if(autoTDSync==anum) return;
	dirty=YES;
	autoTDSync=anum;
}

//autoICalSync
-(NSInteger)autoICalSync{
	return autoICalSync;
}

-(void)setAutoICalSync:(NSInteger)anum{
	if(autoICalSync==anum) return;
	dirty=YES;
	autoICalSync=anum;
}

//hasToodledoFirstTimeSynced
-(NSInteger)hasToodledoFirstTimeSynced{
	return hasToodledoFirstTimeSynced;
}

-(void)setHasToodledoFirstTimeSynced:(NSInteger)anum{
	if(hasToodledoFirstTimeSynced==anum) return;
	dirty=YES;
	hasToodledoFirstTimeSynced=anum;
}

//deletedICalCalendars
- (NSString *)deletedICalCalendars {
    return deletedICalCalendars;
}

- (void)setDeletedICalCalendars:(NSString *)aString {
    if ((!deletedICalCalendars && !aString) || (deletedICalCalendars && aString && [deletedICalCalendars isEqualToString:aString])) return;
    dirty = YES;
    [deletedICalCalendars release];
    deletedICalCalendars = [aString copy];
}

//
-(NSInteger)taskSyncSource{
	return taskSyncSource;
}

-(void)setTaskSyncSource:(NSInteger)anum{
	if(taskSyncSource==anum) return;
	dirty=YES;
	taskSyncSource=anum;
}

- (NSString *)SDWAccUserName {
    return SDWAccUserName;
}

- (void)setSDWAccUserName:(NSString *)aString {
    if ((!SDWAccUserName && !aString) || (SDWAccUserName && aString && [SDWAccUserName isEqualToString:aString])) return;
    dirty = YES;
    [SDWAccUserName release];
    SDWAccUserName = [aString copy];
}

- (NSString *)SDWAccPassword {
    return SDWAccPassword;
}

- (void)setSDWAccPassword:(NSString *)aString {
    if ((!SDWAccPassword && !aString) || (SDWAccPassword && aString && [SDWAccPassword isEqualToString:aString])) return;
    dirty = YES;
    [SDWAccPassword release];
    SDWAccPassword = [aString copy];
}

//SDWDeletedCalendars
- (NSString *)SDWDeletedCalendars {
    return SDWDeletedCalendars;
}

- (void)setSDWDeletedCalendars:(NSString *)aString {
    if ((!SDWDeletedCalendars && !aString) || (SDWDeletedCalendars && aString && [SDWDeletedCalendars isEqualToString:aString])) return;
    dirty = YES;
    [SDWDeletedCalendars release];
    SDWDeletedCalendars = [aString copy];
}

//SDWLastSyncTime
- (NSDate *)SDWLastSyncTime{
	return SDWLastSyncTime;
}

- (void)setSDWLastSyncTime:(NSDate *)aDate{
	if ([SDWLastSyncTime isEqualToDate:aDate]) return;
	dirty=YES;
	
	[SDWLastSyncTime release];
	if (!aDate) {
		SDWLastSyncTime=[[NSDate date] copy];
	}else {
		SDWLastSyncTime=[aDate copy];
	}
    
}

//
- (NSDate *)SDWTokenTime{
	return SDWTokenTime;
}

- (void)setSDWTokenTime:(NSDate *)aDate{
	if ([SDWTokenTime isEqualToDate:aDate]) return;
	dirty=YES;
	
	[SDWTokenTime release];
	if (!aDate) {
		SDWTokenTime=[[NSDate date] copy];
	}else {
		SDWTokenTime=[aDate copy];
	}
    
}

- (NSString *)SDWToken {
    return SDWToken;
}

- (void)setSDWToken:(NSString *)aString {
    if ((!SDWToken && !aString) || (SDWToken && aString && [SDWToken isEqualToString:aString])) return;
    dirty = YES;
    [SDWToken release];
    SDWToken = [aString copy];
}

//SDWKey
- (NSString *)SDWKey {
    return SDWKey;
}

- (void)setSDWKey:(NSString *)aString {
    if ((!SDWKey && !aString) || (SDWKey && aString && [SDWKey isEqualToString:aString])) return;
    dirty = YES;
    [SDWKey release];
    SDWKey = [aString copy];
}

//hasSDWFirstTimeSynced
-(NSInteger)hasSDWFirstTimeSynced{
	return hasSDWFirstTimeSynced;
}

-(void)setHasSDWFirstTimeSynced:(NSInteger)anum{
	if(hasSDWFirstTimeSynced==anum) return;
	dirty=YES;
	hasSDWFirstTimeSynced=anum;
}

- (NSString *)SDWDeletedTasks {
    return SDWDeletedTasks;
}

- (void)setSDWDeletedTasks:(NSString *)aString {
    if ((!SDWDeletedTasks && !aString) || (SDWDeletedTasks && aString && [SDWDeletedTasks isEqualToString:aString])) return;
    dirty = YES;
    [SDWDeletedTasks release];
    SDWDeletedTasks = [aString copy];
}

//syncSourceOption
-(NSInteger)syncSourceOption{
	return syncSourceOption;
}

-(void)setSyncSourceOption:(NSInteger)anum{
	if(syncSourceOption==anum) return;
	dirty=YES;
	syncSourceOption=anum;
}

//SDWautoSync
-(NSInteger)SDWautoSync{
	return SDWautoSync;
}

-(void)setSDWautoSync:(NSInteger)anum{
	if(SDWautoSync==anum) return;
	dirty=YES;
	SDWautoSync=anum;
}

//needReplaceSyncData
-(NSInteger)needReplaceSyncData{
	return needReplaceSyncData;
}

-(void)setNeedReplaceSyncData:(NSInteger)anum{
	if(needReplaceSyncData==anum) return;
	dirty=YES;
	needReplaceSyncData=anum;
}

//lastTasksUpdate
- (NSDate *)lastTasksUpdate{
	return lastTasksUpdate;
}

- (void)setLastTasksUpdate:(NSDate *)aDate{
	if ([lastTasksUpdate isEqualToDate:aDate]) return;
	dirty=YES;
	
	[lastTasksUpdate release];
    lastTasksUpdate=[aDate copy];    
}

- (NSDate *)lastCalendarsUpdate{
	return lastCalendarsUpdate;
}

- (void)setLastCalendarsUpdate:(NSDate *)aDate{
	if ([lastCalendarsUpdate isEqualToDate:aDate]) return;
	dirty=YES;
	
	[lastCalendarsUpdate release];
    lastCalendarsUpdate=[aDate copy];    
}

//dateUpdate
- (NSDate *)dateUpdate{
	return dateUpdate;
}

- (void)setDateUpdate:(NSDate *)aDate{
	if ([dateUpdate isEqualToDate:aDate]) return;
	dirty=YES;
	
	[dateUpdate release];
    dateUpdate=[aDate copy];    
}

//playTimerSound
-(NSInteger)playTimerSound{
	return playTimerSound;
}

-(void)setPlayTimerSound:(NSInteger)anum{
	if(playTimerSound==anum) return;
	dirty=YES;
	playTimerSound=anum;
}

@end
