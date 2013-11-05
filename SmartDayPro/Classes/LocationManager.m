//
//  LocationManager.m
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 10/28/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "LocationManager.h"
#import "DBManager.h"
#import "Location.h"

LocationManager *_locationManagerSingleton = nil;

@implementation LocationManager

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

+(id)getInstance
{
	if (_locationManagerSingleton == nil)
	{
		_locationManagerSingleton = [[LocationManager alloc] init];
	}
	
	return _locationManagerSingleton;
}

+(void)free
{
	if (_locationManagerSingleton != nil)
	{
		[_locationManagerSingleton release];
		
		_locationManagerSingleton = nil;
	}
}

- (NSMutableArray*)getAllLocation
{
    NSMutableArray *locations = [NSMutableArray arrayWithCapacity:10];
    
    sqlite3 *database = [[DBManager getInstance] getDatabase];
    
    sqlite3_stmt *statement;
    
    const char *sql = "SELECT Location_ID FROM LocationTable";
    
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
        
		while (sqlite3_step(statement) == SQLITE_ROW)
        {
			int primaryKey = sqlite3_column_int(statement, 0);
            
            Location *loc = [[Location alloc] initWithPrimaryKey:primaryKey database:database];
            [locations addObject:loc];
            [loc release];
		}
	}
    else
    {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
    
    return  locations;
}

- (void)saveLocation: (Location*) location
{
    sqlite3 *database = [[DBManager getInstance] getDatabase];
    if (location.primaryKey == -1) {
        [location insetIntoDB:database];
    } else {
        [location updateIntoDB:database];
    }
}

- (void)resetLocationStatus
{
    sqlite3_stmt *statement = nil;
    
    sqlite3 *database = [[DBManager getInstance] getDatabase];
	
    if (statement == nil) {
		static char *sql = "UPDATE LocationTable SET Location_Inside = ?";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	sqlite3_bind_int(statement, 1, LOCATION_NONE);
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to query with message '%s'.", sqlite3_errmsg(database));
	}
}

- (NSMutableArray*)getLocationsByStatus: (NSInteger) status
{
    NSMutableArray *locations = [NSMutableArray array];
    
    sqlite3 *database = [[DBManager getInstance] getDatabase];
    
    sqlite3_stmt *statement;
    
    const char *sql = "SELECT Location_ID FROM LocationTable WHERE Location_Inside = ?";
    
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
        
        sqlite3_bind_int(statement, 1, status);
        
		while (sqlite3_step(statement) == SQLITE_ROW)
        {
			int primaryKey = sqlite3_column_int(statement, 0);
            
            Location *loc = [[Location alloc] initWithPrimaryKey:primaryKey database:database];
            [locations addObject:loc];
            [loc release];
		}
	}
    else
    {
        NSAssert1(0, @"Error: failed to query with message '%s'.", sqlite3_errmsg(database));
    }
    
    return  locations;
}
@end
