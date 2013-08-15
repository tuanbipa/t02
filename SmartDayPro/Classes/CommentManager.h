//
//  CommentManager.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 8/5/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentManager : NSObject

@property (nonatomic, retain) 	NSMutableDictionary *commentNotifDict;

- (void) notify:(NSMutableArray *)list;
- (void) show:(UILocalNotification *)notif;

+ (NSDictionary *) getCommentDictBySDWID:(NSArray *)list;
+ (NSDictionary *) getCommentDictByKey:(NSArray *)list;

+(id)getInstance;
+(void)free;

@end
