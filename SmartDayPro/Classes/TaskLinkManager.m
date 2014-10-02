//
//  TaskLinkManager.m
//  SmartCal
//
//  Created by Left Coast Logic on 6/12/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import <sqlite3.h>

#import "TaskLinkManager.h"

#import "Common.h"
#import "Link.h"
#import "Task.h"
#import "LinkInfo2Sort.h"

#import "DBManager.h"
#import "TaskManager.h"
#import "URLAssetManager.h"

TaskLinkManager *_tlmSingleton = nil;

@implementation TaskLinkManager

- (id) init
{
    self = [super init];
    
    if (self)
    {
        
    }
    
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (NSInteger) createLink:(NSInteger)sourceId destId:(NSInteger)destId destType:(NSInteger)destType
{
    NSInteger pk = -1;
    
    //if ((sourceId == destId) || [self checkLinkExist:sourceId destId:destId] || sourceId == -1 || destId == -1)
    if ([self checkLinkExist:sourceId destId:destId destType:destType] || sourceId == -1 || destId == -1)
    {
        return -1;
    }
    
    sqlite3 *database = [[DBManager getInstance] getDatabase];
    
    sqlite3_stmt *statement;
    
    static char *sql = "INSERT INTO TaskLinkTable (Source_ID,Dest_ID,Dest_AssetType,Status,CreationTime,UpdateTime) VALUES (?,?,?,?,?,?)";
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) 
    {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
    
	sqlite3_bind_int(statement, 1, sourceId);
	sqlite3_bind_int(statement, 2, destId);
    sqlite3_bind_int(statement, 3, destType);
	sqlite3_bind_int(statement, 4, LINK_STATUS_NONE);
    
	NSTimeInterval creationTimeValue = [[Common toDBDate:[NSDate date]] timeIntervalSince1970];
    NSTimeInterval updateTimeValue = [[NSDate date] timeIntervalSince1970];
    
    sqlite3_bind_double(statement, 5, creationTimeValue);
    sqlite3_bind_double(statement, 6, updateTimeValue);
    
    int success = sqlite3_step(statement);
    
    if (success != SQLITE_ERROR) 
    {
        pk = sqlite3_last_insert_rowid(database);
    }
    
    sqlite3_finalize(statement);
    
    if (pk != -1)
    {
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:sourceId],
                              @"LinkSourceID",
                              [NSNumber numberWithInt:destId],
                              @"LinkDestID",
                              nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LinkChangeNotification" object:nil userInfo:dict];
    }

    return pk;
}

- (void) deleteLink:(NSInteger)linkId cleanDB:(BOOL)cleanDB
{
    sqlite3 *database = [[DBManager getInstance] getDatabase];
    
    sqlite3_stmt *statement;
    
    const char *sql = cleanDB?"DELETE FROM TaskLinkTable WHERE TaskLink_ID=?":
                            "UPDATE TaskLinkTable SET Status=?,UpdateTime=? WHERE TaskLink_ID=?";
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) 
    {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }

    if (cleanDB)
    {
        sqlite3_bind_int(statement, 1, linkId);
    }
    else 
    {
        NSTimeInterval updateTimeValue = [[NSDate date] timeIntervalSince1970];
        
        sqlite3_bind_int(statement, 1, LINK_STATUS_DELETED);
        sqlite3_bind_double(statement, 2, updateTimeValue);
        sqlite3_bind_int(statement, 3, linkId);
    }
    
    if (sqlite3_step(statement) == SQLITE_ERROR)
    {
        NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));        
    }
    
    sqlite3_finalize(statement);
}

- (void) deleteAllLinks4Task:(Task *)task
{
    NSInteger taskId = (task.original != nil && ![task isREException]?task.original.primaryKey:task.primaryKey);
    NSArray *links = [[task.links retain] autorelease];
    
    for (NSNumber *linkNum in links)
    {
        NSInteger linkId = [linkNum intValue];
        
        [self deleteLink4Task:taskId linkId:linkId];
    }
    
    task.links = [NSMutableArray arrayWithCapacity:0];
}

- (void) deleteLink4Task:(NSInteger)taskId linkId:(NSInteger)linkId
{
    DBManager *dbm = [DBManager getInstance];
    
    NSInteger linkedAssetId = [self getLinkedId4Task:taskId linkId:linkId];
    
    NSInteger linkedAssetType = [self getLinkedAssetType4Task:taskId linkId:linkId];
    
    if (linkedAssetType == ASSET_URL)
    {
        URLAssetManager *uam = [URLAssetManager getInstance];
        
        BOOL cleanable = [uam checkCleanable:linkedAssetId];
        
        [uam deleteURL:linkedAssetId cleanDB:cleanable];
    }
    
    //[self deleteLink:linkId cleanDB:NO];
    Link *link = [[Link alloc] initWithPrimaryKey:linkId database:[dbm getDatabase]];
    [link deleteFromDatabase:[dbm getDatabase]];
    
    [link release];

    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:taskId],
                          @"LinkSourceID",
                          [NSNumber numberWithInt:linkedAssetId],
                          @"LinkDestID",
                          nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LinkChangeNotification" object:nil userInfo:dict];    
}

- (void) deleteLink:(Task *)task linkIndex:(NSInteger)linkIndex reloadLink:(BOOL)reloadLink
{
    //TaskManager *tm = [TaskManager getInstance];
    
    //printf("delete link for Task %s at index: %d\n", [task.name UTF8String], linkIndex);
    
    NSNumber *linkNum = [task.links objectAtIndex:linkIndex];
    
    if (linkNum != nil)
    {
        NSInteger linkId = [linkNum intValue];
        
        NSInteger taskId = (task.original != nil?task.original.primaryKey:task.primaryKey);
        
        //NSInteger linkedTaskId = [self getLinkedId4Task:taskId linkId:linkId];
        
        //[self deleteLink:linkId cleanDB:NO];
        
        [self deleteLink4Task:taskId linkId:linkId];

        if (reloadLink)
        {
            task.links = [self getLinkIds4Task:taskId];
        }
        
        /*
        //printf("delete Link - notitfy change src:%d - dest:%d\n", taskId, linkedTaskId);
        
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:taskId],
                              @"LinkSourceID",
                              [NSNumber numberWithInt:linkedTaskId],
                              @"LinkDestID",
                              nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LinkChangeNotification" object:nil userInfo:dict];
        */
    }
}

- (void) modifyUpdateTime:(NSDate *)updateTime linkId:(NSInteger)linkId
{
    sqlite3 *database = [[DBManager getInstance] getDatabase];
    
    sqlite3_stmt *statement;
    
    const char *sql = "UPDATE TaskLinkTable SET Task_UpdateTime=? WHERE TaskLink_ID=?";
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) 
    {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }

    NSTimeInterval updateTimeValue = (updateTime == nil? -1: [updateTime timeIntervalSince1970]);
    
    sqlite3_bind_double(statement, 1, updateTimeValue);
    sqlite3_bind_int(statement, 2, linkId);
    
    if (sqlite3_step(statement) == SQLITE_ERROR)
    {
        NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));        
    }
    
    sqlite3_finalize(statement);    
}

- (NSMutableArray *) getLinkIds4Task:(NSInteger)taskId
{
    NSMutableArray *links = [NSMutableArray arrayWithCapacity:10];
    
    sqlite3 *database = [[DBManager getInstance] getDatabase];
    
    sqlite3_stmt *statement;
    
    const char *sql = "SELECT TaskLink_ID FROM TaskLinkTable WHERE (Source_ID=? OR Dest_ID=?) AND Status<>?";
    
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_int(statement, 1, taskId);
        sqlite3_bind_int(statement, 2, taskId);
        sqlite3_bind_int(statement, 3, LINK_STATUS_DELETED);
        
		while (sqlite3_step(statement) == SQLITE_ROW) 
        {
			int primaryKey = sqlite3_column_int(statement, 0);
            
            [links addObject:[self getLinkInfo2Sort4Task:taskId linkId:primaryKey]];
		}
	}
    else 
    {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
    
	sqlite3_finalize(statement);
    
    ////printf("Get Link: task %d has %d links\n", taskId, ret.count);
    
    if (links.count > 0)
    {
        NSSortDescriptor *type_descriptor = [[NSSortDescriptor alloc] initWithKey:@"linkedType" ascending:NO];
        NSSortDescriptor *time_descriptor = [[NSSortDescriptor alloc] initWithKey:@"updateTime" ascending:NO];
        
        NSArray *sortDescriptors = [NSArray arrayWithObjects:type_descriptor,time_descriptor,nil];
        
        [type_descriptor release];
        [time_descriptor release];
        
        [links sortUsingDescriptors:sortDescriptors];
    }
    
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:links.count];
    
    for (LinkInfo2Sort *info in links)
    {
        [ret addObject:[NSNumber numberWithInt:info.linkId]];
    }
    
    return ret;
}

- (NSMutableArray *) getLinks4Task:(NSInteger)taskId
{
    NSMutableArray *links = [NSMutableArray arrayWithCapacity:10];
    
    sqlite3 *database = [[DBManager getInstance] getDatabase];
    
    sqlite3_stmt *statement;
    
    const char *sql = "SELECT TaskLink_ID FROM TaskLinkTable WHERE (Source_ID=? OR Dest_ID=?) AND Status<>?";
    
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_int(statement, 1, taskId);
        sqlite3_bind_int(statement, 2, taskId);
        sqlite3_bind_int(statement, 3, LINK_STATUS_DELETED);
        
		while (sqlite3_step(statement) == SQLITE_ROW)
        {
			int primaryKey = sqlite3_column_int(statement, 0);
            
            Link *link = [[Link alloc] initWithPrimaryKey:primaryKey database:database];
            
            [links addObject:link];
            
            [link release];
		}
	}
    else
    {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
    
	sqlite3_finalize(statement);
    
    return links;
}

- (NSInteger) getLinkedId4Task:(NSInteger)taskId linkId:(NSInteger)linkId
{
    sqlite3 *database = [[DBManager getInstance] getDatabase];
    
    sqlite3_stmt *statement;
    
    const char *sql = "SELECT Source_ID, Dest_ID FROM TaskLinkTable WHERE TaskLink_ID = ?";
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) 
    {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
    
    sqlite3_bind_int(statement, 1, linkId);
    
    if (sqlite3_step(statement) == SQLITE_ERROR)
    {
        NSAssert1(0, @"Error: failed to select from the database with message '%s'.", sqlite3_errmsg(database));        
    }
    
    NSInteger sourceId = sqlite3_column_int(statement, 0);
    NSInteger destId = sqlite3_column_int(statement, 1);
    
    sqlite3_finalize(statement);
    
    if (sourceId == taskId)
    {
        return destId;
    }
    else if (destId == taskId)
    {
        return sourceId;
    }
    
    return -1;
}

- (NSInteger) getLinkedAssetType4Task:(NSInteger)taskId linkId:(NSInteger)linkId
{
    NSInteger ret = -1;
    
    sqlite3 *database = [[DBManager getInstance] getDatabase];
    
    sqlite3_stmt *statement;
    
    const char *sql = "SELECT Dest_AssetType FROM TaskLinkTable WHERE TaskLink_ID = ? AND Source_ID = ?";
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)
    {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
    
    sqlite3_bind_int(statement, 1, linkId);
    sqlite3_bind_int(statement, 2, taskId);
    
    int result = sqlite3_step(statement);
    
    if (result == SQLITE_ERROR)
    {
        NSAssert1(0, @"Error: failed to select from the database with message '%s'.", sqlite3_errmsg(database));
    }
    else if (result == SQLITE_ROW)
    {
        ret = sqlite3_column_int(statement, 0);
    }
    
    sqlite3_finalize(statement);
    
    return ret;
}


- (LinkInfo2Sort *) getLinkInfo2Sort4Task:(NSInteger)taskId linkId:(NSInteger)linkId
{
    DBManager *dbm = [DBManager getInstance];
    
    LinkInfo2Sort *ret = [[LinkInfo2Sort alloc] init];
    ret.linkId = linkId;
    
    Link *link = [[Link alloc] initWithPrimaryKey:linkId database:[dbm getDatabase]];
    
    ret.updateTime = link.updateTime;
    
    NSInteger linkedId = (link.srcId == taskId?link.destId:link.srcId);
    
    if (link.destAssetType == ASSET_URL && linkedId == link.destId)
    {
        ret.linkedType = 0;
    }
    else
    {
        sqlite3 *database = [[DBManager getInstance] getDatabase];
        
        sqlite3_stmt *statement;
        
        const char *sql = "SELECT TASK_TYPE FROM TaskTable WHERE Task_ID = ?";
        
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
        
        sqlite3_bind_int(statement, 1, linkedId);
        
        if (sqlite3_step(statement) == SQLITE_ERROR)
        {
            NSAssert1(0, @"Error: failed to select from the database with message '%s'.", sqlite3_errmsg(database));
        }
        
        int taskType = sqlite3_column_int(statement, 0);
        
        sqlite3_finalize(statement);
        
        ret.linkedType = (taskType == TYPE_NOTE?1:0);        
    }
    
    [link release];
    
    return [ret autorelease];
    
}

//- (BOOL) checkLinkExist:(NSInteger)srcId destId:(NSInteger)destId
- (BOOL) checkLinkExist:(NSInteger)srcId destId:(NSInteger)destId destType:(NSInteger)destType
{
    BOOL ret = NO;
    
    sqlite3 *database = [[DBManager getInstance] getDatabase];
    
    sqlite3_stmt *statement;
    
    //const char *sql = "SELECT TaskLink_ID FROM TaskLinkTable WHERE ((Source_ID = ? AND Dest_ID = ?) OR (Source_ID = ? AND Dest_ID = ?)) AND Status <> ?";
    const char *sql = "SELECT TaskLink_ID FROM TaskLinkTable WHERE Source_ID = ? AND Dest_ID = ? AND Dest_AssetType = ? AND Status <> ?";

    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) 
    {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
    
    sqlite3_bind_int(statement, 1, srcId);
    sqlite3_bind_int(statement, 2, destId);
    //sqlite3_bind_int(statement, 3, destId);
    //sqlite3_bind_int(statement, 4, srcId);
    //sqlite3_bind_int(statement, 5, LINK_STATUS_DELETED);
    sqlite3_bind_int(statement, 3, destType);
    sqlite3_bind_int(statement, 4, LINK_STATUS_DELETED);
    
    int success = sqlite3_step(statement);
    
    if (success == SQLITE_ROW)
    {
        ret = YES;
    }
    else if (success == SQLITE_ERROR)
    {
        NSAssert1(0, @"Error: failed to select from the database with message '%s'.", sqlite3_errmsg(database));        
    }
    
    return ret;    
}

- (void) deleteAllLinksContainingTask:(NSInteger)taskId
{
    sqlite3 *database = [[DBManager getInstance] getDatabase];
    
    sqlite3_stmt *statement;
    
    NSString *sql = @"Update TaskLinkTable SET Status = ?, UpdateTime = ?  WHERE (Source_ID=? OR Dest_ID=?)";
    
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        NSTimeInterval updateTimeValue = [[NSDate date] timeIntervalSince1970];
        
        sqlite3_bind_int(statement, 1, LINK_STATUS_DELETED);
        sqlite3_bind_double(statement, 2, updateTimeValue);
        sqlite3_bind_int(statement, 3, taskId);
        sqlite3_bind_int(statement, 4, taskId);
        
		sqlite3_step(statement);
	}
    else
    {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
    
	sqlite3_finalize(statement);
}

#pragma mark Public Methods

+ (NSDictionary *) getLinkDictBySDWID:(NSArray *)linkList
{
	NSMutableArray *mappingList = [NSMutableArray arrayWithCapacity:linkList.count];
	
	for (Link *link in linkList)
	{
		[mappingList addObject:link.sdwId];
	}
	
	return [NSDictionary dictionaryWithObjects:linkList forKeys:mappingList];
}

+ (NSDictionary *) getLinkDictByKey:(NSArray *)linkList
{
	NSMutableArray *mappingList = [NSMutableArray arrayWithCapacity:linkList.count];
	
	for (Link *link in linkList)
	{
		[mappingList addObject:[NSNumber numberWithInt:link.primaryKey]];
	}
	
	return [NSDictionary dictionaryWithObjects:linkList forKeys:mappingList];
}

+(id)getInstance
{
	if (_tlmSingleton == nil)
	{
		_tlmSingleton = [[TaskLinkManager alloc] init];
	}
	
	return _tlmSingleton;
}

+(void)free
{
	if (_tlmSingleton != nil)
	{
		[_tlmSingleton release];
		
		_tlmSingleton = nil;
	}
}

@end
