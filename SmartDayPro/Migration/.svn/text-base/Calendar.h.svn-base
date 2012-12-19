//
//  Common.h
//  SmartOrganizer
//
//  Created by Nang Le Van on 6/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Calendar : NSObject {
	//sqlite3 *database;
	
	NSInteger		primaryKey;
	NSString		*calendarName;
	NSInteger		colorGroupId;
	NSInteger		colorNameId;
	NSInteger		isPrivate;
	NSInteger		toodledoFolderKey;
	NSString		*gcalNameKey;
	NSInteger		builtIn;//0:SO; 1:GCal; 2TD;
	NSInteger		enableGcalSync;
	NSInteger		enableTDSync;
	NSInteger		enableICalSync;
	NSString		*iCalCalendarName;
	
	NSInteger		projectType;//0: normal project; 1: List
	NSInteger		calendarOrder;
	
    NSString        *iCalIdentifier;
    
    NSInteger       SDWIdentifier;
    
	//local uses
	BOOL			isExpanding;
	NSInteger		inVisible;
	BOOL            willExport;
    
    NSDate          *lastUpdate;
    
    NSInteger       migrateID;
    
	BOOL hydrated;
    // Dirty tracks whether there are in-memory changes to data which have no been written to the database.
    BOOL dirty;
    NSData *data;
}

@property(assign,nonatomic) NSInteger		primaryKey;
@property(copy,nonatomic)	NSString		*calendarName;
@property(assign,nonatomic) NSInteger		colorGroupId;
@property(assign,nonatomic) NSInteger		isPrivate;
@property(assign,nonatomic) NSInteger		colorNameId;
@property(assign,nonatomic) NSInteger		toodledoFolderKey;
@property(copy,nonatomic)	NSString		*gcalNameKey;
@property(assign,nonatomic) NSInteger		builtIn;
@property(assign,nonatomic) NSInteger		enableGcalSync;
@property(assign,nonatomic) NSInteger		enableTDSync;
@property(copy,nonatomic)	NSString		*iCalCalendarName;
@property(assign,nonatomic) NSInteger		enableICalSync;
@property(assign,nonatomic) NSInteger		projectType;//0: normal project; 1: List
@property(assign,nonatomic) NSInteger		calendarOrder;
@property(assign,nonatomic) BOOL			isExpanding;
@property(assign,nonatomic) NSInteger		inVisible;
@property(assign,nonatomic) BOOL            willExport;
@property(copy,nonatomic)	NSString        *iCalIdentifier;
@property(assign,nonatomic) NSInteger       SDWIdentifier;
@property(copy,nonatomic)	NSDate          *lastUpdate;
@property(assign,nonatomic) NSInteger       migrateID;

- (void)deleteFromDatabase;
- (void)insertIntoDatabase:(sqlite3 *)db;
- (void)dehydrate;
+ (void)finalizeStatements;
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;
- (void)dehydrateWithDatabase:(sqlite3 *)db;

@end
