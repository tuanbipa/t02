//
//  RepeatData.h
//  SmartCal
//
//  Created by Trung Nguyen on 5/18/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RepeatData : NSObject {
	NSInteger type; // Daily/Weekly/Monthly/Yearly
	NSInteger interval; //how many days/weeks/months/years
	NSInteger weekOption; //on which day_of_week for Weekly type
	NSInteger monthOption;//by day_of_week/day_of_month for Monthly type
	
	NSInteger count; //repeat times
	NSDate *until; //nil is forever
	
	//RE Exception information 
	NSDate *originalStartTime; //RE exception original date
	NSMutableArray *deletedExceptionDates; //RE deleted exception dates

	//RT information
	NSInteger repeatFrom; //0:from Due date, 1:from Completion date
	NSInteger weekDay; //to support TD sync for advanced Monthly RT
	NSInteger weekOrdinal; //to support TD sync for advanced Monthly RT
}

@property NSInteger type;
@property NSInteger interval;
@property NSInteger weekOption;
@property NSInteger monthOption;
@property NSInteger count;

@property (nonatomic, copy)	NSDate *until; //nil is forever
@property (nonatomic, copy)	NSDate *originalStartTime;
@property (nonatomic, retain) NSMutableArray *deletedExceptionDates; 

@property NSInteger repeatFrom;
@property NSInteger weekDay;
@property NSInteger weekOrdinal;

+ (RepeatData *) parseRepeatDataForDeletedException:(NSString *)data;
+ (RepeatData *) parseRepeatDataForException:(NSString *)data;
+ (RepeatData *) parseRepeatData:(NSString *)data;
+ (NSString *) stringOfRepeatDataForDeletedException:(RepeatData *)data;
+ (NSString *) stringOfRepeatDataForException:(RepeatData *)data;
+ (NSString *) stringOfRepeatData:(RepeatData *)data;
+ (BOOL) isEqual:(RepeatData *)src toAnother:(RepeatData *)dest;

- (void) calculateUntilByCount:(NSDate *) fromDate;
- (void) reset;
@end
