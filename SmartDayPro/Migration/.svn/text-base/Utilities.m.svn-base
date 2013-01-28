//
//  Utilities.m
//  SmartOrganizer
//
//  Created by Nang Le on 12/25/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Utilities.h"
#import "SPadCommon.h"
#import "SmartCalAppDelegate.h"
#import "Calendar.h"
#import "MigrationData.h"
#import "Setting.h"
#import "SPadTask.h"

extern NSInteger categoriesColor[];

extern MigrationData *coreData;
extern NSString *amText;
extern NSString *pmText;
extern NSString *lowerAmText;
extern NSString *lowerPmText;

extern NSString *sunText;
extern NSString *monText;
extern NSString *tueText;
extern NSString *wedText;
extern NSString *thuText;
extern NSString *friText;
extern NSString *satText;

extern NSString *janText;
extern NSString *febText;
extern NSString *marText;
extern NSString *aprText;
extern NSString *mayText;
extern NSString *junText;
extern NSString *julText;
extern NSString *augText;
extern NSString *sepText;
extern NSString *octText;
extern NSString *novText;
extern NSString *decText;

extern NSString *WeekdayList[];
extern NSString *twelveHoursList[];

extern NSString *ofEventText;
extern NSString *daysText;
extern NSString *hoursText;
extern NSString *minutesText;
extern NSString *weeksText;
extern NSString *alertByText;
extern NSString *SMSText;
extern NSString *smsButtonText;
extern NSString *popupText;
extern NSString *emailText;
extern NSString *specifiedTimeText;

extern BOOL		is24HrFormat;
extern NSString *sundayText;
extern NSString *mondayText;
extern NSString *tuedayText;
extern NSString *wednesdayText;
extern NSString *thusdayText;
extern NSString *fridayText;
extern NSString *saturdayText;

@implementation Utilities

+ (NSInteger)getSecond:(NSDate *)date{
	if (date==nil) return -1;
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	NSDateComponents *dayComponents =[gregorian components:NSSecondCalendarUnit fromDate:date];
	NSInteger second = [dayComponents second];
	return second; 
}

+ (NSInteger)getMinute:(NSDate *)date{
	if (date==nil) return -1;
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	NSDateComponents *dayComponents =[gregorian components:NSMinuteCalendarUnit fromDate:date];
	NSInteger minute = [dayComponents minute];
	return minute; 
}

+ (NSInteger)getHour:(NSDate *)date{
	if (date==nil) return -1;
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	NSDateComponents *dayComponents =[gregorian components:NSHourCalendarUnit fromDate:date];
	NSInteger hour = [dayComponents hour];
	return hour; 
}

+ (NSInteger)getHourWithAMPM:(NSDate *)date{
	if (date==nil) return -1;
	NSInteger hour=[self getHour:date];
	if (hour>12){
		hour=hour-12;
	}else {
		if (hour==0){
			hour=12;
		}
	}
	return hour;	
}

+ (NSString *)getAMPM:(NSDate *)date{
	NSString *ap=nil;
	if([self getHour:date]>=12){
		ap= pmText;
	}else {
		ap=amText;
	}
	
	return ap;
}

+ (NSInteger)getWeekday:(NSDate *)date{
   	if (date==nil) return -1;
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	NSDateComponents *dayComponents =[gregorian components:NSWeekdayCalendarUnit fromDate:date];
	NSInteger wd = [dayComponents weekday];
	return wd;
}

+ (NSInteger)getWeekdayOrdinal:(NSDate *)date{
   	if (date==nil) return -1;
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	NSDateComponents *dayComponents =[gregorian components:NSWeekdayOrdinalCalendarUnit fromDate:date];
	NSInteger wdo = [dayComponents weekdayOrdinal];
	return wdo;
}

+ (NSString *)getWeekDayName: (NSDate *)date{
   	if (date==nil) return [NSString stringWithString: @""];
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	NSDateComponents *dayComponents =[gregorian components:NSWeekdayCalendarUnit fromDate:date];
	NSInteger wd = [dayComponents weekday];
	NSString *WeekDayName; 
	if(wd== 1){
		WeekDayName=[NSString stringWithString: sunText];
	}else if(wd==2){
		WeekDayName=[NSString stringWithString: monText];
	}else if(wd==3){
		WeekDayName=[NSString stringWithString: tueText];
	}else if(wd==4){
		WeekDayName=[NSString stringWithString: wedText];
	}else if(wd==5){
		WeekDayName=[NSString stringWithString: thuText];
	}else if(wd==6){
		WeekDayName=[NSString stringWithString: friText];
	}else if(wd==7){
		WeekDayName=[NSString stringWithString: satText];
	}
	
	return WeekDayName;  	
}

+ (NSString *)getWeekDayFullName: (NSDate *)date{
   	if (date==nil) return [NSString stringWithString: @""];
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	NSDateComponents *dayComponents =[gregorian components:NSWeekdayCalendarUnit fromDate:date];
	NSInteger wd = [dayComponents weekday];
	NSString *WeekDayName; 
	if(wd== 1){
		WeekDayName=[NSString stringWithString: sundayText];
	}else if(wd==2){
		WeekDayName=[NSString stringWithString: mondayText];
	}else if(wd==3){
		WeekDayName=[NSString stringWithString: tuedayText];
	}else if(wd==4){
		WeekDayName=[NSString stringWithString: wednesdayText];
	}else if(wd==5){
		WeekDayName=[NSString stringWithString: thusdayText];
	}else if(wd==6){
		WeekDayName=[NSString stringWithString: fridayText];
	}else if(wd==7){
		WeekDayName=[NSString stringWithString: saturdayText];
	}
	
	return WeekDayName;  	
}

//Jan,Feb,...
+ (NSString *)getMonthName: (NSDate *)date{
   	if (date==nil) return [NSString stringWithString: @""];
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	NSDateComponents *dayComponents =[gregorian components:NSMonthCalendarUnit fromDate:date];
	NSInteger month = [dayComponents month];
	NSString *monthName; 
	switch (month) {
		case 1:
			monthName=[NSString stringWithString:janText];
			break;
		case 2:
			monthName=[NSString stringWithString:febText];
			break;
		case 3:
			monthName=[NSString stringWithString:marText];
			break;
		case 4:
			monthName=[NSString stringWithString:aprText];
			break;
		case 5:
			monthName=[NSString stringWithString:mayText];
			break;
		case 6:
			monthName=[NSString stringWithString:junText];
			break;
		case 7:
			monthName=[NSString stringWithString:julText];
			break;
		case 8:
			monthName=[NSString stringWithString:augText];
			break;
		case 9:
			monthName=[NSString stringWithString:sepText];
			break;
		case 10:
			monthName=[NSString stringWithString:octText];
			break;
		case 11:
			monthName=[NSString stringWithString:novText];
			break;
		case 12:
			monthName=[NSString stringWithString:decText];
			break;
			
	}
	//[gregorian release];
	return monthName;  	
}

+ (NSInteger)getDay:(NSDate *)date{
	if (date==nil) return -1;
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	NSDateComponents *dayComponents =[gregorian components:NSDayCalendarUnit fromDate:date];
	NSInteger day = [dayComponents day];
	//[gregorian release];
	return day; 
}

+ (NSInteger)getMonth:(NSDate *)date{
	if (date==nil) return -1;
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	NSDateComponents *dayComponents =[gregorian components:NSMonthCalendarUnit fromDate:date];
	NSInteger month = [dayComponents month];
	//[gregorian release];
	return month; 
}

+ (NSInteger)getYear:(NSDate *)date{
	if (date==nil) return -1;
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	NSDateComponents *dayComponents =[gregorian components:NSYearCalendarUnit fromDate:date];
	NSInteger year = [dayComponents year];
	//[gregorian release];
	return year; 
}

+ (NSString *)getDayHourMinSecStringFromDate:(NSDate *) date{
    /*n: 2.2
	NSString *ret=@"";
	if(date !=nil){
		ret= [NSString stringWithFormat:@"%02d %02d:%02d:%02d",
			  [self  getDay:date],
			  [self  getHour:date],
			  [self  getMinute:date],
			  [self  getSecond:date]];	
	}
	return ret;	
     */
    NSString *ret=@"";
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags=NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
	NSDateComponents *comps =[gregorian components:unitFlags fromDate:date];
	
	if(date !=nil){
		ret= [NSString stringWithFormat:@"%02d %02d:%02d:%02d",
			  [comps day],
			  [comps hour],
			  [comps minute],
			  [comps second]];	
	}
	
	[gregorian release];
	return ret;	
}

+ (NSString *)getHourMinSecStringFromDate:(NSDate *) date{
    /*n: 2.2
	NSString *ret=@"";
	if(date !=nil){
		ret= [NSString stringWithFormat:@"%02d:%02d:%02d",
			  [self  getHour:date],
			  [self  getMinute:date],
			  [self  getSecond:date]];	
	}
	return ret;	
     */
    
    NSString *ret=@"";
    
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags=NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
	NSDateComponents *comps =[gregorian components:unitFlags fromDate:date];
	
	if(date !=nil){
		ret= [NSString stringWithFormat:@"%02d:%02d:%02d",
			  [comps hour],
			  [comps minute],
			  [comps second]];	
	}
    [gregorian release];
	return ret;	
}

//get a date string from a given date. Ex: 2010-05-09
+ (NSString *)getShortDateWithFullYearStringFromDate:(NSDate *) date {
    /*n: 2.2
	NSString *ret=@"";
	if(date !=nil){
		ret= [NSString stringWithFormat:@"%04d-%02d-%02d",
			  [self getYear:date],
			  [self  getMonth:date],
			  [self  getDay:date]];	
	}
	return ret;	
     */
    NSString *ret=@"";
	if(date !=nil){
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		unsigned unitFlags=NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit;
		NSDateComponents *comps =[gregorian components:unitFlags fromDate:date];
		
		ret= [NSString stringWithFormat:@"%04d-%02d-%02d",
			  [comps year],
			  [comps  month],
			  [comps  day]];
		
		[gregorian release];
	}
	return ret;
}

//get a date string from a given date. Ex: 2010-05-09
+ (NSString *)getShortDateWithMonthDayYearFromDate:(NSDate *) date {
	NSString *ret=@"";
	if(date !=nil){
        /*n: 2.2
		ret= [NSString stringWithFormat:@"%02d/%02d/%04d",
			  [self  getMonth:date],
			  [self  getDay:date]],
				[self getYear:date];
         */
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		unsigned unitFlags=NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit;
		NSDateComponents *comps =[gregorian components:unitFlags fromDate:date];
		
		ret= [NSString stringWithFormat:@"%02d/%02d/%04d",
			  [comps month],
			  [comps  day],
			  [comps  year]];
		
		[gregorian release];
	}
	return ret;	
}

//get full date string from a given date. Ex: "Fri Jul 7, 2008" or "Fri Jul 7, 2008 10:00AM"
+ (NSString *)getStringFromDate:(NSDate *) date isIncludedTime:(BOOL)isTime{
    
    if (!date) {
		return @"";
	}
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags=NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit;
	NSDateComponents *comps =[gregorian components:unitFlags fromDate:date];
	
	NSString *wdayname=WeekdayList[[comps weekday]-1];
	NSString *monthname=[self getMonthName:date];
	NSString *ret=nil;
	
	if(isTime){
		if(is24HrFormat){
			ret= [wdayname  stringByAppendingFormat:@" %@ %02d, %2d %02d:%02d",
				  monthname,
				  [comps day],
				  [comps year],
				  [comps hour],
				  [comps minute]];
		}else {
			ret= [wdayname stringByAppendingFormat:@" %@ %02d, %2d %02d:%02d%@",
				  monthname,
				  [comps day],
				  [comps year],
				  [self getHourWithAMPM:date],
				  [comps minute],
				  [self getAMPM:date]];
		}
		
	}else{
		ret= [wdayname stringByAppendingFormat:@" %@ %02d, %02d",
			  monthname,
			  [comps day],
			  [comps year]];
		
	}
	
	[gregorian release];
	
	return ret;	
}

//get full date string from a given date. Ex: "Jul 7, 2008" or "Fri Jul 7, 2008 10:00AM"
+ (NSString *)getStringNoWeekDayFromDate:(NSDate *) date isIncludedTime:(BOOL)isTime{
    /*n: 2.2
	NSString *wdayname=@"";//[self getWeekDayName:date];
	NSString *monthname=[self getMonthName:date];
	NSString *ap=[self getAMPM:date];
	NSString *ret=nil;
	
	if(date !=nil){
		if(isTime){
			if(is24HrFormat){
				ret= [wdayname  stringByAppendingFormat:@" %@ %02d, %2d %02d:%02d",
					  monthname,
					  [self getDay:date],
					  [self getYear:date],
					  [self getHour:date],
					  [self getMinute:date]];	
			}else {
				ret= [wdayname  stringByAppendingFormat:@" %@ %02d, %2d %02d:%02d%@",
					  monthname,
					  [self getDay:date],
					  [self getYear:date],
					  [self getHourWithAMPM:date],
					  [self getMinute:date], ap];	
			}
			
		}else{
			ret= [wdayname stringByAppendingFormat:@" %@ %02d, %02d",
				  monthname,
				  [self getDay:date],
				  [self getYear:date]];	
			
		}
	}
	
	return ret;	
     */
    
    NSString *ret=nil;
    
	if(date !=nil){
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		unsigned unitFlags=NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit;
		NSDateComponents *comps =[gregorian components:unitFlags fromDate:date];
		
		NSString *wdayname=@"";
		NSString *monthname=[self getMonthName:date];
		NSString *ap=[self getAMPM:date];
		
		if(isTime){
			if(is24HrFormat){
				ret= [wdayname  stringByAppendingFormat:@" %@ %02d, %2d %02d:%02d",
					  monthname,
					  [comps day],
					  [comps year],
					  [comps hour],
					  [comps minute]];	
			}else {
				ret= [wdayname  stringByAppendingFormat:@" %@ %02d, %2d %02d:%02d%@",
					  monthname,
					  [comps day],
					  [comps year],
					  [self getHourWithAMPM:date],
					  [comps minute], ap];	
			}
			
		}else{
			ret= [wdayname stringByAppendingFormat:@" %@ %02d, %02d",
				  monthname,
				  [comps day],
				  [comps year]];	
			
		}
		
		[gregorian release];
	}else {
		return @"";
	}
	
	return ret;	
}

//get full date string from a given date. Ex: "Jul 7, 10"
+ (NSString *)getShortStringWithShortYearFromDate:(NSDate *) date{
    /*n: 2.2
	NSString *monthname=[self getMonthName:date];
	NSString *ret=nil;
	
	if(date !=nil){
		ret= [NSString stringWithFormat:@"%@ %02d, %@",
			  monthname,
			  [self getDay:date],
			  [[NSString stringWithFormat:@"%d", [self getYear:date]] substringFromIndex:2]];	
	}
	
	return ret;	
     */
    
    NSString *ret=nil;
	if(date !=nil){
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		unsigned unitFlags=NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit;
		NSDateComponents *comps =[gregorian components:unitFlags fromDate:date];
		
		NSString *monthname=[self getMonthName:date];
		
		ret= [NSString stringWithFormat:@"%@ %02d, %@",
			  monthname,
			  [comps day],
			  [[NSString stringWithFormat:@"%d", [comps year]] substringFromIndex:2]];	
		
		[gregorian release];
	}else {
		return @"";
	}
    
	return ret;	
}

+ (NSString *)getShortDateStringFromDate:(NSDate *) date {
    /* :2.2
	NSString *ret=nil;
	if(date !=nil){
		ret= [NSString stringWithFormat:@"%02d-%02d-%02d",
			   [self getYear:date],
			   [self  getMonth:date],
			   [self getDay:date]];	
	}
	return ret;	
     */
    
    NSString *ret=nil;
	if(date !=nil){
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		unsigned unitFlags=NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit;
		NSDateComponents *comps =[gregorian components:unitFlags fromDate:date];
		
		ret= [NSString stringWithFormat:@"%02d-%02d-%02d",
			  [comps year],
			  [comps  month],
			  [comps day]];
		
		[gregorian release];
	}
	return ret;	
}

//get a date string from a given date. Ex: 2010-05-09 10:40:30
+ (NSString *)getShortDateTimeStringFromDate:(NSDate *) date {
    /*n: 2.2
	NSString *ret=nil;
	if(date !=nil){
		ret= [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d",
			  [self getYear:date],
			  [self getMonth:date],
			  [self getDay:date],
			  [self getHour:date],
			  [self getMinute:date],
			  [self getSecond:date]];	
	}
	return ret;
     */
    
    NSString *ret=nil;
	if(date !=nil){
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		unsigned unitFlags=NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit;
		NSDateComponents *comps =[gregorian components:unitFlags fromDate:date];
		
		ret= [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d",
			  [comps year],
			  [comps month],
			  [comps day],
			  [comps hour],
			  [comps minute],
			  [comps second]];
		[gregorian release];
	}
	return ret;	
}

//get a date string from a given date. Ex: "Jul 7, 2008"
+ (NSString *)getShortDateStringWithMonthDay:(NSDate*)date{
    /*n: 2.2
	NSString * monthname = [self getMonthName:date];
	
	NSString * ret = [monthname stringByAppendingFormat:@" %02d, %2d",
					   [self getDay:date],
					   [self getYear:date]];
	return ret;
     */
    
    if (!date) {
		return @"";
	}
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags=NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit;
	NSDateComponents *comps =[gregorian components:unitFlags fromDate:date];
	
	NSString * monthname =[self getMonthName:date];
	
	NSString * ret = [monthname stringByAppendingFormat:@" %02d, %2d",
					  [comps day],
					  [comps year]];
	[gregorian release];
	
	return ret;
}

//get a date string without day from a given date. Ex: "Fri Jul, 2008"
+ (NSString *)getShortDateStringWithoutDay:(NSDate*)date{
    /*n: 2.2
	NSString * wdayname = [self getWeekDayFullName:date];
	NSString * monthname = [self getMonthName:date];
	
	NSString * ret = [wdayname stringByAppendingFormat:@"%, %@ %d\n%4d",
					  monthname,
                      [self getDay:date],		
					  [self getYear:date]];
	return ret;
     */
    
    if (!date) {
		return @"";
	}
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags=NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit;
	NSDateComponents *comps =[gregorian components:unitFlags fromDate:date];
	
	NSString * wdayname = WeekdayList[[comps weekday]-1];
	NSString * monthname =[self getMonthName:date];
	
	NSString * ret = [wdayname stringByAppendingFormat:@" %@, %2d",
					  monthname,		
					  [comps year]];
	[gregorian release];
	return ret;
}

//get a date string from a given date. Ex: "Fri Jul 7, 2008"
+ (NSString *)getCurrentShortDateString{
    /*n: 2.2
	NSDate *date=[NSDate date];
	NSString * wdayname = [self getWeekDayName:date];
	NSString * monthname = [self getMonthName:date];
	
	NSString * ret = [wdayname stringByAppendingFormat:@" %@ %02d, %2d",
					  monthname,		
					  [self getDay:date],
					  [self getYear:date]];
	return ret;
     */
    
    NSDate *date=[NSDate date];
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags=NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit;
	NSDateComponents *comps =[gregorian components:unitFlags fromDate:date];
	
	NSString * wdayname =WeekdayList[[comps weekday]-1];
	NSString * monthname = [self getMonthName:date];
	
	NSString * ret = [wdayname stringByAppendingFormat:@" %@ %02d, %2d",
					  monthname,		
					  [comps day],
					  [comps year]];
	[gregorian release];
	
	return ret;
}

//get time string from a given date. Ex: "11:00 AM"
+ (NSString *)getTimeStringAMPMFromDate:(NSDate *) date{
    /*n: 2.2
	NSString *ret=nil;
	NSString *ap=[self getAMPM:date];
	
	if(date !=nil){
		if(is24HrFormat){
			ret= [NSString stringWithFormat:@"%02d:%02d ",
				   [self getHour:date],
				   [self getMinute:date]];	
		}else {
			ret= [[NSString stringWithFormat:@"%02d:%02d ",
					[self getHourWithAMPM:date],
					[self getMinute:date]] stringByAppendingString:ap];	
		}
		
	}
	return ret;	
	*/
    
    if (!date) return nil;
	
	NSString *ret=nil;
    
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags=NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit;
	NSDateComponents *comps =[gregorian components:unitFlags fromDate:date];
	
	NSInteger hour=[comps hour];
	NSString *ap;//=[self getAMPM:date];
	
	if(is24HrFormat){
		ret= [NSString stringWithFormat:@"%02d:%02d ",
			  hour,
			  [comps minute]];	
	}else {
		if (hour>12){
			hour=hour-12;
			ap=pmText;
		}else {
            if(hour==12){
                ap=pmText;
            }else{
                if (hour==0){
                    hour=12;
                }
                ap=amText;
            }
		}
		
		ret= [[NSString stringWithFormat:@"%02d:%02d ",
			   hour,
			   [comps minute]] stringByAppendingString:ap];	
	}
	
	
	[gregorian release];
	
	return ret;
}

//get time string from a given date. Ex: "11:00am"
+ (NSString *)getTimeStringLowerAmPmFromDate:(NSDate *) date{
    /*n: 2.2
	NSString *ret=nil;
	NSString *ap=[[self getAMPM:date] lowercaseString];
	
	if(date !=nil){
		if(is24HrFormat){
			ret= [NSString stringWithFormat:@"%02d:%02d",
				  [self getHour:date],
				  [self getMinute:date]];	
		}else {
			ret= [[NSString stringWithFormat:@"%02d:%02d",
				   [self getHourWithAMPM:date],
				   [self getMinute:date]] stringByAppendingString:ap];	
		}
		
	}
	return ret;	
	*/
    if (!date) return nil;
	
	NSString *ret=nil;
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags=NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit;
	NSDateComponents *comps =[gregorian components:unitFlags fromDate:date];
	
	NSInteger hour=[comps hour];
	NSString *ap;//=[self getAMPM:date];
    
	if(is24HrFormat){
		ret= [NSString stringWithFormat:@"%02d:%02d",
			  hour,
			  [comps minute]];	
	}else {
		if (hour>12){
			hour=hour-12;
			ap=pmText;
		}else {
			if (hour==0){
				hour=12;
			}
			ap=amText;
		}
		
		ret= [[NSString stringWithFormat:@"%02d:%02d",
			   hour,
			   [comps minute]] stringByAppendingString:[ap lowercaseString]];	
	}
	
	[gregorian release];
	
	return ret;
}

//get weekday string from a given date. Ex: "Sat 3"
+ (NSString *)getDayWithName:(NSDate *) date{
    NSString *ret=nil;
	
	if(date !=nil){
		ret= [NSString stringWithFormat:@"%@ %d",
			  WeekdayList[[self getWeekday:date]-1],
			  [self getDay:date]];	
		
	}
	return ret;
}

//Jan-2010
+(NSString *)getMonthDayNameString:(NSDate*)date{
	NSString *ret;
	NSString *monthNameStr=[self getMonthName:date];
	
	ret=[NSString stringWithFormat:@"%@-%d",monthNameStr,[self getDay:date]];
	
	return ret;
}

//Jan-2010
+(NSString *)getMonthYearNameString:(NSDate*)date{
	NSString *ret;
	NSString *monthNameStr=[self getMonthName:date];

	ret=[NSString stringWithFormat:@"%@-%d",monthNameStr,[self getYear:date]];
	
	return ret;
}

//because of DST, we have to use this way to add time interval for a date.
+(NSDate*)dateByAddTimeInterval:(NSTimeInterval)offset fromDate:(NSDate*)date{
	NSTimeInterval dateInSec=[date timeIntervalSince1970];
	dateInSec+=offset;
	return [NSDate dateWithTimeIntervalSince1970:dateInSec];
}

//because of DST, we have to use this way to add time interval for a date.
//Ex: if offset=86400: will plus one day, if offset=-86400: will minus one day
+(NSDate *)newDateFromDate:(NSDate*)date offset:(NSTimeInterval)offset{
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:date];

/*	long long offsetLong=(long long)offset;	
	NSInteger dayOffset=(NSInteger)offsetLong/86400;
	NSInteger hourOffset=(NSInteger)(offsetLong % 86400)/3600;
	NSInteger minOffset=(NSInteger)((offsetLong % 86400) % 3600)/60;
	NSInteger secOffset=(NSInteger)((offsetLong % 86400) % 3600) % 60;
	
or	
	 NSInteger dayOffset=(NSInteger)offset/86400;
	 NSInteger hourOffset=(NSInteger)(offset - 86400*dayOffset)/3600;
	 NSInteger minOffset=(NSInteger)((offset - 86400*dayOffset) - 3600*hourOffset)/60;
	 NSInteger secOffset=((offset - 86400*dayOffset) - 3600*hourOffset) - 60*minOffset;
*/	 
	NSInteger dayOffset=(NSInteger)offset/86400;
	long long modDay=(NSInteger)offset%86400;//offset - 86400*dayOffset;
	NSInteger hourOffset=(NSInteger)modDay/3600;
	long long modHour=(NSInteger)modDay%3600;;//modDay-3600*hourOffset;
	NSInteger minOffset=modHour/60;
	NSInteger secOffset=modHour%60;;//modHour - 60*minOffset;
	
	[comps setDay:[comps day]+dayOffset];
	[comps setHour:[comps hour]+hourOffset];
	[comps setMinute:[comps minute]+minOffset];
	[comps setSecond:[comps second]+secOffset];
	
	return [[gregorian dateFromComponents:comps] retain];
}

+(NSDate *)nextMonthOfDate:(NSDate*)date{
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:date];
	
	[comps setMonth:[comps month]+1];
	
	return [gregorian dateFromComponents:comps];
}

+(NSDate *)previousMonthOfDate:(NSDate*)date{
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:date];
	
	[comps setMonth:[comps month]-1];	
	
	return [gregorian dateFromComponents:comps];
}

+ (UIButton *)buttonWithTitle:	(NSString *)title
					   target:(id)target
					 selector:(SEL)selector
						frame:(CGRect)frame
						image:(NSString *)image
				 imagePressed:(NSString *)imagePressed
				darkTextColor:(BOOL)darkTextColor
{	
	//UIButton *button = [[UIButton alloc] initWithFrame:frame];
	// or you can do this:
			UIButton *button = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
			button.frame = frame;
	button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
	[button setTitle:title forState:UIControlStateNormal];	
	
	if (darkTextColor)
	{
		[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	}
	else
	{
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	}
	
	if(image !=nil){
		UIImage *newImage = [[UIImage imageNamed:image] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		[button setBackgroundImage:newImage forState:UIControlStateNormal];
	}
	
	if(imagePressed !=nil){
    	UIImage *newPressedImage = [[UIImage imageNamed:imagePressed] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		[button setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];
	}
	
	[button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
	
    // in case the parent view draws with a custom color or gradient, use a transparent color
	button.backgroundColor = [UIColor clearColor];
	return button;
}

+ (UIButton *)getButtonWithType:(NSString *)title 
				buttonType:(UIButtonType)buttonType
					 frame:(CGRect)frame
				titleColor:(UIColor *)titleColor
					target:(id)target
				  selector:(SEL)selector
		  normalStateImage:(NSString *)normalStateImage
		selectedStateImage:(NSString*)selectedStateImage
{
	//ILOG(@"[ivo_Utilities getButton\n");
	// create a UIButton with buttonType
	UIButton *button = [[UIButton buttonWithType:buttonType] retain];
	button.frame = frame;
	[button setTitle:title forState:UIControlStateNormal];
	button.titleLabel.font=[UIFont systemFontOfSize:14];
	if(titleColor!=nil){
		[button setTitleColor:titleColor  forState:UIControlStateNormal];
	}else {
		[button setTitleColor:[UIColor brownColor]  forState:UIControlStateNormal];		
	}
	
	button.backgroundColor = [UIColor clearColor];
	if(normalStateImage !=nil && ![normalStateImage isEqual:@""]){
		//[button setBackgroundImage:[[UIImage imageNamed:normalStateImage] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateNormal];
		[button setBackgroundImage:[UIImage imageNamed:normalStateImage] forState:UIControlStateNormal];
	}
	
	if(selectedStateImage !=nil && ![selectedStateImage isEqual:@""]){
		//[button setBackgroundImage:[[UIImage imageNamed:selectedStateImage] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
		[button setBackgroundImage:[UIImage imageNamed:selectedStateImage] forState:UIControlStateSelected];
	}
	
	[button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
	
	return button;
}

+(void)sortList:(NSMutableArray *)list byKey:(NSString *)byKey{
	[self sortList:list byKey:byKey isAscending:YES];
}

+(void)sortList:(NSMutableArray *)list byKey:(NSString *)byKey isAscending:(BOOL)isAscending{
	
	//sort the list before assigning it
	NSMutableArray* originalQTasks=[[NSMutableArray alloc] initWithArray:list]; 
	
	NSSortDescriptor *date_descriptorQ = [[NSSortDescriptor alloc] initWithKey:byKey ascending: isAscending];
	
	NSArray *sortDescriptors = [NSArray arrayWithObject:date_descriptorQ];
	
	//get the sorted task list based on the original task list 	
	[list setArray:[originalQTasks sortedArrayUsingDescriptors:sortDescriptors]];
	[date_descriptorQ release];
	[originalQTasks release];
	
}


+ (NSInteger)getWeekNumberForDate:(NSDate *)date{
	
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit|NSSecondCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags  fromDate:date];
	CFGregorianDate gregDate;
	CFAbsoluteTime absTime;
	CFTimeZoneRef zone = CFTimeZoneCreateWithTimeIntervalFromGMT( NULL , 0.0 );
	
	gregDate.year = comps.year ;
	gregDate.month = comps.month;
	
	gregDate.day = comps.day;
	
	gregDate.hour = comps.hour;
	
	gregDate.minute = comps.minute;
	gregDate.second = comps.second;
	
	absTime = CFGregorianDateGetAbsoluteTime(gregDate, NULL);
	NSInteger ret=CFAbsoluteTimeGetWeekOfYear(absTime,zone);
	CFRelease(zone);
	
	return ret;
}


+ (void)animateGrowAtTouchPoint:(CGPoint)touchPoint forView:(UIImageView *)theView 
{
	// Pulse the view by scaling up, then move the view to under the finger.
	NSValue *touchPointValue = [[[NSValue valueWithCGPoint:touchPoint] retain] autorelease];
	[UIView beginAnimations:nil context:touchPointValue];
	[UIView setAnimationDuration:GROW_ANIMATION_DURATION_SECONDS];
	CGAffineTransform transform = CGAffineTransformMakeScale(1.2, 1.2);
	theView.transform = transform;
	[UIView commitAnimations];
}

+ (void)animateShrinkView:(UIImageView *)theView toPosition:(CGPoint) thePosition
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:SHRINK_ANIMATION_DURATION_SECONDS];
	// Set the center to the final postion
	theView.center = thePosition;
	// Set the transform back to the identity, thus undoing the previous scaling effect.
	theView.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];	
}

+ (BOOL)check24HourFormat
{
	//[NSUserDefaults resetStandardUserDefaults];

	[NSDateFormatter setDefaultFormatterBehavior:NSNumberFormatterBehavior10_4];
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	NSDate *date = [NSDate date];
	
	NSString *formattedDateString = [dateFormatter stringFromDate:date];
	
	NSRange range;
	
	range.location = formattedDateString.length - 2;
	
	range.length = 2;
	
	NSString *tail = [[formattedDateString substringWithRange:range] uppercaseString];
	
	if ([tail isEqualToString:@"AM"] || [tail isEqualToString:@"PM"])
	{
		return NO;
	}
	
	return YES;
}

//get today start at 00:00:00
+(NSDate *)today{
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];	
	unsigned unitFlags = NSWeekdayCalendarUnit|NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:[NSDate date]];
	[comps setHour:0];
	[comps setMinute:0];
	[comps setSecond:0];
	
	return [gregorian dateFromComponents:comps];
}


+(NSDate *)dateWithNewMonthOffset:(NSDate*)date monthOffset:(NSInteger)monthOffset{
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];	
	unsigned unitFlags = NSWeekdayCalendarUnit|NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:date];
	[comps setDay:1];
	[comps setMonth:[comps month]+monthOffset];
	
	return [gregorian dateFromComponents:comps];
}

+(NSDate *)dateWithNewMonthOfYear:(NSDate*)date monthOfYear:(NSInteger)monthOfYear{
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];	
	unsigned unitFlags = NSWeekdayCalendarUnit|NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:date];
	[comps setDay:1];
	[comps setMonth:monthOfYear];
	
	return [gregorian dateFromComponents:comps];
}

+(NSDate *)dateWithNewYearOffset:(NSDate*)date yearOffset:(NSInteger)yearOffset{
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];	
	unsigned unitFlags = NSWeekdayCalendarUnit|NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:date];
	
	[comps setDay:1];
	[comps setMonth:1];
	[comps setYear:[comps year]+yearOffset];
	
	return [gregorian dateFromComponents:comps];
}

+(NSDate *)dateWithNewDayOfMonth:(NSDate*)date dayOfMonth:(NSInteger)dayOfMonth{
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];	
	unsigned unitFlags = NSWeekdayCalendarUnit|NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:date];
	[comps setDay:dayOfMonth];
	
	return [gregorian dateFromComponents:comps];
}

//Reset a dates with new components
+(NSDate *)resetDate:(NSDate*)date year:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute sencond:(NSInteger)second{
	NSDate *ret=nil;
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];	
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:date];
	
	[comps setYear:year];
	[comps setMonth:month];
	[comps setDay:day];
	
	[comps setHour:hour];
	[comps setMinute:minute];
	[comps setSecond:second];
	
	ret=[gregorian dateFromComponents:comps];
	
	return ret;
}

+(NSDate *)resetTimeForDate:(NSDate*)date hour:(NSInteger)hour minute:(NSInteger)minute sencond:(NSInteger)second{
	NSDate *ret=nil;
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];	
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:date];
	
	[comps setHour:hour];
	[comps setMinute:minute];
	[comps setSecond:second];
	
	ret=[gregorian dateFromComponents:comps];
	
	return ret;
}

#pragma mark common


+(NSInteger)ColorIntFromGroupId:(NSInteger)groupId colorId:(NSInteger)colorId{
    NSInteger num=groupId*8+colorId;
    if (num<0 || num>31) {
        num=0;
    }
    return categoriesColor[num];
}

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert {
	NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
	unsigned hexNum;
	if (![scanner scanHexInt:&hexNum]) return nil;
	
	int r = (hexNum >> 16) & 0xFF;
	int g = (hexNum >> 8) & 0xFF;
	int b = (hexNum) & 0xFF;
	
	return [UIColor colorWithRed:r / 255.0f
						   green:g / 255.0f
							blue:b / 255.0f
						   alpha:1.0f];
}

+ (NSString *)hexStringFromColor:(UIColor *)colorVal 
{
	CGFloat r,g,b,a;
	
	CGColorRef color = [colorVal CGColor];
	
	int numComponents = CGColorGetNumberOfComponents(color);
	
	if (numComponents == 4)
	{
		const CGFloat *components = CGColorGetComponents(color);
		r = components[0];
		g = components[1];
		b = components[2];
		a = components[3];
	}	
	
	r = MIN(MAX(r, 0.0f), 1.0f);
	g = MIN(MAX(g, 0.0f), 1.0f);
	b = MIN(MAX(b, 0.0f), 1.0f);
	
	unsigned hexNum = (((int)roundf(r * 255)) << 16)
	| (((int)roundf(g * 255)) << 8)
	| (((int)roundf(b * 255)));	
	
	return [NSString stringWithFormat:@"%0.6X", hexNum];
}

+ (NSComparisonResult)compareDate:(NSDate*) date1 withDate:(NSDate*) date2
{
	
	NSComparisonResult ret;
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	
	unsigned flags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
	
	NSDateComponents *comps1 = [gregorian components:flags fromDate:date1];
	NSDateComponents *comps2 = [gregorian components:flags fromDate:date2];
	
	if ([comps2 year] > [comps1 year])
	{
		ret= NSOrderedAscending;
	}
	else if ([comps2 year] < [comps1 year])
	{
		ret= NSOrderedDescending;
	}
	else if ([comps2 month] > [comps1 month])
	{
		ret= NSOrderedAscending;		
	}
	else if ([comps2 month] < [comps1 month])
	{
		ret= NSOrderedDescending;		
	}
	else if ([comps2 day] > [comps1 day])
	{
		ret= NSOrderedAscending;		
	}
	else if ([comps2 day] < [comps1 day])
	{
		ret= NSOrderedDescending;
	}
	else if ([comps2 hour] > [comps1 hour])
	{
		ret= NSOrderedAscending;
	}
	else if ([comps2 hour] < [comps1 hour])
	{
		ret= NSOrderedDescending;		
	}
	else if ([comps2 minute] > [comps1 minute])
	{
		ret= NSOrderedAscending;		
	}
	else if ([comps2 minute] < [comps1 minute])
	{
		ret= NSOrderedDescending;		
	}
	else if ([comps2 second] > [comps1 second])
	{
		ret= NSOrderedAscending;		
	}
	else if ([comps2 second] < [comps1 second])
	{
		ret= NSOrderedDescending;
	}
	else 
	{
		ret= NSOrderedSame;
	}
	
	return ret;
}

+ (NSComparisonResult)compareDateNoTime:(NSDate*) date1 withDate:(NSDate*) date2
{
	NSComparisonResult ret;
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	
	unsigned flags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
	
	NSDateComponents *comps1 = [gregorian components:flags fromDate:date1];
	NSDateComponents *comps2 = [gregorian components:flags fromDate:date2];
	
	if ([comps2 year] > [comps1 year])
	{
		ret= NSOrderedAscending;
	}
	else if ([comps2 year] < [comps1 year])
	{
		ret= NSOrderedDescending;
	}
	else if ([comps2 month] > [comps1 month])
	{
		ret= NSOrderedAscending;		
	}
	else if ([comps2 month] < [comps1 month])
	{
		ret= NSOrderedDescending;		
	}
	else if ([comps2 day] > [comps1 day])
	{
		ret= NSOrderedAscending;		
	}
	else if ([comps2 day] < [comps1 day])
	{
		ret= NSOrderedDescending;
	}
	else 
	{
		ret= NSOrderedSame;
	}
	
	return ret;
}

//dateStr: yyyy-mm-dd
+(NSDate *)dateFromDateString:(NSString *)dateStr{
	NSArray *dateComps=[dateStr componentsSeparatedByString:@"-"];
	if (dateComps.count<3)return nil;
	
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];	
	unsigned unitFlags = NSWeekdayCalendarUnit|NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:[NSDate date]];
	[comps setYear:[[dateComps objectAtIndex:0] intValue]];
	[comps setMonth:[[dateComps objectAtIndex:1] intValue]];
	[comps setDay:[[dateComps objectAtIndex:2] intValue]];
	[comps setHour:0];
	[comps setMinute:0];
	[comps setSecond:0];
	
	return [gregorian dateFromComponents:comps];
	
}

+(NSTimeInterval)getExpendingDurationOfTask:(SPadTask *)task{
	NSTimeInterval totalDuration=0; 
	NSArray *doingHistoryList=[task.doingLogs componentsSeparatedByString:@"/"];
	for (NSInteger i=1; i<doingHistoryList.count; i++) {
		NSString *str=[doingHistoryList objectAtIndex:i];
		NSArray *arr=[str componentsSeparatedByString:@"|"];
		NSTimeInterval totalDurationTmp=[[arr objectAtIndex:1] doubleValue]-[[arr objectAtIndex:0] doubleValue];
		totalDuration+=totalDurationTmp;
	}
	return totalDuration;
}

+ (UIButton *)getButton:(NSString *)title 
				buttonType:(UIButtonType)buttonType
					 frame:(CGRect)frame
				titleColor:(UIColor *)titleColor
					target:(id)target
				  selector:(SEL)selector
		  normalStateImage:(NSString *)normalStateImage
		selectedStateImage:(NSString*)selectedStateImage
{
	UIButton *button = [UIButton buttonWithType:buttonType];
	button.frame = frame;
	[button setTitle:title forState:UIControlStateNormal];
	button.titleLabel.font=[UIFont systemFontOfSize:14];
	if(titleColor!=nil){
		[button setTitleColor:titleColor  forState:UIControlStateNormal];
	}else {
		[button setTitleColor:[UIColor brownColor]  forState:UIControlStateNormal];		
	}
	
	button.backgroundColor = [UIColor clearColor];
	if(normalStateImage !=nil && ![normalStateImage isEqual:@""]){
		[button setBackgroundImage:[UIImage imageNamed:normalStateImage] forState:UIControlStateNormal];
	}
	
	if(selectedStateImage !=nil && ![selectedStateImage isEqual:@""]){
		[button setBackgroundImage:[UIImage imageNamed:selectedStateImage] forState:UIControlStateSelected];
	}
	
	[button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
	return button;
}

/*
+ (NSDate *)getDeadLine:(NSInteger)type fromDate:(NSDate *)fromDate{
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
	NSDate *deadLineDate;
	NSDateComponents *compsDln = [gregorian components:unitFlags fromDate:fromDate];
	
	switch (type) {
		case DEADLINE_TODAY:
			deadLineDate = fromDate;
			break;
		case DEADLINE_TOMORROW:
			[compsDln setDay:[compsDln day]+1];
			deadLineDate=[gregorian dateFromComponents:compsDln];
			break;
		case DEADLINE_1_WEEK:
			[compsDln setDay:[compsDln day] +7];
			deadLineDate=[gregorian dateFromComponents:compsDln];
			break;
		case DEADLINE_2_WEEKS:
			[compsDln setDay:[compsDln day] +14];
			deadLineDate=[gregorian dateFromComponents:compsDln];
			
			break;
		case DEADLINE_1_MONTH:
			[compsDln setMonth:[compsDln month] +1];
			deadLineDate=[gregorian dateFromComponents:compsDln];
			
			break;
		default: //ST3.2.1
			deadLineDate = fromDate;
	}
	
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:deadLineDate];
	[comps setSecond:0];
	
	NSInteger weekDay=[self getWeekday:deadLineDate];
	
	NSInteger wkHourDeskEnd=(NSInteger)coreData.currentSetting.deskTimeWEEnd/60;
	NSInteger ndHourDeskEnd=(NSInteger)coreData.currentSetting.deskTimeNDEnd/60;
	
	NSInteger wkMinDeskEnd=(NSInteger)coreData.currentSetting.deskTimeWEEnd%60;
	NSInteger ndMinDeskEnd=(NSInteger)coreData.currentSetting.deskTimeNDEnd%60;
	
	if([coreData isDayInWeekend:weekDay]){
		[comps setMinute:wkMinDeskEnd];
		[comps setHour:wkHourDeskEnd];	
	}else{//normal day
		[comps setMinute:ndMinDeskEnd];
		[comps setHour: ndHourDeskEnd];	
	}
	
	return [gregorian dateFromComponents:comps];
}
*/

+ (NSString *)getHowLongString:(NSInteger)value{
	NSString *ret=nil;
    NSInteger weeks=value/10080;
    NSInteger days=(value%10080)/1440;
	NSInteger hours=((value%10080)%1440)/60;
	NSInteger mins=((value%10080)%1440)%60;
    
    /*
	if(hours<1){
		ret= [NSString stringWithFormat:@"%d min",mins];
	}else {
		if(mins>0){
			if(hours>1){
				if(mins<2){
					ret= [NSString stringWithFormat:@"%d hrs, %d min",hours,mins];
				}else {
					ret= [NSString stringWithFormat:@"%d hrs, %d mins",hours,mins];
				}
				
			}else {
				if(mins<2){
					ret= [NSString stringWithFormat:@"%d hr, %d min",hours,mins];
				}else {
					ret= [NSString stringWithFormat:@"%d hr, %d mins",hours,mins];
				}
				
			}
			
		}else {
			if(hours>1){
				ret= [NSString stringWithFormat:@"%d hrs",hours];
			}else {
				ret= [NSString stringWithFormat:@"%d hr",hours];
			}
		}
    
	}
     */
    ret=[NSString stringWithFormat:@"%@%@%@%@",weeks>0?[NSString stringWithFormat:@"%d week(s) ",weeks]:@"", days>0?[NSString stringWithFormat:@"%d day(s) ",days]:@"", hours>0?[NSString stringWithFormat:@"%d hour(s) ",hours]:@"", mins>0?[NSString stringWithFormat:@"%d min(s)",mins]:@""];
	return ret;
}

+(BOOL)isTheSameIndexOfTask:(SPadTask *)task1 andTask:(SPadTask*)task2{
	BOOL ret=YES;
	
	if ([task1.endTime compare:task2.startTime]!=NSOrderedDescending) {
		return NO;
	}
	
	if ([task1.startTime compare:task2.endTime]!=NSOrderedAscending) {
		return NO;
	}
	
	return ret;
}

/*
+(BOOL)isTheSameIndexFromStartDate:(NSDate *)startDate endDate:(NSDate*)endDate forDate:(NSDate*)date{
	BOOL ret=NO;
	if ([self getYear:startDate]==[self getYear:date] && [self getMonth:startDate]==[self getMonth:date] 
		&& [self getDay:startDate]==[self getDay:date] 
		&& (([self getHour:startDate]*60 + [self getMinute:startDate])<=([self getHour:date]*60 + [self getMinute:date])) 
		&& (([self getHour:endDate]*60 + [self getMinute:endDate])>([self getHour:date]*60 + [self getMinute:date]))) {
		ret=YES;
	}
	
	return ret;
}

+(BOOL)isTheSameIndex:(NSDate *)date1 fromDate:(NSDate*)date2{

	BOOL ret=NO;
	if ([self getYear:date1]==[self getYear:date2] && [self getMonth:date1]==[self getMonth:date2] 
		&& [self getDay:date1]==[self getDay:date2] 
		&& (([self getHour:date1]*60 + [self getMinute:date1])<=([self getHour:date2]*60 + [self getMinute:date2])) 
		&& (([self getHour:date1]*60 + [self getMinute:date1] + 30)>=([self getHour:date2]*60 + [self getMinute:date2]))) {
		ret=YES;
	}
	
	return ret;
}
*/

+(NSDate *)resetTime4Date:(NSDate*)date hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second{
	NSDate *ret=nil;
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];	
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:date];
	
	[comps setHour:hour];
	[comps setMinute:minute];
	[comps setSecond:second];
	
	ret=[gregorian dateFromComponents:comps];
	[gregorian release];
	
	return ret;
}




@end
