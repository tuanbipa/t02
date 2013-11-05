//
//  Location.h
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 10/25/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sqlite3.h>

@interface Location : NSObject {
    NSInteger primaryKey;
    NSString *name;
    NSString *address;
    CGFloat latitude;
    CGFloat longitude;
    NSInteger inside;
}

@property NSInteger primaryKey;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property CGFloat latitude;
@property CGFloat longitude;
@property NSInteger inside;

#pragma mark Methods
+ (void)finalizeStatements;
- (id) initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)database;
- (void) insetIntoDB: (sqlite3 *)database;
- (void) updateIntoDB:(sqlite3 *)database;
- (void) deleteFromDatabase:(sqlite3 *)database;
- (void)refreshLatituAndLongitude: (Location*) loc;
@end
