//
//  TDAccountParser.m
//  SmartCal
//
//  Created by MacBook Pro on 10/6/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "TDAccountParser.h"

#import "Common.h"
#import "TDAccount.h"

@implementation TDAccountParser

@synthesize account;
@synthesize error;

- (id)init
{
	if (self = [super init])
	{
		self.account = nil;
		
		self.error = nil;
		
		currentElementValue = [[NSMutableString alloc] initWithString:@""];
	}
	
	return self;
}

- (void)dealloc 
{
	self.account = nil;
	
	self.error = nil;
	
	[currentElementValue release];
	
	[super dealloc];
}

- (void) reset
{	
	self.account = nil;
	
	self.error = nil;
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
	if([elementName isEqualToString:@"account"]) 
	{
		//self.account = [[[TDAccount alloc] init] autorelease];
		self.account = [[TDAccount alloc] init];
		[self.account release];
	}
	
	[currentElementValue setString:@""];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
	//if([elementName isEqualToString:@"lastaddedit"]) 
	if([elementName isEqualToString:@"lastedit_task"]) 
	{
		//self.account.lastAddEditTime = [Common getDateByFullString:currentElementValue];
		self.account.lastAddEditTime = [NSDate dateWithTimeIntervalSince1970:[currentElementValue doubleValue]];
	}	
	//else if([elementName isEqualToString:@"lastdelete"]) 
	else if([elementName isEqualToString:@"lastdelete_task"]) 
	{
		//self.account.lastDeleteTime = [Common getDateByFullString:currentElementValue];
		self.account.lastDeleteTime = [NSDate dateWithTimeIntervalSince1970:[currentElementValue doubleValue]];
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
	self.account = nil;
}

@end
