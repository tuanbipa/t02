//
//  Utilities.h
//
//  Created by Nang Le on 12/25/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPadCommon.h"
@class SPadTask;

@interface Utilities : NSObject {

}

+ (NSInteger)getSecond:(NSDate *)date;
+ (NSInteger)getMinute:(NSDate *)date;
+ (NSInteger)getHour:(NSDate *)date;
+ (NSInteger)getHourWithAMPM:(NSDate *)date;
+ (NSString *)getAMPM:(NSDate *)date;
+ (NSInteger)getWeekday:(NSDate *)date;
+ (NSInteger)getWeekdayOrdinal:(NSDate *)date;
+ (NSString *)getWeekDayName: (NSDate *)date;
+ (NSString *)getWeekDayFullName: (NSDate *)date;
+ (NSString *)getMonthName: (NSDate *)date;
+ (NSInteger)getDay:(NSDate *)date;
+ (NSInteger)getMonth:(NSDate *)date;
+ (NSInteger)getYear:(NSDate *)date;

+(NSDate *)dateFromDateString:(NSString *)dateStr;
+ (NSString *)getDayHourMinSecStringFromDate:(NSDate *) date;
+ (NSString *)getHourMinSecStringFromDate:(NSDate *) date;

+ (NSString *)getShortDateWithFullYearStringFromDate:(NSDate *) date;
+ (NSString *)getShortDateWithMonthDayYearFromDate:(NSDate *) date;

+ (NSString *)getStringFromDate:(NSDate *) date isIncludedTime:(BOOL)isTime;
+ (NSString *)getShortStringWithShortYearFromDate:(NSDate *) date;
+ (NSString *)getShortDateStringFromDate:(NSDate *) date;
+ (NSString *)getShortDateStringWithoutDay:(NSDate*)date;
+ (NSString *)getCurrentShortDateString;
+ (NSString *)getTimeStringAMPMFromDate:(NSDate *) date;
+ (NSString *)getTimeStringLowerAmPmFromDate:(NSDate *) date;
+ (NSString *)getShortDateTimeStringFromDate:(NSDate *) date;

+ (NSString *)getMonthYearNameString:(NSDate*)date;
+ (NSDate *)newDateFromDate:(NSDate*)date offset:(NSTimeInterval)offset;
+ (NSDate *)nextMonthOfDate:(NSDate*)date;
+ (NSDate *)previousMonthOfDate:(NSDate*)date;
+ (NSString *)getShortDateStringWithMonthDay:(NSDate*)date;
+ (NSDate*)dateByAddTimeInterval:(NSTimeInterval)offset fromDate:(NSDate*)date;
+ (NSString *)getMonthDayNameString:(NSDate*)date;
+ (NSString *)getStringNoWeekDayFromDate:(NSDate *) date isIncludedTime:(BOOL)isTime;
+ (NSInteger)getWeekNumberForDate:(NSDate *)date;
+ (NSString *)getDayWithName:(NSDate *) date;

+ (UIButton *)buttonWithTitle:	(NSString *)title
						target:(id)target
					  selector:(SEL)selector
						 frame:(CGRect)frame
						 image:(NSString *)image
				  imagePressed:(NSString *)imagePressed
				 darkTextColor:(BOOL)darkTextColor;
+ (UIButton *)getButtonWithType:(NSString *)title 
					 buttonType:(UIButtonType)buttonType
						  frame:(CGRect)frame
					 titleColor:(UIColor *)titleColor
						 target:(id)target
					   selector:(SEL)selector
			   normalStateImage:(NSString *)normalStateImage
			 selectedStateImage:(NSString*)selectedStateImage;

+(void)sortList:(NSMutableArray *)list byKey:(NSString *)byKey;
+ (void)sortList:(NSMutableArray *)list byKey:(NSString *)byKey isAscending:(BOOL)isAscending;

+ (NSInteger)getWeekNumberForDate:(NSDate *)date;
+ (void)animateGrowAtTouchPoint:(CGPoint)touchPoint forView:(UIImageView *)theView;
+ (void)animateShrinkView:(UIImageView *)theView toPosition:(CGPoint) thePosition;
//+ (NSString *)parseHourMinuteHistoryForTask:(SPadTask *)task;
+ (BOOL)check24HourFormat;
+(NSDate *)today;

+(NSDate *)dateWithNewDayOfMonth:(NSDate*)date dayOfMonth:(NSInteger)dayOfMonth;
+(NSDate *)dateWithNewMonthOffset:(NSDate*)date monthOffset:(NSInteger)monthOffset;
+(NSDate *)dateWithNewMonthOfYear:(NSDate*)date monthOfYear:(NSInteger)monthOfYear;
+(NSDate *)dateWithNewYearOffset:(NSDate*)date yearOffset:(NSInteger)yearOffset;
+(NSDate *)resetDate:(NSDate*)date year:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute sencond:(NSInteger)second;
+(NSDate *)resetTimeForDate:(NSDate*)date hour:(NSInteger)hour minute:(NSInteger)minute sencond:(NSInteger)second;

#pragma mark Common

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;
+ (NSString *)hexStringFromColor:(UIColor *)colorVal;
+ (NSComparisonResult)compareDate:(NSDate*) date1 withDate:(NSDate*) date2;
+ (NSComparisonResult)compareDateNoTime:(NSDate*) date1 withDate:(NSDate*) date2;

+(NSTimeInterval)getExpendingDurationOfTask:(SPadTask *)task;

+(NSMutableArray*)getFramesForSubText:(NSString*)subText inTextView:(UITextView*)textView;
+(CGPoint)getCursorPositionOfTextView:(UITextView*)textView;

+ (UIButton *)getButton:(NSString *)title 
				buttonType:(UIButtonType)buttonType
					 frame:(CGRect)frame
				titleColor:(UIColor *)titleColor
					target:(id)target
				  selector:(SEL)selector
		  normalStateImage:(NSString *)normalStateImage
		selectedStateImage:(NSString*)selectedStateImage;
+ (NSDate *)getDeadLine:(NSInteger)type fromDate:(NSDate *)fromDate;
+ (NSString *)getHowLongString:(NSInteger)value;


//+(BOOL)isTheSameIndexFromStartDate:(NSDate *)startDate endDate:(NSDate*)endDate forDate:(NSDate*)date;
//+(BOOL)isTheSameIndex:(NSDate *)date1 fromDate:(NSDate*)date2;
+(BOOL)isTheSameIndexOfTask:(SPadTask *)task1 andTask:(SPadTask*)task2;
+(NSDate *)resetTime4Date:(NSDate*)date hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second;

#pragma mark testing methods

+(NSInteger)ColorIntFromGroupId:(NSInteger)groupId colorId:(NSInteger)colorId;
+(BOOL)isEmailValid:(NSString *)email;

@end
