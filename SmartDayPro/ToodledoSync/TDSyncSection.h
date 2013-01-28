//
//  TDSyncSection.h
//  SmartCal
//
//  Created by MacBook Pro on 10/7/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TDSyncSection : NSObject {
	NSString *userId;
	NSString *token;
	NSString *key;
	
	NSDate *lastTokenAcquireTime;
}

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *key;

@property (nonatomic, retain) NSDate *lastTokenAcquireTime;

+(NSString *)md5:(NSString *)str;
-(BOOL)checkTokenExpired;
-(void)refreshKey;

@end
