//
//  List.h
//  SmartOrganizer
//
//  Created by Nang Le Van on 6/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface List : NSObject {
	
	NSInteger	primaryKey;
	NSString	*listName;
	
	BOOL hydrated;
    // Dirty tracks whether there are in-memory changes to data which have no been written to the database.
    BOOL dirty;
    NSData *data;
}

@property(nonatomic, assign)	NSInteger	primaryKey;
@property(nonatomic, copy)		NSString	*listName;

- (void)deleteFromDatabase;
- (void)insertIntoDatabase:(sqlite3 *)db;
- (void)dehydrate;
+ (void)finalizeStatements;
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;

@end
