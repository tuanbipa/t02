//
//  TaskLinkManager.h
//  SmartCal
//
//  Created by Left Coast Logic on 6/12/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Task;
@class LinkInfo2Sort;

@interface TaskLinkManager : NSObject
{
    
}

- (NSInteger) createLink:(NSInteger)sourceId destId:(NSInteger)destId;
- (void) deleteLink:(NSInteger)linkId cleanDB:(BOOL)cleanDB;
- (void) deleteLink:(Task *)task linkIndex:(NSInteger)linkIndex reloadLink:(BOOL)reloadLink;
- (void) deleteAllLinks4Task:(Task *)task;
- (void) modifyUpdateTime:(NSDate *)updateTime linkId:(NSInteger)linkId;
- (NSMutableArray *) getLinkIds4Task:(NSInteger)taskId;
- (NSMutableArray *) getLinks4Task:(NSInteger)taskId;
- (NSInteger) getLinkedId4Task:(NSInteger)taskId linkId:(NSInteger)linkId;
- (BOOL) checkLinkExist:(NSInteger)srcId destId:(NSInteger)destId;
- (void) deleteAllLinksContainingTask:(NSInteger)taskId;
- (LinkInfo2Sort *) getLinkInfo2Sort4Task:(NSInteger)taskId linkId:(NSInteger)linkId;

+ (NSDictionary *) getLinkDictBySDWID:(NSArray *)linkList;
+ (NSDictionary *) getLinkDictByKey:(NSArray *)linkList;
+(id)getInstance;
+(void)free;

@end
