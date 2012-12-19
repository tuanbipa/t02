//
//  TDFolder.m
//  SmartCal
//
//  Created by MacBook Pro on 9/30/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "TDFolder.h"


@implementation TDFolder

@synthesize id;
@synthesize name;
@synthesize archived;

- (id)init
{
	if (self = [super init])
	{
		self.id = @"";
		self.name = @"";
        self.archived = NO;
	}
	
	return self;
}

- (void)dealloc 
{
	self.id = nil;
	self.name = nil;
	
	[super dealloc];
}

- (id) copyWithZone:(NSZone*) zone{
	TDFolder *copy = [[TDFolder alloc] init];
	
	copy.id = self.id;
	copy.name = self.name;
	
	return copy;
}

@end
