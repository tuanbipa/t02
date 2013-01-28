//
//  CoreData.m
//  SmartOrganizer
//
//  Created by Nang Le Van on 5/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MigrationData.h"
#import <sqlite3.h>   

#import "Setting.h" 

#import "SPadTask.h"
#import "Calendar.h"
#import "List.h"
#import	"ListItem.h"
#import "Note.h"
#import "Sketch.h"
#import "HyperNote.h"
#import "Common.h"
#import "Calendar.h"
#import "GTMBase64.h"
#import "DBManager.h"

#import "TaskManager.h"
#import "Task.h"

#import "ProjectManager.h"
#import "Project.h"

#import "AlertManager.h"
#import "AlertData.h"

#import "RepeatData.h"

#import "TaskProgress.h"
#import "Settings.h"

#import "SmartCalAppDelegate.h"

BOOL			hasRestoringDB=NO;
sqlite3			*database;
double			gmtSeconds; 

BOOL    is24HrFormat;

extern BOOL _is24HourFormat;

NSTimeZone	*App_defaultTimeZone;
BOOL		isDayLigtSavingTime;
NSTimeInterval	dstOffset;
NSTimeInterval dstOffset1;

BOOL     isLockingDB;

//extern DBManager *_dbManagerSingleton;

MigrationData *coreData;

@interface MigrationData (Private)
-(BOOL)check24HourFormat;
- (void)createEditableCopyOfDatabaseIfNeeded;
- (void)checkAndInitializeRestoringDatabase;
- (void)getSettingList;
- (void)initTimeZone;
- (void)checkAndMigrateData;
- (NSDate *)getToday;
- (NSMutableArray*)getCalendarList;
- (NSMutableArray*)getAllTasksEvents;
- (NSMutableArray*)getAllNotes;
- (NSMutableArray *)getAllHyperNotes;

- (void)cleanAllProjectsFromNewDB:(sqlite3*)db;
- (void)cleanAllAlertsFromNewDB:(sqlite3*)db;
- (void)cleanAllTasksEventFromNewDB:(sqlite3*)db;
- (void)cleanAllTasksProgressFromNewDB:(sqlite3*)db;

-(void)finalizeDataBeforeShutdown;

#pragma mark Note
-(void)backup;
@end

@implementation MigrationData
@synthesize today;

-(id)init{
    self=[super init];
	if (self) {
		
		[self initTimeZone];
		
		calendarList=[[NSMutableArray alloc] init];
        allTasksEventsAdes=[[NSMutableArray alloc] init];
        notesList=[[NSMutableArray alloc] init];
        hyperNotesList=[[NSMutableArray alloc] init];
        
		self.today=[self getToday];

		//init database
		[self checkAndInitializeRestoringDatabase];		
        
        is24HrFormat=_is24HourFormat;
        
        coreData=self;
	}
	
	return self;
}

-(void)initTimeZone{
	App_defaultTimeZone = [[NSTimeZone defaultTimeZone] retain];
	
	gmtSeconds=App_defaultTimeZone.secondsFromGMT;
	isDayLigtSavingTime=[App_defaultTimeZone isDaylightSavingTime];
	NSDate *date=[App_defaultTimeZone nextDaylightSavingTimeTransition];
	NSDate *date1;
	
	dstOffset=[App_defaultTimeZone daylightSavingTimeOffsetForDate:[date dateByAddingTimeInterval:86400]];
	dstOffset1=dstOffset;
	
	if(dstOffset==0){
		date1=[App_defaultTimeZone nextDaylightSavingTimeTransitionAfterDate:date];
		dstOffset=[App_defaultTimeZone daylightSavingTimeOffsetForDate:[date1 dateByAddingTimeInterval:-86400]];
		dstOffset1=[App_defaultTimeZone daylightSavingTimeOffsetForDate:[date1 dateByAddingTimeInterval:86400]];
	}
}

-(void)dealloc{
	[currentSetting release];
	[calendarList release];
    [notesList release];
    [hyperNotesList release];
	[allTasksEventsAdes release];
	[super dealloc];
}

-(void)checkAndMigrateData{
    
    if (hasRestoringDB) {
        DBManager *dm=[DBManager getInstance];
        sqlite3 *db=[dm getDatabase];
        [self cleanAllAlertsFromNewDB:db];
        [self cleanAllTasksProgressFromNewDB:db];
        [self cleanAllTasksEventFromNewDB:db];
        [self cleanAllProjectsFromNewDB:db];
        
        //migrate Settings
        Settings *setting=[Settings getInstance];
        setting.weekStart=currentSetting.weekStartDay;
        setting.taskDuration=currentSetting.durationDefTaskVal;
        setting.taskDefaultProject=currentSetting.calendarDefID;
        setting.eventCombination=currentSetting.showFaded;
        setting.movableAsEvent=currentSetting.moveTaskInCalendar;
        
        //setting.weekdayStartTime=currentSetting.deskTimeNDStart;
        //setting.weekdayEndTime=currentSetting.deskTimeNDEnd;
        //setting.weekendStartTime=currentSetting.deskTimeWEStart;
        //setting.weekendEndTime=currentSetting.deskTimeWEEnd;
        //setting.dayManagerStartTime=currentSetting.da
        
        setting.ekAutoSyncEnabled=currentSetting.enableSyncGcal;
        setting.syncWindowStart=currentSetting.iCalSyncWindowStart;
        setting.syncWindowEnd=currentSetting.iCalSyncWindowEnd;
        
        setting.deleteWarning=currentSetting.isWarningForDeleting;
        setting.tdAutoSyncEnabled=currentSetting.enableSyncToodledo;
        setting.tdEmail=currentSetting.toodledoUserName;
        setting.tdPassword=currentSetting.toodledoPassword;
        setting.tdLastSyncTime=currentSetting.toodledoSyncTime;
        setting.ekLastSyncTime=currentSetting.iCalLastSyncTime;
        
        setting.sdwEmail=currentSetting.SDWAccUserName;
        setting.sdwPassword=currentSetting.SDWAccPassword;
                
        //Migrate calendars
        for (Calendar *cal in calendarList) {
            Project *newProject=[[Project alloc] init];
            newProject.name=cal.calendarName;
            if (cal.inVisible) {
                newProject.status=PROJECT_STATUS_INVISIBLE;
            }else {
                newProject.status=PROJECT_STATUS_NONE;
            }
            
            if (cal.projectType==0) {
                newProject.type=TYPE_PLAN;
            }else {
                newProject.type=TYPE_LIST;
            }
        
            newProject.colorId=[self ColorIntFromGroupId:cal.colorGroupId colorId:cal.colorNameId];
            newProject.ekId=cal.iCalIdentifier;
            newProject.sdwId=[NSString stringWithFormat:@"%d", cal.SDWIdentifier];
            newProject.tdId=[NSString stringWithFormat:@"%d",cal.toodledoFolderKey];
            
            [newProject insertIntoDB:db];
            cal.migrateID=newProject.primaryKey;
            
            if (cal.primaryKey=currentSetting.calendarDefID) {
                setting.taskDefaultProject=cal.migrateID;
            }
            
            [newProject updateIntoDB:db];
        }
        
        Settings *updateSetting=[Settings getInstance];
        [updateSetting updateSettings:setting];

        //this would happen before migrating task/event
        for (Note *nt in notesList) {
            Task *note=[[Task alloc] init];
            note.type=TYPE_NOTE;
            note.startTime=nt.noteDate;
            note.note=nt.noteContent;
            if ([nt.noteContent length]<30) {
                note.name=nt.noteContent;
            }else {
                note.name=[NSString stringWithFormat:@"%@...",[nt.noteContent substringToIndex:28]];
            }
            
            nt.migrateID=note.primaryKey;
            for (Calendar *calendar in calendarList) {
                if (currentSetting.calendarDefID==calendar.primaryKey) {
                    note.project=calendar.migrateID;
                    break;
                }
            }

            [note insertIntoDB:db];
            [note updateIntoDB:db];
        }

        for (SPadTask *sPadtask in allTasksEventsAdes) {
            Task *task=[[Task alloc] init];
            task.name=sPadtask.taskName;
            task.location=sPadtask.taskLocation;
            task.note=sPadtask.notes;
            if (sPadtask.taskType==0) {
                task.type=TYPE_TASK;
            }else {
                task.type=TYPE_EVENT;
            }
            
            task.groupKey=sPadtask.parentId;
            task.project=sPadtask.calendarId;
            
            if (sPadtask.isPinned) {
                task.status=TASK_STATUS_PINNED;
            }else {
                task.status=TASK_STATUS_NONE;
            }
            
            if (sPadtask.taskType==0) {
                task.startTime=sPadtask.dueStart;
                if (sPadtask.hasDue) {
                    task.deadline=sPadtask.dueEnd;
                }else {
                    task.deadline=nil;
                }
                task.syncId=[NSString stringWithFormat:@"%d",sPadtask.toodledoID];
            }else {
                task.startTime=sPadtask.startTime;
                task.syncId=sPadtask.iCalIdentifier;
            }
            
            task.endTime=sPadtask.endTime;
            task.duration=sPadtask.duration*60;
            
            if (sPadtask.repeatType>0) {
                NSInteger repeatEvery;
                NSInteger repeatBy;
                NSString *repeatOn;
                
                if(sPadtask.repeatOptions !=nil && ![sPadtask.repeatOptions isEqualToString:@""]){
                    NSArray *options=[sPadtask.repeatOptions componentsSeparatedByString:@"/"];
                    repeatEvery=[(NSString*)[options objectAtIndex:0] intValue];
                    repeatOn=(NSString*)[options objectAtIndex:1];
                    repeatBy=[(NSString*)[options objectAtIndex:2] intValue];
                }else {
                    repeatEvery=1;
                    repeatOn=@"";
                    repeatBy=0;
                }
                
                if(repeatEvery<1){
                    repeatEvery=1;
                }

                NSInteger repeatWeekOption=-1;
                if (sPadtask.repeatType==2) {
                    NSArray *repeatOns=[repeatOn componentsSeparatedByString:@"|"];
                    for (NSString *str in repeatOns) {
                        NSInteger wd=[str intValue];
                        if (wd>0) {
                            NSInteger weekDay;
                            switch (wd) {
                                case 1:
                                    weekDay=ON_SUNDAY;
                                    break;
                                case 2:
                                    weekDay=ON_MONDAY;
                                    break;
                                case 3:
                                    weekDay=ON_TUESDAY;

                                    break;
                                case 4:
                                    weekDay=ON_WEDNESDAY;

                                    break;
                                case 5:
                                    weekDay=ON_THURSDAY;
                                    
                                    break;
                                case 6:
                                    weekDay=ON_FRIDAY;

                                    break;
                                case 7:
                                    weekDay=ON_SATURDAY;

                                    break;

                            }
                            if (repeatWeekOption==-1) {
                                repeatWeekOption=weekDay;
                            }else{
                                repeatWeekOption=repeatWeekOption|weekDay;
                            }
                        }
                    }
                }else if (sPadtask.repeatType==3) {
                    repeatWeekOption=repeatBy; 
                }
                
                NSString *repeatRulesStr=[NSString stringWithFormat:@"%d/%d/%d/%f/%d|%d|%d",sPadtask.repeatType-1,repeatEvery,repeatWeekOption, sPadtask.isRepeatForever?-1:[sPadtask.repeatEndDate timeIntervalSince1970], sPadtask.taskRepeatStyle,0,0];
                
                task.repeatData=[RepeatData parseRepeatData:repeatRulesStr];
                
            }else {
                task.repeatData=nil;
            }
            
            ///////////////////////////////////////////////////
            //timming log will create into TaskProgressTable //
            ///////////////////////////////////////////////////
            if ([sPadtask.doingLogs length]>0) {
                NSArray *timedLogs=[sPadtask.doingLogs componentsSeparatedByString:@"/"];
                for (NSString *str in timedLogs) {
                    if ([str length]>0) {
                        NSArray *startEnd=[str componentsSeparatedByString:@"|"];
                        TaskProgress *taskProgress=[[TaskProgress alloc] init];
                        taskProgress.task=task;
                        taskProgress.startTime=[NSDate dateWithTimeIntervalSince1970:[[startEnd objectAtIndex:0] floatValue]];
                        taskProgress.endTime=[NSDate dateWithTimeIntervalSince1970:[[startEnd objectAtIndex:1] floatValue]];
                        [taskProgress insertIntoDB:db];
                        //[taskProgress updateIntoDB:db];
                    }
                }
            }
            
            task.timerStatus=sPadtask.doingStatus;
            if (sPadtask.doingStatus>0) {
                TaskProgress *lastProgress=[[TaskProgress alloc] init];
                lastProgress.task=task;
                lastProgress.startTime=sPadtask.currentStartTime;
                [lastProgress insertIntoDB:db];
                //[taskProgress updateIntoDB:db];
                
                task.lastProgress=lastProgress;
            }
            ///////////
                       
            for (Calendar *calendar in calendarList) {
                if (sPadtask.calendarId==calendar.primaryKey) {
                    task.project=calendar.migrateID;
                    break;
                }
            }

            [task insertIntoDB:db];
            //[self updateNewTaskKey:sPadtask.primaryKey forOldKey:task.primaryKey inDB:db];
            [task updateIntoDB:db];
            sPadtask.migrateID=task.primaryKey;
            
            if (sPadtask.hyperNoteId>0) {
                for (Note *note in notesList) {
                    if (sPadtask.hyperNoteId==note.primaryKey) {
                        if (!task.links) {
                            task.links=[NSMutableArray array];
                        }
                        
                        [task.links addObject:[NSNumber numberWithInt:note.migrateID]];
                        break;
                    }
                }
            }
        }
        
        [self finalizeDataBeforeShutdown];
        
        // Close the database.
        if (sqlite3_close(database) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(database));
        }

        
        NSFileManager *fileMG=[NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Database.sql"];
        
        if ([fileMG isDeletableFileAtPath:path]) {
            [fileMG removeItemAtPath:path error:nil];
        }
    }
    
}

-(void)finalizeDataBeforeShutdown{
    [Setting finalizeStatements];
    [SPadTask finalizeStatements];
	[Note finalizeStatements];
	[HyperNote finalizeStatements];
    [Calendar finalizeStatements];
	[List finalizeStatements];
	[ListItem finalizeStatements];
	[Sketch finalizeStatements];
	
}

-(NSInteger)ColorIntFromGroupId:(NSInteger)groupId colorId:(NSInteger)colorId{
    NSInteger num=groupId*8+colorId;
    if (num<0 || num>31) {
        num=0;
    }
    return num;
}

-(void)cleanAllProjectsFromNewDB:(sqlite3*)db{
    const char *sql = "DELETE FROM ProjectTable";
    sqlite3_stmt *statement;
    // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
    // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
    if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
    }
    sqlite3_step(statement);
    sqlite3_finalize(statement);
}

-(void)cleanAllAlertsFromNewDB:(sqlite3*)db{
    const char *sql = "DELETE FROM AlertTable";
    sqlite3_stmt *statement;
    // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
    // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
    if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
    }
    sqlite3_step(statement);
    sqlite3_finalize(statement);
}

-(void)cleanAllTasksEventFromNewDB:(sqlite3*)db{
    const char *sql = "DELETE FROM TaskTable";
    sqlite3_stmt *statement;
    // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
    // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
    if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
    }
    sqlite3_step(statement);
    sqlite3_finalize(statement);
}

-(void)cleanAllTasksProgressFromNewDB:(sqlite3*)db{
    const char *sql = "DELETE FROM TaskProgressTable";
    sqlite3_stmt *statement;
    // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
    // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
    if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
    }
    sqlite3_step(statement);
    sqlite3_finalize(statement);
}

-(NSDate *)getToday{
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit|NSSecondCalendarUnit;
	
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:[NSDate date]];	
	[comps setSecond:0];
	[comps setMinute:0];
	[comps setHour:0];
	
	return [gregorian dateFromComponents:comps];	
	
}

#pragma mark Database Interaction

// Open the database connection and retrieve minimal information for all objects.
- (void)checkAndInitializeRestoringDatabase {
	// The database is stored in the application bundle. 
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Database.sql"];
	// Open the database. The database was prepared outside the application.
    
    if (sqlite3_config(SQLITE_CONFIG_SERIALIZED) == SQLITE_OK) {
        //NSLog(@"Can now use sqlite on multiple threads, using the same connection");
    }
	
    hasRestoringDB=NO;
    NSFileManager *fileManager=[NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:path]){
        if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
            
            // to be sure that the backed up db can be used, hasRestoringDB is assigned here
            hasRestoringDB=YES;
            
            // Get data lists
            [self getSettingList];
            [calendarList addObjectsFromArray:[self getCalendarList]];
            [allTasksEventsAdes addObjectsFromArray:[self getAllTasksEvents]];
            [notesList addObjectsFromArray:[self getAllNotes]];
            [hyperNotesList addObjectsFromArray:[self getAllHyperNotes]];
            
        } else {
            // Even though the open failed, call close to properly clean up resources.
            sqlite3_close(database);
            NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
            // Additional error handling, as appropriate...
        }
    }
}

#pragma mark get dataList from DB

#pragma mark Setting
-(void)getSettingList{
	if(hasRestoringDB){
		
		const char *sql = "SELECT primaryKey FROM Settings";
		sqlite3_stmt *statement;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				int primaryKey = sqlite3_column_int(statement, 0);
				currentSetting = [[Setting alloc] initWithPrimaryKey:primaryKey database:database];
			}
		}
		// "Finalize" the statement - releases the resources associated with the statement.
		sqlite3_finalize(statement);
	}
}

#pragma mark Calendar
-(NSMutableArray*)getCalendarList{
	NSMutableArray *calendarListTmp=[NSMutableArray array];
	if(hasRestoringDB){
		const char *sql = "SELECT primaryKey FROM Calendars";
		sqlite3_stmt *statement;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				int primaryKey = sqlite3_column_int(statement, 0);
				// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
				// autorelease is slightly more expensive than release. This design choice has nothing to do with
				// actual memory management - at the end of this block of code, all the book objects allocated
				// here will be in memory regardless of whether we use autorelease or release, because they are
				// retained by the books array.
				Calendar *cal = [[Calendar alloc] initWithPrimaryKey:primaryKey database:database];
				[calendarListTmp addObject:cal];
				[cal release];
			}
		}
		
		// "Finalize" the statement - releases the resources associated with the statement.
		sqlite3_finalize(statement);
	}
	return calendarListTmp;
}

#pragma mark Notes

- (NSMutableArray*)getAllNotes{
	NSMutableArray *noteListTmp=[NSMutableArray array];
	
	if(hasRestoringDB){
		
		NSString *sql =[NSString stringWithFormat:@"SELECT primaryKey FROM Notes" ];
		
		sqlite3_stmt *statement;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			//sqlite3_bind_int(statement,1, completed);
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				int primaryKey = sqlite3_column_int(statement, 0);
				// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
				// autorelease is slightly more expensive than release. This design choice has nothing to do with
				// actual memory management - at the end of this block of code, all the tasks objects allocated
				// here will be in memory regardless of whether we use autorelease or release, because they are
				// retained by the tasks array.
				Note *note = [[Note alloc] initWithPrimaryKey:primaryKey database:database];
				[noteListTmp addObject:note];
				////printf("\n updated date: %s",[[Utilities getShortDateStringFromDate:task.dateUpdate] UTF8String]);
				[note release];
			}
		}
		
		sqlite3_finalize(statement);		
	}else
		//printf("Database can not open!");
	return noteListTmp;		
}

#pragma mark Tasks

-(NSMutableArray*)getAllTasksEvents{
	NSMutableArray *retList=[NSMutableArray array];
	
	if(hasRestoringDB){
		
		NSString *sql =[NSString stringWithFormat:@"SELECT primaryKey FROM Tasks"];
		
		sqlite3_stmt *statement;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			//sqlite3_bind_int(statement,1, completed);
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				int primaryKey = sqlite3_column_int(statement, 0);
				// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
				// autorelease is slightly more expensive than release. This design choice has nothing to do with
				// actual memory management - at the end of this block of code, all the tasks objects allocated
				// here will be in memory regardless of whether we use autorelease or release, because they are
				// retained by the tasks array.
				SPadTask *task = [[SPadTask alloc] initWithPrimaryKey:primaryKey database:database];
				[retList addObject:task];
				[task release];
			}
		}
		
		sqlite3_finalize(statement);		
	}else
		//printf("Database can not open!");
	
	return retList;
	
}

#pragma mark HyperNote

-(NSMutableArray *)getAllHyperNotes{
	
	NSMutableArray *hyperNotes=[NSMutableArray array];
	
	if(hasRestoringDB){
		NSString *sql =@"SELECT primaryKey FROM HyperNotes";
		sqlite3_stmt *statement;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				int primaryKey = sqlite3_column_int(statement, 0);
				// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
				// autorelease is slightly more expensive than release. This design choice has nothing to do with
				// actual memory management - at the end of this block of code, all the book objects allocated
				// here will be in memory regardless of whether we use autorelease or release, because they are
				// retained by the books array.
				HyperNote *item = [[HyperNote alloc] initWithPrimaryKey:primaryKey database:database];
				[hyperNotes addObject:item];
				[item release];
			}
		}
		
		// "Finalize" the statement - releases the resources associated with the statement.
		sqlite3_finalize(statement);
	}
	return hyperNotes;
}

#pragma mark Demos
-(void)restoreFromInternalBackup{
    NSString *sourceFilename = @"Database.sql";
    NSString *destionationFilename = @"Database_Backup.sql";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *sourcePath = [documentsDirectory stringByAppendingPathComponent: sourceFilename];
    NSString *destPath = [documentsDirectory stringByAppendingPathComponent: destionationFilename];
    
    NSError *error=nil;
    NSData *sourceData=[NSData dataWithContentsOfFile:destPath];
    [sourceData writeToFile:sourcePath options:NSAtomicWrite error:&error];
    
}

-(BOOL)hasInternalBackedup{
    BOOL ret=NO;
    NSString *destionationFilename = @"Database_Backup.sql";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *destPath = [documentsDirectory stringByAppendingPathComponent: destionationFilename];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:destPath]) {
        ret=YES;
    }
    
    return ret;
}

@end
