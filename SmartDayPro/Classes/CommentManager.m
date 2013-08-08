//
//  CommentManager.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 8/5/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "CommentManager.h"

#import "Comment.h"

CommentManager *_cmdManagerSingleton = nil;

@implementation CommentManager

- (id) init
{
    if (self = [super init])
    {
        
    }
    
    return self;
}

- (void) dealloc
{
    [super dealloc];
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
