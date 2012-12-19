//
//  SDWSection.h
//  SmartCal
//
//  Created by Mac book Pro on 2/9/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SDWSite @"http://mysmartday.com"
//#define SDWSite @"http://174.136.110.108"
#define SDWAppRegId @"5c14dff59eec0a9b9431e044e59278ae"

@interface SDWSection : NSObject

@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *deviceUUID;

@property (nonatomic, retain) NSDate *lastTokenAcquireTime;

-(BOOL)checkTokenExpired;
-(void)refreshKey;
-(void)reset;

@end
