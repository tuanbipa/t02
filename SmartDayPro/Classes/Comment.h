//
//  Comment.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 8/5/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//
#import <sqlite3.h>
#import <Foundation/Foundation.h>

@interface Comment : NSObject
{
    BOOL isExternalUpdate;
}

@property NSInteger primaryKey;
@property NSInteger itemKey;
@property NSInteger status;
@property NSInteger type;
@property BOOL isOwner;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *sdwId;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSDate *createTime;
@property (nonatomic, copy) NSDate *updateTime;

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)database;
- (void) insertIntoDB:(sqlite3 *)database;
- (void) updateIntoDB:(sqlite3 *)database;
- (void) updateSDWIDIntoDB:(sqlite3 *)database;
- (void) modifyUpdateTimeIntoDB:(sqlite3 *)database;
- (void)cleanFromDatabase:(sqlite3 *)database;
- (void)deleteFromDatabase:(sqlite3 *)database;

-(void) externalUpdate;
-(void) enableExternalUpdate;

@end
