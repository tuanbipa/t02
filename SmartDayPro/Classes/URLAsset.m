//
//  URLAsset.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 7/29/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//
#import <sqlite3.h>

#import "URLAsset.h"

#import "DBManager.h"

@implementation URLAsset

@synthesize primaryKey;
@synthesize urlValue;

- (id)init
{
	if (self = [super init])
	{
        self.urlValue = @"";
    }
    
    return self;
}

- (void) dealloc
{
    self.urlValue = nil;
    
    [super dealloc];
}

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)database
{
    if (self = [super init])
	{
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
            self.primaryKey = pk;
            
            char *str = (char *)sqlite3_column_text(statement, 0);
            self.urlValue = (str == NULL? @"":[NSString stringWithUTF8String:str]);
        }
        
        sqlite3_finalize(statement);
    }
    
    return self;
}

@end
