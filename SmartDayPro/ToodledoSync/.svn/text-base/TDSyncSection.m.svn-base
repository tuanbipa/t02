//
//  TDSyncSection.m
//  SmartCal
//
//  Created by MacBook Pro on 10/7/10.
//  Copyright 2010 LCL. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>


#import "TDSyncSection.h"
#import "Settings.h"

@implementation TDSyncSection

@synthesize userId;
@synthesize token;
@synthesize key;
@synthesize lastTokenAcquireTime;

- (id)init
{
	if (self = [super init])
	{
		self.lastTokenAcquireTime = nil;
	}
	
	return self;
}

- (void)dealloc 
{
	self.userId = nil;
	self.token = nil;
	self.key = nil;
	
	self.lastTokenAcquireTime = nil;
	
	[super dealloc];
}

-(NSString *)generateKey
{
	if (self.token != nil && self.userId != nil)
	{
		//return [NSString stringWithString:[TDSyncSection md5:[[[TDSyncSection md5:[[Settings getInstance] tdPassword]] stringByAppendingString:self.token] stringByAppendingString:self.userId]]];
		
		NSString *md5pwd = [TDSyncSection md5:[[Settings getInstance] tdPassword]];
		
		return [TDSyncSection md5:[NSString stringWithFormat:@"%@%@%@", md5pwd, ToodledoAppToken, self.token]];
	}
	
	return @"";
}

-(void)refreshKey
{
	self.key = [self generateKey];
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

+(NSString *)md5:(NSString *)str {
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	NSString *ret= [NSString stringWithFormat:
					@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
					result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
					result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
					];
	return ret;
}

@end
