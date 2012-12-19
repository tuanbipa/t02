//
//  TDTask.h
//  SmartCal
//
//  Created by MacBook Pro on 10/4/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RepeatData;

@interface TDTask : NSObject {
	NSString *id;
	NSString *folderId;
	NSString *title;
	NSString *tag;
	NSString *note;
	NSDate *startTime;
	NSDate *dueTime;
	NSDate *modifiedTime;
	NSDate *completedTime;
	NSInteger priority;
	NSInteger length;
	NSInteger repeat;
	NSInteger repeatFrom;
	NSString *rep_advanced;
	NSInteger star;
	NSString *meta;
}

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *folderId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, copy) NSString *note;

@property (nonatomic, copy) NSDate *startTime;
@property (nonatomic, copy) NSDate *dueTime;
@property (nonatomic, copy) NSDate *modifiedTime;
@property (nonatomic, copy) NSDate *completedTime;

@property NSInteger priority;
@property NSInteger length;

@property NSInteger repeat;
@property NSInteger repeatFrom;
@property (nonatomic, copy) NSString *rep_advanced;

@property NSInteger star;
@property (nonatomic, copy) NSString *meta;

- (RepeatData *) getRepeatData;
- (void) print;

@end