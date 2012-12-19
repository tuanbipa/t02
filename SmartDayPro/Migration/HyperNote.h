//
//  HyperNote.h
//  SmartOrganizer
//
//  Created by Nang Le Van on 7/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface HyperNote : NSObject {
	//sqlite3		*database;
	
	NSInteger	primaryKey;
	NSString	*keyWord;
	NSInteger	noteId;
	NSInteger	appearPositionInNote;
	NSInteger	highlightColor;
	float		startPosition;
	float		endPosition;
	
	BOOL hydrated;
    // Dirty tracks whether there are in-memory changes to data which have no been written to the database.
    BOOL dirty;
    NSData *data;
}

@property(nonatomic, assign)	NSInteger	primaryKey;
@property(nonatomic, copy)		NSString	*keyWord;
@property(nonatomic, assign)	NSInteger	noteId;
@property(nonatomic, assign)	NSInteger	appearPositionInNote;
@property(nonatomic, assign)	NSInteger	highlightColor;
@property(nonatomic, assign)	float		startPosition;
@property(nonatomic, assign)	float		endPosition;


- (void)deleteFromDatabase;
- (void)insertIntoDatabase:(sqlite3 *)db;
- (void)dehydrate;
+ (void)finalizeStatements;
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;
@end
