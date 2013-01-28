//
//  TDClient.h
//  SmartCal
//
//  Created by MacBook Pro on 9/30/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
	FETCH_TOKEN,
	FETCH_USER_ID,
	FETCH_ALL_FOLDER,
	FETCH_ADD_FOLDER,
	FETCH_EDIT_FOLDER,
	FETCH_DELETE_FOLDER,
	FETCH_TASK,
	FETCH_ACCOUNT,
	FETCH_ADD_TASK,
	FETCH_EDIT_TASK,
	FETCH_ALL_DELETED_TASK,
	FETCH_DELETE_TASK
} FetchCommand;

@class TDFetchParam;

@interface TDClient : NSObject {
	id _delegate;
	SEL _finishedSEL;
	SEL _failedSEL;
	
	NSMutableData *xmlData;
	
	NSObject *userInfo;
}

@property (nonatomic, retain) NSMutableData *xmlData;
@property (nonatomic, retain) NSObject *userInfo;

+(id)getInstance;
+(void)free;

- (void)fetchData:(TDFetchParam *)param delegate:(id)delegate didFinishSelector:(SEL)finishedSEL didFailSelector:(SEL)failedSEL userInfo:(NSObject *)userInfo;

@end
