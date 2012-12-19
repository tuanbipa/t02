//
//  TDTaskParser.m
//  SmartCal
//
//  Created by MacBook Pro on 10/4/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "TDTaskParser.h"

#import "Common.h"
#import "TDTask.h"
#import "Settings.h"

@implementation TDTaskParser

@synthesize tasks;
@synthesize task;
@synthesize error;
@synthesize errorCode;
@synthesize forDeletion;

- (id)init
{
	if (self = [super init])
	{
		self.tasks = nil;
		self.task = nil;
		self.error = nil;
		self.errorCode = 0;
		self.forDeletion = NO;
		
		currentElementValue = [[NSMutableString alloc] initWithString:@""];
	}
	
	return self;
}

- (void)dealloc 
{
	self.tasks = nil;
	self.task = nil;
	self.error = nil;
	
	[currentElementValue release];
	
	[super dealloc];
}

- (void) reset
{
	/*
	if (task != nil)
	{
		[task release];
	}
	
	task = nil;
	*/
	self.task = nil;
	self.tasks = nil;
	
	self.error = nil;
	self.errorCode = 0;
}

- (void)parseXML:(NSData *)xmlData
{	
	[self reset];
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
    [parser setDelegate:self];
    [parser parse];	
	
	[parser release];
}
#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict 
{
	if([elementName isEqualToString:@"tasks"] || [elementName isEqualToString:@"deleted"]) 
	{
		//self.tasks = [[[NSMutableArray alloc] init] autorelease];
		self.tasks = [[NSMutableArray alloc] init];
		
		[self.tasks release];
	}
	else if([elementName isEqualToString:@"task"]) 
	{
		self.task = [[TDTask alloc] init];
		[self.task release];
	}
	else if([elementName isEqualToString:@"id"]) 
	{
		if (self.forDeletion)
		{
			self.task = [[TDTask alloc] init];
			[self.task release];
		}
	}
	else if ([elementName isEqualToString:@"error"])	
	{
		self.errorCode = [[attributeDict objectForKey:@"id"] intValue];
	}
	
	[currentElementValue setString:@""];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
	if([elementName isEqualToString:@"tasks"] || [elementName isEqualToString:@"deleted"])
		return;
	
	if([elementName isEqualToString:@"task"]) 
	{
		[self.tasks addObject:self.task];
		//[task release];
		//task = nil;
	}
	else if([elementName isEqualToString:@"id"]) 
	{
		task.id = currentElementValue;
		
		if (self.forDeletion)
		{
			[self.tasks addObject:self.task];
			//[task release];
			//task = nil;			
		}
	}
	else if([elementName isEqualToString:@"folder"]) 
	{
		task.folderId = currentElementValue;
	}
	else if([elementName isEqualToString:@"title"]) 
	{
		task.title = currentElementValue;
	}
	else if([elementName isEqualToString:@"tag"]) 
	{
		task.tag = currentElementValue;
	}
	else if([elementName isEqualToString:@"note"]) 
	{
		task.note = currentElementValue;
	}
	else if([elementName isEqualToString:@"startdate"]) 
	{
		//task.startTime = [Common getDateByString:currentElementValue];
		if ([currentElementValue isEqualToString:@"0"])
		{
			task.startTime = nil;
		}
		else 
		{
			task.startTime = [NSDate dateWithTimeIntervalSince1970:[currentElementValue doubleValue]];			
		}
	}
	else if([elementName isEqualToString:@"starttime"]) 
	{
		if (task.startTime != nil)
		{
			//if ([currentElementValue isEqualToString:@""])
			if ([currentElementValue isEqualToString:@"0"])
			{
				task.startTime = [[Settings getInstance] getWorkingStartTimeForDate:task.startTime];
			}
			else 
			{
				//NSString *dtStr = [NSString stringWithFormat:@"%@ %@", [Common getFullDateString2:task.startTime], currentElementValue];
				
				//task.startTime = [Common getDateByFullString2:dtStr];
				NSDate *startTime = [NSDate dateWithTimeIntervalSince1970:[currentElementValue doubleValue]];
				task.startTime = [Common copyTimeFromDate:startTime toDate:task.startTime];
				
			}
		}		
		
	}
	else if([elementName isEqualToString:@"duedate"]) 
	{
		//task.dueTime = [Common getDateByString:currentElementValue];
		if ([currentElementValue isEqualToString:@"0"])
		{
			task.dueTime = nil;
		}
		else 
		{			
			task.dueTime = [NSDate dateWithTimeIntervalSince1970:[currentElementValue doubleValue]];
		}
	}
	else if([elementName isEqualToString:@"duetime"]) 
	{
		if (task.dueTime != nil)
		{
			//if ([currentElementValue isEqualToString:@""])
			if ([currentElementValue isEqualToString:@"0"])
			{
				task.dueTime = [[Settings getInstance] getWorkingEndTimeForDate:task.dueTime];
			}
			else 
			{
				//NSString *dtStr = [NSString stringWithFormat:@"%@ %@", [Common getFullDateString2:task.dueTime], currentElementValue];
				
				//task.dueTime = [Common getDateByFullString2:dtStr];
				
				NSDate *dueTime = [NSDate dateWithTimeIntervalSince1970:[currentElementValue doubleValue]];
				task.dueTime = [Common copyTimeFromDate:dueTime toDate:task.dueTime];
			}
		}		
	}
	else if([elementName isEqualToString:@"modified"]) 
	{
		//task.modifiedTime = [Common getDateByFullString:currentElementValue];
		task.modifiedTime = [NSDate dateWithTimeIntervalSince1970:[currentElementValue doubleValue]];		
	}
	else if([elementName isEqualToString:@"completed"]) 
	{
		//if ([currentElementValue isEqualToString:@""])
		if ([currentElementValue isEqualToString:@"0"])
		{
			task.completedTime = nil;
		}
		else 
		{
			//task.completedTime =  [[Settings getInstance] getWorkingEndTimeForDate:[Common getDateByString:currentElementValue]];
			NSDate *completedTime = [NSDate dateWithTimeIntervalSince1970:[currentElementValue doubleValue]];
			
			//////printf("TD complete time:%s, task:%s\n", [[completedTime description] UTF8String], [task.title UTF8String]);
			
			//task.completedTime =  [[Settings getInstance] getWorkingEndTimeForDate:completedTime];
			task.completedTime = completedTime;
		}			
	}	
	else if([elementName isEqualToString:@"priority"])
	{
		task.priority = [currentElementValue intValue];
	}
	else if([elementName isEqualToString:@"length"])
	{
		task.length = [currentElementValue intValue];
	}
	else if([elementName isEqualToString:@"repeatfrom"])
	{
		task.repeatFrom = [currentElementValue intValue];
	}
	else if([elementName isEqualToString:@"repeat"])
	{
		//task.repeat = [currentElementValue intValue];
		task.rep_advanced = currentElementValue;
	}
/*	else if([elementName isEqualToString:@"rep_advanced"])
	{
		task.rep_advanced = currentElementValue;
	}
*/
	else if([elementName isEqualToString:@"star"])
	{
		task.star = [currentElementValue intValue];
	}	
	else if([elementName isEqualToString:@"meta"])
	{
		task.meta = currentElementValue;
	}	
	else if([elementName isEqualToString:@"error"]) 
	{
		self.error = currentElementValue;
	}	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[currentElementValue appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError 
{
}

@end
