//
//  TaskManager.h
//  SmartCal
//
//  Created by Trung Nguyen on 5/19/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FilterData;
@class Task;
@class TaskProgress;

@interface TaskManager : NSObject {
	//smartList data
	NSMutableArray *taskList;
    NSMutableArray *mustDoTaskList;
	NSMutableArray *scheduledTaskList;
	
	//calendar day data
	//NSMutableArray *todayEventList;
    
    //NSMutableArray *garbageList;
	
	NSDate *today;
	
	NSMutableArray *REList;
	NSMutableArray *RADEList;
	
	NSDate *dayManagerStartTime;
	NSDate *dayManagerEndTime;
	
	FilterData *filterData;
	
	NSInteger taskTypeFilter;
    BOOL filterChanged;
	
	// remember duration and color of previous Task for quick edit
	NSInteger lastTaskDuration;
	NSInteger lastTaskProjectKey;
	
	NSMutableArray *sortQueue;
	Task *taskDummy;
	Task *eventDummy;
	
	BOOL refreshGTD;
	BOOL sortBGInProgress;
	BOOL scheduleBGInProgress;
	
	BOOL thumbPlannerBGInProgress;
	
	NSCondition *sortCond;
	NSCondition *thumbPlannerBGCond;
    NSCondition *scheduleBGCond;
}

@property (nonatomic, retain) NSMutableArray *taskList;
@property (nonatomic, retain) NSMutableArray *mustDoTaskList;
@property (nonatomic, retain) NSMutableArray *scheduledTaskList;

//@property (nonatomic, retain) NSMutableArray *todayEventList;

//@property (nonatomic, retain) NSMutableArray *garbageList;

@property (nonatomic, copy) NSDate *today;

@property (nonatomic, retain) NSMutableArray *REList;
@property (nonatomic, retain) NSMutableArray *RADEList;

@property (nonatomic, copy) NSDate *dayManagerStartTime; 
@property (nonatomic, copy) NSDate *dayManagerEndTime;

@property (nonatomic, copy) FilterData *filterData;

@property (nonatomic, retain) NSMutableArray *sortQueue;

@property NSInteger taskTypeFilter;

@property NSInteger lastTaskDuration;
@property NSInteger lastTaskProjectKey;

@property (nonatomic, readonly) Task *taskDummy;
@property (nonatomic, readonly) Task *eventDummy;

+(id)getInstance;
+(void)startup;
+(void)free;
+ (NSDictionary *) getTaskDictionary:(NSArray *)taskList;
+ (NSDictionary *) getTaskDictionaryBySyncId:(NSArray *)taskList;
+ (NSDictionary *) getTaskDictionaryByName:(NSArray *)taskList;
+ (NSDictionary *) getTaskDictBySDWID:(NSArray *)taskList;
+ (BOOL)checkTaskInTimeRange:(Task *)task startTime:(NSDate *)startTime endTime:(NSDate *)endTime;

- (void) initMiniMonth:(BOOL)inProgress;
- (void) initData;
- (void) initRE;
- (void) reset;
- (NSArray *) getTaskList;
- (NSMutableArray *) splitEvent:(Task *)event;
- (void) splitEvents:(NSMutableArray *) eventList fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (NSMutableArray *) getADEListOnDate:(NSDate *)onDate;
- (NSMutableArray *) getEventListOnDate:(NSDate *)onDate;
- (NSMutableArray *) getNoteList;
- (NSMutableArray *) getWeekNoteList;
- (NSMutableArray *) getNoteListOnDate:(NSDate *)onDate;
- (NSMutableArray *) getNoteListFromDate: (NSDate *) fromDate toDate: (NSDate *) toDate;
- (NSMutableArray *) getDoneTasksToday;
- (NSMutableArray *) getDoneTasksOnDate: (NSDate*)date;
- (NSMutableArray *) getDoneTasksFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate;
- (NSMutableArray *) getEventListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (NSMutableArray *) getADEListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (NSMutableArray *) getDTaskListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (NSMutableArray *) getDTaskListOnDate:(NSDate *)onDate;
- (NSMutableArray *) getSTaskListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (NSMutableArray *) getSTaskListOnDate:(NSDate *)onDate;
- (NSMutableArray *) getOverdueTaskList;
- (NSMutableArray *) getATaskListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (NSMutableArray *) getATaskListOnDate:(NSDate *)onDate;
- (void) initCalendarData:(NSDate *) date;
- (TaskProgress *) getEventSegment:(Task *)task onDate:(NSDate *)onDate;
- (void) addREInstanceToList:(NSMutableArray *)list original:(Task *)re onDate:(NSDate *)onDate fromDate:(NSDate *)fromDate toDate:(NSDate *) toDate;
- (NSMutableArray *) expandRE:(Task *)re fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate excludeException:(BOOL)excludeException;
//- (void) refreshCalendarDataForScrollPage:(int)page;
//- (NSMutableArray *) getEventListForPage:(int)page;
- (NSInteger) getTotalTaskDuration;
- (NSDate *) getWorkingStartTime:(NSDate *)date;
- (NSDate *) getWorkingEndTime:(NSDate *)date;
-(void) findFreeTimeSlotsForDuration:(NSInteger)duration fromDate:(NSDate *)fromDate segments:(NSMutableArray *)segments;
- (void) schedule;
- (void) initDayManager;
- (Task *) findRTInstance:(Task *)rt fromDate:(NSDate *) fromDate;
- (void) sortDue;
- (void) sortStart;
- (void) resort;
- (void) resetTabAllWithList:(NSMutableArray *)allList;
- (void) initSmartListData;
- (void) sortAndReschedule;
- (void) populateEvent:(Task *)task;
- (void) populateRE:(Task *)re fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (void) assignTimeForTask:(Task *)original durationLeft:(NSInteger)durationLeft segments:(NSMutableArray *)segments list:(NSMutableArray *)list;
//- (NSMutableArray *) scheduleTasksWithEvents:(NSMutableArray *)eventList;
- (void) clearScheduledFlag;
- (void) scheduleTasks;
- (NSMutableArray *)findScheduledTasks:(Task *)original;
- (NSMutableArray *)getScheduledTasksOnDate:(NSDate *)date;
- (NSMutableArray *)getUnSplittedScheduledTasksOnDate:(NSDate *)date;
- (NSMutableArray *)getScheduledTasksFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (NSMutableArray *) getTopTasks;
- (void)reconcileSeqNo:(NSArray *)checkList;
- (NSInteger) getDisplayListCount;
- (NSMutableArray *) getDisplayList;
//- (NSMutableArray *) getDisplayListWithManualTasks;
-(void) unDone:(Task *)task;
- (void) populateRE:(Task *)re isNew:(BOOL)isNew;
//-(void) changeTask:(Task *)task toProject:(NSInteger)prjKey;
-(void) sortTasks:(NSMutableArray *)tasks;
-(NSMutableArray *) sortTask:(Task *)task;
-(BOOL) addTask:(Task *)task;
-(BOOL)updateTask:(Task *)taskEdit withTask:(Task *)task;
-(void)createREException:(Task *)instance originalTime:(NSDate *)originalTime;
-(BOOL) changeRE:(Task *)re withUntil:(NSDate *)until;
-(void)updateREInstance:(Task *)instance withRE:(Task *)re updateOption:(NSInteger) updateOption;
//-(void)updateInstancesForRE:(Task *)original;
-(void)deleteREInstance:(Task *)instance deleteOption:(NSInteger) deleteOption;
-(Task *)convertRE2Task:(Task *)instance option:(NSInteger) option;
- (void)removeTaskByKey:(NSInteger)taskKey;
- (void)removeTasksByKey:(NSMutableArray *)tasks;
//-(void)removeTask:(Task *)task deleteFromDB:(BOOL)deleteFromDB;
-(void)removeTask:(Task *)task status:(NSInteger)status;
- (Task *) doneRT:(Task *)rt;
-(void) starTask:(Task *)task;
-(void) starTasks:(NSMutableArray *)tasks;
-(void) markDoneTask:(Task *)task;
-(void) markDoneTasks:(NSMutableArray *)tasks;
-(void) deleteTask:(Task *)task;
-(void) deleteTasks:(NSMutableArray *)tasks;
- (void) removeEventFromList:(NSMutableArray *)list forKey:(NSInteger)key;
- (void) removeEvent:(Task *)event;
- (void)moveTime:(NSDate *)date forEvent:(Task *)event;
- (void)resizeTask:(Task *)task;
- (void) changeOrder:(Task *)srcTask destTask:(Task *)destTask;
- (BOOL) checkFilterIn:(Task *) task;
- (BOOL) checkGlobalFilterIn:(Task *)task;
- (BOOL) checkGlobalFilterIn:(Task *)task tagDict:(NSDictionary *)tagDict catDict:(NSDictionary *)catDict;
- (NSMutableArray *) filterList:(NSMutableArray *)list;
- (void) filterForTaskType:(NSInteger) type;
-(NSDictionary *) getFilterTagDict;
- (void) resetRESyncIdForProject:(NSInteger) prjKey;
- (void) refreshSyncID4AllItems;
//- (void) garbage:(NSObject *)obj;
-(NSDictionary *) getFilterCategoryDict;
- (NSString *) getFilterTitle:(NSInteger)filterType;
- (NSString *) getFilterTitle;
- (void) refreshTopTasks;

- (Task *) getTask2Update:(Task *)taskEdit;
- (Task *) findTaskByKey:(NSInteger)key;
- (Task *) findEventByKey:(NSInteger)key;
- (Task *) findREByKey:(NSInteger)key;
- (Task *) findSmartTask:(Task *)task;
- (Task *) findItemByKey:(NSInteger)key;

- (void) reconcileLinks:(NSDictionary *)dict;
- (void) reloadAlert4Task:(NSInteger)taskId;
- (void)moveTop: (NSArray*) tasks;
- (void) moveTask2Top:(Task *)task;
- (void) defer:(Task *)task deferOption:(NSInteger)deferOption;
- (void)deferTasks: (NSMutableArray*)tasks withOption: (NSInteger)option;

-(void) purge;
-(void) recover;

- (void) wait4ScheduleGBComplete;
- (void) wait4ThumbPlannerInitComplete;
- (void) wait4SortComplete;
//- (void) cleanupGarbage;

@end
