//
//  TDTask.m
//  SmartCal
//
//  Created by MacBook Pro on 10/4/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "TDTask.h"

#import "Common.h"
#import "RepeatData.h"

@implementation TDTask

@synthesize id;
@synthesize folderId;
@synthesize title;
@synthesize tag;
@synthesize note;
@synthesize startTime;
@synthesize dueTime;
@synthesize modifiedTime;
@synthesize completedTime;
@synthesize priority;
@synthesize length;

@synthesize repeat;
@synthesize repeatFrom;
@synthesize rep_advanced;
@synthesize star;

@synthesize meta;

- (id)init
{
	if (self = [super init])
	{
	}
	
	return self;
}

- (void)dealloc 
{
	self.id = nil;
	self.folderId = nil;
	self.title = nil;
	self.tag = nil;
	self.note = nil;
	self.startTime = nil;
	self.dueTime = nil;
	self.modifiedTime = nil;
	self.completedTime = nil;
	
	self.rep_advanced = nil;
	
	self.meta = nil;
	
	[super dealloc];
}


- (void) print
{
	/*////printf("TD Task: %s - id: %s - folder: %s - start: %s - due: %s - modified: %s\n", [self.title UTF8String], 
		   [self.id UTF8String],
		   [self.folderId UTF8String],
		   [[self.startTime description] UTF8String],
		   [[self.dueTime description] UTF8String],
		   [[self.modifiedTime description] UTF8String]);
	*/
}

- (NSInteger) getWeekdayByString:(NSString *)wkdayStr forOption:(BOOL) forOption
{
	NSInteger ret = 0;
	
	//if ([wkdayStr isEqualToString:@"Sun"])
	if ([wkdayStr isEqualToString:@"SUN"])
	{
		ret = forOption?ON_SUNDAY:1;
	}
	//else if ([wkdayStr isEqualToString:@"Mon"])
	else if ([wkdayStr isEqualToString:@"MON"])
	{
		ret = forOption?ON_MONDAY:2;						
	}
	//else if ([wkdayStr isEqualToString:@"Tue"])
	else if ([wkdayStr isEqualToString:@"TUE"])
	{
		ret = forOption?ON_TUESDAY:3;						
	}
	//else if ([wkdayStr isEqualToString:@"Wed"])
	else if ([wkdayStr isEqualToString:@"WED"])
	{
		ret = forOption?ON_WEDNESDAY:4;		
	}
	//else if ([wkdayStr isEqualToString:@"Thu"])
	else if ([wkdayStr isEqualToString:@"THU"])
	{
		ret = forOption?ON_THURSDAY:5;
	}
	//else if ([wkdayStr isEqualToString:@"Fri"])
	else if ([wkdayStr isEqualToString:@"FRI"])
	{
		ret = forOption?ON_FRIDAY:6;
	}
	//else if ([wkdayStr isEqualToString:@"Sat"])
	else if ([wkdayStr isEqualToString:@"SAT"])
	{
		ret = forOption?ON_SATURDAY:7;		
	}
	
	return ret;
}
- (RepeatData *) getRepeatData
{
	if (self.rep_advanced != nil && ![self.rep_advanced isEqualToString:@""])
	{
		NSString *up_rep_advanced = [self.rep_advanced uppercaseString];
		
		RepeatData *repDat = [[[RepeatData alloc] init] autorelease];
		
		repDat.repeatFrom = (self.repeatFrom == 1?REPEAT_FROM_COMPLETION:REPEAT_FROM_DUE);
		
		//NSRange keyRange = [rep_advanced rangeOfString:@"Every "];
		NSRange keyRange = [up_rep_advanced rangeOfString:@"EVERY "];
		
		if (keyRange.location != NSNotFound) //Format 1 or Format 3
		{
			//NSString *str = [rep_advanced stringByReplacingOccurrencesOfString:@"Every " withString:@""];	
			NSString *str = [up_rep_advanced stringByReplacingOccurrencesOfString:@"EVERY " withString:@""];	
			
			//keyRange = [rep_advanced rangeOfString:@"weekend"];
			keyRange = [str rangeOfString:@"WEEKEND"];
			
			if (keyRange.location != NSNotFound) //Format 3
			{
				repDat.type = REPEAT_WEEKLY;
				repDat.weekOption = ON_SATURDAY | ON_SUNDAY;
			}
			else
			{
				//keyRange = [rep_advanced rangeOfString:@"weekday"];
				keyRange = [str rangeOfString:@"WEEKDAY"];
				
				if (keyRange.location != NSNotFound) //Format 3
				{
					repDat.type = REPEAT_WEEKLY;
					repDat.weekOption = ON_MONDAY | ON_TUESDAY | ON_WEDNESDAY | ON_THURSDAY | ON_FRIDAY;
				}
				else
				{
					//keyRange = [rep_advanced rangeOfString:@", "];
					keyRange = [str rangeOfString:@", "];
					
					if (keyRange.location != NSNotFound) //Format 3
					{
						repDat.type = REPEAT_WEEKLY;
						
						NSArray *parts = [str componentsSeparatedByString:@", "];
						
						for (NSString *part in parts)
						{
							repDat.weekOption |= [self getWeekdayByString:part forOption:YES];
						}
					}
					else 
					{
						NSArray *parts = [str componentsSeparatedByString:@" "];
						
						if (parts.count == 2) //Format 1
						{
							repDat.interval = [[parts objectAtIndex:0] intValue];
							
							//NSString *str = [[parts objectAtIndex:1] stringByReplacingOccurrencesOfString:@"s" withString:@""];
							NSString *str = [[parts objectAtIndex:1] stringByReplacingOccurrencesOfString:@"S" withString:@""];
							
							//if ([str isEqualToString:@"day"])
							if ([str isEqualToString:@"DAY"])
							{
								repDat.type = REPEAT_DAILY;
							}
							//else if ([str isEqualToString:@"week"])
							else if ([str isEqualToString:@"WEEK"])
							{
								repDat.type = REPEAT_WEEKLY;
							}
							//else if ([str isEqualToString:@"month"])
							else if ([str isEqualToString:@"MONTH"])
							{
								repDat.type = REPEAT_MONTHLY;
							}
							//else if ([str isEqualToString:@"year"])
							else if ([str isEqualToString:@"YEAR"])
							{
								repDat.type = REPEAT_YEARLY;
							}									
						}
						else if (parts.count == 1) //Format 3
						{
							NSRange dayRange;
							
							dayRange.location = 0;
							dayRange.length = 3;
							
							NSString *dayStr = [[parts objectAtIndex:0] substringWithRange:dayRange];
							
							repDat.type = REPEAT_WEEKLY;
							repDat.weekOption = [self getWeekdayByString:dayStr forOption:YES];
						}
						
					}
					
				}						
			}
		}
		
		//keyRange = [rep_advanced rangeOfString:@"of each month"];
		keyRange = [up_rep_advanced rangeOfString:@"OF EACH MONTH"];
		
		if (keyRange.location != NSNotFound) //Format 2
		{
			repDat.type = REPEAT_MONTHLY;
			repDat.monthOption = BY_DAY_OF_WEEK;
			
			//NSString *str = [rep_advanced stringByReplacingOccurrencesOfString:@"The " withString:@""];					
			NSString *str = [up_rep_advanced stringByReplacingOccurrencesOfString:@"THE " withString:@""];	
			
			//str = [str stringByReplacingOccurrencesOfString:@" of each month" withString:@""];
			str = [str stringByReplacingOccurrencesOfString:@" OF EACH MONTH" withString:@""];
			
			NSArray *parts = [str componentsSeparatedByString:@" "];
			
			NSString *ordinalStr = [parts objectAtIndex:0];
			NSString *wkdayStr = [parts objectAtIndex:1];
			
			//if ([ordinalStr isEqualToString:@"1st"])
			if ([ordinalStr isEqualToString:@"1ST"])
			{
				repDat.weekOrdinal = 1;						
			}
			//else if ([ordinalStr isEqualToString:@"2nd"])
			else if ([ordinalStr isEqualToString:@"2ND"])
			{
				repDat.weekOrdinal = 2;						
			}
			//else if ([ordinalStr isEqualToString:@"3rd"])
			else if ([ordinalStr isEqualToString:@"3RD"])
			{
				repDat.weekOrdinal = 3;						
			}
			//else if ([ordinalStr isEqualToString:@"4th"])
			else if ([ordinalStr isEqualToString:@"4TH"])
			{
				repDat.weekOrdinal = 4;						
			}					
			//else if ([ordinalStr isEqualToString:@"5th"])
			else if ([ordinalStr isEqualToString:@"5TH"])
			{
				repDat.weekOrdinal = 5;			
			}	
			//else if ([ordinalStr isEqualToString:@"last"])
			else if ([ordinalStr isEqualToString:@"LAST"])
			{
				repDat.weekOrdinal = 6;
			}
			
			repDat.weekDay = [self getWeekdayByString:wkdayStr forOption:NO];
			
			//////printf("TD Repeat Data - task:%s, weekday:%d, weekordinal:%d\n", [self.title UTF8String], repDat.weekDay, repDat.weekOrdinal);
		}
		
		return repDat;
	}
	
	return nil;
}
- (RepeatData *) getRepeatData_v10
{
	if (self.repeat > 0)
	{
		RepeatData *repDat = [[[RepeatData alloc] init] autorelease];
		
		if (self.repeat > 100)
		{
			repDat.repeatFrom = REPEAT_FROM_COMPLETION;
			
			self.repeat -= 100;
		}
		else 
		{
			repDat.repeatFrom = REPEAT_FROM_DUE;
		}
		
		repDat.repeatFrom = (self.repeatFrom == 1?REPEAT_FROM_COMPLETION:REPEAT_FROM_DUE);
		
		switch (self.repeat) 
		{
			case 1:
				repDat.type = REPEAT_WEEKLY;
				break;
			case 2:
				repDat.type = REPEAT_MONTHLY;
				break;
			case 3:
				repDat.type = REPEAT_YEARLY;
				break;
			case 4:
				repDat.type = REPEAT_DAILY;
				break;
			case 5:
			{
				repDat.type = REPEAT_WEEKLY;
				repDat.interval = 2;
			}
				break;
			case 6:
			{
				repDat.type = REPEAT_MONTHLY;
				repDat.interval = 2;
			}
				break;
			case 7:
			{
				repDat.type = REPEAT_MONTHLY;
				repDat.interval = 6;
			}
				break;
			case 8:
			{
				repDat.type = REPEAT_MONTHLY;
				repDat.interval = 3;
			}
				break;
			case 50:
			{
				NSRange keyRange = [rep_advanced rangeOfString:@"Every "];
				
				if (keyRange.location != NSNotFound) //Format 1 or Format 3
				{
					NSString *str = [rep_advanced stringByReplacingOccurrencesOfString:@"Every " withString:@""];	
					
					keyRange = [rep_advanced rangeOfString:@"weekend"];
					
					if (keyRange.location != NSNotFound) //Format 3
					{
						repDat.type = REPEAT_WEEKLY;
						repDat.weekOption = ON_SATURDAY | ON_SUNDAY;
					}
					else
					{
						keyRange = [rep_advanced rangeOfString:@"weekday"];
						
						if (keyRange.location != NSNotFound) //Format 3
						{
							repDat.type = REPEAT_WEEKLY;
							repDat.weekOption = ON_MONDAY | ON_TUESDAY | ON_WEDNESDAY | ON_THURSDAY | ON_FRIDAY;
						}
						else
						{
							keyRange = [rep_advanced rangeOfString:@", "];
							
							if (keyRange.location != NSNotFound) //Format 3
							{
								repDat.type = REPEAT_WEEKLY;
								
								NSArray *parts = [str componentsSeparatedByString:@", "];
								
								for (NSString *part in parts)
								{
									repDat.weekOption |= [self getWeekdayByString:part forOption:YES];
								}
							}
							else 
							{
								NSArray *parts = [str componentsSeparatedByString:@" "];
								
								if (parts.count == 2) //Format 1
								{
									repDat.interval = [[parts objectAtIndex:0] intValue];
									
									NSString *str = [[parts objectAtIndex:1] stringByReplacingOccurrencesOfString:@"s" withString:@""];
									
									if ([str isEqualToString:@"day"])
									{
										repDat.type = REPEAT_DAILY;
									}
									else if ([str isEqualToString:@"week"])
									{
										repDat.type = REPEAT_WEEKLY;
									}
									else if ([str isEqualToString:@"month"])
									{
										repDat.type = REPEAT_MONTHLY;
									}
									else if ([str isEqualToString:@"year"])
									{
										repDat.type = REPEAT_YEARLY;
									}									
								}
								else if (parts.count == 1) //Format 3
								{
									NSRange dayRange;
									
									dayRange.location = 0;
									dayRange.length = 3;
									
									NSString *dayStr = [[parts objectAtIndex:0] substringWithRange:dayRange];
									
									repDat.type = REPEAT_WEEKLY;
									repDat.weekOption = [self getWeekdayByString:dayStr forOption:YES];
								}
								
							}

						}						
					}
				}
				
				keyRange = [rep_advanced rangeOfString:@"of each month"];
				
				if (keyRange.location != NSNotFound) //Format 2
				{
					repDat.type = REPEAT_MONTHLY;
					repDat.monthOption = BY_DAY_OF_WEEK;
					
					NSString *str = [rep_advanced stringByReplacingOccurrencesOfString:@"The " withString:@""];					
					str = [str stringByReplacingOccurrencesOfString:@" of each month" withString:@""];
					
					NSArray *parts = [str componentsSeparatedByString:@" "];
					
					NSString *ordinalStr = [parts objectAtIndex:0];
					NSString *wkdayStr = [parts objectAtIndex:1];
					
					if ([ordinalStr isEqualToString:@"1st"])
					{
						repDat.weekOrdinal = 1;						
					}
					else if ([ordinalStr isEqualToString:@"2nd"])
					{
						repDat.weekOrdinal = 2;						
					}
					else if ([ordinalStr isEqualToString:@"3rd"])
					{
						repDat.weekOrdinal = 3;						
					}
					else if ([ordinalStr isEqualToString:@"4th"])
					{
						repDat.weekOrdinal = 4;						
					}					
					else if ([ordinalStr isEqualToString:@"5th"])
					{
						repDat.weekOrdinal = 5;			
					}	
					else if ([ordinalStr isEqualToString:@"last"])
					{
						repDat.weekOrdinal = 6;
					}

					repDat.weekDay = [self getWeekdayByString:wkdayStr forOption:NO];
					
					//////printf("TD Repeat Data - task:%s, weekday:%d, weekordinal:%d\n", [self.title UTF8String], repDat.weekDay, repDat.weekOrdinal);
				}					
			}
				break;
			default:
				break;
		}
		
		return repDat;
	}

	return nil;
}

@end
