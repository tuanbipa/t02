//
//  URLAsset.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 7/29/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLAsset : NSObject

@property NSInteger primaryKey;

@property (nonatomic, copy) NSString *urlValue;

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)database;

@end
