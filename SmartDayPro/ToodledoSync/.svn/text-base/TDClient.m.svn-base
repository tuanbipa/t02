//
//  TDClient.m
//  SmartCal
//
//  Created by MacBook Pro on 9/30/10.
//  Copyright 2010 LCL. All rights reserved.
//
#import "TDClient.h"
#import "Settings.h"
#import "TDKeyParser.h"

#import "TDFolderParser.h"
#import "TDFolder.h"

#import "TDTaskParser.h"
#import "TDTask.h"

#import "TDFetchParam.h"
#import "TDSync.h"
#import "TDSyncSection.h"

TDClient *_tdClientSingleton;

@implementation TDClient

@synthesize xmlData;
@synthesize userInfo;

- (void) reset
{
	self.xmlData = nil;	
	self.userInfo = nil;
}

- (id)init
{
	if (self = [super init])
	{
		[self reset];
	}
	
	return self;
}

- (void)dealloc 
{
	[self reset];
	
	[super dealloc];
}

- (void)fetchData:(TDFetchParam *)param delegate:(id)delegate didFinishSelector:(SEL)finishedSEL didFailSelector:(SEL)failedSEL userInfo:(NSObject *)usrInfo
{
	NSString *url = nil;
	
	BOOL post = NO;
	
	switch (param.command) 
	{
		case FETCH_USER_ID:
		{
			url = [NSString stringWithFormat:@"http://api.toodledo.com/2/account/lookup.php?f=xml;"];
		}
			break;
		case FETCH_TOKEN:
		{
			url = [NSString stringWithFormat:@"http://api.toodledo.com/2/account/token.php?f=xml;"];
		}
			break;
		case FETCH_ALL_FOLDER:
		{
			url = [NSString stringWithFormat:@"http://api.toodledo.com/2/folders/get.php?f=xml;"];
		}
			break;
		case FETCH_ADD_FOLDER:
		{
			url = [NSString stringWithFormat:@"http://api.toodledo.com/2/folders/add.php?f=xml;fields=folder,meta;"];
		}
			break;	
		case FETCH_EDIT_FOLDER:
		{
			url = [NSString stringWithFormat:@"http://api.toodledo.com/2/folders/edit.php?f=xml;"];
		}			
			break;					
		case FETCH_DELETE_FOLDER:
		{
			url = [NSString stringWithFormat:@"http://api.toodledo.com/2/folders/delete.php?f=xml;"];
		}			
			break;
		case FETCH_TASK:
		{
			NSString *fields = @"folder,tag,note,startdate,starttime,duedate,duetime,length,repeatFrom,repeat,star,parent,children,meta";
			
			url = [NSString stringWithFormat:@"http://api.toodledo.com/2/tasks/get.php?f=xml;fields=%@;", [TDSync encodeString:fields]];
		}
			break;
		case FETCH_ACCOUNT:
		{
			url = [NSString stringWithFormat:@"http://api.toodledo.com/2/account/get.php?f=xml;"];
		}
			break;
		case FETCH_ADD_TASK:
		{
			url = [NSString stringWithFormat:@"http://api.toodledo.com/2/tasks/add.php?f=xml;fields=folder,star,meta;"];
			
			post = YES;
		}
			break;
		case FETCH_EDIT_TASK:
		{
			url = [NSString stringWithFormat:@"http://api.toodledo.com/2/tasks/edit.php?f=xml;fields=folder,star;"];
			
			post = YES;
		}			
			break;
			
		case FETCH_ALL_DELETED_TASK:
		{
			url = [NSString stringWithFormat:@"http://api.toodledo.com/2/tasks/deleted.php?f=xml;"];
		}
			break;
		case FETCH_DELETE_TASK:
		{
			url = [NSString stringWithFormat:@"http://api.toodledo.com/2/tasks/delete.php?f=xml;"];
			
			post = YES;
		}			
			break;
	}
	
	TDSync *tdSync = [TDSync getInstance];
	
	url = [NSString stringWithFormat:@"%@key=%@;", url, tdSync.syncSection.key];
	
	if (!post)
	{
		url = [url stringByAppendingString:param.param];
	}
	
	////printf("URL: %s\n", [url UTF8String]);
		
	NSMutableURLRequest *newURLRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
	
	if (post)
	{
        ////printf("param = %s\n", [param.param UTF8String]);
        
		[newURLRequest setHTTPMethod:@"POST"];
		
		NSData *body = [param.param dataUsingEncoding:NSUTF8StringEncoding];
		[newURLRequest setHTTPBody:body];
		[newURLRequest addValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];			
	}
	
	
	//[[[NSURLConnection alloc] initWithRequest:newURLRequest delegate:self] autorelease];	
	
    [NSThread detachNewThreadSelector:@selector(fetch:) toTarget:self  
                           withObject:[NSDictionary dictionaryWithObjectsAndKeys:
									   newURLRequest,@"request",
									   delegate, @"delegate",
									   [NSValue valueWithBytes:&finishedSEL objCType:@encode(SEL)], @"finishedSEL",
									   [NSValue valueWithBytes:&failedSEL objCType:@encode(SEL)], @"failedSEL",
									   usrInfo, @"userInfo", nil]];
	
}

- (void) fetch:(NSDictionary *)dictionary
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
	
	NSURLRequest *request = [dictionary objectForKey:@"request"]; 
	id delegate = [dictionary objectForKey:@"delegate"]; 
	SEL finishedSEL;
	[(NSValue *)[dictionary objectForKey:@"finishedSEL"] getValue:&finishedSEL];
	SEL failedSEL;
	[(NSValue *)[dictionary objectForKey:@"failedSEL"] getValue:&failedSEL];
	
	NSObject *usrInfo = [dictionary objectForKey:@"userInfo"];
	
    NSURLResponse *response = nil;  
    NSError *error = nil;  
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];  
    if(error)  
    {  
		if (failedSEL) {
			[delegate performSelector:failedSEL withObject:error];
		}		
    }  
    else  
    {  
		if (finishedSEL) {
			[delegate performSelector:finishedSEL withObject:data withObject:usrInfo];
		}
    }  
    [pool release]; 	
}

/*
#pragma mark NSURLConnection delegate methods

// The following are delegate methods for NSURLConnection. Similar to callback functions, this is how the connection object,
// which is working in the background, can asynchronously communicate back to its delegate on the thread from which it was
// started - in this case, the main thread.

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.xmlData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [xmlData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
    if (_failedSEL) {
		[_delegate performSelector:_failedSEL withObject:error];
    }	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (_finishedSEL) {
		[_delegate performSelector:_finishedSEL withObject:self.xmlData withObject:self.userInfo];
    }
	
}
*/

#pragma mark Public methods

+(id)getInstance
{
	if (_tdClientSingleton == nil)
	{
		_tdClientSingleton = [[TDClient alloc] init];
	}
	
	return _tdClientSingleton;
}

+(void)free
{
	if (_tdClientSingleton != nil)
	{
		[_tdClientSingleton release];
		
		_tdClientSingleton = nil;
	}	
}

@end
