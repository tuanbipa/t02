//
//  URLAssetManager.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 7/29/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "URLAssetManager.h"

#import "DBManager.h"

URLAssetManager *_urlAssetManagerSingleton;

@implementation URLAssetManager

- (id) init
{
    if (self = [super init])
    {
        
    }
    
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (NSInteger) createURL:(NSString *)value
{
    NSInteger pk = -1;
    
    sqlite3 *database = [[DBManager getInstance] getDatabase];
    
    sqlite3_stmt *statement;
    
    static char *sql = "INSERT INTO URLTable (URL_Value, URL_Status, URL_UpdateTime, URL_SDWID) VALUES (?,?,?,'')";
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)
    {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
    
    NSTimeInterval updateTimeValue = [[NSDate date] timeIntervalSince1970];
    
    sqlite3_bind_text(statement, 1, [value UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(statement, 2, URL_STATUS_NONE);
    sqlite3_bind_double(statement, 3, updateTimeValue);
    
    int success = sqlite3_step(statement);
    
    if (success != SQLITE_ERROR)
    {
        pk = sqlite3_last_insert_rowid(database);
    }
    
    sqlite3_finalize(statement);
        
    return pk;
}

- (void) updateURL:(NSInteger)pk value:(NSString *)value
{
    sqlite3 *database = [[DBManager getInstance] getDatabase];
    
    sqlite3_stmt *statement;
    
    static char *sql = "UPDATE URLTable SET URL_Value=?, URL_UpdateTime=? WHERE URL_ID=?";
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)
    {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
    
    NSTimeInterval updateTimeValue = [[NSDate date] timeIntervalSince1970];
    
    sqlite3_bind_text(statement, 1, [value UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_double(statement, 2, updateTimeValue);
    sqlite3_bind_int(statement, 3, pk);
    
    if (sqlite3_step(statement) == SQLITE_ERROR)
    {
        NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
    }
    
    sqlite3_finalize(statement);
}

- (void) deleteURL:(NSInteger)pk cleanDB:(BOOL)cleanDB
{
    sqlite3 *database = [[DBManager getInstance] getDatabase];
    
    sqlite3_stmt *statement;
    
    const char *sql = cleanDB?"DELETE FROM URLTable WHERE URL_ID=?":
    "UPDATE URLTable SET URL_Status=?, URL_UpdateTime=? WHERE URL_ID=?";
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)
    {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
    
    if (cleanDB)
    {
        sqlite3_bind_int(statement, 1, pk);
    }
    else
    {
        NSTimeInterval updateTimeValue = [[NSDate date] timeIntervalSince1970];
        
        sqlite3_bind_int(statement, 1, URL_STATUS_DELETED);
        sqlite3_bind_double(statement, 2, updateTimeValue);
        sqlite3_bind_int(statement, 3, pk);
    }
    
    if (sqlite3_step(statement) == SQLITE_ERROR)
    {
        NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
    }
    
    sqlite3_finalize(statement);
}

- (NSString *) getURLValue:(NSInteger)pk
{
    NSString *ret = @"";
    
    sqlite3 *database = [[DBManager getInstance] getDatabase];
    
    sqlite3_stmt *statement;
    
    static char *sql = "SELECT URL_Value FROM URLTable WHERE URL_ID=?";
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)
    {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
    
    sqlite3_bind_int(statement, 1, pk);

    int result = sqlite3_step(statement);
    
    if (result == SQLITE_ERROR)
    {
        NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
    }
    else if (result == SQLITE_ROW)
    {
        char *str = (char *)sqlite3_column_text(statement, 0);
        ret = (str == NULL? @"":[NSString stringWithUTF8String:str]);
    }
    
    sqlite3_finalize(statement);
    
    return ret;
}

- (BOOL) checkCleanable:(NSInteger)pk
{
    BOOL ret = YES;
    
    sqlite3 *database = [[DBManager getInstance] getDatabase];
    
    sqlite3_stmt *statement;
    
    static char *sql = "SELECT URL_SDWID FROM URLTable WHERE URL_ID=?";
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)
    {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
    
    sqlite3_bind_int(statement, 1, pk);
    
    int result = sqlite3_step(statement);
    
    if (result == SQLITE_ERROR)
    {
        NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
    }
    else if (result == SQLITE_ROW)
    {
        char *str = (char *)sqlite3_column_text(statement, 0);
        NSString *sdwId = (str == NULL? @"":[NSString stringWithUTF8String:str]);
        
        ret = ([sdwId isEqualToString:@""]);
    }
    
    sqlite3_finalize(statement);
    
    return ret;
}

+(id)getInstance
{
	if (_urlAssetManagerSingleton == nil)
	{
		_urlAssetManagerSingleton = [[URLAssetManager alloc] init];
	}
	
	return _urlAssetManagerSingleton;
}

+(void)free
{
	if (_urlAssetManagerSingleton != nil)
	{
		[_urlAssetManagerSingleton release];
		
		_urlAssetManagerSingleton = nil;
	}
}

@end
