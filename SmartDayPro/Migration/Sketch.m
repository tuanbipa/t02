//
//  Sketch.m
//  SmartOrganizer
//
//  Created by Nang Le Van on 7/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Sketch.h"
#import <sqlite3.h>
#import "MigrationData.h"

extern sqlite3 *database;
extern BOOL     isLockingDB;

static sqlite3_stmt *insert_statement = nil;
static sqlite3_stmt *init_statement = nil;
static sqlite3_stmt *delete_statement = nil;
static sqlite3_stmt *hydrate_statement = nil;
static sqlite3_stmt *dehydrate_statement = nil;

@implementation Sketch
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
		self.pointValues=@"";
	}
	return self;
}


// Creates the object with primary key and title is brought into memory.
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db {
    if (self = [super init]) {
        while (isLockingDB) {
            //usleep(20);
        [NSThread sleepForTimeInterval:0.01];
        }
        isLockingDB=YES;

        primaryKey = pk;
        // Compile the query for retrieving book data. See insertNewBookIntoDatabase: for more detail.
        if (init_statement == nil) {
            // Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
            // This is a great way to optimize because frequently used queries can be compiled once, then with each
            // use new variable values can be bound to placeholders.
            const char *sql = "SELECT pointVlues,noteId,lineSize,lineColor FROM Sketches WHERE primaryKey=?";
            if (sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // For this query, we bind the primary key to the first (and only) placeholder in the statement.
        // Note that the parameters are numbered from 1, not from 0.
        sqlite3_bind_int(init_statement, 1, primaryKey);
		
        if (sqlite3_step(init_statement) == SQLITE_ROW) {
			
			char *pointStr=(char *)sqlite3_column_text(init_statement, 0);
			self.pointValues=(pointStr)?[NSString stringWithUTF8String:pointStr] : @"";
			self.noteId=sqlite3_column_int(init_statement, 1);
			self.lineSize=sqlite3_column_int(init_statement, 2);
			self.lineSize=sqlite3_column_int(init_statement, 3);
        } 
		
        // Reset the statement for future reuse.
        sqlite3_reset(init_statement);
        dirty = NO;
        isLockingDB=NO;
    }
    return self;
}

-(void)dealloc{
	[pointValues release];
	[super dealloc];
}

- (void)insertIntoDatabase:(sqlite3 *)db {
    while (isLockingDB) {
        //usleep(20);
        [NSThread sleepForTimeInterval:0.01];
    }
    isLockingDB=YES;

    // This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed by any Book object.
    if (insert_statement == nil) {
        static char *sql = "INSERT INTO Sketches (pointValues) VALUES(?)";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    sqlite3_bind_text(insert_statement, 1, [self.pointValues UTF8String], -1, SQLITE_TRANSIENT);
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
        const char *sql = "DELETE FROM Sketches WHERE primaryKey=?";
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
        // Write any changes to the database.
        // First, if needed, compile the dehydrate query.
        if (dehydrate_statement == nil) {
            const char *sql = "UPDATE Sketches SET noteContent=?,noteDate=?,fontSize=?,fontColor=? WHERE primaryKey=?";
            if (sqlite3_prepare_v2(database, sql, -1, &dehydrate_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // Bind the query variables.
		
		sqlite3_bind_text(dehydrate_statement, 1, [self.pointValues UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(dehydrate_statement, 2, self.noteId);
		sqlite3_bind_int(dehydrate_statement, 3, self.lineSize);
		sqlite3_bind_int(dehydrate_statement, 4, self.lineColor);
        sqlite3_bind_int(dehydrate_statement, 5, primaryKey);
		
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

#pragma mark Common methods
-(Sketch *)copy{
	Sketch *note=[[Sketch alloc] init];
	note.primaryKey=self.primaryKey;
	note.pointValues=self.pointValues;
	note.noteId=self.noteId;
	note.lineSize=self.lineSize;
	note.lineColor=self.lineColor;
	
	return note;
}

#pragma mark Properties

-(NSInteger)primaryKey{
	return primaryKey;
}

-(void)setPrimaryKey:(NSInteger)anum{
	primaryKey=anum;
}

-(NSString	*)pointValues{
	return pointValues;
}

-(void)setPointValues:(NSString *)aString{
	if ((!pointValues && !aString) || (pointValues && aString && [pointValues isEqualToString:aString])) return;
	dirty=YES;
	[pointValues release];
	pointValues=[aString copy];
}

-(NSInteger)noteId{
	return noteId;
}

-(void)setNoteId:(NSInteger)anum{
	if (noteId==anum) return;
	dirty=YES;
	
	noteId=anum;
}

-(NSInteger)lineSize{
	return lineSize;
}

-(void)setLineSize:(NSInteger)anum{
	if (lineSize==anum) return;
	dirty=YES;
	
	lineSize=anum;
}

-(NSInteger)lineColor{
	return lineColor;
}

-(void)setLineColor:(NSInteger)anum{
	if (lineColor==anum) return;
	dirty=YES;
	
	lineColor=anum;
}

@end
