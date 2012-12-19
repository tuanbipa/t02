//
//  Common.h
//  SmartOrganizer
//
//  Created by Nang Le Van on 5/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Calendar.h"
#import <sqlite3.h>
#import "MigrationData.h"
#import "Setting.h"

extern MigrationData *coreData;
extern sqlite3 *database;
extern BOOL     isLockingDB;

extern double gmtSeconds;
extern NSTimeZone	*App_defaultTimeZone;
extern BOOL				isDayLigtSavingTime;
extern NSTimeInterval	dstOffset;

static sqlite3_stmt *insert_statement = nil;
static sqlite3_stmt *init_statement = nil;
static sqlite3_stmt *delete_statement = nil;
static sqlite3_stmt *hydrate_statement = nil;
static sqlite3_stmt *dehydrate_statement = nil;

@implementation Calendar
@synthesize isExpanding;
@synthesize willExport;
@synthesize migrateID;

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
	if(self=[super init]){
		colorGroupId=0;
		colorNameId=0;
		builtIn=0;
		gcalNameKey=@"";
		enableGcalSync=1;
		enableTDSync=1;
        iCalIdentifier=@"";
	}
	return self;
}


// Creates the object with primary key and title is brought into memory.
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db {
    while (isLockingDB) {
        //usleep(20);
        [NSThread sleepForTimeInterval:0.01];
    }
    isLockingDB=YES;
    
    if (self = [super init]) {
        primaryKey = pk;
        if (!database && db) {
            database = db;
        }
        // Compile the query for retrieving book data. See insertNewBookIntoDatabase: for more detail.
        if (init_statement == nil) {
            // Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
            // This is a great way to optimize because frequently used queries can be compiled once, then with each
            // use new variable values can be bound to placeholders.
            const char *sql = "SELECT calendarName,colorNameId,colorGroupId,toodledoFolderKey,isPrivate,gcalNameKey,builtIn,enableGcalSync,enableTDSync,iCalCalendarName,enableICalSync,projectType,calendarOrder,inVisible,iCalIdentifier,SDWIdentifier,lastUpdate FROM Calendars WHERE primaryKey=?";
            if (sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // For this query, we bind the primary key to the first (and only) placeholder in the statement.
        // Note that the parameters are numbered from 1, not from 0.
        sqlite3_bind_int(init_statement, 1, primaryKey);
        if (sqlite3_step(init_statement) == SQLITE_ROW) {
			
            NSDate *date=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 16)-gmtSeconds];
			NSTimeInterval adjustTimeVal=-gmtSeconds -[App_defaultTimeZone daylightSavingTimeOffsetForDate:date]+[App_defaultTimeZone daylightSavingTimeOffset];
            
			char *calName=(char *)sqlite3_column_text(init_statement, 0);
			self.calendarName=(calName)?[NSString stringWithUTF8String:calName] : @"";
			self.colorNameId=sqlite3_column_int(init_statement, 1);
			self.colorGroupId=sqlite3_column_int(init_statement, 2);
			self.toodledoFolderKey=sqlite3_column_int(init_statement, 3);
			self.isPrivate=sqlite3_column_int(init_statement, 4);
			
			char *gcalName=(char *)sqlite3_column_text(init_statement, 5);
			self.gcalNameKey=(gcalName)?[NSString stringWithUTF8String:gcalName] : @"";
			
			self.builtIn=sqlite3_column_int(init_statement, 6);
			self.enableGcalSync=sqlite3_column_int(init_statement, 7);
			self.enableTDSync=sqlite3_column_int(init_statement, 8);
			
			char *icalName=(char *)sqlite3_column_text(init_statement, 9);
			self.iCalCalendarName=(icalName)?[NSString stringWithUTF8String:icalName] : @"";
			
			self.enableICalSync=sqlite3_column_int(init_statement, 10);
			self.projectType=sqlite3_column_int(init_statement, 11);
			self.calendarOrder=sqlite3_column_int(init_statement, 12);
			self.inVisible=sqlite3_column_int(init_statement, 13);
            
			char *icalId=(char *)sqlite3_column_text(init_statement, 14);
			self.iCalIdentifier=(icalId)?[NSString stringWithUTF8String:icalId] : @"";
            
            self.SDWIdentifier=sqlite3_column_int(init_statement, 15);
            
            self.lastUpdate=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 16)];
            
        } else {
			self.calendarName=@"";
			self.colorGroupId=0;
			self.colorNameId=0;
        }
        // Reset the statement for future reuse.
        sqlite3_reset(init_statement);
        dirty = NO;
        isLockingDB=NO;
    }
    return self;
}

-(void)dealloc{
	[calendarName release];
	[gcalNameKey release];
	[iCalCalendarName release];
    [iCalIdentifier release];
    [lastUpdate release];
	[super dealloc];
}

- (void)insertIntoDatabase:(sqlite3 *)db {
    while (isLockingDB) {
        //usleep(20);
        [NSThread sleepForTimeInterval:0.01];
    }
    isLockingDB=YES;

    if (!database && db) {
        database = db;
    }

    // This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed by any Book object.
    if (insert_statement == nil) {
        static char *sql = "INSERT INTO Calendars (calendarOrder) VALUES(?)";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	NSInteger max=[coreData getMaxOrderOfCalendars];
	
    //sqlite3_bind_text(insert_statement, 1, [self.calendarName UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(insert_statement, 1, max+1);
	self.calendarOrder=max+1;
	
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
        const char *sql = "DELETE FROM Calendars WHERE primaryKey=?";
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

// Flushes all but the primary key and title out to the database.
- (void)dehydrate {
    while (isLockingDB) {
        //usleep(20);
        [NSThread sleepForTimeInterval:0.01];
    }
    isLockingDB=YES;

    if (dirty) {
        dirty=NO;
        // Write any changes to the database.
        // First, if needed, compile the dehydrate query.
        if (dehydrate_statement == nil) {
            const char *sql = "UPDATE Calendars SET calendarName=?,colorNameId=?,colorGroupId=?,toodledoFolderKey=?,isPrivate=?,gcalNameKey=?,builtIn=?,enableGcalSync=?,enableTDSync=?,iCalCalendarName=?,enableICalSync=?,projectType=?,calendarOrder=?,inVisible=?,iCalIdentifier=?,SDWIdentifier=?,lastUpdate=? WHERE primaryKey=?";
            if (sqlite3_prepare_v2(database, sql, -1, &dehydrate_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // Bind the query variables.
		
        NSDate *date=[[self.lastUpdate retain] autorelease];
        NSTimeInterval adjustTimeVal=gmtSeconds + [App_defaultTimeZone daylightSavingTimeOffsetForDate:date]-[App_defaultTimeZone daylightSavingTimeOffset];
        
        self.lastUpdate=[NSDate date];
        
		sqlite3_bind_text(dehydrate_statement, 1, [self.calendarName UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(dehydrate_statement, 2, self.colorNameId);
		sqlite3_bind_int(dehydrate_statement, 3, self.colorGroupId);
		sqlite3_bind_int(dehydrate_statement, 4, self.toodledoFolderKey);
		sqlite3_bind_int(dehydrate_statement, 5, self.isPrivate);
		sqlite3_bind_text(dehydrate_statement, 6, [self.gcalNameKey UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(dehydrate_statement, 7, self.builtIn);
		sqlite3_bind_int(dehydrate_statement, 8, self.enableGcalSync);
		sqlite3_bind_int(dehydrate_statement, 9, self.enableTDSync);
		//iCalCalendarName
		sqlite3_bind_text(dehydrate_statement, 10, [self.iCalCalendarName UTF8String], -1, SQLITE_TRANSIENT);
		//enableICalSync
		sqlite3_bind_int(dehydrate_statement, 11, self.enableICalSync);
		//projectType
		sqlite3_bind_int(dehydrate_statement, 12, self.projectType);
		//calendarOrder
		sqlite3_bind_int(dehydrate_statement, 13, self.calendarOrder);
		//inVisible
		sqlite3_bind_int(dehydrate_statement, 14, self.inVisible);
		//iCalIdentifier
        sqlite3_bind_text(dehydrate_statement, 15, [self.iCalIdentifier UTF8String], -1, SQLITE_TRANSIENT);
        
        //SDWIdentifier
        sqlite3_bind_int(dehydrate_statement, 16, self.SDWIdentifier);
        //lastUpdate
         sqlite3_bind_double(dehydrate_statement, 17, [[NSDate date] timeIntervalSince1970]);
        
        sqlite3_bind_int(dehydrate_statement, 18, primaryKey);

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

- (void)dehydrateWithDatabase:(sqlite3 *)db{
    if (!database && db) {
        database = db;
    }

	[self dehydrate];
}

#pragma mark Common methods
-(Calendar *)copy{
	Calendar *newCal=[[Calendar alloc] init];
	newCal.primaryKey=self.primaryKey;
	newCal.calendarName=self.calendarName;
	newCal.colorGroupId=self.colorGroupId;
	newCal.colorNameId=self.colorNameId;
	newCal.toodledoFolderKey=self.toodledoFolderKey;
	newCal.isPrivate=self.isPrivate;
	newCal.gcalNameKey=self.gcalNameKey;
	newCal.builtIn=self.builtIn;
	newCal.enableGcalSync=self.enableGcalSync;
	newCal.enableTDSync=self.enableTDSync;
	newCal.enableICalSync=self.enableICalSync;
	newCal.iCalCalendarName=self.iCalCalendarName;
	newCal.projectType=self.projectType;
	newCal.calendarOrder=self.calendarOrder;
	newCal.inVisible=self.inVisible;
    newCal.SDWIdentifier=self.SDWIdentifier;
    newCal.lastUpdate=self.lastUpdate;
    
	return newCal;
}

/*
+ (id)copyWithZone:(NSZone *)zone{
	return self;
}
*/

#pragma mark Properties

-(NSInteger)primaryKey{
	return primaryKey;
}

-(void)setPrimaryKey:(NSInteger)anum{
	primaryKey=anum;
}

-(NSString	*)calendarName{
	return calendarName;
}

-(void)setCalendarName:(NSString *)aString{
	if ((!calendarName && !aString) || (calendarName && aString && [calendarName isEqualToString:aString])) return;
	dirty=YES;
	[calendarName release];
	calendarName=[aString copy];
}

//gcalNameKey
-(NSString	*)gcalNameKey{
	return gcalNameKey;
}

-(void)setGcalNameKey:(NSString *)aString{
	if ((!gcalNameKey && !aString) || (gcalNameKey && aString && [gcalNameKey isEqualToString:aString])) return;
	dirty=YES;
	[gcalNameKey release];
	gcalNameKey=[aString copy];
}

-(NSInteger)colorNameId{
	return colorNameId;
}

-(void)setColorNameId:(NSInteger)anum{
	if(colorNameId==anum) return;
	
	dirty=YES;
	colorNameId=anum;
}

-(NSInteger)colorGroupId{
	return colorGroupId;
}

-(void)setColorGroupId:(NSInteger)anum{
	if(colorGroupId==anum) return;
	dirty=YES;
	colorGroupId=anum;
}

//toodledoFolderKey
-(NSInteger)toodledoFolderKey{
	return toodledoFolderKey;
}

-(void)setToodledoFolderKey:(NSInteger)anum{
	if(toodledoFolderKey==anum) return;
	dirty=YES;
	toodledoFolderKey=anum;
}

-(NSInteger)isPrivate{
	return isPrivate;
}

-(void)setIsPrivate:(NSInteger)anum{
	if(isPrivate==anum) return;
	dirty=YES;
	isPrivate=anum;
}

//builtIn
-(NSInteger)builtIn{
	return builtIn;
}

-(void)setBuiltIn:(NSInteger)anum{
	if(builtIn==anum) return;
	dirty=YES;
	builtIn=anum;
}

//enableGcalSync
-(NSInteger)enableGcalSync{
	return enableGcalSync;
}

-(void)setEnableGcalSync:(NSInteger)anum{
	if(enableGcalSync==anum) return;
	dirty=YES;
	enableGcalSync=anum;
}

//enableTDSync
-(NSInteger)enableTDSync{
	return enableTDSync;
}

-(void)setEnableTDSync:(NSInteger)anum{
	if(enableTDSync==anum) return;
	dirty=YES;
	enableTDSync=anum;
}

//iCalCalendarName
-(NSString	*)iCalCalendarName{
	return iCalCalendarName;
}

-(void)setICalCalendarName:(NSString *)aString{
	if ((!iCalCalendarName && !aString) || (iCalCalendarName && aString && [iCalCalendarName isEqualToString:aString])) return;
	dirty=YES;
	[iCalCalendarName release];
	iCalCalendarName=[aString copy];
}

//enableICalSync
-(NSInteger)enableICalSync{
	return enableICalSync;
}

-(void)setEnableICalSync:(NSInteger)anum{
	if(enableICalSync==anum) return;
	dirty=YES;
	enableICalSync=anum;
}

//projectType
-(NSInteger)projectType{
	return projectType;
}

-(void)setProjectType:(NSInteger)anum{
	if(projectType==anum) return;
	dirty=YES;
	projectType=anum;
}

//calendarOrder
-(NSInteger)calendarOrder{
	return calendarOrder;
}

-(void)setCalendarOrder:(NSInteger)anum{
	if(calendarOrder==anum) return;
	dirty=YES;
	calendarOrder=anum;
}

//inVisible
-(NSInteger)inVisible{
	return inVisible;
}

-(void)setInVisible:(NSInteger)anum{
	if(inVisible==anum) return;
	dirty=YES;
	inVisible=anum;
}

//iCalIdentifier
-(NSString	*)iCalIdentifier{
	return iCalIdentifier;
}

-(void)setICalIdentifier:(NSString *)aString{
	if ((!iCalIdentifier && !aString) || (iCalIdentifier && aString && [iCalIdentifier isEqualToString:aString])) return;
	dirty=YES;
	[iCalIdentifier release];
	iCalIdentifier=[aString copy];
}

//SDWIdentifier
-(NSInteger)SDWIdentifier{
	return SDWIdentifier;
}

-(void)setSDWIdentifier:(NSInteger)anum{
	if(SDWIdentifier==anum) return;
	dirty=YES;
	SDWIdentifier=anum;
}

//lastUpdate
- (NSDate *)lastUpdate{
	return lastUpdate;
}

- (void)setLastUpdate:(NSDate *)aDate{
	if ([lastUpdate isEqualToDate:aDate]) return;
	dirty=YES;
	
	[lastUpdate release];
	lastUpdate=[aDate copy];
}

@end
