//
//  TDKeyParser.m
//  SmartCal
//
//  Created by MacBook Pro on 10/4/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "TDKeyParser.h"


@implementation TDKeyParser

@synthesize key;
@synthesize error;
@synthesize errorCode;

- (id)init
{
	if (self = [super init])
	{
		self.key = nil;
		self.error = nil;
		self.errorCode = 0;
		
		currentElementValue = [[NSMutableString alloc] initWithString:@""];
	}
	
	return self;
}

- (void)dealloc 
{
	self.key = nil;
	self.error = nil;
	
	[currentElementValue release];
	
	[super dealloc];
}

- (void) reset
{
	self.key = nil;
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
	[currentElementValue setString:@""];
	
	if ([elementName isEqualToString:@"error"])	
	{
		self.errorCode = [[attributeDict objectForKey:@"id"] intValue];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
	if([elementName isEqualToString:@"userid"] 
	   || [elementName isEqualToString:@"token"]
	   || [elementName isEqualToString:@"added"]
	   ) 
	{
		self.key = currentElementValue;
	}
	else if ([elementName isEqualToString:@"error"])
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
