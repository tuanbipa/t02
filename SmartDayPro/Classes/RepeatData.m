//
//  RepeatData.m
//  SmartCal
//
//  Created by Trung Nguyen on 5/18/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "RepeatData.h"
#import "Common.h"

@implementation RepeatData

@synthesize type;
@synthesize interval;
@synthesize weekOption;
@synthesize monthOption;
@synthesize count;
@synthesize until;
@synthesize originalStartTime;
@synthesize deletedExceptionDates;

//RT
@synthesize repeatFrom;
@synthesize weekDay;
@synthesize weekOrdinal;

- (id)init
{
	if (self = [super init])
	{
		self.type = REPEAT_DAILY;
		self.repeatFrom = REPEAT_FROM_DUE;
		[self reset];
	}
	
	return self;
}

- (void) reset
{
	//NSInteger wkOptions[7] = {ON_SUNDAY, ON_MONDAY, ON_TUESDAY, ON_WEDNESDAY, ON_THURSDAY, ON_FRIDAY, ON_SATURDAY};
	//int day = [Common getWeekday:[NSDate date]];
	
	self.interval = 1;
	//self.weekOption = wkOptions[day-1];
    self.weekOption = 0;
	self.monthOption = BY_DAY_OF_MONTH;
	self.count = 0;
	self.until = nil;	
	self.originalStartTime = nil;
	
	self.weekDay = 0;
	self.weekOrdinal = 0;
}

- (id) copyWithZone:(NSZone*) zone{
	RepeatData *copy = [[RepeatData alloc] init];
	
	copy.type = type;
	copy.interval = interval;
	copy.weekOption = weekOption;
	copy.monthOption = monthOption;
	copy.count = count;
	copy.until = until;
	
	copy.originalStartTime = originalStartTime;
	copy.deletedExceptionDates = [deletedExceptionDates mutableCopyWithZone:zone];
	
	copy.repeatFrom = repeatFrom;
	copy.weekDay = weekDay;
	copy.weekOrdinal = weekOrdinal;
	
	return copy;
}

- (NSString *) getRepeatData
{
	return @"";
}

- (void) calculateUntilByCount:(NSDate *) fromDate
{
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	unsigned unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit |NSSecondCalendarUnit;
    
	//NSDateComponents *comps = [gregorian components:unitFlags fromDate:fromDate];
	
    NSDateComponents *dtcomps = [gregorian components:unitFlags fromDate:fromDate];
    
    NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
    
    comps.year = dtcomps.year;
    comps.month = dtcomps.month;
    comps.hour = dtcomps.hour;
    comps.minute = dtcomps.minute;
    comps.second = dtcomps.second;
    
	switch (self.type) {
		case REPEAT_DAILY:
		{
			[comps setDay:[comps day]+self.interval*(self.count-1)];
		}
			break;
		case REPEAT_WEEKLY:
		{
			NSInteger wkOptions[7] = {ON_SUNDAY, ON_MONDAY, ON_TUESDAY, ON_WEDNESDAY, ON_THURSDAY, ON_FRIDAY, ON_SATURDAY}; 

			int wkday = [Common getWeekday:fromDate];
			int idx = wkday - 1;
			
			int nInstances = 0;
			//int nPreInstances = 0;
			
			for (int i=0; i<7; i++)
			{
				if (self.weekOption & wkOptions[i])
				{
					/*if (i < idx)
					{
						nPreInstances += 1;
					}*/
					
					nInstances += 1;
				}
			}
			
			if (nInstances == 0) //self.weekOption = 0 -> repeat on current week day
			{
				nInstances = 1;
				//nPreInstances = 1;
			}
			
			int n1 = 7*self.interval*(self.count/nInstances)-1;
			int n2 = self.count%nInstances;
			
			//int ndays = [comps day] + n1 + n2 - nPreInstances;
            
            int ndays = [comps day] + n1;
            
            if (n2 > 0)
            {
                for (int i=idx; i<7; i++)
                {
                    ndays += 1;
                    
                    if (self.weekOption & wkOptions[i])
                    {
                        n2 -= 1;
                    }
                    
                    if (n2 == 0)
                    {
                        break;
                    }
                }
                
                if (n2 > 0)
                {
                    //count instances in the next interval
                    
                    ndays += 7*self.interval - idx - 1;
                    
                    for (int i=0;i<idx;i++)
                    {
                        ndays += 1;
                        
                        if (self.weekOption & wkOptions[i])
                        {
                            n2 -= 1;
                        }
                        
                        if (n2 == 0)
                        {
                            break;
                        }                    
                    }
                }
                
            }
			
			[comps setDay:ndays];
		}
			break;
		case REPEAT_MONTHLY:
		{
			int nMonths = [comps month] + self.interval*(self.count-1);
			
			[comps setYear:[comps year] + nMonths/12];
			[comps setMonth:nMonths%12];
			
			if (self.monthOption == BY_DAY_OF_WEEK)
			{
                int wkday = [Common getWeekday:fromDate];
                int wkordinal = [Common getWeekdayOrdinal:fromDate];
                
				[comps setWeekday:wkday];
				[comps setWeekdayOrdinal:wkordinal];
			}
            else if (self.monthOption == BY_DAY_OF_MONTH)
            {
                int day = [Common getDay:fromDate];
                
                [comps setDay:day];
            }
		}
			break;
		case REPEAT_YEARLY:
		{
			[comps setYear:[comps year]+self.interval*(self.count-1)];
		}
			break;
		default:
			break;
	}
	
	self.until = [gregorian dateFromComponents:comps];
}

/*
-(NSString *)getDueString
{
	if (self.dueDays >= 0)
	{
		return [NSString stringWithFormat:@"%@ %d %@", _byText, self.dueDays, _daysAfterStartText];
	}
	else if (self.dueDays == -2)
	{
		return _byStartOfNextInstanceText;
	}
	
	return _noneText;
}
*/

- (void)dealloc {
	
	self.until = nil;
	self.originalStartTime = nil;
	
	self.deletedExceptionDates = nil;
	
    [super dealloc];
}

+ (RepeatData *) parseRepeatDataForDeletedException:(NSString *)data
{
	if (data != nil && ![data isEqualToString:@""])
	{
		RepeatData *ret = [[[RepeatData alloc] init] autorelease]; 
		
		NSArray *parts = [data componentsSeparatedByString:@"|"];
		
		ret.deletedExceptionDates = [NSMutableArray arrayWithCapacity:parts.count];
		
		for (NSString *part in parts)
		{
			NSDate *exceptionDate = [NSDate dateWithTimeIntervalSince1970:[part doubleValue]];
			
			[ret.deletedExceptionDates addObject:exceptionDate];
		}
		
		return ret;
	}
	
	return nil;
}

+ (RepeatData *) parseRepeatDataForException:(NSString *)data
{
	if (data != nil && ![data isEqualToString:@""])
	{
		RepeatData *ret = [[[RepeatData alloc] init] autorelease]; 
		
		double dt = [data doubleValue];
		
		if (dt == -1)
		{
			return nil;
		}
		
		ret.originalStartTime = [NSDate dateWithTimeIntervalSince1970:dt];

		return ret;
	}
	
	return nil;
}

+ (RepeatData *) parseRepeatData:(NSString *)data
{
	if (data != nil && ![data isEqualToString:@""])
	{
		RepeatData *ret = [[[RepeatData alloc] init] autorelease]; 
		
		NSArray *parts = [data componentsSeparatedByString:@"/"];
		
		NSInteger type = [[parts objectAtIndex:0] intValue];
		NSInteger interval = [[parts objectAtIndex:1] intValue];
		NSInteger option = [[parts objectAtIndex:2] intValue];
		double until = [[parts objectAtIndex:3] doubleValue];
		
		//NSInteger from = [[parts objectAtIndex:4] intValue];
		NSArray *rtParts = [[parts objectAtIndex:4] componentsSeparatedByString:@"|"];
		
		ret.type = type;
		ret.interval = interval;
		
		//ret.repeatFrom = from;
		ret.repeatFrom = [[rtParts objectAtIndex:0] intValue];
		
		if (rtParts.count > 1)
		{
			ret.weekDay = [[rtParts objectAtIndex:1] intValue];
			ret.weekOrdinal = [[rtParts objectAtIndex:2] intValue];
		}
		
		if (type == REPEAT_WEEKLY)
		{
			ret.weekOption = option;
		}
		else if (type == REPEAT_MONTHLY)
		{
			ret.monthOption = option;
		}
		
		if (until == -1)
		{
			ret.until = nil;
		}
		else 
		{
			ret.until = [NSDate dateWithTimeIntervalSince1970:until];
		}
		
		return ret;	
	}
	
	return nil;
}

+ (NSString *) stringOfRepeatDataForDeletedException:(RepeatData *)data
{
	if (data != nil && data.deletedExceptionDates != nil && data.deletedExceptionDates.count > 0)
	{
		NSDate *dt = [data.deletedExceptionDates objectAtIndex:0];
		
		NSString *ret = [NSString stringWithFormat:@"%f", [dt timeIntervalSince1970]];
		
		for (int i=1; i<data.deletedExceptionDates.count ;i++)
		{
			dt = [data.deletedExceptionDates objectAtIndex:i];
			
			ret = [ret stringByAppendingFormat:@"|%f", [dt timeIntervalSince1970]];
		}
		
		return ret;
	}
	
	return @"";
}

+ (NSString *) stringOfRepeatDataForException:(RepeatData *)data
{
	if (data != nil)
	{
		return [NSString stringWithFormat:@"%f", (data.originalStartTime == nil?-1:[data.originalStartTime timeIntervalSince1970])];
	}
	
	return @"";
}

+ (NSString *) stringOfRepeatData:(RepeatData *)data
{
	if (data != nil)
	{
		NSInteger option = -1;
		
		if (data.type == REPEAT_WEEKLY)
		{
			option = data.weekOption;
		}
		else if (data.type == REPEAT_MONTHLY)
		{
			option = data.monthOption;
		}
		
		return [NSString stringWithFormat:@"%d/%d/%d/%f/%d|%d|%d", data.type, data.interval, option, (data.until == nil?-1:[data.until timeIntervalSince1970]), data.repeatFrom, data.weekDay, data.weekOrdinal];
	}
	
	return @"";
}

+ (BOOL) isEqual:(RepeatData *)src toAnother:(RepeatData *)dest
{
	if (src != nil && dest != nil)
	{
		return [[RepeatData stringOfRepeatData:src] isEqualToString:[RepeatData stringOfRepeatData:dest]];
	}
	else if (src == nil && dest == nil)
	{
		return YES;
	}
	
	return NO;
}


@end
