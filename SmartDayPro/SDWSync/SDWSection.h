//
//  SDWSection.h
//  SmartCal
//
//  Created by Mac book Pro on 2/9/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define SDWSite @"http://mysmartday.com"
//#define SDWSite @"http://50.19.33.18"
#define SDWSite @"http://mysmartday.com:8087"
#define SDWAppRegId @"5c14dff59eec0a9b9431e044e59278ae"
#define SDP_Alias @"ad944424393cf309efaf0e70f1b125cb"

@interface SDWSection: NSObject

@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *deviceUUID;

@property (nonatomic, retain) NSDate *lastTokenAcquireTime;

-(BOOL)checkTokenExpired;
-(void)refreshKey;
-(void)reset;

@end
