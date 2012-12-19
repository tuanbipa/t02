//
//  TDFolderParser.m
//  SmartCal
//
//  Created by MacBook Pro on 9/30/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "TDFolderParser.h"

#import "TDFolder.h"

@implementation TDFolderParser

@synthesize folders;
@synthesize folder;
@synthesize error;

- (id)init
{
	if (self = [super init])
	{
		self.folders = nil;
		self.folder = nil;
		self.error = nil;
		
		currentElementValue = [[NSMutableString alloc] initWithString:@""];
	}
	
	return self;
}

- (void)dealloc 
{
	self.folders = nil;
	self.folder = nil;
	self.error = nil;	
	
	[currentElementValue release];
	
	[super dealloc];
}

- (void) reset
{
	/*
	if (folder != nil)
	{
		[folder release];
	}

	folder = nil;
*/
	self.folder = nil;
	self.folders = nil;
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
	if([elementName isEqualToString:@"folders"]) 
	{
		//self.folders = [[[NSMutableArray alloc] init] autorelease];
		self.folders = [NSMutableArray arrayWithCapacity:10];
	}
	else if([elementName isEqualToString:@"folder"]) 
	{
		//folder = [[TDFolder alloc] init];
		self.folder = [[TDFolder alloc] init];
		[self.folder release];
	}
	
	[currentElementValue setString:@""];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
	if([elementName isEqualToString:@"folders"])
		return;
	
	if([elementName isEqualToString:@"id"]) 
	{
		folder.id = currentElementValue;
	}
	else if([elementName isEqualToString:@"folder"]) 
	{
		folder.name = currentElementValue;
		
		[self.folders addObject:folder];
		/*
		[folder release];
		folder = nil;
		*/
	}
	else if([elementName isEqualToString:@"archived"]) 
	{
        folder.archived = [currentElementValue isEqualToString:@"1"];
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
