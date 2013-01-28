//
//  Sketch.h
//  SmartOrganizer
//
//  Created by Nang Le Van on 7/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Sketch : NSObject {
	
	NSInteger	primaryKey;
	NSString	*pointValues;
	NSInteger	noteId;
	NSInteger	lineSize;
	NSInteger	lineColor;
	
	BOOL hydrated;
    // Dirty tracks whether there are in-memory changes to data which have no been written to the database.
    BOOL dirty;
    NSData *data;
}

@property(nonatomic, assign)	NSInteger	primaryKey;
@property(nonatomic, copy)		NSString	*pointValues;
@property(nonatomic, assign)	NSInteger	noteId;
@property(nonatomic, assign)	NSInteger	lineSize;
@property(nonatomic, assign)	NSInteger	lineColor;


- (void)deleteFromDatabase;
- (void)insertIntoDatabase:(sqlite3 *)db;
- (void)dehydrate;
+ (void)finalizeStatements;
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;

@end
