//
//  CommentManager.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 8/5/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "CommentManager.h"

#import "Comment.h"

#import "DBManager.h"

CommentManager *_cmdManagerSingleton = nil;

@implementation CommentManager
@synthesize commentNotifDict;

- (id) init
{
    if (self = [super init])
    {
        self.commentNotifDict = [NSMutableDictionary dictionaryWithCapacity:20];
    }
    
    return self;
}

- (void) dealloc
{
    self.commentNotifDict = nil;
    
    [super dealloc];
}

- (void) notify:(NSMutableArray *)list
{
    DBManager *dbm = [DBManager getInstance];
    
    NSMutableDictionary *taskCommentDict = [NSMutableDictionary dictionaryWithCapacity:list.count];
    
    for (Comment *comment in list)
    {
        NSString *key = [NSString stringWithFormat:@"%d#%d", comment.type, comment.itemKey];
        
        NSNumber *count = [taskCommentDict objectForKey:key];
        
        if (count == nil)
        {
            count = [NSNumber numberWithInt:1];
        }
        else
        {
            count = [NSNumber numberWithInt:([count intValue] + 1)];
        }
        
        [taskCommentDict setObject:count forKey:key];
    }
    
    NSArray *keys = [taskCommentDict.keyEnumerator allObjects];
    
    NSString *info = @"";
    
    for (NSString *key in keys)
    {
        NSArray *parts = [key componentsSeparatedByString:@"#"];
        
        NSInteger type = [parts[0] intValue];
        NSInteger itemId = [parts[1] intValue];
        
        NSNumber *count = [taskCommentDict objectForKey:key];
        
        NSString *name = (type == COMMENT_TYPE_ITEM?[dbm getItemNameByKey:itemId]:[dbm getProjectNameByKey:itemId]);
        
        NSString *typeName = (type == COMMENT_TYPE_ITEM?@"item":@"project");
        
        info = [info stringByAppendingFormat:@"%d new comment(s) on %@ '%@'\n", [count intValue], typeName, name];
    }
    
    NSNumber *key = [NSNumber numberWithInt:(self.commentNotifDict.count + 1)];
    
	UILocalNotification *notif = [[UILocalNotification alloc] init];
	notif.fireDate = nil;
	notif.alertBody = info;
	notif.soundName = UILocalNotificationDefaultSoundName;
    notif.userInfo = [NSDictionary dictionaryWithObject:key forKey:@"CommentListKey"];
	
    [[UIApplication sharedApplication] scheduleLocalNotification:notif];
	
	//[self.commentNotifDict setObject:list forKey:key];
	
	[notif release];
    
}

- (void) show:(UILocalNotification *)notif
{
    //NSNumber *key = [notif.userInfo objectForKey:@"CommentListKey"];
    
    [[UIApplication sharedApplication] cancelLocalNotification:notif];
    
    //[self.commentNotifDict removeObjectForKey:key];
}

#pragma mark Public

+ (NSDictionary *) getCommentDictBySDWID:(NSArray *)list
{
	NSMutableArray *mappingList = [NSMutableArray arrayWithCapacity:list.count];
	
	for (Comment *comment in list)
	{
		[mappingList addObject:comment.sdwId];
	}
	
	return [NSDictionary dictionaryWithObjects:list forKeys:mappingList];
}

+ (NSDictionary *) getCommentDictByKey:(NSArray *)list
{
	NSMutableArray *mappingList = [NSMutableArray arrayWithCapacity:list.count];
	
	for (Comment *comment in list)
	{
		[mappingList addObject:[NSNumber numberWithInt:comment.primaryKey]];
	}
	
	return [NSDictionary dictionaryWithObjects:list forKeys:mappingList];
}

+(id)getInstance
{
	if (_cmdManagerSingleton == nil)
	{
		_cmdManagerSingleton = [[CommentManager alloc] init];
	}
	
	return _cmdManagerSingleton;
}

+(void)free
{
	if (_cmdManagerSingleton != nil)
	{
		[_cmdManagerSingleton release];
	}
}

@end
