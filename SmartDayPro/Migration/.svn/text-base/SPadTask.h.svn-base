//
//  Task.h
//  iVo_DatabaseAccess
//
//  Created by Nang Le on 4/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <sqlite3.h>
//#import <sqlite3.h>


@interface SPadTask : NSObject {
    // Primary key in the database.
    NSInteger	primaryKey;			//map to task ID from database.
    // General info
	NSInteger	taskType;			//0:smart task (duration>0); 1:event; 2:list item;
	NSInteger	isADE;				//
    NSString	*taskName;			//Task Title
	NSString	*taskLocation;		//Task Location
	NSString	*notes;				//Task Notes
	
	//For logic
	NSDate		*createdDate;
    
	NSDate		*startTime;			//Start Time	
	NSDate		*endTime;			//End Time
	
	NSDate		*dueStart;			//horizon task 
	NSDate		*dueEnd;			//deadline
    
	NSDate		*dateUpdate;		//the date when task is updated
	
	NSDate		*startWindow;		//task start window
	NSDate		*endWindow;			//task end window
	
	NSDate		*completedDate;
	NSInteger	hasDue;				//1: due task, 0:normal task
	NSInteger	taskOrder;
    
	//repeat information
	NSInteger	repeatType;			//
    
	NSDate		*repeatStartDate;	//start date
	NSDate		*repeatEndDate;		//
    
	NSString	*repeatOptions;		//map to Set_Resvr3 in database. Format: "RepeatEvery|RepeatOn|RepeatBy"
	NSString	*repeatExceptions;	//map to Set_Resvr2 in database.
    
	NSInteger	isRepeatForever;	//1: repeat forever; 0: has repeat end
	
	//detail
	NSInteger	status;				//not start, starting, pausing, done
	NSInteger	whatId;				//what ID for What Actions	
	NSInteger	whoId;				//who ID for Contact
	NSString	*contactName;
	NSInteger	contextId;			//0:home; 1: work (context)
	
	NSInteger	originalContextId;	//keep track for where
	NSInteger	hasDuration;
	NSInteger	duration;			//durations in mins
	
	NSInteger	calendarId;			//calendar ID from Calendar list
	NSInteger	parentId;			//for RE dummies use to link to its parent
	
	NSInteger	updateType;			//0: update; 1: done
	NSInteger	isInitialTask;		//1: task is default
	NSInteger	isPinned;
	
	NSInteger	doingStatus;//1:is doing; 2: is pausing
	NSString    *doingLogs;//format: /startdatetime1|enddatetime1/startdatetime1|enddatetime1/....
	
	NSDate		*currentStartTime;
	
	//for alerts
	NSDate		*specifiedAlertTime;
	NSString	*alertValues;	//map to Set_Resver1 in database
	NSString	*PNSKey;
	
	//HyperNote use
	NSInteger	hyperNoteId;
    
	//Toodledo syncing use
	NSInteger	toodledoID;
	
	//Gcal uses
	double		gcalSynKey;
	NSString	*gcalEventId;
	NSDate		*originalExceptionDate;//also is original instance date.
	
	//local use
	BOOL		isUsedExternalUpdateTime;//
	BOOL		isDeletedFromGCal;
	NSInteger	originalPKey;		//used for app layer only, for add a group of tasks/Events when syncing to ST;
	NSInteger	overlapIndex;
	NSInteger	totalOverlap;
	NSInteger	showInDayOfWeek;
	NSString	*originalHyperNoteString;
	BOOL		isTopGTDTask;
	
	NSString	*iCalIdentifier;
	NSString	*iCalCalendarName;
	NSInteger	builtIn;
	NSInteger	hiddenFromTaskView;
	
	BOOL		isDisplaying;
	NSInteger	isHidden;
	
	//local uses
	NSInteger		isList;
	BOOL	toodledoHasStart;
	
	NSInteger	gtdOrder;
	NSInteger   taskRepeatStyle;//From Due or from Completion date;
    
    NSInteger   SDWIdentifer;
    
    NSMutableArray *reInstances;
    BOOL    hasUsed;
    
    NSInteger   migrateID;
    
    // Internal state variables. Hydrated tracks whether attribute data is in the object or the database.
    BOOL hydrated;
    // Dirty tracks whether there are in-memory changes to data which have no been written to the database.
    BOOL dirty;
    NSData *data;
	BOOL isFromSyncing;
    BOOL isMyselfException;
}

@property(nonatomic,assign) NSInteger	primaryKey;			//map to task ID from database.
// General info
@property(nonatomic,assign) NSInteger	taskType;			//0:smart task (duration>0); 1:event; 2:list item;
@property(nonatomic,assign) NSInteger	isADE;				//
@property(nonatomic,copy)	NSString	*taskName;			//Task Title
@property(nonatomic,copy)	NSString	*taskLocation;		//Task Location
@property(nonatomic,copy)	NSString	*notes;				//Task Notes

//For logic
@property(nonatomic,copy)	NSDate		*createdDate;
@property(nonatomic,copy)	NSDate		*startTime;			//Start Time	
@property(nonatomic,copy)	NSDate		*endTime;			//End Time
@property(nonatomic,copy)	NSDate		*dueStart;			//horizon task 
@property(nonatomic,copy)	NSDate		*dueEnd;			//deadline
@property(nonatomic,copy)	NSDate		*dateUpdate;		//the date when task is updated
@property(nonatomic,copy)	NSDate		*startWindow;		//task start window
@property(nonatomic,copy)	NSDate		*endWindow;			//task end window
@property(nonatomic,copy)	NSDate		*completedDate;
@property(nonatomic,assign) NSInteger	hasDue;				//1: due task, 0:normal task
@property(nonatomic,assign) NSInteger	taskOrder;

//repeat information
@property(nonatomic,assign) NSInteger	repeatType;			//
@property(nonatomic,copy)	NSDate		*repeatStartDate;	//start date
@property(nonatomic,copy)	NSDate		*repeatEndDate;		//
@property(nonatomic,copy)	NSString	*repeatOptions;		//map to Set_Resvr3 in database. Format: "RepeatEvery|RepeatOn|RepeatBy"
@property(nonatomic,copy)	NSString	*repeatExceptions;	//map to Set_Resvr2 in database.
@property(nonatomic,assign) NSInteger	isRepeatForever;	//1: repeat forever; 0: has repeat end

//detail
@property(nonatomic,assign) NSInteger	status;				//not start, starting, pausing, done
@property(nonatomic,assign) NSInteger	whatId;				//what ID for What Actions
@property(nonatomic,assign) NSInteger	whoId;				//who ID for Contact
@property(nonatomic,copy)	NSString	*contactName;
@property(nonatomic,assign) NSInteger	contextId;			//0:home; 1: work (context)
@property(nonatomic,assign) NSInteger	originalContextId;	//keep track for where
@property(nonatomic,assign) NSInteger	hasDuration;
@property(nonatomic,assign) NSInteger	duration;			//durations
@property(nonatomic,assign) NSInteger	calendarId;			//calendar ID from Calendar list
@property(nonatomic,assign) NSInteger	parentId;			//for RE dummies use to link to its parent
@property(nonatomic,assign) NSInteger	updateType;			//0: update; 1: done
@property(nonatomic,assign) NSInteger	isInitialTask;		//1: task is default
@property(nonatomic,assign) NSInteger	isPinned;
@property(nonatomic,assign) NSInteger	doingStatus;//1:is doing; 0: is stopping
@property(nonatomic,copy)	NSString    *doingLogs;//format: /startdatetime1|enddatetime1/startdatetime1|enddatetime1/....
@property(nonatomic,copy)	NSDate		*currentStartTime;

//for alerts
@property(nonatomic,copy)	NSDate		*specifiedAlertTime;
@property(nonatomic,copy)	NSString	*alertValues;	//map to Set_Resver1 in database
@property(nonatomic,copy)	NSString	*PNSKey;

//HyperNote use
@property(nonatomic,assign) NSInteger	hyperNoteId;

//Toodledo syncing use
@property(nonatomic,assign) NSInteger	toodledoID;

//GCal uses
@property(nonatomic,assign) double		gcalSynKey;
@property(nonatomic,copy)	NSString	*gcalEventId;
@property(nonatomic,copy)	NSDate		*originalExceptionDate;

//iCal uses
@property(nonatomic,copy)	NSString	*iCalIdentifier;
@property(nonatomic,copy)	NSString	*iCalCalendarName;

//local use
//@property(nonatomic,assign) double		gCalSynKey;			//replace for TaskTypeID
@property(nonatomic,assign) BOOL		isDeletedFromGCal;
@property(nonatomic,assign) NSInteger	originalPKey;		//used for app layer only, for add a group of tasks/Events when syncing to ST;

@property(nonatomic,assign) NSInteger	overlapIndex;
@property(nonatomic,assign) NSInteger	totalOverlap;
@property(nonatomic,assign) NSInteger	showInDayOfWeek;
@property(nonatomic,retain) NSString	*originalHyperNoteString;
@property(nonatomic,assign) BOOL		isTopGTDTask;

@property(nonatomic,assign) NSInteger	builtIn;
@property(nonatomic,assign) NSInteger	hiddenFromTaskView;
@property(nonatomic,assign) BOOL		isFromSyncing;
@property(nonatomic,assign) BOOL		isDisplaying;

@property(nonatomic,assign) NSInteger	isHidden;
@property(nonatomic,assign) NSInteger	isList;
@property(nonatomic,assign) BOOL		toodledoHasStart;
@property(nonatomic,assign) NSInteger	gtdOrder;
@property(nonatomic,assign) NSInteger   taskRepeatStyle;//From Due or from Completion date;

@property(nonatomic,assign) NSInteger   SDWIdentifer;

@property(nonatomic,retain) NSMutableArray *reInstances;
@property(nonatomic,assign) BOOL    hasUsed;
@property(nonatomic,assign) BOOL isMyselfException;

@property(nonatomic,assign) NSInteger   migrateID;

//local uses

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements;

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;
- (void)insertIntoDatabase:(sqlite3 *)db ;
- (void)deleteFromDatabase;
- (void)dehydrate;

-(void)copyContentOfTask:(SPadTask *)task;
-(NSMutableArray *)creatAlertList;
-(void)updateAlertList:(NSMutableArray *)list;

//
//- (BOOL)isEqualToTask:(Task *)task;
//-(NSMutableArray *)creatAlertList;

//-(void)updateAlertList:(NSMutableArray *)list;
//-(NSDate *)getOriginalDateOfExceptionInstance;//this is only used for Exception

- (void)dehydrateFromSync;
- (void)normalDehydrate;
- (void)normalInsert;
- (void)insertIntoDatabaseFromSync;
-(id)initWithLessInfo;

@end
