//
//  DBManager.h
//  SmartPlan
//
//  Created by Huy Le on 12/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sqlite3.h>

#import "Common.h"

@class Task;
@class TaskProgress;

@interface DBManager : NSObject {
	sqlite3 *database;
}

+(void)startup;
+(id)getInstance;
+(void)free;

- (sqlite3 *) getDatabase;
- (void)createEditableCopyOfDatabaseIfNeeded;
- (void)initializeDatabase;

- (NSMutableArray *) searchTitle:(NSString *)text;
- (NSMutableArray *) searchLinkSource:(NSInteger)linkId;
- (NSMutableArray *) getAllNotes;
- (NSMutableArray *) getTodayNotes;
//- (NSMutableArray *) getNotesByDate:(NSDate *)date;
- (NSMutableArray *) getNotesByThisWeek;
- (NSString *) getItemNameByKey:(NSInteger)taskKey;
- (NSString *) getProjectNameByKey:(NSInteger)prjKey;
- (NSMutableArray *) getAllTasks;
- (NSMutableArray *) getAllTasksEventsHaveLocation;
- (NSMutableArray *) getTasks2Sync;
- (NSMutableArray *) getModifiedTasks2Sync:(NSDate *)afterDate;
- (NSMutableArray *) getTasks;
//- (NSMutableArray *)getManualTasks;
//- (NSMutableArray *)getManualTasksFromDate: (NSDate *) fromDate toDate: (NSDate *) toDate;
- (NSMutableArray *) getVisibleTasks;
- (NSMutableArray *) getRecurringTasks;
- (NSMutableArray *) getMustDoTasks;
- (NSMutableArray *) getDueTasks;
- (NSMutableArray *) getOverdueTasks;
- (NSMutableArray *) getStartTasks;
- (NSMutableArray *) getActiveTasks;
- (NSMutableArray *) getInActiveTasks;
- (NSMutableArray *) getPinnedTasks;
- (NSMutableArray *) getDoneTasks;
- (NSMutableArray *) getDoneTasks4Plan:(NSInteger)planKey;
- (NSMutableArray *) getDoneTasksToday;
- (NSMutableArray *) getDoneTasksOnDate: (NSDate*) date;
- (NSMutableArray *) getDoneTasksFromDate: (NSDate*) fromDate toDate: (NSDate*) toDate;
- (NSInteger) countItems: (NSInteger)type inPlan:(NSInteger)inPlan;
- (NSMutableArray *) getItems: (NSInteger)type inPlan:(NSInteger)inPlan;
- (NSMutableArray *) getAllItemsForPlan:(NSInteger)planKey;
- (NSMutableArray *) getTasksForPlan:(NSInteger)planKey;
- (NSMutableArray *) getPinnedTasksForPlan:(NSInteger)planKey;
- (NSMutableArray *) getActiveTasksForPlan:(NSInteger)planKey;
- (NSMutableArray *) getTasksInGroup:(NSInteger)groupKey;
- (Task *) getDeletedExceptionForRE:(NSInteger)reKey;
- (NSMutableArray *) getExceptionsForRE:(NSInteger)reKey;
- (NSMutableArray *) getREs;
- (NSMutableArray *) getRADEs;
- (NSMutableArray *) getNotesOnDate:(NSDate *)date;
- (NSMutableArray *) getNotesFromDate:(NSDate *)fromDate toDate:(NSDate *) toDate;
- (NSMutableArray *) getEventsOnDate:(NSDate *)date;
- (NSMutableArray *) getADEsOnDate:(NSDate *)date;
- (NSMutableArray *) getSTasksOnDate:(NSDate *)date;
- (NSMutableArray *) getSTasksFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (NSMutableArray *) getDueTasksOnDate:(NSDate *)date;
- (NSMutableArray *) getDueTasksFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (NSMutableArray *) getAnchoredTasksFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (BOOL) checkDueTasksOnDate:(NSDate *)date;
- (NSMutableArray *) getEventsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (NSMutableArray *) getADEsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (NSMutableArray *) getAllEvents; //get all non-repeating events
- (NSMutableArray *) getEvents2Sync;
- (NSMutableArray *) getEvents2SyncFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
//- (NSMutableArray *) getModifiedEvents:(NSDate *)afterDate;
- (NSMutableArray *) getDeletedEvents;
- (NSMutableArray *) getDeletedTasks;
- (void) deleteTasksInGroup:(NSInteger)groupKey;
//- (void) deleteTasksForProject:(NSInteger)prjKey;
- (void) cleanTasksToDate:(NSDate *)toDate;
- (NSMutableArray *) getAlertsForTask:(NSInteger)taskKey;
- (void) deleteAlertsForTask:(NSInteger)taskKey;
- (NSInteger) getTaskMinSortSeqNo;
- (NSInteger) getTaskMaxSortSeqNo;
- (BOOL) checkNeedResort;
- (NSInteger) getTaskMaxSeqNo;
- (NSInteger) getTaskMaxSeqNoForPlan:(NSInteger)key;
- (NSInteger) getPlanMaxSeqNo;
- (NSMutableArray *) getPlanList;
- (NSInteger) getColorOfProject:(NSInteger)prjKey;
- (NSMutableArray *)getProjects;
- (NSMutableArray *)getPlans;
- (NSMutableArray *) getDeletedPlans;
- (Task *) getTopTaskForPlan:(NSInteger)key excludeFutureTasks:(BOOL)excludeFutureTasks;
- (void) resetEventSyncIdForProject:(NSInteger) prjKey;
- (void) resetProjectSyncIds;
- (void) resetTaskSyncIds;
- (void) resetSDWIds;
- (NSInteger) getTaskCountForProject:(NSInteger) prjKey;
- (NSInteger) getEventCountForProject:(NSInteger) prjKey;
- (NSInteger) countTasksForProject:(NSInteger) prjKey;
- (NSMutableArray *) getTasksForProject:(NSInteger) prjKey isInitial:(BOOL)isInitial groupExcluded:(BOOL)groupExcluded;
- (NSMutableArray *) getTasksWithDurationForProject:(NSInteger) prjKey estimatedOnly:(BOOL)estimatedOnly;
- (ProgressInfo) getProgressInfoForProject:(NSInteger) prjKey;
- (CGFloat) getActualDurationForTask:(NSInteger) taskKey;
- (NSMutableArray *) getAllProgressHistoryForTask:(NSInteger) taskKey;
- (NSMutableArray *) getProgressHistoryForTask:(NSInteger) taskKey;
- (Task *)getTBDTaskForProject:(NSInteger)prjKey;
- (NSInteger) getTaskMaxSeqNoForProject:(NSInteger) prjKey;
- (void) cleanTaskByToodledoId:(NSString *)toodledoId;
- (void) cleanAllEventsForProject:(NSInteger)prjKey;
- (void) cleanAllTasksForProject:(NSInteger)prjKey;
- (void) cleanAllItemsForProject:(NSInteger)prjKey;
- (void) cleanAllProjects;
- (void) deleteAllItemsForProject:(NSInteger)prjKey;
- (void) deleteAllProgressForTask:(NSInteger)taskKey;
- (void) deleteAllComments:(NSInteger)itemKey;
-(NSMutableArray *) getActiveTaskList;
-(NSMutableArray *) getInProgressTaskList;
-(TaskProgress *)getLastProgressForTask:(NSInteger) taskKey;
- (GoalInfo) getGoalFromDate:(NSDate *)startDate toDate:(NSDate *)endDate;

//SDW Sync
- (NSMutableArray *) getAllComments;
- (NSInteger) countCommentsForItem:(NSInteger) itemId;
- (NSMutableArray *) getComments4Item:(NSInteger)itemId;
- (void) updateCommentStatus:(NSInteger)status forItem:(NSInteger)itemId;
- (NSInteger) countUnreadComments;
- (NSMutableArray *) getUnreadComments;
- (NSMutableArray *) getAllURLAssets;
- (NSMutableArray *) getDeletedURLAssets;
- (NSMutableArray *) getItems2Sync;
- (NSMutableArray *) getModifiedItems2Sync:(NSDate *)afterDate;
- (NSMutableArray *) getDeletedItems2Sync;
- (NSMutableArray *) getDeletedLinks;
- (NSMutableArray *) getAllLinks;
- (NSMutableArray *) getModifiedLinks2Sync:(NSDate *)afterDate;
- (NSString *) getSDWId4Key:(NSInteger)key;
- (NSInteger) getKey4SDWId:(NSString *)sdwId;
- (NSString *) getSDWId4ProjectKey:(NSInteger)key;
- (NSInteger) getProjectKey4SDWId:(NSString *)sdwId;
- (NSString *) getSDWId4URLAssetKey:(NSInteger)key;
- (NSInteger) getURLAssetKey4SDWId:(NSString *)sdwId;
- (NSDate *) getLastestTaskUpdateTime;
- (void)deleteSuspectedDuplication;
- (void) cleanDB;

- (void)upgrade;
- (void)upgradeDBv1_0_2;
- (void)upgradeDBv2_0;
- (void)upgradeDBv3_0;

@end
