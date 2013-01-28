//
//  SDWSection.m
//  SmartCal
//
//  Created by Mac book Pro on 2/9/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import "SDWSection.h"

#import "Common.h"
#import "Settings.h"

@implementation SDWSection

@synthesize token;
@synthesize key;
@synthesize lastTokenAcquireTime;
@synthesize deviceUUID;

- (id)init
{
	if (self = [super init])
	{
		[self reset];
        
        self.deviceUUID = nil;
	}
	
	return self;
}

-(void)reset
{
	self.token = nil;
	self.key = nil;
	
	self.lastTokenAcquireTime = nil;
}

- (void)dealloc 
{
    [self reset];
    
    self.deviceUUID = nil;
	
	[super dealloc];
}

-(NSString *)generateKey:(NSString *)sdwAppRegID
{
	if (self.token != nil)
	{
		NSString *md5pwd = [Common md5:[[Settings getInstance] sdwPassword]];
		
		return [Common md5:[NSString stringWithFormat:@"%@%@%@", md5pwd, sdwAppRegID, self.token]];
	}
	
	return @"";
}

-(void)refreshKey
{
	self.key = [self generateKey:SDWAppRegId];
}

-(BOOL)checkTokenExpired
{
	if (self.lastTokenAcquireTime != nil)
	{
		if ([self.lastTokenAcquireTime timeIntervalSinceNow]*(-1) < 4*3600)
		{
			return NO;
		}
	}
	
	return YES;
}

@end
