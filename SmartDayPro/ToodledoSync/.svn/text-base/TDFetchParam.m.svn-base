//
//  TDFetchParam.m
//  SmartCal
//
//  Created by MacBook Pro on 10/5/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "TDFetchParam.h"


@implementation TDFetchParam

@synthesize command;

@synthesize param;

- (id)init
{
	if (self = [super init])
	{
		self.param = nil;
	}
	
	return self;
}

- (void)dealloc 
{
	self.param = nil;
	
	[super dealloc];
}

+ (TDFetchParam *) fetchParamWithCommand:(NSInteger)command param:(NSString *)param
{
	TDFetchParam *fparam = [[[TDFetchParam alloc] init] autorelease];
	
	fparam.command = command;
	fparam.param = param;
	
	return fparam;
}
 
@end
