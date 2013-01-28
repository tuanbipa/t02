//
//  Notes.h
//  SmartOrganizer
//
//  Created by Nang Le Van on 7/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Note : NSObject {
	
	NSInteger	primaryKey;
	NSString	*noteContent;
	NSDate		*noteDate;	
	NSInteger	fontSize;
	NSInteger	fontColor;
	
	NSInteger	isInitial;
	
    //for migration
    NSInteger   migrateID;
    
	BOOL hydrated;
    // Dirty tracks whether there are in-memory changes to data which have no been written to the database.
    BOOL dirty;
    NSData *data;
}

@property(nonatomic, assign)	NSInteger	primaryKey;
@property(nonatomic, copy)		NSString	*noteContent;
@property(nonatomic, copy)		NSDate		*noteDate;
@property(nonatomic, assign)	NSInteger	fontSize;
@property(nonatomic, assign)	NSInteger	fontColor;
@property(nonatomic, assign)	NSInteger	isInitial;
@property(nonatomic, assign)	NSInteger   migrateID;

- (void)deleteFromDatabase;
- (void)insertIntoDatabase:(sqlite3 *)db;
- (void)dehydrate;
+ (void)finalizeStatements;
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;

@end
