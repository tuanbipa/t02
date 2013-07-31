//
//  URLAsset.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 7/29/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLAsset : NSObject
{
    BOOL isExternalUpdate;
}

@property NSInteger primaryKey;
@property NSInteger status;

@property (nonatomic, copy) NSString *urlValue;
@property (nonatomic, copy) NSString *sdwId;

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
