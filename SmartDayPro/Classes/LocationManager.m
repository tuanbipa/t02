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
@end
