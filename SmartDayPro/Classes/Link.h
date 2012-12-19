//
//  Link.h
//  SmartCal
//
//  Created by Left Coast Logic on 7/12/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Link : NSObject
{
    BOOL isExternalUpdate;
}

@property NSInteger primaryKey;
@property NSInteger srcId;
@property NSInteger destId;
@property NSInteger status;

@property (nonatomic, copy) NSString *sdwId;
@property (nonatomic, copy) NSDate *updateTime;

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)database;
- (void) insertIntoDB:(sqlite3 *)database;
- (void) updateIntoDB:(sqlite3 *)database;
- (void) updateSDWIDIntoDB:(sqlite3 *)database;
- (void) modifyUpdateTimeIntoDB:(sqlite3 *)database;
- (void)cleanFromDatabase:(sqlite3 *)database;
- (void)deleteFromDatabase:(sqlite3 *)database;

@end
